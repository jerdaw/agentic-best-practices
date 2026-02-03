# Project Docs

Internal documentation for maintaining `agentic-best-practices` (process, plans, templates, and ADRs).

## Index

| Doc | Type | Status | Primary use |
| --- | --- | --- | --- |
| `docs/implementation-plan.md` | Plan | Active | How we choose and execute work (phases, validation, risks). |
| `docs/release-process.md` | Process | Active | How we ship changes safely (tagging, notes, rollback). |
| `docs/roadmap-process.md` | Process | Active | How we maintain the `README.md` roadmap. |
| `docs/feedback-template.md` | Template | Active | How adopters report gaps/conflicts quickly and consistently. |
| `docs/triage-rubric.md` | Rubric | Active | How we classify and resolve feedback with minimal human time. |
| `docs/adr-001-validation-and-ci.md` | ADR | Active | Why validation + CI are treated as the primary “test suite”. |
| `docs/references.md` | Reference | Active | External sources (human readers only). |
| `docs/phase-1-pr-split.md` | Execution note | Archived | Historical “how we split big diffs into reviewable PRs”. |
| `docs/phase-1-ship-revert-summary.md` | Execution note | Archived | Historical “ship vs hold” checklist for Phase 1. |

## Conventions

| Convention | Why |
| --- | --- |
| Keep `docs/` flat (no subdirectories) | Avoid deep nesting and link drift. |
| Prefer tables over prose | Faster scanning and easier maintenance. |
| Version docs that define process | Makes changes auditable. |
