---
name: gate-machine
description: Install and operate an exact-token approval gate in any repository — a GATES.md ledger, an awaiting-to-APPROVED stamp ritual, and a guard script that refuses commits until the operator's literal token lands. Use when work must stop for human approval, when setting up phase gates, or when the user mentions gates, approval tokens, or sign-off discipline.
---

# gate-machine

Approval is a recorded artifact, never an inferred sentiment. This skill installs the smallest
version of that discipline that actually binds.

## The ledger

Create `GATES.md` at the repo root. One row per gate, four columns:

```markdown
# GATES

| Gate | Scope | Evidence | Status |
|---|---|---|---|
| G-1 | <what this gate approves, concretely> | <suite results, file counts, proof runs> | awaiting `APPROVE G-1` |
```

## The rules, in force from the first row

1. **Exact token only.** The status cell names the literal token (`APPROVE G-1`). Case-sensitive,
   whole token. "approved", "lgtm", a thumbs-up, or a paraphrase are NOT the token; if one
   arrives, say so and keep waiting.
2. **Stamp before commit.** On receiving the exact token, replace exactly one occurrence:
   `awaiting `APPROVE G-1`` becomes `**APPROVED** `APPROVE G-1` @ <ISO-8601 UTC>`.
3. **Guard fronts every gated commit.** Run the guard with the token; commit only on exit 0.
4. **Demonstrate refusal before asking.** Before requesting the token, run the guard once and
   show it refusing (exit 1). A guard never seen refusing proves nothing.
5. **STOP means stop.** Work reaches its gate with a dirty tree, the ledger row awaiting, and a
   report; nothing commits until the token. Never infer approval from enthusiasm.

## The guard

Save as `scripts/gate-guard.sh`, `chmod +x`:

```bash
#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")/.."
tok="${1:-}"
[ -n "$tok" ] || { echo "gate-guard: usage: gate-guard.sh \"APPROVE <ID>\"" >&2; exit 2; }
n=$(grep -cF "**APPROVED** \`$tok\`" GATES.md)
[[ "$n" =~ ^[0-9]+$ ]] || n=0
if [ "$n" -ge 1 ]; then
  echo "gate-guard: ok — \"$tok\" is APPROVED in GATES.md ($n row(s))."
  exit 0
fi
if grep -qF "\`$tok\`" GATES.md; then
  echo "gate-guard: REFUSED — \"$tok\" has no APPROVED row in GATES.md."
  echo "  the row exists and is still awaiting the operator. Stop and ask; do not commit."
else
  echo "gate-guard: REFUSED — no row mentions that token."
fi
exit 1
```

## Operating loop

work → append the awaiting row → run the guard (show the refusal) → report and STOP → operator
sends the exact token → stamp → guard passes → commit → verify post-commit → next gate.
