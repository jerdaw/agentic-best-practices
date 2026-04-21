# Roadmap

Execution roadmap for current implementation work. Canonical product roadmap remains in `README.md`.

| Field | Value |
| --- | --- |
| **Status** | Active |
| **Last Updated** | 2026-04-20 |
| **Current Focus** | Pilot selection, external validation, and Tier 4 backlog triage |

## Contents

| Section |
| --- |
| [Current Workstream](#current-workstream) |
| [Guide Coverage Expansion — Phase 2](#guide-coverage-expansion--phase-2) |
| [Human-Led Track](#human-led-track) |
| [Active Milestones](#active-milestones) |
| [Next Action](#next-action) |

---

## Current Workstream

| Workstream | Goal | Status |
| --- | --- | --- |
| External validation | Validate standards and workflows in 1-2 real repositories | 🔴 Blocked on pilot repo selection |
| Tier 4 backlog triage | Evaluate specialized topics after pilot evidence and real-world feedback | 🟡 Planned |

Completed implementation details are archived in:

- `docs/planning/archive/2026-02-08-adoption-integration-hardening-plan-v0.2.0.md`
- `docs/planning/archive/2026-02-08-adoption-customization-hardening-plan-v0.3.0.md`
- `docs/planning/archive/2026-02-16-guide-coverage-expansion-roadmap.md`
- `docs/planning/archive/2026-02-26-tier1-guide-coverage-expansion.md`
- `docs/planning/archive/2026-04-20-phase2-tier2-tier3-guide-expansion.md`

---

## Guide Coverage Expansion — Phase 2

Gaps identified through a comprehensive audit on 2026-02-26. Tiers 1-3 (GE-01 through GE-14) are complete — see [Tier 1 archive](docs/planning/archive/2026-02-26-tier1-guide-coverage-expansion.md) and [Tier 2-3 archive](docs/planning/archive/2026-04-20-phase2-tier2-tier3-guide-expansion.md).

### Tier 4 — Worth Considering (valuable but specialized)

| ID | Topic | Rationale | Status |
| --- | --- | --- | --- |
| GE-15 | MCP & Tool Integration Patterns | Tool Configuration covers IDE setup but not MCP server configuration, custom tool creation, or tool ecosystem management. Could expand existing guide. | 🔴 Not started |
| GE-16 | Queue & Background Job Patterns | Async processing, job scheduling, dead letter queues, idempotent consumers. Adjacent to Idempotency and Resilience guides. | 🔴 Not started |
| GE-17 | Feature Flag Lifecycle | Deployment Strategies mentions flags but doesn't cover full lifecycle: creation, targeting, stale flag debt, flag-driven testing. | 🔴 Not started |
| GE-18 | Infrastructure as Code | Terraform/Pulumi patterns, drift detection, state management. Adjacent to Deployment Strategies but distinct discipline. | 🔴 Not started |

---

## Human-Led Track

These actions require human owners and cannot be completed autonomously from this repository.

| Item | Owner | Status | How to Execute |
| --- | --- | --- | --- |
| Select 1-2 pilot repositories with explicit owner commitment | Human maintainer | 🔴 Pending | Apply `docs/planning/pilot-repo-selection.md` and record selected repos/owners in pilot kickoff files. |
| Kick off pilot repositories with generated artifacts | Human maintainer + pilot owners | 🔴 Pending | Run `scripts/prepare-pilot-project.sh`, then run `scripts/check-pilot-readiness.sh --min-weekly-checkins 0 --strict`. |
| Run weekly pilot cadence for 6-8 weeks | Pilot owners | 🔴 Pending | Create `weekly-01.md`, `weekly-02.md`, ... from template and keep readiness check passing. |
| Generate consolidated pilot findings summaries before close-out | Human maintainer + pilot owners | 🔴 Pending | Run `scripts/summarize-pilot-findings.sh` and attach `pilot-summary.md` to rollout decision review. |
| Close pilot with retrospective and decision record | Human maintainer + pilot owners | 🔴 Pending | Complete retrospective and run readiness check with `--require-retrospective`. |
| Convert pilot findings into prioritized implementation backlog | Human maintainer + contributors | 🔴 Pending | File issues using `docs/templates/feedback-template.md` and map to release milestones. |

---

## Active Milestones

| Milestone | Status |
| --- | --- |
| Select 1-2 pilot repositories with explicit team commitment | 🔴 Blocked |
| Complete 6-8 week pilot run with weekly check-ins | 🟡 Planned |
| Convert pilot outcomes into release backlog | 🟡 Planned |
| Triage Tier 4 specialized backlog after pilot evidence | 🟡 Planned |

---

## Next Action

| Priority | Action | Owner | Status |
| --- | --- | --- | --- |
| 1 | Select pilot repositories with explicit team commitment | Human maintainer | 🔴 Pending |
| 2 | Execute 6-8 week pilot with generated artifacts | Human maintainer + pilot owners | 🔴 Pending |
| 3 | Convert pilot findings into guide/script backlog and releases | Human maintainer + contributors | 🔴 Pending |
| 4 | Triage Tier 4 topics (GE-15 through GE-18) using pilot evidence | Agent + human review | 🟡 Planned |
