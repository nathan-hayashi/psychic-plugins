---
name: unknown-audit
description: Audit a document, plan, or answer for guessed-in content — label every load-bearing claim established, inferred, or speculative, and emit an explicit unknown_fields list of what the artifact assumes without evidence. Use when reviewing plans or reports, when the user asks what is actually known, or before acting on any pasted analysis.
---

# unknown-audit

A complete-looking artifact hiding guessed-in requirements is the expensive failure. This skill
makes the incompleteness visible instead.

## Procedure

1. **Inventory the load-bearing claims.** A claim is load-bearing if the artifact's conclusion
   or next action changes when the claim is false. Number them.
2. **Label each one:**
   - `[E]` established — the evidence is at hand: the file itself, the command output, the
     fetched page. Name it.
   - `[I]` inferred — follows from established facts by a stated step. Name the step.
   - `[S]` speculative — plausible, unverified. Say so plainly.
3. **Hunt the guess markers.** Numbers with no source. Names, versions, or APIs stated from
   memory. "Should", "probably", "typically", "it is likely". Defaults assumed silently.
   Each hit is either re-labeled honestly or moved to unknown_fields.
4. **Emit the verdict block:**

```text
claims_audited: <count>
established: <count>   inferred: <count>   speculative: <count>
weakest_claim: <the single claim most likely to be wrong, quoted, with why>
unknown_fields: <everything the artifact needs but does not establish, listed>
```

5. **Report findings; do not silently fix them.** An audit that rewrites as it goes has
   destroyed its own evidence. Corrections are a separate, named step after the audit lands.

## Doctrine

A field left blank is UNKNOWN and stays UNKNOWN: the executor never fills it by guess — it may ask a bounded question or proceed with the unknown recorded in the output.

## Calibration

Label with the artifact's own stakes: in a weekend prototype, `[S]` is often fine and the audit
just names it; in anything gated, irreversible, or outward-facing, every `[S]` on the load path
is a stop. The audit's job is that the difference is now a decision, not an accident.
