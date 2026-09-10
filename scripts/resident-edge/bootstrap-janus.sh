#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="${HOME}/hypernet"

mkdir -p \
  "$ROOT/bin" \
  "$ROOT/inbox" \
  "$ROOT/packets/pending" \
  "$ROOT/packets/claimed" \
  "$ROOT/packets/running" \
  "$ROOT/packets/complete" \
  "$ROOT/packets/failed" \
  "$ROOT/events" \
  "$ROOT/receipts" \
  "$ROOT/logs" \
  "$ROOT/state" \
  "$ROOT/spool/outbound"

for pkg in openssh git tmux rsync python; do
  if ! command -v "$pkg" >/dev/null 2>&1; then
    pkg install -y "$pkg"
  fi
done

cat > "$ROOT/state/nodes.json" <<'JSON'
{
  "janus": {"state": "ONLINE", "role": "resident-edge"},
  "odin": {"state": "MOBILE", "role": "mobile-operator"},
  "eden": {"state": "UNKNOWN", "role": "local-runtime"},
  "shambala": {"state": "UNKNOWN", "role": "local-node"},
  "t5810a": {"state": "OFFLINE", "role": "compute-reserve"},
  "t5810b": {"state": "OFFLINE", "role": "compute-reserve"}
}
JSON

chmod 700 "$ROOT"

echo "JANUS_RESIDENT_EDGE_BOOTSTRAP=PASS"
echo "ROOT=$ROOT"
echo "NEXT: configure ODIN public key in ~/.ssh/authorized_keys, then run scripts/resident-edge/start-janus.sh"
