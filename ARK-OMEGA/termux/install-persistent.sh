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
MARK_BEGIN="# >>> ARK OMEGA AUTOBOOT >>>"
MARK_END="# <<< ARK OMEGA AUTOBOOT <<<"

echo "=== GHOST ATLAS // ODIN ARK Ω FAIL-SAFE INSTALL v1.1.2 ==="
pkg update -y
pkg install -y git openssh curl jq rsync python tmux

mkdir -p "$ROOT" "$BIN" "$BOOTDIR" "$STATE/logs" "$STATE/receipts" "$STATE/outbox" "$HOME/.config/ghost-atlas" "$RUNTIME"

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

cat > "$BIN/ark-service" <<EOF
#!/data/data/com.termux/files/usr/bin/bash
export ARK_PYTHON="$VENV/bin/python"
exec "$REPO/ARK-OMEGA/termux/ark-service.sh" "\$@"
EOF
cat > "$BIN/ark" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
ark-service start >/dev/null 2>&1 || true
ark-service ui
rc=$?
if [ "$rc" -ne 0 ]; then
  echo "ARK_OMEGA_UI=FAILED RC=$rc"
  echo "SAFE_SHELL=ACTIVE"
fi
return "$rc" 2>/dev/null || exit "$rc"
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

cat > "$BOOTDIR/10-ark-omega.sh" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
export PATH="$HOME/.local/bin:$PREFIX/bin:$PATH"
LOG="$HOME/.local/state/ghost-atlas/logs/boot.log"
mkdir -p "$(dirname "$LOG")"
echo "BOOT_ATTEMPT=$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$LOG"
for n in 1 2 3 4 5 6 7 8 9 10 11 12; do
  if command -v ark-service >/dev/null 2>&1; then
    if ark-service start >> "$LOG" 2>&1; then
      echo "BOOT_RESULT=PASS ATTEMPT=$n" >> "$LOG"
      exit 0
    fi
  fi
  echo "BOOT_RETRY=$n" >> "$LOG"
  sleep 5
done
echo "BOOT_RESULT=FAIL" >> "$LOG"
exit 1
EOF
chmod +x "$BOOTDIR/10-ark-omega.sh"

BASHRC="$HOME/.bashrc"
touch "$BASHRC"
python - "$BASHRC" "$MARK_BEGIN" "$MARK_END" <<'PY'
from pathlib import Path
import sys
p=Path(sys.argv[1]); begin=sys.argv[2]; end=sys.argv[3]
s=p.read_text() if p.exists() else ""
# Remove both legacy autoattach and current autoboot blocks.
for a,b in [
    ("# >>> ARK OMEGA AUTOATTACH >>>", "# <<< ARK OMEGA AUTOATTACH <<<"),
    (begin,end),
]:
    if a in s and b in s:
        i=s.index(a); j=s.index(b,i)+len(b)
        s=s[:i].rstrip()+"\n"+s[j:].lstrip("\n")
block='''# >>> ARK OMEGA AUTOBOOT >>>
export PATH="$HOME/.local/bin:$PATH"
if [[ $- == *i* ]] && [ -z "${TMUX:-}" ] && [ -z "${ARK_NO_AUTOBOOT:-}" ] && [ -z "${ARK_AUTOBOOT_ATTEMPTED:-}" ] && command -v ark >/dev/null 2>&1; then
  export ARK_AUTOBOOT_ATTEMPTED=1
  ark || {
    printf '\nARK Ω SAFE SHELL // cockpit did not start.\n'
    printf 'Run: ark-diagnose\n'
  }
fi
# <<< ARK OMEGA AUTOBOOT <<<'''
p.write_text(s.rstrip()+"\n\n"+block+"\n")
PY

ark-service restart

echo
ark-service status || true
echo "FAILSAFE_INSTALL=PASS"
echo "PYTHON_RUNTIME=$VENV/bin/python"
echo "BOOT_SCRIPT=$BOOTDIR/10-ark-omega.sh"
echo "COMMAND=ark"
echo "DIAGNOSTICS=ark-diagnose"
echo "SAFE_SHELL_OPT_OUT=ARK_NO_AUTOBOOT=1 bash"
echo "BOOT_POLICY=HEADLESS_SUPERVISOR_ONLY"
echo "UI_POLICY=INTERACTIVE_TTY_ONLY_WITH_SAFE_SHELL_FALLBACK"
