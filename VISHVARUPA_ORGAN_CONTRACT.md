# ARK OS — VISHVARUPA Organ Contract

Status: SEEDED
Organism: VISHVARUPA
Organ class: Physical/mobile node operating layer

## Mission
ARK OS turns Ghost Atlas hardware nodes into governed members of the physical Hypernet by exposing device capabilities, local services, storage, model runtimes, communications, and health state through a consistent node contract.

## Authority
May inventory local capabilities, start approved resident services, execute bounded node tasks, maintain heartbeat/attestation, and expose approved device interfaces. May not escalate device privilege, execute undeclared destructive actions, or publish sensitive hardware state outside policy.

## Inputs
- Packet OS node tasks
- CrownGrid capability routes
- EDEN/VISHVARUPA node policy
- local hardware/runtime state

## Outputs
- node capability manifest
- health/heartbeat telemetry
- bounded task results
- local service endpoints
- node attestation receipts

## Handoffs
Upstream: VISHVARUPA, EDEN, CrownGrid, Packet-OS, Janus-Odin
Downstream: Cali-CRF, local model/tool runtimes, Runtime Observatory, SECA, ProofGrid

## Events
Consumes: node.enroll, node.execute.requested, policy.updated, service.start_requested
Emits: node.online, node.offline, node.attested, capability.advertised, node.task_completed, node.task_failed

## Proof requirements
All node actions are attributable to node id, packet id, capability id, policy version, timestamps, and evidence reference. Public telemetry must honor inventory redaction boundaries.

## Definition of integrated
A registered ARK node can advertise capabilities, receive a CrownGrid-routed packet, execute through the approved local runtime, emit telemetry, and return verified proof to VISHVARUPA.