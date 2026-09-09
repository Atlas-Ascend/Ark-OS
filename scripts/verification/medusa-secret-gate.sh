#!/usr/bin/env bash
set -euo pipefail
TARGET="${1:-.}"
FAIL=0
while IFS= read -r -d '' f; do
  [[ "$(basename "$f")" == "medusa-secret-gate.sh" ]] && continue
  lower="$(printf '%s' "$f" | tr '[:upper:]' '[:lower:]')"
  case "$lower" in
    */.env|*/.env.*|*.pem|*.key|*.p12|*.pfx|*.keystore|*/.ssh/*|*credentials*|*secret*|*token*) echo "MEDUSA_BLOCK path=$f" >&2; FAIL=1 ;;
  esac
done < <(find "$TARGET" -type f -print0)
while IFS= read -r -d '' f; do
  [[ "$(basename "$f")" == "medusa-secret-gate.sh" ]] && continue
  if file "$f" 2>/dev/null | grep -qiE 'text|json|yaml|script|empty'; then
    if grep -Eqi '(BEGIN (RSA |OPENSSH |EC )?PRIVATE KEY|(^|[^A-Za-z])(api[_-]?key|access[_-]?token|auth[_-]?token|password|passwd|client[_-]?secret)[[:space:]]*[:=][[:space:]]*[^[:space:]#]{6,})' "$f" 2>/dev/null; then echo "MEDUSA_BLOCK content=$f" >&2; FAIL=1; fi
  fi
done < <(find "$TARGET" -type f -print0)
if [[ "$FAIL" -ne 0 ]]; then echo "MEDUSA_SECRET_GATE=FAIL" >&2; exit 4; fi
echo "MEDUSA_SECRET_GATE=PASS"
