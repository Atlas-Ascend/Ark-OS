#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REGISTRY_REPO="${GA_FORENSICS_REPO:-https://github.com/Atlas-Ascend/Estate-Service-Catalog-Capability-Registry.git}"
REGISTRY_SLUG="${GA_FORENSICS_REPO_SLUG:-Atlas-Ascend/Estate-Service-Catalog-Capability-Registry}"
BRANCH="${GA_FORENSICS_BRANCH:-convergence/estate-forensics-hypernet-81-repos-20260910}"
EXECUTOR_NODE="${GA_EXECUTOR_NODE:-ODIN}"
ARK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ROOT="${HOME}/hypernet"
WORKSPACES="$ROOT/workspaces"
RECEIPTS="$ROOT/receipts"
STAMP="$(date -u +'%Y%m%dT%H%M%SZ')"
WORKDIR="$WORKSPACES/estate-forensics-$STAMP"

mkdir -p "$WORKSPACES" "$RECEIPTS"

command -v git >/dev/null 2>&1 || { echo 'ESTATE_FORENSICS_BLOCKED=git_missing' >&2; exit 20; }
command -v python >/dev/null 2>&1 || { echo 'ESTATE_FORENSICS_BLOCKED=python_missing' >&2; exit 21; }

identity_emitter="$ARK_ROOT/scripts/resident-edge/odin/emit-odin-identity-receipt.sh"
[ -f "$identity_emitter" ] || { echo 'ESTATE_FORENSICS_BLOCKED=identity_emitter_missing' >&2; exit 22; }
identity_output="$(bash "$identity_emitter")"
printf '%s\n' "$identity_output"
identity_receipt="$(printf '%s\n' "$identity_output" | sed -n 's/^ODIN_IDENTITY=PASS receipt=\([^ ]*\).*/\1/p' | tail -n 1)"
[ -n "$identity_receipt" ] && [ -f "$identity_receipt" ] || {
  echo 'ESTATE_FORENSICS_BLOCKED=identity_receipt_missing' >&2
  exit 23
}

# Reuse existing GitHub credentials without printing token material.
TOKEN="${GA_ESTATE_GITHUB_TOKEN:-${GH_TOKEN:-${GITHUB_TOKEN:-}}}"
if [ -z "$TOKEN" ] && command -v gh >/dev/null 2>&1; then
  TOKEN="$(gh auth token 2>/dev/null || true)"
fi
if [ -z "$TOKEN" ]; then
  echo 'ESTATE_FORENSICS_BLOCKED=github_api_auth_missing' >&2
  echo 'Authenticate with gh auth login or provide GA_ESTATE_GITHUB_TOKEN/GITHUB_TOKEN/GH_TOKEN.' >&2
  exit 24
fi
export GITHUB_TOKEN="$TOKEN"
export GH_TOKEN="$TOKEN"
if command -v gh >/dev/null 2>&1; then
  gh auth setup-git >/dev/null 2>&1 || true
fi

echo "ESTATE_FORENSICS_EXECUTOR=$EXECUTOR_NODE"
echo "ESTATE_FORENSICS_IDENTITY_RECEIPT=$identity_receipt"
echo "ESTATE_FORENSICS_BRANCH=$BRANCH"
echo "ESTATE_FORENSICS_WORKDIR=$WORKDIR"

if command -v gh >/dev/null 2>&1; then
  gh repo clone "$REGISTRY_SLUG" "$WORKDIR" -- --quiet --single-branch --branch "$BRANCH"
else
  git clone --quiet --single-branch --branch "$BRANCH" "$REGISTRY_REPO" "$WORKDIR"
fi
cd "$WORKDIR"

remote="$(git remote get-url origin)"
current_branch="$(git branch --show-current)"
case "$remote" in
  *Atlas-Ascend/Estate-Service-Catalog-Capability-Registry*) ;;
  *) echo "ESTATE_FORENSICS_BLOCKED=unexpected_remote:$remote" >&2; exit 25 ;;
esac
[ "$current_branch" = "$BRANCH" ] || {
  echo "ESTATE_FORENSICS_BLOCKED=unexpected_branch:$current_branch" >&2
  exit 26
}

export GA_EXECUTOR_NODE="$EXECUTOR_NODE"
export GA_EXECUTOR_PROOF="$identity_receipt"
export GA_FORENSICS_REQUIRE_RESIDENT_IDENTITY="1"
export GA_FORENSICS_PUSH="1"
export GA_EXPECTED_REPO_FLOOR="81"
export GA_EXPECTED_NODE_FLOOR="574"
export GA_FORENSICS_STRICT="0"

python scripts/run_forensics_resident.py

receipt="proof/ESTATE_RESIDENT_FORENSICS_RECEIPT.json"
[ -f "$receipt" ] || { echo 'ESTATE_FORENSICS_BLOCKED=resident_receipt_missing' >&2; exit 27; }

python - "$receipt" <<'PY'
import json, sys
p=sys.argv[1]
d=json.load(open(p, encoding='utf-8'))
assert d.get('final_state') in {'VERIFIED_LOCAL','VERIFIED_LOCAL_AND_PUSHED'}, d
identity=d.get('executor',{}).get('identity',{})
assert identity.get('verified') is True, identity
assert d.get('executor',{}).get('evidence_class') == 'resident-observed', d.get('executor')
print('ESTATE_FORENSICS_RESIDENT_IDENTITY=PASS')
PY

out="$RECEIPTS/ODIN-ESTATE-FORENSICS-$STAMP.json"
cp "$receipt" "$out"
sha256sum "$out" > "$out.sha256"

if [ -f "$ARK_ROOT/scripts/resident-edge/emit-proof-receipt.sh" ]; then
  bash "$ARK_ROOT/scripts/resident-edge/emit-proof-receipt.sh" >/dev/null || true
fi

echo "ESTATE_FORENSICS_GATE=PASS executor=$EXECUTOR_NODE receipt=$out identity=$identity_receipt"
