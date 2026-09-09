# 09 — Context & Sensor Policy

Sensor/context access is permissioned, visible, minimal, and task-scoped.

Potential Android observations: microphone, camera, location, motion/orientation, battery, network state, selected shared files, notification events, assist structure/content, and allowed screenshot context.

Every observation carries source/body, timestamp, permission state, freshness, and confidence where applicable.

Sensitive/secure apps or Android policy may suppress assist/screenshot context. Absence of sensor data must be represented explicitly; Atlas must not infer unseen content.