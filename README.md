# Best Practices

An opinionated set of best practices for agentic, AI-assisted software development. Each guide distills real-world patterns into scannable references with concrete examples.

## Quick Reference

| Topic | Guidance |
| --- | --- |
| **For Agents** | Adopt patterns immediately; no need to ask permission for standard practices. |
| **For Humans** | Use as a reference; challenge guidelines if they impede valid edge cases. See [references](docs/reference/references.md) for external sources. |
| **Contributing** | Follow [Writing Best Practices](guides/writing-best-practices/writing-best-practices.md) strictly. |
| **Philosophy** | Examples > Prose. Tables > Paragraphs. Actionable > Theoretical. |

---

## Core Principles

| Principle | Why |
| --- | --- |
| **Show, Don't Tell** | Code examples are unambiguous and easier to copy-paste. |
| **Scannability First** | AI agents and busy logic have limited attention spans. |
| **Living Documents** | Outdated documentation is worse than no documentation. |
| **Agent-Centric** | Optimized for AI consumption (token efficiency, clear actions). |

---

## Why This Project?

AI coding tools offer "skills" (scripts, commands, specialized tasks) that extend *what* an agent can do. This project fills a different gap: establishing *how* AI approaches any task.

| Aspect | Skills | agentic-best-practices |
| --- | --- | --- |
| **Focus** | Capabilities (deploy, test, build) | Standards AND procedural skills backed by deep guides |
| **Scope** | Task-specific | Cross-cutting principles |
| **Usage** | On-demand invocation | Continuous reference + auto-discoverable skills |
| **Ownership** | Often tool-specific | Tool-agnostic (Claude, Gemini, ChatGPT) |
| **Update model** | Per-project embedding | Central repo, one `git pull` updates all |

**In short**: Skills = "What to do." This project = "How to do things well — and teaches agents how, step by step."

The result is consistent engineering judgment across all AI work—AI consults these standards before making decisions rather than reinventing patterns or making arbitrary choices.

---

## Skills

Procedural workflow skills that agents can auto-discover and follow. Each skill is a concise, step-by-step wrapper backed by a deep guide in `guides/`. See [skills/README.md](skills/README.md) for details.

| Skill | Trigger | Deep Guide(s) |
| --- | --- | --- |
| [debugging](skills/debugging/SKILL.md) | Diagnosing bugs, test failures, unexpected behavior | [Debugging with AI](guides/debugging-with-ai/debugging-with-ai.md) |
| [code-review](skills/code-review/SKILL.md) | Reviewing code, preparing PRs for review | [Code Review for AI Output](guides/code-review-ai/code-review-ai.md) |
| [testing](skills/testing/SKILL.md) | Writing tests, designing test strategy | [Testing Strategy](guides/testing-strategy/testing-strategy.md), [Testing AI Code](guides/testing-ai-code/testing-ai-code.md) |
| [planning](skills/planning/SKILL.md) | Planning multi-step tasks, implementation plans | [Planning Documentation](guides/planning-documentation/planning-documentation.md), [Agentic Workflow](guides/agentic-workflow/agentic-workflow.md) |
| [pr-writing](skills/pr-writing/SKILL.md) | Creating PRs, writing commits | [Git Workflows with AI](guides/git-workflows-ai/git-workflows-ai.md) |
| [secure-coding](skills/secure-coding/SKILL.md) | Security-sensitive code, auth, user input | [Secure Coding](guides/secure-coding/secure-coding.md), [Security Boundaries](guides/security-boundaries/security-boundaries.md) |
| [prompting](skills/prompting/SKILL.md) | Crafting prompts, managing AI context | [Prompting Patterns](guides/prompting-patterns/prompting-patterns.md), [Context Management](guides/context-management/context-management.md) |
| [refactoring](skills/refactoring/SKILL.md) | Large changes across multiple files | [Multi-File Refactoring](guides/multi-file-refactoring/multi-file-refactoring.md) |
| [e2e-testing](skills/e2e-testing/SKILL.md) | Writing or fixing end-to-end tests | [E2E Testing](guides/e2e-testing/e2e-testing.md) |
| [doc-maintenance](skills/doc-maintenance/SKILL.md) | Keeping docs in sync with code changes | [Documentation Maintenance](guides/doc-maintenance/doc-maintenance.md) |
| [issue-writing](skills/issue-writing/SKILL.md) | Filing bug reports, feature requests, task tickets | Standalone |
| [git-workflow](skills/git-workflow/SKILL.md) | Branching, committing, conflict resolution, PRs | [Git Workflows with AI](guides/git-workflows-ai/git-workflows-ai.md) |
| [logging](skills/logging/SKILL.md) | Structured logging, log levels, redaction | [Logging Practices](guides/logging-practices/logging-practices.md) |
| [deployment](skills/deployment/SKILL.md) | Production deploys, rollback, verification | [Deployment Strategies](guides/deployment-strategies/deployment-strategies.md) |

