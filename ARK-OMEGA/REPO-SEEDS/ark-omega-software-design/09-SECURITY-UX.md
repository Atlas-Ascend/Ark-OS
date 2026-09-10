# Security UX

Security state is visible but not noisy.

Trust labels: LOCAL, ENROLLED, VERIFIED, DEGRADED, REVOKED, UNKNOWN.
Authority labels: READ, OPERATE, MUTATE, ADMIN, DENIED.

Sensitive commands show target, authority source, expected side effects, and proof requirement. Credentials are never displayed in plaintext. Secret values are redacted at presentation boundaries.

Medusa findings surface by severity and affected capability. Security blocks cannot be dismissed as cosmetic UI warnings; they alter dispatch eligibility.
