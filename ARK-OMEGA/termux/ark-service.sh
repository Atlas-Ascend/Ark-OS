#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPO="${ARK_REPO:-$HOME/ghost-atlas/Ark-OS}"
SESSION="${ARK_TMUX_SESSION:-ark-omega-supervisor}"
STATE="$HOME/.local/state/ghost-atlas"
LOGDIR="$STATE/logs"
HEARTBEAT="$STATE/ark-omega-supervisor.heartbeat"
UI="$REPO/ARK-OMEGA/termux/ark-ui.sh"
mkdir -p "$LOGDIR"

start_supervisor() {
  if tmux has-session -t "$SESSION" 2>/dev/null; then
    echo "ARK_OMEGA_SERVICE=ALREADY_RUNNING SESSION=$SESSION"
    return 0
  fi
  command -v termux-wake-lock >/dev/null 2>&1 && termux-wake-lock || true
  tmux new-session -d -s "$SESSION" "while :; do date -u +%Y-%m-%dT%H:%M:%SZ > '$HEARTBEAT'; sleep 30; done"
  sleep 1
  if tmux has-session -t "$SESSION" 2>/dev/null; then
    echo "ARK_OMEGA_SERVICE=STARTED SESSION=$SESSION"
  else
    echo "ARK_OMEGA_SERVICE=FAIL SUPERVISOR_START_FAILED"
    return 70
  fi
}

case "${1:-start}" in
  start)
    start_supervisor
    ;;
  stop)
    tmux kill-session -t "$SESSION" 2>/dev/null || true
    command -v termux-wake-unlock >/dev/null 2>&1 && termux-wake-unlock || true
    echo "ARK_OMEGA_SERVICE=STOPPED"
    ;;
  restart)
    "$0" stop
    "$0" start
    ;;
  status)
    if tmux has-session -t "$SESSION" 2>/dev/null; then
      hb="$(cat "$HEARTBEAT" 2>/dev/null || echo UNKNOWN)"
      echo "ARK_OMEGA_SERVICE=RUNNING SESSION=$SESSION HEARTBEAT=$hb"
    else
      echo "ARK_OMEGA_SERVICE=STOPPED"
      exit 3
    fi
    ;;
  ui|attach)
    start_supervisor >/dev/null || true
    exec "$UI"
    ;;
  diagnose)
    echo "=== ARK Ω DIAGNOSTICS ==="
    "$0" status || true
    echo "REPO=$REPO"
    echo "UI=$UI"
    [ -x "$UI" ] && echo "UI_SCRIPT=PASS" || echo "UI_SCRIPT=FAIL"
    [ -x "$HOME/.local/share/ark-omega/venv/bin/python" ] && echo "PYTHON_RUNTIME=PASS" || echo "PYTHON_RUNTIME=FAIL"
    "$HOME/.local/share/ark-omega/venv/bin/python" -c 'import textual; print("TEXTUAL=PASS")' 2>/dev/null || echo "TEXTUAL=FAIL"
    echo "--- BOOT LOG ---"
    tail -n 20 "$LOGDIR/boot.log" 2>/dev/null || echo "NO_BOOT_LOG"
    echo "--- UI LOG ---"
    tail -n 20 "$LOGDIR/ark-ui.log" 2>/dev/null || echo "NO_UI_LOG"
    ;;
  *)
    echo "usage: ark-service {start|stop|restart|status|ui|attach|diagnose}" >&2
    exit 64
    ;;
esac
