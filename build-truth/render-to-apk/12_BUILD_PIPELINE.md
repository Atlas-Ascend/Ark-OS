# 12 — Render-to-APK Build Pipeline

Canonical delivery pipeline:

`GitHub → web/runtime tests → Render deploy → runtime health/proof → Android web/native sync → Gradle build → APK signing → install/test → Assistant-role proof → VISHVARUPA attestation`.

Recommended hybrid shell: Capacitor-backed Android project where useful, plus native Kotlin services for Android Assistant/voice integrations that require platform APIs.

The Render web application may update independently of APK releases when native contracts remain compatible. Native permission/service changes require a new APK build.