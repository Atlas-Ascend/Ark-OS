# Ghost Atlas Android Assistant — Render → APK

Campaign: `GA-ARK-RENDER-TO-APK-001`

This is the first native Android embodiment of Atlas Mind. Render remains the cognitive/runtime body. The APK is a thin Android body + JANUS VIBE surface.

## Runtime topology

`Android APK → HTTPS → ghost-atlas-runtime-gateway.onrender.com → SAMI / Atlas Mind / JANUS → Packet OS / Workforce → SECA / ProofGrid → Thoth`

## V0 scope

- selectable Android Assistant role;
- `VoiceInteractionService` + `VoiceInteractionSessionService`;
- long-press/assistant invocation once selected by the user;
- SAMI resident brief read;
- push-to-talk using Android SpeechRecognizer;
- Android TextToSpeech;
- governed commands through `/v1/commands`;
- assist-context package observation;
- screenshot reception deliberately non-uploading until ARGUS policy is wired;
- no embedded estate secrets;
- no arbitrary shell or accessibility automation.

## Build

Official 2026 baseline:
- AGP 9.4.0
- Gradle 9.6.0
- JDK 17
- compileSdk / targetSdk 36 (Android 16)

From `android/atlas-assistant` with Gradle 9.6 available:

```bash
gradle :app:assembleDebug
```

Expected artifact:

`app/build/outputs/apk/debug/app-debug.apk`

## Truth boundary

Repository scaffold != APK proof. The next proof gate is successful Android build, install on JANUS/ODIN, selection as the device Assistant, invocation from the configured assistant gesture/power-button path, live SAMI read, and one governed command-to-proof round trip.
