---
name: gate-machine
description: Run an exact-token approval gate as pure ledger discipline — a GATES table, an awaiting-to-APPROVED stamp ritual, and refusal to proceed until the approver's literal token appears. Use when work must stop for human approval, when setting up phase gates, or when the user mentions gates, approval tokens, or sign-off discipline.
---

# gate-machine

Approval is a recorded artifact, never an inferred sentiment. This skill runs the smallest
version of that discipline that actually binds — entirely as ledger prose, in any surface where
you can keep a document.

## The ledger

Keep one table (a `GATES.md` file, a pinned doc, a canvas — any durable surface) with one row per
gate:

| Gate | ISO (UTC) | Scope | Evidence | Approval |
|---|---|---|---|---|
| PHASE-1 |  | what this gate covers | what was verified, where | awaiting `APPROVE PHASE-1` |

## The rules, in force from the first row

1. **Exact tokens, declared up front.** Every gate names its literal token (`APPROVE PHASE-1`)
   when the row is created — never minted at approval time, never paraphrased. "Looks good",
   "ship it", a thumbs-up: none of these is the token, and none approves anything.
2. **Awaiting means stopped.** While the row says `awaiting`, the gated work does not proceed,
   is not merged, is not published. There are no exceptions for momentum, confidence, or how
   close to done it looks.
3. **The stamp ritual.** When the approver sends the exact token, edit the row:
   `awaiting \`APPROVE PHASE-1\`` becomes `**APPROVED** \`APPROVE PHASE-1\` @ 2026-01-15T20:00:00Z`.
   The timestamp is written at stamp time. Only then does the gated action happen.
4. **Demonstrate refusal once.** Before the first real approval, show the discipline refusing:
   state plainly "the row still says awaiting — not proceeding" in response to a near-miss
   ("approve it", the right token with a typo, enthusiasm without the token). A gate never seen
   refusing is decoration.
5. **Append-only history.** Rows are never deleted or rewritten after stamping; a correction is
   a new row citing the old one. A ledger that can be quietly edited approves nothing.

## Operating loop

Open the gate row (awaiting) → do the gated work → present the evidence in the row → ask for the
exact token → refuse anything that is not it → on the literal token, stamp with a timestamp →
only then act → record the outcome in the row's evidence cell.

## What this deliberately is not

No scripts, no hooks, no automation — those exist in the parent program this skill was extracted
from, where the same discipline is machine-enforced. This portable form binds through the
ledger's visibility: anyone reading the table can see what was approved, by which token, when,
and what is still waiting.
