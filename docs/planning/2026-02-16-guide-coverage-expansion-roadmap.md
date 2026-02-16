# Guide Coverage Expansion Roadmap

Execution-ready backlog for guide coverage expansion across architecture, governance, release, and operations topics.

| Field | Value |
| --- | --- |
| **Status** | Complete - roadmap scope LG-01 through LG-09 implemented and harmonized |
| **Created** | 2026-02-16 |
| **Decision owner** | Human maintainer |
| **Input method** | Guide coverage synthesis and backlog scoping |
| **Progress Updated** | 2026-02-16 |

## Contents

| Section |
| --- |
| [Input Snapshot](#input-snapshot) |
| [Gap Signal Map](#gap-signal-map) |
| [Gap Backlog](#gap-backlog) |
| [Delivery Plan](#delivery-plan) |
| [Index Edit Plan (Exact Rows)](#index-edit-plan-exact-rows) |
| [Milestones](#milestones) |
| [Acceptance and Validation](#acceptance-and-validation) |
| [Risks and Mitigations](#risks-and-mitigations) |

---

## Input Snapshot

| Item | Value |
| --- | --- |
| **Scope basis** | Architecture and operations pattern gaps observed in implementation-focused project layouts |
| **Signal type** | Directory names, file names, file locations |
| **Out of scope** | File body analysis, behavioral correctness claims |
| **Result quality** | High confidence for architecture/process coverage gaps; medium confidence for implementation depth gaps |

---

## Gap Signal Map

| Area | Structural signals |
| --- | --- |
| **Monorepo topology** | `apps/`, `packages/`, `pnpm-workspace.yaml`, `packages/config/` |
| **Release/versioning** | `.changeset/`, `CHANGELOG.md`, `.github/workflows/release.yml`, `docs/planning/versioning-policy.md` |
| **Governance** | `.github/CODEOWNERS`, `.github/branch-protection.main.json`, `scripts/apply-branch-protection.mjs`, `scripts/verify-branch-protection.mjs` |
| **Database lifecycle** | `apps/api/src/db/migrations/`, `apps/api/src/db/schema/current.sql`, `scripts/migration-check-drift.mjs`, `scripts/migration-smoke.mjs` |
| **API contract lifecycle** | `docs/api/openapi.yaml`, `tests/contract/openapi.contract.test.ts`, `scripts/openapi-breaking-check.mjs`, `.spectral.yaml` |
| **DR and recoverability** | `scripts/db-backup.mjs`, `scripts/db-restore.mjs`, `scripts/db-backup-restore-smoke.mjs` |
| **Runbook-driven operations** | `docs/runbooks/*` |
| **Toolchain reproducibility** | `.mise.toml`, `.tool-versions`, `.nvmrc`, `.editorconfig`, `.husky/*` |
| **Test environment realism** | `apps/api/tests/integration/testcontainers.int.test.ts`, `tests/e2e/`, `tests/contract/` |

---

## Gap Backlog

| ID | Work type | Gap topic | Recommendation | Priority |
| --- | --- | --- | --- | --- |
| LG-01 | New guide | Monorepo workspace architecture | Add dedicated guide for workspace boundaries and dependency direction | P1 |
| LG-02 | New guide | Release engineering and versioning | Add dedicated guide for semver, changesets, release workflows | P1 |
| LG-03 | New guide | Repository governance | Add dedicated guide for branch protection, CODEOWNERS, policy-as-code | P1 |
| LG-04 | New guide | Database migrations and drift management | Add dedicated guide for migration safety, drift checks, rollback strategy | P1 |
| LG-05 | New guide | API contract governance | Add dedicated guide for OpenAPI lifecycle, breaking checks, contract tests | P1 |
| LG-06 | New guide | Backup, restore, and DR drills | Add dedicated guide for backup verification and restore readiness | P1 |
| LG-07 | Expansion | Runbook patterns in docs | Expand documentation guidance for runbook structure and operation docs | P2 |
| LG-08 | Expansion | Toolchain reproducibility | Expand tool-configuration guidance for pinned runtimes and local parity | P2 |
| LG-09 | Expansion | Integration test environments | Expand testing strategy and E2E guidance for Testcontainers and env parity | P2 |

---

## Delivery Plan

### New Guides (Create + Index)

| ID | Guide path | Objective | Required H2 sections | Files to modify |
| --- | --- | --- | --- | --- |
| LG-01 | `guides/monorepo-workspaces/monorepo-workspaces.md` | Standardize how to structure and scale multi-package repos without dependency chaos | `## Workspace Topology`; `## Dependency Direction Rules`; `## Package Boundary Contracts`; `## Build and Test Graph Strategy`; `## Good/Bad Layout Examples` | Create guide, update `AGENTS.md`, update `README.md` |
| LG-02 | `guides/release-engineering-versioning/release-engineering-versioning.md` | Define repeatable, low-risk release/versioning workflows | `## Versioning Strategy`; `## Release Pipeline Stages`; `## Changelog Discipline`; `## Rollback and Hotfix Flow`; `## Good/Bad Release Patterns` | Create guide, update `AGENTS.md`, update `README.md` |
| LG-03 | `guides/repository-governance/repository-governance.md` | Define repo control-plane defaults and ownership boundaries | `## Ownership Model`; `## Branch Protection as Code`; `## PR and Issue Governance`; `## Automation and Compliance Checks`; `## Good/Bad Governance Patterns` | Create guide, update `AGENTS.md`, update `README.md` |
| LG-04 | `guides/database-migrations-drift/database-migrations-drift.md` | Prevent schema drift and unsafe migration rollout | `## Migration Lifecycle`; `## Drift Detection and Policy`; `## Rollback and Recovery`; `## CI Smoke Checks`; `## Good/Bad Migration Patterns` | Create guide, update `AGENTS.md`, update `README.md` |
| LG-05 | `guides/api-contract-governance/api-contract-governance.md` | Keep API contract changes explicit, compatible, and test-enforced | `## Contract Source of Truth`; `## Contract Linting`; `## Breaking Change Gates`; `## Consumer Compatibility`; `## Good/Bad Contract Governance` | Create guide, update `AGENTS.md`, update `README.md` |
| LG-06 | `guides/backup-restore-dr/backup-restore-dr.md` | Ensure recoverability is tested and measurable | `## Backup Policy Design`; `## Restore Drill Workflow`; `## RPO/RTO Targets`; `## Verification Automation`; `## Good/Bad DR Practices` | Create guide, update `AGENTS.md`, update `README.md` |

### Existing Guide Expansions

| ID | Existing guide path(s) | Objective | Required additions | Files to modify |
| --- | --- | --- | --- | --- |
| LG-07 | `guides/documentation-guidelines/documentation-guidelines.md` | Make runbooks first-class documentation artifacts | Add sections for runbook templates, operational ownership, and update cadence | Update guide only |
| LG-08 | `guides/tool-configuration/tool-configuration.md` | Encode modern reproducibility patterns for local/CI parity | Add sections for runtime pinning, toolchain manifests, pre-commit orchestration, and failure modes | Update guide only |
| LG-09 | `guides/testing-strategy/testing-strategy.md`; `guides/e2e-testing/e2e-testing.md` | Cover contract/integration environment realism beyond unit/E2E basics | Add sections for Testcontainers usage, environment matrix, contract test placement, and flaky-environment triage | Update both guides only |

---

## Index Edit Plan (Exact Rows)

Use these exact rows when each new guide is added.

### AGENTS.md (`## Guide Index` → `### Coding Foundations`)

| ID | Snippet label |
| --- | --- |
| LG-01 | `AGENTS-LG-01` |
| LG-02 | `AGENTS-LG-02` |
| LG-03 | `AGENTS-LG-03` |
| LG-04 | `AGENTS-LG-04` |
| LG-05 | `AGENTS-LG-05` |
| LG-06 | `AGENTS-LG-06` |

```md
AGENTS-LG-01
| [Monorepo Workspaces](guides/monorepo-workspaces/monorepo-workspaces.md) | Workspace boundaries, package ownership, dependency direction |
AGENTS-LG-02
| [Release Engineering & Versioning](guides/release-engineering-versioning/release-engineering-versioning.md) | SemVer, release pipelines, changelog discipline |
AGENTS-LG-03
| [Repository Governance](guides/repository-governance/repository-governance.md) | CODEOWNERS, branch protection, policy-as-code |
AGENTS-LG-04
| [Database Migrations & Drift](guides/database-migrations-drift/database-migrations-drift.md) | Migration lifecycle, drift checks, rollback safety |
AGENTS-LG-05
| [API Contract Governance](guides/api-contract-governance/api-contract-governance.md) | OpenAPI lifecycle, breaking-change gates, contract tests |
AGENTS-LG-06
| [Backup, Restore & DR](guides/backup-restore-dr/backup-restore-dr.md) | Backup verification, restore drills, RPO/RTO readiness |
```

### README.md (`## Contents` → `### Coding Foundations`)

| ID | Snippet label |
| --- | --- |
| LG-01 | `README-LG-01` |
| LG-02 | `README-LG-02` |
| LG-03 | `README-LG-03` |
| LG-04 | `README-LG-04` |
| LG-05 | `README-LG-05` |
| LG-06 | `README-LG-06` |

```md
README-LG-01
| [Monorepo Workspaces](guides/monorepo-workspaces/monorepo-workspaces.md) | Workspace boundaries, package ownership, and dependency direction. |
README-LG-02
| [Release Engineering & Versioning](guides/release-engineering-versioning/release-engineering-versioning.md) | SemVer policy, release orchestration, and changelog quality. |
README-LG-03
| [Repository Governance](guides/repository-governance/repository-governance.md) | CODEOWNERS, branch protections, and policy-as-code controls. |
README-LG-04
| [Database Migrations & Drift](guides/database-migrations-drift/database-migrations-drift.md) | Migration safety, schema drift detection, and rollback strategy. |
README-LG-05
| [API Contract Governance](guides/api-contract-governance/api-contract-governance.md) | OpenAPI governance, compatibility gates, and contract testing. |
README-LG-06
| [Backup, Restore & DR](guides/backup-restore-dr/backup-restore-dr.md) | Data recoverability, restore drills, and RPO/RTO operations. |
```

---

## Milestones

| Milestone | Scope | Exit criteria | Status |
| --- | --- | --- | --- |
| M1 | LG-01, LG-02, LG-03 | Three guides merged, indexes updated, `npm run validate` passes | Completed |
| M2 | LG-04, LG-05, LG-06 | Three guides merged, indexes updated, `npm run validate` passes | Completed |
| M3 | LG-07, LG-08, LG-09 | Expansions merged with cross-links and examples, `npm run validate` passes | Completed |
| M4 | Cross-guide harmonization | Shared terminology and links normalized across all touched guides | Completed |

---

## Acceptance and Validation

| Check | Command | Expected result |
| --- | --- | --- |
| Markdown quality | `npm run lint:md` | No lint violations |
| Navigation integrity | `npm run validate` | No missing index links or broken guide references |
| Coverage traceability | Manual check against LG-01..LG-09 | Every backlog item mapped to merged docs |

| Deliverable quality bar | Requirement |
| --- | --- |
| Every new guide | Includes concrete Good/Bad examples |
| Every new/expanded guide | Uses tables-first structure and scannable sections |
| Navigation updates | `AGENTS.md` and `README.md` updated in same PR as each new guide |

---

## Risks and Mitigations

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Scope overreach in one PR | Slow reviews and low merge velocity | Execute by milestone and keep PRs bounded to 1-2 backlog items |
| Inconsistent terminology across new guides | Reader confusion and duplicate concepts | Add harmonization pass (M4) plus explicit cross-links |
| Navigation drift after partial merges | Broken discoverability | Treat index updates as required checklist item per LG-01..LG-06 |
| Prioritization conflict with pilot work | Roadmap churn | Keep this plan active in `roadmap.md`; re-order milestones without changing scoped outcomes |
