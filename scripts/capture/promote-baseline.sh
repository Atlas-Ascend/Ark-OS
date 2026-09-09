#!/usr/bin/env bash
set -euo pipefail
IDENTITY="${1:-}"
if [[ -z "$IDENTITY" ]]; then echo "Usage: $0 JANUS|ODIN" >&2; exit 2; fi
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CAP="$ROOT/baseline/current-phone-ark/captures/$IDENTITY"
OUT="$ROOT/baseline/current-phone-ark/original"
"$ROOT/scripts/verification/verify-capture.sh" "$IDENTITY"
"$ROOT/scripts/verification/medusa-secret-gate.sh" "$CAP/files"
rm -rf "$OUT"
mkdir -p "$OUT"
cp -a "$CAP/files" "$OUT/files"
cp -a "$CAP/meta" "$OUT/meta"
cp "$CAP/SHA256SUMS" "$OUT/SHA256SUMS"
printf '%s\n' "$IDENTITY" > "$OUT/PROMOTED_FROM"
printf '%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$OUT/PROMOTED_AT_UTC"
echo "BASELINE_PROMOTION=PASS source=$IDENTITY"
