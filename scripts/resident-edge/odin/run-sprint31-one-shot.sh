#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ARK_ROOT="${ODIN_ARK_ROOT:-$HOME/ghost-atlas/Ark-OS}"
ROOT="$HOME/hypernet"
RECEIPTS="$ROOT/receipts"
STAMP="$(date -u +'%Y%m%dT%H%M%SZ')"
MASTER="$RECEIPTS/ODIN-SPRINT31-MASTER-$STAMP.json"
RUN_FORENSICS="${GA_SPRINT31_RUN_FORENSICS:-1}"

mkdir -p "$RECEIPTS" "$ROOT/workspaces"
command -v pkg >/dev/null 2>&1 || { echo 'ODIN_SPRINT31=FAIL reason=termux_required' >&2; exit 20; }

pkg install -y git gh python openssh coreutils jq >/dev/null
if ! command -v node >/dev/null 2>&1 || [ "$(node -p 'Number(process.versions.node.split(".")[0])' 2>/dev/null || echo 0)" -lt 22 ]; then
  pkg install -y nodejs-lts >/dev/null 2>&1 || pkg install -y nodejs >/dev/null
fi
command -v node >/dev/null 2>&1 || { echo 'ODIN_SPRINT31=FAIL reason=node_missing' >&2; exit 21; }
[ "$(node -p 'Number(process.versions.node.split(".")[0])')" -ge 22 ] || { echo 'ODIN_SPRINT31=FAIL reason=node_22_required' >&2; exit 22; }

if ! gh auth status >/dev/null 2>&1; then
  echo 'ODIN_SPRINT31=BLOCKED reason=github_auth_required'
  gh auth login
fi
gh auth status >/dev/null 2>&1 || { echo 'ODIN_SPRINT31=FAIL reason=github_auth_unavailable' >&2; exit 23; }
gh auth setup-git >/dev/null 2>&1 || true

identity_output="$(bash "$ARK_ROOT/scripts/resident-edge/odin/emit-odin-identity-receipt.sh")"
printf '%s\n' "$identity_output"
identity="$(printf '%s\n' "$identity_output" | sed -n 's/^ODIN_IDENTITY=PASS receipt=\([^ ]*\).*/\1/p' | tail -n 1)"
[ -n "$identity" ] && [ -f "$identity" ] || { echo 'ODIN_SPRINT31=FAIL reason=identity_receipt_missing' >&2; exit 24; }
export GA_EXECUTOR_PROOF="$identity"
export GA_EXECUTOR_NODE="ODIN"

forensics=""
if [ "$RUN_FORENSICS" = "1" ]; then
  forensics_output="$(bash "$ARK_ROOT/scripts/resident-edge/estate-forensics.sh")"
  printf '%s\n' "$forensics_output"
  forensics="$(printf '%s\n' "$forensics_output" | sed -n 's/^ESTATE_FORENSICS_GATE=PASS .*receipt=\([^ ]*\).*/\1/p' | tail -n 1)"
  [ -n "$forensics" ] && [ -f "$forensics" ] || { echo 'ODIN_SPRINT31=FAIL reason=forensics_receipt_missing' >&2; exit 25; }
fi

workforce_output="$(bash "$ARK_ROOT/scripts/resident-edge/odin/run-workforce-proof.sh")"
printf '%s\n' "$workforce_output"
workforce="$(printf '%s\n' "$workforce_output" | sed -n 's/^ODIN_WORKFORCE_PROOF=PASS receipt=\([^ ]*\).*/\1/p' | tail -n 1)"
[ -n "$workforce" ] && [ -f "$workforce" ] || { echo 'ODIN_SPRINT31=FAIL reason=workforce_receipt_missing' >&2; exit 26; }

gari_output="$(bash "$ARK_ROOT/scripts/resident-edge/odin/run-gari-proof.sh")"
printf '%s\n' "$gari_output"
gari_proof="$(printf '%s\n' "$gari_output" | sed -n 's/^ODIN_GARI_PROOF=PASS proof=\([^ ]*\).*/\1/p' | tail -n 1)"
gari_bundle="$(printf '%s\n' "$gari_output" | sed -n 's/^ODIN_GARI_PROOF=PASS .*bundle=\([^ ]*\).*/\1/p' | tail -n 1)"
[ -n "$gari_proof" ] && [ -f "$gari_proof" ] || { echo 'ODIN_SPRINT31=FAIL reason=gari_proof_missing' >&2; exit 27; }
[ -n "$gari_bundle" ] && [ -f "$gari_bundle" ] || { echo 'ODIN_SPRINT31=FAIL reason=gari_bundle_missing' >&2; exit 28; }

