# [TEST-<NNN>] <Title>

> SPDD artifact · test scenarios derived from the canvas ACs. Drives Pest generation.
> Cross-reference existing tests first — only add genuinely new scenarios.

## Test case overview
| # | Type | Scenario | Input | Expected |
|---|---|---|---|---|
| 1 | normal | <happy path> | <request> | HTTP 201, <exact values> |
| 2 | boundary | <edge> | <...> | <...> |
| 3 | error | missing field | <...> | HTTP 422, message |
| 4 | error | unknown id | <...> | HTTP 404 |
| 5 | error | unauthorized | <...> | HTTP 403 |

## New scenarios only (after de-dup vs existing suite)
- [ ] <scenario not already covered>

## Notes
- Feature tests hit real routes (`RefreshDatabase`, factories). Assert status + JSON shape + computed numbers.
- Unit-test domain math (pricing, Value Objects) directly.
- Add a Pest arch test if a Norm needs enforcing.
