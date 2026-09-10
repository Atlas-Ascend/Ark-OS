# Implementation Handoff

Implementation may begin only against versioned contracts. UI code must consume mock fixtures and live adapters through the same interfaces.

Required gates before design is marked implemented:
- component state coverage
- keyboard navigation test
- narrow-terminal rendering test
- stale/offline/degraded state test
- authorization denial test
- mission correlation test
- proof receipt rendering test
- event replay determinism test
- no-fake-state audit
- accessibility audit
- recovery flow test

A surface is not DONE because it renders. DONE requires contract-backed data, failure behavior, operator control, verification, and proof.
