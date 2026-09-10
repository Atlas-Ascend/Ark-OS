# JANUS Ghost Atlas Fabric v1 — Build Truth

**Change ID:** JANUS-GHOST-ATLAS-FABRIC-001  
**Repository:** `Atlas-Ascend/Ark-OS`  
**Branch:** `janus-resident-edge-v1`  
**Device:** JANUS  
**Role:** always-on resident Hypernet edge controller  
**State:** repository-wired / physical-runtime-unverified

## Decision

JANUS is not a new standalone platform and does not replace any Ghost Atlas organ. It is a T2 Mobile ARK resident-edge profile that provides a persistent physical adapter between ODIN, the local Hypernet, and the existing cloud/control fabric.

The dedicated GAIA H0 ARK seed remains a GAIA bootstrap lineage. JANUS resident operation belongs in `Ark-OS` because ARK owns the field hardware node contract, device capability declaration, and mobile runtime interface.

## Canonical command-to-proof route

```text
ODIN
  -> JANUS resident edge
  -> JANUS PRIME authorization
  -> Atlas Mind cognition/policy
  -> Packet OS atomic work
  -> CrownGrid capability routing
  -> Workforce Spine dispatch
  -> target local/cloud organ
  -> SECA + DevOS verification
  -> Medusa security boundary
  -> ProofGrid evidence
  -> Thoth durable memory/archive
  -> ODIN/JANUS observability
```

PROMETHEUS is the bounded failure/repair path. VISHVARUPA is the organism-level integration root.

## Canonical repositories verified during this pass

- `Atlas-Ascend/Janus-Prime`
- `Atlas-Ascend/Atlas-Mind-LLM`
- `Atlas-Ascend/Packet-OS`
- `Atlas-Ascend/Crowngrid`
- `Atlas-Ascend/workforce-spine`
- `Atlas-Ascend/thoth-archive-engine`
- `Atlas-Ascend/SECA`
- `Atlas-Ascend/DEVOS`
- `Atlas-Ascend/Medusa-Sovereign-Security`
- `Atlas-Ascend/PROMETHEUS-V-1.1.1`
- `Atlas-Ascend/VISHVARUPA-Software-Hardware-Organism`

A dedicated repository named ProofGrid was not resolved in the installed repository search. ProofGrid remains a canonical protocol/organ and is represented in multiple estate repositories and durable proof tables. This file does not invent a replacement ProofGrid repository.

## Live cloud fabric observed during this pass

### Render

The connected Render workspace exposes active Ghost Atlas services including:

- Janus Prime runtime authorization
- Vishvarupa organism and cybernetic brain gate
- Ghost Atlas Machine Wake and OIDC ingress
- Ghost Atlas runtime gateway and resident worker lanes
- MAAT Universal CaseGraph
- ARGUS FieldVision
- HERMES Public Access Relay
- ATHENA AI Infrastructure Command Plane
- HEIMDALL Machine Governor
- HESTIA Hearth Agentic Control Plane
- ARTEMIS Local Sovereign AI
- VULCAN Agentic Engineering Foundry

The current Janus Prime runtime authorization deployment was observed in `live` state during this build-truth pass.

### Vercel

The connected Ghost Atlas Vercel team exposes projects including:

- `atlas-mind-live-surface`
- `ghost-atlas-machine-wake-observatory`
- `ghost-atlas-live-build-showcase`
- `ghost-atlas-enterprise-bootstrap`
- `ghost-atlas-cloud-continuity`

The current Atlas Mind live surface was observed `READY` in production during this pass.

### Neon

The connected `ghost-atlas-estate-registry` project already contains the durable structures JANUS needs rather than requiring a new database. Relevant tables include:

- `estate_registry.runtime_presence`
- `corporate_os.capabilities`
- `corporate_os.services`
- `corporate_os.runtime_bindings`
- `corporate_os.health_snapshots`
- `corporate_os.packets`
- `corporate_os.events`
- `corporate_os.proofs`
- `corporate_os.workers`
- `corporate_os.workforce_dispatches`

