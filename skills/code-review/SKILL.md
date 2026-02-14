---
name: code-review
description: Use when reviewing code, preparing a PR for review, or processing review feedback
---

# Code Review

**Announce at start:** "Following the code-review skill for structured review."

## Pre-Review Checklist

Before starting any review, gather:

- [ ] Clear description of the change
- [ ] List of modified files
- [ ] Related interfaces and types
- [ ] Existing test files for the module

## Review Focus Areas

Review in this order — stop escalating when critical issues are found.

### 1. Logic and Correctness

- Off-by-one errors, null dereferences, boundary conditions
- Missing error handling on fallible operations
- Race conditions in concurrent code

### 2. Security

- SQL injection, XSS, CSRF
- PII leakage in logs
- Weak cryptographic patterns
- Insecure direct object references (IDOR)

### 3. Performance

- N+1 queries in loops
- Unbounded memory growth
- Blocking the event loop

## Feedback Format

Every piece of feedback must follow this structure:

```text
**Issue**: [Specific problem]
**Rationale**: [Why this matters]
**Fix**: [Concrete suggestion with example code]
```

Never give vague feedback like "this is complex" or "improve this."

## Processing Feedback

| Severity | Action |
| --- | --- |
| **Critical** | Fix immediately — blocks merge |
| **Important** | Fix before proceeding to next task |
| **Minor** | Note for later — does not block |

### When to Push Back

- Show code or tests that prove the reviewer is wrong
- Provide technical reasoning
- Request clarification if feedback is ambiguous

## Automated Review Dispatch

For systematic reviews using diff-based context:

```bash
BASE_SHA=$(git merge-base HEAD origin/main)
HEAD_SHA=$(git rev-parse HEAD)
```

Provide: what was implemented, the plan/requirements, base SHA, head SHA, and a brief description.

## Related Skills

| When | Invoke |
| --- | --- |
| Review finds bugs | [debugging](../debugging/SKILL.md) |
| Review requires test changes | [testing](../testing/SKILL.md) |
| Post-review, ready to submit | [pr-writing](../pr-writing/SKILL.md) |
| Review finds security issues | [secure-coding](../secure-coding/SKILL.md) |

## Deep Reference

For principles, rationale, anti-patterns, and examples:
`guides/code-review-ai/code-review-ai.md`
