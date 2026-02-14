# Multi-File Refactoring with AI

A reference for coordinating large refactoring efforts with AI assistance—planning, executing, and verifying changes that
span many files.

> **Scope**: These patterns help manage complexity when AI-assisted changes touch multiple files. Large changes fail more
> often; these patterns reduce that risk.

## Contents

| Section |
| :--- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Planning Large Refactors](#planning-large-refactors) |
| [Incremental vs Big-Bang](#incremental-vs-big-bang) |
| [Dependency Ordering](#dependency-ordering) |
| [Verification Checkpoints](#verification-checkpoints) |
| [Rollback Strategies](#rollback-strategies) |
| [Batching Changes](#batching-changes) |
| [AI-Specific Patterns](#ai-specific-patterns) |
| [Breaking Changes](#breaking-changes) |
| [Refactoring Patterns](#refactoring-patterns) |
| [Verification Checklist](#verification-checklist) |
| [Anti-Patterns](#anti-patterns) |

---

## Quick Reference

**Before starting**:

- Map all files that will change
- Identify the order of changes
- Define verification points
- Plan rollback strategy

**During refactoring**:

- Change in small batches
- Verify after each batch
- Keep the codebase working
- Commit at verification points

**Risk factors**:

- More files = higher risk
- Breaking changes = coordinate carefully
- No tests = danger zone
- Shared code = ripple effects

---

## Core Principles

1. **Incremental over big-bang** – Small, verified steps beat large leaps
2. **Always compilable** – Codebase should work after each change
3. **Test constantly** – Verify before moving to next step
4. **Rollback ready** – Know how to undo at any point
5. **Communicate changes** – Breaking changes need coordination

---

## Planning Large Refactors

### Change Impact Analysis

Before starting, map what will change:

| Question | Why It Matters |
| :--- | :--- |
| Which files change? | Scope the work |
| What depends on changed code? | Find ripple effects |
| What tests exist? | Know verification coverage |
| What's the change order? | Dependencies affect sequence |
| Are there breaking changes? | Coordination needed |

### Planning Template

```markdown
## Refactor: [Name]

### Goal
[One sentence: what this achieves]

### Files Affected
1. `src/services/user.ts` - Extract interface
2. `src/repositories/user-repo.ts` - Implement interface
3. `src/api/users.ts` - Update to use interface
4. `src/tests/user.test.ts` - Update mocks

### Dependencies (change order)
1. Create interface (no dependencies)
2. Update repository (depends on interface)
3. Update service (depends on repository)
4. Update API (depends on service)
5. Update tests (depends on all above)

### Verification Points
- [ ] After interface: Types check
- [ ] After repository: Unit tests pass
- [ ] After service: Integration tests pass
- [ ] After API: E2E tests pass

### Rollback Strategy
Git revert to commit before refactor start.
Each batch is a separate commit for granular rollback.
```

---

## Incremental vs Big-Bang

### When to Use Each

| Approach | When to Use | Risk Level |
| :--- | :--- | :--- |
| **Incremental** | Most refactors | Lower |
| **Big-bang** | Coupled changes that can't be split | Higher |

### Incremental Approach

```text
Step 1: Add new code alongside old
        ↓ Verify: compiles, tests pass
Step 2: Migrate first consumer to new code
        ↓ Verify: compiles, tests pass
Step 3: Migrate remaining consumers
        ↓ Verify: compiles, tests pass
Step 4: Remove old code
        ↓ Verify: compiles, tests pass
```

**Example** – Renaming a function:

```typescript
// Step 1: Add new name, keep old as alias
export function getUserById(id: string) { /* ... */ }
export const getUser = getUserById  // Alias for old name

// Step 2-3: Update callers to use getUserById
// Step 4: Remove the alias
```

### Big-Bang Approach

Only when changes can't be split:

```text
1. Create branch
2. Make all changes
3. Run full test suite
4. Review carefully
5. Merge (ideally with feature flag)
```

---

## Dependency Ordering

### Change Order Rules

| Rule | Reason |
| :--- | :--- |
| Interfaces before implementations | Contracts first |
| Base classes before derived | Hierarchy stability |
| Utilities before consumers | Dependencies available |
| Core before edge | Stable foundation |

### Dependency Graph

Map dependencies to determine order:

```text
UserService → UserRepository → Database
           → EmailService → EmailProvider
           → Logger

Change order (leaves first):
1. Database, EmailProvider, Logger (no dependencies)
2. UserRepository, EmailService (depend on step 1)
3. UserService (depends on step 2)
```

### Handling Circular Dependencies

When A depends on B and B depends on A:

| Strategy | How |
| :--- | :--- |
| **Extract interface** | Create interface both can depend on |
| **Merge modules** | Combine if truly inseparable |
| **Dependency injection** | Pass dependency at runtime |
| **Event-based** | Communicate via events, not direct calls |

---

## Verification Checkpoints

### What to Verify

| Checkpoint | Checks |
| :--- | :--- |
| After each file | Compiles, imports resolve |
| After each module | Unit tests pass |
| After each feature | Integration tests pass |
| After complete refactor | Full suite, manual testing |

### Checkpoint Template

```markdown
## Checkpoint: [Name]

### Changes Made
- [List of changes since last checkpoint]

### Verified
- [ ] Code compiles without errors
- [ ] TypeScript/linting passes
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual smoke test works

### Issues Found
- [Any issues discovered]

### Next Steps
- [What to do next]
```

### Automated Verification

Run these at each checkpoint:

```bash
# TypeScript/compilation
npm run typecheck

# Linting
npm run lint

# Unit tests
npm test

# Integration tests
npm run test:integration

# Build
npm run build
```

---

## Rollback Strategies

### Git-Based Rollback

```bash
# Rollback to specific commit
git reset --hard <commit-hash>

# Rollback last N commits (keeping changes staged)
git reset --soft HEAD~N

# Revert specific commit (creates new commit)
git revert <commit-hash>

# Revert range of commits
git revert <oldest>^..<newest>
```

### Rollback Planning

| Change Size | Strategy |
| :--- | :--- |
| Single file | Undo in editor, or git checkout file |
| Few files | Git reset to previous commit |
| Many files | Revert each batch commit |
| Deployed | Feature flag, then code rollback |

### Feature Flags for Safe Rollback

For risky changes, use feature flags:

```typescript
// New implementation behind flag
if (featureFlags.useNewUserService) {
  return newUserService.getUser(id)
} else {
  return legacyUserService.getUser(id)
}
```

Rollback = disable flag, no code change needed.

---

## Batching Changes

### Batch Size Guidelines

| Batch Size | When to Use |
| :--- | :--- |
| 1 file | Learning the refactor pattern |
| 2-5 files | Well-understood, similar changes |
| 5-10 files | Mechanical changes (rename, format) |
| >10 files | Only if automated (codemods) |

### Batching by Type

Group files by the type of change:

```text
Batch 1: Type definitions
- src/types/user.ts
- src/types/order.ts

Batch 2: Layer
- src/repositories/user-repo.ts
- src/repositories/order-repo.ts
```

### Commit Per Batch

```bash
# After batch 1
git add src/types/
git commit -m "refactor: update type definitions"
```

---

## AI-Specific Patterns

### Context Management for Large Refactors

| Strategy | When |
| :--- | :--- |
| Share only current batch | Normal refactoring |
| Share pattern + current file | Repeating similar changes |
| Start fresh session | After major section |
| Re-share types/interfaces | When AI forgets contracts |

### Effective AI Prompts for Refactoring

**Single file**:

````text
Refactor this file to use dependency injection:

```[language]
[file contents]
```

Follow this pattern from UserRepository:
```[language]
[pattern example]
```
````

**Batch of similar files**:

````text
Apply the same refactoring pattern to these files:

Pattern (already applied to UserRepository):
```[language]
[pattern example]
```

Apply to:
1. OrderRepository - [file contents]
2. ProductRepository - [file contents]
````

**Verification request**:

````text
Check if this refactored code maintains same behavior:

Original:
```[language]
[original code]
```

Refactored:
```[language]
[new code]
```

Specifically verify:
- All public methods have same signatures
- Error handling is preserved
````

### AI Limitations in Multi-File Refactors

| Limitation | Mitigation |
| :--- | :--- |
| Context window limits | Work in batches |
| Can't see all files at once | Provide explicit dependencies |
| May forget earlier patterns | Re-share pattern with each batch |
| May make inconsistent changes | Verify consistency between files |

---

## Breaking Changes

### Identifying Breaking Changes

| Change Type | Breaking? |
| :--- | :--- |
| Adding optional parameter | No |
| Adding required parameter | Yes |
| Changing return type | Yes |
| Renaming public method | Yes |
| Changing internal logic | No |
| Removing public method | Yes |

### Communication Template

````markdown
## Breaking Change: [Description]

### What Changed
- `UserService.getUser(id)` now returns `User | null` instead of throwing

### Why
Previously threw exception for missing users, now returns null for consistency.

### Migration
Before:

```typescript
try {
  const user = await userService.getUser(id)
} catch (e) {
  // Handle not found
}
```

After:

```typescript
const user = await userService.getUser(id)
if (!user) {
  // Handle not found
}
```

### Affected Files

- src/api/users.ts
- src/services/order-service.ts
- src/tests/*.ts
````

### Breaking Change Workflow

```text
1. Document the breaking change
2. Create migration guide
3. Notify affected teams/consumers
4. Make the change
5. Update all internal consumers
6. Release with clear changelog
```

---

## Refactoring Patterns

### Extract Interface

```text
1. Define interface for existing class
2. Have class implement interface
3. Update consumers to use interface type
4. Now can add alternative implementations
```

### Rename/Move

```text
1. Create new name/location
2. Export from old location (re-export)
3. Update consumers to use new location
4. Remove re-export from old location
5. Delete old file if moved
```

### Split Module

```text
1. Create new modules
2. Move pieces to new modules
3. Re-export from original for compatibility
4. Update consumers to import from new locations
5. Remove re-exports from original
```

### Extract Service

```text
1. Create new service class
2. Move methods from original
3. Update original to delegate
4. Update consumers to use new service directly
5. Clean up delegation if consumers updated
```

---

## Verification Checklist

After completing multi-file refactor:

### Functionality

- [ ] All tests pass (unit, integration, e2e)
- [ ] Manual smoke test works
- [ ] No console errors or warnings

### Code Quality

- [ ] No commented-out code left behind
- [ ] No `TODO: remove` markers left
- [ ] No duplicate code created
- [ ] Naming is consistent across files

### Clean-up

- [ ] Unused imports removed
- [ ] Unused files deleted
- [ ] Old implementations removed
- [ ] Temporary compatibility code removed

### Documentation

- [ ] Breaking changes documented
- [ ] Migration guide created (if needed)
- [ ] API documentation updated
- [ ] Changelog updated

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| :--- | :--- | :--- |
| **Big bang without tests** | No safety net | Add tests first |
| **No verification points** | Errors accumulate | Verify after each batch |
| **Mixing refactor with features** | Hard to review/rollback | Separate commits/PRs |
| **Leaving broken state** | Can't deploy, blocks others | Keep buildable |
| **Skipping cleanup** | Tech debt remains | Finish refactor fully |
| **No rollback plan** | Stuck if things break | Plan rollback before starting |

---

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| Changing more than 10 files without a checkpoint | Stop, commit, verify, then continue | Large unreverified batches accumulate errors silently |
| No tests exist for the code being refactored | Write tests first, then refactor | Refactoring without tests is blind surgery |
| Mixing refactoring with new feature work | Separate into distinct PRs | Mixed PRs are impossible to review and risky to rollback |
| Build is broken and you continue editing | Fix the build first | Building on top of broken code compounds failures |
| "I'll clean up the old code later" | Delete it now or don't refactor | Abandoned cleanup becomes permanent tech debt |

---

## See Also

- [Context Management](../context-management/context-management.md) – Managing context for large tasks
- [Git Workflows with AI](../git-workflows-ai/git-workflows-ai.md) – Committing and reviewing refactors
