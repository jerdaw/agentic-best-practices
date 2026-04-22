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
| [Documentation Map](#documentation-map) |
| [Critical Files](#critical-files) |
| [Maintenance](#maintenance) |

---

## Standards Reference

This project uses shared guidance from `{{STANDARDS_PATH}}/` as its working defaults.

**Before implementing**, consult the relevant guide:

Treat these as the project's recommended defaults for recurring concerns, not as a claim that every default must fit every situation unchanged.

Use `{{STANDARDS_PATH}}/README.md` when work touches a topic outside this shortlist.

| Topic | Guide |
| --- | --- |
<!-- markdownlint-disable MD055 MD056 -->
{{STANDARDS_GUIDE_ROWS}}
<!-- markdownlint-enable MD055 MD056 -->

For other topics, check `{{STANDARDS_PATH}}/README.md` for the full guide index (all guides are in `{{STANDARDS_PATH}}/guides/`).

**Decision policy**: {{DECISION_POLICY}}

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
| **Always** | Update docs/docstrings/comments in the same PR when behavior or API changes | Prevents documentation drift |
| **Always** | [Add your own] | [Rationale] |
| **Ask First** | Database schema changes | Requires migration review |
| **Ask First** | Add new dependencies | Security and bundle impact |
| **Ask First** | [Add your own] | [Rationale] |
| **Never** | Add AI tools or assistants as commit authors, co-authors, or document contributors | Preserves human accountability |
| **Never** | Commit .env or secrets | Security requirement |
| **Never** | Force push to main | Protects shared history |
| **Never** | [Add your own] | [Rationale] |

---

## Skills (Optional)

If skills are installed (via `--install-skills`), agents can auto-discover procedural workflow skills in the skills directory. Each skill provides step-by-step instructions for common workflows backed by the deep guides referenced in Standards Reference above.

See `{{STANDARDS_PATH}}/skills/README.md` for the full skills index.

---

## Project-Specific Overrides

<!--
  Document any intentional project decisions about {{STANDARDS_PATH}} here.
  If this section is empty, the project currently adopts the selected defaults above as its working defaults.

  Format:
  ### [Topic]
  **Recommended default**: [What best-practices suggests]
  **Project decision**: [What this project does instead, or why it omits the default]
  **Rationale**: [Why this is a better fit here]
  **Reviewed**: [Date]
-->

None. This project currently uses the selected defaults above as its working defaults.

---

## Documentation Map

| Documentation Type | Path | Notes |
| --- | --- | --- |
| Architecture decisions | `[docs/adr/]` | Record non-trivial design trade-offs |
| Operational/process docs | `[docs/process/]` | Runbooks, release, and maintenance workflows |
| API or reference docs | `[docs/reference/]` | Public/internal contracts and references |
| Planning/spec docs | `[docs/planning/]` | Specs, roadmaps, and implementation plans |

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
