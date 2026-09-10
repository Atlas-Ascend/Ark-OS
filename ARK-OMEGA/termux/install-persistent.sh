#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

BRANCH="${ARK_BRANCH:-feat/ark-omega-cinematic-command-to-proof}"
ROOT="$HOME/ghost-atlas"
REPO="$ROOT/Ark-OS"
BIN="$HOME/.local/bin"
BOOTDIR="$HOME/.termux/boot"
STATE="$HOME/.local/state/ghost-atlas"
RUNTIME="$HOME/.local/share/ark-omega"
VENV="$RUNTIME/venv"

echo "=== GHOST ATLAS // ODIN ARK Ω FAIL-SAFE INSTALL v1.1.3 ==="
pkg update -y
pkg install -y git openssh curl jq rsync python tmux

mkdir -p "$ROOT" "$BIN" "$BOOTDIR" "$STATE/logs" "$STATE/receipts" "$STATE/outbox" "$HOME/.config/ghost-atlas" "$RUNTIME" "$HOME/.tmp"
chmod 700 "$HOME/.tmp" 2>/dev/null || true

if [ ! -d "$REPO/.git" ]; then
  git clone --branch "$BRANCH" --single-branch https://github.com/Atlas-Ascend/Ark-OS.git "$REPO"
else
  git -C "$REPO" fetch origin "$BRANCH"
  git -C "$REPO" checkout "$BRANCH"
  git -C "$REPO" pull --ff-only origin "$BRANCH"
fi

if [ ! -x "$VENV/bin/python" ]; then
  python -m venv "$VENV"
fi
"$VENV/bin/python" -m pip install --disable-pip-version-check -r "$REPO/ARK-OMEGA/termux/requirements.txt"
chmod +x "$REPO/ARK-OMEGA/termux/ark-service.sh" "$REPO/ARK-OMEGA/termux/ark-ui.sh"

# Retire the legacy pre-failsafe UI session. It redirected the Textual PTY and could render blank.
if tmux has-session -t ark-omega 2>/dev/null; then
  tmux kill-session -t ark-omega || true
  echo "LEGACY_SESSION=RETIRED:ark-omega"
fi

cat > "$BIN/ark-service" <<EOF
#!/data/data/com.termux/files/usr/bin/bash
export HOME="$HOME"
export PREFIX="$PREFIX"
export TMPDIR="$HOME/.tmp"
export PATH="$HOME/.local/bin:$PREFIX/bin:$PREFIX/bin/applets:/system/bin:/system/xbin"
export ARK_PYTHON="$VENV/bin/python"
exec "$REPO/ARK-OMEGA/termux/ark-service.sh" "\$@"
EOF
cat > "$BIN/ark" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
set +e
ark-service start >/dev/null 2>&1
ark-service ui
rc=$?
stty sane 2>/dev/null || true
printf '\033[?25h\033[?1049l\033[0m' 2>/dev/null || true
if [ "$rc" -ne 0 ]; then
  echo
  echo "ARK Ω SAFE SHELL // cockpit did not start"
  echo "RC=$rc"
  echo "Run: ark-diagnose"
fi
exit "$rc"
EOF
cat > "$BIN/ark-restart" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
exec ark-service restart
EOF
cat > "$BIN/ark-status" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
exec ark-service status
EOF
cat > "$BIN/ark-diagnose" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
exec ark-service diagnose
EOF
chmod +x "$BIN/ark-service" "$BIN/ark" "$BIN/ark-restart" "$BIN/ark-status" "$BIN/ark-diagnose"

cat > "$BOOTDIR/10-ark-omega.sh" <<EOF
#!$PREFIX/bin/bash
export HOME="$HOME"
export PREFIX="$PREFIX"
export TMPDIR="$HOME/.tmp"
export PATH="$HOME/.local/bin:$PREFIX/bin:$PREFIX/bin/applets:/system/bin:/system/xbin"
LOG="$STATE/logs/boot.log"
mkdir -p "$STATE/logs" "$HOME/.tmp"
echo "BOOT_ATTEMPT=\$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "\$LOG"
for n in 1 2 3 4 5 6 7 8 9 10 11 12; do
  if [ -x "$BIN/ark-service" ]; then
    if "$BIN/ark-service" start >> "\$LOG" 2>&1; then
      echo "BOOT_RESULT=PASS ATTEMPT=\$n" >> "\$LOG"
      exit 0
    fi
  fi
  echo "BOOT_RETRY=\$n" >> "\$LOG"
  sleep 5
done
echo "BOOT_RESULT=FAIL" >> "\$LOG"
exit 1
EOF
chmod +x "$BOOTDIR/10-ark-omega.sh"

# Remove every previous ARK UI auto-exec block. Interactive shell must remain recoverable.
BASHRC="$HOME/.bashrc"
touch "$BASHRC"
python - "$BASHRC" <<'PY'
from pathlib import Path
import sys
p=Path(sys.argv[1]); s=p.read_text(errors='ignore') if p.exists() else ''
for begin,end in [
 ('# >>> ARK OMEGA AUTOATTACH >>>','# <<< ARK OMEGA AUTOATTACH <<<'),
 ('# >>> ARK OMEGA AUTOBOOT >>>','# <<< ARK OMEGA AUTOBOOT <<<'),
 ('# >>> ARK OMEGA FAILSAFE ENV >>>','# <<< ARK OMEGA FAILSAFE ENV <<<'),
]:
    while begin in s and end in s:
        i=s.index(begin); j=s.index(end,i)+len(end)
        s=s[:i].rstrip()+'\n'+s[j:].lstrip('\n')
block='''# >>> ARK OMEGA FAILSAFE ENV >>>
export HOME=/data/data/com.termux/files/home
export PREFIX=/data/data/com.termux/files/usr
export TMPDIR="$HOME/.tmp"
export PATH="$HOME/.local/bin:$PREFIX/bin:$PREFIX/bin/applets:/system/bin:/system/xbin"
# Boot starts the headless supervisor only. UI is explicit: ark
# This shell is never replaced automatically by ARK Ω.
# <<< ARK OMEGA FAILSAFE ENV <<<'''
p.write_text(s.rstrip()+'\n\n'+block+'\n')
PY

ark-service restart

echo
ark-service status || true
echo "FAILSAFE_INSTALL=PASS"
echo "VERSION=1.1.3"
echo "LEGACY_UI_SESSION=RETIRED"
echo "BOOT_POLICY=HEADLESS_SUPERVISOR_ONLY"
echo "UI_POLICY=EXPLICIT_INTERACTIVE_TTY_ONLY"
echo "SAFE_SHELL_FALLBACK=ENABLED"
echo "COMMAND=ark"
echo "DIAGNOSTICS=ark-diagnose"
