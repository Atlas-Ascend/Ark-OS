# 14 — Security & Verification

Required tests/gates:
- no embedded privileged secrets;
- TLS-only production endpoints;
- auth/session expiry and revocation;
- Talk cannot mutate estate state;
- Status is read-only;
- Act requires JANUS authorization;
- offline queued work cannot claim execution;
- permission denial degrades safely;
- forged/stale proof cannot become success;
- phone/body staleness removes routing eligibility;
- Render outage produces explicit degraded state;
- APK build/install/launch verified on target device.

SECA/DevOS/ProofGrid remain independent assurance authorities.