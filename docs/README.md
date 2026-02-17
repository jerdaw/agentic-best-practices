# Project Docs

Internal documentation for maintaining `agentic-best-practices` (process, plans, templates, and ADRs).

## Index

| Doc | Type | Status | Primary use |
| --- | --- | --- | --- |
| `docs/process/health-dashboard.md` | Dashboard | Active | Real-time repository health and v1 readiness metrics. |
| `docs/process/self-audit-2026-02-17.md` | Audit | Active | Repo-wide self-audit verifying standards compliance and remediation status. |
| `docs/process/pilot-execution-playbook.md` | Process | Active | Step-by-step workflow for running external adoption pilots. |
| `docs/process/release-process.md` | Process | Active | How we ship changes safely (tagging, notes, rollback). |
| `docs/process/roadmap-process.md` | Process | Active | How we maintain the product and execution roadmaps. |
| `docs/process/maintenance-cadence-decision.md` | Decision | Active | Why quarterly + event-driven maintenance. |
| `docs/planning/archive/2026-02-16-guide-coverage-expansion-roadmap.md` | Plan | Archived | Completed LG-01 through LG-09 guide coverage expansion and harmonization roadmap. |
| `docs/planning/archive/2026-02-08-adoption-integration-hardening-plan-v0.2.0.md` | Plan | Archived | Completed adoption hardening implementation record (Phase 1-4). |
| `docs/planning/archive/2026-02-08-adoption-customization-hardening-plan-v0.3.0.md` | Plan | Archived | Completed implementation record for customization hardening and pilot evidence automation (Phase 1-4). |
| `docs/templates/feedback-template.md` | Template | Active | How adopters report gaps/conflicts quickly and consistently. |
| `docs/templates/pilot-kickoff-template.md` | Template | Active | Kickoff checklist and baseline for pilot repositories. |
| `docs/templates/pilot-weekly-checkin-template.md` | Template | Active | Weekly pilot status template for friction and outcomes. |
| `docs/templates/pilot-retrospective-template.md` | Template | Active | End-of-pilot summary and rollout decision template. |
| `docs/adr/adr-001-validation-and-ci.md` | ADR | Active | Why validation + CI are treated as the primary "test suite". |
| `docs/adr/adr-002-adoption-hardening-and-authorship-policy.md` | ADR | Active | Why adoption hardening baseline is fixed and commit authorship remains human-only. |
| `docs/adr/adr-003-pilot-evidence-handoff-and-human-validation.md` | ADR | Active | Why pilot evidence summary and human-owned external validation gates are standardized. |
| `docs/reference/references.md` | Reference | Active | External sources (human readers only). |
| `docs/deep-research/chatgpt-agentic-documentation-and-comments-2026-02-15.md` | Research output | Active | ChatGPT deep-research report for docs/comments in agentic coding. |
| `docs/deep-research/gemini-agentic-documentation-and-comments-2026-02-15.md` | Research output | Active | Gemini deep-research report for docs/comments in agentic coding. |
| `docs/deep-research/2026-02-15-evaluation-rubric.md` | Evaluation | Active | Objective rubric used to score deep-research outputs. |
| `docs/deep-research/2026-02-15-compliance-checklist.md` | Evaluation | Active | Prompt-level pass/fail compliance checklist per output. |
| `docs/deep-research/2026-02-15-source-audit.md` | Evaluation | Active | Citation quality and source-tier audit summary. |
| `docs/deep-research/2026-02-15-claim-verification.md` | Evaluation | Active | Verification sample of high-impact claims against primary sources. |
| `docs/deep-research/2026-02-15-scorecard.md` | Evaluation | Active | Weighted scorecard and hard-gate outcome for each output. |
| `docs/deep-research/2026-02-15-synthesized-recommendations.md` | Evaluation | Active | High-confidence recommendations after revalidation. |
| `docs/deep-research/2026-02-15-repo-change-map.md` | Evaluation | Active | File-level plan mapping validated findings to repo updates. |

## Directories

| Directory | What it contains |
| --- | --- |
| `docs/adr/` | Architecture Decision Records |
| `docs/process/` | Ongoing process docs (health dashboard, release, maintenance) |
| `docs/templates/` | Copy-paste templates |
| `docs/reference/` | External references for human readers |
| `docs/planning/` | Active planning documents (roadmaps, proposals) |
| `docs/planning/archive/` | Historical planning docs and decisions |
| `docs/deep-research/` | Research outputs plus evaluation artifacts and synthesis |

## Conventions

| Convention | Why |
| --- | --- |
| Keep `docs/` one level deep | Group by type without creating deep nesting. |
| Prefer tables over prose | Faster scanning and easier maintenance. |
| Version docs that define process | Makes changes auditable. |
