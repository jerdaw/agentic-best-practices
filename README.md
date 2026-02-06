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
| **Focus** | Capabilities (deploy, test, build) | Standards (error handling, logging, API design) |
| **Scope** | Task-specific | Cross-cutting principles |
| **Usage** | On-demand invocation | Continuous reference |
| **Ownership** | Often tool-specific | Tool-agnostic (Claude, Gemini, ChatGPT) |
| **Update model** | Per-project embedding | Central repo, one `git pull` updates all |

**In short**: Skills = "What to do." This project = "How to do things well."

The result is consistent engineering judgment across all AI work—AI consults these standards before making decisions rather than reinventing patterns or making arbitrary choices.

---

## Getting Started

Use this repository as a shared standards library across all your projects.

### Quick Start

```bash
# One-time: clone to standard location
git clone https://github.com/[org]/agentic-best-practices.git ~/agentic-best-practices

# Per-project: copy template and customize
cp ~/agentic-best-practices/adoption/template-agents.md ./AGENTS.md
ln -s AGENTS.md CLAUDE.md
# Edit AGENTS.md to fill in project-specific sections
```

### How It Works

| Component | Purpose |
| --- | --- |
| **This repo** (`~/agentic-best-practices/`) | Single source of truth for all standards |
| **Project AGENTS.md** | Points AI to consult agentic-best-practices for guidance |
| **Template** | Ready-to-use AGENTS.md with reference directive built in |

The template includes a **Standards Reference** section that tells AI:
> *Before implementing patterns for error handling, logging, API design, etc., consult the relevant guide in `~/agentic-best-practices/`.*

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
| Update local standards | `git -C ~/agentic-best-practices pull` |
| Review recent changes | `git -C ~/agentic-best-practices log --oneline -20` |

Release hygiene and tagging conventions are documented in `docs/process/release-process.md`.

See the full [Adoption Guide](adoption/adoption.md) for detailed setup instructions.

---

## Roadmap

### Pre-v1 Launch (85% Complete)

| Work Item | Status | Notes |
| --- | --- | --- |
| Content complete (38 guides with examples) | ✅ Complete | All guides have 2+ code examples |
| Infrastructure (CI, issue templates, health dashboard) | ✅ Complete | Link checking, freshness tracking, feedback templates |
| Self-dogfooding (CLAUDE.md, validation) | ✅ Complete | Repository follows own best practices |
| Maintenance process defined | ✅ Complete | [Quarterly + event-driven cadence](docs/process/maintenance-cadence-decision.md) |
| Add CODE_OF_CONDUCT.md | 🔴 Blocked | Need to select and add standard template |
| Add LICENSE file | 🔴 Blocked | Recommend MIT or Apache 2.0 |
| Choose 1–2 adoption pilot repos | 🔴 Blocked | Requires org priorities. See [selection criteria](docs/planning/pilot-repo-selection.md) |

See [health dashboard](docs/process/health-dashboard.md) for detailed metrics.

---

## Contents

### Coding Foundations

Core software development patterns applicable to any project.

| Guide | Description |
| --- | --- |
| [Writing Best Practices](guides/writing-best-practices/writing-best-practices.md) | **Start Here**. Meta-guide for writing best practices documentation. |
| [Coding Guidelines](guides/coding-guidelines/coding-guidelines.md) | Writing clear, maintainable code. |
| [Commenting Guidelines](guides/commenting-guidelines/commenting-guidelines.md) | When and how to write comments. |
| [Documentation Guidelines](guides/documentation-guidelines/documentation-guidelines.md) | READMEs, API docs, and ADRs. |
| [Error Handling](guides/error-handling/error-handling.md) | Handling errors robustly/gracefully. |
| [Logging Practices](guides/logging-practices/logging-practices.md) | Effective logging patterns for observability. |
| [API Design](guides/api-design/api-design.md) | Designing clear, consistent interfaces. |
| [Dependency Management](guides/dependency-management/dependency-management.md) | Managing external packages safety. |
| [Supply Chain Security](guides/supply-chain-security/supply-chain-security.md) | SLSA, provenance, and artifact integrity. |
| [Resilience Patterns](guides/resilience-patterns/resilience-patterns.md) | Retries, circuit breakers, and fallbacks. |
| [Idempotency Patterns](guides/idempotency-patterns/idempotency-patterns.md) | Safe retry and deduplication strategies. |
| [Secrets & Configuration](guides/secrets-configuration/secrets-configuration.md) | Config separation and secret management. |
| [Secure Coding](guides/secure-coding/secure-coding.md) | OWASP patterns and injection prevention. |
| [Deployment Strategies](guides/deployment-strategies/deployment-strategies.md) | Blue-green, canary, and feature flags. |
| [Observability Patterns](guides/observability-patterns/observability-patterns.md) | Metrics, tracing, and health checks. |
| [Testing Strategy](guides/testing-strategy/testing-strategy.md) | Test pyramid and coverage goals. |
| [CI/CD Pipelines](guides/cicd-pipelines/cicd-pipelines.md) | Build, test, deploy automation. |
| [Codebase Organization](guides/codebase-organization/codebase-organization.md) | Directory structure and layering. |
| [Static Analysis](guides/static-analysis/static-analysis.md) | Linters, formatters, and SAST. |
| [Privacy & Compliance](guides/privacy-compliance/privacy-compliance.md) | GDPR and data protection. |
| [Accessibility & i18n](guides/accessibility-i18n/accessibility-i18n.md) | WCAG and localization. |
| [Distributed Sagas](guides/distributed-sagas/distributed-sagas.md) | Multi-service transactions. |
| [Database Indexing](guides/database-indexing/database-indexing.md) | Query optimization. |
| [Planning Documentation](guides/planning-documentation/planning-documentation.md) | Roadmaps, implementation plans, and RFCs. |

### AI-Assisted Development

Best practices specific to working with AI coding assistants.

| Guide | Description |
| --- | --- |
| [Adoption Guide](adoption/adoption.md) | **Start Here.** Integrate agentic-best-practices into your projects. |
| [AGENTS.md Template](adoption/template-agents.md) | Copy into a project as a starting point. |
| [AGENTS.md Guidelines](guides/agents-md/agents-md-guidelines.md) | Creating effective AGENTS.md files. |
| [Agentic Workflow](guides/agentic-workflow/agentic-workflow.md) | MAP-FIRST workflow for safe coding. |
| [Prompting Patterns](guides/prompting-patterns/prompting-patterns.md) | Crafting effective prompts for AI tools. |
| [Context Management](guides/context-management/context-management.md) | Providing the right context to AI. |
| [Code Review for AI Output](guides/code-review-ai/code-review-ai.md) | Reviewing AI-generated code effectively. |
| [Security Boundaries](guides/security-boundaries/security-boundaries.md) | Security requirements for AI development. |
| [Testing AI-Generated Code](guides/testing-ai-code/testing-ai-code.md) | Verification strategies for AI output. |
| [Git Workflows with AI](guides/git-workflows-ai/git-workflows-ai.md) | Version control practices for AI. |
| [Debugging with AI](guides/debugging-with-ai/debugging-with-ai.md) | Effective debugging with AI assistance. |
| [Multi-File Refactoring](guides/multi-file-refactoring/multi-file-refactoring.md) | Coordinating large changes with AI. |
| [Human-AI Collaboration](guides/human-ai-collaboration/human-ai-collaboration.md) | Deciding when and how to use AI. |
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
