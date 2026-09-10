# 04 // Architecture

Planes: Command, Data, Resource, Event, Proof, Security.

Command Plane accepts operator intent and produces authorized mission commands. Data Plane moves typed envelopes. Resource Plane advertises CPU/RAM/GPU/storage/models/services/battery/network/load. Event Plane emits append-only mission state. Proof Plane binds hashes, tests, deploys and verification. Security Plane enforces identity, policy and trust boundaries.

No node is hard-coded as the universal executor. HYPERNET resolves capability against policy, health, cost and load.
