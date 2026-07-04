---
name: business-context
description: Capture and explain the business domain of a project so AI work stays aligned with real intent. Use at project kickoff, when onboarding to an unfamiliar codebase, or before an SPDD analysis when the domain is unclear.
---

# Business context

SPDD only works when the domain is bounded. A "context black hole" — unclear rules, fuzzy
boundaries — is where AI fails most confidently (SPDD fitness: 1 star). This skill front-loads
the domain understanding so the story/analysis/canvas rest on real intent, not guesswork.

## When to run
- Project kickoff, or onboarding to an unfamiliar codebase.
- Before `/spdd-analysis` when the feature's domain isn't clear — the `spdd` orchestrator routes here.
- When two people would describe the same rule differently.

## What to capture (keep it to one page)
- **Domain in one paragraph** — what the business does, who the users are, how it makes money.
- **Core entities + ubiquitous language** — the real-world nouns and the exact words the business
  uses. Map each to a candidate Eloquent Model. Pin synonyms ("client" vs "customer" vs "account")
  to ONE term — that becomes the naming in code.
- **Key business rules & invariants** — the non-negotiables ("an invoice is never negative", "a
  subscription has exactly one active plan"). These become **Safeguards** in the canvas.
- **Boundaries** — what's explicitly out of scope / owned by another system.
- **Lifecycle & states** — the important status transitions (draft → sent → paid).
- **Open questions** — what only a human stakeholder can answer. Flag, don't guess.

## How to produce it
1. Read what exists first: README, migrations, Models, Enums, existing tests, config — infer the
   domain from the code before asking.
2. List what you inferred, then ask the human ONLY the genuinely blocking questions.
3. Write the result where it helps: a short `spdd/DOMAIN.md`, or feed it straight into the next
   `/spdd-analysis`. Reuse it across features — this is accumulated domain knowledge.

## Feeds into
Ubiquitous language → **Entities** in the canvas. Rules/invariants → **Safeguards**. Boundaries →
**Scope-out**. Get this right and every downstream SPDD artifact gets sharper.
