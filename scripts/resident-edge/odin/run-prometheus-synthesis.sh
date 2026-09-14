#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

PROM_REPO="${GA_PROMETHEUS_REPO:-https://github.com/Atlas-Ascend/PROMETHEUS-AIS-V-1.1.1.git}"
PROM_BRANCH="${GA_PROMETHEUS_BRANCH:-convergence/sprint31-resident-workforce-prometheus}"
ROOT="$HOME/hypernet"
WORKSPACES="$ROOT/workspaces"
RECEIPTS="$ROOT/receipts"
STAMP="$(date -u +'%Y%m%dT%H%M%SZ')"
WORKDIR="$WORKSPACES/prometheus-sprint31-$STAMP"
BUNDLE="${1:-${GA_SPRINT31_EXECUTION_BUNDLE:-}}"
WORKFORCE_PROOF="${2:-${GA_WORKFORCE_PROOF_RECEIPT:-}}"

[ -n "$BUNDLE" ] && [ -f "$BUNDLE" ] || {
  echo "ODIN_PROMETHEUS_SYNTHESIS=FAIL reason=execution_bundle_missing" >&2
  exit 20
}

for cmd in git gh node; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "ODIN_PROMETHEUS_SYNTHESIS=FAIL reason=${cmd}_missing" >&2; exit 21; }
done

node_major="$(node -p 'Number(process.versions.node.split(".")[0])')"
[ "$node_major" -ge 22 ] || {
  echo "ODIN_PROMETHEUS_SYNTHESIS=FAIL reason=node_22_required current=$(node -v)" >&2
  exit 22
}

if ! gh auth status >/dev/null 2>&1; then
  echo "ODIN_PROMETHEUS_SYNTHESIS=BLOCKED reason=github_auth_required" >&2
  exit 23
fi
gh auth setup-git >/dev/null 2>&1 || true

mkdir -p "$WORKSPACES" "$RECEIPTS"
git clone --quiet --single-branch --branch "$PROM_BRANCH" "$PROM_REPO" "$WORKDIR"
cd "$WORKDIR/serverforge/software-design"

case "$(git -C "$WORKDIR" remote get-url origin)" in
  *Atlas-Ascend/PROMETHEUS-AIS-V-1.1.1*) ;;
  *) echo "ODIN_PROMETHEUS_SYNTHESIS=FAIL reason=unexpected_remote" >&2; exit 24 ;;
esac
[ "$(git -C "$WORKDIR" branch --show-current)" = "$PROM_BRANCH" ] || {
  echo "ODIN_PROMETHEUS_SYNTHESIS=FAIL reason=unexpected_branch" >&2
  exit 25
}

workforce_id=""
if [ -n "$WORKFORCE_PROOF" ] && [ -f "$WORKFORCE_PROOF" ]; then
  workforce_id="workforce-proof:$(sha256sum "$WORKFORCE_PROOF" | awk '{print $1}')"
fi

out="$RECEIPTS/ODIN-PROMETHEUS-SPRINT31-$STAMP.json"
cmd=(node --experimental-strip-types scripts/synthesize-resident-bundle.mjs --input "$BUNDLE" --output "$out")
if [ -n "$workforce_id" ]; then
  cmd+=(--workforce-proof-id "$workforce_id")
fi
"${cmd[@]}"

python - "$out" <<'PY'
import json, sys
p=sys.argv[1]
d=json.load(open(p, encoding='utf-8'))
assert d.get('promotableEvidence') is True, d
assert d.get('conclusion') == 'SUPPORTED', d
assert not d.get('contradictions'), d
assert d.get('authority', {}).get('promotionAuthority') is False, d
print('ODIN_PROMETHEUS_SYNTHESIS_RECEIPT=PASS')
PY

sha256sum "$out" > "$out.sha256"
echo "ODIN_PROMETHEUS_SYNTHESIS=PASS receipt=$out"