---

## Getting Started

Use this repository as a shared standards library across all your projects.

### Quick Start

```bash
# One-time: clone to standard location
git clone https://github.com/[org]/agentic-best-practices.git ~/agentic-best-practices

# Set standards path (customize if needed)
export AGENTIC_BEST_PRACTICES_HOME="${AGENTIC_BEST_PRACTICES_HOME:-$HOME/agentic-best-practices}"

# Per-project: render AGENTS.md + CLAUDE.md with project defaults
bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/adopt-into-project.sh" \
  --project-dir . \
  --standards-path "$AGENTIC_BEST_PRACTICES_HOME"

# Optional: apply reusable customization settings from a config file
bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/adopt-into-project.sh" \
  --project-dir . \
  --standards-path "$AGENTIC_BEST_PRACTICES_HOME" \
  --config-file .agentic-best-practices/adoption.env

# Existing project with AGENTS.md: merge standards section in-place
bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/adopt-into-project.sh" \
  --project-dir . \
  --standards-path "$AGENTIC_BEST_PRACTICES_HOME" \
  --existing-mode merge \
  --claude-mode skip

# Optional pinned mode: snapshot standards at a specific tag/commit
bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/adopt-into-project.sh" \
  --project-dir . \
  --standards-path "$AGENTIC_BEST_PRACTICES_HOME" \
  --adoption-mode pinned \
  --pinned-ref v1.0.0

# Validate adoption output
bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/validate-adoption.sh" \
  --project-dir . \
  --expect-standards-path "$AGENTIC_BEST_PRACTICES_HOME"
# For pinned mode validation, omit --expect-standards-path or pass the pinned path from AGENTS.md

# Optional: prepare pilot artifacts (kickoff, weekly check-in, retrospective)
bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/prepare-pilot-project.sh" \
  --project-dir . \
  --standards-path "$AGENTIC_BEST_PRACTICES_HOME" \
  --existing-mode merge \
  --pilot-owner "Team Name"

# Optional: check pilot readiness status (setup/cadence/retrospective)
bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/check-pilot-readiness.sh" \
  --project-dir . \
  --min-weekly-checkins 0 \
  --strict
```

### How It Works

| Component | Purpose |
| --- | --- |
| **This repo** (`$AGENTIC_BEST_PRACTICES_HOME/`) | Single source of truth for all standards |
| **Project AGENTS.md** | Points AI to consult agentic-best-practices for guidance |
| **Bootstrap script** | Renders template with project defaults and standards path |
| **Stack-aware defaults** | Auto-detects Node/Python/Go/Rust/JVM projects to pre-fill language/runtime/testing and key command defaults |
| **Adoption config file** | Lets projects customize role, priorities, standards topics, and commands with one reusable file |
| **Merge workflow** | Updates existing `AGENTS.md` with a managed Standards Reference block |
| **Pinned mode** | Creates project-local standards snapshot at a specific git ref |
| **Pilot prep script** | Bootstraps adoption + strict validation + pilot artifacts in one command |

