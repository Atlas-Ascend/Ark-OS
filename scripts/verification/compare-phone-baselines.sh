#!/usr/bin/env bash
set -euo pipefail
A="${1:-JANUS}"
B="${2:-ODIN}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
AF="$ROOT/baseline/current-phone-ark/captures/$A/files"
BF="$ROOT/baseline/current-phone-ark/captures/$B/files"
[[ -d "$AF" && -d "$BF" ]] || { echo "Both captures must exist" >&2; exit 1; }
TMPA="$(mktemp)"; TMPB="$(mktemp)"; trap 'rm -f "$TMPA" "$TMPB"' EXIT
(cd "$AF" && find . -type f -print0 | sort -z | xargs -0 -r sha256sum) > "$TMPA"
(cd "$BF" && find . -type f -print0 | sort -z | xargs -0 -r sha256sum) > "$TMPB"
if diff -u "$TMPA" "$TMPB"; then echo "PHONE_BASELINE_COMPARE=IDENTICAL $A=$B"; else echo "PHONE_BASELINE_COMPARE=DIFFERENT $A!=$B"; exit 3; fi
