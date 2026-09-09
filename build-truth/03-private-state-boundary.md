# BT-03 — Private State Boundary

**Requirement:** Credentials, SSH keys, logs, model binaries, caches, databases, and other device-private state must remain outside Git.

**Proof mechanism:** Capture allowlist/rejection policy plus .gitignore and Medusa gate.

**Seed state:** PASS — SEED IMPLEMENTED
