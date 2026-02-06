# Project Docs

Internal documentation for maintaining `agentic-best-practices` (process, plans, templates, and ADRs).

## Index

| Doc | Type | Status | Primary use |
| --- | --- | --- | --- |
| `docs/process/health-dashboard.md` | Dashboard | Active | Real-time repository health and v1 readiness metrics. |
| `docs/process/release-process.md` | Process | Active | How we ship changes safely (tagging, notes, rollback). |
| `docs/process/roadmap-process.md` | Process | Active | How we maintain the `README.md` roadmap. |
| `docs/process/maintenance-cadence-decision.md` | Decision | Active | Why quarterly + event-driven maintenance. |
| `docs/templates/feedback-template.md` | Template | Active | How adopters report gaps/conflicts quickly and consistently. |
| `docs/adr/adr-001-validation-and-ci.md` | ADR | Active | Why validation + CI are treated as the primary "test suite". |
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
