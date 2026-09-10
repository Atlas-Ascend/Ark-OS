#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
ROOT="$HOME/ghost-atlas/Ghost-Atlas-Estate-Service-Mesh-Runtime-Connectivity-Fabric"
if [ ! -d "$ROOT/.git" ]; then
  mkdir -p "$(dirname "$ROOT")"
  git clone https://github.com/Atlas-Ascend/Ghost-Atlas-Estate-Service-Mesh-Runtime-Connectivity-Fabric.git "$ROOT"
else
  git -C "$ROOT" pull --ff-only origin main
fi
bash "$ROOT/global-resolution/cognitive-office-mesh/termux/install.sh" "$ROOT"
echo 'ARK_HYPERNET_COGNITIVE_OFFICE_MESH=READY'
