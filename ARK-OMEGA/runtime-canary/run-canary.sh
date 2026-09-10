#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${ARK_CANARY_ENV:-$ROOT/canary.env}"
STATE_DIR="${ARK_STATE_DIR:-$HOME/.ark-omega}"
RECEIPT_DIR="$STATE_DIR/receipts"
mkdir -p "$RECEIPT_DIR"
if [[ ! -f "$ENV_FILE" ]]; then echo "ARK_OMEGA_CANARY=UNBOUND"; echo "MISSING_ENV=$ENV_FILE"; exit 20; fi
# shellcheck disable=SC1090
source "$ENV_FILE"
need(){ command -v "$1" >/dev/null 2>&1 || { echo "MISSING_TOOL=$1"; exit 21; }; }
for tool in ssh sha256sum date sed grep mktemp od tr awk; do need "$tool"; done
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
COMMAND_ID="cmd-$STAMP-$(od -An -N4 -tx1 /dev/urandom | tr -d ' \n')"
MISSION_ID="mission-$STAMP"
NONCE="$(od -An -N16 -tx1 /dev/urandom | tr -d ' \n')"
RECEIPT="$RECEIPT_DIR/$MISSION_ID.receipt"
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT
cat >"$TMP" <<EOF
{"schema":"ark.omega.command.v1","command_id":"$COMMAND_ID","mission_id":"$MISSION_ID","nonce":"$NONCE","origin":"${ARK_OPERATOR:-ODIN}","intent":"ARK-OMEGA-RUNTIME-CANARY-001","timestamp":"$STAMP"}
EOF
HASH="$(sha256sum "$TMP" | awk '{print $1}')"
exec_stage(){ local stage="$1" host="$2" user="$3" remote_cmd="$4"; if [[ -z "$host" || -z "$user" || -z "$remote_cmd" ]]; then printf '%s=UNBOUND\n' "$stage" | tee -a "$RECEIPT"; return 30; fi; printf '%s=RUNNING\n' "$stage" | tee -a "$RECEIPT"; if ssh ${SSH_OPTS:-'-o BatchMode=yes -o ConnectTimeout=6'} "$user@$host" "$remote_cmd" <"$TMP" >>"$RECEIPT" 2>&1; then printf '%s=PASS\n' "$stage" | tee -a "$RECEIPT"; else printf '%s=FAIL\n' "$stage" | tee -a "$RECEIPT"; return 31; fi; }
{
 echo "ARK_OMEGA_RUNTIME_CANARY=START"; echo "COMMAND_ID=$COMMAND_ID"; echo "MISSION_ID=$MISSION_ID"; echo "ENVELOPE_SHA256=$HASH"; echo "STAMP=$STAMP";
} | tee "$RECEIPT"
exec_stage JANUS_AUTH "$JANUS_HOST" "$JANUS_USER" "$JANUS_AUTH_COMMAND"
exec_stage HYPERNET_ROUTE "$JANUS_HOST" "$JANUS_USER" "$HYPERNET_ROUTE_COMMAND"
exec_stage EDEN_EXEC "$EDEN_HOST" "$EDEN_USER" "$EDEN_EXEC_COMMAND"
exec_stage PACKET_OS "$JANUS_HOST" "$JANUS_USER" "$PACKET_OS_COMMAND"
exec_stage WORKFORCE_SPINE "$JANUS_HOST" "$JANUS_USER" "$WORKFORCE_COMMAND"
exec_stage SECA "$JANUS_HOST" "$JANUS_USER" "$SECA_COMMAND"
exec_stage DEVOS "$JANUS_HOST" "$JANUS_USER" "$DEVOS_COMMAND"
exec_stage PROOFGRID "$JANUS_HOST" "$JANUS_USER" "$PROOFGRID_COMMAND"
exec_stage THOTH "$JANUS_HOST" "$JANUS_USER" "$THOTH_COMMAND"
echo "ODIN_ACK=PASS" | tee -a "$RECEIPT"
echo "SEALED=PASS" | tee -a "$RECEIPT"
echo "RECEIPT=$RECEIPT"
