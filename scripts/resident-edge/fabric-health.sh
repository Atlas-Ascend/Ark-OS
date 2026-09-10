#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="${HOME}/hypernet"
OUT="$ROOT/state/fabric-health.json"
TMP="$ROOT/state/.fabric-health.ndjson"
SCOPE="${1:---core}"
mkdir -p "$ROOT/state"
: > "$TMP"

probe() {
  local name="$1"
  local role="$2"
  local url="$3"
  local code="000"
  local state="UNKNOWN"

  if [ -n "$url" ]; then
    code="$(curl -L -sS -o /dev/null --connect-timeout 4 --max-time 8 -w '%{http_code}' "$url" 2>/dev/null || printf '000')"
    case "$code" in
      2??|3??) state="UP" ;;
      000) state="DOWN" ;;
      *) state="DEGRADED" ;;
    esac
  fi

  jq -n \
    --arg name "$name" \
    --arg role "$role" \
    --arg url "$url" \
    --arg state "$state" \
    --arg http_code "$code" \
    '{name:$name,role:$role,url:$url,state:$state,http_code:$http_code}' >> "$TMP"
}

# Core command-to-proof surfaces. Each can be overridden without editing Git.
probe "janus-prime-runtime-authorization" "authorization" "${JANUS_PRIME_URL:-https://janus-prime-runtime-authorization.onrender.com}"
probe "vishvarupa-organism" "organism-control" "${VISHVARUPA_URL:-https://vishvarupa-organism.onrender.com}"
probe "ghost-atlas-machine-wake" "resident-control-plane" "${MACHINE_WAKE_URL:-https://ghost-atlas-machine-wake.onrender.com}"
probe "ghost-atlas-runtime-gateway" "execution-gateway" "${RUNTIME_GATEWAY_URL:-https://ghost-atlas-runtime-gateway.onrender.com}"
probe "maat-universal-casegraph" "casegraph" "${MAAT_URL:-https://maat-universal-casegraph.onrender.com}"

if [ "$SCOPE" = "--full" ]; then
  probe "vishvarupa-cybernetic-brain-gate" "cybernetic-brain-gate" "${VISHVARUPA_BRAIN_URL:-https://vishvarupa-cybernetic-brain-gate.onrender.com}"
  probe "ghost-atlas-machine-wake-oidc-ingress" "authenticated-resident-ingress" "${MACHINE_WAKE_OIDC_URL:-https://ghost-atlas-machine-wake-oidc-ingress.onrender.com}"
  probe "ghost-atlas-runtime-worker-core" "worker-core" "${WORKER_CORE_URL:-https://ghost-atlas-runtime-worker-core.onrender.com}"
  probe "ghost-atlas-runtime-worker-custodian" "worker-custodian" "${WORKER_CUSTODIAN_URL:-https://ghost-atlas-runtime-worker-custodian.onrender.com}"
  probe "ghost-atlas-runtime-worker-factory" "worker-factory" "${WORKER_FACTORY_URL:-https://ghost-atlas-runtime-worker-factory.onrender.com}"
  probe "ghost-atlas-runtime-worker-qualification" "worker-qualification" "${WORKER_QUALIFICATION_URL:-https://ghost-atlas-runtime-worker-qualification.onrender.com}"
  probe "argus-fieldvision-api" "field-observation" "${ARGUS_API_URL:-https://argus-fieldvision-api.onrender.com}"
  probe "argus-fieldvision-web" "field-observation-surface" "${ARGUS_WEB_URL:-https://argus-fieldvision-web.onrender.com}"
  probe "hermes-public-access-relay" "public-relay" "${HERMES_URL:-https://hermes-public-access-relay.onrender.com}"
  probe "athena-ai-infrastructure-command-plane" "infrastructure-command-plane" "${ATHENA_URL:-https://athena-ai-infrastructure-command-plane.onrender.com}"
  probe "heimdall-machine-governor" "machine-governor" "${HEIMDALL_URL:-https://heimdall-machine-governor.onrender.com}"
  probe "hestia-hearth-agentic-control-plane" "hearth-control-plane" "${HESTIA_URL:-https://hestia-hearth-agentic-control-plane.onrender.com}"
  probe "artemis-local-sovereign-ai" "local-sovereign-ai" "${ARTEMIS_URL:-https://artemis-local-sovereign-ai.onrender.com}"
  probe "vulcan-agentic-engineering-foundry" "engineering-foundry" "${VULCAN_URL:-https://vulcan-agentic-engineering-foundry.onrender.com}"

  # Vercel aliases and any authenticated data-plane health endpoints are supplied
  # through environment variables so no credentials or unstable deployment URLs enter Git.
  probe "atlas-mind-live-surface" "atlas-mind-ui" "${ATLAS_MIND_VERCEL_URL:-}"
  probe "ghost-atlas-machine-wake-observatory" "machine-wake-observability" "${MACHINE_WAKE_OBSERVATORY_URL:-}"
  probe "ghost-atlas-cloud-continuity" "cloud-continuity" "${CLOUD_CONTINUITY_URL:-}"
  probe "ghost-atlas-estate-registry" "durable-data-plane" "${ESTATE_REGISTRY_HEALTH_URL:-}"
fi

now="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
jq -s --arg timestamp "$now" --arg scope "$SCOPE" \
  '{node:"JANUS",timestamp_utc:$timestamp,scope:$scope,services:.}' "$TMP" > "$OUT"
rm -f "$TMP"

cat "$OUT"
