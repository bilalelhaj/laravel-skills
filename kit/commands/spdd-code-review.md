---
description: Review the diff against the canvas — intent alignment + verification layers
argument-hint: [@canvas.md] [base-branch]
---

You are running **SPDD: code-review**. You check the *mechanical* alignment between the
REASONS Canvas and the code diff. You do NOT replace human review of whether the canvas
itself still matches business intent — flag that for the human.

## Input
$ARGUMENTS  ← optionally the canvas + a base branch (default: `main`).
Diff to review: `git diff <base>...HEAD` (or the staged/working diff if no base).

## Checks (report one finding per line: `path:line: <severity>: <problem>. <fix>.`)
1. **Intent alignment** — does each changed file map to an Operation in the canvas? Flag
   code with no canvas backing (scope creep) and Operations with no code (missing work).
2. **Norms** — strict types, Form Request validation, API Resource output, Enums over
   string constants, no N+1 / lazy loading, naming, no `env()` outside config, no logic in
   controllers/migrations/blade.
3. **Safeguards** — invariants (money not float), backward compat (migrations, nullable),
   security (authz via Policy, mass-assignment allow-list, no hardcoded secrets), scope-out respected.
4. **Verification layers** — are there Pest tests for each AC? Would Pint/Larastan pass?
   Flag magic numbers, missing tests, untyped boundaries.

## Output
- A findings list grouped by severity (blocker / warning / nit). No praise, no restating good code.
- Then a single **VERDICT**: `ALIGNED` (intent matches, layers green) or `DRIFT` with the
  top reasons. If DRIFT is a behavior bug → `/spdd-prompt-update`; if it's a code smell →
  refactor then `/spdd-sync`.
- Skip pure formatting nits — Pint owns those.
