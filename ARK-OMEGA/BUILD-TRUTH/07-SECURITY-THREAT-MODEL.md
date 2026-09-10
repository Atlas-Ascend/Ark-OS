# 07 // Security + Threat Model

Threats: stolen phone, rogue node, replayed command, forged ACK, poisoned telemetry, credential leakage, path traversal, arbitrary shell escalation, transfer tampering, malicious artifact, privilege confusion, stale-node routing.

Controls: device identity; short-lived credentials; signed/enveloped commands; nonce + expiry; mTLS or authenticated overlay transport where supported; hash verification; allowlisted capabilities; no generic remote shell through the control API; command policy gates; audit log; secret redaction; node quarantine; rate limits; bounded payload sizes; Medusa review hooks.

Destructive operations require explicit elevated authorization and are never inferred from natural-language ambiguity.
