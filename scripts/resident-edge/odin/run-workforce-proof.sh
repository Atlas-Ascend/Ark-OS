#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ARK_ROOT="${ODIN_ARK_ROOT:-$HOME/ghost-atlas/Ark-OS}"
WORKFORCE_REPO="${GA_WORKFORCE_REPO:-https://github.com/Atlas-Ascend/workforce-spine.git}"
WORKFORCE_BRANCH="${GA_WORKFORCE_BRANCH:-convergence/sprint31-resident-workforce-prometheus}"
ROOT="$HOME/hypernet"
WORKSPACES="$ROOT/workspaces"
RECEIPTS="$ROOT/receipts"
STAMP="$(date -u +'%Y%m%dT%H%M%SZ')"
WORKDIR="$WORKSPACES/workforce-sprint31-$STAMP"
mkdir -p "$WORKSPACES" "$RECEIPTS"

for cmd in git python gh; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "ODIN_WORKFORCE_PROOF=FAIL reason=${cmd}_missing" >&2; exit 20; }
done
if ! gh auth status >/dev/null 2>&1; then
  echo "ODIN_WORKFORCE_PROOF=BLOCKED reason=github_auth_required" >&2
  exit 21
fi
gh auth setup-git >/dev/null 2>&1 || true

identity_receipt="${GA_EXECUTOR_PROOF:-}"
if [ -z "$identity_receipt" ]; then
  identity_output="$(bash "$ARK_ROOT/scripts/resident-edge/odin/emit-odin-identity-receipt.sh")"
  printf '%s\n' "$identity_output"
  identity_receipt="$(printf '%s\n' "$identity_output" | sed -n 's/^ODIN_IDENTITY=PASS receipt=\([^ ]*\).*/\1/p' | tail -n 1)"
fi
[ -n "$identity_receipt" ] && [ -f "$identity_receipt" ] || { echo "ODIN_WORKFORCE_PROOF=FAIL reason=identity_receipt_missing" >&2; exit 22; }

git clone --quiet --single-branch --branch "$WORKFORCE_BRANCH" "$WORKFORCE_REPO" "$WORKDIR"
cd "$WORKDIR"
case "$(git remote get-url origin)" in
  *Atlas-Ascend/workforce-spine*) ;;
  *) echo "ODIN_WORKFORCE_PROOF=FAIL reason=unexpected_remote" >&2; exit 23 ;;
esac
[ "$(git branch --show-current)" = "$WORKFORCE_BRANCH" ] || { echo "ODIN_WORKFORCE_PROOF=FAIL reason=unexpected_branch" >&2; exit 24; }

python workforce/prove_resident.py --executor ODIN --executor-proof "$identity_receipt" --require-resident-identity
proof="$WORKDIR/proof/workforce-resident-proof.json"
[ -f "$proof" ] || { echo "ODIN_WORKFORCE_PROOF=FAIL reason=workforce_receipt_missing" >&2; exit 25; }
python - "$proof" <<'PY'
import json, sys
d=json.load(open(sys.argv[1], encoding='utf-8'))
assert d.get('gate') == 'PASS', d
assert d.get('execution_class') == 'resident-observed', d
assert d.get('executor_identity', {}).get('verified') is True, d
print('ODIN_WORKFORCE_RECEIPT=PASS')
print('MISSION_ID=' + str(d.get('mission_id')))
print('READY_PACKETS=' + str(len(d.get('ready_packets', []))))
print('BLOCKED_PACKETS=' + str(len(d.get('blocked_packets', {}))))
PY
out="$RECEIPTS/ODIN-WORKFORCE-SPRINT31-$STAMP.json"
cp "$proof" "$out"
sha256sum "$out" > "$out.sha256"
echo "ODIN_WORKFORCE_PROOF=PASS receipt=$out identity=$identity_receipt"
