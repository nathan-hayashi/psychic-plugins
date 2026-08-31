# psychic-plugins — law

Portable working-discipline skills, one plugin, this repo doubling as its own marketplace
(`.claude-plugin/marketplace.json`, self-source `"./"`). Born 2026-08-26 under the parent HELIX
program's SIDE-2 gate (psychic-crew). PRIVATE at creation — which the claude.ai org-distribution
path independently requires.

## Binding rules
- **The platform's skill constraints are mechanized here**, not remembered: frontmatter `name`
  ≤64 chars, lowercase/numbers/hyphens, no reserved words ("anthropic", "claude"); `description`
  non-empty, ≤1024, no XML tags. `./scripts/validate-plugins.sh` fails on violation.
- **Prose-first skills.** The cross-surface law ("Custom Skills do not sync across surfaces")
  means a skill leaning on repo-local scripts dies off Claude Code; these three run anywhere.
- **Acceptance is the platform's own check:** `claude plugin validate .` green, exercised at
  every gate that touches a manifest or skill.
- **Evidence labels** ([E]/[I]/[S]) on load-bearing claims; weakest claim flagged.
- **Gate law.** Exact operator tokens in `GATES.md`; commits fronted by `scripts/gate-guard.sh`.
- **One risk vocabulary:** low | med | high | crit. **No absolute machine paths. Zero credentials.**

Canonical author identity (S0-RECONCILE, 2026-08-31): **Nathan Lim** — LICENSE copyright
lines cite this form estate-wide; the GitHub handle is an address, not a copyright holder.
