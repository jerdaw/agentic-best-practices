# AGENTS.md

Directives for AI agents working within this repository.

> **Scope**: Applies to any AI agent (Claude, ChatGPT, Gemini, etc.) modifying files in `agentic-best-practices`.

## Contents

| Section |
| --- |
| [Guide Index](#guide-index) |
| [Style Requirements](#style-requirements) |
| [Operational Rules](#operational-rules) |
| [Maintenance Rules](#maintenance-rules) |

---

## Guide Index

### Coding Foundations

| Guide | Note |
| --- | --- |
| [Writing Best Practices](guides/writing-best-practices/writing-best-practices.md) | **Start here.** Meta-guide for writing this documentation. |
| [Coding Guidelines](guides/coding-guidelines/coding-guidelines.md) | |
| [Commenting Guidelines](guides/commenting-guidelines/commenting-guidelines.md) | |
| [Documentation Guidelines](guides/documentation-guidelines/documentation-guidelines.md) | READMEs, API docs, ADRs |
| [Error Handling](guides/error-handling/error-handling.md) | |
| [Logging Practices](guides/logging-practices/logging-practices.md) | |
| [API Design](guides/api-design/api-design.md) | |
| [API Contract Governance](guides/api-contract-governance/api-contract-governance.md) | OpenAPI lifecycle, breaking-change gates, contract tests |
| [Dependency Management](guides/dependency-management/dependency-management.md) | |
| [Supply Chain Security](guides/supply-chain-security/supply-chain-security.md) | SLSA, provenance |
| [Resilience Patterns](guides/resilience-patterns/resilience-patterns.md) | Retries, circuit breakers |
| [Backup, Restore & DR](guides/backup-restore-dr/backup-restore-dr.md) | Backup verification, restore drills, RPO/RTO readiness |
| [Idempotency Patterns](guides/idempotency-patterns/idempotency-patterns.md) | Safe retry, deduplication |
| [Secrets & Configuration](guides/secrets-configuration/secrets-configuration.md) | Config separation, secret management |
| [Secure Coding](guides/secure-coding/secure-coding.md) | OWASP patterns, injection prevention |
| [Deployment Strategies](guides/deployment-strategies/deployment-strategies.md) | Blue-green, canary, feature flags |
| [Release Engineering & Versioning](guides/release-engineering-versioning/release-engineering-versioning.md) | SemVer, release pipelines, changelog discipline |
| [Observability Patterns](guides/observability-patterns/observability-patterns.md) | Metrics, tracing, health checks |
| [Testing Strategy](guides/testing-strategy/testing-strategy.md) | Test pyramid, coverage |
| [E2E Testing](guides/e2e-testing/e2e-testing.md) | Selectors, flaky tests, Page Object Model |
| [Documentation Maintenance](guides/doc-maintenance/doc-maintenance.md) | Code-to-docs sync, freshness tracking |
| [CI/CD Pipelines](guides/cicd-pipelines/cicd-pipelines.md) | Build, test, deploy automation |
| [Codebase Organization](guides/codebase-organization/codebase-organization.md) | Directory structure, layering |
| [Monorepo Workspaces](guides/monorepo-workspaces/monorepo-workspaces.md) | Workspace boundaries, package ownership, dependency direction |
| [Repository Governance](guides/repository-governance/repository-governance.md) | CODEOWNERS, branch protection, policy-as-code |
| [Static Analysis](guides/static-analysis/static-analysis.md) | Linters, formatters, SAST |
| [Privacy & Compliance](guides/privacy-compliance/privacy-compliance.md) | GDPR, data protection |
| [Accessibility & i18n](guides/accessibility-i18n/accessibility-i18n.md) | WCAG, localization |
| [Distributed Sagas](guides/distributed-sagas/distributed-sagas.md) | Multi-service transactions |
| [Database Migrations & Drift](guides/database-migrations-drift/database-migrations-drift.md) | Migration lifecycle, drift checks, rollback safety |
| [Database Indexing](guides/database-indexing/database-indexing.md) | Query optimization |
| [Planning Documentation](guides/planning-documentation/planning-documentation.md) | Roadmaps, RFCs, ADRs |

### AI-Assisted Development

| Guide | Note |
| --- | --- |
| [Adoption Guide](adoption/adoption.md) | **Start here.** Integrate agentic-best-practices into projects. |
| [AGENTS.md Template](adoption/template-agents.md) | Copy into a project as a starting point. |
| [Adoption Config Template](adoption/template-adoption-config.env) | Reusable config for script-driven AGENTS customization. |
| [AGENTS.md Guidelines](guides/agents-md/agents-md-guidelines.md) | Creating effective AGENTS.md files |
| [Agentic Workflow](guides/agentic-workflow/agentic-workflow.md) | MAP-FIRST workflow |
| [Prompting Patterns](guides/prompting-patterns/prompting-patterns.md) | |
| [Context Management](guides/context-management/context-management.md) | |
| [Prompt Files](guides/prompt-files/prompt-files.md) | Reusable task templates |
| [Memory Patterns](guides/memory-patterns/memory-patterns.md) | State across sessions |
| [Custom Agents](guides/custom-agents/custom-agents.md) | Specialized worker profiles |
| [Code Review for AI Output](guides/code-review-ai/code-review-ai.md) | |
| [Security Boundaries](guides/security-boundaries/security-boundaries.md) | |
| [Testing AI-Generated Code](guides/testing-ai-code/testing-ai-code.md) | |
| [Git Workflows with AI](guides/git-workflows-ai/git-workflows-ai.md) | |
| [Debugging with AI](guides/debugging-with-ai/debugging-with-ai.md) | |
| [Multi-File Refactoring](guides/multi-file-refactoring/multi-file-refactoring.md) | |
| [Human-AI Collaboration](guides/human-ai-collaboration/human-ai-collaboration.md) | |
| [Tool Configuration](guides/tool-configuration/tool-configuration.md) | |
| [PRD for Agents](guides/prd-for-agents/prd-for-agents.md) | Specs AI can consume |
| [Architecture for AI](guides/architecture-for-ai/architecture-for-ai.md) | System docs that prevent hallucination |

### Skills

Procedural, auto-discoverable workflow skills. Each wraps one or more deep guides above. See [skills/README.md](skills/README.md).

| Skill | Trigger |
| --- | --- |
| [debugging](skills/debugging/SKILL.md) | Diagnosing bugs, test failures, unexpected behavior |
| [code-review](skills/code-review/SKILL.md) | Reviewing code, preparing PRs |
| [testing](skills/testing/SKILL.md) | Writing tests, designing test strategy |
| [planning](skills/planning/SKILL.md) | Planning multi-step tasks, implementation plans |
| [pr-writing](skills/pr-writing/SKILL.md) | Creating PRs, writing commits |
| [secure-coding](skills/secure-coding/SKILL.md) | Security-sensitive code, auth, user input |
| [prompting](skills/prompting/SKILL.md) | Crafting prompts, managing AI context |
| [refactoring](skills/refactoring/SKILL.md) | Large changes across multiple files |
| [e2e-testing](skills/e2e-testing/SKILL.md) | Writing or fixing end-to-end tests |
| [doc-maintenance](skills/doc-maintenance/SKILL.md) | Keeping docs in sync with code changes |
| [issue-writing](skills/issue-writing/SKILL.md) | Filing bug reports, feature requests, task tickets |
| [git-workflow](skills/git-workflow/SKILL.md) | Branching, committing, conflict resolution, PRs |
| [logging](skills/logging/SKILL.md) | Structured logging, log levels, redaction |
| [deployment](skills/deployment/SKILL.md) | Production deploys, rollback, verification |

---

## Style Requirements

Follow [Writing Best Practices](guides/writing-best-practices/writing-best-practices.md) strictly.

| Requirement | Rationale |
| --- | --- |
| Tables > bullets > prose | Maximizes scannability |
| Good/Bad code examples | Clarifies by contrast |
| Each guide in `guides/` subdirectory | Predictable file locations |

---

## Operational Rules

| Action | Permission | Rationale |
| --- | --- | --- |
| Update README | **Required** | When adding new guides |
| Fix broken links | **Always** | Maintains graph integrity |
| Keep human-only authorship metadata | **Required** | Maintains accountability in git history and docs |
| Avoid AI attribution | **Required** | No 'Co-authored-by' trailers or AI credits |
| Add new directory | **Ask first** | Taxonomy decisions need review |
| Restructure repo | **Ask first** | High impact on linking |

### Anti-Patterns

| Anti-Pattern | Rationale |
| --- | --- |
| Filler content | "Coming soon" is waste |
| Deep nesting | Max 1 level deep |
| Prose walls | If it fits a table, use a table |

---

## Maintenance Rules

Keep navigation in sync when modifying files.

| When You | Also Update | Rationale |
| --- | --- | --- |
| Add/remove H2 section | That file's Contents table | Keeps navigation accurate |
| Add new guide file | AGENTS.md Guide Index + README.md | Makes guide discoverable |
| Rename/delete a guide | All links pointing to it | Prevents broken links |
| Change guide location | AGENTS.md + README.md + cross-references | Maintains graph integrity |

### Validation

Run `scripts/validate-navigation.sh` to check for drift:

- Contents tables match actual H2 sections
- Guide Index matches actual files
- All internal links resolve
