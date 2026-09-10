#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
pkg install -y openssh coreutils
install -m 700 "$HERE/janusctl" "$PREFIX/bin/janusctl"

echo "JANUSCTL_INSTALL=PASS"
echo "COMMAND=janusctl"
echo "REQUIRES=~/.ssh/config Host janus plus ODIN public key authorized on JANUS"
