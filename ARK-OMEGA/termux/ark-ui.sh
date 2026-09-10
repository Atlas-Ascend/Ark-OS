#!/data/data/com.termux/files/usr/bin/bash
set -u

REPO="${ARK_REPO:-$HOME/ghost-atlas/Ark-OS}"
APP="$REPO/ARK-OMEGA/termux/ark_omega.py"
PYTHON_BIN="${ARK_PYTHON:-$HOME/.local/share/ark-omega/venv/bin/python}"
LOGDIR="$HOME/.local/state/ghost-atlas/logs"
mkdir -p "$LOGDIR"

restore_terminal() {
  stty sane 2>/dev/null || true
  printf '\033[?25h\033[?1049l\033[0m' 2>/dev/null || true
}
trap restore_terminal EXIT HUP INT TERM

if [ ! -t 0 ] || [ ! -t 1 ]; then
  echo "ARK_OMEGA_UI=SKIP NO_INTERACTIVE_TTY" >> "$LOGDIR/ark-ui.log"
  exit 0
fi

if [ ! -x "$PYTHON_BIN" ]; then
  restore_terminal
  echo "ARK Ω SAFE SHELL"
  echo "UI_NOT_STARTED=PYTHON_RUNTIME_MISSING"
  echo "EXPECTED=$PYTHON_BIN"
  exit 69
fi

if [ ! -f "$APP" ]; then
  restore_terminal
  echo "ARK Ω SAFE SHELL"
  echo "UI_NOT_STARTED=APP_MISSING"
  echo "EXPECTED=$APP"
  exit 66
fi

if ! "$PYTHON_BIN" -c 'import textual' >/dev/null 2>&1; then
  restore_terminal
  echo "ARK Ω SAFE SHELL"
  echo "UI_NOT_STARTED=TEXTUAL_IMPORT_FAILED"
  exit 70
fi

export TERM="${TERM:-xterm-256color}"
export COLORTERM="${COLORTERM:-truecolor}"
"$PYTHON_BIN" "$APP" 2>>"$LOGDIR/ark-ui.log"
rc=$?
restore_terminal

if [ "$rc" -ne 0 ]; then
  echo
  echo "=== ARK Ω SAFE SHELL ==="
  echo "COCKPIT_EXIT=$rc"
  echo "LAST_LOG=$LOGDIR/ark-ui.log"
  tail -n 12 "$LOGDIR/ark-ui.log" 2>/dev/null || true
  echo "Run: ark-diagnose"
fi
exit "$rc"
