# Ark-OS

**Canonical implementation:** GA-ARK (Ghost Atlas ARK)

**Ghost Atlas ARK — Phone Baseline + Cyber Throne Convergence**

GA-ARK preserves the current ARK lineage running on the JANUS/ODIN phones and layers the **GA-ARK T2 Mobile Cyber Throne v1** profile above it without replacing the existing runtime.

## Canonical law

1. The current phone ARK is the baseline, not legacy trash.
2. Cyber Throne is an **overlay/profile**, not a replacement operating system.
3. The baseline is immutable after promotion.
4. Device-private state never enters Git.
5. Every migration is reversible.
6. Every promotion requires verification evidence.
7. JANUS remains the command surface; ODIN remains the observability surface.
8. Commands route through the existing Ghost Atlas command-to-proof loop.

## Closed loop

```text
VOICE / TOUCH
    ↓
ATLAS MIND
    ↓
JANUS
    ↓
PACKET OS
    ↓
WORKFORCE SPINE
    ↓
TARGET ORGAN / HYPERNET NODE
    ↓
SECA / DevOS
    ↓
PROOFGRID
    ↓
JANUS VIBE / ODIN
```

## Repository layout

```text
GA-ARK/
├── baseline/current-phone-ark/      # Sanitized, verified phone ARK source baseline
│   ├── captures/                    # Per-device safe captures (JANUS / ODIN)
│   └── original/                    # Promoted canonical baseline
├── profiles/t2-mobile/current/      # Descriptor for the phone profile already in use
├── profiles/t2-mobile/cyber-throne/ # New non-destructive Cyber Throne overlay
├── capabilities/                    # Operator, Android-body, voice, Hypernet capability specs
├── interfaces/                      # JANUS VIBE + ODIN mobile surfaces
├── runtime/atlas-mind/              # Runtime integration boundary
├── contracts/                       # Node and command contracts
├── migrations/                      # Explicit upgrade/rollback path
├── scripts/                         # Capture, verification, migration tooling
├── proof/                           # Evidence and receipts
└── tests/                           # Structural and safety gates
```

## Why the original phone ARK is captured rather than blindly copied

The live install root may contain tokens, `.env` files, SSH material, logs, model binaries, caches, databases, or other device-private state. `capture-current-phone-ark.sh` therefore performs a **safe source/config capture**: it preserves code, scripts, manifests, contracts, and non-secret configuration byte-for-byte while rejecting obvious credential material. Rejected paths are listed in a local report so they can be reviewed without publishing their contents.

The reported current phone baseline is recorded in `ARK_BASELINE.lock`. Its exact bytes become canonical only after a capture is verified and promoted.

## Phone capture

Run from a clone of this repo on each phone:

```bash
bash scripts/capture/capture-current-phone-ark.sh --identity JANUS
bash scripts/verification/verify-capture.sh JANUS
```

On ODIN:

```bash
bash scripts/capture/capture-current-phone-ark.sh --identity ODIN
bash scripts/verification/verify-capture.sh ODIN
```

Compare the two:

```bash
bash scripts/verification/compare-phone-baselines.sh JANUS ODIN
```

Promote a verified capture:

```bash
bash scripts/capture/promote-baseline.sh JANUS
```

The promoted baseline is written to `baseline/current-phone-ark/original/` and sealed with SHA-256 checksums.

## Cyber Throne overlay

The overlay lives under `profiles/t2-mobile/cyber-throne/` and is intentionally independent of the baseline files. Install it into a separate overlay directory:

```bash
bash migrations/phone-current-to-cyber-throne-v1/install-overlay.sh
```

Verify:

```bash
bash scripts/verification/verify-repo.sh
```

Rollback removes only the overlay marker/directory created by this repository; it does not touch the baseline ARK:

```bash
bash migrations/phone-current-to-cyber-throne-v1/rollback-overlay.sh
```

## Security gate

Before any push/publication:

```bash
bash scripts/verification/medusa-secret-gate.sh
```

The gate intentionally errs on the side of blocking suspicious files.

## Status

- **Current ARK baseline:** declared, awaiting byte-level capture from JANUS/ODIN.
- **Cyber Throne profile:** seeded as non-destructive overlay.
- **Migration:** seeded and rollback-safe.
- **Remote GitHub repository:** `Atlas-Ascend/Ark-OS`.
- **Repository convergence:** seeded from the GA-ARK preservation + Cyber Throne architecture.
- **Device promotion gate:** remains pending until JANUS/ODIN produce verified captures of the live phone ARK bytes.
