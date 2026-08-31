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
for f in .claude-plugin/plugin.json .claude-plugin/marketplace.json README.md CLAUDE.md GATES.md; do
  [ -f "$f" ] && ok "exists: $f" || no "missing: $f"
done
for s in scripts/*.sh; do bash -n "$s" 2>/dev/null || no "syntax error in $s"; done
ok "all shell files parse"
python3 - <<'PY' && ok "both manifests parse as JSON" || no "a manifest does not parse"
import json
json.load(open('.claude-plugin/plugin.json')); json.load(open('.claude-plugin/marketplace.json'))
PY

echo "== B. manifest fields and self-marketplace =="
read -r pname pver mname msrc mplug < <(python3 - <<'PY'
import json
p=json.load(open('.claude-plugin/plugin.json')); m=json.load(open('.claude-plugin/marketplace.json'))
print(p.get('name',''), p.get('version',''), m.get('name',''), m['plugins'][0].get('source',''), m['plugins'][0].get('name',''))
PY
)
[ -n "$pname" ] && [[ "$pname" =~ ^[a-z0-9-]+$ ]] && ok "plugin name kebab: $pname" || no "plugin name malformed: '$pname'"
[ -n "$pver" ] && ok "plugin version present: $pver" || no "plugin version missing"
[ "$msrc" = "./" ] && ok "marketplace lists this repo as its own source (\"./\")" || no "self-source is '$msrc', expected ./"
[ "$mplug" = "$pname" ] && ok "marketplace entry name matches plugin.json" || no "name mismatch: marketplace '$mplug' vs plugin '$pname'"

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
vn=$(grep -cF "v$pver" README.md)
[[ "$vn" =~ ^[0-9]+$ ]] || vn=0
[ "$vn" -ge 1 ] && ok "README names the manifest version v$pver" || no "README does not name v$pver"

echo "== F. hygiene =="
abshits=$(git ls-files -z | xargs -0 grep -lF -- "$ABS" 2>/dev/null)
[ -z "$abshits" ] && ok "no absolute machine paths in tracked files" || no "absolute path in: $(tr '\n' ' ' <<<"$abshits")"
credhits=""
for ndl in "$CRED1" "$CRED2" "$CRED3" "$CRED4"; do
  h=$(git ls-files -z | xargs -0 grep -lF -- "$ndl" 2>/dev/null)
  [ -n "$h" ] && credhits="$credhits $h"
done
[ -z "$credhits" ] && ok "no credential-shaped strings in tracked files" || no "credential shape in:$credhits"

echo "== G. platform acceptance (conditional) =="
if command -v claude >/dev/null 2>&1; then
  vout=$(claude plugin validate . 2>&1)
  if grep -qF "Validation passed" <<<"$vout"; then
    ok "claude plugin validate: passed"
  else
    no "claude plugin validate failed: $(tail -2 <<<"$vout" | tr '\n' ' ')"
  fi
else
  sk "claude CLI absent — platform validate deferred, stated"
fi

echo "== H. negative controls (existence first, then fire) =="
for fx in tests/fixtures/bad-skill-name.md tests/fixtures/bad-desc-xml.md; do
  [ -f "$fx" ] && ok "fixture exists: $fx" || no "fixture MISSING (controls would be vacuous): $fx"
done
chk_skillfront tests/fixtures/bad-skill-name.md "" \
  && no "control DID NOT fire: reserved-word name accepted" || ok "control fires: reserved-word name caught"
chk_skillfront tests/fixtures/bad-desc-xml.md "" \
  && no "control DID NOT fire: XML description accepted" || ok "control fires: XML description caught"
chk_skillfront tests/fixtures/does-not-exist.md "" \
  && no "control DID NOT fire: phantom file passed" || ok "control fires: phantom path refused"


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
