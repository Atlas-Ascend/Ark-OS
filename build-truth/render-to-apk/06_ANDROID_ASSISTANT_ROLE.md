# 06 — Android Assistant Role

Target integration uses Android's supported assistant/voice-interaction surfaces rather than claiming replacement of Android's entire AI stack.

Target components:
- `VoiceInteractionService`
- `VoiceInteractionSessionService`
- `VoiceInteractionSession`
- Assistant-role enrollment/onboarding
- native assistant overlay / JANUS VIBE

Acceptance requires proof on the physical target phone that Atlas can be selected as the device digital assistant and invoked through the configured assistant gesture/power-button path.

Custom always-on wake phrase is a later device-specific gate and is not required for V1.