#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ARK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ROOT="${HOME}/hypernet"
STATE="$ROOT/state"
RECEIPTS="$ROOT/receipts"
mkdir -p "$STATE" "$RECEIPTS"

bash "$ARK_ROOT/scripts/resident-edge/health-snapshot.sh" >/dev/null
bash "$ARK_ROOT/scripts/resident-edge/fabric-health.sh" --core >/dev/null || true

stamp="$(date -u +'%Y%m%dT%H%M%SZ')"
created="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
out="$RECEIPTS/JANUS-RESIDENT-EDGE-$stamp.json"

sshd_state="$(jq -r '.sshd // "UNKNOWN"' "$STATE/health.json")"
tmux_state="$(jq -r '.tmux // "UNKNOWN"' "$STATE/health.json")"
local_state="FAIL"
if [ "$sshd_state" = "RUNNING" ] && [ "$tmux_state" = "RUNNING" ]; then
  local_state="PASS"
fi

hashes='[]'
for f in resident.json nodes.json health.json fabric-health.json; do
  if [ -f "$STATE/$f" ]; then
    digest="$(sha256sum "$STATE/$f" | awk '{print $1}')"
    hashes="$(jq -c --arg path "state/$f" --arg sha256 "$digest" '. + [{path:$path,sha256:$sha256}]' <<<"$hashes")"
  fi
done

jq -n \
  --arg receipt_id "JANUS-RESIDENT-EDGE-$stamp" \
  --arg created_at "$created" \
  --arg local_state "$local_state" \
  --arg sshd "$sshd_state" \
  --arg tmux "$tmux_state" \
  --argjson artifact_hashes "$hashes" \
  '{
    schema:"ghost-atlas.proof.receipt/v1",
    receipt_id:$receipt_id,
    node:"JANUS",
    profile:"janus-resident-edge-v1",
    created_at:$created_at,
    verification:{
      resident_runtime:$local_state,
      sshd:$sshd,
      tmux:$tmux,
      physical_device_execution:true,
      cloud_fabric_reachability:"informational"
    },
    artifact_hashes:$artifact_hashes,
    promotion_rule:"Do not promote JANUS resident-edge to physically verified unless resident_runtime is PASS and ODIN key-auth SSH plus reboot persistence are separately demonstrated."
  }' > "$out"

cat "$out"
echo "RECEIPT_PATH=$out"
