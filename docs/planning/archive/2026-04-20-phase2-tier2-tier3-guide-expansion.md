# Phase 2 Tier 2 and Tier 3 Guide Expansion

| Field | Value |
| --- | --- |
| **Status** | Complete |
| **Completed** | 2026-04-20 |
| **Scope** | GE-07 through GE-14 |
| **Roadmap ref** | `roadmap.md` — Guide Coverage Expansion Phase 2 |

## Summary

Completed the remaining Tier 2 and Tier 3 guide backlog from the 2026-02-26 audit. Added 8 new guides covering evaluation, event-driven design, schema design, team coordination, retrieval-oriented docs, decision logs, spec-driven workflows, and documentation security. Also added 3 workflow skills that wrap the Tier 1 Incident Response, Performance Engineering, and Cost & Token Management guides.

## Guides Created

| ID | Guide | Category | File |
| --- | --- | --- | --- |
| GE-07 | AI Agent Evaluation & Metrics | AI Development | `guides/ai-agent-evaluation-metrics/ai-agent-evaluation-metrics.md` |
| GE-08 | Event-Driven Architecture | SE Foundation | `guides/event-driven-architecture/event-driven-architecture.md` |
| GE-09 | Data Modeling & Schema Design | SE Foundation | `guides/data-modeling-schema-design/data-modeling-schema-design.md` |
| GE-10 | Team AI Coordination | AI Development | `guides/team-ai-coordination/team-ai-coordination.md` |
| GE-11 | llms.txt & RAG-Optimized Docs | AI Development | `guides/llms-txt-rag-optimized-docs/llms-txt-rag-optimized-docs.md` |
| GE-12 | Agentic Decision Logs | AI Development | `guides/agentic-decision-logs/agentic-decision-logs.md` |
| GE-13 | Spec-Driven Development | AI Development | `guides/spec-driven-development/spec-driven-development.md` |
| GE-14 | Documentation as Attack Surface | AI Development | `guides/documentation-as-attack-surface/documentation-as-attack-surface.md` |

## Navigation Updates

- `AGENTS.md` — 8 guide index entries added
- `README.md` — 8 guide entries added and roadmap updated to reflect Tier 1-3 completion
- `roadmap.md` — active backlog updated to remove completed GE-07 through GE-14 items

## Skills Created

| Skill | Backing guide |
| --- | --- |
| `incident-response` | `guides/incident-response/incident-response.md` |
| `performance` | `guides/performance-engineering/performance-engineering.md` |
| `cost-management` | `guides/cost-token-management/cost-token-management.md` |

## Validation

- `npx -y -p node@20 npm run lint:md` — 122 markdown files, 0 errors
- `npm run validate` — all navigation and link checks passed
- `npx -y -p node@20 npm run validate:adoption:sim` — passed
- `npx -y -p node@20 npm run precommit` — passed
