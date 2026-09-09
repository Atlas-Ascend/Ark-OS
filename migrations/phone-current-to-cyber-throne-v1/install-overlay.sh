#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
ARK_ROOT="${GHOST_ATLAS_ROOT:-$HOME/.ghost-atlas}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DEST="$ARK_ROOT/overlays/cyber-throne-v1"
RECEIPT="$ARK_ROOT/proof/cyber-throne-v1-install.receipt"
mkdir -p "$DEST" "$(dirname "$RECEIPT")"
cp -a "$REPO_ROOT/profiles/t2-mobile/cyber-throne/." "$DEST/"
{
  echo "schema=ga-ark-overlay-receipt/v1"
  echo "overlay=cyber-throne-v1"
  echo "installed_at_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "baseline_mutated=false"
} > "$RECEIPT"
echo "CYBER_THRONE_OVERLAY_INSTALL=PASS"
echo "Baseline untouched. Activation wiring remains explicit/system-specific."
