# 05 — Talk / Status / Act Lanes

Mobile interaction is split into three explicit lanes.

## TALK
Read/cognitive lane. User conversation routes to Atlas Mind/Resident GARI through a mobile-safe Render conversation proxy. Conversation alone must not create a mutation packet.

## STATUS
Read-only situational-awareness lane. Reads SAMI reconciled state, Thoth-backed memory views, proof references, body/runtime health, and operator-safe telemetry.

## ACT
State-changing lane. A user action request routes to JANUS PRIME for authorization before Packet OS/Workforce/execution. The APK cannot transform arbitrary speech directly into execution.

UI and API payloads must preserve the selected lane.