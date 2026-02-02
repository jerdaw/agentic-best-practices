# AGENTS.md Guidelines

A reference for creating and maintaining effective AGENTS.md files for AI coding assistants.

> **Scope**: This document provides general-purpose guidance applicable to any project's AGENTS.md file. It intentionally contains no project-specific details. All examples use fictional/generic codebases to illustrate patterns. When applying these guidelines, adapt the examples to your specific project's needs.

Based on analysis of 2,500+ repositories and industry best practices.

## Contents

| Section |
| --- |
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
| --- | --- |
| **Agent Role** | Define who the agent is and their prioritized principles. |
| **Tech Stack** | List technologies with explicit version numbers. |
| **Key Commands** | Provide full executable commands with flags. |
| **Boundaries** | Define critical rules (Always / Ask First / Never). |

**Common Mistakes**:

| Mistake | Impact |
| --- | --- |
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
| --- | --- | --- |
| `AGENTS.md` | GitHub Copilot, Codex, Factory | Emerging standard; broad compatibility |
| `CLAUDE.md` | Claude Code | Anthropic's implementation |
| `CODEX.md` | OpenAI Codex (legacy) | Transitioning to AGENTS.md |
| `.cursorrules` | Cursor | Tool-specific format |

**Recommendation**: Use `AGENTS.md` for broadest compatibility across tools. Symlink `CLAUDE.md → AGENTS.md` to support Claude Code while maintaining a standard single source of truth.

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

Not every section is required. Start with Agent Role, Tech Stack, Commands, and Boundaries, then expand as needed.

---

## Section Guidelines

### Agent Role

Define a specialist persona with ordered priorities. The agent should know what to optimize for when trade-offs arise.

**Good:**
```markdown
You are a **security-conscious backend developer** working on a payment processing API. Your priorities:
1. Security over convenience
2. Explicit error handling
3. Comprehensive logging
4. Performance (but never at the expense of security)
```

**Bad:**
```markdown
You are a helpful coding assistant that helps with this project.
```

**Why it matters**: When an agent faces a choice between a quick fix and a secure fix, the prioritized list tells it which to choose.

### Tech Stack

Use a table with explicit versions. Agents often assume the latest version, which can cause compatibility issues.

**Good:**

| Layer | Technology | Version |
| --- | --- | --- |
| Framework | Express | 4.x |
| Language | TypeScript | 5.x |
| Runtime | Node.js | 20+ |
| Database | PostgreSQL | 15 |
| ORM | Prisma | 5.x |

**Bad:**
```markdown
We use Express, TypeScript, and Node.
```

### Commands

Include full syntax with flags. Group by category (dev, test, build, deploy).

**Good:**
```bash
# Development
npm run dev              # Start with hot reload (port 3000)
npm run dev:debug        # Start with Node inspector attached

# Testing
npm test                 # Run all unit tests
npm test -- --watch      # Watch mode
npm run test:coverage    # With coverage report (threshold: 80%)
npm run test:e2e         # Playwright E2E tests

# Build & Deploy
npm run build            # Production build
npm run lint             # ESLint (must pass before commit)
npm run lint -- --fix    # Auto-fix lint issues
```

**Bad:**
```markdown
Run tests with npm test. You can also run coverage tests.
```

### Boundaries (Three-Tier)

The most impactful section. Prevents costly mistakes and clarifies decision authority.

| Level | Action | Why |
| --- | --- | --- |
| **Always** | Run lint/type-check before commit | Ensures code quality and CI success. |
| **Always** | Write tests for new functions | Prevents regressions and proves logic. |
| **Always** | Use project logger | Centralizes observability; avoid console.log. |
| **Ask First** | Database schema changes | Migrations require review for data safety. |
| **Ask First** | New dependencies | Impacts bundle size and security surface. |
| **Ask First** | Modify CI/CD | Critical infrastructure security gate. |
| **Never** | Commit secrets/.env files | Prevents security breaches and leaks. |
| **Never** | Force push to main | Protects history and team collaboration. |
| **Never** | Bypass security checks | Maintains system integrity. |

**Tip**: After an agent makes a mistake, add a corresponding boundary to prevent recurrence.

---

### Infrastructure Boundaries

If your project has production servers or remote infrastructure that agents cannot access, state this explicitly:

| Constraint | Requirement | Why |
| --- | --- | --- |
| **Access** | No SSH/Remote Access | Security boundary; agents have no credentials. |
| **Execution** | Suggest commands only | Operator must verify and run manually. |
| **Formatting** | Copy/Paste blocks | Minimizes operator error during execution. |

---

### Code Examples

Show real patterns. An example is worth a thousand words of explanation.

**Good:**

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

**Bad:**
```markdown
Use proper error handling in all functions.
```

<!-- BEGIN USER-SPECIFIED: Do not modify -->
### Self-Documenting Code

Write code that's immediately clear through naming and structure. If you need a comment to explain what code does, refactor instead.

**Good:**

```typescript
function calculateRefundForCancelledSubscription(subscription: Subscription): Money {
  const unusedDays = subscription.daysRemainingInBillingCycle()
  const dailyRate = subscription.monthlyPrice.divideBy(30)
  return dailyRate.multiplyBy(unusedDays)
}
```

**Bad:**

