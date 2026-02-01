# AGENTS.md Guidelines

A reference for creating and maintaining effective AGENTS.md files for AI coding assistants.

> **Scope**: This document provides general-purpose guidance applicable to any project's AGENTS.md file. It intentionally contains no project-specific details. All examples use fictional/generic codebases to illustrate patterns. When applying these guidelines, adapt the examples to your specific project's needs.

Based on analysis of 2,500+ repositories and industry best practices.

---

## Quick Reference

**Essential sections** (minimum viable AGENTS.md):
1. Agent Role – Who the agent is, with prioritized principles
2. Tech Stack – Technologies with versions
3. Key Commands – Full syntax with flags
4. Boundaries – Always / Ask First / Never

**Most common mistakes**:
- Vague persona ("helpful assistant")
- Commands without flags
- No boundaries section
- Prose instead of scannable lists/tables
- Not marking user-specified content that AI shouldn't modify

**Rule of thumb**: If you'd repeat it across sessions, put it in AGENTS.md.

---

## Core Principles

1. **Specialist over generalist** – Define a specific role, not "helpful coding assistant"
2. **Show, don't tell** – Code examples beat prose explanations
3. **Actionable over descriptive** – Commands with flags, not theoretical descriptions
4. **Boundaries are critical** – Clear Always/Ask First/Never rules prevent mistakes
5. **Living document** – Update when patterns change; tell the agent to "update AGENTS.md with..."
6. **Stay in sync** – The file should reflect actual practices, not aspirational ones
7. **Progressive disclosure** – Keep AGENTS.md focused; link to detailed docs for deep dives
8. **Self-documenting code** – Write code so clear it needs no comments; refactor instead of explaining

---

## File Naming & Compatibility

Several naming conventions exist across different AI tools:

| File | Primary Tool | Notes |
|------|--------------|-------|
| `AGENTS.md` | GitHub Copilot, Codex, Factory | Emerging standard; broad compatibility |
| `CLAUDE.md` | Claude Code | Anthropic's implementation |
| `CODEX.md` | OpenAI Codex (legacy) | Transitioning to AGENTS.md |
| `.cursorrules` | Cursor | Tool-specific format |

**Recommendation**: Use `AGENTS.md` for broadest compatibility across tools. If using Claude Code specifically, you can symlink `CLAUDE.md → AGENTS.md` to support both.

---

## Recommended Structure

```
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
```
You are a **security-conscious backend developer** working on a payment processing API. Your priorities:
1. Security over convenience
2. Explicit error handling
3. Comprehensive logging
4. Performance (but never at the expense of security)
```

**Bad:**
```
You are a helpful coding assistant that helps with this project.
```

**Why it matters**: When an agent faces a choice between a quick fix and a secure fix, the prioritized list tells it which to choose.

### Tech Stack

Use a table with explicit versions. Agents often assume the latest version, which can cause compatibility issues.

**Good:**

| Layer | Technology | Version |
|-------|------------|---------|
| Framework | Express | 4.x |
| Language | TypeScript | 5.x |
| Runtime | Node.js | 20+ |
| Database | PostgreSQL | 15 |
| ORM | Prisma | 5.x |

**Bad:**
```
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
```
Run tests with npm test. You can also run coverage tests.
```

### Boundaries (Three-Tier)

The most impactful section. Prevents costly mistakes and clarifies decision authority.

```
### ✅ Always
- Run `npm run lint` and `npm run type-check` before committing
- Write tests for new functionality
- Use the project's logger instead of console.log
- Handle errors explicitly (no silent catches)
- Update types when changing data structures
- Ensure git commits list only human authors

### ⚠️ Ask First
- Database schema changes (migrations)
- Changes to authentication or authorization logic
- Adding new dependencies (especially large ones)
- Removing or skipping tests
- Changing public API contracts
- Modifying CI/CD configuration

### 🚫 Never
- Commit, view, or access secrets, API keys, or `.env` files
- Disable or bypass security checks
- Force push to main/master
- Skip pre-commit hooks (`--no-verify`)
- Delete or modify production data directly
- Merge without passing CI
- SSH to production servers or attempt remote command execution (if applicable)
- List AI agents as commit authors or co-authors
```

**Tip**: After an agent makes a mistake, add a corresponding boundary to prevent recurrence.

**Infrastructure boundaries**: If your project has production servers or remote infrastructure that agents cannot access, state this explicitly at the top of your file:

```
**CRITICAL: AI agents do NOT have access to production infrastructure.**
- You CANNOT run commands on production servers (no SSH, no remote execution)
- You CAN ONLY suggest commands for the operator to run manually
- Format troubleshooting commands as copy/paste examples for the operator
```

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
```
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
|---------|--------------|-----|
| Tests timeout | Missing mock for external service | Add mock in test setup |
| Build fails on CI | Works locally | Check Node version matches CI |
| Type errors after pull | Schema changed | Run `npm run generate` |
| Auth redirects loop | Cookie not set | Check HTTPS/secure cookie settings |

### When You're Stuck

Help agents recover when they hit blockers. Include debugging steps and escalation paths.

**Good:**
```
## When You're Stuck

