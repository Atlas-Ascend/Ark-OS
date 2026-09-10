# Visual System

Design language: firmware console + mission control + high-density observability.

## Hierarchy
- Level 0: estate state
- Level 1: domain/navigation
- Level 2: selected object
- Level 3: forensic detail

## Status vocabulary
READY, DEGRADED, OFFLINE, UNBOUND, DENIED, QUEUED, ROUTING, EXECUTING, VERIFYING, REPAIRING, SEALED.

## Motion policy
Motion communicates state transition only. Packet movement is rendered only when a packet event exists. Pulses indicate active transport, not decoration. Replay is event-derived.

## Density
Primary cockpit: sparse and glanceable.
Subsystem views: dense and inspectable.
Proof view: evidence-first, chronological, exportable.

## Typography
Monospaced operational typography for data, identifiers, paths, hashes, and hotkeys. Human-readable sans-serif may be used in web surfaces for explanatory content. TUI must remain legible at narrow Android terminal widths.
