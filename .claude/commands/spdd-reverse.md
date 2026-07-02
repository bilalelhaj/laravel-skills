---
description: Reverse-engineer existing code into a REASONS Canvas (SPDD on-ramp for legacy)
argument-hint: <area description, or @files/@dir to reverse>
---

You are running **SPDD: reverse** (code → canvas, first time). Bring an existing,
un-tracked area of the codebase under SPDD — the on-ramp for a legacy project or a feature
built before SPDD. You produce a canvas that describes the code **as it is now**, so the
normal loop (`/spdd-prompt-update` → `/spdd-generate`, or `/spdd-sync`) can take over.

## Input
$ARGUMENTS  ← the area to reverse: a description ("checkout coupon logic"), file paths, or
a directory. If nothing passed, ask which feature/area to reverse.

## Rules — read, don't invent
- **Reverse only the code that exists.** Describe actual behavior; do NOT add, fix, or
  improve anything. No new features, no refactors. If the code has a bug, the canvas records
  the buggy behavior as-is — note it, fix later via `/spdd-prompt-update`.
- **Stay bounded.** Reverse one feature/area, not the whole app. Follow the real boundaries
  (a set of Actions/Models/routes), not everything the keywords touch. No big-bang reverse.

## Task
1. Scan the target area along the real flow: routes → Form Requests → Controllers →
   Actions/Services → Models → Resources, plus its migrations and existing tests.
2. Reconstruct the seven REASONS dimensions from the code:
   - **R** — infer the problem + a Definition of Done from current behavior and existing tests.
   - **E** — the real Models/Enums/Value Objects and their invariants.
   - **A** — the pattern actually used (name it; note it even if it's over-engineered).
   - **S** — the real files/classes and their dependencies.
   - **O** — operations as the code actually implements them (class names, signatures, types).
   - **N / S** — norms and safeguards visible in the code (validation, authz, invariants, money handling).
3. Where behavior is ambiguous or a rule is unclear, mark it `⚠️ ASSUMED` and ask the human
   rather than guessing.

## Output
Write `spdd/<NNN>-<slug>/canvas.md` using `.claude/spdd-templates/reasons-canvas.md` — the
next free `<NNN>`. Print the path, the `⚠️ ASSUMED` list for the human to confirm, and a
short summary. From here it's a normal canvas: change behavior via `/spdd-prompt-update`,
keep it honest with `/spdd-sync`.
