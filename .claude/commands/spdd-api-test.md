---
description: Generate Pest feature tests (+ optional curl script) from the canvas ACs
argument-hint: <@canvas.md> [--curl]
---

You are running **SPDD: API/feature test generation**. Turn acceptance criteria into
deterministic, runnable tests — the verification layer for behavior.

## Input
$ARGUMENTS  ← the REASONS Canvas (or the implemented code + ACs). `--curl` also emits a shell script.

## Task — Pest (default)
Generate **Pest feature tests** under `tests/Feature/` that hit the real routes.
- One test per acceptance criterion, named as the Given/When/Then with concrete numbers.
- Cover normal, **boundary**, and **error** scenarios (validation 400/422, not-found 404, authz 403).
- Use factories for setup and `RefreshDatabase`. Assert status + JSON shape + computed values
  (e.g. exact charge amounts). Use Laravel/Pest assertions (`assertCreated`, `assertJsonPath`).
- Add a Pest **arch test** if the canvas Norms imply one (e.g. controllers free of `DB::`).

Print a TEST CASE OVERVIEW table (scenario · input · expected) before the code.

## Task — curl (`--curl`)
Also write `scripts/test-api.sh`: a curl-based script with a test-case table in comments,
running each scenario and printing expected-vs-actual. Make it executable.

## After
- Run `./vendor/bin/pest --ci` (or `--filter` the new tests). Report pass/fail honestly.
- These tests are the regression net; keep them green before `/spdd-code-review`.