```typescript
// Calculate the refund amount (what we owe the customer)
function calc(sub: Subscription): number {
  const d = sub.end - sub.current  // Days left
  const r = sub.price / 30         // Daily rate
  return r * d                      // Refund amount
}
```

**Exception**: Comments explaining *why* (business rules, external constraints) are fine. Comments explaining *what* mean the code needs refactoring.
<!-- END USER-SPECIFIED -->

### Common Pitfalls

Use a table for quick scanning. Include the fix, not just the problem.

| Symptom | Likely Cause | Fix |
| --- | --- | --- |
| Tests timeout | Missing mock for external service | Add mock in test setup |
| Build fails on CI | Works locally | Check Node version matches CI |
| Type errors after pull | Schema changed | Run `npm run generate` |
| Auth redirects loop | Cookie not set | Check HTTPS/secure cookie settings |

---

### When You're Stuck

Help agents recover when they hit blockers with explicit recovery steps.

| Step | Action | Rationale |
| --- | --- | --- |
| **1. Explore** | Run `npm run docs` | Self-service technical context. |
| **2. Observe** | Check `logs/` directory | Reveals runtime errors and trace IDs. |
| **3. Compare** | Search `tests/` for patterns | Existing tests show valid usage patterns. |
| **4. Contextualize** | Run `git log -20` | Understand recent evolution of changes. |
| **5. Escalate** | Ask before big changes (>3 files) | Prevents architectural thrash. |

---

### Critical Files

Point agents to the most important files. Use `file:line` format for precise navigation in IDEs.

**Good:**

| Component | Path |
| --- | --- |
| Entry Point | `src/index.ts` |
| Routes | `src/routes/index.ts:15` |
| Middleware | `src/middleware/auth.ts:42` |
| DB Config | `src/config/database.ts` |
| Types | `src/types/` |

**Bad:**
```markdown
The main files are in src/. Look at index.ts to start.
```

---

### User-Specified Content

Mark sections that are explicitly authored by humans and must not be modified, removed, or contradicted by AI agents.

**When to Use Boundary Markers:**

| Situation | Value |
| --- | --- |
| **Contradictory decisions** | Protects specific logic that overrides "best" practices. |
| **Historical rationale** | Preserves context AI might deem redundant. |
| **Onboarding tone** | Maintains specific human-to-human instructions. |
| **Policy/Legal** | Ensures critical compliance text is never "optimized". |

**Good:**
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
| --- | :---: | :---: |
| Build/test/lint commands | ✓ | |
| Project architecture | ✓ | |
| Code style conventions | ✓ | |
| Repeatable workflows | ✓ | |
| Security boundaries | ✓ | |
| One-off task instructions | | ✓ |
| Session-specific context | | ✓ |
| Temporary debugging needs | | ✓ |

**Persistence test**: Would you want this instruction to apply to every future session? If yes → AGENTS.md. If no → prompt.

---

## Anti-Patterns to Avoid

| Anti-Pattern | Problem | Fix |
| --- | --- | --- |
| **Vague persona** | Agent doesn't know priorities | Define specific role + ordered priorities |
| **Prose-only rules** | Hard to scan, easy to miss | Use tables, lists, three-tier boundaries |
| **Missing versions** | Agent assumes latest tech | Table with explicit versions |
| **Overly long file** | Agent loses focus/context | Keep under 500 lines; link to sub-docs |
| **Unmarked user decisions** | Agent "improves" intentional choices | Mark with `<!-- BEGIN USER-SPECIFIED -->` blocks |

---

## Hierarchy & Monorepos

AGENTS.md supports hierarchical placement. The closest file to the code being edited takes precedence.

```text
repo/
├── AGENTS.md              # Root: org-wide standards
├── packages/
│   ├── api/
│   │   └── AGENTS.md      # API-specific conventions
│   └── shared/
│       └── AGENTS.md      # Shared lib conventions
```

Nested files should focus only on local overrides/additions to the root file.

---

## Maintenance & Updates

| Practice | Frequency | Value |
| --- | --- | --- |
| **Update on Error** | Immediately | Converts a mistake into a permanent boundary. |
| **Technical Update** | Per dependency change | Keeps environment info accurate. |
| **Quarterly Review** | Every 3 months | Prunes stale patterns and verifies examples. |
| **Pattern Addition** | Per new convention | Builds institutional logic for the agent. |

---

## Minimal Template

For new projects, start with this and expand as patterns emerge:

```markdown
# AGENTS.md – [Project Name]

## Agent Role
You are a [specific role] working on [project type]. Your priorities:
1. [Primary Principle]
2. [Secondary Principle]

## Tech Stack
| Layer | Technology | Version |
| --- | --- | --- |
| Language | | |

## Key Commands
\`\`\`bash
npm run dev      # Start dev server
npm test         # Run tests
\`\`\`

## Boundaries
| Level | Action | Why |
| --- | --- | --- |
| **Always** | Run lint before commit | Quality gate |
| **Never** | Commit .env files | Security |

## User-Specified Content
Use \`<!-- BEGIN USER-SPECIFIED -->\` to mark human-authored sections.
```

---

## References

- [GitHub Blog: How to write a great agents.md](https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/)
- [agents.md specification](https://agents.md/)
- [Instruction Files Overview](https://aruniyer.github.io/blog/agents-md-instruction-files.html)
- [Architecture for AI](../architecture-for-ai/architecture-for-ai.md) – System docs that agents consume
