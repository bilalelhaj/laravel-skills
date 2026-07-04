---
description: Generate the REASONS Canvas — the structured prompt (SPDD step 4)
argument-hint: <@analysis.md or @story.md>
---

You are running **SPDD step 4: REASONS Canvas**. Translate the agreed analysis into an
**executable blueprint** across all seven REASONS dimensions, combined with the current
state of the codebase. This is the structured prompt — the source of truth.

## Input
$ARGUMENTS  ← the analysis (preferred) or a direct requirement.

## The REASONS Canvas (fill every section)
**Abstract (intent & design)**
- **R — Requirements**: the problem + Definition of Done (testable).
- **E — Entities**: domain entities, relationships, invariants → map to Eloquent Models,
  migrations, Enums, Value Objects.
- **A — Approach**: the strategy. Name the Laravel/OO pattern and why (e.g. Strategy via an
  interface bound in a ServiceProvider + a Factory to resolve per plan). State trade-offs accepted.
- **S — Structure**: where the change lives — exact files/classes to add or touch, and
  their dependencies. Honour the Route→Request→Controller→Action/Service→Eloquent→Resource flow.

**Specific (execution)**
- **O — Operations**: break the strategy into concrete, ordered, testable steps. Be precise
  down to **class names, method signatures, parameter and return types**, and execution order.
  Each operation should be independently verifiable.

**Governance**
- **N — Norms**: cross-cutting standards from `conventions.md` — strict types, Form Request
  validation, API Resources for output, Enums, no N+1, naming, observability/logging.
- **S — Safeguards**: non-negotiable boundaries — invariants (money never float), backward
  compatibility (existing rows/migrations), security (authz via Policy, mass-assignment
  allow-list), performance limits, and explicit scope-out.

## Rules
- Operations must correspond 1:1 with the code that will be generated — no hidden behavior.
- Stay inside the scope from the story/analysis. Do not invent features.

## Output
Write `spdd/<NNN>-<slug>/canvas.md` using `spdd-templates/reasons-canvas.md`.
Print the path and a short summary of the Approach + Operations. Tell the user that to
change the canvas they should NOT hand-edit it — use `/spdd-prompt-update`. Suggest:
`/spdd-generate @spdd/<NNN>-<slug>/canvas.md`.
