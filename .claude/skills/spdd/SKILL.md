---
name: spdd
description: Build a Laravel feature end-to-end with SPDD. Triggers whenever the user wants to add, build, implement, or change a feature and describes it in plain language. The user does NOT need to remember any /command — this drives the whole pipeline (story → analysis → canvas → code → tests → review), self-reviews every artifact, and pauses for the user's approval at each gate.
---

# SPDD feature builder (orchestrator)

The user only describes a feature in plain words. **You** run the entire SPDD pipeline,
**you** self-review every artifact before showing it, and you **stop for approval at each
gate**. The user reviews intent, not 500-line diffs. Never run the chain unattended.

## How you behave
- **One phase at a time.** After each phase: show a SHORT summary + your own skeptical
  critique (what's weak/missing), then ask `approve / change what?`. Wait. Don't advance alone.
- **You drive each step yourself, one phase at a time.** Two mechanics both work in Claude
  Code: (a) invoke the step via the Skill tool — commands are skills, and the model may call
  any skill that isn't `disable-model-invocation`; or (b) `Read .claude/commands/spdd-*.md`
  and follow its procedure inline. **Prefer (b) read-and-follow** here: it keeps you in
  control of the pause-at-gate between phases and doesn't hand control to a sub-command's own
  "suggest next step" tail. The user never types a `/spdd-*`.
- **Self-review is mandatory.** After generating each artifact, critique it AS A SKEPTIC and
  list gaps BEFORE the user sees it. For the canvas, apply the `spdd-prompt` skill checklist.
- **Apply the user's changes**, then continue. Pre-code, edit the artifact directly and
  re-run downstream phases as needed. Once code exists, behavior changes go via prompt-update (see Divergence).
- Keep gates light: summary + critique + one question. No walls of text. Honor `.claude/CLAUDE.md`
  (strict types, money-never-float, no code comments, thin controllers, Conventional Commits).

## Pipeline
0. **Intake** — restate the feature in one paragraph so the user confirms you understood.
   Ask at most 2–3 genuinely blocking questions. Then route:
   - **Change to a feature that already has a `spdd/<NNN>-<slug>/` canvas?** (even a year later)
     → don't create a new folder. Reopen that canvas via the Divergence path below.
   - **Touches existing code that has no canvas yet (legacy)?** → run `/spdd-reverse` on that
     area first to bootstrap a canvas from the current code, then continue the pipeline.
   - **Genuinely new feature?** → pick the next free `spdd/<NNN>-<slug>/` folder (create
     `spdd/` if absent). If the domain is unclear, run the `business-context` skill first.
1. **Story** — procedure: `.claude/commands/spdd-story.md`.
   Self-check: INVEST? ACs testable with concrete numbers? scope in/out explicit?
   → **GATE**.
2. **Analysis** — procedure: `.claude/commands/spdd-analysis.md` (scan the real codebase).
   Self-check: edge cases surfaced the story missed? risks named? domain mapped to real
   classes/migrations? every AC covered?
   → **GATE**.
3. **Canvas** — procedure: `.claude/commands/spdd-reasons-canvas.md`.
   Self-review with the full `spdd-prompt` skill checklist — apply it, don't restate it here.
   → **GATE — the most important one (intent + design locked here).**
4. **Generate** — procedure: `.claude/commands/spdd-generate.md`. Then run `pint` + `phpstan`.
   Report each file ↔ which Operation it implements.
5. **Test** — procedure: `.claude/commands/spdd-api-test.md`. Run `pest`. Report pass/fail honestly.
6. **Review** — procedure: `.claude/commands/spdd-code-review.md`. Present the `ALIGNED`/`DRIFT` verdict.
   → **GATE — user decides ship.**
7. **Commit** — suggest a Conventional Commit (English, imperative, no co-author, no trailers).

## Divergence (changes after code exists)
- **Behavior change** (new rule, bug): run `/spdd-prompt-update` (fix the canvas first) → re-generate. 
- **Pure refactor** (no behavior change): refactor the code, then `/spdd-sync` (code → canvas).
State which path you're taking and why before doing it.

## When NOT to run the full pipeline
- One-line fix / typo / config tweak / throwaway script → just do it; SPDD overhead isn't worth it.
- Say so in one line and skip to the edit. SPDD is for logic-bearing features, not chores.
