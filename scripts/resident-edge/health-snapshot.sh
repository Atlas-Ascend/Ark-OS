#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="${HOME}/hypernet"
OUT="$ROOT/state/health.json"
mkdir -p "$ROOT/state"

now="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
sshd_state="STOPPED"
tmux_state="STOPPED"

pgrep -f '[s]shd' >/dev/null 2>&1 && sshd_state="RUNNING"
tmux has-session -t janus 2>/dev/null && tmux_state="RUNNING"

cat > "$OUT" <<JSON
{
  "node": "JANUS",
  "timestamp_utc": "$now",
  "resident_edge": "ONLINE",
  "sshd": "$sshd_state",
  "tmux": "$tmux_state",
  "battery_percent": "UNKNOWN",
  "network": "UNKNOWN",
  "routing_authority": "BOUNDED",
  "heavy_compute": false
}
JSON

# If Termux:API is installed, enrich only with non-secret local telemetry.
if command -v termux-battery-status >/dev/null 2>&1; then
  termux-battery-status > "$ROOT/state/battery.json" 2>/dev/null || true
fi

if command -v termux-wifi-connectioninfo >/dev/null 2>&1; then
  termux-wifi-connectioninfo > "$ROOT/state/wifi.json" 2>/dev/null || true
fi

cat "$OUT"
