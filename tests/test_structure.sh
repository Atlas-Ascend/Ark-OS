#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
grep -q 'class: overlay' "$ROOT/profiles/t2-mobile/cyber-throne/profile.yaml"
grep -q 'baseline_immutable' "$ROOT/profiles/t2-mobile/cyber-throne/profile.yaml"
grep -q 'preservation: immutable-after-promotion' "$ROOT/ARK_BASELINE.lock"
grep -q 'baseline_mutated=false' "$ROOT/migrations/phone-current-to-cyber-throne-v1/install-overlay.sh"
echo "STRUCTURE_TEST=PASS"
