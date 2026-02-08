# ADR-003: Pilot Evidence Handoff and Human-Owned External Validation

Decision record for standardizing pilot evidence consolidation while keeping repository selection/execution human-owned.

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
| External validation dependency | Pilot repo selection and execution require explicit human owners and consent |
| Handoff friction | Weekly pilot artifacts can be scattered and hard to convert into release backlog inputs |
| Roadmap clarity | Human-owned steps must remain explicit and visible in active roadmap tracking |
| Quality assurance | Pilot artifacts should be validated consistently before rollout decisions |

---

## Decision

| Decision | Outcome |
| --- | --- |
| Add pilot readiness gate | Use `scripts/check-pilot-readiness.sh` for setup/cadence/retrospective checks |
| Add pilot findings summary workflow | Use `scripts/summarize-pilot-findings.sh` to generate `pilot-summary.md` for backlog intake |
| Keep human-owned pilot lifecycle explicit | Track selection, execution, close-out, and backlog conversion in `roadmap.md` Human-Led Track |
| Keep validation automated in repo | Include readiness and summary paths in adoption smoke simulation |

---

## Consequences

| Impact | Result |
| --- | --- |
| Positive | Pilot evidence is consolidated into a repeatable summary format for release planning |
| Positive | Human-owned decisions remain explicit and auditable in roadmap/process docs |
| Positive | Readiness and summary workflows are tested alongside other adoption scenarios |
| Tradeoff | External pilot execution still depends on human availability and org priorities |

---

## Alternatives Considered

| Alternative | Rejected Because |
| --- | --- |
| Keep pilot evidence collection fully manual | Creates inconsistency and slows backlog conversion |
| Attempt full automation of pilot execution decisions | Conflicts with ownership/consent requirements for external repositories |
| Keep completed implementation detail in active roadmap | Increases noise and reduces focus on pending work |

---

## Follow-Up

| Item | Owner | Status |
| --- | --- | --- |
| Select pilot repositories and start first external run | Human maintainer | Pending |
| Run weekly cadence and generate findings summaries | Human maintainer + pilot owners | Pending |
| Convert validated findings into release backlog updates | Human maintainer + contributors | Pending |
