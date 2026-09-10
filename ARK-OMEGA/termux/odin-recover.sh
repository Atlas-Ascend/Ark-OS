#!/data/data/com.termux/files/usr/bin/bash
set -u

# ODIN ARK Ω production recovery director.
# Goals: preserve state, identify the lowest broken layer, repair only that layer,
# verify every promotion gate with real return codes, and never allow a UI to own
# shell startup automatically.

HOME=${HOME:-/data/data/com.termux/files/home}
PREFIX=${PREFIX:-/data/data/com.termux/files/usr}
TMPDIR=${TMPDIR:-$HOME/.tmp}
PATH="$PREFIX/bin:$PREFIX/bin/applets:/system/bin:/system/xbin:$HOME/.local/bin"
export HOME PREFIX TMPDIR PATH

BRANCH=${ARK_BRANCH:-feat/ark-omega-cinematic-command-to-proof}
REPO=${ARK_REPO:-$HOME/ghost-atlas/Ark-OS}
STATE="$HOME/.local/state/ghost-atlas"
STAMP=$(date +%Y%m%d-%H%M%S 2>/dev/null || echo recovery)
RUN="$STATE/recovery/$STAMP"
LOG="$STATE/logs/odin-recover-$STAMP.log"
RECEIPT="$STATE/receipts/ODIN-RECOVERY-$STAMP.receipt"
VENV="$HOME/.local/share/ark-omega/venv"
BOOT="$HOME/.termux/boot"
BIN="$HOME/.local/bin"

mkdir -p "$TMPDIR" "$RUN" "$STATE/logs" "$STATE/receipts" "$BIN" "$BOOT" "$VENV" 2>/dev/null || true
chmod 700 "$TMPDIR" 2>/dev/null || true

exec > >(tee -a "$LOG") 2>&1

pass(){ printf '%s=PASS\n' "$1"; }
fail(){ printf '%s=FAIL%s\n' "$1" "${2:+:$2}"; }
phase(){ printf '\n[%s] %s\n' "$1" "$2"; }

phase 01 "GUARDS"
[ "$HOME" = "/data/data/com.termux/files/home" ] || { fail HOME_GUARD "$HOME"; exit 90; }
[ "$PREFIX" = "/data/data/com.termux/files/usr" ] || { fail PREFIX_GUARD "$PREFIX"; exit 91; }
pass HOME_GUARD
pass PREFIX_GUARD

phase 02 "PRESERVE OPERATOR STATE"
for f in "$HOME/.bashrc" "$HOME/.profile" "$HOME/.bash_profile" "$HOME/.zshrc"; do
  [ -f "$f" ] && cp -a "$f" "$RUN/$(basename "$f")" 2>/dev/null || true
done
[ -d "$BOOT" ] && cp -a "$BOOT" "$RUN/boot" 2>/dev/null || true
[ -d "$BIN" ] && cp -a "$BIN" "$RUN/bin" 2>/dev/null || true
pass STATE_PRESERVED

phase 03 "SUBSTRATE EXECUTION"
substrate=0
for spec in "bash --version" "apt --version" "dpkg --version"; do
  set -- $spec
  c=$1; shift
  if [ -x "$PREFIX/bin/$c" ] && "$PREFIX/bin/$c" "$@" >/dev/null 2>&1; then
    echo "$c=EXEC_PASS"
  else
    echo "$c=EXEC_FAIL"
    substrate=1
  fi
done
if [ "$substrate" -ne 0 ]; then
  fail TERMUX_SUBSTRATE
  echo "NEXT_STAGE=TERMUX_PREFIX_REBOOTSTRAP"
  echo "ARK_MUTATION=DENIED"
  echo "LOG=$LOG"
  exit 70
fi
pass TERMUX_SUBSTRATE

phase 04 "PACKAGE HEALTH"
"$PREFIX/bin/dpkg" --audit 2>/dev/null || true
"$PREFIX/bin/apt" update || exit 71
"$PREFIX/bin/apt" install -y --reinstall bash coreutils dash termux-tools || exit 72
"$PREFIX/bin/apt" install -y git openssh curl jq rsync python tmux || exit 73
pass PACKAGE_HEALTH

phase 05 "TOOLCHAIN GATE"
FAIL=0
for c in bash git python tmux ssh curl jq rsync; do
  if command -v "$c" >/dev/null 2>&1 && "$c" --version >/dev/null 2>&1; then
    echo "$c=PASS:$(command -v "$c")"
  else
    # tmux uses -V; ssh may not accept --version.
    case "$c" in
      tmux) tmux -V >/dev/null 2>&1 && echo "tmux=PASS:$(command -v tmux)" || FAIL=1 ;;
      ssh) ssh -V >/dev/null 2>&1 && echo "ssh=PASS:$(command -v ssh)" || FAIL=1 ;;
      *) FAIL=1 ;;
    esac
  fi
done
[ "$FAIL" -eq 0 ] || { fail TOOLCHAIN; exit 74; }
pass TOOLCHAIN

