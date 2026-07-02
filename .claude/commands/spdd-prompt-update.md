---
description: Requirements changed → update the canvas first, then regenerate (SPDD)
argument-hint: <@canvas.md> "<what changed / new rule>"
---

You are running **SPDD: prompt-update** (requirements → prompt → code). Use this when a
**business rule or behavior changes**. This is an update/bug-fix, not a refactor.

## Input
$ARGUMENTS  ← the canvas to update + a description of the new requirement.

## Task
1. Determine which REASONS dimensions the change touches (often R/A/O, sometimes E/S Safeguards).
2. **Incrementally update only those sections** of `canvas.md`. Preserve everything else
   verbatim. Do not rewrite the whole canvas. Keep Operations precise (signatures/types).
3. Show the user a concise diff of what changed in the canvas and why.

Example intents this handles: "modelId is now required with default fast-model",
"premium plan must reject quota fields", "round half-up instead of down".

## Rules
- Never hand-wave the change into code directly — the canvas must reflect the new truth first.
- If the change is actually a no-behavior refactor, stop and use `/spdd-sync` instead.

## After
Tell the user to run `/spdd-generate @<canvas>` to apply targeted code diffs for the change,
then `/spdd-api-test` to update/extend the affected tests.
