# S1-PLUGINS-WEB, explained plainly

## What changed

This repo stopped being a Claude Code plugin and became what you asked for: an army of
plain-prose skills for claude.ai chat. The two machine manifests and every slash-command install
instruction are gone from the current files (they stay visible in git history). The gate-machine
skill was rewritten so it teaches the approval-ledger discipline with zero shell in it. The
README now speaks to a chat user: zip a folder, upload it in Settings, ask in plain words.

## Why

Your ruling: web plugins, "never containing any CLI invoking init functions", public later. The
zero-CLI law covers what SHIPS; the repo keeps its own validator and gate guard as local tooling
— and it actually got cleaner: the only python dependency in the whole estate died with the
manifests it existed to parse.

## Verify it yourself

```
./scripts/validate-plugins.sh          # incl. the new zero-CLI arm + its fire-probe + the
                                       # stage-everything publication probe
grep -rn "plugin install" skills/      # nothing — shipped content is CLI-free
git log --oneline -- .claude-plugin/   # the retired manifests, preserved in history
```

## What could break, and what catches it

If a future skill body gains a shell fence or an install command, the validator fails naming the
skill and the shape (a planted fixture proves the arm fires). If an unignored file appears at
the root before the public flip, the publication probe fails by path — the exact class that
nearly published private material in the parent once.