1. **Check the docs**: Run `npm run docs` to browse API documentation locally
2. **Read the logs**: Server logs are in `logs/`, API errors include correlation IDs
3. **Check tests**: Look for similar test cases in `tests/` for usage examples
4. **Examine recent changes**: `git log --oneline -20` for context on recent work
5. **Ask before big changes**: If a fix requires touching >3 files, explain your plan first
```

### Critical Files

Point agents to the most important files. Use `file:line` format for precise navigation in IDEs.

**Good:**
```
## Critical Files

| What | Where |
|------|-------|
| App entry point | `src/index.ts` |
| Route definitions | `src/routes/index.ts:15` |
| Auth middleware | `src/middleware/auth.ts:42` |
| Database config | `src/config/database.ts` |
| Type definitions | `src/types/` |
```

**Bad:**
```
The main files are in src/. Look at index.ts to start.
```

### User-Specified Content

Mark sections that are explicitly authored by humans and must not be modified, removed, or contradicted by AI agents. This protects critical human decisions, project-specific requirements, or carefully crafted documentation that AI might otherwise "improve" inappropriately.

**Good:**

```markdown
<!-- BEGIN USER-SPECIFIED: Do not modify -->
## Deployment Philosophy

We deploy on Fridays. Yes, really. This is an explicit decision based on our team's
workflow and on-call rotation. Do not suggest changing this or adding deployment
guards for Fridays.

Our staging environment uses production data snapshots. This is intentional and
approved by security. Do not suggest using synthetic data or anonymization.
<!-- END USER-SPECIFIED -->
```

Or for inline protection:

```markdown
## Testing Requirements

- Unit tests required for all new functions
- E2E tests for critical user paths
- <!-- USER-SPECIFIED: 60% coverage minimum (not 80%) - this is intentional due to legacy code --> Coverage threshold: 60%
```

**Alternative markers** (use consistently within your project):

```markdown
<!-- AI: DO NOT MODIFY THIS SECTION -->
...content...
<!-- AI: END PROTECTED SECTION -->
```

or

```markdown
<!-- ✋ HUMAN-AUTHORED: No AI modifications -->
...content...
<!-- ✋ END HUMAN-AUTHORED -->
```

**Bad:**

```markdown
## Deployment Philosophy

We deploy on Fridays. [Agent might "helpfully" add warnings about Friday deployments]
```

**Why it matters**: AI agents are trained to follow best practices, which sometimes conflict with legitimate project-specific decisions. Marking content as user-specified prevents agents from:
- "Improving" deliberately simple code that serves as a teaching example
- Contradicting your documented decisions elsewhere in the file
- Removing context that seems redundant but captures important history
- Standardizing intentionally non-standard approaches

**When to use**:
- Documenting decisions that contradict common best practices (with justification)
- Preserving historical context or rationale that AI might deem unnecessary
- Protecting specific wording in onboarding instructions or style guides
- Marking sections that should only be updated by senior engineers

<!-- BEGIN USER-SPECIFIED: Do not modify -->
**Git Authorship**: While AI agents may create commits with human oversight, only humans should be listed as commit authors or co-authors. No AI agents, assistants, or tools should appear in author fields. This maintains proper attribution, legal accountability, and copyright clarity in version control history.

Example boundary:

```markdown
### ✅ Always
- Ensure git commits list only human authors and co-authors
- Have a human take full authorship responsibility for all commits

### 🚫 Never
- List AI agents as commit authors or co-authors
- Include AI assistants in Co-Authored-By trailers
- Commit changes without a human listed as the author
```
<!-- END USER-SPECIFIED -->

**Integration with Boundaries**: Consider adding to your boundaries section:

```markdown
### 🚫 Never
- Modify, remove, or contradict content within `<!-- BEGIN USER-SPECIFIED -->` blocks
- "Improve" or "fix" code examples marked as USER-SPECIFIED
- Add conflicting guidance that overrides USER-SPECIFIED sections
- List AI agents as commit authors or co-authors
```

---

## What Belongs Where

| Content Type | AGENTS.md | Prompt |
|--------------|:---------:|:------:|
| Build/test/lint commands | ✓ | |
| Project architecture | ✓ | |
| Code style conventions | ✓ | |
| Repeatable workflows | ✓ | |
| Security boundaries | ✓ | |
| One-off task instructions | | ✓ |
| Session-specific context | | ✓ |
| Temporary debugging needs | | ✓ |
| Bug ticket details | | ✓ |
| Experimental approaches | | ✓ |

**Persistence test**: Would you want this instruction to apply to every future session? If yes → AGENTS.md. If no → prompt.

**Pollution warning**: Adding one-off instructions to AGENTS.md creates noise and can mislead agents in future sessions.

---

## Anti-Patterns to Avoid

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| Vague persona | Agent doesn't know priorities | Define specific role + ordered priorities |
| Commands without flags | Agent guesses options | Include full syntax with common flags |
| Prose-only rules | Hard to scan, easy to miss | Use tables, lists, three-tier boundaries |
| No code examples | Agent invents patterns | Show real examples from codebase |
| Missing versions | Agent assumes latest | Table with explicit versions |
| Overly long file | Agent loses focus | Keep under 500 lines; link to docs |
| No boundaries | Agent makes risky changes | Always include boundaries section |
| Stale examples | Agent follows outdated patterns | Review quarterly; update after refactors |
| Conflicting instructions | Agent gets confused | Audit for contradictions |
| Duplicated docs | Drift between sources | Single source of truth; link don't copy |
| Unmarked user decisions | Agent "improves" intentional choices | Mark with `<!-- BEGIN USER-SPECIFIED -->` blocks |

---

## Hierarchy & Monorepos

AGENTS.md supports hierarchical placement. The closest file to the code being edited takes precedence.

```
repo/
├── AGENTS.md              # Root: org-wide standards
├── packages/
│   ├── api/
│   │   └── AGENTS.md      # API-specific: auth patterns, DB conventions
│   ├── web/
│   │   └── AGENTS.md      # Frontend-specific: component patterns, state
│   └── shared/
│       └── AGENTS.md      # Shared lib: export conventions, versioning
```

**Root file**: General standards (commit conventions, CI requirements, code style)
**Package files**: Technology-specific patterns, local commands, package-specific boundaries

Nested files don't need to repeat root guidance—agents read up the tree.

**Example nested AGENTS.md** (for a subpackage):

```markdown
# AGENTS.md – api subpackage

