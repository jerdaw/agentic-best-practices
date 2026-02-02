# AGENTS.md

Directives for AI agents working within this repository.

> **Scope**: Applies to any AI agent (Claude, ChatGPT, Gemini, etc.) modifying files in `best-practices`.

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
| [Writing Best Practices](writing-best-practices/writing-best-practices.md) | **Start here.** Meta-guide for writing this documentation. |
| [Coding Guidelines](coding-guidelines/coding-guidelines.md) | |
| [Commenting Guidelines](commenting-guidelines/commenting-guidelines.md) | |
| [Documentation Guidelines](documentation-guidelines/documentation-guidelines.md) | READMEs, API docs, ADRs |
| [Error Handling](error-handling/error-handling.md) | |
| [Logging Practices](logging-practices/logging-practices.md) | |
| [API Design](api-design/api-design.md) | |
| [Dependency Management](dependency-management/dependency-management.md) | |
| [Supply Chain Security](supply-chain-security/supply-chain-security.md) | SLSA, provenance |
| [Resilience Patterns](resilience-patterns/resilience-patterns.md) | Retries, circuit breakers |
| [Planning Documentation](planning-documentation/planning-documentation.md) | Roadmaps, RFCs, ADRs |

### AI-Assisted Development

| Guide | Note |
| --- | --- |
| [AGENTS.md Guidelines](agents-md/agents-md-guidelines.md) | Creating effective AGENTS.md files |
| [Agentic Workflow](agentic-workflow/agentic-workflow.md) | MAP-FIRST workflow |
| [Prompting Patterns](prompting-patterns/prompting-patterns.md) | |
| [Context Management](context-management/context-management.md) | |
| [Code Review for AI Output](code-review-ai/code-review-ai.md) | |
| [Security Boundaries](security-boundaries/security-boundaries.md) | |
| [Testing AI-Generated Code](testing-ai-code/testing-ai-code.md) | |
| [Git Workflows with AI](git-workflows-ai/git-workflows-ai.md) | |
| [Debugging with AI](debugging-with-ai/debugging-with-ai.md) | |
| [Multi-File Refactoring](multi-file-refactoring/multi-file-refactoring.md) | |
| [Human-AI Collaboration](human-ai-collaboration/human-ai-collaboration.md) | |
| [Tool Configuration](tool-configuration/tool-configuration.md) | |
| [PRD for Agents](prd-for-agents/prd-for-agents.md) | Specs AI can consume |
| [Architecture for AI](architecture-for-ai/architecture-for-ai.md) | System docs that prevent hallucination |

---

## Style Requirements

Follow [Writing Best Practices](writing-best-practices/writing-best-practices.md) strictly.

| Requirement | Rationale |
| --- | --- |
| Tables > bullets > prose | Maximizes scannability |
| Good/Bad code examples | Clarifies by contrast |
| Each guide in own subdirectory | Predictable file locations |

---

## Operational Rules

| Action | Permission | Rationale |
| --- | --- | --- |
| Update README | **Required** | When adding new guides |
| Fix broken links | **Always** | Maintains graph integrity |
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
