---
name: laravel-architecture
description: Opinionated Laravel application architecture — where logic lives and how to wire it. When/how to use Controllers, Actions, Services, Form Requests, API Resources, Policies, Enums, Value Objects, and patterns like Strategy/Factory. Use when designing or structuring a Laravel feature, deciding where code belongs, or reviewing architecture.
---

# Laravel architecture (the deep version)

conventions.md has the one-line rules. This skill is the worked reference: when to reach for
each construct, how to wire patterns, and the anti-patterns to refuse.

## Where does logic go? (decision table)
| Need | Put it in | Not in |
|---|---|---|
| Validate + authorize a request | **Form Request** | controller, action |
| One use-case / write operation | **Action** (`handle()`) | controller, model |
| Stateful or external integration (mail, payment, S3) | **Service** | action (call the service from one) |
| Shape JSON output | **API Resource** | controller returning a model |
| Authorization rule | **Policy** | inline `if` checks |
| Fixed set of values | **backed Enum** | string constants |
| Money / quantity / typed value | **Value Object** | float / raw int passed around |
| Background work | **Queued Job** (thin: call an Action) | fat `handle()` |
| Read data | **Eloquent** (scopes for reuse) | repository (unless real 2nd impl) |

## Request flow
```
Route → FormRequest (validate+authorize) → Controller (orchestrate) → Action (logic)
      → Eloquent (persist) → API Resource (output)
```
The controller is glue: resolve the Action, hand it validated data, return a Resource.

```php
final class IssueInvoiceController
{
    public function __construct(private readonly IssueInvoiceAction $issue) {}

    public function __invoke(IssueInvoiceRequest $request): JsonResponse
    {
        $invoice = $this->issue->handle(
            customer: $request->customer(),
            lines: $request->lines(),
        );
        return InvoiceResource::make($invoice)->response()->setStatusCode(201);
    }
}
```

## Action shape
One job, one public method, dependencies injected. Returns a domain result, not a response.
```php
final class IssueInvoiceAction
{
    public function __construct(private readonly InvoiceNumberGenerator $numbers) {}

    public function handle(Customer $customer, Collection $lines): Invoice
    {
        // domain rules live here; throw domain exceptions on invariant breach
        return DB::transaction(fn () => Invoice::create([...]));
    }
}
```

## Strategy + Factory (the "varies by type" pattern)
Use when behavior changes by a value (plan, channel, country) and is likely to grow. One
interface, one implementation per case, a factory to resolve. Don't reach for it for two
cases that will never expand — that's the ponytail trap.

```php
interface BillingStrategy { public function bill(UsageRecord $usage): Money; }

final class StandardPlanBilling implements BillingStrategy { /* quota + overage */ }
final class PremiumPlanBilling  implements BillingStrategy { /* split rates */ }

final class BillingStrategyFactory
{
    public function for(Plan $plan): BillingStrategy
    {
        return match ($plan) {
            Plan::Standard => app(StandardPlanBilling::class),
            Plan::Premium  => app(PremiumPlanBilling::class),
        };
    }
}
```
`Plan` is a backed Enum. Adding a plan = new Enum case + new strategy class; the factory's
`match` makes the compiler/static analysis force you to handle it. Bind shared deps in a ServiceProvider.

## Value Object for money (never float)
```php
final readonly class Money
{
    public function __construct(public int $minorUnits, public string $currency = 'EUR') {}
    public function add(self $o): self { /* assert same currency */ }
    public function format(): string { return number_format($this->minorUnits / 100, 2); }
}
```
Persist as integer minor units; cast on the model. Currency math stays exact.

## Anti-patterns (refuse these)
- Business logic in controllers, models (beyond accessors/scopes), migrations, or blade.
- `$guarded = []` — always allow-list with `$fillable`.
- Returning Eloquent models straight from controllers (leaks columns, no versioned contract).
- Repository interface with a single Eloquent implementation — indirection for nothing.
- A Service/Action that's a one-line passthrough — inline it.
- Generic `Helper`/`Utils` god-classes — name things by what they do.

## ponytail boundary
Reach for the lowest rung that holds. A scope beats a repository; an Enum beats a strategy
for two fixed cases; a cast beats a Value Object for a plain string. Add structure when a
second real case or a real invariant shows up — not before.
