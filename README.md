# laravel-skills

Opinionated **Laravel + AI dev kit**. Copy `.claude/` into any Laravel project for a consistent
SPDD workflow, reusable skills, and a verification-gated CI pipeline.

## Use it

Describe a feature in plain words — no command to remember:

> "Add coupon codes to checkout."

The `spdd` skill drives the pipeline, pausing at each gate for your approval:

```
story → analysis → canvas → generate → test → review
```

You review **intent** at the gates (story / analysis / canvas); the AI drives each step.
Artifacts land in `spdd/<NNN>-<slug>/` — **one canvas per feature**, committed with the code.
Change a feature later (even a year on) → reopen its canvas via `/spdd-prompt-update`.
Existing code with no canvas → `/spdd-reverse` first.

## Install

```bash
cp -r laravel-skills/.claude /path/to/laravel-project/

# CI (optional):
cp laravel-skills/ci/github-actions/*.yml /path/to/laravel-project/.github/workflows/
cp laravel-skills/ci/pint.json laravel-skills/ci/phpstan.neon /path/to/laravel-project/
```

Per-project copy = no auto-updates; re-copy `.claude/` from a fresh pull to update.

## Building blocks (drive a step yourself)

```
/spdd-story · /spdd-analysis · /spdd-reasons-canvas · /spdd-generate
/spdd-api-test · /spdd-code-review
/spdd-prompt-update   requirements changed → fix canvas → regenerate
/spdd-sync            code refactored → sync canvas back (--check = drift report for CI)
/spdd-reverse         legacy code with no canvas → bootstrap one from the code
```

## Layout

```
.claude/
├── CLAUDE.md          always-on Laravel rules (stack auto-detected from composer.json)
├── skills/            spdd (orchestrator) · laravel-* · business-context · spdd-prompt
├── commands/          /spdd-* building blocks
└── spdd-templates/    story / analysis / canvas / test skeletons
ci/                    Pint · Larastan · GitHub Actions
```

## Golden rule

The canvas is the source of truth; code is its artifact. When reality diverges, fix the prompt
first, then the code — behavior change via `/spdd-prompt-update`, refactor via `/spdd-sync`.
