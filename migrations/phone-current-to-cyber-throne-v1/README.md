# Current Phone ARK → Cyber Throne v1

This migration is additive. `install-overlay.sh` copies only the Cyber Throne profile into `~/.ghost-atlas/overlays/cyber-throne-v1` (or `$GHOST_ATLAS_ROOT`) and writes a receipt. It does **not** alter current runtime files or attempt to guess the existing ARK activation mechanism.

Actual activation wiring should be added only after the JANUS/ODIN baseline capture identifies the current launcher/service contracts.
