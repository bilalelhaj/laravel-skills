# [ANALYSIS-<NNN>] <Title>

> SPDD artifact · step 3 · grounded in the actual codebase · "what" and "why", not "how".

## Domain keywords scanned
<keyword → files/classes inspected>

## Domain concepts
| Concept | Existing / New | Maps to (Laravel construct) | Key business rule |
|---|---|---|---|
| <e.g. Plan> | New | `app/Models/PricingPlan` + migration | <rule> |

### Relationships & invariants
- <e.g. a Customer has one PricingPlan; Money is never negative.>

## Strategic approach
- **Direction**: <solution shape in one paragraph.>
- **Pattern**: <Action / Service / Strategy via interface+binding / Resource ...> — why.
- **Trade-offs accepted**: <what we chose and what we gave up.>

## Risks, gaps & edge cases
- **Edge cases**: <ones the story missed.>
- **Backward compatibility**: <migrations, nullable columns, existing rows.>
- **Technical risks**: <perf, concurrency, external deps.>
- **AC coverage gaps**: <ACs not yet pinned to a concrete behavior.>

## Open questions for the human
- [ ] <decision needed before the canvas.>
