#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
ROOT="${HOME}/ghost-atlas/Ark-OS"
SRC="$ROOT/ARK-OMEGA/termux"
VENV="${HOME}/.local/share/ark-omega/venv"
BIN="${HOME}/.local/bin"
STATE="${HOME}/.local/state/ghost-atlas"
CONFIG="${HOME}/.config/ghost-atlas"

echo '============================================================'
echo ' GHOST ATLAS // ARK OMEGA // ODIN FIELD COMMAND ACCESSION '
echo '============================================================'
pkg update -y
pkg install -y python git gh openssh curl jq rsync tmux termux-api
python -m venv "$VENV"
"$VENV/bin/python" -m pip install --upgrade pip wheel
"$VENV/bin/pip" install -r "$SRC/requirements.txt"
mkdir -p "$BIN" "$STATE/receipts" "$STATE/outbox" "$CONFIG"
[ -f "$CONFIG/odin.json" ] || printf '%s\n' '{"vessel":"ODIN","peer":"AUTO","protocol":"ark-omega/0.1"}' > "$CONFIG/odin.json"
cat > "$BIN/ark" <<EOF
#!/data/data/com.termux/files/usr/bin/bash
exec "$VENV/bin/python" "$SRC/ark_omega.py" "\$@"
EOF
chmod 700 "$BIN/ark"
grep -q 'HOME/.local/bin' "$HOME/.bashrc" 2>/dev/null || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
echo 'ACCESSION_STAGE=TUI_INSTALLED'
echo 'Run: source ~/.bashrc && ark'
