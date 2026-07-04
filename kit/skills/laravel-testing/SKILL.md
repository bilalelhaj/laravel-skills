---
name: laravel-testing
description: Opinionated Pest testing for Laravel — feature-first tests, turning acceptance criteria into tests, factories, fakes, architecture tests, and CI coverage. Use when writing or structuring tests for a Laravel app, mapping ACs to tests, or setting up the test suite.
---

# Testing Laravel with Pest (the deep version)

conventions.md has the rule (feature-first, AC→test). This skill is the how.

## The pyramid, inverted toward features
- **Feature tests** (most of them): hit the real route, assert status + JSON shape + computed
  values. Highest confidence per test. Default choice.
- **Unit tests**: the domain — Actions, Value Objects, pricing/date math. Fast, no DB boot.
- **Arch tests**: enforce conventions structurally so review doesn't have to.

## AC → test (one per criterion, concrete numbers)
Name the test as the Given/When/Then so a failure reads like the spec.
```php
it('standard plan: 30k tokens with 90k of 100k quota used bills 20k overage at 0.20', function () {
    $customer = Customer::factory()->standard()->create();
    UsageRecord::factory()->for($customer)->create(['tokens' => 90_000]);

    $response = $this->postJson('/api/usage', [
        'customer_id' => $customer->id,
        'model_id' => 'fast-model',
        'tokens' => 30_000,
    ]);

    $response->assertCreated()
        ->assertJsonPath('data.included_tokens', 10_000)
        ->assertJsonPath('data.overage_tokens', 20_000)
        ->assertJsonPath('data.charge', '0.20');
});
```

## Boundary + error scenarios (always include)
```php
it('rejects a missing modelId', fn () => $this->postJson('/api/usage', ['tokens' => 10])
    ->assertStatus(422)->assertJsonValidationErrorFor('model_id'));

it('404s an unknown customer', fn () => $this->postJson('/api/usage', [...])->assertNotFound());
it('403s when not the owner', fn () => /* acting as other user */ ->assertForbidden());
```

## Setup conventions
- `uses(RefreshDatabase::class)` in `tests/Pest.php` for the Feature suite.
- **Factories** for all setup; never seeders in tests. Add factory **states** for domain
  variants (`->standard()`, `->premium()`) instead of inline attribute soup.
- Datasets for table-driven cases:
```php
it('charges :rate per 1k for :model', function (string $model, string $rate) { /* ... */ })
    ->with([['fast-model', '0.01'], ['reasoning-model', '0.03']]);
```

## Fakes — assert the side effect, don't perform it
```php
Mail::fake();      // then Mail::assertQueued(InvoicePaid::class)
Queue::fake();     // then Queue::assertPushed(GenerateReport::class)
Event::fake();     Notification::fake();     Http::fake();   Storage::fake();
```
Freeze time for date math: `$this->travelTo(now()->startOfMonth())`.

## Architecture tests (enforce the rules)
```php
arch('controllers stay thin')
    ->expect('App\Http\Controllers')->not->toUse(['Illuminate\Support\Facades\DB']);

arch('strict types everywhere')->expect('App')->toUseStrictTypes();
arch('actions are final')->expect('App\Actions')->toBeClasses()->toBeFinal();
arch('no debug leftovers')->expect(['dd', 'dump', 'ray', 'var_dump'])->not->toBeUsed();
```

## CI
`./vendor/bin/pest --ci --coverage` with SQLite in-memory (see `ci/github-actions/ci.yml`).
Add `--min=80` once coverage is healthy. Shard slow suites with `--shard=1/4`.

## ponytail for tests
Test behavior at the boundary, not every private method. One feature test through the route
often covers what five unit tests would. Don't mock what you own — use the real Action with a
fake DB. Trivial one-liners need no test; money/auth/parsing paths always do.
