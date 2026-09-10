# 20 // ODIN Operator Ownership & Recovery Law v1.1.4

Status: CANONICAL ACCESSION CONTROL

## Purpose

Prevent multiple generations of operator interfaces from competing for the same Termux terminal lifecycle and provide a deterministic production-recovery path for ODIN.

## Operator ownership law

- VISHVARUPA runtime, compatibility, HYPERNET identity, cloud twin, and historical assets are preserved.
- VISHVARUPA interactive terminal ownership is denied on ODIN.
- Legacy ARK tmux/UI auto-attach ownership is denied.
- ARK OMEGA is the sole designated interactive operator surface.
- ARK OMEGA background services are headless only.
- Termux safe shell access is mandatory and may never be replaced automatically by a UI.
- Shell startup files may establish environment only; they may not `exec` or attach an operator UI.

## Recovery law

Every recovery follows:

OBSERVE -> PRESERVE -> ISOLATE AUTHORITY -> REPAIR LOWEST BROKEN LAYER -> VERIFY REAL RETURN CODES -> PROMOTE -> RECEIPT

No upper-layer ARK mutation is permitted while the Termux execution substrate is unhealthy.

## Acceptance gates

A PASS is valid only when the underlying command or process actually succeeds.

Required pre-UI gates:

1. Termux bash executes successfully.
2. apt/dpkg execute successfully.
3. git/python/tmux/ssh/curl/jq/rsync execute successfully.
4. Ark-OS canonical branch is synchronized.
5. Android compatibility checks pass.
6. ARK command surface is installed.
7. `ark-omega-supervisor` exists and is healthy.
8. legacy `ark-omega` UI session is absent.
9. VISHVARUPA UI session is absent.
10. safe shell remains available.

## Boot promotion

Boot persistence is explicitly deferred until:

- foreground `ark` cockpit canary passes;
- cockpit exit restores the shell;
- supervisor remains healthy after UI exit;
- no VISHVARUPA or legacy ARK interactive owner reappears.

Only then may Termux:Boot persistence be enabled and cold-reboot tested.

## Canonical recovery command

`ARK-OMEGA/termux/odin-recover.sh`

The recovery director is idempotent, preserves local state before mutation, fails closed on substrate errors, and writes a receipt under `~/.local/state/ghost-atlas/receipts/`.

## Supersession

This document supersedes ad hoc terminal autoattach, blind startup mutation, ceremonial PASS output, and any procedure that promotes boot automation before foreground validation.
