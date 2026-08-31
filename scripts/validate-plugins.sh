#!/usr/bin/env bash
# validate-plugins.sh — the PLG assertion layer, born WITH the scaffold. The platform documents
# hard constraints on skill frontmatter (length, charset, reserved words, XML-free descriptions);
# remembering rules is how they get broken, so this file enforces them mechanically. Negative
# controls assert their fixtures EXIST before expecting failure (the templates sibling watched an
# expect-fail control pass vacuously against a missing file on its own birth day).
set -uo pipefail
cd "$(dirname "$0")/.."
P=0; F=0; S=0
ok () { P=$((P+1)); printf '  [PASS] %s\n' "$1"; }
no () { F=$((F+1)); printf '  [FAIL] %s\n' "$1"; }
sk () { S=$((S+1)); printf '  [SKIP] %s\n' "$1"; }

ABS=$(printf '/%s/' home)
CRED1="gh""p_"; CRED2="xox""b-"; CRED3="AKI""A"; CRED4="BEGIN ""PRIVATE KEY"
DOC='A field left blank is UNKNOWN and stays UNKNOWN: the executor never fills it by guess — it may ask a bounded question or proceed with the unknown recorded in the output.'
# The reserved words, assembled so this file's own frontmatter-free prose never trips a scanner.
RW1="anthro""pic"; RW2="cla""ude"

chk_skillfront () { # $1=SKILL.md path, $2=expected dir name ("" to skip the dir check)
  local f="$1" want="$2" fm name desc
  [ -f "$f" ] || return 1
  fm=$(awk '/^---$/{n++;next} n==1' "$f")
  name=$(sed -n 's/^name: *//p' <<<"$fm" | head -1)
  desc=$(sed -n 's/^description: *//p' <<<"$fm" | head -1)
  [ -n "$name" ] || return 1
  [ "${#name}" -le 64 ] || return 1
  [[ "$name" =~ ^[a-z0-9-]+$ ]] || return 1
  grep -qiE "$RW1|$RW2" <<<"$name" && return 1
  [ -n "$desc" ] || return 1
  [ "${#desc}" -le 1024 ] || return 1
  grep -qE '<[a-zA-Z]' <<<"$desc" && return 1
  if [ -n "$want" ]; then [ "$name" = "$want" ] || return 1; fi
  return 0
}

echo "== A. structure =="
for f in README.md CLAUDE.md GATES.md LICENSE docs/explainers/INDEX.md; do
  [ -f "$f" ] && ok "exists: $f" || no "missing: $f"
done
for s in scripts/*.sh; do bash -n "$s" 2>/dev/null || no "syntax error in $s"; done
ok "all shell files parse"

echo "== B. the web-pack surface =="
for d in skills/*/; do
  [ -f "$d/SKILL.md" ] && ok "pack complete: $(basename "$d")/SKILL.md" || no "pack missing SKILL.md: $d"
done
grep -qF 'Settings > Features' README.md && ok "README carries the claude.ai upload lane" \
  || no "README lost the upload lane instructions"

echo "== C. the platform's skill constraints, mechanized =="
scount=0
for d in skills/*/; do
  s=$(basename "$d")
  scount=$((scount+1))
  chk_skillfront "$d/SKILL.md" "$s" && ok "frontmatter legal: $s" || no "frontmatter violates a platform constraint: $s"
done
[ "$scount" -eq 3 ] && ok "exactly 3 skills present" || no "skill count $scount != 3"

echo "== D. doctrine placement =="
for s in request-contract unknown-audit; do
  dn=$(grep -cF "$DOC" "skills/$s/SKILL.md")
  [[ "$dn" =~ ^[0-9]+$ ]] || dn=0
  [ "$dn" -eq 1 ] && ok "doctrine verbatim once: $s" || no "doctrine missing/duplicated in $s ($dn)"
done
dn=$(grep -cF "$DOC" "skills/gate-machine/SKILL.md")
[[ "$dn" =~ ^[0-9]+$ ]] || dn=0
[ "$dn" -eq 0 ] && ok "gate-machine carries no doctrine line (exempt by declaration)" || no "doctrine leaked into gate-machine"

echo "== E. README bindings =="
r3=$(grep -oE '\*\*[0-9]+ skills\*\*' README.md | head -1 | grep -oE '[0-9]+')
[[ "$r3" =~ ^[0-9]+$ ]] || r3=-1
[ "$r3" -eq "$scount" ] && ok "README skill count ($r3) matches the tree ($scount)" || no "README says $r3 skills, tree has $scount"

echo "== F. hygiene =="
abshits=$(git ls-files -z | xargs -0 grep -lF -- "$ABS" 2>/dev/null)
[ -z "$abshits" ] && ok "no absolute machine paths in tracked files" || no "absolute path in: $(tr '\n' ' ' <<<"$abshits")"
credhits=""
for ndl in "$CRED1" "$CRED2" "$CRED3" "$CRED4"; do
  h=$(git ls-files -z | xargs -0 grep -lF -- "$ndl" 2>/dev/null)
  [ -n "$h" ] && credhits="$credhits $h"
done
[ -z "$credhits" ] && ok "no credential-shaped strings in tracked files" || no "credential shape in:$credhits"

# S1: the stage-everything publication probe (ported from the parent — this repo flips public at
# S1B, and an untracked-unignored drop at the root is invisible to every ls-files-based check).
spout=$(git ls-files --others --exclude-standard 2>/dev/null)
sprisk=""
while IFS= read -r pth; do
  [ -n "$pth" ] || continue
  sprisk="$sprisk [$pth]"
done <<<"$spout"
[ -z "$sprisk" ] && ok "stage-everything probe: zero unignored untracked paths" \
  || no "publication risk — untracked and NOT ignored:$sprisk"
grep -qF '.claude/state/' .gitignore && ok "runtime fence present in .gitignore" \
  || no ".gitignore lost the runtime fence"

echo "== G. zero CLI in shipped skill content (S1 law: executable shapes, never bare verbs) =="
# Needles are assembled here so this scanner never contains its prey as a contiguous literal.
g_f1=$(printf '%s%s' '```' 'bash')
g_f2=$(printf '%s%s' '```' 'sh')
g_f3=$(printf '%s%s' '```' 'zsh')
g_c1=$(printf '%s%s' 'chmo' 'd ')
g_c2=$(printf '%s%s' './scri' 'pts/')
g_c3=$(printf '%s%s' '/plu' 'gin ')
g_c4=$(printf '%s%s' 'npx' ' ')
for d in skills/*/; do
  s=$(basename "$d")
  ghits=""
  for ndl in "$g_f1" "$g_f2" "$g_f3" "$g_c1" "$g_c2" "$g_c3" "$g_c4"; do
    grep -qF -- "$ndl" "$d/SKILL.md" 2>/dev/null && ghits="$ghits [$ndl]"
  done
  [ -z "$ghits" ] && ok "zero CLI content: $s" || no "CLI shape in shipped skill $s:$ghits"
