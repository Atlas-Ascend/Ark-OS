# 03 // Requirements

Functional: peer switching JANUS/EDEN/HYPERNET; bidirectional object transfer; capability discovery; resource-aware execution; offline queue; command/session journal; mission timeline; estate graph; forensic drill-down; mission replay; proof retrieval.

Non-functional: least privilege; authenticated transport; idempotent commands; checksummed transfers; bounded retries; resumability; deterministic receipts; observable failure states; explicit rollback; mobile power awareness; local-first operation; no secret material in logs.

SLO seed: command acknowledgement <=2s on healthy local fabric; transfer integrity 100% hash verified; no unreceipted state-changing execution; replay event ordering deterministic by mission/event sequence.
