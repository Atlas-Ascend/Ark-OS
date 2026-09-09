# 08 — CrownGrid and Event Routing

Consumes: node.enroll, node.execute.requested, policy.updated, service.start_requested, update.requested.
Emits: node.online, node.offline, node.attested, node.degraded, capability.advertised, node.task_completed, node.task_failed.

CrownGrid treats live attestation/health as routing evidence.