The template includes a **Standards Reference** section that tells AI:
> *Before implementing patterns for error handling, logging, API design, etc., consult the relevant guide in `{{STANDARDS_PATH}}/`.*

This ensures consistent AI behavior across all your projects.

### Preventing Drift

The [Adoption Guide](adoption/adoption.md) includes mechanisms to prevent projects from diverging:

| Mechanism | Effect |
| --- | --- |
| **Deviation policy** | AI asks before deviating from standards |
| **Overrides section** | Intentional deviations must be documented with rationale |
| **Periodic sync** | `git pull` updates standards across all projects |

### Updating Standards

| Task | Command |
| --- | --- |
| Update local standards | `git -C "$AGENTIC_BEST_PRACTICES_HOME" pull` |
| Review recent changes | `git -C "$AGENTIC_BEST_PRACTICES_HOME" log --oneline -20` |
| Refresh pinned project to new ref | `bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/adopt-into-project.sh" --project-dir . --adoption-mode pinned --pinned-ref vX.Y.Z --existing-mode merge` |

Release hygiene and tagging conventions are documented in `docs/process/release-process.md`.

See the full [Adoption Guide](adoption/adoption.md) for detailed setup instructions.

---

## Roadmap

### Guide Coverage Expansion — Phase 2

Gaps identified through comprehensive audit (2026-02-26). Full backlog in [roadmap.md](roadmap.md#guide-coverage-expansion--phase-2).

| Tier | Items | Topics |
| --- | --- | --- |
| **Tier 1 — Critical** | GE-01 through GE-06 | Incident Response, Performance Engineering, Technical Debt Management, Cost & Token Management, Multi-Agent Orchestration, Concurrency & Async Patterns |
| **Tier 2 — Important** | GE-07 through GE-10 | AI Agent Evaluation & Metrics, Event-Driven Architecture, Data Modeling & Schema Design, Team AI Coordination |
| **Tier 3 — Audit Debt** | GE-11 through GE-14 | llms.txt & RAG-Optimized Docs, Agentic Decision Logs, Spec-Driven Development, Documentation as Attack Surface |
| **Tier 4 — Specialized** | GE-15 through GE-18 | MCP & Tool Integration, Queue & Background Jobs, Feature Flag Lifecycle, Infrastructure as Code |

### Pre-v1 Launch

| Work Item | Status | Notes |
| --- | --- | --- |
| Guide Coverage Expansion Phase 2 — Tier 1 | ✅ Complete | 6 new guides. See [roadmap](roadmap.md#tier-1--critical-no-existing-coverage). |
| Choose 1-2 adoption pilot repos | 🔴 Blocked | Human decision needed. Use [selection criteria](docs/planning/pilot-repo-selection.md). |
| Execute pilot validation cycle (6-8 weeks) | 🟡 Planned | Use [pilot execution playbook](docs/process/pilot-execution-playbook.md). |
| Feed pilot outcomes into next release backlog | 🟡 Planned | File actionable updates via [feedback template](docs/templates/feedback-template.md). |

Completed implementation details are archived in:

- `docs/planning/archive/2026-02-08-adoption-integration-hardening-plan-v0.2.0.md`
- `docs/planning/archive/2026-02-08-adoption-customization-hardening-plan-v0.3.0.md`
- `docs/planning/archive/2026-02-16-guide-coverage-expansion-roadmap.md`

See [health dashboard](docs/process/health-dashboard.md) for readiness metrics.

---

## Contents

### Coding Foundations

Core software development patterns applicable to any project.

| Guide | Description |
| --- | --- |
| [Writing Best Practices](guides/writing-best-practices/writing-best-practices.md) | **Start Here**. Meta-guide for writing best practices documentation. |
| [Coding Guidelines](guides/coding-guidelines/coding-guidelines.md) | Writing clear, maintainable code. |
| [Commenting Guidelines](guides/commenting-guidelines/commenting-guidelines.md) | When and how to write comments. |
| [Concurrency & Async Patterns](guides/concurrency-async/concurrency-async.md) | Threading, async/await, and race condition prevention. |
| [Documentation Guidelines](guides/documentation-guidelines/documentation-guidelines.md) | READMEs, API docs, and ADRs. |
| [Error Handling](guides/error-handling/error-handling.md) | Handling errors robustly/gracefully. |
| [Logging Practices](guides/logging-practices/logging-practices.md) | Effective logging patterns for observability. |
| [API Design](guides/api-design/api-design.md) | Designing clear, consistent interfaces. |
| [API Contract Governance](guides/api-contract-governance/api-contract-governance.md) | OpenAPI governance, compatibility gates, and contract testing. |
| [Dependency Management](guides/dependency-management/dependency-management.md) | Managing external packages safety. |
| [Supply Chain Security](guides/supply-chain-security/supply-chain-security.md) | SLSA, provenance, and artifact integrity. |
| [Resilience Patterns](guides/resilience-patterns/resilience-patterns.md) | Retries, circuit breakers, and fallbacks. |
| [Backup, Restore & DR](guides/backup-restore-dr/backup-restore-dr.md) | Data recoverability, restore drills, and RPO/RTO operations. |
| [Idempotency Patterns](guides/idempotency-patterns/idempotency-patterns.md) | Safe retry and deduplication strategies. |
| [Secrets & Configuration](guides/secrets-configuration/secrets-configuration.md) | Config separation and secret management. |
| [Secure Coding](guides/secure-coding/secure-coding.md) | OWASP patterns and injection prevention. |
| [Deployment Strategies](guides/deployment-strategies/deployment-strategies.md) | Blue-green, canary, and feature flags. |
| [Release Engineering & Versioning](guides/release-engineering-versioning/release-engineering-versioning.md) | SemVer policy, release orchestration, and changelog quality. |
| [Observability Patterns](guides/observability-patterns/observability-patterns.md) | Metrics, tracing, and health checks. |
| [Incident Response](guides/incident-response/incident-response.md) | Severity classification, escalation chains, and blameless postmortems. |
| [Testing Strategy](guides/testing-strategy/testing-strategy.md) | Test pyramid and coverage goals. |
| [E2E Testing](guides/e2e-testing/e2e-testing.md) | End-to-end testing patterns and flaky test prevention. |
| [Documentation Maintenance](guides/doc-maintenance/doc-maintenance.md) | Keeping docs in sync with code changes. |
| [CI/CD Pipelines](guides/cicd-pipelines/cicd-pipelines.md) | Build, test, deploy automation. |
| [Codebase Organization](guides/codebase-organization/codebase-organization.md) | Directory structure and layering. |
| [Monorepo Workspaces](guides/monorepo-workspaces/monorepo-workspaces.md) | Workspace boundaries, package ownership, and dependency direction. |
| [Repository Governance](guides/repository-governance/repository-governance.md) | CODEOWNERS, branch protections, and policy-as-code controls. |
| [Static Analysis](guides/static-analysis/static-analysis.md) | Linters, formatters, and SAST. |
| [Technical Debt Management](guides/technical-debt-management/technical-debt-management.md) | Debt identification, tracking, and paydown strategies. |
| [Privacy & Compliance](guides/privacy-compliance/privacy-compliance.md) | GDPR and data protection. |
| [Accessibility & i18n](guides/accessibility-i18n/accessibility-i18n.md) | WCAG and localization. |
| [Distributed Sagas](guides/distributed-sagas/distributed-sagas.md) | Multi-service transactions. |
| [Database Migrations & Drift](guides/database-migrations-drift/database-migrations-drift.md) | Migration safety, schema drift detection, and rollback strategy. |
| [Database Indexing](guides/database-indexing/database-indexing.md) | Query optimization. |
| [Performance Engineering](guides/performance-engineering/performance-engineering.md) | Profiling, load testing, benchmarking, and capacity planning. |
| [Planning Documentation](guides/planning-documentation/planning-documentation.md) | Roadmaps, implementation plans, and RFCs. |

### AI-Assisted Development

Best practices specific to working with AI coding assistants.

| Guide | Description |
| --- | --- |
| [Adoption Guide](adoption/adoption.md) | **Start Here.** Integrate agentic-best-practices into your projects. |
| [AGENTS.md Template](adoption/template-agents.md) | Copy into a project as a starting point. |
| [Adoption Config Template](adoption/template-adoption-config.env) | Reusable configuration for script-driven AGENTS customization. |
| [AGENTS.md Guidelines](guides/agents-md/agents-md-guidelines.md) | Creating effective AGENTS.md files. |
| [Agentic Workflow](guides/agentic-workflow/agentic-workflow.md) | MAP-FIRST workflow for safe coding. |
| [Prompting Patterns](guides/prompting-patterns/prompting-patterns.md) | Crafting effective prompts for AI tools. |
| [Context Management](guides/context-management/context-management.md) | Providing the right context to AI. |
| [Prompt Files](guides/prompt-files/prompt-files.md) | Authoring reusable task templates for agents. |
| [Memory Patterns](guides/memory-patterns/memory-patterns.md) | State management across agent sessions. |
| [Custom Agents](guides/custom-agents/custom-agents.md) | Designing specialized agent worker profiles. |
| [Code Review for AI Output](guides/code-review-ai/code-review-ai.md) | Reviewing AI-generated code effectively. |
| [Cost & Token Management](guides/cost-token-management/cost-token-management.md) | Token budgets, model selection, and spend governance. |
| [Security Boundaries](guides/security-boundaries/security-boundaries.md) | Security requirements for AI development. |
| [Testing AI-Generated Code](guides/testing-ai-code/testing-ai-code.md) | Verification strategies for AI output. |
| [Git Workflows with AI](guides/git-workflows-ai/git-workflows-ai.md) | Version control practices for AI. |
| [Debugging with AI](guides/debugging-with-ai/debugging-with-ai.md) | Effective debugging with AI assistance. |
| [Multi-File Refactoring](guides/multi-file-refactoring/multi-file-refactoring.md) | Coordinating large changes with AI. |
| [Human-AI Collaboration](guides/human-ai-collaboration/human-ai-collaboration.md) | Deciding when and how to use AI. |
| [Multi-Agent Orchestration](guides/multi-agent-orchestration/multi-agent-orchestration.md) | Coordinating multiple agents on shared tasks. |
| [Tool Configuration](guides/tool-configuration/tool-configuration.md) | Configuring AI coding tools effectively. |
| [PRD for Agents](guides/prd-for-agents/prd-for-agents.md) | Writing specs that AI agents can consume. |
| [Architecture for AI](guides/architecture-for-ai/architecture-for-ai.md) | System docs that prevent hallucination. |

---

## Contributing

New guides must follow the [Writing Best Practices](guides/writing-best-practices/writing-best-practices.md) standard.

| Requirement | Description |
| --- | --- |
| **Actionable** | Concrete examples over abstract principles. |
| **Scannable** | Tables and lists over prose. |
| **Maintained** | Updated when practices evolve. |

### Roadmap

| Topic | Doc |
| --- | --- |
| How we maintain the roadmap | `docs/process/roadmap-process.md` |
| Project maintenance docs index | `docs/README.md` |

### Feedback

| If you found... | Use |
| --- | --- |
| A missing pattern, conflict, or confusing guidance | `docs/templates/feedback-template.md` |
| A consistent way to classify and resolve feedback | `docs/templates/feedback-template.md` |

---

## License

MIT
