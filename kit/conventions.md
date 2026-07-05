# Laravel Engineering Conventions (opinionated)

Always-on rules for AI-assisted Laravel work. Deeper patterns + worked examples live in
on-demand **skills** (listed at the end) — this file stays lean on purpose. A project's
own `conventions.md` overrides this.

> Stack: **detect from the project's `composer.json`** — Laravel + PHP version, and whether
> Pest / Pint / Larastan are installed. Apply the idioms that version supports: these rules assume
> **PHP 8.1+** (backed Enums, typed props, constructor promotion); on older PHP fall back to what it
> has (class constants pre-8.1, no promotion pre-8.0, array-config not Enums). Never assume — check.

## How we work — SPDD + verification
Prompt (REASONS Canvas) is the source of truth; code is its artifact. Describe a feature in plain
words → the **`spdd`** skill drives the pipeline (story→analysis→canvas→code→tests→review); the
`/spdd-*` commands are its building blocks. One canvas per feature under `spdd/<NNN>-<slug>/`, it lives on.
Golden rule: **when reality diverges, fix the prompt first, then the code.**
- Behavior change → `/spdd-prompt-update` → `/spdd-generate`.
- Refactor (no behavior change) → refactor → `/spdd-sync`.
- Existing code with no canvas (legacy) → `/spdd-reverse` first.

Review **intent** (story/analysis/canvas), not 500-line diffs. Code is gated by layers, not eyeballs:
Pint (style) → Larastan (lvl 8) → Pest (ACs as tests) → `/spdd-code-review` (intent).
If a script can't check it, it isn't done.

## Architecture — thin edges, fat domain
Flow: **Route → Form Request (validate+authorize) → Controller (thin) → Action/Service (logic) → Eloquent → API Resource/View.**
- Controllers orchestrate only — no logic, no queries beyond a trivial `find`. Invokable for non-CRUD.
- Form Requests own validation + authorization. Never validate inline.
- Actions = one public `handle()`, constructor-injected deps. Default unit of business logic.
- Services = stateful / external collaborators (mail, payments, S3).
- API Resources shape every JSON response. Never return a model directly from a controller.
- Policies own authz. Eloquent for data; repository pattern only with a real 2nd implementation.

→ patterns, wiring (Strategy/Factory), full examples: **laravel-architecture** skill.

```
app/
├── Actions/   Http/{Controllers,Requests,Resources}/   Models/
├── Policies/  Services/   Support/   (value objects, enums)
```

## Code rules (non-negotiable)
- `declare(strict_types=1);` every file. Typed props/params/returns. No bare `mixed`.
- Backed **Enums** over string constants. **Value Objects** for money/quantities — never float currency.
- Mass-assignment via `$fillable` allow-list, never `$guarded = []`.
- No N+1: eager-load relations; assume `preventLazyLoading()` in non-prod.
- No logic in migrations / blade / queued job `handle()` beyond dispatch+call.
- No `env()` outside config files — read via `config('...')`.
- No comments — code explains itself (clear names, small methods). Add one only when *why* genuinely isn't derivable from the code (a non-obvious invariant or external constraint). No marker comments. Any comment that is justified must be English and as short and simple as possible.
- Everything in code is **English** — class/method/variable/column names, enum cases, keys. Only user-facing strings get translated (via lang files).
- Names: Models singular, tables plural, Actions verb-first (`SuspendAccountAction`), Enums suffixed `Enum` (`RoleEnum`, `PaymentTypeEnum`), booleans `is/has/can`.

## Testing
Pest, feature-first. Each acceptance criterion → one test, concrete numbers, Given/When/Then in the name.
Unit-test the domain (Actions, Value Objects, math) directly. `RefreshDatabase` + factories. Arch tests enforce the rules above.

→ Pest patterns, fakes, arch tests, examples: **laravel-testing** skill.

## Laziness (ponytail)
First rung that works: stdlib → native Laravel → already-installed package → a few lines → only then a new abstraction/dependency.
No interface with one implementation. No service for a one-liner. Record deliberate shortcuts (and their upgrade path) in the REASONS Canvas Approach/Safeguards — not in code comments.

## Commits
- Conventional Commits, always English, imperative subject ≤50 chars: `feat:`, `fix:`, `wip:`, `refactor:`, `test:`, `docs:`, `chore:`, `perf:`.
- Body only when *why* isn't obvious. **No co-author, no "Generated with" trailers** — clean message only.
- Several agents may work the repo at once — don't be thrown by changes you didn't make. Focus only on your task: stage its files by explicit path (never `git add -A`/`.`), commit only those, leave the rest untouched.

## Security (never simplified away)
Validate at the boundary (Form Requests); authorize via Policies. Money = Value Object / integer minor units, never float.
No secrets in code/logs — `config()` + env. Mass-assignment allow-list. Signed URLs for public-ish links. Rate-limit auth + public APIs.

---
On-demand skills: **laravel-architecture · laravel-testing · laravel-email · laravel-docker · business-context · spdd-prompt**. Pull when relevant; don't inline their content here.
