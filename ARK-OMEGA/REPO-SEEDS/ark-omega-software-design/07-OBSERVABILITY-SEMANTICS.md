# Observability Semantics

Every displayed transition requires an event containing: event_id, timestamp, source, actor, target, class, state, correlation_id, trust, payload_digest.

Mission replay orders events by correlation_id and timestamp. Late events are marked late; they are not reordered silently.

Telemetry freshness classes:
FRESH <= 5s
AGING <= 30s
STALE > 30s
UNKNOWN no valid sample

Remote health must distinguish transport reachability from execution readiness. ONLINE does not imply READY. READY requires contract compatibility, authority, required capability, and health gate success.
