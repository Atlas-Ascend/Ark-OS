# ARK Ω ODIN Fail-Safe Boot — v1.1.2

Status: IMPLEMENTED / REBOOT VALIDATION REQUIRED

## Invariant
A cockpit/UI failure MUST NOT replace, deadlock, or obscure the operator shell.

## Boot architecture
ANDROID BOOT -> Termux:Boot -> headless ARK Ω supervisor -> heartbeat/log receipt.

The Textual cockpit is NOT launched from the boot hook. It launches only from an interactive TTY.

## Interactive architecture
TERMUX OPEN -> .bashrc -> one guarded ARK autoboot attempt -> UI preflight -> cockpit.

If preflight or cockpit execution fails:
- terminal state is restored;
- error is logged;
- SAFE SHELL remains available;
- `ark-diagnose` exposes supervisor, Python runtime, Textual import, boot log, and UI log.

## Guards
- no `exec tmux attach-session` from `.bashrc`;
- no detached Textual TUI as boot-critical service;
- one guarded autoboot attempt per shell environment;
- headless supervisor is single-instance;
- boot hook retries up to 12 times;
- UI requires an interactive TTY;
- wake-lock belongs to the supervisor, not UI lifetime.

## Commands
- `ark` — launch cockpit with safe-shell fallback
- `ark-status` — inspect headless supervisor
- `ark-restart` — restart supervisor
- `ark-diagnose` — inspect boot/UI failure evidence
- `ARK_NO_AUTOBOOT=1 bash` — explicit safe shell

## Promotion gate
`ODIN_FAILSAFE_BOOT=PASS` requires a physical reboot followed by:
1. supervisor heartbeat present,
2. boot log contains `BOOT_RESULT=PASS`,
3. opening Termux starts cockpit on a real TTY,
4. deliberate cockpit failure returns to a usable shell,
5. `ark-diagnose` reports actionable evidence.
