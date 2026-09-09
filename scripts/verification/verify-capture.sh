#!/usr/bin/env bash
set -euo pipefail
IDENTITY="${1:-}"
if [[ -z "$IDENTITY" ]]; then echo "Usage: $0 JANUS|ODIN" >&2; exit 2; fi
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CAP="$ROOT/baseline/current-phone-ark/captures/$IDENTITY"
[[ -d "$CAP/files" ]] || { echo "Missing capture files: $CAP/files" >&2; exit 1; }
[[ -f "$CAP/meta/DEVICE-MANIFEST.yaml" ]] || { echo "Missing device manifest" >&2; exit 1; }
[[ -f "$CAP/SHA256SUMS" ]] || { echo "Missing SHA256SUMS" >&2; exit 1; }
(cd "$CAP/files" && sha256sum -c ../SHA256SUMS)
echo "CAPTURE_VERIFY=PASS identity=$IDENTITY"