`estate_registry.runtime_presence` supports service/environment identity, version, base URL, health, lifecycle status, priority, JSON capabilities/metadata, registration time and last heartbeat. This is the canonical future registration target for JANUS physical presence.

**Important:** no `active` JANUS runtime-presence row is written by this repository change. Physical execution must be proven first.

## New resident capabilities in this branch

1. Termux resident bootstrap and state directories.
2. SSH daemon on Termux port 8022.
3. Persistent `tmux` session named `janus`.
4. Dynamic node registry with T5810-A/B explicitly retained as offline compute reserve.
5. Local JANUS health snapshot.
6. Core and extended Ghost Atlas cloud-fabric probes.
7. ODIN `janusctl` operator client.
8. File ingress into `~/hypernet/inbox`.
9. Packet queue visibility.
10. Android notification path when Termux:API is installed.
11. Local cryptographic proof receipt generation.
12. Termux:Boot entry for restart recovery.
13. Explicit binding manifest for Ghost Atlas organs and cloud surfaces.

## Runtime files

```text
~/hypernet/
├── bin/
├── inbox/
├── packets/
│   ├── pending/
│   ├── claimed/
│   ├── running/
│   ├── complete/
│   └── failed/
├── events/
├── receipts/
├── logs/
├── state/
└── spool/outbound/
```

## ODIN control surface

After SSH key enrollment and installation of the client, ODIN uses:

```bash
janusctl status
janusctl fabric
janusctl fabric-full
janusctl nodes
janusctl packets
janusctl send FILE
janusctl receipt
janusctl logs
janusctl shell
```

## Physical deployment

On JANUS:

```bash
cd ~
git clone -b janus-resident-edge-v1 https://github.com/Atlas-Ascend/Ark-OS.git
cd ~/Ark-OS
bash scripts/resident-edge/bootstrap-janus.sh
bash scripts/resident-edge/start-janus.sh
bash scripts/resident-edge/health-snapshot.sh
bash scripts/resident-edge/fabric-health.sh --core
bash scripts/resident-edge/emit-proof-receipt.sh
```

On ODIN, from a clone of the same branch:

```bash
bash scripts/resident-edge/odin/install-janusctl.sh
```

Then configure ODIN's SSH alias `janus` to JANUS port 8022 and enroll ODIN's public key on JANUS.

## Promotion proof gate

Repository presence is not physical proof. Promotion from `active-candidate` to physically verified requires all of:

- JANUS bootstrap reports PASS.
- JANUS `sshd` is reachable from ODIN on port 8022.
- ODIN key authentication succeeds without a password prompt.
- `tmux` session `janus` survives ODIN disconnect/reconnect.
- `janusctl status` succeeds from ODIN.
- `janusctl fabric` emits a fabric-health artifact.
- `janusctl receipt` emits a receipt with resident runtime PASS.
- reboot persistence is demonstrated on JANUS.
- no secrets or private device credentials enter Git.

Only after those proofs should an `active` JANUS physical presence be published into Neon or the profile be promoted as runtime-proven.

## Hardware baseline

```text
JANUS      ACTIVE-CANDIDATE  resident edge controller
ODIN       ACTIVE            mobile operator console
EDEN       ACTIVE/EXTERNAL   local runtime body
SHAMBALA   ACTIVE/EXTERNAL   local node
T5810-A    OFFLINE           compute reserve
T5810-B    OFFLINE           compute reserve
```

## Non-replacement law

This is an extension of the existing ARK lineage. It does not replace the current phone ARK, JANUS Prime, Packet OS, CrownGrid, Workforce Spine, Thoth, MetaForge/VULCAN, SECA, DevOS, Medusa, ProofGrid, GARI, ServerForge, RoadBridge, EDEN, or Vishvarupa. It gives those systems an always-on physical edge doorway through JANUS.
