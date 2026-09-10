# Failure and Recovery UX

Failures must name the failed layer: LOCAL, TRANSPORT, IDENTITY, POLICY, CAPABILITY, EXECUTION, VERIFICATION, PROOF, MEMORY.

Recovery console domains:
1 Network diagnostics
2 HYPERNET repair
3 Peer re-enrollment
4 Credential health
5 Local cache integrity
6 Packet queue inspection
7 Event journal recovery
8 Restore last known configuration
9 VISHVARUPA compatibility mode
0 Safe shell

No recovery action may destroy historical state by default. Repair produces a receipt. Rollback identifies source version, target version, affected contracts, and post-rollback verification.
