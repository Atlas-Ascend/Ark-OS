# 13 — Signing, Distribution & Updates

Debug APKs are development evidence only. Release promotion requires reproducible signed artifacts and recorded hashes.

Track:
- application ID;
- versionCode/versionName;
- source commit;
- Render backend/API contract version;
- Gradle/AGP/JDK/SDK versions;
- artifact SHA-256;
- signing identity reference (never private key material);
- device install result;
- rollback target.

Web/runtime changes deploy through Render. Native code changes ship through a new signed APK/version.