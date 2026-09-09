#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

IDENTITY=""
SOURCE="${GHOST_ATLAS_ROOT:-$HOME/.ghost-atlas}"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --identity) IDENTITY="${2:-}"; shift 2 ;;
    --source) SOURCE="${2:-}"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

if [[ -z "$IDENTITY" ]]; then
  echo "Usage: $0 --identity JANUS|ODIN [--source PATH]" >&2
  exit 2
fi
if [[ ! -d "$SOURCE" ]]; then
  echo "ARK source root not found: $SOURCE" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DEST="$REPO_ROOT/baseline/current-phone-ark/captures/$IDENTITY"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/files"
REJECT="$TMP/REJECTED-PATHS.txt"
: > "$REJECT"

find "$SOURCE" -type f -print0 | while IFS= read -r -d '' file; do
  rel="${file#$SOURCE/}"
  lower="$(printf '%s' "$rel" | tr '[:upper:]' '[:lower:]')"
  case "$lower" in
    *"/.ssh/"*|.ssh/*|*"/.cache/"*|.cache/*|*"/cache/"*|cache/*|*"/logs/"*|logs/*|*"/log/"*|log/*|*"/models/"*|models/*|*.gguf|*.bin|*.sqlite|*.sqlite3|*.db|*.pem|*.key|*.p12|*.pfx|*.keystore|.env|.env.*|*credential*|*secret*|*token*)
      printf '%s\n' "$rel" >> "$REJECT"; continue ;;
  esac
  size="$(wc -c < "$file" 2>/dev/null || echo 999999999)"
  if [[ "$size" -gt 2097152 ]]; then printf '%s\n' "$rel" >> "$REJECT"; continue; fi
  case "$lower" in
    *.sh|*.bash|*.py|*.js|*.mjs|*.cjs|*.ts|*.tsx|*.jsx|*.json|*.yaml|*.yml|*.toml|*.ini|*.conf|*.cfg|*.md|*.txt|*.service|*.socket|*.target|*.env.example|*/readme|readme|*/version|version|*/license|license) ;;
    *) printf '%s\n' "$rel" >> "$REJECT"; continue ;;
  esac
  if grep -Eqi '(BEGIN (RSA |OPENSSH |EC )?PRIVATE KEY|(^|[^A-Za-z])(api[_-]?key|access[_-]?token|auth[_-]?token|password|passwd|client[_-]?secret)[[:space:]]*[:=][[:space:]]*[^[:space:]#]{6,})' "$file" 2>/dev/null; then
    printf '%s\n' "$rel" >> "$REJECT"; continue
  fi
  mkdir -p "$TMP/files/$(dirname "$rel")"
  cp -p "$file" "$TMP/files/$rel"
done

mkdir -p "$TMP/meta"
{
  echo "schema: ga-ark-device-capture/v1"
  echo "identity: $IDENTITY"
  echo "captured_at_utc: \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""
  echo "source_root: \"~/.ghost-atlas\""
  echo "capture_policy: safe-source-config-v1"
  echo "host_kernel: \"$(uname -srmo 2>/dev/null | sed 's/"/\\"/g')\""
  if command -v getprop >/dev/null 2>&1; then echo "android_release: \"$(getprop ro.build.version.release 2>/dev/null | sed 's/"/\\"/g')\""; fi
} > "$TMP/meta/DEVICE-MANIFEST.yaml"

(cd "$TMP/files" && find . -type f -print0 | sort -z | xargs -0 -r sha256sum) > "$TMP/SHA256SUMS"
rm -rf "$DEST"
mkdir -p "$DEST"
cp -a "$TMP/files" "$DEST/files"
cp -a "$TMP/meta" "$DEST/meta"
cp "$TMP/SHA256SUMS" "$DEST/SHA256SUMS"
cp "$REJECT" "$DEST/REJECTED-PATHS.txt"
printf 'Captured safe ARK baseline for %s\n' "$IDENTITY"
printf 'Destination: %s\n' "$DEST"
printf 'Files: %s\n' "$(find "$DEST/files" -type f | wc -l)"
printf 'Rejected/private candidates: %s\n' "$(wc -l < "$DEST/REJECTED-PATHS.txt")"
printf 'NEXT: bash scripts/verification/verify-capture.sh %s\n' "$IDENTITY"
