# Project Docs

Internal documentation for maintaining `agentic-best-practices` (process, plans, templates, and ADRs).

## Index

| Doc | Type | Status | Primary use |
| --- | --- | --- | --- |
| `docs/process/release-process.md` | Process | Active | How we ship changes safely (tagging, notes, rollback). |
| `docs/process/roadmap-process.md` | Process | Active | How we maintain the `README.md` roadmap. |
| `docs/templates/feedback-template.md` | Template | Active | How adopters report gaps/conflicts quickly and consistently. |
| `docs/adr/adr-001-validation-and-ci.md` | ADR | Active | Why validation + CI are treated as the primary “test suite”. |
| `docs/reference/references.md` | Reference | Active | External sources (human readers only). |

## Directories

| Directory | What it contains |
| --- | --- |
| `docs/adr/` | Architecture Decision Records |
| `docs/process/` | Ongoing process docs (release, roadmap maintenance) |
| `docs/templates/` | Copy-paste templates |
| `docs/reference/` | External references for human readers |

## Conventions

| Convention | Why |
| --- | --- |
| Keep `docs/` one level deep | Group by type without creating deep nesting. |
| Prefer tables over prose | Faster scanning and easier maintenance. |
| Version docs that define process | Makes changes auditable. |
