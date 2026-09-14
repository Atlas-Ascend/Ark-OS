#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ARK_ROOT="${ODIN_ARK_ROOT:-$HOME/ghost-atlas/Ark-OS}"
GARI_REPO="${GA_GARI_REPO:-https://github.com/Atlas-Ascend/GARI-.git}"
GARI_BRANCH="${GA_GARI_BRANCH:-convergence/sprint31-resident-gari-proof}"
ROOT="$HOME/hypernet"
WORKSPACES="$ROOT/workspaces"
RECEIPTS="$ROOT/receipts"
STAMP="$(date -u +'%Y%m%dT%H%M%SZ')"
WORKDIR="$WORKSPACES/gari-sprint31-$STAMP"

mkdir -p "$WORKSPACES" "$RECEIPTS"

for cmd in git python gh; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "ODIN_GARI_PROOF=FAIL reason=${cmd}_missing" >&2; exit 20; }
done

if ! gh auth status >/dev/null 2>&1; then
  echo "ODIN_GARI_PROOF=BLOCKED reason=github_auth_required" >&2
  echo "Run: gh auth login" >&2
  exit 21
fi
gh auth setup-git >/dev/null 2>&1 || true

identity_receipt="${GA_EXECUTOR_PROOF:-}"
if [ -z "$identity_receipt" ]; then
  identity_output="$(bash "$ARK_ROOT/scripts/resident-edge/odin/emit-odin-identity-receipt.sh")"
  printf '%s\n' "$identity_output"
  identity_receipt="$(printf '%s\n' "$identity_output" | sed -n 's/^ODIN_IDENTITY=PASS receipt=\([^ ]*\).*/\1/p' | tail -n 1)"
fi
[ -n "$identity_receipt" ] && [ -f "$identity_receipt" ] || {
  echo "ODIN_GARI_PROOF=FAIL reason=identity_receipt_missing" >&2
  exit 22
}

git clone --quiet --single-branch --branch "$GARI_BRANCH" "$GARI_REPO" "$WORKDIR"
cd "$WORKDIR"

case "$(git remote get-url origin)" in
  *Atlas-Ascend/GARI-*) ;;
  *) echo "ODIN_GARI_PROOF=FAIL reason=unexpected_remote" >&2; exit 23 ;;
esac
[ "$(git branch --show-current)" = "$GARI_BRANCH" ] || {
  echo "ODIN_GARI_PROOF=FAIL reason=unexpected_branch" >&2
  exit 24
}

python -m pip install --disable-pip-version-check -e '.[dev]'
python -m lantern.prove_resident \
  --executor ODIN \
  --executor-proof "$identity_receipt" \
  --require-resident-identity
python -m lantern.sprint31_bundle

proof="$WORKDIR/.proof/jarvis-gari/JARVIS-GARI-CONTRACT-LATEST.json"
bundle="$WORKDIR/.proof/jarvis-gari/SPRINT31-EXECUTION-BUNDLE.json"
[ -f "$proof" ] && [ -f "$bundle" ] || {
  echo "ODIN_GARI_PROOF=FAIL reason=proof_or_bundle_missing" >&2
  exit 25
}

python - "$proof" "$bundle" <<'PY'
import json, sys
proof=json.load(open(sys.argv[1], encoding='utf-8'))
bundle=json.load(open(sys.argv[2], encoding='utf-8'))
assert proof.get('state') == 'PROVEN', proof
assert proof.get('execution_class') == 'resident-observed', proof
assert proof.get('executor_identity', {}).get('verified') is True, proof
assert bundle.get('adapterGate') == 'PASS', bundle
assert bundle.get('executionState') == 'SUCCEEDED', bundle
assert bundle.get('executorIdentityVerified') is True, bundle
print('ODIN_GARI_RESIDENT_CONTRACT=PASS')
PY

proof_out="$RECEIPTS/ODIN-GARI-SPRINT31-$STAMP.json"
bundle_out="$RECEIPTS/ODIN-GARI-SPRINT31-BUNDLE-$STAMP.json"
cp "$proof" "$proof_out"
cp "$bundle" "$bundle_out"
sha256sum "$proof_out" > "$proof_out.sha256"
sha256sum "$bundle_out" > "$bundle_out.sha256"

echo "ODIN_GARI_PROOF=PASS proof=$proof_out bundle=$bundle_out identity=$identity_receipt"
