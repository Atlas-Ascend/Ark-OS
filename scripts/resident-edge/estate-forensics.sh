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

# Reuse existing GitHub credentials without printing token material.
TOKEN="${GA_ESTATE_GITHUB_TOKEN:-${GH_TOKEN:-${GITHUB_TOKEN:-}}}"
if [ -z "$TOKEN" ] && command -v gh >/dev/null 2>&1; then
  TOKEN="$(gh auth token 2>/dev/null || true)"
fi
if [ -z "$TOKEN" ]; then
  echo 'ESTATE_FORENSICS_BLOCKED=github_api_auth_missing' >&2
  echo 'Authenticate with gh auth login or provide GA_ESTATE_GITHUB_TOKEN/GITHUB_TOKEN/GH_TOKEN.' >&2
  exit 22
fi
export GITHUB_TOKEN="$TOKEN"
export GH_TOKEN="$TOKEN"
if command -v gh >/dev/null 2>&1; then
  gh auth setup-git >/dev/null 2>&1 || true
fi

echo "ESTATE_FORENSICS_EXECUTOR=$EXECUTOR_NODE"
echo "ESTATE_FORENSICS_BRANCH=$BRANCH"
echo "ESTATE_FORENSICS_WORKDIR=$WORKDIR"

if command -v gh >/dev/null 2>&1; then
  gh repo clone "$REGISTRY_SLUG" "$WORKDIR" -- --quiet --single-branch --branch "$BRANCH"
else
  git clone --quiet --single-branch --branch "$BRANCH" "$REGISTRY_REPO" "$WORKDIR"
fi
cd "$WORKDIR"

# Verify the clone resolves to the governed source repository and expected branch.
remote="$(git remote get-url origin)"
current_branch="$(git branch --show-current)"
case "$remote" in
  *Atlas-Ascend/Estate-Service-Catalog-Capability-Registry*) ;;
  *) echo "ESTATE_FORENSICS_BLOCKED=unexpected_remote:$remote" >&2; exit 23 ;;
esac
[ "$current_branch" = "$BRANCH" ] || {
  echo "ESTATE_FORENSICS_BLOCKED=unexpected_branch:$current_branch" >&2
  exit 24
}

export GA_EXECUTOR_NODE="$EXECUTOR_NODE"
export GA_FORENSICS_PUSH="1"
export GA_EXPECTED_REPO_FLOOR="81"
export GA_EXPECTED_NODE_FLOOR="574"
export GA_FORENSICS_STRICT="0"

python scripts/run_forensics_resident.py

receipt="proof/ESTATE_RESIDENT_FORENSICS_RECEIPT.json"
[ -f "$receipt" ] || { echo 'ESTATE_FORENSICS_BLOCKED=resident_receipt_missing' >&2; exit 25; }

final_state="$(python -c 'import json; print(json.load(open("proof/ESTATE_RESIDENT_FORENSICS_RECEIPT.json", encoding="utf-8"))["final_state"])')"
case "$final_state" in
  VERIFIED_LOCAL|VERIFIED_LOCAL_AND_PUSHED) ;;
  *) echo "ESTATE_FORENSICS_GATE=FAIL final_state=$final_state" >&2; exit 26 ;;
esac

cp "$receipt" "$RECEIPTS/ODIN-ESTATE-FORENSICS-$STAMP.json"
sha256sum "$RECEIPTS/ODIN-ESTATE-FORENSICS-$STAMP.json" > "$RECEIPTS/ODIN-ESTATE-FORENSICS-$STAMP.sha256"

# Reuse the existing resident-edge proof surface.
if [ -f "$ARK_ROOT/scripts/resident-edge/emit-proof-receipt.sh" ]; then
  bash "$ARK_ROOT/scripts/resident-edge/emit-proof-receipt.sh" >/dev/null || true
fi

echo "ESTATE_FORENSICS_GATE=PASS executor=$EXECUTOR_NODE receipt=$RECEIPTS/ODIN-ESTATE-FORENSICS-$STAMP.json"
