#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPO="${ARK_REPO:-$HOME/ghost-atlas/Ark-OS}"
APP="$REPO/ARK-OMEGA/termux/ark_omega.py"
SESSION="${ARK_TMUX_SESSION:-ark-omega}"
LOGDIR="$HOME/.local/state/ghost-atlas/logs"
PYTHON_BIN="${ARK_PYTHON:-$HOME/.local/share/ark-omega/venv/bin/python}"
mkdir -p "$LOGDIR"

case "${1:-start}" in
  start)
    if tmux has-session -t "$SESSION" 2>/dev/null; then
      echo "ARK_OMEGA_SERVICE=ALREADY_RUNNING"
      exit 0
    fi
    [ -f "$APP" ] || { echo "ARK_OMEGA_SERVICE=FAIL APP_NOT_FOUND=$APP"; exit 66; }
    [ -x "$PYTHON_BIN" ] || { echo "ARK_OMEGA_SERVICE=FAIL PYTHON_RUNTIME_NOT_FOUND=$PYTHON_BIN"; exit 69; }
    command -v termux-wake-lock >/dev/null 2>&1 && termux-wake-lock || true
    tmux new-session -d -s "$SESSION" "cd '$REPO' && exec '$PYTHON_BIN' '$APP' >>'$LOGDIR/ark-omega.tui.log' 2>&1"
    echo "ARK_OMEGA_SERVICE=STARTED SESSION=$SESSION PYTHON=$PYTHON_BIN"
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
      echo "ARK_OMEGA_SERVICE=RUNNING SESSION=$SESSION PYTHON=$PYTHON_BIN"
    else
      echo "ARK_OMEGA_SERVICE=STOPPED"
      exit 3
    fi
    ;;
  attach)
    tmux attach-session -t "$SESSION"
    ;;
  *)
    echo "usage: ark-service {start|stop|restart|status|attach}" >&2
    exit 64
    ;;
esac
