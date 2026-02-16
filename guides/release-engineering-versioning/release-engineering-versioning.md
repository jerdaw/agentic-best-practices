# Release Engineering & Versioning

Best practices for shipping predictable releases with clear version semantics, changelogs, and rollback readiness.

> **Scope**: SemVer policy, release pipelines, changelog discipline, and hotfix/rollback workflows for libraries and services.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Versioning Strategy](#versioning-strategy) |
| [Release Pipeline Stages](#release-pipeline-stages) |
| [Changelog Discipline](#changelog-discipline) |
| [Rollback and Hotfix Flow](#rollback-and-hotfix-flow) |
| [Good/Bad Release Patterns](#goodbad-release-patterns) |
| [Anti-Patterns](#anti-patterns) |
| [Red Flags](#red-flags) |

---

## Quick Reference

| Category | Guidance | Rationale |
| --- | --- | --- |
| **Versioning** | Use SemVer with explicit breaking/non-breaking classification | Makes compatibility expectations testable |
| **Automation** | Build release from CI, not developer laptops | Improves repeatability and auditability |
| **Validation** | Gate release on full test + contract checks | Prevents shipping invalid artifacts |
| **Changelog** | Tie every release note to user-visible impact | Keeps changelog actionable |
| **Rollback** | Maintain documented rollback path before each release | Reduces incident recovery time |

---

## Core Principles

| Principle | Guideline | Rationale |
| --- | --- | --- |
| **Deterministic release** | Same git SHA produces same artifact | Prevents "works on my machine" releases |
| **Contract safety** | Breaking changes require explicit major bump | Protects downstream consumers |
| **Traceability** | Every release links commit range, notes, and artifacts | Supports incident forensics |
| **Fast recovery** | Hotfix and rollback paths are rehearsed | Production failures need predictable response |

---

## Versioning Strategy

| Change type | Version bump | Example |
| --- | --- | --- |
| New backward-compatible feature | Minor (`1.4.0` -> `1.5.0`) | Added optional API field |
| Backward-compatible fix | Patch (`1.4.2` -> `1.4.3`) | Corrected validation bug |
| Breaking API/behavior change | Major (`1.x` -> `2.0.0`) | Removed endpoint/renamed required field |

| Rule | Enforcement pattern |
| --- | --- |
| Breaking changes need justification | PR template section + release reviewer signoff |
| Public packages align with SemVer | Auto-version tooling (e.g., changesets) |
| Pre-1.0 projects still classify breakage | Mark as breaking in changelog even if major policy differs |

---

## Release Pipeline Stages

| Stage | Required checks | Exit criteria |
| --- | --- | --- |
| `prepare` | Lint, typecheck, unit tests | Clean build inputs |
| `verify` | Integration/contract/security scans | No blocking failures |
| `build` | Reproducible artifact creation | Checksums and metadata captured |
| `publish/deploy` | Registry publish or environment deploy | Artifact available and tagged |
| `post-release` | Smoke checks, release notes publication | Release marked healthy |

```yaml
# Good: release runs from tagged CI workflow
on:
  push:
    tags:
      - 'v*'
jobs:
  release:
    steps:
      - run: npm ci
      - run: npm test
      - run: npm run build
      - run: npm run publish
```

```yaml
# Bad: release script with no validation gates
jobs:
  release:
    steps:
      - run: npm run publish
```

---

## Changelog Discipline

| Rule | Good | Bad |
| --- | --- | --- |
| Describe user impact | "Added pagination cursor support" | "Updated service" |
| Classify by change type | `Added`, `Changed`, `Fixed`, `Security` | Unstructured list |
| Link to source | PR/issue links per item | No references |
| Mark breaking changes | Explicit migration note | Hidden incompatibility |

```md
## [2.0.0] - 2026-02-16

### Changed
- Replaced `statusText` with enum `status` in API responses. **Breaking**.

### Migration
- Update consumers to map old string values to enum.
```

---

## Rollback and Hotfix Flow

| Scenario | Response | Time target |
| --- | --- | --- |
| Deployment failure | Roll back to last healthy artifact | < 15 minutes |
| Data-compatible bug | Ship patch hotfix | < 2 hours |
| Data migration issue | Stop rollout + execute runbooked restore path | Incident-dependent |

| Hotfix step | Requirement |
| --- | --- |
| Branching | `hotfix/<issue-id>` from latest release tag |
| Validation | Full targeted tests + smoke tests |
| Release | Patch bump only unless contract break introduced |
| Documentation | Add incident note and changelog entry |

---

## Good/Bad Release Patterns

| Pattern | Good practice | Bad practice |
| --- | --- | --- |
| Tagging | Immutable version tags (`v1.2.3`) | Retagging old versions |
| Approvals | Mandatory code/release approval | Single-person release bypass |
| Artifact provenance | Signed/published with metadata | Build provenance unavailable |
| Rollback drills | Quarterly rehearsal | Untested rollback scripts |

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| --- | --- | --- |
| Manual release from local machine | Non-reproducible output | CI-driven release only |
| Breaking changes in patch/minor | Silent client breakage | Enforce SemVer gates |
| Release notes after deploy | Lost context and accuracy | Generate changelog during release prep |
| No post-release smoke checks | Failures discovered late | Add mandatory post-release checks |

---

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| Version bump and changelog disagree | Block release and reconcile | Version policy must match documented impact |
| Rollback path not documented for current release | Stop rollout until documented | Recovery readiness is a release prerequisite |
| Hotfix process bypasses tests | Require emergency gate checklist | Speed without validation creates repeat incidents |

---

## See Also

- [Deployment Strategies](../deployment-strategies/deployment-strategies.md)
- [CI/CD Pipelines](../cicd-pipelines/cicd-pipelines.md)
- [Supply Chain Security](../supply-chain-security/supply-chain-security.md)
- [Repository Governance](../repository-governance/repository-governance.md)
- [Backup, Restore & DR](../backup-restore-dr/backup-restore-dr.md)
