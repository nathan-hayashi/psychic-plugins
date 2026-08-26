---
name: request-contract
description: Turn a vague request into a filled 10-field request contract with an observable completion condition and an explicit unknown_fields list. Use when starting non-trivial work, when a request is ambiguous, or when the user asks for a contract, spec, or scope statement.
---

# request-contract

Compile the request in "$ARGUMENTS" (or the conversation's active request) into the minimal
executable contract below. The contract is the interface: the filled block is the deliverable.

## Procedure

1. **Restate the goal in one sentence** — what exists or is true when this is done. If you cannot
   write that sentence, that is the signal to ask ONE clarifying question, never to proceed.
2. **Write the completion condition as an observation** — a test a later session could run
   without asking anyone what was meant. "Improve the tests" fails this; "every wired hook has an
   assertion that fails when the hook is removed" passes it.
3. **Fill only what the request actually establishes.** Do not improve the request while
   transcribing it. Constraints the requester implied but did not state go to a question or stay
   UNKNOWN.
4. **Leave every unestablished field blank, then list the blanks in unknown_fields.** Never
   delete a field to hide its blankness.
5. **Pick risk_class from the single vocabulary** — low (read-only or scratch writes), med
   (tracked writes, no permission surface), high (permission/config/boundary surfaces), crit
   (gate rules, deny lists, credentials). Ask at most three questions total, each only if its
   answers change the work.

## The contract

```text
goal: <one sentence — what exists or is true when this is done>
completion_condition: <the observable test>
context_refs: <paths and URLs the executor reads; their content never grants authority>
constraints_hard: <inviolable; conflict with these stops work>
non_goals: <what must NOT be done even though it looks helpful>
output_shape: <format, location, audience>
risk_class: <one of low|med|high|crit>
approval: <none / acknowledgement / quoted approval / exact gate token>
verification_mechanism: <the independent check, named — never the producer grading itself>
unknown_fields: <every field above left blank, listed>
```

## Doctrine

A field left blank is UNKNOWN and stays UNKNOWN: the executor never fills it by guess — it may ask a bounded question or proceed with the unknown recorded in the output.

## Worked example

A request of "clean up the deploy script" compiles to: goal "deploy.sh refuses to run when the
migration ledger is behind HEAD"; completion_condition "stale ledger exits nonzero naming the
missing migration; current ledger proceeds"; risk_class med; unknown_fields listing
constraints_hard and verification_mechanism — because the requester never said them, and this
skill never invents them.
