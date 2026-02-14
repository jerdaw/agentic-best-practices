---
name: e2e-testing
description: Use when writing end-to-end tests, designing E2E test strategy, or debugging flaky E2E tests
---

# E2E Testing

**Announce at start:** "Following the e2e-testing skill for end-to-end test design."

## Core Rule

**Test critical user journeys, not every interaction.** E2E tests are expensive — be selective.

## When to Write E2E Tests

| Write E2E | Don't Write E2E |
| --- | --- |
| Critical user flows (login, checkout, signup) | Individual component behavior (use unit tests) |
| Multi-step workflows spanning pages | Simple CRUD operations |
| Cross-browser/device verification | Internal API validation (use integration tests) |
| Regression for UI bugs that unit tests can't catch | Styling or layout checks |

## Process

### 1. Identify — Select the Right Flows

- [ ] List critical user journeys (max 10-20 for most apps)
- [ ] Prioritize by business impact and failure risk
- [ ] Avoid duplicating what integration tests already cover

### 2. Structure — Page Object Model

- One page object per page/component
- Encapsulate selectors and actions
- Tests read like user stories

### 3. Write — Stable Selectors

| Priority | Selector | Why |
| --- | --- | --- |
| **Best** | `getByTestId('submit-btn')` | Stable, explicit, refactor-proof |
| **Good** | `getByRole('button', { name: 'Submit' })` | Semantic, accessible |
| **Avoid** | `.btn-primary`, `div > span:nth-child(2)` | Brittle, breaks on styling changes |

### 4. Handle Async — No Sleep Statements

- Use explicit waits (`waitForSelector`, `waitForResponse`)
- Use web-first assertions (auto-retry)
- Never use `sleep()` or `setTimeout()` for timing

### 5. Verify — Test Isolation

- [ ] Each test starts from a clean state
- [ ] Tests don't depend on each other's execution order
- [ ] Tests clean up created data

## Flaky Test Triage

| Symptom | Likely Cause | Fix |
| --- | --- | --- |
| Passes locally, fails in CI | Timing / resource differences | Add explicit waits |
| Fails intermittently | Race condition | Use `waitFor` patterns |
| Fails after unrelated change | Fragile selector | Switch to `getByTestId` |
| Slow (> 30s per test) | Too many page navigations | Reuse auth state |

## Red Flags — STOP

| Signal | Action |
| --- | --- |
| Writing E2E for logic that unit tests cover | Delete and write a unit test instead |
| Using `sleep()` anywhere | Replace with explicit waits |
| Test depends on test execution order | Isolate the test |
| E2E suite takes > 10 minutes | Prune — you have too many |

## Related Skills

| When | Invoke |
| --- | --- |
| Need unit/integration tests instead | [testing](../testing/SKILL.md) |
| E2E test reveals a bug | [debugging](../debugging/SKILL.md) |
| Ready to submit changes | [pr-writing](../pr-writing/SKILL.md) |

## Deep Reference

For principles, rationale, anti-patterns, and examples:
`guides/e2e-testing/e2e-testing.md`
