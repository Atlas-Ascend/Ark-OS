# ARK Ω ODIN Persistent Appliance — v1.1.1

Status: IMPLEMENTED / DEVICE BOOT CONFIRMATION REQUIRED

## Purpose
Promote ODIN from an interactive Termux install to a reboot-persistent ARK Ω appliance while preserving fail-closed estate semantics.

## Boot Contract
1. Android boot invokes Termux:Boot.
2. `~/.termux/boot/10-ark-omega.sh` waits for user-space readiness.
3. `ark-service start` acquires wake lock when available and starts exactly one `tmux` session named `ark-omega`.
4. The session launches the ARK Ω Textual operator cockpit from the canonical Ark-OS branch.
5. Opening an interactive Termux shell automatically attaches to the existing ARK Ω session.
6. Duplicate sessions are denied by `tmux has-session` idempotency.

## Operator Commands
- `ark` — start if necessary and attach.
- `ark-status` — verify resident service state.
- `ark-restart` — controlled restart.
- `ark-service stop` — controlled stop.
- `ARK_NO_AUTOATTACH=1 bash` — one-shell maintenance bypass.

## Truth / Safety Law
- Boot persistence MUST NOT imply remote estate readiness.
- JANUS, EDEN, HYPERNET, workers, ProofGrid and other remote components remain evidence-derived.
- Missing authenticated peer evidence renders `UNBOUND`, never synthetic `PASS`.
- Remote mutation remains governed by Runtime Binding v1.1.0.
- Destructive repair is never executed automatically during boot.

## Android Dependency
Android must have the Termux:Boot companion installed and opened at least once. The OS must permit Termux and Termux:Boot to run at boot/background for guaranteed automatic startup.

## Acceptance
`PERSISTENT_APPLIANCE=PASS` requires:
- installer completes with `PERSISTENT_INSTALL=PASS`;
- `ark-status` returns `ARK_OMEGA_SERVICE=RUNNING`;
- device reboot occurs;
- `~/.local/state/ghost-atlas/logs/boot.log` records successful ARK Ω start;
- opening Termux attaches to the pre-existing `ark-omega` session;
- no duplicate tmux session is created.
