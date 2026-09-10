#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

BRANCH="${ARK_BRANCH:-feat/ark-omega-cinematic-command-to-proof}"
ROOT="${HOME}/ghost-atlas"
REPO="${ROOT}/Ark-OS"

echo '=== GHOST ATLAS // ODIN ARK OMEGA ACCESSION ==='
pkg update -y
pkg install -y git gh openssh curl jq rsync python nodejs-lts tmux termux-api
mkdir -p "$ROOT" "$HOME/.config/ghost-atlas" "$HOME/.local/bin" "$HOME/.local/state/ghost-atlas/outbox"

if [ ! -d "$REPO/.git" ]; then
  git clone --branch "$BRANCH" --single-branch https://github.com/Atlas-Ascend/Ark-OS.git "$REPO"
else
  git -C "$REPO" fetch origin "$BRANCH"
  git -C "$REPO" checkout "$BRANCH"
  git -C "$REPO" pull --ff-only origin "$BRANCH"
fi

cat > "$HOME/.config/ghost-atlas/odin.env" <<'EOF'
GA_VESSEL=ODIN
GA_PEER_MODE=AUTO
GA_PRIMARY_PEER=HYPERNET
GA_OUTBOX=$HOME/.local/state/ghost-atlas/outbox
EOF

cat > "$HOME/.local/bin/atlas" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
CONF="$HOME/.config/ghost-atlas/odin.env"
[ -f "$CONF" ] && . "$CONF"
cmd="${1:-status}"; shift || true
case "$cmd" in
  status) echo "VESSEL=${GA_VESSEL:-ODIN} PEER_MODE=${GA_PEER_MODE:-AUTO} PRIMARY=${GA_PRIMARY_PEER:-HYPERNET}" ;;
  peer)
    p="${1:-auto}"; p="$(printf '%s' "$p" | tr '[:lower:]' '[:upper:]')"
    case "$p" in AUTO|JANUS|EDEN|HYPERNET) sed -i "s/^GA_PEER_MODE=.*/GA_PEER_MODE=$p/;s/^GA_PRIMARY_PEER=.*/GA_PRIMARY_PEER=$p/" "$CONF";; *) echo "Custom peer selected: $p"; sed -i "s/^GA_PRIMARY_PEER=.*/GA_PRIMARY_PEER=$p/" "$CONF";; esac
    echo "PEER=$p" ;;
  doctor)
    command -v git >/dev/null && echo GIT=PASS
    command -v ssh >/dev/null && echo SSH=PASS
    command -v jq >/dev/null && echo JQ=PASS
    command -v gh >/dev/null && echo GH=PASS
    [ -d "$HOME/ghost-atlas/Ark-OS/.git" ] && echo ARK_REPO=PASS
    ;;
  *) echo "ARK OMEGA scaffold: command '$cmd' requires the estate adapter package before mutation is enabled."; exit 64;;
esac
EOF
chmod +x "$HOME/.local/bin/atlas"
grep -q 'HOME/.local/bin' "$HOME/.bashrc" 2>/dev/null || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"

echo 'ACCESSION_STAGE=SCAFFOLD_INSTALLED'
echo 'Run: source ~/.bashrc && atlas doctor && atlas status'
echo 'Mutating estate commands remain disabled until authenticated HYPERNET adapters and policy gates are installed.'
