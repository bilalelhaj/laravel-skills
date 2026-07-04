---
description: Strategic analysis — scan the Laravel codebase, surface domain/risks (SPDD step 3)
argument-hint: <@story.md>
---

You are running **SPDD step 3: Analysis**. Produce a strategic analysis grounded in the
**actual codebase** — the "what" and "why", deliberately NOT implementation detail.

## Input
$ARGUMENTS  ← the user story (or a direct requirement description).

## Task
1. **Extract domain keywords** from the story (e.g. "billing", "quota", "plan", "invoice").
2. **Scan only the relevant code** using those keywords — do not read the whole repo.
   For a Laravel project look at: `app/Models/`, `app/Actions/`, `app/Services/`,
   `app/Http/Controllers/`, `app/Http/Requests/`, `routes/`, `database/migrations/`,
   `config/`, and existing tests under `tests/`.
3. Produce an analysis covering:
   - **Domain concepts** — existing vs new, relationships, key business rules. Map each
     to concrete Laravel constructs already in the repo (which Model, which migration).
   - **Strategic approach** — solution direction, design decisions, trade-offs. Name the
     Laravel pattern (Action, Service, Strategy via interface+binding, API Resource, etc.).
   - **Risks & gaps** — ambiguities, edge cases, technical risks, backward-compat concerns
     (migrations, nullable columns, existing data), and AC coverage.

Surface edge cases the story did NOT mention. Be more thorough than the story.

## Constraints
- No method-level implementation yet. Stay at concept/strategy altitude.
- Respect `conventions.md` conventions when proposing direction.

## Output
Write `spdd/<NNN>-<slug>/analysis.md` (same folder as the story) using
`spdd-templates/analysis.md`. Print the path, then list the top risks/edge cases
for the human to confirm. Suggest: `/spdd-reasons-canvas @spdd/<NNN>-<slug>/analysis.md`.
