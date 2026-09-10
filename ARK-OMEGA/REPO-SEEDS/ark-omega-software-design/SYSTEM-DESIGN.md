# ARK OMEGA Software System Design

## Architectural style
Hexagonal/ports-and-adapters around a typed event core. UI, CLI, ODIN/Termux, JANUS, EDEN, HYPERNET, Thoth, Packet OS, Workforce Spine, SECA/DevOS and ProofGrid integrate through explicit ports. No UI component talks directly to arbitrary hosts.

## Runtime boundaries
Operator Surface -> Command API -> Policy/Identity -> Mission Coordinator -> Adapter Ports -> Estate organs. Reads may aggregate; mutations require authorization, idempotency key, mission correlation and receipt expectation.

## Cinematic renderer
Projection-only subsystem. Consumes ordered MissionEvent streams and resource metrics. It cannot advance mission state. This prevents UI theater from becoming control authority.

## Failure model
Typed failures: AUTHN, AUTHZ, ROUTE, CAPABILITY, TRANSPORT, INTEGRITY, TIMEOUT, EXECUTION, VERIFY, DEPLOY, PROOF. Every failure has retryability classification and operator-visible remediation path.
