# ARK OMEGA Software Seed

Target stack: TypeScript strict mode; Next.js/React operator surface; shared typed contracts; event-stream adapter; CLI package; local durable outbox for ODIN; test harness; observability; provider adapters.

Suggested packages: `apps/command-center`, `packages/contracts`, `packages/cli`, `packages/hypernet-client`, `packages/event-replay`, `packages/proof-client`, `packages/security-policy`, `packages/testkit`.

Implementation must preserve policy boundaries: no arbitrary shell execution, no unauthenticated mutations, no unreceipted state change.
