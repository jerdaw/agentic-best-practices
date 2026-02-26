# Debugging with AI

Best practices for collaborating with AI coding agents to diagnose, reproduce, and fix bugs effectively.

> **Scope**: Applies to the entire debugging lifecycle—from receiving an error report to verifying a fix. The goal is to
> treat debugging as a structured scientific process.

## Contents

| Section |
| :--- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [The Iron Law](#the-iron-law) |
| [The Debugging Lifecycle](#the-debugging-lifecycle) |
| [Effective Error Reporting](#effective-error-reporting) |
| [Investigation Techniques](#investigation-techniques) |
| [Verification of Fixes](#verification-of-fixes) |
| [Anti-Patterns](#anti-patterns) |
| [Red Flags](#red-flags) |
| [See Also](#see-also) |

---

## Quick Reference

| Category | Guidance | Rationale |
| :--- | :--- | :--- |
| **Context** | Share the full stack trace | AI needs the entire failure path |
| **Reproduction**| Always create a failing test first | Proves the bug and the fix |
| **Hypothesis** | Ask the AI for 3 potential causes | Prevents premature conclusions |
| **Logs** | Share relevant application logs | Reveals state before/during failure |
| **Isolation** | Minimize the code shared to the bug | Reduces noise and token usage |

---

## Core Principles

| Principle | Guideline | Rationale |
| :--- | :--- | :--- |
| **Reproduce first** | Create a failing test before investigating | If you can't prove it's broken, you can't prove it's fixed |
| **Scientific Method** | Form a hypothesis, test it, observe, repeat | Systematic investigation is faster than guessing |
| **Evidence-based** | Trust logs and traces over assumptions | Guesses compound errors; evidence narrows the search |
| **Fix the root cause** | Don't just patch the symptoms | Symptom fixes mask underlying issues and guarantee rework |
| **Regression safety** | Every fix must include a test to prevent recurrence | Without a test, the same bug returns in the next refactor |

---

## The Iron Law

```text
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

If you haven't completed the Observe → Reproduce → Isolate → Diagnose steps, you cannot propose fixes. Symptom fixes mask underlying issues and waste time.

### When This Matters Most

| Situation | Why You Must Follow the Process |
| :--- | :--- |
| Under time pressure | Rushing guarantees rework — systematic is faster than thrashing |
| "Just one quick fix" seems obvious | Obvious fixes are often wrong; verify before applying |
| Multiple fixes already attempted | You're guessing — go back to isolation |
| Issue seems simple | Simple bugs have root causes too |

---

## The Debugging Lifecycle

1. **Observe** – Collect error messages, logs, and user reports.
2. **Reproduce** – Create a minimal environment where the bug consistently occurs.
3. **Isolate** – Determine exactly which component or function is failing.
4. **Diagnose** – Understand *why* it is failing (the root cause).
5. **Fix** – Implement the minimal correction needed.
6. **Verify** – Confirm the failing test now passes and no regressions exist.

---

## Effective Error Reporting

When asking an AI to fix a bug, provide:

| Item | Description |
| :--- | :--- |
| **The Error** | Full stack trace and error message |
| **The Environment**| OS, Runtime, Versions, and Dependencies |
| **The Input** | Data used when the error occurred |
| **The Code** | The specific functions mentioned in the trace |
| **The Goal** | What the expected behavior was |

### Examples

**Good: Complete error report**

```
Error: Cannot read property 'id' of undefined
  at UserService.getProfile (user.service.ts:42)
  at UserController.profile (user.controller.ts:18)

Environment:
  Node.js v18.12.0
  Express 4.18.2

Input:
  GET /api/users/profile
  Headers: { Authorization: "Bearer eyJ..." }

Code (user.service.ts:42):
  async getProfile(userId: string): Promise<UserProfile> {
    const user = await this.db.findUser(userId);
    return { id: user.id, name: user.name }; // <- Line 42
  }

Expected: Return user profile for authenticated user
Actual: Crashes when user not found in database
```

**Bad: Vague error report**

```
"It's broken when I try to get the user profile.
Can you fix it?"
```

**Good: Debugging conversation with AI**

```
Human: "Fix this TypeError: Cannot read property 'length' of null"

AI: "I need more context to help effectively:
1. Full stack trace showing where the error occurs
2. The function code where this happens
3. Example input that triggers it"
```

---

## Investigation Techniques

Ask the AI to perform these actions during investigation:

- [ ] "Explain the execution flow leading to this error."
- [ ] "List all edge cases for these input parameters."
- [ ] "Identify any race conditions in this concurrent block."
- [ ] "Check for PII leakage in these logs."
- [ ] "Search for similar patterns in other modules."

---

## Verification of Fixes

A fix is only complete when:

1. The reproduction test passes.
2. The full test suite passes (no regressions).
3. The AI can explain *why* the fix works.
4. The fix is verified manually (if applicable).

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| :--- | :--- | :--- |
| **Guessing** | Wastes tokens and time | Reproduce and trace first |
| **Patching symptoms** | Bug returns later | Identify the root cause |
| **Implicit reproduction**| "It works now" (unproven) | Always show a passing test |
| **Context starvation** | Missing pieces of the trace | Share the full, raw error log |
| **Over-fixing** | Refactoring while debugging | Keep the bug fix minimal |

---

## Red Flags

| Signal | Action | Rationale |
| :--- | :--- | :--- |
| Tempted to "just try something" | Return to the Observe step | Untested fixes compound the problem and waste tokens |
| Fix didn't work | Return to Diagnose — you don't have root cause | Stacking guesses makes the real cause harder to find |
| Multiple fixes already attempted | Return to Isolate — you're guessing | Systematic isolation is faster than trial-and-error |
| Can't explain why the fix works | Investigate further before committing | Unexplained fixes mask the real bug and break later |
| AI proposes a fix without seeing the stack trace | Provide the full error context first | Fixes without evidence are guesses with extra confidence |
| Debugging session exceeds 30 minutes without progress | Step back; re-read logs; try binary search isolation | Long sessions indicate a wrong mental model of the failure |

---

## See Also

- [Testing Strategy](../testing-strategy/testing-strategy.md) – Writing reproduction tests
- [Logging Practices](../logging-practices/logging-practices.md) – Enabling better investigation
- [Error Handling Patterns](../error-handling/error-handling.md) – Preventing common bugs
