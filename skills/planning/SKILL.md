---
name: planning
description: Use when planning multi-step tasks, writing implementation plans, or starting new feature work before touching code
---

# Planning

**Announce at start:** "Following the planning skill — mapping before editing."

## The Core Rule

**No edits before understanding.** MAP first, then plan, then implement.

## Process

### 1. MAP — Understand the Codebase

Before any change, build a mental model:

- [ ] Read README, CONTRIBUTING, ARCHITECTURE.md
- [ ] Identify build system and commands
- [ ] Identify test strategy (unit/integration/e2e)
- [ ] Locate CI workflows
- [ ] Sketch package/module boundaries

**Output a repo map**:

```markdown
## Repo Map: [project-name]

### Build & Test
- Build: `[command]` | Test: `[command]`
- CI: [platform] on [trigger]

### Structure
- `src/[dir]/` - [purpose]
- `tests/[dir]/` - [purpose]

### Invariants
- [architectural constraint]
```

### 2. PLAN — Design Small, Reversible Changes

Write a change plan before implementing:

- [ ] Define objective (one sentence)
- [ ] List files and functions to change
- [ ] Define tests to add or update
- [ ] Document rollback strategy
- [ ] Identify risks and mitigations

### 3. Bite-Sized Task Granularity

**Each step should be one action (2-5 minutes):**

| Step | Example |
| --- | --- |
| Write the failing test | One step |
| Run it to verify it fails | One step |
| Implement minimal code to pass | One step |
| Run tests to verify they pass | One step |
| Commit | One step |

**Not**: "Implement the feature and write tests" (too large, not reversible).

### 4. Plan Document Template

```markdown
# [Feature Name] Implementation Plan

**Goal:** [One sentence]

**Architecture:** [2-3 sentences about approach]

---

### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file`
- Modify: `exact/path/to/existing`
- Test: `tests/exact/path/to/test`

**Step 1:** Write the failing test
**Step 2:** Run test to verify it fails
**Step 3:** Write minimal implementation
**Step 4:** Run test to verify it passes
**Step 5:** Commit
```

### 5. Execute with Checkpoints

- Execute in batches of 3 tasks
- Report results after each batch
- Wait for feedback before continuing
- Stop and ask when blocked — do not guess

## Red Flags — STOP

| Signal | Action |
| --- | --- |
| Editing before understanding | Go back to MAP |
| "This is too simple to need a plan" | It's not — follow the process |
| Task is larger than 5 minutes | Break it down further |
| Blocked on unclear requirements | Ask before guessing |

## Related Skills

| When | Invoke |
| --- | --- |
| Ready to start implementation | [refactoring](../refactoring/SKILL.md) (for restructuring) or begin coding |
| Need to write tests first | [testing](../testing/SKILL.md) |
| Plan involves security-sensitive changes | [secure-coding](../secure-coding/SKILL.md) |
| Ready to submit changes | [pr-writing](../pr-writing/SKILL.md) |

## Deep Reference

For principles, rationale, anti-patterns, and examples:

- `guides/planning-documentation/planning-documentation.md`
- `guides/agentic-workflow/agentic-workflow.md`
