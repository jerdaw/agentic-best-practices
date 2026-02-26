# Roadmap

Execution roadmap for current implementation work. Canonical product roadmap remains in `README.md`.

| Field | Value |
| --- | --- |
| **Status** | Active |
| **Last Updated** | 2026-02-26 |
| **Current Focus** | Guide coverage expansion (Phase 2, Tiers 2-4) and pilot selection |

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
| Guide coverage expansion (Phase 2) | Fill SE foundation and AI-development gaps identified in 2026-02-26 audit | 🟡 In progress (Tier 1 complete) |
| External validation | Validate standards and workflows in 1-2 real repositories | Blocked on pilot repo selection |

Completed implementation details are archived in:

- `docs/planning/archive/2026-02-08-adoption-integration-hardening-plan-v0.2.0.md`
- `docs/planning/archive/2026-02-08-adoption-customization-hardening-plan-v0.3.0.md`
- `docs/planning/archive/2026-02-16-guide-coverage-expansion-roadmap.md`
- `docs/planning/archive/2026-02-26-tier1-guide-coverage-expansion.md`

---

## Guide Coverage Expansion — Phase 2

Gaps identified through a comprehensive audit on 2026-02-26. Tier 1 (GE-01 through GE-06) is complete — see [archive](docs/planning/archive/2026-02-26-tier1-guide-coverage-expansion.md).

### Tier 2 — Important (minimal or no coverage)

| ID | Topic | Category | Rationale | Status |
| --- | --- | --- | --- | --- |
| GE-07 | AI Agent Evaluation & Metrics | AI Development | No systematic guidance on measuring agent effectiveness, quality tracking over time, or productivity metrics. | 🔴 Not started |
| GE-08 | Event-Driven Architecture | SE Foundation | Pub/sub, event sourcing, CQRS, message broker patterns. Distributed Sagas is adjacent but doesn't cover event-driven design broadly. | 🔴 Not started |
| GE-09 | Data Modeling & Schema Design | SE Foundation | Database Indexing and Migrations exist but no guide on schema design, normalization, domain modeling, or entity relationships. | 🔴 Not started |
| GE-10 | Team AI Coordination | AI Development | Human-AI Collaboration covers individual pairing only. No guidance on multiple developers using agents on the same codebase, conflict prevention, or team-level AI policies. | 🔴 Not started |

### Tier 3 — Audit Debt (flagged by prior audits, not yet addressed)

| ID | Topic | Source | Rationale | Status |
| --- | --- | --- | --- | --- |
| GE-11 | llms.txt & RAG-Optimized Docs | Gemini audit (2026-02-15) | How to structure docs for agent consumption via RAG. The `llms.txt` standard, chunking strategies, metadata for retrieval. | 🔴 Not started |
| GE-12 | Agentic Decision Logs | Gemini audit (2026-02-15) | Automatic logging of agent decisions, rationale capture, audit trails for AI actions. Different from ADRs (human architectural decisions). | 🔴 Not started |
| GE-13 | Spec-Driven Development | Gemini audit (2026-02-15) | Specs-before-code workflow for AI-assisted teams. Adjacent to PRD for Agents and Planning Documentation but neither covers the full SDD lifecycle. | 🔴 Not started |
| GE-14 | Documentation as Attack Surface | Gemini audit (2026-02-15) | Indirect prompt injection via docs, poisoned comments, malicious context. Security Boundaries covers code-level threats but not documentation-vector attacks. | 🔴 Not started |

### Tier 4 — Worth Considering (valuable but specialized)

| ID | Topic | Rationale | Status |
| --- | --- | --- | --- |
| GE-15 | MCP & Tool Integration Patterns | Tool Configuration covers IDE setup but not MCP server configuration, custom tool creation, or tool ecosystem management. Could expand existing guide. | 🔴 Not started |
| GE-16 | Queue & Background Job Patterns | Async processing, job scheduling, dead letter queues, idempotent consumers. Adjacent to Idempotency and Resilience guides. | 🔴 Not started |
| GE-17 | Feature Flag Lifecycle | Deployment Strategies mentions flags but doesn't cover full lifecycle: creation, targeting, stale flag debt, flag-driven testing. | 🔴 Not started |
| GE-18 | Infrastructure as Code | Terraform/Pulumi patterns, drift detection, state management. Adjacent to Deployment Strategies but distinct discipline. | 🔴 Not started |

### Potential New Skills

| Skill | Wraps | Priority |
| --- | --- | --- |
| `incident-response` | GE-01 Incident Response | Tier 1 |
| `performance` | GE-02 Performance Engineering | Tier 1 |
| `cost-management` | GE-04 Cost & Token Management | Tier 1 |

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
| Complete Guide Coverage Expansion Phase 2 — Tier 2 (GE-07 through GE-10) | 🟡 Planned |
| Address audit debt — Tier 3 (GE-11 through GE-14) | 🟡 Planned |
| Select 1-2 pilot repositories with explicit team commitment | 🔴 Blocked |
| Complete 6-8 week pilot run with weekly check-ins | 🟡 Planned |
| Convert pilot outcomes into release backlog | 🟡 Planned |

---

## Next Action

| Priority | Action | Owner | Status |
| --- | --- | --- | --- |
| 1 | Write Tier 2 guides (GE-07 through GE-10) | Agent + human review | 🟡 Planned |
| 2 | Address Tier 3 audit debt (GE-11 through GE-14) | Agent + human review | 🟡 Planned |
| 3 | Select pilot repositories with explicit team commitment | Human maintainer | 🔴 Pending |
| 4 | Execute 6-8 week pilot with generated artifacts | Human maintainer + pilot owners | 🔴 Pending |
| 5 | Convert pilot findings into guide/script backlog and releases | Human maintainer + contributors | 🔴 Pending |