prom_output="$(bash "$ARK_ROOT/scripts/resident-edge/odin/run-prometheus-synthesis.sh" "$gari_bundle" "$workforce")"
printf '%s\n' "$prom_output"
prometheus="$(printf '%s\n' "$prom_output" | sed -n 's/^ODIN_PROMETHEUS_SYNTHESIS=PASS receipt=\(.*\)$/\1/p' | tail -n 1)"
[ -n "$prometheus" ] && [ -f "$prometheus" ] || { echo 'ODIN_SPRINT31=FAIL reason=prometheus_receipt_missing' >&2; exit 29; }

export GA_S31_MASTER="$MASTER"
export GA_S31_IDENTITY="$identity"
export GA_S31_FORENSICS="$forensics"
export GA_S31_WORKFORCE="$workforce"
export GA_S31_GARI="$gari_proof"
export GA_S31_BUNDLE="$gari_bundle"
export GA_S31_PROMETHEUS="$prometheus"
python - <<'PY'
import hashlib, json, os
from datetime import datetime, timezone
from pathlib import Path

def digest(p):
    if not p: return None
    path=Path(p)
    h=hashlib.sha256()
    with path.open('rb') as f:
        for chunk in iter(lambda:f.read(1024*1024), b''): h.update(chunk)
    return h.hexdigest()

def record(name, p):
    if not p: return {"name":name,"status":"SKIPPED","path":None,"sha256":None}
    return {"name":name,"status":"PASS","path":p,"sha256":digest(p)}

prom=json.load(open(os.environ['GA_S31_PROMETHEUS'], encoding='utf-8'))
wf=json.load(open(os.environ['GA_S31_WORKFORCE'], encoding='utf-8'))
gari=json.load(open(os.environ['GA_S31_GARI'], encoding='utf-8'))
identity=json.load(open(os.environ['GA_S31_IDENTITY'], encoding='utf-8'))
assert identity.get('verification',{}).get('physical_device_execution') is True
assert wf.get('gate') == 'PASS'
assert wf.get('execution_class') == 'resident-observed'
assert gari.get('state') == 'PROVEN'
assert gari.get('execution_class') == 'resident-observed'
assert prom.get('promotableEvidence') is True
assert prom.get('authority',{}).get('promotionAuthority') is False

payload={
  "schema":"ghost-atlas.sprint31-odin-master-receipt/v1",
  "generated_at":datetime.now(timezone.utc).isoformat(),
  "sprint":31,
  "node":"ODIN",
  "state":"RESIDENT_EVIDENCE_CHAIN_PROVEN",
  "github_actions_required":False,
  "identity_anchor_sha256":identity.get('identity_anchor_sha256'),
  "stages":[
    record('ODIN_IDENTITY', os.environ['GA_S31_IDENTITY']),
    record('ESTATE_FORENSICS', os.environ.get('GA_S31_FORENSICS','')),
    record('WORKFORCE_SPINE', os.environ['GA_S31_WORKFORCE']),
    record('GARI_JARVIS', os.environ['GA_S31_GARI']),
    record('GARI_SPRINT31_BUNDLE', os.environ['GA_S31_BUNDLE']),
    record('PROMETHEUS_SYNTHESIS', os.environ['GA_S31_PROMETHEUS']),
  ],
  "workforce_queue_truth":{
    "ready_packets":wf.get('ready_packets',[]),
    "blocked_packets":wf.get('blocked_packets',{}),
  },
  "prometheus":{
    "conclusion":prom.get('conclusion'),
    "confidence":prom.get('confidence'),
    "contradictions":prom.get('contradictions',[]),
    "promotion_authority":False,
  },
  "remaining_gate":"WF-MW-020 physical EDEN estate census remains blocked unless its distinct required physical-host outputs are separately proven.",
  "promotion_rule":"This master receipt proves the Sprint 31 ODIN resident evidence chain only. It does not substitute for SECA, Medusa, ProofGrid, Thoth, or the blocked physical EDEN census packet."
}
Path(os.environ['GA_S31_MASTER']).write_text(json.dumps(payload, indent=2, sort_keys=True)+'\n', encoding='utf-8')
print('ODIN_SPRINT31_MASTER=PASS')
PY
sha256sum "$MASTER" > "$MASTER.sha256"

echo "ODIN_SPRINT31=PASS receipt=$MASTER"
