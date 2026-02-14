# Code Review with AI

Best practices for using AI coding agents as code reviewers and preparing code for AI review.

> **Scope**: Applies to automated code reviews, PR feedback loops, and using AI to explain or validate changes.
> Goal: Maximize the utility of AI reviewers while maintaining high standards for security and quality.

## Contents

| Section |
| :--- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [The Review Workflow](#the-review-workflow) |
| [Review Categories](#review-categories) |
| [AI Feedback Patterns](#ai-feedback-patterns) |
| [Verification Requests](#verification-requests) |
| [Anti-Patterns](#anti-patterns) |

---

## Quick Reference

| Action | Guidance | Rationale |
| :--- | :--- | :--- |
| **Request** | Provide specific focus areas | Prevents generic "LGTM" noise |
| **Context** | Share related files and types | Enables logic analysis (not just style) |
| **Verification**| Ask for proof (tests/examples) | Validates AI suggestions |
| **Trust** | AI is an advisor, not an author | Human oversight is always required |
| **Security** | Prioritize OWASP Top 10 checks | Critical for safety-conscious code |

---

## Core Principles

1. **Specific over generic** – "Review this for race conditions" beats "Review this."
2. **Actionable feedback** – Suggestions must include example code or clear steps.
3. **Critical thinking** – Agents should look for *why* code is wrong, not just *how* to style it.
4. **Safe defaults** – Default to rejecting non-obvious fixes without tests.
5. **Human in the loop** – AI reviews complement human review, never replace it.

---

## The Review Workflow

### 1. Preparation

Provide the context needed for a deep review.

- [ ] Clear description of the change
- [ ] List of modified files
- [ ] Related interfaces/types
- [ ] Existing test files for the module

### 2. Requesting the Review

````text
Review this PR focus on [area]:

Summary: [Purpose of change]

Files: [File list]

Look for:
- [Specific concern 1]
- [Specific concern 2]

Constraints:
- [What must not change]
````

### 3. Processing Feedback

| Type | Action |
| :--- | :--- |
| **Bug/Fix** | Apply, then ask agent to verify its own fix |
| **Suggestion** | Discuss trade-offs; apply if truly better |
| **Explainer** | Use to clarify complex logic or legacy code |
| **Doubt** | Ask for a test case that proves the issue |

---

## Review Categories

### Logic & Correctness

```typescript
// Ask AI to spot off-by-one errors or edge cases
function parseAmount(input: string): number {
  if (!input) return 0
  return parseFloat(input.replace(/[^0-9.]/g, ''))
}
// AI: "Review for edge case where input is '...' or '1.2.3'"
```

### Security & Privacy

Check for:

- SQL Injection, XSS, CSRF
- PII leakage in logs
- Weak cryptographic patterns
- Insecure direct object references (IDOR)

### Performance

Check for:

- N+1 queries in loops
- Excessive object allocation
- Blocking the event loop (NodeJS)
- Unbounded memory growth

---

## AI Feedback Patterns

### Good Feedback

> **Issue**: High-cardinality label in metrics.
> **Rationale**: Using `user_id` as a Prometheus label will cause metric explosion in production.
> **Fix**: Use a generic `status` label and log the `user_id` in traces instead.

### Bad Feedback

> **Issue**: This code is a bit complex.
> **Rationale**: It's hard to read.
> **Fix**: Make it simpler.

---

## Verification Requests

Don't just take the AI's word; ask it to prove the suggestion.

| Request | Purpose |
| :--- | :--- |
| "Provide a failing test for this bug" | Proves the bug exists |
| "Write a benchmark for this fix" | Proves the performance gain |
| "Show the exploit for this security flaw"| Proves the vulnerability |
| "Explain the trade-off of this refactor" | Ensures maintainability |

---

## Automated Review Dispatch

For systematic reviews, provide diff-based context to ensure comprehensive coverage.

### Setup

```bash
BASE_SHA=$(git merge-base HEAD origin/main)
HEAD_SHA=$(git rev-parse HEAD)
```

### Review Request Format

| Field | Content |
| :--- | :--- |
| **What was implemented** | Brief description of the change |
| **Requirements/plan** | Link to plan, PRD, or issue |
| **Base SHA** | `$BASE_SHA` |
| **Head SHA** | `$HEAD_SHA` |
| **Focus areas** | Specific concerns for review |

### Severity-Based Triage

| Severity | Action | Example |
| :--- | :--- | :--- |
| **Critical** | Fix immediately — blocks merge | Security vulnerability, data loss |
| **Important** | Fix before proceeding | Missing error handling, race condition |
| **Minor** | Note for later — doesn't block | Naming suggestion, style preference |

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| :--- | :--- | :--- |
| **Silent LGTM** | Agent misses subtle bugs | Provide checklists and focus areas |
| **Style nitpicking** | Noise drowns out logic | Use automated linters for style |
| **Logic hallucinations** | Agent invents bugs | Ask for proof (tests/explorations) |
| **Blindly applying** | Subtle regressions | Always review and test AI fixes |
| **Context starvation** | "Code looks fine" (wrong) | Share dependencies and callers |

---

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| Approving a PR without running the code | Run it locally or verify CI passed | "Looks good" without execution misses runtime bugs |
| AI-generated PR with no test changes | Request tests before approving | Untested AI code has unknown failure modes |
| Review comment says "I don't understand this but LGTM" | Ask the author to explain or simplify | Approving code you don't understand transfers risk to production |
| PR has 50+ changed files | Request splitting into smaller PRs | Large PRs get rubber-stamped — reviewers can't maintain focus |
| No security review on auth/payment/data code | Flag for security-focused review | Security bugs in critical paths have outsized impact |

---

## See Also

- [Secure Coding](../secure-coding/secure-coding.md) – What to look for in security reviews
- [Testing Strategy](../testing-strategy/testing-strategy.md) – Verifying fixes
- [Prompting Patterns](../prompting-patterns/prompting-patterns.md) – Crafting review prompts
