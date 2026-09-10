#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="${HOME}/hypernet"
mkdir -p "$ROOT/logs" "$ROOT/state"

if ! pgrep -f '[s]shd' >/dev/null 2>&1; then
  sshd
fi

if ! tmux has-session -t janus 2>/dev/null; then
  tmux new-session -d -s janus -n resident
fi

cat > "$ROOT/state/resident.json" <<JSON
{
  "node": "JANUS",
  "role": "resident-edge",
  "sshd": "RUNNING",
  "ssh_port": 8022,
  "tmux_session": "janus",
  "heavy_compute": false,
  "wake_lock_default": false
}
JSON

date -u +'%Y-%m-%dT%H:%M:%SZ JANUS_RESIDENT_EDGE=STARTED' >> "$ROOT/logs/resident.log"

echo "JANUS_RESIDENT_EDGE=RUNNING"
echo "SSH_PORT=8022"
echo "TMUX_SESSION=janus"
