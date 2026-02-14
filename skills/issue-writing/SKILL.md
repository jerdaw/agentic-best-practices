---
name: issue-writing
description: Write clear, actionable bug reports and feature requests that humans and agents can act on immediately
---

# Issue Writing

Write structured issue tickets — bug reports, feature requests, and task descriptions — that contain all the
information needed for immediate action.

> **Deep guide**: This skill is standalone. For related patterns see
> [Documentation Guidelines](../../guides/documentation-guidelines/documentation-guidelines.md) and
> [PRD for Agents](../../guides/prd-for-agents/prd-for-agents.md).

## Triggers

Use this skill when you need to:

- File a bug report for a defect you discovered
- Write a feature request based on user feedback or product need
- Break down a large task into sub-issues
- Document a technical debt item for future work
- Create a spike/investigation ticket

## Process

### 1. Choose the Issue Type

| Type | Template | When |
| --- | --- | --- |
| **Bug Report** | [Bug Template](#bug-report-template) | Something is broken or behaves unexpectedly |
| **Feature Request** | [Feature Template](#feature-request-template) | New capability or enhancement needed |
| **Task** | [Task Template](#task-template) | Work item that needs to be completed |
| **Spike** | [Spike Template](#spike-template) | Investigation or research needed before implementation |

### 2. Write a Clear Title

| Pattern | Example |
| --- | --- |
| `[Component] Verb + specific context` | `[Auth] Login fails when email contains '+' character` |
| `[Area] Expected vs actual` | `[API] GET /users returns 500 instead of 404 for missing user` |
| Avoid vague titles | ❌ "Bug in login" ❌ "Fix issue" ❌ "Something broken" |

### 3. Fill in the Template

Follow the appropriate template below. Every field exists for a reason — incomplete issues waste time.

### 4. Add Context

- Attach screenshots, logs, or stack traces
- Link to related issues, PRs, or discussions
- Tag affected components or areas
- Set priority based on impact and urgency

### 5. Review Before Submitting

| Check | Why |
| --- | --- |
| Could someone act on this without asking questions? | Self-contained issues save roundtrips |
| Is the title scannable in a list? | Teams triage by title first |
| Are reproduction steps numbered and specific? | Vague steps like "login and try stuff" are useless |
| Is expected vs actual behavior explicit? | Without both, you're describing a symptom, not a bug |

## Bug Report Template

```markdown
## Bug: [Component] Brief description

### Environment
- OS / Browser: 
- Version / Commit: 
- Environment: staging / production / local

### Steps to Reproduce
1. Navigate to ...
2. Click on ...
3. Enter "..." in the field
4. Submit the form

### Expected Behavior
[What should happen]

### Actual Behavior
[What actually happens]

### Error Output
[Stack trace, console errors, or log output]

### Severity
- [ ] Critical — system down, data loss
- [ ] High — feature broken, no workaround
- [ ] Medium — feature broken, workaround exists
- [ ] Low — cosmetic or minor inconvenience
```

## Feature Request Template

```markdown
## Feature: [Area] Brief description

### Problem
[What pain point or need does this address?]

### Proposed Solution
[What should be built? Be specific about behavior.]

### Acceptance Criteria
- [ ] [Criterion 1 — testable, specific]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

### Alternatives Considered
[What other approaches were considered and why they were rejected?]

### Impact
- Users affected: [scope]
- Priority: [high / medium / low]
```

## Task Template

```markdown
## Task: [Area] Brief description

### Goal
[One sentence — what does completing this achieve?]

### Requirements
- [ ] [Specific deliverable 1]
- [ ] [Specific deliverable 2]
- [ ] [Specific deliverable 3]

### Dependencies
[What must be done before this? Link to blocking issues.]

### Definition of Done
[How do we know this is complete? Tests pass? Docs updated? PR merged?]
```

## Spike Template

```markdown
## Spike: [Area] Brief description

### Question
[What specific question needs answering?]

### Context
[Why do we need to investigate this? What decision depends on the answer?]

### Time Box
[Maximum time to spend — e.g., "4 hours" or "1 day"]

### Expected Output
[What deliverable comes from this spike? Decision doc? Prototype? Recommendation?]
```

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| Title is vague ("Fix bug", "Update thing") | Rewrite with component + specific context | Vague titles get deprioritized and misunderstood |
| No reproduction steps on a bug report | Add numbered, specific steps | Unreproducible bugs don't get fixed |
| Issue mixes multiple unrelated problems | Split into separate issues | Multi-problem issues get partially completed and forgotten |
| No acceptance criteria on a feature request | Add testable criteria | Without criteria, "done" is undefined |
| Issue has been open for 30+ days with no activity | Re-evaluate priority or close | Stale issues clutter the backlog |

## Related Skills

| Skill | When to Chain |
| --- | --- |
| [Planning](../planning/SKILL.md) | Break large issues into planned implementation steps |
| [PR Writing](../pr-writing/SKILL.md) | Reference the issue in your PR for traceability |
| [Doc Maintenance](../doc-maintenance/SKILL.md) | Update docs when closing feature issues |
