# Ghost Atlas Android Assistant — Render → APK

Campaign: `GA-ARK-RENDER-TO-APK-001`

This is the first native Android embodiment of Atlas Mind. **Render remains the resident runtime/control body; the APK is a thin Android body + JANUS VIBE surface.** The phone does not carry estate server secrets or become a competing cognition stack.

## Runtime topology

```text
Android / Ark-OS APK
  ├─ STATUS ──GET──> Render /v1/sami/brief
  ├─ TALK ─────────> Render Atlas conversation proxy [BINDING REQUIRED]
  └─ ACT ───POST──> Render /v1/commands → JANUS → Packet/Workforce → ProofGrid → Thoth
```

The APK must never turn an ordinary conversational utterance into a state-changing command. TALK and ACT are separate user intents and separate backend contracts.

## V0 implemented scope

- selectable Android Assistant-role request;
- `VoiceInteractionService` + `VoiceInteractionSessionService`;
- assistant/keyguard session support where Android/OEM permits it;
- live SAMI resident-brief read from Render;
- push-to-talk using Android `SpeechRecognizer`;
- Android `TextToSpeech`;
- explicit **Act through JANUS** lane using the live `/v1/commands` contract (`intent`, `correlation_id`, proof/memory flags);
- assist-context package observation;
- screenshot reception deliberately non-uploading until ARGUS policy is wired;
- no embedded estate secrets;
- no arbitrary shell or accessibility automation;
- CI recipe that builds and uploads `app-debug.apk`.

## Deliberately unbound in V0

The **Talk to Atlas** lane does not dispatch commands and does not embed `ATLAS_OPERATOR_TOKEN`. The existing Atlas inference API is protected. Production TALK becomes active only after a **server-side Render conversation proxy / device-auth bridge** is proven, so privileged Atlas credentials remain server-side.

Until then TALK can hear the user and read SAMI context, but reports the processor bridge as unbound and performs no estate mutation.

## Build

2026 project baseline:
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

The GitHub workflow `.github/workflows/atlas-android-apk.yml` performs the same build and uploads the debug APK when a runner is available.

## Truth boundary

Repository scaffold != APK proof. Promotion requires:

1. Android compilation succeeds and an APK artifact exists;
2. APK installs on a real JANUS/ODIN phone;
3. Android accepts Atlas as the selected Assistant;
4. the configured assistant/power-button invocation opens Atlas;
5. STATUS reads live SAMI state;
6. ACT submits one bounded JANUS-governed request and observes its ProofGrid/Thoth completion;
7. TALK reaches Atlas Mind through a server-side Render credential boundary without embedding privileged server credentials in the APK.
