#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
ARK_ROOT="${GHOST_ATLAS_ROOT:-$HOME/.ghost-atlas}"
DEST="$ARK_ROOT/overlays/cyber-throne-v1"
RECEIPT="$ARK_ROOT/proof/cyber-throne-v1-install.receipt"
rm -rf "$DEST"
rm -f "$RECEIPT"
echo "CYBER_THRONE_OVERLAY_ROLLBACK=PASS"
echo "Current phone ARK baseline was not modified."
