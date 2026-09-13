# ARK-OS BINDING — ATLAS MIND PWA ORGANISM V1 — 2026-09-13

Campaign: `GA-ATLAS-MIND-PWA-ORGANISM-V1-2026-09-13`
Status: ACTIVE / CONVERGENCE ONLY
Created: 2026-09-13
Canonical owner: `Atlas-Ascend/Ark-OS`

## Ark-OS responsibility

Ark-OS is the field/mobile substrate for the same Atlas Mind identity. For the MVP, the installable `atlasmind.global` PWA is the default phone embodiment. Ark-OS does not host a replacement cognition stack.

## Active MVP binding

- phone/browser launches the installable Atlas Mind PWA;
- PWA conversation uses the existing Atlas Mind web/runtime owners;
- state-changing work remains JANUS-governed;
- Termux receives a zero-secret `atlas` launcher into the same PWA identity rather than a separate prompt/model system;
- HYPERNET/device controls remain Ark-owned;
- native Android Atlas Assistant source is preserved as a later/deeper embodiment and is not deleted or treated as the MVP release gate.

## Implemented Termux field entry

Canonical scripts:

- `scripts/atlas-mind/atlas`
- `scripts/atlas-mind/install-termux-atlas.sh`

After installation the field operator can use:

- `atlas` / `atlas organism` -> `/organism`
- `atlas try` -> bounded `/try`
- `atlas operator` -> governed `/atlas`
- `atlas status` -> public `/status`

The launcher stores no Atlas/JANUS/operator credential. It opens the canonical web body using `termux-open-url` when available and otherwise prints the canonical URL.

This is **not yet a terminal-native conversational client**. Direct natural-language terminal turns remain an OPEN proof item until the existing operator identity/auth contract can be reused safely without embedding a privileged token in a distributable Termux script.

## Preserved assets

Existing native Android assistant, voice services, TTS/speech recognition, resident-edge scripts, `janusctl`, HYPERNET controls, profiles, and proof utilities remain canonical assets. This convergence does not replace them.

## Ark proof criteria

- PWA installs/launches standalone on a real Ark/JANUS/ODIN phone;
- authenticated session reaches the same Atlas Mind identity used by desktop web;
- Termux launcher opens the same canonical PWA surfaces with no embedded privilege;
- terminal-native natural-language turns reuse the same Atlas identity/auth contract when that contract is proven;
- a governed action returns matching execution/proof/memory evidence;
- no privileged estate credential is embedded in browser/PWA/Termux distributable source;
- native Android remains available for future OS-level assistant/wake-word capabilities without blocking this MVP.
