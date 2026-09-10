#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

BRANCH="${ARK_BRANCH:-feat/ark-omega-cinematic-command-to-proof}"
ROOT="$HOME/ghost-atlas"
REPO="$ROOT/Ark-OS"
BIN="$HOME/.local/bin"
BOOTDIR="$HOME/.termux/boot"
STATE="$HOME/.local/state/ghost-atlas"
MARK_BEGIN="# >>> ARK OMEGA AUTOATTACH >>>"
MARK_END="# <<< ARK OMEGA AUTOATTACH <<<"

echo "=== GHOST ATLAS // ODIN ARK Ω PERSISTENT INSTALL ==="
pkg update -y
pkg install -y git openssh curl jq rsync python tmux
python -m pip install --upgrade pip

mkdir -p "$ROOT" "$BIN" "$BOOTDIR" "$STATE/logs" "$STATE/receipts" "$STATE/outbox" "$HOME/.config/ghost-atlas"

if [ ! -d "$REPO/.git" ]; then
  git clone --branch "$BRANCH" --single-branch https://github.com/Atlas-Ascend/Ark-OS.git "$REPO"
else
  git -C "$REPO" fetch origin "$BRANCH"
  git -C "$REPO" checkout "$BRANCH"
  git -C "$REPO" pull --ff-only origin "$BRANCH"
fi

python -m pip install -r "$REPO/ARK-OMEGA/termux/requirements.txt"
chmod +x "$REPO/ARK-OMEGA/termux/ark-service.sh"

cat > "$BIN/ark-service" <<EOF
#!/data/data/com.termux/files/usr/bin/bash
exec "$REPO/ARK-OMEGA/termux/ark-service.sh" "\$@"
EOF
cat > "$BIN/ark" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
set -e
ark-service start >/dev/null || true
exec ark-service attach
EOF
cat > "$BIN/ark-restart" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
exec ark-service restart
EOF
cat > "$BIN/ark-status" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
exec ark-service status
EOF
chmod +x "$BIN/ark-service" "$BIN/ark" "$BIN/ark-restart" "$BIN/ark-status"

cat > "$BOOTDIR/10-ark-omega.sh" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
export PATH="$HOME/.local/bin:$PREFIX/bin:$PATH"
sleep 8
ark-service start >> "$HOME/.local/state/ghost-atlas/logs/boot.log" 2>&1
EOF
chmod +x "$BOOTDIR/10-ark-omega.sh"

BASHRC="$HOME/.bashrc"
touch "$BASHRC"
python - "$BASHRC" "$MARK_BEGIN" "$MARK_END" <<'PY'
from pathlib import Path
import sys
p=Path(sys.argv[1]); begin=sys.argv[2]; end=sys.argv[3]
s=p.read_text() if p.exists() else ""
if begin in s and end in s:
    a=s.index(begin); b=s.index(end,a)+len(end)
    s=s[:a].rstrip()+"\n"+s[b:].lstrip("\n")
block='''# >>> ARK OMEGA AUTOATTACH >>>
export PATH="$HOME/.local/bin:$PATH"
if [[ $- == *i* ]] && [ -z "${TMUX:-}" ] && [ -z "${ARK_NO_AUTOATTACH:-}" ] && command -v ark-service >/dev/null 2>&1; then
  ark-service start >/dev/null 2>&1 || true
  if tmux has-session -t ark-omega 2>/dev/null; then
    exec tmux attach-session -t ark-omega
  fi
fi
# <<< ARK OMEGA AUTOATTACH <<<'''
p.write_text(s.rstrip()+"\n\n"+block+"\n")
PY

ark-service restart

echo
ark-service status || true
echo "PERSISTENT_INSTALL=PASS"
echo "BOOT_SCRIPT=$BOOTDIR/10-ark-omega.sh"
echo "COMMAND=ark"
echo "OPT_OUT_ONCE=ARK_NO_AUTOATTACH=1 bash"
echo "ANDROID_REQUIREMENT=Install/Open Termux:Boot once so Android executes ~/.termux/boot after device reboot."
