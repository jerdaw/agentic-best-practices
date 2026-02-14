---
name: debugging
description: Use when diagnosing bugs, test failures, or unexpected behavior before attempting any fix
---

# Debugging

**Announce at start:** "Following the debugging skill to find root cause before fixing."

## The Iron Law

```text
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

If you have not completed steps 1-4 below, you cannot propose fixes. Symptom fixes are failure.

## Process

### 1. Observe

Collect the full picture before forming any hypothesis.

- Full stack trace and error message
- Application logs around the failure
- Environment details (OS, runtime, versions)
- Input data that triggered the failure

### 2. Reproduce

Create a minimal environment where the bug consistently occurs.

- Write a failing test that demonstrates the bug
- If untestable, document exact reproduction steps
- Confirm the test fails for the right reason

### 3. Isolate

Narrow down to the exact component or function.

- Binary search: disable half the code path, check if bug persists
- Check recent changes (`git log`, `git bisect`)
- Trace execution flow leading to the error

### 4. Diagnose

Identify the root cause — not just the symptom.

- Ask: "Why does this happen?" at least 3 times (5 Whys)
- List 3 potential causes before investigating any single one
- Check for edge cases: null, empty, boundary values, race conditions

### 5. Fix

Implement the minimal correction needed.

- Change only what is required to fix the root cause
- Do not refactor while debugging
- Do not fix unrelated issues in the same change

### 6. Verify

Confirm the fix is correct and complete.

- [ ] Reproduction test now passes
- [ ] Full test suite passes (no regressions)
- [ ] You can explain *why* the fix works
- [ ] Manual verification if applicable

## Red Flags — STOP

| Signal | Action |
| --- | --- |
| Tempted to "just try something" | Go back to step 1 |
| Fix didn't work | You don't have root cause — go back to step 4 |
| Multiple fixes attempted | You're guessing — go back to step 3 |
| Under time pressure | Slow down — systematic is faster than thrashing |
| Issue seems simple | Simple bugs have root causes too — follow the process |

## Related Skills

| When | Invoke |
| --- | --- |
| Bug fix requires multi-file changes | [refactoring](../refactoring/SKILL.md) |
| Need to write regression test | [testing](../testing/SKILL.md) |
| Fix touches security-sensitive code | [secure-coding](../secure-coding/SKILL.md) |
| Ready to submit the fix | [pr-writing](../pr-writing/SKILL.md) |

## Deep Reference

For principles, rationale, anti-patterns, and examples:
`guides/debugging-with-ai/debugging-with-ai.md`
