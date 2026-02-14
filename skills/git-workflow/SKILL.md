---
name: git-workflow
description: Execute safe Git workflows — branching, committing, resolving conflicts, and managing PRs
---

# Git Workflow

Safe Git operations for branching, committing, conflict resolution, and pull request management.

## When to Use

- Creating feature branches and managing commit history
- Resolving merge conflicts
- Preparing and submitting pull requests
- Rebasing or squashing commits

## Workflow

### 1. Branch Creation

```bash
# Always branch from up-to-date main
git fetch origin
git checkout -b <type>/<short-description> origin/main
```

**Branch naming**: `feat/`, `fix/`, `refactor/`, `docs/`, `chore/`

### 2. Commit Patterns

Write atomic commits — one logical change per commit.

```bash
# Stage specific files, not everything
git add <file1> <file2>

# Commit with conventional format
git commit -m "<type>(<scope>): <description>"
```

**Conventional types**: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`

| Do | Don't |
| --- | --- |
| One logical change per commit | Bundle unrelated changes |
| Descriptive message explaining "what" | `git commit -m "updates"` |
| Stage specific files | `git add .` blindly |

### 3. Keeping Up to Date

```bash
# Rebase on main to keep linear history
git fetch origin
git rebase origin/main

# If conflicts arise, resolve then continue
git add <resolved-files>
git rebase --continue
```

### 4. Conflict Resolution

1. Read both sides of the conflict carefully
2. Understand the intent of each change
3. Merge intentionally — never accept "ours" or "theirs" blindly
4. Run tests after resolving

### 5. Pull Request Preparation

```bash
# Squash fixup commits before PR
git rebase -i origin/main

# Push (first time)
git push -u origin <branch-name>

# Push after rebase (force-with-lease, never --force)
git push --force-with-lease
```

### 6. PR Checklist

- [ ] Branch is up to date with main
- [ ] All tests pass
- [ ] Commit messages follow convention
- [ ] Description explains what and why
- [ ] No unrelated changes included
- [ ] No secrets or credentials in the diff

## Red Flags

| Signal | Action |
| --- | --- |
| `git push --force` on shared branch | Use `--force-with-lease` |
| Credentials in a commit | Rotate immediately, rewrite history |
| 20+ files changed with vague message | Split into logical commits |
| Merge conflict resolved without reading both sides | Re-resolve intentionally |

## Related Skills

| Skill | When |
| --- | --- |
| [pr-writing](../pr-writing/SKILL.md) | Writing the PR description |
| [code-review](../code-review/SKILL.md) | Reviewing the resulting PR |
| [refactoring](../refactoring/SKILL.md) | When the branch contains a refactor |

## Backing Guide

- [Git Workflows with AI](../../guides/git-workflows-ai/git-workflows-ai.md)
