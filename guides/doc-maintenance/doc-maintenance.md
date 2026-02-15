# Documentation Maintenance

Guidelines for keeping documentation synchronized with code changes — preventing drift, tracking staleness, and propagating updates across related docs.

> **Scope**: Covers the workflow for maintaining docs when code changes, not the initial writing of documentation.
> For doc writing guidelines, see [Documentation Guidelines](../documentation-guidelines/documentation-guidelines.md).

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principle](#core-principle) |
| [Change Propagation Workflow](#change-propagation-workflow) |
| [Documentation Blast Radius](#documentation-blast-radius) |
| [Automated Verification](#automated-verification) |
| [PR Checklist for Documentation](#pr-checklist-for-documentation) |
| [Minimum Documentation CI Gates](#minimum-documentation-ci-gates) |
| [Scaffolding New Documentation](#scaffolding-new-documentation) |
| [Documentation Debt](#documentation-debt) |
| [Anti-Patterns](#anti-patterns) |
| [Red Flags](#red-flags) |

---

## Quick Reference

| Category | Guidance | Rationale |
| --- | --- | --- |
| **Always** | Update docs in the same PR as code changes | Prevents drift between code and docs |
| **Always** | Check the blast radius before committing | Every code change affects documentation |
| **Always** | Verify code examples in docs still work | Stale examples mislead and waste time |
| **Prefer** | Minimal docs that stay current over comprehensive docs that go stale | Accuracy over completeness |
| **Prefer** | Links to source over duplicating content | Single source of truth |
| **Never** | Say "I'll update docs later" | Later never comes — update now |
| **Never** | Leave docs describing removed features | Actively misleads users |

---

## Core Principle

**Every code change has a documentation blast radius.** Before committing any change, map which documents it affects and update them in the same PR.

| Change Type | Typical Blast Radius |
| --- | --- |
| New API endpoint | API docs, README, CHANGELOG, integration guides |
| Changed behavior | Inline comments, user-facing docs, CHANGELOG |
| New configuration option | README, environment docs, config reference |
| Removed feature | All references, migration guide, CHANGELOG |
| Renamed entity | Every file that mentions the old name |
| Dependency update | README (if minimum versions listed), CHANGELOG |

---

## Change Propagation Workflow

### 1. Identify — What Changed?

Categorize the code change:

| Category | Examples |
| --- | --- |
| **Public API** | New endpoint, changed response format, new parameter |
| **Behavior** | Algorithm change, default value change, error handling |
| **Configuration** | New environment variable, changed config format |
| **Structure** | File moved, module renamed, dependency added/removed |
| **Internal only** | Refactoring with no external impact → minimal doc update |

### 2. Map — What Docs Are Affected?

For each change category, check:

- [ ] **README** — Does it mention this feature, API, or config?
- [ ] **API docs** — Does an endpoint, parameter, or response change?
- [ ] **Inline comments** — Do code comments reference this behavior?
- [ ] **Configuration reference** — Is this setting documented?
- [ ] **Architecture docs** — Does this change the component structure?
- [ ] **CHANGELOG** — Does this need a user-facing changelog entry?
- [ ] **Migration guide** — Is this a breaking change?
- [ ] **Tutorials/guides** — Do step-by-step instructions reference this?

### 3. Update — Same PR, Same Commit

```text
Good: Code change + doc update in one PR
  ├── src/api/users.js        (changed endpoint)
  ├── docs/api/users.md       (updated API docs)
  ├── README.md               (updated setup instructions)
  └── CHANGELOG.md            (added entry)

Bad: Code change now, "docs PR later"
  ├── src/api/users.js        (changed endpoint)
  └── docs are now wrong until someone remembers to update them
```

### 4. Verify — Docs Match Code

| Check | How |
| --- | --- |
| Code examples work | Run them or verify against current API |
| Links resolve | Run link checker (e.g., `validate-navigation.sh`) |
| Version numbers are current | Grep for version strings |
| Screenshots reflect current UI | Compare against running app |
| CLI commands work | Execute them in a clean environment |

---

## Documentation Blast Radius

Use this matrix to quickly map code changes to their documentation impact:

| Code Change | README | API Docs | CHANGELOG | Config Docs | Architecture | Inline Comments |
| --- | --- | --- | --- | --- | --- | --- |
| **New feature** | ✅ | ✅ | ✅ | If configurable | If new component | ✅ |
| **Bug fix** | — | — | ✅ | — | — | If complex fix |
| **Breaking change** | ✅ | ✅ | ✅ | ✅ | — | ✅ |
| **Config change** | ✅ | — | ✅ | ✅ | — | — |
| **Dependency update** | If min version changes | — | ✅ | — | If architecture changes | — |
| **Refactoring** | — | If API unchanged | — | — | If components moved | Update stale comments |
| **Removal** | ✅ | ✅ | ✅ | ✅ | ✅ | Remove |

---

## Automated Verification

### Link Validation

Run link checkers as part of CI to catch broken references:

```bash
# Project-specific validation
npm run validate

# Generic link checking
markdown-link-check README.md
```

### Example Code Verification

```bash
# Extract code blocks from docs and test them
# (framework-specific — use pytest, jest, or equivalent)
pytest --doctest-glob="docs/**/*.md"
```

### Freshness Tracking

| Freshness | Threshold | Action |
| --- | --- | --- |
| **Current** | Updated within 90 days | No action needed |
| **Aging** | 90-180 days since last update | Review for accuracy |
| **Stale** | 180+ days since last update | Audit and update or delete |

```bash
# Find docs not modified in 180+ days
find docs/ -name "*.md" -mtime +180
```

---

## PR Checklist for Documentation

Use this checklist in pull requests that change behavior, APIs, or workflows.

| Checklist Item | Why |
| --- | --- |
| Documentation blast radius reviewed | Prevents silent drift |
| README/guide updates included when behavior changed | Keeps entry points accurate |
| Public API docstrings/docs updated | Preserves contract clarity |
| Added/updated tests for documented behavior | Keeps docs verifiable |
| Sensitive content review completed (no secrets/internal-only leak) | Reduces security exposure |

### Template Snippet

```markdown
### Documentation
- [ ] I reviewed documentation blast radius for this change
- [ ] I updated docs/docstrings/comments where behavior or contracts changed
- [ ] I added or updated tests/examples for documented behavior
- [ ] I verified no secrets or sensitive operational details were added to broad-access docs
```

---

## Minimum Documentation CI Gates

Documentation quality should be enforced by CI, not memory.

| Gate | Existing/Recommended Command | Failure Meaning |
| --- | --- | --- |
| Markdown lint | `npm run lint:md` | Formatting/structure drift |
| Navigation and link integrity | `npm run validate` | Broken internal links or out-of-sync indexes |
| External link check | GitHub `link-check` workflow | Stale external references |
| Adoption/docs smoke checks | `npm run validate:adoption:sim` | Drift in generated onboarding artifacts |

| Adoption Level | Required Gates |
| --- | --- |
| Minimum | Markdown lint + navigation validation |
| Standard | Minimum + external link checks |
| Strict | Standard + doc examples/tests where supported |

---

## Scaffolding New Documentation

When a new feature doesn't have documentation yet, create a minimum viable doc:

### Minimum Viable Doc Template

```markdown
# [Feature Name]

[One-paragraph overview: what this does and why it exists.]

## Quick Start

[The simplest working example — 3-5 lines max.]

## Configuration

[Required settings, if any.]

## See Also

[Links to related docs.]
```

### Placement Rules

| Content Type | Location |
| --- | --- |
| User-facing feature | `docs/` or equivalent docs directory |
| API endpoint | API documentation directory |
| Architecture decision | `docs/adr/` or `docs/decisions/` |
| Development guide | `CONTRIBUTING.md` or `docs/development/` |
| Quick reference | README.md |

---

## Documentation Debt

### Identifying Stale Docs

| Signal | Meaning |
| --- | --- |
| Doc mentions versions that are multiple releases behind | Needs version update |
| Code examples produce errors or warnings | Needs code update |
| Doc describes a feature that was removed | Needs deletion or migration note |
| Users/developers keep asking about something the doc supposedly covers | Doc is not clear enough |
| `git log --diff-filter=M -- src/` shows changes not reflected in docs | Drift has occurred |

### Documentation Review Cadence

| Cadence | Scope | Focus |
| --- | --- | --- |
| **Every PR** | Changed files' related docs | Blast radius check |
| **Monthly** | High-traffic docs (README, onboarding) | Freshness and accuracy |
| **Quarterly** | Full doc inventory | Staleness audit, retirement |

### Retiring Documentation

When documentation is no longer relevant:

1. Mark as deprecated with a date and reason
2. Point to replacement documentation if any exists
3. Remove after one release cycle (or immediately if misleading)

Do not archive product/operational docs by default — they become invisible and stale.
Exception: planning artifacts follow the lifecycle in
`guides/planning-documentation/planning-documentation.md` and may be archived after extracting enduring decisions.

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| --- | --- | --- |
| **"Docs later" commits** | Docs drift from code immediately | Update docs in same PR |
| **Duplicated content** | Two copies, one inevitably wrong | Link to single source of truth |
| **Stale screenshots** | UI has changed, screenshots mislead | Use automated screenshot tools or remove |
| **Version-locked examples** | Examples break on next release | Test examples in CI |
| **Changelog neglect** | Users don't know what changed | Add CHANGELOG entries per PR |
| **TODO docs** | "Coming soon" never comes | Write minimum viable doc now |

---

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| PR has code changes but zero doc changes | Check the blast radius matrix | Most code changes affect some documentation |
| "I'll update docs in a follow-up PR" | Update now — in the same PR | Follow-up docs PRs have a 90%+ abandonment rate |
| Docs describe behavior that no longer exists | Delete or update immediately | Stale docs actively harm users |
| Users keep asking about a documented feature | The doc isn't clear enough — rewrite | FAQ questions indicate doc failure |
| New feature merged with no documentation | Create minimum viable doc before next task | Undocumented features are invisible features |
| Code examples in docs are untested | Add to CI or verify manually | Broken examples destroy trust |

---

## See Also

- [Documentation Guidelines](../documentation-guidelines/documentation-guidelines.md) – What to document and how
- [Writing Best Practices](../writing-best-practices/writing-best-practices.md) – Documentation quality standards
- [Planning Documentation](../planning-documentation/planning-documentation.md) – Roadmaps, RFCs, ADRs
