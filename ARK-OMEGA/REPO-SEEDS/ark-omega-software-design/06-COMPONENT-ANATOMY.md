# Component Anatomy

Core components:
- StatusRail
- DomainRail
- ContextRail
- HotkeyRail
- PeerSwitcher
- NodeTable
- ResourceMeter
- CapabilityMatrix
- MissionTimeline
- PacketInspector
- EventStream
- ProofReceiptViewer
- SecurityStatePanel
- RecoveryConsole
- CommandPalette
- BootSequence

Each component accepts normalized contract data only. Components must not reach directly into transport implementations. Adapters convert SSH/HTTPS/Tailscale/local sources into canonical node, event, packet, resource, and proof contracts.

Every component defines: empty, loading, ready, degraded, denied, offline, stale, and error states.
