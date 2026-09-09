# BT-09 — Rollback

**Requirement:** Every upgrade must have a bounded rollback that removes only what the upgrade added.

**Proof mechanism:** rollback-overlay.sh deletes only the Cyber Throne overlay and its receipt.

**Seed state:** PASS — SEED IMPLEMENTED
