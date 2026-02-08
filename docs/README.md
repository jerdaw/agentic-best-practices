# Project Docs

Internal documentation for maintaining `agentic-best-practices` (process, plans, templates, and ADRs).

## Index

| Doc | Type | Status | Primary use |
| --- | --- | --- | --- |
| `docs/process/health-dashboard.md` | Dashboard | Active | Real-time repository health and v1 readiness metrics. |
| `docs/process/pilot-execution-playbook.md` | Process | Active | Step-by-step workflow for running external adoption pilots. |
| `docs/process/release-process.md` | Process | Active | How we ship changes safely (tagging, notes, rollback). |
| `docs/process/roadmap-process.md` | Process | Active | How we maintain the `README.md` roadmap. |
| `docs/process/maintenance-cadence-decision.md` | Decision | Active | Why quarterly + event-driven maintenance. |
| `docs/planning/archive/2026-02-08-adoption-integration-hardening-plan-v0.2.0.md` | Plan | Archived | Completed adoption hardening implementation record (Phase 1-4). |
| `docs/templates/feedback-template.md` | Template | Active | How adopters report gaps/conflicts quickly and consistently. |
| `docs/templates/pilot-kickoff-template.md` | Template | Active | Kickoff checklist and baseline for pilot repositories. |
| `docs/templates/pilot-weekly-checkin-template.md` | Template | Active | Weekly pilot status template for friction and outcomes. |
| `docs/templates/pilot-retrospective-template.md` | Template | Active | End-of-pilot summary and rollout decision template. |
| `docs/adr/adr-001-validation-and-ci.md` | ADR | Active | Why validation + CI are treated as the primary "test suite". |
| `docs/adr/adr-002-adoption-hardening-and-authorship-policy.md` | ADR | Active | Why adoption hardening baseline is fixed and commit authorship remains human-only. |
| `docs/reference/references.md` | Reference | Active | External sources (human readers only). |

## Directories

| Directory | What it contains |
| --- | --- |
| `docs/adr/` | Architecture Decision Records |
| `docs/process/` | Ongoing process docs (health dashboard, release, maintenance) |
| `docs/templates/` | Copy-paste templates |
| `docs/reference/` | External references for human readers |
| `docs/planning/` | Active planning documents (roadmaps, proposals) |
| `docs/planning/archive/` | Historical planning docs and decisions |

## Conventions

| Convention | Why |
| --- | --- |
| Keep `docs/` one level deep | Group by type without creating deep nesting. |
| Prefer tables over prose | Faster scanning and easier maintenance. |
| Version docs that define process | Makes changes auditable. |
