#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ARK_REPO="https://github.com/Atlas-Ascend/Ark-OS.git"
ARK_BRANCH="${GA_ARK_FORENSICS_BRANCH:-convergence/odin-resident-estate-forensics-20260910}"
ARK_ROOT="${GA_ARK_ROOT:-$HOME/ghost-atlas/Ark-OS}"

say() { printf '\n[%s] %s\n' "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" "$*"; }
fail() { printf '\nODIN_FORENSICS_BOOTSTRAP=FAIL reason=%s\n' "$*" >&2; exit 1; }

say "ODIN resident estate-forensics bootstrap"

if ! command -v pkg >/dev/null 2>&1; then
  fail "termux_pkg_unavailable"
fi

say "Installing bounded resident dependencies"
pkg install -y git gh python openssh coreutils jq >/dev/null

mkdir -p "$(dirname "$ARK_ROOT")" "$HOME/hypernet/receipts" "$HOME/hypernet/workspaces"

if [ -d "$ARK_ROOT/.git" ]; then
  say "Refreshing existing Ark-OS checkout"
  git -C "$ARK_ROOT" remote set-url origin "$ARK_REPO"
  git -C "$ARK_ROOT" fetch --prune origin "$ARK_BRANCH"
else
  say "Cloning Ark-OS resident edge"
  git clone --quiet --single-branch --branch "$ARK_BRANCH" "$ARK_REPO" "$ARK_ROOT"
fi

cd "$ARK_ROOT"

if git show-ref --verify --quiet "refs/heads/$ARK_BRANCH"; then
  git switch "$ARK_BRANCH" >/dev/null
  git merge --ff-only "origin/$ARK_BRANCH" >/dev/null
else
  git switch -c "$ARK_BRANCH" --track "origin/$ARK_BRANCH" >/dev/null
fi

actual_branch="$(git branch --show-current)"
[ "$actual_branch" = "$ARK_BRANCH" ] || fail "unexpected_ark_branch:$actual_branch"

say "Installing ODIN command surface"
bash scripts/resident-edge/odin/install-janusctl.sh >/dev/null

if ! gh auth status >/dev/null 2>&1; then
  say "GitHub authentication required for the live 81-repository API census"
  gh auth login
fi

gh auth status >/dev/null 2>&1 || fail "github_auth_unavailable"

say "Executing canonical estate forensic census"
export GA_EXECUTOR_NODE="ODIN"
janusctl estate-forensics

latest_receipt="$(find "$HOME/hypernet/receipts" -maxdepth 1 -type f -name 'ODIN-ESTATE-FORENSICS-*.json' -print 2>/dev/null | sort | tail -n 1)"
[ -n "$latest_receipt" ] || fail "resident_receipt_not_found"

say "Verifying resident receipt"
python - "$latest_receipt" <<'PY'
import json, sys
p=sys.argv[1]
with open(p, encoding='utf-8') as f:
    d=json.load(f)
state=d.get('final_state')
if state not in {'VERIFIED_LOCAL','VERIFIED_LOCAL_AND_PUSHED'}:
    raise SystemExit(f'ODIN_FORENSICS_RECEIPT=FAIL final_state={state!r}')
print(f"ODIN_FORENSICS_RECEIPT=PASS final_state={state} path={p}")
print(f"REPOSITORIES={d.get('repository_count')}")
print(f"BRANCHES={d.get('branch_count')}")
print(f"LOGICAL_NODES={d.get('logical_node_count')}")
PY

say "Resident census complete"
printf 'ODIN_FORENSICS_BOOTSTRAP=PASS\nRECEIPT=%s\n' "$latest_receipt"
