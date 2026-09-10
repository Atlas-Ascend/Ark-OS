# 05 // Universal Node Contract

Required node fields: node_id, vessel, identity_key_id, trust_domain, transports, capabilities, resources, health, policy_labels, last_seen, protocol_version.

Required behaviors: advertise, heartbeat, accept authorized envelopes, reject unsupported capability, return typed ACK/NACK, emit execution events, produce or reference receipts, support graceful drain.

Resource scheduling considers capability match first, then security policy, execution readiness, health, locality, battery/power, load, latency and cost.
