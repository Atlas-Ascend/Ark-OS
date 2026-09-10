#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail
pkg update -y
pkg install -y openssh coreutils git
mkdir -p "$HOME/.ark-omega/receipts" "$HOME/.ark-omega/bin"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ln -sf "$SCRIPT_DIR/run-canary.sh" "$HOME/.ark-omega/bin/ark-canary"
if ! grep -q '.ark-omega/bin' "$HOME/.bashrc" 2>/dev/null; then printf '\nexport PATH="$HOME/.ark-omega/bin:$PATH"\n' >> "$HOME/.bashrc"; fi
echo 'ARK_OMEGA_CANARY_INSTALL=PASS'
echo 'NEXT: copy canary.env.example to canary.env and bind real peer users/commands'
