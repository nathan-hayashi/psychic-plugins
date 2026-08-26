# psychic-plugins

Working discipline as portable skills — **3 skills**, one plugin, extracted from the
psychic-crew program where each ran as enforced law before it became advice:

| Skill | What it does |
|---|---|
| `request-contract` | Compile a vague request into a 10-field contract with an observable completion condition and an explicit `unknown_fields` list. |
| `gate-machine` | Install exact-token approval gates: the GATES.md ledger, the stamp ritual, and a guard script that refuses commits until the operator's literal token lands. |
| `unknown-audit` | Label every load-bearing claim `[E]`/`[I]`/`[S]` and surface what an artifact assumes without evidence — report, never silently fix. |

**PRIVATE at creation** (the claude.ai org-distribution path requires it anyway). Version
**v0.1.0** (`.claude-plugin/plugin.json`).

## Install (Claude Code)

```text
/plugin marketplace add nathan-hayashi/psychic-plugins
/plugin install psychic-plugins@psychic-plugins
```

Then: `/psychic-plugins:request-contract <your request>` — or let the descriptions trigger them.
For local development: `claude --plugin-dir ./psychic-plugins` and `/reload-plugins`.

## Other surfaces — the cross-surface law

The platform docs state it plainly: "Custom Skills do not sync across surfaces." To use these on
claude.ai, zip a skill folder and upload it under Settings > Features (per user, Pro plans up);
for the API, upload through `/v1/skills`. These skills are deliberately prose-first so all three
packagings carry the same behavior. The claude.ai lane is documented but not yet exercised here —
see the parent program's SIDE-2 research note for that honest boundary.

## Verification

`./scripts/validate-plugins.sh` — manifests parse and cross-agree, the platform's frontmatter
constraints enforced mechanically (length, charset, reserved words, XML-free descriptions),
doctrine placement, README bindings, hygiene, negative controls proven to fire, and — when the
`claude` CLI is present — the platform's own `claude plugin validate .` as acceptance.
