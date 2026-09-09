# Architecture

## Identity

**GA-ARK** is the hardware/runtime node architecture. **Cyber Throne** is an operator-control profile installed on a GA-ARK node. It is not a new sovereign organ.

## T2 Mobile composition

```text
GA-ARK T2 MOBILE
├── CURRENT PHONE ARK BASELINE
│   ├── Atlas Mind runtime boundary
│   ├── JANUS / ODIN identity
│   ├── Termux-resident scripts/configuration
│   └── existing field/road behavior
└── CYBER THRONE v1 OVERLAY
    ├── JANUS VIBE command surface
    ├── ODIN observability surface
    ├── Android body adapters
    ├── voice command ingress
    ├── Hypernet control bridge
    ├── Packet OS ingress
    ├── Workforce Spine routing
    └── SECA/DevOS → ProofGrid return path
```

## Invariants

- Baseline files are never edited by an overlay install.
- Overlay activation must be explicitly reversible.
- Phone-local operation must survive loss of remote Hypernet connectivity.
- Remote compute is an acceleration path, not a boot dependency.
- Commands must be attributable, bounded, and receipted.
- No secret-bearing device state is promoted into Git.
