# Phase 1 PR Split (Archived, v0.1)

PR-sized patch set proposal for Phase 1 (“Make Current Changes Reviewable”) from `docs/plans/implementation-plan.md`.

| Field | Value |
| --- | --- |
| **Version** | `0.1` |
| **Last updated** | 2026-02-02 |
| **Status** | Archived (Phase 1 complete; kept for reference) |
| **Primary goal** | Make large diffs reviewable with minimal human time |
| **Quality gate** | `npm run precommit` (must be green for every PR) |

## Contents

| Section |
| --- |
| [Proposed PR Series](#proposed-pr-series) |
| [Staging Commands](#staging-commands) |
| [Validation per PR](#validation-per-pr) |
| [Rollback](#rollback) |

---

## Proposed PR Series

This split optimizes for:

| Constraint | Approach |
| --- | --- |
| Large guide changes | One guide rewrite per PR for the largest files |
| Minimal human time | Early PRs are low-risk; later PRs are isolated rewrites |
| Safe dependency ordering | Tooling/QA lands before doc changes that rely on it |

### Core PRs (recommended to ship first)

| PR | Title | Files | Size (lines changed) | Depends on |
| --- | --- | --- | --- | --- |
| 1 | Tooling + audit bump | Tooling/CI/lint/deps | Large (lockfile) | None |
| 2 | Repo meta + roadmap + plan docs | README/AGENTS + planning docs | Small/Medium | PR 1 |
| 3 | Adoption template: add Contents table | `adoption/template-agents.md` | Small | PR 2 |

### Guide rewrites (isolate risk; ship after PR 1–3)

| PR | Guide | Size (lines changed) |
| --- | --- | --- |
| 4 | `guides/coding-guidelines/coding-guidelines.md` | 586 |
| 5 | `guides/debugging-with-ai/debugging-with-ai.md` | 554 |
| 6 | `guides/context-management/context-management.md` | 540 |
| 7 | `guides/dependency-management/dependency-management.md` | 482 |
| 8 | `guides/commenting-guidelines/commenting-guidelines.md` | 463 |
| 9 | `guides/code-review-ai/code-review-ai.md` | 443 |
| 10 | `guides/architecture-for-ai/architecture-for-ai.md` | 354 |
| 11 | `guides/cicd-pipelines/cicd-pipelines.md` | 324 |
| 12 | `guides/codebase-organization/codebase-organization.md` | 289 |
| 13 | `guides/deployment-strategies/deployment-strategies.md` | 266 |
| 14 | `guides/agents-md/agents-md-guidelines.md` | 247 |

### Medium/small guide updates (bundle safely)

| PR | Files | Size (lines changed) | Notes |
| --- | --- | --- | --- |
| 15 | `guides/database-indexing/database-indexing.md`, `guides/prompting-patterns/prompting-patterns.md`, `guides/planning-documentation/planning-documentation.md` | 543 | If too large, split into 15a/15b |
| 16 | `guides/logging-practices/logging-practices.md`, `guides/multi-file-refactoring/multi-file-refactoring.md`, `guides/prd-for-agents/prd-for-agents.md` | 389 | Low coupling |
| 17 | `guides/privacy-compliance/privacy-compliance.md`, `guides/security-boundaries/security-boundaries.md`, `guides/secure-coding/secure-coding.md`, `guides/static-analysis/static-analysis.md`, `guides/supply-chain-security/supply-chain-security.md`, `guides/testing-ai-code/testing-ai-code.md`, `guides/testing-strategy/testing-strategy.md`, `guides/tool-configuration/tool-configuration.md`, `guides/writing-best-practices/writing-best-practices.md`, `guides/api-design/api-design.md`, `guides/secrets-configuration/secrets-configuration.md`, `guides/observability-patterns/observability-patterns.md`, `guides/resilience-patterns/resilience-patterns.md`, `guides/documentation-guidelines/documentation-guidelines.md` | ~490 | Keep as “small fixes” bucket |

---

## Staging Commands

These commands stage one PR at a time. After staging, review with `git diff --staged`, then commit.

### PR 1 — Tooling + audit bump

```bash
git reset
git add \
  package.json \
  package-lock.json \
  .markdownlint.jsonc \
  scripts/validate-navigation.sh \
  .husky/pre-commit \
  .github/workflows/lint.yml
```

### PR 2 — Repo meta + roadmap + plan docs

```bash
git reset
git add \
  README.md \
  AGENTS.md \
  docs/plans/implementation-plan.md \
  docs/archive/phase-1-pr-split.md \
  docs/archive/phase-1-ship-revert-summary.md
```

### PR 3 — Adoption template (Contents table)

```bash
git reset
git add adoption/template-agents.md
```

### PR 4+ — Guide rewrite PRs

One guide per PR for the largest changes:

```bash
git reset
git add guides/coding-guidelines/coding-guidelines.md
```

---

## Validation per PR

| PR type | Required validation |
| --- | --- |
| Tooling/deps | `npm run precommit` and `npm audit` |
| Docs/meta | `npm run precommit` |
| Guide rewrites | `npm run precommit` |

---

## Rollback

| Scenario | Rollback |
| --- | --- |
| Tooling PR breaks CI | Revert PR 1 first; rerun `npm run precommit` |
| A guide rewrite is wrong | Revert only that PR; no dependency on other guides |