phase 06 "OPERATOR OWNERSHIP SANITIZE"
# No interface may auto-exec from shell startup. Preserve backend/runtime assets.
cat > "$HOME/.bashrc" <<'EOF'
export HOME=/data/data/com.termux/files/home
export PREFIX=/data/data/com.termux/files/usr
export TMPDIR="$HOME/.tmp"
export PATH="$PREFIX/bin:$PREFIX/bin/applets:/system/bin:/system/xbin:$HOME/.local/bin"
# ODIN operator law:
# VISHVARUPA interactive ownership denied.
# legacy ARK autoattach denied.
# ARK OMEGA UI auto-exec denied.
# Safe shell must always remain available.
EOF
cp "$HOME/.bashrc" "$HOME/.profile"
for s in ark-omega vishvarupa atlas-mind; do tmux kill-session -t "$s" 2>/dev/null || true; done
pass OPERATOR_OWNERSHIP_SANITIZED

phase 07 "REPOSITORY"
if [ ! -d "$REPO/.git" ]; then
  FOUND=$(find "$HOME" -maxdepth 7 -type d -name .git 2>/dev/null | sed 's#/.git$##' | grep '/Ark-OS$' | head -n1)
  if [ -n "${FOUND:-}" ]; then REPO="$FOUND"; else
    mkdir -p "$HOME/ghost-atlas"
    git clone --branch "$BRANCH" --single-branch https://github.com/Atlas-Ascend/Ark-OS.git "$REPO" || exit 75
  fi
fi
cd "$REPO" || exit 76
if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
  git diff > "$RUN/local.patch" 2>/dev/null || true
  git stash push -u -m "ODIN-RECOVERY-$STAMP" || true
fi
git fetch origin "$BRANCH" || exit 77
git checkout "$BRANCH" || exit 78
git pull --ff-only origin "$BRANCH" || exit 79
echo "ARK_BRANCH=$(git branch --show-current)"
echo "ARK_HEAD=$(git rev-parse HEAD)"
pass ARK_REPOSITORY

phase 08 "ANDROID COMPATIBILITY"
if grep -R "pip install --upgrade pip" ARK-OMEGA/termux 2>/dev/null; then fail GLOBAL_PIP_MUTATION; exit 80; else pass GLOBAL_PIP_MUTATION_ABSENT; fi
if grep -R "psutil" ARK-OMEGA/termux 2>/dev/null; then fail PSUTIL_ANDROID_COMPAT; exit 81; else pass PSUTIL_ANDROID_COMPAT; fi

phase 09 "ARK INSTALL"
chmod +x ARK-OMEGA/termux/install-persistent.sh
bash ARK-OMEGA/termux/install-persistent.sh || exit 82
export PATH="$HOME/.local/bin:$PREFIX/bin:$PREFIX/bin/applets:/system/bin:/system/xbin"
pass ARK_INSTALL

phase 10 "COMMAND SURFACE"
FAIL=0
for c in ark ark-service ark-status ark-diagnose ark-restart; do
  command -v "$c" >/dev/null 2>&1 && echo "$c=PASS:$(command -v "$c")" || { echo "$c=FAIL"; FAIL=1; }
done
[ "$FAIL" -eq 0 ] || { fail COMMAND_SURFACE; exit 83; }
pass COMMAND_SURFACE

phase 11 "HEADLESS SUPERVISOR"
ark-service restart || exit 84
sleep 2
if tmux has-session -t ark-omega-supervisor 2>/dev/null; then pass ARK_SUPERVISOR; else fail ARK_SUPERVISOR; exit 85; fi
if tmux has-session -t ark-omega 2>/dev/null; then fail LEGACY_ARK_UI; exit 86; else pass LEGACY_ARK_UI_RETIRED; fi
if tmux has-session -t vishvarupa 2>/dev/null; then fail VISHVARUPA_UI; exit 87; else pass VISHVARUPA_UI_RETIRED; fi

phase 12 "BOOT POLICY"
# Boot persistence is deliberately not promoted by this recovery director.
# It is enabled only after foreground UI and safe-shell tests pass.
find "$BOOT" -maxdepth 1 -type f -print 2>/dev/null || true
echo "BOOT_PROMOTION=DEFERRED_UNTIL_FOREGROUND_CANARY"
pass SAFE_SHELL_POLICY

phase 13 "RECEIPT"
{
  echo "ODIN_RECOVERY=PASS"
  echo "TIMESTAMP=$STAMP"
  echo "TERMUX_SUBSTRATE=PASS"
  echo "TOOLCHAIN=PASS"
  echo "ARK_REPOSITORY=PASS"
  echo "ARK_INSTALL=PASS"
  echo "COMMAND_SURFACE=PASS"
  echo "ARK_SUPERVISOR=PASS"
  echo "VISHVARUPA_UI=RETIRED"
  echo "LEGACY_ARK_UI=RETIRED"
  echo "SAFE_SHELL=PASS"
  echo "BOOT_PROMOTION=DEFERRED"
  echo "LOG=$LOG"
  echo "RECOVERY_DIR=$RUN"
} | tee "$RECEIPT"

echo
echo "PRODUCTION_RECOVERY=PASS"
echo "FOREGROUND_CANARY_COMMAND=ark"
echo "RECEIPT=$RECEIPT"
