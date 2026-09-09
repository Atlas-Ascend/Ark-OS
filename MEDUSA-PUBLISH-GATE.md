# Medusa Publish Gate

Before pushing a captured phone baseline:

1. `verify-capture.sh <IDENTITY>` passes.
2. `medusa-secret-gate.sh baseline/current-phone-ark/captures/<IDENTITY>/files` passes.
3. Review `REJECTED-PATHS.txt`; never add rejected private files merely to make the baseline look complete.
4. No `.env`, token, private key, SSH material, runtime database, user log, or model weight enters Git.
5. Promote only the sanitized, checksum-sealed source/config baseline.
