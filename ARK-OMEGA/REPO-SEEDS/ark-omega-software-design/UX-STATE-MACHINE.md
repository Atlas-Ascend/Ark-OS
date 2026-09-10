# Mission UX State Machine

States: ACCEPTED -> BLUEPRINTING -> ROUTING -> EXECUTING -> VERIFYING -> DEPLOYING -> SEALED.

Side states: WAITING, BLOCKED, REPAIRING, ROLLED_BACK, FAILED.

Only backend mission events may transition rendered state. Client optimistic transitions are forbidden for execution/proof states. Every state exposes timestamp, actor/node, packet refs and receipt refs when available.