done
# The interpreter dependency died with the manifests it parsed. Needle assembled (a scanner
# never contains its prey); scope = executable surfaces only — ledger prose may DESCRIBE the
# removal without re-tripping it.
g_py=$(printf 'pyth%s' 'on3')
pyh=$(git grep -l -- "$g_py" -- scripts/ skills/ 2>/dev/null | grep -v 'validate-plugins.sh' | tr '\n' ' ')
[ -z "$pyh" ] && ok "the interpreter dependency is gone from executable surfaces" \
  || no "interpreter still referenced in:$pyh"

echo "== H. negative controls (existence first, then fire) =="
for fx in tests/fixtures/bad-skill-name.md tests/fixtures/bad-desc-xml.md tests/fixtures/bad-cli-content.md; do
  [ -f "$fx" ] && ok "fixture exists: $fx" || no "fixture MISSING (controls would be vacuous): $fx"
done
chk_skillfront tests/fixtures/bad-skill-name.md "" \
  && no "control DID NOT fire: reserved-word name accepted" || ok "control fires: reserved-word name caught"
chk_skillfront tests/fixtures/bad-desc-xml.md "" \
  && no "control DID NOT fire: XML description accepted" || ok "control fires: XML description caught"
chk_skillfront tests/fixtures/does-not-exist.md "" \
  && no "control DID NOT fire: phantom file passed" || ok "control fires: phantom path refused"



# S1 fire-probe: the zero-CLI arm must catch a planted executable shape (existence asserted above).
gpfx=tests/fixtures/bad-cli-content.md
gph=""
for ndl in "$g_f1" "$g_c1" "$g_c3"; do
  grep -qF -- "$ndl" "$gpfx" 2>/dev/null && gph="$gph [$ndl]"
done
[ -n "$gph" ] && ok "zero-CLI fire-probe: the planted fixture is caught:$gph" \
  || no "zero-CLI fire-probe FAILED — the planted fixture went unseen; the arm is void"

# S0-RECONCILE — the explainer-epoch discipline, ported from the parent with ONE DECLARED
# VARIANCE: an empty post-epoch set is PASS-with-reason here (this repo gates rarely, so the
# epoch row is often the last row); the parent's stricter FAIL stands over there. Grandfathered
# rows (enumerated in INDEX.md) are events recorded without tokens and owe no explainer.
exepoch=$(grep -m1 '^EXPLAINER-EPOCH: ' docs/explainers/INDEX.md 2>/dev/null | awk '{print $2}')
exgf=$(grep -m1 '^EXPLAINER-GRANDFATHERED: ' docs/explainers/INDEX.md 2>/dev/null | sed 's/^EXPLAINER-GRANDFATHERED: //')
if [ -z "${exepoch:-}" ]; then
  no "explainer epoch line missing from docs/explainers/INDEX.md"
else
  exrows=$(awk -F'|' -v ep="$exepoch" '/^\| [A-Za-z]/ { g=$2; gsub(/^ +| +$/,"",g); if (found && g!="Gate") print g; if (g==ep) found=1 }' GATES.md)
  exmiss=""
  for g in $exrows; do
    case " ${exgf:-} " in *" $g "*) continue ;; esac
    [ -f "docs/explainers/$g.md" ] || exmiss="$exmiss [$g]"
  done
  if [ -z "$exrows" ]; then
    ok "explainer epoch: post-epoch set empty (epoch is the last row) — PASS with stated reason (declared variance)"
  elif [ -z "$exmiss" ]; then
    ok "every post-epoch gate has its plain-language explainer"
  else
    no "explainer(s) MISSING for post-epoch gate(s):$exmiss"
  fi
  exfx=$(mktemp); cat GATES.md > "$exfx"
  printf '| PROBE-X9 |  | p | p | awaiting probe |\n' >> "$exfx"
  exrows2=$(awk -F'|' -v ep="$exepoch" '/^\| [A-Za-z]/ { g=$2; gsub(/^ +| +$/,"",g); if (found && g!="Gate") print g; if (g==ep) found=1 }' "$exfx")
  case "$exrows2" in
    *"PROBE-X9"*) ok "explainer fire-probe: a planted post-epoch gate row is seen by the extractor" ;;
    *) no "explainer fire-probe FAILED — a planted row went unseen; the binding is void" ;;
  esac
  rm -f "$exfx"
fi

echo "== validate-plugins: $P PASS / $F FAIL / $S SKIP =="
[ "$F" -eq 0 ]
