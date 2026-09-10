# JANUS Resident Edge v1 — Build Truth

## Status
ACTIVE-CANDIDATE

## Canonical repository
`Atlas-Ascend/Ark-OS`

## Change
JANUS is reclassified from a primarily mobile phone console into an always-on resident Hypernet edge controller. The existing ARK phone baseline is preserved. This is a non-destructive T2 Mobile profile extension.

## Active hardware baseline
- JANUS — resident edge controller
- ODIN — mobile operator peer
- EDEN — local runtime
- SHAMBALA — local node

## Paused / offline reserve
- T5810-A — compute reserve, OFFLINE
- T5810-B — compute reserve, OFFLINE

## Resident capabilities
- ODIN -> JANUS SSH control on Termux sshd port 8022
- persistent tmux resident session
- Hypernet bastion / relay
- Packet OS ingress and local spool
- dynamic node-state registry
- health snapshots
- file ingress/egress
- optional Termux:API telemetry
- future Wake-on-LAN dispatch for enrolled hardware

## Runtime directories
`~/hypernet/` contains inbox, packet lifecycle queues, events, receipts, logs, state, and outbound spool.

## Safety / governance
- no credentials or device-private state in Git
- no public unbounded shell exposure
- no routing to known-OFFLINE nodes
- repository state is not physical runtime proof
- no permanent wake lock by default
- heavy compute is not a JANUS responsibility

## Proof criteria
Promotion requires physical evidence from JANUS that:
1. bootstrap script passes;
2. ODIN can authenticate to JANUS using an authorized SSH key;
3. `sshd` is reachable on the private Hypernet;
4. `tmux attach -t janus` reaches the persistent resident session;
5. `~/hypernet/state/health.json` is emitted;
6. T5810-A/B remain OFFLINE until live discovery changes their state;
7. reboot restores resident services through the Termux:Boot entry.

## Promotion state
Repository implementation: SEEDED
Physical JANUS deployment: PENDING LIVE RECEIPT
Canonical promotion: PENDING PROOF
