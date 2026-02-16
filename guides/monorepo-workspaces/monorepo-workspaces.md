# Monorepo Workspaces

Best practices for organizing monorepos so teams can scale packages, apps, and shared tooling without dependency sprawl.

> **Scope**: Workspace topology, package boundary contracts, and dependency direction across `apps/` and `packages/` style repositories.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Workspace Topology](#workspace-topology) |
| [Dependency Direction Rules](#dependency-direction-rules) |
| [Package Boundary Contracts](#package-boundary-contracts) |
| [Build and Test Graph Strategy](#build-and-test-graph-strategy) |
| [Good/Bad Layout Examples](#goodbad-layout-examples) |
| [Anti-Patterns](#anti-patterns) |
| [Red Flags](#red-flags) |

---

## Quick Reference

| Category | Guidance | Rationale |
| --- | --- | --- |
| **Structure** | Separate deployable apps from reusable packages | Makes ownership and release scope explicit |
| **Dependencies** | Enforce one-way flow: app -> domain package -> utility package | Prevents cyclic and lateral coupling |
| **Contracts** | Export only public APIs from package root | Keeps internal refactors safe |
| **Tooling** | Centralize lint/test/tsconfig presets in dedicated config packages | Avoids copy-paste drift |
| **CI** | Run affected-only tasks from dependency graph | Scales pipeline cost with change size |

---

## Core Principles

| Principle | Guideline | Rationale |
| --- | --- | --- |
| **Clarity of purpose** | Every workspace package has a single role | Avoids "misc" package growth |
| **Directional dependencies** | Lower-level packages never depend on higher-level ones | Preserves architecture boundaries |
| **Stable interfaces** | Root exports are the package contract | Enables safe internals churn |
| **Small blast radius** | Changes should invalidate only dependent targets | Keeps CI fast and predictable |

---

## Workspace Topology

| Directory | Purpose | Ownership signal |
| --- | --- | --- |
| `apps/` | Deployable services/frontends | Product or platform teams |
| `packages/domain-*` | Domain/business logic | Domain teams |
| `packages/shared-*` | Cross-domain primitives | Platform team |
| `packages/config-*` | Lint/build/test presets | Developer experience |
| `scripts/` | Repo-wide automation | Platform team |

| Topology rule | Recommendation |
| --- | --- |
| App count grows | Split app-local code under each app first before creating shared packages |
| Shared package grows | Split by domain capability, not by framework type |
| Team ownership unclear | Add CODEOWNERS mapping by package path |

---

## Dependency Direction Rules

### Allowed import flow

```text
apps/* -> packages/domain-* -> packages/shared-* -> packages/config-*
```

### Forbidden import flow

```text
packages/shared-* -> packages/domain-*      # inverts layering
packages/domain-* -> apps/*                 # app leakage
apps/app-a -> apps/app-b                    # cross-app runtime coupling
```

| Rule | Good | Bad |
| --- | --- | --- |
| App-to-app sharing | Move shared code to `packages/domain-*` | Directly importing another app's `src/` |
| Domain reuse | Depend on shared primitives only | Domain package depending on a specific app |
| Configuration | Consume config packages from all layers | Duplicating eslint/tsconfig in each package |

---

## Package Boundary Contracts

| Contract element | Requirement | Rationale |
| --- | --- | --- |
| Public entrypoint | Use root `index.ts` or explicit exports map | Defines stable API |
| Internal modules | Keep under `internal/` or non-exported paths | Prevents accidental coupling |
| Versioning | Track breaking changes per package | Protects downstream apps |
| Tests | Cover public API behavior first | Locks expected contract |

```ts
// Good: package root contract
export { createOrder } from './orders/create-order'
export type { Order, CreateOrderInput } from './orders/types'
```

```ts
// Bad: importing package internals from consumers
import { createOrder } from '@acme/orders/src/orders/create-order'
```

---

## Build and Test Graph Strategy

| Strategy | Implementation | Benefit |
| --- | --- | --- |
| Affected-only CI | Compute changed package graph and run impacted targets | Faster CI on large repos |
| Layered pipelines | Lint/typecheck first, then unit, then integration/e2e | Fails fast on cheap checks |
| Cache-aware builds | Reuse task cache by input hash | Reduces duplicate work |
| Per-package test ownership | Package tests run with package changes | Improves signal and accountability |

| CI trigger | Minimum command set |
| --- | --- |
| Pull request | `lint`, `typecheck`, affected `test` |
| Merge to main | Full unit/integration and packaging |
| Release/tag | Full validation + publish/deploy flow |

---

## Good/Bad Layout Examples

```text
# Good
apps/
  api/
  web/
packages/
  domain-billing/
  domain-users/
  shared-types/
  shared-utils/
  config-eslint/
  config-ts/
```

```text
# Bad
src/
  app-a/
  app-b/
  shared/
    everything/
      random/
```

| Why "good" works | Why "bad" fails |
| --- | --- |
| Explicit package ownership and purpose | Mixed concerns and no clear contracts |
| Layered dependencies are enforceable | High chance of hidden cross-dependencies |

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| --- | --- | --- |
| Single `shared/` dumping ground | Becomes unreviewable and tightly coupled | Split by domain or primitive type |
| Direct app-to-app imports | Hidden runtime coupling | Extract shared package |
| Exporting everything by default | Consumers lock into internals | Export only contract surface |
| Per-package copied tool configs | Drift and inconsistent enforcement | Centralize in config packages |

---

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| Package depends on consumer app code | Block merge and refactor dependency direction | Violates architectural layering |
| CI runtime scales linearly with repo size | Add affected-only graph execution | Monorepos must scale by change set, not total size |
| Multiple teams editing same shared package weekly | Split package by ownership boundary | Frequent contention indicates wrong package seams |

---

## See Also

- [Codebase Organization](../codebase-organization/codebase-organization.md)
- [Dependency Management](../dependency-management/dependency-management.md)
- [CI/CD Pipelines](../cicd-pipelines/cicd-pipelines.md)
- [Repository Governance](../repository-governance/repository-governance.md)
- [Release Engineering & Versioning](../release-engineering-versioning/release-engineering-versioning.md)
