#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
SOURCE="$SCRIPT_DIR/atlas"
DEST="${PREFIX:-/data/data/com.termux/files/usr}/bin/atlas"

[ -f "$SOURCE" ] || { echo "Atlas launcher source missing: $SOURCE" >&2; exit 1; }
install -m 0755 "$SOURCE" "$DEST"
printf 'ATLAS_TERMUX_LAUNCHER=INSTALLED path=%s\n' "$DEST"
printf 'Run: atlas | atlas try | atlas operator | atlas status\n'
