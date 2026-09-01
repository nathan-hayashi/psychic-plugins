# S1B-PUBLIC, explained plainly

## What changed

This repo went public — the last estate repo to flip, and the only one whose flip went through
the full ceremony the others got retroactively: a complete history scan first, then your explicit
ruling on what history reveals, then the switch, then the record.

## Why

Public history is forever; reverting to private later does not un-publish what anyone already
pulled. So the gate scanned every commit for private material (none exists — zero paths, zero
names, zero credential shapes) and put the one real disclosure to you plainly: history shows this
began as a Claude Code plugin. You ruled that provenance acceptable, and rewriting it away would
have destroyed the birth commit's evidence for nothing.

## Verify it yourself

```
gh repo view nathan-hayashi/psychic-plugins --json isPrivate   # false
git log --oneline --all                                        # the intact origin story
./scripts/validate-plugins.sh                                  # 35 checks incl. the publication probe
```

## What could break, and what catches it

Anything untracked-and-unignored landing at the root now fails the publication probe by path
before it can ever be staged. New shipped content carrying CLI shapes fails the zero-CLI arm by
skill and needle.
