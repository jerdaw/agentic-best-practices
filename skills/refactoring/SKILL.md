---
name: refactoring
description: Use when coordinating large changes across multiple files or performing significant code restructuring
---

# Refactoring

**Announce at start:** "Following the refactoring skill for multi-file changes."

## Core Rule

**Interface first, implementation second.** Define contracts before changing internals.

## Process

### 1. Inventory — Map the Blast Radius

Before changing anything:

- [ ] List all files that will be touched
- [ ] Identify dependency order (what depends on what)
- [ ] Identify public interfaces that callers depend on
- [ ] Run the full test suite and record the baseline

### 2. Plan — Order Changes by Dependency

| Order | What | Why |
| --- | --- | --- |
| **First** | Types/interfaces | Contracts must be stable before implementation |
| **Second** | Core logic | Internal changes behind stable interfaces |
| **Third** | Callers/consumers | Update after interfaces are settled |
| **Last** | Tests | Verify everything works together |

### 3. Execute — One Layer at a Time

For each file in dependency order:

1. Make the minimal change to that file
2. Run the type checker / compiler
3. Run targeted unit tests
4. Commit with a clear message
5. Move to the next file

**Do not batch multiple files into one uncommitted change.**

### 4. Verify — Build Between Steps

| After Each File | After Each Layer | After All Changes |
| --- | --- | --- |
| Type check passes | Build succeeds | Full test suite passes |
| Relevant tests pass | Integration tests pass | Manual verification |
| Git status is clean | No regressions | PR is reviewable size |

## Change Size Guidelines

| Size | Recommendation |
| --- | --- |
| 1-50 lines | Ideal — easy to review |
| 50-200 lines | Acceptable — stay focused |
| 200-500 lines | Split if possible |
| 500+ lines | Must split into multiple PRs |

## Rollback Strategy

Before starting, define how to undo:

| Strategy | When |
| --- | --- |
| `git revert` | Single-commit changes |
| Feature flag | Behavior changes |
| Separate revert PR | Multi-commit changes |
| Config toggle | Environment-specific |

## Red Flags — STOP

| Signal | Action |
| --- | --- |
| Changing behavior during refactor | Separate into two PRs (refactor then feature) |
| Tests are failing and you don't know why | Stop, diagnose before continuing |
| Change touches more than 10 files | Break into smaller PRs |
| No test coverage for changed code | Add tests before refactoring |

## Related Skills

| When | Invoke |
| --- | --- |
| Refactoring uncovers a bug | [debugging](../debugging/SKILL.md) |
| Need to update tests for refactored code | [testing](../testing/SKILL.md) |
| Refactoring complete, ready to submit | [pr-writing](../pr-writing/SKILL.md) |
| Refactoring started without a plan | [planning](../planning/SKILL.md) |

## Deep Reference

For principles, rationale, anti-patterns, and examples:
`guides/multi-file-refactoring/multi-file-refactoring.md`
