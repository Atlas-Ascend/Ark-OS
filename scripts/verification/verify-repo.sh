#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
required=(
  README.md VERSION ARK_BASELINE.lock
  profiles/t2-mobile/current/profile.yaml
  profiles/t2-mobile/cyber-throne/profile.yaml
  contracts/ark-node.schema.yaml
  contracts/ark-command-node.contract.yaml
  migrations/phone-current-to-cyber-throne-v1/install-overlay.sh
  migrations/phone-current-to-cyber-throne-v1/rollback-overlay.sh
)
for f in "${required[@]}"; do [[ -e "$ROOT/$f" ]] || { echo "MISSING $f" >&2; exit 1; }; done
"$ROOT/scripts/verification/medusa-secret-gate.sh" "$ROOT"
echo "GA_ARK_REPO_VERIFY=PASS"
