# Skills

Procedural workflow skills that agents can auto-discover and follow. Each skill is a concise, step-by-step wrapper backed by a deep guide in `guides/`.

> **Skills vs Guides**: Skills tell agents *what to do* (imperative, procedural). Guides explain *why* (principles, rationale, anti-patterns). Skills reference guides for depth; agents use both.

## Available Skills

| Skill | Trigger | Deep Guide(s) |
| --- | --- | --- |
| [debugging](debugging/SKILL.md) | Diagnosing bugs, test failures, unexpected behavior | [Debugging with AI](../guides/debugging-with-ai/debugging-with-ai.md) |
| [code-review](code-review/SKILL.md) | Reviewing code, preparing PRs for review | [Code Review for AI Output](../guides/code-review-ai/code-review-ai.md) |
| [testing](testing/SKILL.md) | Writing tests, designing test strategy | [Testing Strategy](../guides/testing-strategy/testing-strategy.md), [Testing AI Code](../guides/testing-ai-code/testing-ai-code.md) |
| [planning](planning/SKILL.md) | Planning multi-step tasks, writing implementation plans | [Planning Documentation](../guides/planning-documentation/planning-documentation.md), [Agentic Workflow](../guides/agentic-workflow/agentic-workflow.md) |
| [pr-writing](pr-writing/SKILL.md) | Creating PRs, writing commit messages | [Git Workflows with AI](../guides/git-workflows-ai/git-workflows-ai.md) |
| [secure-coding](secure-coding/SKILL.md) | Security-sensitive code, auth, user input | [Secure Coding](../guides/secure-coding/secure-coding.md), [Security Boundaries](../guides/security-boundaries/security-boundaries.md) |
| [prompting](prompting/SKILL.md) | Crafting prompts, managing AI context | [Prompting Patterns](../guides/prompting-patterns/prompting-patterns.md), [Context Management](../guides/context-management/context-management.md) |
| [refactoring](refactoring/SKILL.md) | Large changes across multiple files | [Multi-File Refactoring](../guides/multi-file-refactoring/multi-file-refactoring.md) |
| [e2e-testing](e2e-testing/SKILL.md) | Writing or fixing end-to-end tests | [E2E Testing](../guides/e2e-testing/e2e-testing.md) |
| [doc-maintenance](doc-maintenance/SKILL.md) | Keeping docs in sync with code changes | [Documentation Maintenance](../guides/doc-maintenance/doc-maintenance.md) |
| [issue-writing](issue-writing/SKILL.md) | Filing bug reports, feature requests, task tickets | Standalone |
| [git-workflow](git-workflow/SKILL.md) | Branching, committing, conflict resolution, PRs | [Git Workflows with AI](../guides/git-workflows-ai/git-workflows-ai.md) |
| [logging](logging/SKILL.md) | Structured logging, log levels, redaction | [Logging Practices](../guides/logging-practices/logging-practices.md) |
| [deployment](deployment/SKILL.md) | Production deploys, rollback, verification | [Deployment Strategies](../guides/deployment-strategies/deployment-strategies.md) |

## SKILL.md Format

Each skill lives in `skills/<name>/SKILL.md` with:

```yaml
---
name: skill-name
description: Trigger condition — when should agents activate this skill
---
```

Followed by procedural steps in markdown.

## Installation

Skills can be installed into projects via the adoption script:

```bash
bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/adopt-into-project.sh" \
  --project-dir . \
  --standards-path "$AGENTIC_BEST_PRACTICES_HOME" \
  --install-skills \
  --skills-agent claude
```

See [Adoption Guide](../adoption/adoption.md) for details.
