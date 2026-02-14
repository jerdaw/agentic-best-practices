---
name: pr-writing
description: Use when creating PRs, writing commit messages, managing branches, or preparing code for merge
---

# PR Writing

**Announce at start:** "Following the pr-writing skill for this submission."

## Commit Messages

Use Conventional Commits format:

```text
<type>(<scope>): <description>

[Optional body with context]

[Optional footer with references]
```

### Commit Types

| Type | When | Example |
| --- | --- | --- |
| `feat` | New functionality | `feat(auth): add password reset flow` |
| `fix` | Bug fixes | `fix(api): handle null user in profile endpoint` |
| `refactor` | Code changes (no behavior change) | `refactor(db): extract query builder` |
| `test` | Adding/modifying tests | `test(auth): add edge cases for token expiry` |
| `docs` | Documentation changes | `docs: update API reference` |
| `chore` | Maintenance | `chore(deps): update express to 4.19` |

### Commit Rules

- One logical change per commit
- Imperative mood ("Add validation" not "Added validation")
- Reference issues when applicable ("Fixes #123")
- Separate refactors from feature changes

## PR Template

```markdown
## Summary
[One paragraph: what this PR does and why]

## Changes
- [Key change 1]
- [Key change 2]

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Manually tested: [scenarios]

## Evidence
[Test output, screenshots, or other proof]

## Risks and Rollback
- Risk: [What could go wrong]
- Rollback: [How to undo]
```

## Attribution Rules

| Rule | Rationale |
| --- | --- |
| **Human is always the author** | Humans are accountable; AI is a tool |
| **Never set AI as commit co-author** | AI should not appear in git authorship |
| **Never include "Generated with [AI tool]" in PR descriptions** | Unless the PR directly relates to that tool |
| **Note AI usage in PR body if significant** | Transparency for reviewers |

## Branch Naming

```text
<type>/<short-description>
```

| Branch | Purpose |
| --- | --- |
| `feat/user-auth` | New feature |
| `fix/login-null-check` | Bug fix |
| `refactor/api-layer` | Code cleanup |
| `chore/deps-update` | Maintenance |

## When to Squash

| Scenario | Action |
| --- | --- |
| Multiple iteration commits | Squash into one logical commit |
| Failed experiments | Drop entirely |
| Independent fixes | Keep separate |
| WIP "save work" commits | Squash |

## Related Skills

| When | Invoke |
| --- | --- |
| PR needs tests | [testing](../testing/SKILL.md) |
| PR needs code review | [code-review](../code-review/SKILL.md) |
| PR has security implications | [secure-coding](../secure-coding/SKILL.md) |

## Deep Reference

For principles, rationale, anti-patterns, and examples:
`guides/git-workflows-ai/git-workflows-ai.md`
