# 03 — Render.com Runtime Authority

Render.com is the primary continuously deployable mobile backend/runtime boundary for this campaign.

Render responsibilities:
- expose mobile-safe HTTPS/WSS/SSE endpoints;
- hold privileged server-side credentials;
- proxy protected Atlas Mind inference where required;
- expose SAMI resident state and proof/event streams;
- submit action intents into JANUS-governed execution;
- return explicit degraded states when upstream organs are unavailable.

The APK never embeds Render service secrets, Atlas operator secrets, database credentials, GitHub credentials, or estate admin keys.