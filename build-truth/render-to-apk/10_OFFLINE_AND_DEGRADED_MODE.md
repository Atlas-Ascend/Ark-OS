# 10 — Offline & Degraded Mode

Connectivity states:
- ONLINE: full Render/estate cognition and governed execution.
- ESTATE_LAN: optional direct approved estate/local route when configured.
- DEGRADED: cached state, local UI, queued non-destructive intents, optional local model.
- OFFLINE: device-only functions and explicit estate-unavailable status.

Queued state-changing commands are never represented as executed. Replay requires current authentication, JANUS authorization, and fresh policy at reconnect time.