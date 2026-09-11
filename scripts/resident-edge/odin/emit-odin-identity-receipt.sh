#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="${HOME}/hypernet"
RECEIPTS="$ROOT/receipts"
STATE="$ROOT/state"
ARK_ROOT="${ODIN_ARK_ROOT:-$HOME/ghost-atlas/Ark-OS}"
STAMP="$(date -u +'%Y%m%dT%H%M%SZ')"
CREATED="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
OUT="$RECEIPTS/ODIN-IDENTITY-$STAMP.json"
KEY="$HOME/.ssh/id_ed25519"
PUB="$KEY.pub"

mkdir -p "$RECEIPTS" "$STATE" "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

command -v python >/dev/null 2>&1 || { echo 'ODIN_IDENTITY=FAIL reason=python_missing' >&2; exit 20; }
command -v ssh-keygen >/dev/null 2>&1 || { echo 'ODIN_IDENTITY=FAIL reason=ssh_keygen_missing' >&2; exit 21; }

if [ ! -f "$PUB" ]; then
  ssh-keygen -q -t ed25519 -N '' -f "$KEY"
fi
chmod 600 "$KEY" 2>/dev/null || true
chmod 644 "$PUB" 2>/dev/null || true

PREFIX_OK=false
case "${PREFIX:-}" in
  /data/data/com.termux/files/usr*) PREFIX_OK=true ;;
esac

GETPROP="/system/bin/getprop"
ANDROID_OK=false
MODEL=""
DEVICE=""
MANUFACTURER=""
SDK=""
if [ -x "$GETPROP" ]; then
  MODEL="$($GETPROP ro.product.model 2>/dev/null || true)"
  DEVICE="$($GETPROP ro.product.device 2>/dev/null || true)"
  MANUFACTURER="$($GETPROP ro.product.manufacturer 2>/dev/null || true)"
  SDK="$($GETPROP ro.build.version.sdk 2>/dev/null || true)"
  [ -n "$MODEL" ] && ANDROID_OK=true
fi

ANCHOR="$(sha256sum "$PUB" | awk '{print $1}')"
BRANCH="UNAVAILABLE"
COMMIT="UNAVAILABLE"
if [ -d "$ARK_ROOT/.git" ]; then
  BRANCH="$(git -C "$ARK_ROOT" branch --show-current 2>/dev/null || true)"
  COMMIT="$(git -C "$ARK_ROOT" rev-parse HEAD 2>/dev/null || true)"
fi

PHYSICAL=false
if [ "$PREFIX_OK" = true ] && [ "$ANDROID_OK" = true ] && [ -d /proc ]; then
  PHYSICAL=true
fi

export ODIN_ID_CREATED="$CREATED"
export ODIN_ID_OUT="$OUT"
export ODIN_ID_PREFIX_OK="$PREFIX_OK"
export ODIN_ID_ANDROID_OK="$ANDROID_OK"
export ODIN_ID_PHYSICAL="$PHYSICAL"
export ODIN_ID_MODEL="$MODEL"
export ODIN_ID_DEVICE="$DEVICE"
export ODIN_ID_MANUFACTURER="$MANUFACTURER"
export ODIN_ID_SDK="$SDK"
export ODIN_ID_ANCHOR="$ANCHOR"
export ODIN_ID_BRANCH="$BRANCH"
export ODIN_ID_COMMIT="$COMMIT"
export ODIN_ID_UNAME="$(uname -a 2>/dev/null || true)"

python - <<'PY'
import json, os
from pathlib import Path

def b(name: str) -> bool:
    return os.environ.get(name, '').lower() == 'true'

payload = {
    'schema': 'ghost-atlas.physical-resident-identity/v1',
    'node': 'ODIN',
    'created_at': os.environ['ODIN_ID_CREATED'],
    'identity_anchor_type': 'ssh-ed25519-public-key-sha256',
    'identity_anchor_sha256': os.environ['ODIN_ID_ANCHOR'],
    'verification': {
        'physical_device_execution': b('ODIN_ID_PHYSICAL'),
        'termux_environment': b('ODIN_ID_PREFIX_OK'),
        'android_userspace': b('ODIN_ID_ANDROID_OK'),
        'identity_anchor_sha256': os.environ['ODIN_ID_ANCHOR'],
    },
    'device': {
        'manufacturer': os.environ.get('ODIN_ID_MANUFACTURER') or None,
        'model': os.environ.get('ODIN_ID_MODEL') or None,
        'device': os.environ.get('ODIN_ID_DEVICE') or None,
        'android_sdk': os.environ.get('ODIN_ID_SDK') or None,
        'uname': os.environ.get('ODIN_ID_UNAME') or None,
    },
    'ark_os': {
        'branch': os.environ.get('ODIN_ID_BRANCH'),
        'commit': os.environ.get('ODIN_ID_COMMIT'),
    },
    'credential_boundary': 'Only the SHA-256 fingerprint of the public SSH key is recorded. No private key or token material is included.',
}
out = Path(os.environ['ODIN_ID_OUT'])
out.write_text(json.dumps(payload, indent=2, sort_keys=True) + '\n', encoding='utf-8')
print(json.dumps(payload, indent=2, sort_keys=True))
PY

if [ "$PHYSICAL" != true ]; then
  echo "ODIN_IDENTITY=FAIL receipt=$OUT reason=physical_termux_android_not_verified" >&2
  exit 22
fi

echo "ODIN_IDENTITY=PASS receipt=$OUT anchor=$ANCHOR"
