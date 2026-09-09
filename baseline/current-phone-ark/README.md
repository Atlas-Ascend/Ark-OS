# Current Phone ARK Baseline

This directory holds the sanitized, checksum-verifiable source baseline captured from the ARK currently installed on JANUS and ODIN.

- `captures/JANUS/` — safe capture from JANUS.
- `captures/ODIN/` — safe capture from ODIN.
- `original/` — one promoted canonical baseline after verification.

Do not manually dump the entire live ARK root here. Use the capture script so private runtime state and credential material remain outside Git.
