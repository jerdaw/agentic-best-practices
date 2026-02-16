# Backup, Restore & Disaster Recovery

Best practices for ensuring data recoverability through verified backups, tested restores, and explicit RPO/RTO targets.

> **Scope**: Backup policy design, restore drills, DR readiness checks, and operational automation patterns.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Backup Policy Design](#backup-policy-design) |
| [Restore Drill Workflow](#restore-drill-workflow) |
| [RPO/RTO Targets](#rporto-targets) |
| [Verification Automation](#verification-automation) |
| [Good/Bad DR Practices](#goodbad-dr-practices) |
| [Anti-Patterns](#anti-patterns) |
| [Red Flags](#red-flags) |

---

## Quick Reference

| Category | Guidance | Rationale |
| --- | --- | --- |
| **Policy** | Define backup frequency/retention by data criticality | Matches cost to business risk |
| **Recovery** | Test restores on schedule, not just backup creation | Backup success != recoverability |
| **Targets** | Set explicit RPO/RTO per service tier | Guides incident decisions |
| **Isolation** | Store backups in separate fault domain/account | Protects from correlated failures |
| **Automation** | Alert on backup/restore failures immediately | Shortens recovery gap |

---

## Core Principles

| Principle | Guideline | Rationale |
| --- | --- | --- |
| **Recoverability over backup count** | Measure restore success and time | Business impact is about restoration |
| **Tiered protection** | Stronger controls for higher-critical data | Avoids one-size-fits-none policy |
| **Operational rehearsal** | Run tabletop + technical drills | Team readiness is part of DR |
| **Secure by default** | Encrypt backups and limit access | Backups contain high-value data |

---

## Backup Policy Design

| Policy element | Requirement | Example |
| --- | --- | --- |
| Data classification | Tier systems by criticality | `Tier 0` payments, `Tier 2` analytics cache |
| Backup cadence | Define full/incremental schedules | Full daily + incremental hourly |
| Retention | Keep short/long retention windows | 30 days hot, 90 days cold |
| Security | Encryption + access controls | KMS-managed encryption, least privilege |
| Integrity checks | Verify snapshot integrity | Periodic checksum validation |

| Data tier | Suggested baseline | Notes |
| --- | --- | --- |
| Tier 0 | Hourly backup, cross-region copy | Strict RPO requirements |
| Tier 1 | 4-6 hour backup cadence | Important but not existential |
| Tier 2 | Daily backup | Lower business criticality |

---

## Restore Drill Workflow

| Step | Action | Evidence |
| --- | --- | --- |
| `prepare` | Select backup set and define success criteria | Drill plan record |
| `restore` | Restore to isolated environment | Restore logs |
| `validate` | Run data integrity + app smoke checks | Validation report |
| `measure` | Capture elapsed time vs RTO | Drill metrics |
| `improve` | Record gaps and remediation tasks | Follow-up issue(s) |

```bash
# Good: recurring restore smoke drill
npm run db:backup-restore-smoke
```

```bash
# Bad: backup created but never restore-tested
npm run db:backup
```

| Drill frequency | Recommendation |
| --- | --- |
| Tier 0 systems | Monthly technical drill + quarterly game day |
| Tier 1 systems | Quarterly technical drill |
| Tier 2 systems | Semiannual validation |

---

## RPO/RTO Targets

| Metric | Definition | Example |
| --- | --- | --- |
| RPO | Maximum acceptable data loss window | 15 minutes |
| RTO | Maximum acceptable service restoration time | 60 minutes |

| Service class | RPO | RTO |
| --- | --- | --- |
| Customer-facing transactional | <= 15m | <= 1h |
| Internal operations tooling | <= 4h | <= 8h |
| Reporting/analytics | <= 24h | <= 24h |

| Decision rule | Action |
| --- | --- |
| Current drill exceeds target | Open prioritized remediation and rerun drill |
| No target defined | Do not declare DR-ready |

---

## Verification Automation

| Automation check | Trigger | Failure response |
| --- | --- | --- |
| Backup job health | Scheduled | Page on-call for tiered critical systems |
| Backup artifact validation | Post-backup | Mark backup unusable and retry |
| Restore smoke test | Scheduled/nightly/release | Block release for critical data paths |
| DR metric reporting | Weekly | Escalate if targets violated |

```yaml
name: dr-verification
on:
  schedule:
    - cron: '0 3 * * *'
jobs:
  verify:
    steps:
      - run: npm run db:backup
      - run: npm run db:backup-restore-smoke
```

---

## Good/Bad DR Practices

| Area | Good | Bad |
| --- | --- | --- |
| Backup confidence | Verified restore success | Assuming backup job success means safe |
| Access control | Encrypted and restricted backups | Broad read access to backup storage |
| Targets | RPO/RTO documented and measured | No explicit recovery targets |
| Incident readiness | Runbooked response and drills | Ad hoc recovery steps |

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| --- | --- | --- |
| Backups never restore-tested | False confidence | Schedule recurring restore drills |
| Backup storage in same blast radius | Correlated failure risk | Use cross-region/account storage |
| DR runbook not versioned | Stale/unknown recovery steps | Keep runbook in repo with review |
| "Best effort" RPO/RTO | No objective decision-making | Set explicit service-tier targets |

---

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| Last successful restore drill is older than one quarter | Schedule immediate drill and remediation review | DR confidence decays quickly without rehearsal |
| Backup job succeeds but integrity check fails | Treat as failed backup and escalate | Corrupt backups are unusable |
| Recovery time exceeds stated RTO in two drills | Prioritize architectural remediation | Current design cannot meet continuity goals |

---

## See Also

- [Resilience Patterns](../resilience-patterns/resilience-patterns.md)
- [Secrets & Configuration](../secrets-configuration/secrets-configuration.md)
- [Deployment Strategies](../deployment-strategies/deployment-strategies.md)
- [Database Migrations & Drift](../database-migrations-drift/database-migrations-drift.md)
- [Release Engineering & Versioning](../release-engineering-versioning/release-engineering-versioning.md)
