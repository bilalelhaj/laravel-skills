---
name: spdd-prompt
description: Pair on authoring a high-quality SPDD REASONS Canvas (the structured prompt). Use when writing or sharpening a canvas by hand, reviewing one for under-specification, or teaching the SPDD method. Complements the /spdd-* commands.
---

# Authoring a good REASONS Canvas

The `/spdd-reasons-canvas` command generates a canvas; this skill is for **judging and
sharpening** it — the human skill SPDD depends on. Two devs writing the same canvas can
differ; this raises the floor.

## The three core skills the canvas must show
1. **Abstraction first** — entities, responsibilities, and boundaries are clear *before*
   any method detail. If Operations exist but Entities/Approach are thin, the canvas is upside down.
2. **Alignment** — "what we will / won't do" is explicit; standards and hard constraints
   are stated up front (Norms + Safeguards), not discovered in review.
3. **Iterative review** — the canvas is changed by `/spdd-prompt-update` or `/spdd-sync`,
   never silently hand-edited out of sync with code.

## Quality checklist (run against any canvas)
- **R**: Is the Definition of Done *testable* with concrete numbers? If not, it's a wish.
- **E**: Does every entity map to a real Eloquent Model / Enum / Value Object, with invariants?
- **A**: Is the chosen pattern *named and justified*, with the trade-off stated? Beware
  over-engineering — a Strategy pattern for two cases that'll never grow is debt (ponytail).
- **S**: Does the change respect the layer flow (Request→Controller→Action→Eloquent→Resource)?
  Are touched files listed exactly?
- **O**: Are operations ordered, with method signatures + types, each independently verifiable?
  Could a different dev implement them and land in the same place?
- **N**: Are the cross-cutting norms from `conventions.md` present (strict types, validation,
  resources, enums, no N+1)?
- **S (Safeguards)**: Are invariants, backward-compat, security, and **scope-out** all explicit
  and non-negotiable? Money never float. Authz named. Mass-assignment allow-listed.

## Smells (push back when you see these)
- A canvas that's structurally complete but substantively vague ("handle billing correctly").
- Operations more elaborate than the problem (gold-plating) — under-specified Approach usually causes it.
- Missing scope-out → the model will invent features.
- Safeguards that aren't falsifiable.

## How to fix
Don't rewrite by hand. State the gap to the model and run `/spdd-prompt-update` so the change
is captured in the canvas first, then `/spdd-generate`. Keep prompt and code in lockstep.
