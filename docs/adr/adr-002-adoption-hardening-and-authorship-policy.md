# ADR-002: Adoption Hardening Baseline and Human Authorship Policy

Decision record for finalizing adoption hardening Phase 1-4 and enforcing human-only commit authorship metadata.

| Field | Value |
| --- | --- |
| Status | Accepted |
| Date | 2026-02-08 |
| Owners | Maintainer |
| Supersedes | None |
| Superseded By | None |

## Contents

| Section |
| --- |
| [Context](#context) |
| [Decision](#decision) |
| [Consequences](#consequences) |
| [Alternatives Considered](#alternatives-considered) |
| [Follow-Up](#follow-up) |

---

## Context

| Constraint | Detail |
| --- | --- |
| Adoption consistency | External projects need a predictable bootstrap + validation path |
| Operational readiness | Pilot execution should be repeatable with low setup overhead |
| Roadmap hygiene | Completed plans should be archived to keep active roadmap focused |
| Auditability | Commit metadata should identify accountable human authors |

---

## Decision

| Decision | Outcome |
| --- | --- |
| Adoption hardening baseline | Keep Phase 1-4 capabilities as supported baseline (`adopt`, `merge`, `pin`, `validate`, `pilot prep`) |
| Pilot operations | Standardize pilot rollout using `scripts/prepare-pilot-project.sh` and pilot templates |
| Plan lifecycle | Archive completed implementation plan under `docs/planning/archive/` |
| Git authorship policy | Use human maintainer identity for commit author metadata; do not use tool or assistant identities |

---

## Consequences

| Impact | Result |
| --- | --- |
| Positive | Faster and safer onboarding for external projects |
| Positive | Reduced drift through strict validation and smoke simulation |
| Positive | Clear historical traceability without cluttering active roadmap docs |
| Tradeoff | Pilot repository selection/execution remains human-dependent |

---

## Alternatives Considered

| Alternative | Rejected Because |
| --- | --- |
| Keep hardening plan active indefinitely | Leaves stale “done” detail in active planning docs |
| Manual pilot setup without script/templates | Higher setup variance and missed checks |
| Allow non-human/bot author identities | Reduces accountability and violates maintainership policy |

---

## Follow-Up

| Item | Owner | Status |
| --- | --- | --- |
| Select pilot repositories and run 6-8 week validation | Maintainer + pilot owners | Pending |
| Convert pilot findings into release backlog | Maintainer | Pending |
