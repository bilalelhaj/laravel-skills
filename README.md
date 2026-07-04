# laravel-skills

Opinionated **Laravel + AI dev kit**. One tool-neutral source (`kit/`), compiled into any Laravel
project for your assistant of choice — **Claude Code** or **Codex** — for a consistent SPDD
workflow, reusable skills, and a verification-gated CI pipeline.

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

Non-destructive — adds our skills/commands/templates without overwriting yours, and
**appends** the conventions block instead of replacing it. Just run it bare for a guided
install, or pass flags for a non-interactive one:

```bash
./install.sh                                             # guided: asks for dir, assistant, CI
./install.sh /path/to/laravel-project                    # asks only for the assistant
./install.sh /path/to/laravel-project --target codex     # fully non-interactive
./install.sh /path/to/laravel-project --both --ci        # both assistants + CI pipeline
```

| Target | Lands as | |
|---|---|---|
| `claude` | `.claude/` | `CLAUDE.md`, `skills/`, `commands/`, `spdd-templates/` |
| `codex` | `AGENTS.md` (repo root) + `.agents/skills/` | conventions → `AGENTS.md`; each skill **and** each `/spdd-*` command → a `SKILL.md` (Codex reads both); path refs rewritten to the Codex layout |
| `both` | both of the above | |

Run without `--target` for an interactive menu; non-interactive (CI/pipe) defaults to
`claude`. Existing same-named files are kept; the conventions block is added once
(idempotent). No auto-updates: to refresh, delete the marked section and re-run.

## Building blocks (drive a step yourself)

```
/spdd-story · /spdd-analysis · /spdd-reasons-canvas · /spdd-generate
/spdd-api-test · /spdd-code-review
/spdd-prompt-update   requirements changed → fix canvas → regenerate
/spdd-sync            code refactored → sync canvas back (--check = drift report for CI)
/spdd-reverse         legacy code with no canvas → bootstrap one from the code
```

## Layout

`kit/` is the single, tool-neutral source; `install.sh` compiles it into `.claude/` (Claude Code)
or `AGENTS.md` + `.agents/` (Codex), rewriting path references to match.

```
kit/                   tool-neutral source of truth
├── conventions.md     always-on Laravel rules (installed as CLAUDE.md / AGENTS.md)
├── skills/            spdd (orchestrator) · laravel-* · business-context · spdd-prompt
├── commands/          /spdd-* building blocks
└── spdd-templates/    story / analysis / canvas / test skeletons
ci/                    Pint · Larastan · GitHub Actions
install.sh             compiles kit/ into a target project (.claude/ and/or .agents/)
```

## Golden rule

The canvas is the source of truth; code is its artifact. When reality diverges, fix the prompt
first, then the code — behavior change via `/spdd-prompt-update`, refactor via `/spdd-sync`.
