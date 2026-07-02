# [CANVAS-<NNN>] <title!>

> SPDD artifact · the structured prompt · **source of truth**. Do not hand-edit —
> change via `/spdd-prompt-update` (requirements) or `/spdd-sync` (code). Code = artifact of this.

---
## R — Requirements
**Problem**: <what we are solving.>
**Definition of Done** (testable):
- [ ] <DoD item with concrete expected behavior.>

## E — Entities
| Entity | Eloquent / VO / Enum | Fields | Invariants |
|---|---|---|---|
| <Invoice> | Model `app/Models/Invoice` | <...> | <money ≥ 0> |

Relationships: <...>

## A — Approach
- **Strategy**: <the chosen approach in prose.>
- **Pattern**: <Laravel/OO pattern + how it's wired (provider binding, factory).>
- **Trade-offs**: <accepted.>

## S — Structure
Files to add / touch, with dependencies (respect Route→Request→Controller→Action→Eloquent→Resource):
- `app/...` — <new/modify> — <responsibility> — depends on <...>

---
## O — Operations  (concrete, ordered, testable)
1. **<op name>** — `App\...\Class::method(Type $arg): ReturnType`
   - Steps: <1..n precise steps.>
   - Verifies: <which AC / how to test.>
2. ...

---
## N — Norms (cross-cutting)
- `declare(strict_types=1)`; typed everywhere. Validation in Form Requests. Output via API Resources.
- Enums over string constants. No N+1. No `env()` outside config. Naming per `.claude/CLAUDE.md`.
- <feature-specific norms>

## S — Safeguards (non-negotiable boundaries)
- **Invariants**: <money via Money/int minor units, never float; ...>
- **Backward compatibility**: <migration strategy, nullable/default for existing rows.>
- **Security**: authz via Policy; mass-assignment allow-list; no hardcoded secrets.
- **Performance**: <limits.>
- **Scope-out**: <explicitly NOT in this change.>
