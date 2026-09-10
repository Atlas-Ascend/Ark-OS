# Hardware/Node Hardening

ODIN: screen lock + device encryption; no long-lived plaintext estate secrets; short-lived auth; restricted SSH keys; battery-aware scheduling; local encrypted/permission-restricted outbox where platform permits; remote revoke capability.

JANUS/EDEN: dedicated service identities; firewall/overlay restrictions; no password SSH where key auth is available; capability allowlists; health probes; graceful drain; resource ceilings; log redaction; filesystem boundary checks.

All nodes: clock sanity, protocol/version reporting, quarantine state and explicit decommission procedure.
