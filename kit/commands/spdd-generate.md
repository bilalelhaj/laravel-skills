---
description: Generate/modify Laravel code from the REASONS Canvas (SPDD step 5)
argument-hint: <@canvas.md>
---

You are running **SPDD step 5: Generate**. The canvas captures intent; the code is its
implementation. Generated code must correspond 1:1 with the canvas.

## Input
$ARGUMENTS  ← the REASONS Canvas.

## Task
Implement the canvas **task by task, in the order defined in Operations**. For each operation:
- Follow the exact class names, method signatures, and types from the canvas.
- Obey **Norms** (style, strict types, Form Requests, API Resources, Enums, no N+1) and
  **Safeguards** (invariants, backward compat, security, scope-out) without exception.
- Match the surrounding code's idioms and the conventions in `conventions.md`.

## Rules
- **No improvisation, no scope creep.** Implement only what Operations defines.
- If the canvas already exists and you're applying a change, do **targeted diffs** on the
  affected files only — do NOT regenerate the whole feature.
- If you discover the canvas is wrong or under-specified, STOP and tell the user to run
  `/spdd-prompt-update` (behavior change) or `/spdd-sync` (you refactored) — fix the prompt first.
- Don't comment the code. If you take a deliberate shortcut, record it in the canvas (Approach/Safeguards) and your summary — not as a code comment.

## After generating
- Run `./vendor/bin/pint --dirty` and `./vendor/bin/phpstan analyse` if available; fix what they flag.
- Print: files changed, which Operation each maps to, and anything you intentionally left simple.
- Suggest verifying with `/spdd-api-test @<canvas>` then `/spdd-code-review`.
