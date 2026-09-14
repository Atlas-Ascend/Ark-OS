# BT-10 — JANUS / ODIN Role Split

**Requirement:** JANUS remains executive command; ODIN remains observability.

**Proof mechanism:** Current and Cyber Throne profile descriptors preserve role separation.

**Resident estate-forensics binding:** ODIN may execute the canonical Estate Service Catalog forensic census as an observability workload through `janusctl estate-forensics`. This authority is limited to discovery, verification, evidence generation, and pushing governed forensic artifacts to the existing convergence branch. It does not authorize ODIN to promote runtime lineages, redefine canonical ownership, mutate production state, or bypass JANUS/Medusa/SECA/DevOS gates.

**Execution substrate:** `scripts/resident-edge/estate-forensics.sh` -> `Estate-Service-Catalog-Capability-Registry/scripts/run_forensics_resident.py`.

**Seed state:** PASS — SEED IMPLEMENTED
