# 16 // Proof + Promotion

Required receipt fields: mission_id, command_hash, operator identity reference, route, participating nodes, packet ids, artifact hashes, git refs, tests, security gates, verification result, deployment refs, timestamps, event root hash, rollback version.

Promotion condition: all mandatory gates PASS; no unresolved critical/high security findings; canary replay complete; transfer integrity PASS; rollback PASS; VISHVARUPA parity matrix accepted.

Final states: CANDIDATE, SEALED, PROMOTED, SUPERSEDED. Never label complete without evidence.
