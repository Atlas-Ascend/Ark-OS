# ARK-OMEGA-RUNTIME-CANARY-001

Purpose: execute the first governed ODIN -> JANUS -> HYPERNET -> EDEN/capability -> Packet OS -> Workforce Spine -> SECA -> DEVOS -> ProofGrid -> Thoth -> ODIN acknowledgement test.

## Truth boundary
This harness does not simulate remote success. A stage is PASS only when its concrete command returns success and the expected receipt artifact exists. Missing configuration yields UNBOUND; failed checks yield FAIL; either state prevents SEALED.

## Required local configuration
Copy `canary.env.example` to `canary.env` and set real peer endpoints/commands. `JANUS_HOST` may use a Tailscale MagicDNS hostname. EDEN can default to `100.83.241.3` if still current, but verify before use.

## Run
`bash ARK-OMEGA/runtime-canary/run-canary.sh`

Receipts are written under `$HOME/.ark-omega/receipts/`.
