---
name: doc-maintenance
description: Use when code changes may affect documentation, when adding new features that need docs, or when reviewing documentation freshness
---

# Documentation Maintenance

**Announce at start:** "Following the doc-maintenance skill to keep docs in sync."

## Core Rule

**Every code change has a documentation blast radius.** Map it before committing.

## Process

### 1. Map — Identify Affected Docs

After any code change, check:

- [ ] README mentions this feature?
- [ ] API docs cover this endpoint/function?
- [ ] Inline comments reference this behavior?
- [ ] Configuration docs list this setting?
- [ ] Architecture docs describe this component?
- [ ] CHANGELOG needs an entry?

### 2. Update — Same PR, Same Commit

| Change Type | Docs to Update |
| --- | --- |
| New API endpoint | API docs, README (if public), CHANGELOG |
| Changed behavior | Inline comments, user-facing docs, CHANGELOG |
| New configuration | README, environment docs, config reference |
| Removed feature | All references, migration guide, CHANGELOG |
| Renamed entity | All references (grep for old name) |

### 3. Scaffold — New Features Need New Docs

If a feature doesn't have documentation yet:

1. Create a minimal doc (title + one-paragraph overview + basic usage)
2. Add to navigation (README, AGENTS.md, or equivalent index)
3. Mark TODOs for sections to expand later

### 4. Verify — Docs Match Code

- [ ] Code examples in docs actually work
- [ ] Links to source files are correct
- [ ] Version numbers are current
- [ ] Screenshots/diagrams reflect current UI

## Red Flags — STOP

| Signal | Action |
| --- | --- |
| PR has code changes but no doc updates | Check the blast radius map |
| "I'll update docs later" | Update now — later never comes |
| Docs describe behavior that no longer exists | Delete or update immediately |
| New feature merged without any documentation | Create minimum viable doc before next task |

## Related Skills

| When | Invoke |
| --- | --- |
| Writing the code that needs docs | [planning](../planning/SKILL.md) |
| Ready to submit docs with code | [pr-writing](../pr-writing/SKILL.md) |
| Reviewing existing doc quality | [code-review](../code-review/SKILL.md) |

## Deep Reference

For principles, rationale, anti-patterns, and examples:

- `guides/doc-maintenance/doc-maintenance.md`
- `guides/documentation-guidelines/documentation-guidelines.md`
