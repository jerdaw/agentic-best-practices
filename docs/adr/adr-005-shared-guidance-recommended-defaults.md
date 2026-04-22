# ADR-005: Shared Guidance as Recommended Defaults

Decision record for the onboarding stance of `agentic-best-practices`.

| Field | Value |
| --- | --- |
| Status | Accepted |
| Date | 2026-04-22 |
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
| Overreach risk | Adoption language can accidentally imply that every project should adopt the same patterns unchanged |
| Project fit | Repositories differ in risk profile, architecture, team process, and operational needs |
| Auditability | Project-specific choices should remain explicit and reviewable |
| Backward compatibility | Existing adopters may still use older `DEVIATION_POLICY` configuration |

---

## Decision

| Decision | Outcome |
| --- | --- |
| Onboarding posture | Treat repo guidance as prima facie good defaults, not universal mandates |
| Project autonomy | Each project may adopt the defaults, adopt a modified version, or decline specific pieces with rationale |
| Template wording | Use `Decision policy` language in generated `AGENTS.md` files |
| Config interface | Prefer `DECISION_POLICY`; continue accepting legacy `DEVIATION_POLICY` for compatibility |
| Project records | Capture intentional changes or omissions in `Project-Specific Overrides` |

---

## Consequences

| Impact | Result |
| --- | --- |
| Positive | Adoption is more credible because it leaves room for justified project-specific choices |
| Positive | Projects can make objective decisions without pretending all defaults fit equally well |
| Positive | Differences remain visible through documented rationale instead of silent drift |
| Tradeoff | Cross-repo uniformity becomes a recommendation rather than an implicit command |

---

## Alternatives Considered

| Alternative | Rejected Because |
| --- | --- |
| Treat every guide as mandatory for adopters | Overstates confidence and ignores legitimate project constraints |
| Leave posture implicit in scattered docs | Makes adoption tone inconsistent and invites drift in templates/scripts |
| Break compatibility by renaming config without fallback | Creates avoidable friction for existing adopters |

---

## Follow-Up

| Item | Owner | Status |
| --- | --- | --- |
| Keep onboarding docs, templates, and scripts aligned on `Decision policy` wording | Maintainer | Complete |
| Preserve backward compatibility for older adoption configs | Maintainer | Complete |
| Validate posture against real pilot feedback | Maintainer + pilot owners | Pending |
