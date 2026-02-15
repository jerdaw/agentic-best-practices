# AGENTS.md Guidelines

A reference for creating and maintaining effective AGENTS.md files for AI coding assistants.

> **Scope**: This document provides general-purpose guidance applicable to any project's AGENTS.md file. It
> intentionally contains no project-specific details. All examples use fictional/generic codebases to illustrate
> patterns.

## Contents

| Section |
| :--- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [File Naming & Compatibility](#file-naming--compatibility) |
| [Recommended Structure](#recommended-structure) |
| [Section Guidelines](#section-guidelines) |
| [What Belongs Where](#what-belongs-where) |
| [Anti-Patterns to Avoid](#anti-patterns-to-avoid) |
| [Hierarchy & Monorepos](#hierarchy--monorepos) |
| [Maintenance & Updates](#maintenance--updates) |
| [Minimal Template](#minimal-template) |

---

## Quick Reference

**Essential Sections** (Minimum Viable AGENTS.md):

| Section | Purpose |
| :--- | :--- |
| **Agent Role** | Define who the agent is and their prioritized principles. |
| **Tech Stack** | List technologies with explicit version numbers. |
| **Key Commands** | Provide full executable commands with flags. |
| **Boundaries** | Define critical rules (Always / Ask First / Never). |

**Common Mistakes**:

| Mistake | Impact |
| :--- | :--- |
| **Vague persona** | Agent lacks decision priorities (e.g., "helpful assistant"). |
| **Commands without flags** | Agent guesses options, often incorrectly. |
| **No boundaries** | Risky changes (deletions, secrets) go unchecked. |
| **Prose walls** | High token cost, low comprehension. |
| **Unprotected content** | AI overrides intentional user decisions. |

**Rule of thumb**: If you'd repeat it across sessions, put it in AGENTS.md.

---

## Core Principles

1. **Specialist over generalist** – Define a specific role with ordered priorities.
2. **Show, don't tell** – Use concrete code examples and actionable commands with flags.
3. **Boundaries are critical** – Clear rules (Always/Ask First/Never) prevent regressions and errors.
4. **Living document** – Update proactively as patterns evolve; tell the agent to update it.
5. **Progressive disclosure** – Keep focus on essentials; link to deep-dive docs for subsystems.
6. **Self-documenting focus** – Prioritize clear naming and structure over explanatory comments.

---

## File Naming & Compatibility

Several naming conventions exist across different AI tools:

| File | Primary Tool | Notes |
| :--- | :--- | :--- |
| `AGENTS.md` | GitHub Copilot | Emerging standard; broad compatibility |
| `CLAUDE.md` | Claude Code | Anthropic's implementation |
| `CODEX.md` | OpenAI Codex | Transitioning to AGENTS.md |
| `.cursorrules` | Cursor | Tool-specific format |

---

## Recommended Structure

```markdown
# AGENTS.md – [Project Name]

## Agent Role
[Persona + priorities - what the agent IS, not just what the project is]

## Project Overview
[Mission, philosophy, tech stack with versions]

## Key Commands
[Executable commands with flags, grouped by category]

## Verification Gates
[Exactly which checks must pass before proposing completion]

## Documentation Map
[Where to find ADRs, runbooks, API docs, and specs]

## Architecture
[System design, data flow, key patterns with code examples]

## Code Style & Conventions
[Real examples of good patterns; emphasize self-documenting code over comments]

## Testing Strategy
[Framework, coverage requirements, expectations]

## Boundaries
[Three-tier: Always / Ask First / Never]

## User-Specified Content
[Sections explicitly marked as human-authored; AI agents must not modify]

## Critical Files
[Entry points and key files to understand; use file:line format for navigation]

## Common Pitfalls
[Symptom → Cause → Fix format]

## When You're Stuck
[Debugging steps and escalation paths]
```

---

## Section Guidelines

### Agent Role

Define a specialist persona with ordered priorities.

**Good**:

```markdown
You are a **security-conscious backend developer** working on a payment processing API. Your priorities:
1. Security over convenience
2. Explicit error handling
3. Comprehensive logging
```

### Tech Stack

Use a table with explicit versions.

| Layer | Technology | Version |
| :--- | :--- | :--- |
| Framework | Express | 4.x |
| Language | TypeScript | 5.x |
| Runtime | Node.js | 20+ |

### Commands

Include full syntax with flags. Group by category (dev, test, build, deploy).

```bash
# Development
npm run dev              # Start with hot reload (port 3000)
npm run dev:debug        # Start with Node inspector attached

# Testing
npm test                 # Run all unit tests
npm test -- --watch      # Watch mode
npm run test:coverage    # With coverage report (threshold: 80%)
```

---

### Verification Gates

`AGENTS.md` should define a fixed completion gate so agents do not stop after code edits without verification.

| Gate Type | Example | Why |
| :--- | :--- | :--- |
| Compile/type-check | `npm run typecheck` | Catches structural API mismatches quickly |
| Unit/integration tests | `npm test` | Verifies behavior changes |
| Lint/format | `npm run lint` | Prevents style and quality drift |
| Repo-specific validation | `npm run validate` | Enforces project conventions and docs integrity |

| Rule | Guidance |
| :--- | :--- |
| Command reliability | Only include commands already proven in CI or local docs |
| Deterministic output | Prefer commands with stable pass/fail status |
| Scope control | Separate fast checks from full checks to avoid skipped validation |

---

### Documentation Map

Agent instructions should point to high-value docs, not just code locations.

| Documentation Type | Suggested Location | Agent Behavior |
| :--- | :--- | :--- |
| ADRs | `docs/adr/` | Read when a change touches architecture, queues, data models, or API contracts |
| Runbooks | `docs/process/` or `docs/runbooks/` | Read for operational changes and incident-sensitive logic |
| API reference | `docs/api/` or generated docs | Validate public contract changes before editing handlers |
| Standards guides | central standards path | Resolve policy/style decisions before implementation |

| Anti-Pattern | Better Pattern |
| :--- | :--- |
| "See docs" with no path | Explicit path: `docs/adr/adr-004-...md` |
| Duplicating long rules in multiple files | Keep canonical rule once and link to it |

---

### Boundaries (Three-Tier)

| Level | Action | Why |
| :--- | :--- | :--- |
| **Always** | Run lint/type-check | Ensures code quality and CI success. |
| **Always** | Write tests | Prevents regressions and proves logic. |
| **Always** | Use project logger | Centralizes observability; avoid console.log. |
| **Ask First** | DB schema changes | Migrations require review for data safety. |
| **Ask First** | New dependencies | Impacts bundle size and security surface. |
| **Never** | Commit secrets | Prevents security breaches and leaks. |

---

### Code Examples

Show real patterns.

**Error handling** – Always use the Result pattern:

```typescript
// Good: Explicit error handling
const result = await fetchUser(id)
if (result.error) {
  logger.error("Failed to fetch user", { id, error: result.error })
  return { error: "User not found" }
}
return { data: result.data }
```

**Self-Documenting Code**:

```typescript
function calculateRefundForCancelledSubscription(subscription: Subscription): Money {
  const unusedDays = subscription.daysRemainingInBillingCycle()
  const dailyRate = subscription.monthlyPrice.divideBy(30)
  return dailyRate.multiplyBy(unusedDays)
}
```

---

### Common Pitfalls

| Symptom | Likely Cause | Fix |
| :--- | :--- | :--- |
| Tests timeout | Missing mock | Add mock in test setup |
| Build fails on CI | Node version | Check Node version matches CI |
| Type errors | Schema changed | Run `npm run generate` |

---

### When You're Stuck

| Step | Action | Rationale |
| :--- | :--- | :--- |
| **1. Explore** | Run `npm run docs` | Self-service technical context. |
| **2. Observe** | Check `logs/` dir | Reveals runtime errors and trace IDs. |
| **3. Compare** | Search `tests/` | Existing tests show valid usage patterns. |

---

### Critical Files

| Component | Path |
| :--- | :--- |
| Entry Point | `src/index.ts` |
| Routes | `src/routes/index.ts:15` |
| Middleware | `src/middleware/auth.ts:42` |

---

### User-Specified Content

Mark sections that must not be modified by AI agents.

```markdown
<!-- BEGIN USER-SPECIFIED: Do not modify -->
## Deployment Philosophy
We deploy on Fridays. This is an explicit decision based on our team's
on-call rotation. Do not suggest changing this.
<!-- END USER-SPECIFIED -->
```

---

## What Belongs Where

| Content Type | AGENTS.md | Prompt |
| :--- | :---: | :---: |
| Commands | ✓ | |
| Architecture | ✓ | |
| Style | ✓ | |
| Workflows | ✓ | |
| Boundaries | ✓ | |
| One-off tasks | | ✓ |
| Session context | | ✓ |

---

## Anti-Patterns to Avoid

| Anti-Pattern | Problem | Fix |
| :--- | :--- | :--- |
| **Vague persona** | No priorities | Define role + ordered priorities |
| **Prose-only rules** | Hard to scan | Use tables, lists, boundaries |
| **Missing versions** | Tech mismatch | Table with explicit versions |
| **Overly long file** | Loses focus | Keep under 500 lines; link to sub-docs |

---

## Hierarchy & Monorepos

```text
repo/
├── AGENTS.md              # Root: org-wide standards
├── packages/
│   ├── api/
│   │   └── AGENTS.md      # API-specific conventions
│   └── shared/
│       └── AGENTS.md      # Shared lib conventions
```

---

## Maintenance & Updates

| Practice | Frequency | Value |
| :--- | :--- | :--- |
| **Update on Error** | Immediately | Converts mistake into boundary. |
| **Technical Update** | Per change | Keeps environment info accurate. |
| **Quarterly Review**| Every 3 months| Prunes stale patterns. |

---

## Minimal Template

```markdown
# AGENTS.md – [Project Name]

## Agent Role

You are a [role] working on [type]. Your priorities:

1. [Principle 1]

## Tech Stack

| Layer | Technology | Version |
| :--- | :--- | :--- |
| Language | | |

## Key Commands

```bash
npm run dev      # Start dev server
npm test         # Run tests
```

## Boundaries

| Level | Action | Why |
| :--- | :--- | :--- |
| **Always** | Run lint | Quality gate |
| **Never** | Commit secrets | Security |

---

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| AGENTS.md exceeds 500 lines | Split into sub-docs and link | Oversized files waste context tokens and dilute focus |
| No boundaries section (Always / Ask First / Never) | Add one immediately | Without boundaries, agents make risky changes unchecked |
| Commands listed without flags or full syntax | Add complete, copy-paste-ready commands | Incomplete commands force agents to guess options |
| Agent role says "helpful assistant" with no priorities | Define a specialist role with ordered priorities | Vague personas produce generic, low-quality output |
| AGENTS.md not updated after major architecture change | Update to match current reality | Stale AGENTS.md causes agents to follow outdated patterns |

---

## See Also

- [Architecture for AI](../architecture-for-ai/architecture-for-ai.md) – System docs that agents consume
- [Documentation Guidelines](../documentation-guidelines/documentation-guidelines.md) – General writing standards
- [Tool Configuration](../tool-configuration/tool-configuration.md) – Configuring AI tools per-project

---

## References

- [GitHub Blog](https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/)
- [agents.md specification](https://agents.md/)
- [Architecture for AI](../architecture-for-ai/architecture-for-ai.md) – System docs that agents consume
