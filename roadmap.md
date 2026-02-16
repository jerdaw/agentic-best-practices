# Roadmap

Execution roadmap for current implementation work. Canonical product roadmap remains in `README.md`.

| Field | Value |
| --- | --- |
| **Status** | Active |
| **Last Updated** | 2026-02-16 |
| **Current Focus** | External pilot selection and pilot execution readiness |

## Contents

| Section |
| --- |
| [Current Workstream](#current-workstream) |
| [Human-Led Track](#human-led-track) |
| [Active Milestones](#active-milestones) |
| [Next Action](#next-action) |

---

## Current Workstream

| Workstream | Goal | Status |
| --- | --- | --- |
| Adoption customization hardening | Make downstream incorporation easier to customize with repeatable config-driven flow, stack-aware defaults, human-led pilot execution gates, and evidence handoff automation | ✅ Phase 4 complete |
| Agent concepts taxonomy | Define and document the 8 core agent concepts (Prompt Files, Memory, Custom Agents, etc.) with new guides and ADR 004 | ✅ Complete |
| External validation | Validate standards and workflows in 1-2 real repositories | Blocked on pilot repo selection |

Completed implementation details are archived in:

- `docs/planning/archive/2026-02-08-adoption-integration-hardening-plan-v0.2.0.md`
- `docs/planning/archive/2026-02-08-adoption-customization-hardening-plan-v0.3.0.md`
- `docs/planning/archive/2026-02-16-guide-coverage-expansion-roadmap.md`

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

---

## Next Action

| Priority | Action | Owner | Status |
| --- | --- | --- | --- |
| 1 | Select pilot repositories with explicit team commitment | Human maintainer | 🔴 Pending |
| 2 | Execute 6-8 week pilot with generated artifacts | Human maintainer + pilot owners | 🔴 Pending |
| 3 | Convert pilot findings into guide/script backlog and releases | Human maintainer + contributors | 🔴 Pending |
