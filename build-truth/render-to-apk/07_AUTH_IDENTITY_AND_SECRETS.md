# 07 — Authentication, Identity & Secrets

APK-distributed binaries are hostile extraction environments. No long-lived privileged estate secret may be shipped in resources, source, BuildConfig, assets, native libraries, or JavaScript bundles.

Mobile authentication model:
1. device/app establishes a bounded user/device session with Render;
2. Render validates session and operator identity;
3. Render holds privileged upstream credentials server-side;
4. JANUS separately authorizes state-changing work.

Use Android Keystore-backed storage for device/session credentials. Support revocation, rotation, expiry, device ID, and VISHVARUPA body identity.