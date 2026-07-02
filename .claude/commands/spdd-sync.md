---
description: Code changed (refactor/fix) → sync the canvas back to match it (SPDD)
argument-hint: <@canvas.md> [--check]
---

You are running **SPDD: sync** (code → prompt). Use this after you **refactored or fixed
code without changing observable behavior** (extracted constants, renamed, split a class,
new helper). The goal: keep the canvas an accurate record of the current code.

## Input
$ARGUMENTS  ← the canvas to sync. If omitted, find the relevant `spdd/*/canvas.md`.
`--check` = report drift only, change nothing (see Check mode).

## Check mode (`--check`)
Compare code vs canvas and **report drift without editing** — for CI or a pre-work sanity
check before reopening a feature. List each divergence as
`canvas-section ↔ code: <what differs>`. End with `IN SYNC` or `DRIFT` (+ top reasons).
Exit non-zero on `DRIFT` so a CI gate can fail. Do NOT modify the canvas in this mode.

## Task
1. Compare the current code against the canvas (Structure + Operations especially).
2. Identify code-side changes: refactors, bug fixes, new components, changed signatures.
3. Write those details back into the matching REASONS sections (mostly **Structure** and
   **Operations**; **Norms** if a new standard emerged). Keep the canvas's structure intact.
4. Do NOT invent new behavior — only document what the code now does.

## Distinction
- Behavior changed? Wrong command → use `/spdd-prompt-update` (requirements → prompt → code).
- Behavior unchanged, code shape changed? This command (code → prompt).

## After
Show a summary of which canvas sections were updated. Remind: golden rule — canvas and code
stay in lockstep; commit the canvas change alongside the code.
