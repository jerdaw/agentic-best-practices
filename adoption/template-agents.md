# AGENTS.md – [Project Name]

<!--
  SETUP INSTRUCTIONS (delete this block after setup):
  1. Recommended: run scripts/adopt-into-project.sh from agentic-best-practices to render this template
  2. If editing manually: replace [Project Name], [bracketed placeholders], and all {{TOKENS}}
  3. Customize the Tech Stack, Commands, and Boundaries sections
  4. Delete this comment block
  5. Commit: git add AGENTS.md && ln -s AGENTS.md CLAUDE.md && git add CLAUDE.md
-->

## Agent Role

You are a [specific role, e.g., "security-conscious backend developer"] working on [brief project description].

**Priorities** (in order):

1. [First priority, e.g., "Security over convenience"]
2. [Second priority, e.g., "Correctness over speed"]
3. [Third priority, e.g., "Readability over cleverness"]

---

## Contents

| Section |
| --- |
| [Standards Reference](#standards-reference) |
| [Tech Stack](#tech-stack) |
| [Key Commands](#key-commands) |
| [Boundaries](#boundaries) |
| [Project-Specific Overrides](#project-specific-overrides) |
| [Critical Files](#critical-files) |
| [Maintenance](#maintenance) |

---

## Standards Reference

This project follows organizational standards defined in `{{STANDARDS_PATH}}/`.

**Before implementing**, consult the relevant guide:

| Topic | Guide |
| --- | --- |
<!-- markdownlint-disable MD055 MD056 -->
{{STANDARDS_GUIDE_ROWS}}
<!-- markdownlint-enable MD055 MD056 -->

For other topics, check `{{STANDARDS_PATH}}/README.md` for the full guide index (all guides are in `{{STANDARDS_PATH}}/guides/`).

**Deviation policy**: {{DEVIATION_POLICY}}

---

## Tech Stack

| Layer | Technology | Version |
| --- | --- | --- |
| Language | [e.g., TypeScript] | [e.g., 5.x] |
| Framework | [e.g., Express] | [e.g., 4.x] |
| Runtime | [e.g., Node.js] | [e.g., 20+] |
| Database | [e.g., PostgreSQL] | [e.g., 15] |
| Testing | [e.g., Jest] | [e.g., 29.x] |

---

## Key Commands

```bash
# Development
[npm run dev]              # [Start dev server with hot reload]

# Testing
[npm test]                 # [Run all tests]
[npm run test:coverage]    # [Run tests with coverage report]

# Quality
[npm run lint]             # [Run linter]
[npm run typecheck]        # [Run type checker]

# Build
[npm run build]            # [Production build]
```

---

## Boundaries

| Level | Action | Why |
| --- | --- | --- |
| **Always** | Run lint before commit | Catches errors early |
| **Always** | Write tests for new functions | Prevents regressions |
| **Always** | [Add your own] | [Rationale] |
| **Ask First** | Database schema changes | Requires migration review |
| **Ask First** | Add new dependencies | Security and bundle impact |
| **Ask First** | [Add your own] | [Rationale] |
| **Never** | Commit .env or secrets | Security requirement |
| **Never** | Force push to main | Protects shared history |
| **Never** | [Add your own] | [Rationale] |

---

## Project-Specific Overrides

<!--
  Document any intentional deviations from {{STANDARDS_PATH}} here.
  If this section is empty, the project follows all standards without exception.

  Format:
  ### [Topic]
  **Standard**: [What best-practices says]
  **Override**: [What this project does instead]
  **Rationale**: [Why the deviation is necessary]
  **Approved**: [Date]
-->

None. This project follows all organizational standards.

---

## Critical Files

| Component | Path |
| --- | --- |
| Entry point | `[src/index.ts]` |
| Config | `[src/config/]` |
| Routes/API | `[src/routes/]` |
| Core logic | `[src/services/]` |
| Types | `[src/types/]` |

---

## Maintenance

**Periodic tasks**:

| Frequency | Action |
| --- | --- |
| Weekly | `git -C {{STANDARDS_PATH}} pull` to update standards |
| Per feature | Verify patterns align with current standards |
| Quarterly | Review Project-Specific Overrides for continued relevance |
