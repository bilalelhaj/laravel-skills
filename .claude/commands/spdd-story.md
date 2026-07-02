---
description: Break a rough idea into INVEST user stories (SPDD step 1)
argument-hint: <@idea.md or a description of the requirement>
---

You are running **SPDD step 1: Story**. Optional but recommended for anything bigger
than a one-file change.

## Input
$ARGUMENTS

If nothing was passed, ask the user for the rough idea/requirement before continuing.

## Task
Break the requirement into independent, deliverable **user stories** following INVEST
(Independent, Negotiable, Valuable, Estimable, Small — 1–5 days each, Testable).

For each story produce, in **business language** (no implementation detail):
- **Title**
- **Background** — why now, what context.
- **Business Value** — who benefits and how.
- **Scope In** / **Scope Out** — explicit boundaries.
- **Acceptance Criteria** — Given/When/Then with **concrete numeric examples**.

Keep each story to ~one page. Use 3 high-level ACs max per story unless the user asks for more.

## Output
For each story, create `spdd/<NNN>-<slug>/story.md` in the **consuming project**,
where `<NNN>` is the next free zero-padded sequence number and `<slug>` is a short
kebab-case title. Use the template at `.claude/spdd-templates/story.md`.

If the user asks to consolidate multiple stories into one, merge them keeping only
Background, Business Value, Scope In, Scope Out, Acceptance Criteria — strip implementation detail.

After writing, print the path(s) and a one-line summary of each story. Then suggest:
`/spdd-analysis @spdd/<NNN>-<slug>/story.md`.
