#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
pkg install -y openssh coreutils git python gh
install -m 700 "$HERE/janusctl" "$PREFIX/bin/janusctl"

echo "JANUSCTL_INSTALL=PASS"
echo "COMMAND=janusctl"
echo "FORENSICS_COMMAND=janusctl estate-forensics"
echo "REQUIRES=GitHub auth via gh auth login or GA_ESTATE_GITHUB_TOKEN/GITHUB_TOKEN/GH_TOKEN"
echo "JANUS_SSH_REQUIRES=~/.ssh/config Host janus plus ODIN public key authorized on JANUS"
