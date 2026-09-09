# 04 — Android APK Role

The APK is the native mobile embodiment layer.

Responsibilities:
- Android Assistant-role integration when supported;
- JANUS VIBE UI;
- voice capture and playback;
- camera/sensor access under runtime permissions;
- notifications and haptics;
- secure local session/device credentials;
- Render API client;
- offline/degraded cache;
- VISHVARUPA body attestation client;
- optional local inference fallback when separately proven.

The APK does not contain canonical Atlas Mind model weights by default and does not execute unrestricted shell or arbitrary UI automation.