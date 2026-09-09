# Migration Contract

## From

`GA-ARK T2 Mobile / current-phone-ark`

## To

`GA-ARK T2 Mobile / current-phone-ark + cyber-throne-v1 overlay`

## Method

- Capture and verify baseline.
- Install overlay into a dedicated `overlays/cyber-throne-v1` directory beneath the ARK root.
- Do not alter baseline source files.
- Write an activation receipt/marker only.
- Run repository + on-device verification.
- Promote only after SECA/DevOS proof passes.

## Rollback

Rollback removes only files created by the overlay installer and leaves the original ARK untouched.
