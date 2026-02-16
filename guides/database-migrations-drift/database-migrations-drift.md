# Database Migrations & Drift

Best practices for evolving schemas safely while detecting drift early and preserving rollback options.

> **Scope**: Migration authoring, schema drift checks, rollback planning, and CI smoke validation for relational databases.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Migration Lifecycle](#migration-lifecycle) |
| [Drift Detection and Policy](#drift-detection-and-policy) |
| [Rollback and Recovery](#rollback-and-recovery) |
| [CI Smoke Checks](#ci-smoke-checks) |
| [Good/Bad Migration Patterns](#goodbad-migration-patterns) |
| [Anti-Patterns](#anti-patterns) |
| [Red Flags](#red-flags) |

---

## Quick Reference

| Category | Guidance | Rationale |
| --- | --- | --- |
| **Design** | Create additive migrations before destructive ones | Reduces breakage during rollout |
| **Repeatability** | Treat migration files as immutable once merged | Preserves deterministic environments |
| **Drift** | Compare live schema against expected snapshot in CI | Detects manual or out-of-band changes |
| **Rollback** | Document reverse strategy per migration | Shortens incident response |
| **Validation** | Run migrate + smoke + rollback drills in automation | Proves real operability |

---

## Core Principles

| Principle | Guideline | Rationale |
| --- | --- | --- |
| **Forward-safe first** | Prefer additive, backwards-compatible changes | Supports phased application rollout |
| **Schema as artifact** | Keep canonical schema snapshot under version control | Makes diff and drift explicit |
| **Operational readiness** | Every migration has execution and recovery plan | DDL changes are production operations |
| **Test like production** | Validate migrations against realistic engine versions | Prevents environment-specific failures |

---

## Migration Lifecycle

| Phase | Required activity | Exit criteria |
| --- | --- | --- |
| `design` | Assess compatibility and lock impact | Rollout + rollback documented |
| `author` | Write migration and update schema snapshot | Migration deterministic locally |
| `verify` | Run migration tests on clean and current DB states | Both paths pass |
| `deploy` | Apply via controlled release process | Post-deploy checks healthy |
| `stabilize` | Monitor errors/perf and close migration task | No regressions in observation window |

| Change type | Preferred sequence |
| --- | --- |
| Add required column | Add nullable + backfill + enforce not null later |
| Rename column | Add new column + dual-write/read + remove old later |
| Drop column/table | Mark deprecated + verify no callers + drop in later release |

---

## Drift Detection and Policy

| Drift source | Detection method | Policy response |
| --- | --- | --- |
| Manual DB change | Schema diff check in CI | Block merge until reconciled |
| Migration file edited post-merge | Hash/integrity check | Reject and create new migration |
| Snapshot mismatch | Compare generated vs committed schema | Fail CI and update via reviewed workflow |

```bash
# Good: automated drift gate
npm run migration:check-drift
```

```bash
# Bad: no drift check before deploy
npm run deploy
```

| Drift policy rule | Requirement |
| --- | --- |
| Production hotfix to DB | Must be followed by migration file in next commit |
| Snapshot update | Must happen through dedicated script + review |
| Drift suppression | Time-boxed exception and linked incident |

---

## Rollback and Recovery

| Failure mode | Preferred recovery |
| --- | --- |
| App-level incompatibility | Roll back app while keeping additive schema |
| Data corruption during migration | Restore from backup + replay safe operations |
| Blocking DDL impact | Abort deployment and apply safer phased migration |

| Rollback requirement | Guidance |
| --- | --- |
| Reversible migration | Include explicit down migration or documented fallback |
| Data migrations | Keep idempotent scripts and checkpointing |
| Destructive changes | Require verified backup and restore drill before release |

```sql
-- Good: additive and reversible pattern
ALTER TABLE users ADD COLUMN display_name TEXT;
-- backfill in controlled batch job
```

```sql
-- Bad: destructive one-step migration
ALTER TABLE users DROP COLUMN name;
```

---

## CI Smoke Checks

| Check | Purpose | Typical trigger |
| --- | --- | --- |
| Fresh DB migrate | Ensure new environments can bootstrap | Pull request |
| Existing DB migrate | Verify upgrade path from previous schema | Pull request |
| App startup against migrated DB | Catch contract breakage | Pull request |
| Optional rollback smoke | Validate recovery script viability | Nightly/release |

```yaml
steps:
  - run: npm run db:migrate:fresh
  - run: npm run db:migrate:upgrade
  - run: npm run test:integration:db
```

---

## Good/Bad Migration Patterns

| Pattern | Good | Bad |
| --- | --- | --- |
| File handling | Append new migration file | Edit old applied migration |
| Schema evolution | Expand/contract pattern | Big-bang destructive change |
| Testing | CI checks clean + upgraded DB | Manual local-only checks |
| Recovery | Runbooked restore and rollback steps | "We'll figure it out during incident" |

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| --- | --- | --- |
| Force-editing old migrations | Breaks deterministic history | Add new corrective migration |
| Coupling app change to immediate destructive DDL | Requires lockstep deploy | Use phased compatibility windows |
| No schema snapshot in repo | Drift remains invisible | Commit canonical schema artifact |
| Migration scripts without runtime bounds | Long locks and outages | Use batching and lock-time budgeting |

---

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| Migration passes locally but fails in CI containerized DB | Align local and CI engine/version; rerun verification | Environment mismatch hides production risks |
| Production schema differs from repo snapshot | Freeze related releases and reconcile drift | Unknown schema state invalidates assumptions |
| Destructive migration proposed without verified backup | Block change until backup/restore drill passes | No safe recovery path |

---

## See Also

- [Database Indexing](../database-indexing/database-indexing.md)
- [Deployment Strategies](../deployment-strategies/deployment-strategies.md)
- [Resilience Patterns](../resilience-patterns/resilience-patterns.md)
- [Backup, Restore & DR](../backup-restore-dr/backup-restore-dr.md)
- [Release Engineering & Versioning](../release-engineering-versioning/release-engineering-versioning.md)
