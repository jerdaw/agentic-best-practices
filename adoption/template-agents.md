# AGENTS.md – [Project Name]

<!--
  SETUP INSTRUCTIONS (delete this block after setup):
  1. Replace [Project Name] with your project name
  2. Fill in all [bracketed placeholders]
  3. Customize the Tech Stack, Commands, and Boundaries sections
  4. Verify the ~/agentic-best-practices path is correct for your setup
  5. Delete this comment block
  6. Commit: git add AGENTS.md && ln -s AGENTS.md CLAUDE.md && git add CLAUDE.md
-->

## Agent Role

You are a [specific role, e.g., "security-conscious backend developer"] working on [brief project description].

**Priorities** (in order):

1. [First priority, e.g., "Security over convenience"]
2. [Second priority, e.g., "Correctness over speed"]
3. [Third priority, e.g., "Readability over cleverness"]

---

## Standards Reference

This project follows organizational standards defined in `~/agentic-best-practices/`.

**Before implementing**, consult the relevant guide:

| Topic | Guide |
| --- | --- |
| Error handling | `~/agentic-best-practices/guides/error-handling/error-handling.md` |
| Logging | `~/agentic-best-practices/guides/logging-practices/logging-practices.md` |
| API design | `~/agentic-best-practices/guides/api-design/api-design.md` |
| Documentation | `~/agentic-best-practices/guides/documentation-guidelines/documentation-guidelines.md` |
| Code style | `~/agentic-best-practices/guides/coding-guidelines/coding-guidelines.md` |
| Comments | `~/agentic-best-practices/guides/commenting-guidelines/commenting-guidelines.md` |

For other topics, check `~/agentic-best-practices/README.md` for the full guide index (all guides are in `~/agentic-best-practices/guides/`).

**Deviation policy**: Do not deviate from these standards without explicit approval. If deviation is necessary, document it in the Project-Specific Overrides section below with rationale.

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
  Document any intentional deviations from ~/agentic-best-practices here.
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
| Weekly | `git -C ~/agentic-best-practices pull` to update standards |
| Per feature | Verify patterns align with current standards |
| Quarterly | Review Project-Specific Overrides for continued relevance |