This package handles REST API endpoints and database access.

## Key Constraint
This package is the **only** place that directly accesses the database.
Other packages must go through the API client in `shared/`.

## Module Map
| Module | Purpose |
|--------|---------|
| `routes/` | Express route handlers |
| `models/` | Prisma schema and queries |
| `middleware/` | Auth, logging, rate limiting |

## Local Commands
```bash
npm run db:migrate    # Run pending migrations
npm run db:seed       # Seed test data
npm run test:api      # API-specific tests only
```

## When Changing This Package
1. Update OpenAPI spec if changing route signatures
2. Add migration if changing Prisma schema
3. Update `shared/api-client` if changing response shapes
```

---

## When to Update

| Trigger | Action |
|---------|--------|
| Agent made a preventable mistake | Add to Boundaries (Never or Ask First) |
| New pattern established | Add code example |
| Dependency upgraded | Update version in Tech Stack |
| New command added | Add to Commands with flags |
| Refactored architecture | Update Architecture section |
| Onboarded new team member | Note what confused them |
| Quarterly review | Remove stale content, verify examples still work |

---

## Maintenance Tips

1. **Review quarterly** – Remove stale patterns, verify examples compile
2. **Update after incidents** – Every agent mistake is a missing boundary
3. **Keep it DRY** – Link to detailed docs instead of duplicating
4. **Version in git** – Track changes to understand what guidance evolved
5. **Test your examples** – Stale code examples actively mislead
6. **Ask agents to update it** – "Please add this pattern to AGENTS.md" builds institutional knowledge
7. **Read your own file** – If you can't scan it quickly, neither can the agent
8. **Use progressive disclosure** – AGENTS.md should provide essential context, not exhaustive documentation. Add a note like: "This file provides essential context. For deep dives on specific subsystems, see the linked docs."

---

## Minimal Template

For new projects, start with this and expand as patterns emerge:

```markdown
# AGENTS.md – [Project Name]

## Agent Role

You are a [specific role] working on [project type]. Your priorities:
1. [Most important principle]
2. [Second priority]
3. [Third priority]

## Tech Stack

| Layer | Technology | Version |
|-------|------------|---------|
| Language | | |
| Framework | | |
| Database | | |

## Key Commands

```bash
npm run dev      # Start development server
npm test         # Run tests
npm run lint     # Lint code
npm run build    # Production build
```

## Code Style

### ✅ Always
- Write self-documenting code with clear, descriptive names
- Refactor unclear code rather than adding explanatory comments
- Extract complex logic into well-named functions

### 🚫 Never
- Add comments explaining what code does (refactor instead)
- Use cryptic abbreviations or unclear variable names

## Boundaries

### ✅ Always
- Run linting before committing
- Ensure git commits list only human authors and co-authors
- [Add project-specific requirements]

### ⚠️ Ask First
- Database schema changes
- Adding new dependencies

### 🚫 Never
- Commit secrets or `.env` files
- Force push to main
- List AI agents as commit authors or co-authors
- Modify content within `<!-- BEGIN USER-SPECIFIED -->` blocks

## Critical Files

- `src/index.ts` – Application entry point
- [Add key files as project grows]

## User-Specified Content

Use `<!-- BEGIN USER-SPECIFIED -->` and `<!-- END USER-SPECIFIED -->` to mark
sections that AI agents must not modify or contradict. Useful for protecting
project-specific decisions that might conflict with general best practices.

```

---

## References

- [GitHub Blog: How to write a great agents.md](https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/) – Analysis of 2,500+ repositories
- [agents.md specification](https://agents.md/) – Official format documentation
- [Instruction Files Overview](https://aruniyer.github.io/blog/agents-md-instruction-files.html) – Comparison of formats
