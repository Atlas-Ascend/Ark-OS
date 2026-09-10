# 06 // Data + Event Contracts

TransferEnvelope: transfer_id, mission_id, source, destination, content_type, content_hash, size, created_at, route_policy, ttl, encryption, ack_required.

MissionEvent: mission_id, event_id, sequence, timestamp, actor, node_id, packet_id, event_type, state_from, state_to, payload_ref, payload_hash, receipt_ref.

State-changing events are append-only. Payloads may live elsewhere; event records carry immutable references and hashes. Replay renders only recorded events.
