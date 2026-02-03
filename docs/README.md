# Project Docs

Internal documentation for maintaining `agentic-best-practices` (process, plans, templates, and ADRs).

## Index

| Doc | Type | Status | Primary use |
| --- | --- | --- | --- |
| `docs/plans/implementation-plan.md` | Plan | Active | How we choose and execute work (phases, validation, risks). |
| `docs/process/release-process.md` | Process | Active | How we ship changes safely (tagging, notes, rollback). |
| `docs/process/roadmap-process.md` | Process | Active | How we maintain the `README.md` roadmap. |
| `docs/templates/feedback-template.md` | Template | Active | How adopters report gaps/conflicts quickly and consistently. |
| `docs/rubrics/triage-rubric.md` | Rubric | Active | How we classify and resolve feedback with minimal human time. |
| `docs/adr/adr-001-validation-and-ci.md` | ADR | Active | Why validation + CI are treated as the primary “test suite”. |
| `docs/reference/references.md` | Reference | Active | External sources (human readers only). |
| `docs/archive/phase-1-pr-split.md` | Execution note | Archived | Historical “how we split big diffs into reviewable PRs”. |
| `docs/archive/phase-1-ship-revert-summary.md` | Execution note | Archived | Historical “ship vs hold” checklist for Phase 1. |

## Directories

| Directory | What it contains |
| --- | --- |
| `docs/adr/` | Architecture Decision Records |
| `docs/plans/` | Implementation plans and execution planning |
| `docs/process/` | Ongoing process docs (release, roadmap maintenance) |
| `docs/templates/` | Copy-paste templates |
| `docs/rubrics/` | Rubrics for triage/decision-making |
| `docs/reference/` | External references for human readers |
| `docs/archive/` | Historical notes kept for traceability |

## Conventions

| Convention | Why |
| --- | --- |
| Keep `docs/` one level deep | Group by type without creating deep nesting. |
| Prefer tables over prose | Faster scanning and easier maintenance. |
| Version docs that define process | Makes changes auditable. |
