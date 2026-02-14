# Memory Patterns for AI Agents

Best practices for maintaining AI agent state across steps and sessions — scratchpads, project state files, decision logs, and continuity patterns.

> **Scope**: Covers how agents and their human collaborators manage evolving state during and between work sessions.
> Focus is on *what to persist, how to structure it, and when to discard it* — not on the agent's internal context
> window (see [Context Management](../context-management/context-management.md) for that).

## Contents

| Section |
| :--- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Memory Types](#memory-types) |
| [State File Design](#state-file-design) |
| [Cross-Session Continuity](#cross-session-continuity) |
| [Memory Scope](#memory-scope) |
| [Storage Patterns](#storage-patterns) |
| [Anti-Patterns](#anti-patterns) |
| [Self-Assessment Checklist](#self-assessment-checklist) |
| [Red Flags](#red-flags) |
| [See Also](#see-also) |

---

## Quick Reference

| Category | Guidance | Rationale |
| :--- | :--- | :--- |
| **Purpose** | Preserve decisions and progress across steps/sessions | Prevents re-discovery and contradictory actions |
| **Default posture** | Persist the minimum needed to resume | State bloat degrades signal-to-noise |
| **Format** | Structured markdown with clear sections | Human-readable, version-controllable, agent-parseable |
| **Lifecycle** | Create → Update → Prune → Archive or delete | Stale state is worse than no state |
| **Ownership** | Human reviews; agent proposes updates | Critical decisions require human judgment |

---

## Core Principles

1. **Temporal over static** – Memory changes as the work progresses; treat it as a living document, not documentation.
2. **Minimal persistence** – Store only what's needed to resume or avoid repeating mistakes. Less is more.
3. **Structured over freeform** – Use consistent headings, tables, and checklists. Agents parse structure better than prose.
4. **Decay by default** – State has a shelf life. Old decisions should be pruned or archived, not accumulated forever.
5. **Separation of concerns** – Task state, project decisions, and learned constraints are different things with different lifecycles.

---

## Memory Types

| Type | Scope | Lifecycle | Example |
| :--- | :--- | :--- | :--- |
| **Session scratchpad** | Single session | Discarded at session end | "Tried approach X, failed because Y" |
| **Task state** | Multi-session task | Archived on task completion | Checklist of subtasks, current progress |
| **Decision log** | Project-wide | Long-lived, append-only | "Chose PostgreSQL over MongoDB because..." |
| **Learned constraints** | Project-wide | Updated as project evolves | "The auth module has a circular dependency — don't import X from Y" |
| **TODO tracker** | Project-wide | Items resolved or promoted to issues | "Needs refactoring after v2 ships" |

### When to Use Each

```
Is this a temporary note for the current session?
├── Yes → Session scratchpad (agent-managed, ephemeral)
└── No
    ├── Is it tracking progress on a specific task?
    │   └── Yes → Task state file
    ├── Is it a decision that future sessions need to know?
    │   └── Yes → Decision log
    ├── Is it a constraint discovered during work?
    │   └── Yes → Learned constraints (consider adding to AGENTS.md)
    └── Is it work to do later?
        └── Yes → TODO tracker (consider promoting to a GitHub issue)
```

---

## State File Design

### Recommended Format

```markdown
# Project State: [Feature/Task Name]

## Status
**Current phase**: Planning / In Progress / Blocked / Complete
**Last updated**: 2026-02-14
**Blocking on**: [Nothing / specific issue]

## Progress
- [x] Database schema designed
- [x] API endpoints implemented
- [/] Frontend components (3 of 5 done)
- [ ] Integration tests
- [ ] Documentation

## Decisions Made
| Decision | Rationale | Date |
| :--- | :--- | :--- |
| Use REST over GraphQL | Simpler for CRUD-only API | 2026-02-10 |
| Skip pagination in v1 | Dataset small (<1000 rows) | 2026-02-12 |

## Constraints Discovered
- Auth middleware must be applied before rate limiting (order matters)
- The `users` table has a unique constraint on email — handle duplicates

## Open Questions
- [ ] Should we support batch operations in v1?
- [ ] Which caching strategy for the list endpoint?
```

### What to Include vs Omit

| Include | Omit |
| :--- | :--- |
| Decisions and their rationale | Code snippets (they belong in source files) |
| Current progress and blockers | Full conversation history |
| Constraints discovered during work | Obvious project facts (language, framework) |
| Open questions needing human input | Detailed error logs (use issue tracker) |
| Links to relevant files/PRs | Rehashing of AGENTS.md content |

---

## Cross-Session Continuity

The hardest problem in agentic coding: how does the agent pick up where it left off?

### Handoff Summary Pattern

At the end of a session, the agent (or human) writes a handoff summary:

```markdown
## Session Handoff — 2026-02-14

### What Was Done
- Implemented user registration endpoint (`src/api/users.ts`)
- Added input validation with Zod schemas
- Wrote 8 unit tests (all passing)

### What's Next
1. Add email verification flow (design in `docs/email-verification.md`)
2. Wire up the frontend registration form

### Current State
- Branch: `feature/user-registration`
- Tests: 8/8 passing
- Lint: Clean
- Remaining: 2 of 4 subtasks

### Watch Out For
- The email service mock in tests uses a hardcoded API key — needs env var
- Registration endpoint doesn't handle duplicate emails yet (see TODO in code)
```

### Checkpoint Pattern

For long-running tasks, create periodic checkpoints:

| Checkpoint | Trigger | Content |
| :--- | :--- | :--- |
| **Start-of-session** | Agent begins work | Read existing state, summarize understanding |
| **Mid-task** | After significant milestone | Update progress, note any new constraints |
| **Blocker** | Agent can't proceed | Document what's blocking and what was tried |
| **End-of-session** | Before session ends | Write handoff summary |

### Resumption Pattern

When starting a new session on an existing task:

1. **Read** the state file and most recent handoff summary
2. **Verify** the current state matches what the handoff says (run tests, check branch)
3. **Summarize** your understanding back to the human for confirmation
4. **Proceed** from where the handoff left off

---

## Memory Scope

Not all memory belongs in the same place.

| Scope | Stored In | Who Maintains | Lifecycle |
| :--- | :--- | :--- | :--- |
| **Task-local** | Task state file (e.g., `state.md`) | Agent + human | Archived on task completion |
| **Project-wide** | `AGENTS.md`, architecture docs | Human (agent proposes) | Updated with the project |
| **Org-wide** | Shared standards repo (like this one) | Team | Versioned with releases |

### Promotion Pattern

Temporary memory should be promoted to permanent artifacts when appropriate:

| From | To | When |
| :--- | :--- | :--- |
| **Session scratchpad** → | Task state | Insight is needed beyond this session |
| **Task state** → | Decision log / ADR | Decision has project-wide impact |
| **Learned constraint** → | `AGENTS.md` | Constraint is permanent and applies to all future work |
| **TODO** → | GitHub issue | Work item needs tracking beyond the current task |

---

## Storage Patterns

### File-Based (Recommended)

Store state in markdown files committed to the repo:

```
.state/
├── current-task.md           # Active task state
├── decisions.md              # Append-only decision log
└── archive/
    ├── 2026-02-user-auth.md  # Completed task states
    └── 2026-01-api-v2.md
```

**Advantages**: Version-controlled, human-readable, survives tool changes.

**Disadvantages**: Requires discipline to update and prune.

### Tool-Provided

Some tools offer built-in memory:

| Tool | Memory Feature | Scope |
| :--- | :--- | :--- |
| Claude Code | Memory files | Session + project |
| Cursor | Notepad | Session |
| Gemini | Knowledge items | Cross-session |

**Advantages**: Automatic, integrated with the tool.

**Disadvantages**: Tool-specific, may not be version-controlled or shareable.

### Hybrid (Recommended for Teams)

- Use **tool-provided memory** for session-level scratchpads
- Use **file-based memory** for anything that needs to persist, be shared, or be reviewed

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| :--- | :--- | :--- |
| **Hoard everything** | State file grows to 500+ lines, signal lost in noise | Prune aggressively; archive completed tasks |
| **No structure** | Freeform notes the agent can't parse reliably | Use consistent headings, tables, and checklists |
| **Stale state** | State file says "in progress" for a task completed weeks ago | Update state at checkpoints; archive on completion |
| **Memory as documentation** | State file duplicates what should be in README or ADR | Promote stable decisions to proper docs |
| **No handoff** | New session starts from scratch, repeating earlier work | Always write a handoff summary before ending |
| **State in chat** | Decisions buried in a conversation the next session can't see | Extract decisions to a state file |

---

## Self-Assessment Checklist

Before ending a work session:

- [ ] State file reflects current progress accurately?
- [ ] Decisions and their rationale are recorded (not just outcomes)?
- [ ] Handoff summary written for the next session?
- [ ] Stale items pruned or archived?
- [ ] Constraints that apply broadly are proposed for `AGENTS.md`?
- [ ] TODOs either tracked in state file or promoted to issues?

---

## Red Flags

| Signal | Action | Rationale |
| :--- | :--- | :--- |
| State file over 200 lines | Archive completed sections, prune resolved items | Bloated state files bury the signal the agent needs |
| Agent re-discovers the same constraint in multiple sessions | Add the constraint to `AGENTS.md` as a permanent rule | Repeated re-discovery wastes time and risks inconsistency |
| No one has updated the state file in 2+ weeks | Archive or delete it — it's stale | Stale state is actively misleading |
| Agent contradicts a decision from a previous session | Check if a decision log exists; create one if not | Without a log, decisions are rediscovered (often differently) each session |
| Team members have conflicting understanding of task progress | Centralize state in a shared, committed file | Chat-based state is invisible to other collaborators |

---

## See Also

- [Agentic Workflow](../agentic-workflow/agentic-workflow.md) – The MAP-PLAN-PATCH-PROVE-PR workflow that state supports
- [Planning Documentation](../planning-documentation/planning-documentation.md) – Structured specs for complex tasks
- [Context Management](../context-management/context-management.md) – Managing the agent's active context window
- [AGENTS.md Guidelines](../agents-md/agents-md-guidelines.md) – Where permanent constraints should live
