# Phase 1 Ship / Hold Summary (Archived, v0.1)

Fast approval checklist for the Phase 1 PR split.

| Field | Value |
| --- | --- |
| **Version** | `0.1` |
| **Last updated** | 2026-02-02 |
| **Status** | Archived (Phase 1 complete; kept for reference) |
| **Default posture** | Ship low-risk infra/meta; isolate guide rewrites |
| **Why** | Large guide rewrites can change intent; ship them in isolated PRs |

## Contents

| Section |
| --- |
| [Default Ship Set](#default-ship-set) |
| [Hold Set (Isolated Guide Rewrites)](#hold-set-isolated-guide-rewrites) |
| [Per-File Summary](#per-file-summary) |

---

## Default Ship Set

| Bucket | What ships | Why |
| --- | --- | --- |
| Tooling + QA | Dev-dep audit bump + validator robustness + CI/Husky alignment | Keeps gates green and fixes security advisory noise |
| Repo meta/docs | Roadmap table + plan docs | Improves execution clarity without changing technical standards |
| Adoption template | Adds a Contents table | Improves usability; low risk |

---

## Hold Set (Isolated Guide Rewrites)

| Bucket | What to hold | Why |
| --- | --- | --- |
| Large guide rewrites | Files with hundreds of line changes | Higher chance of policy/meaning changes |
| Medium guide bundles | Bundled PRs 15–17 | Safer after big rewrites are reviewed/merged |

---

## Per-File Summary

Change size is computed as `insertions + deletions` for tracked files.

| File | Category | Size | Risk | Recommendation |
| --- | --- | ---: | --- | --- |
| `package.json` | Tooling/deps | 6 | Low | Ship (PR 1) |
| `package-lock.json` | Tooling/deps | 977 | Low | Ship (PR 1) |
| `.markdownlint.jsonc` | Tooling/lint | 7 | Low | Ship (PR 1) |
| `scripts/validate-navigation.sh` | Tooling/validation | 132 | Medium | Ship (PR 1) |
| `.husky/pre-commit` | Tooling/hooks | 2 | Low | Ship (PR 1) |
| `.github/workflows/lint.yml` | Tooling/CI | 2 | Low | Ship (PR 1) |
| `README.md` | Repo meta | 19 | Low | Ship (PR 2) |
| `AGENTS.md` | Repo meta | 1 | Low | Ship (PR 2) |
| `docs/plans/implementation-plan.md` | Repo docs | New | Low | Ship (PR 2) |
| `docs/archive/phase-1-pr-split.md` | Repo docs | New | Low | Ship (PR 2) |
| `docs/archive/phase-1-ship-revert-summary.md` | Repo docs | New | Low | Ship (PR 2) |
| `adoption/template-agents.md` | Adoption | 14 | Low | Ship (PR 3) |
| `guides/coding-guidelines/coding-guidelines.md` | Guide rewrite | 586 | High | Hold; ship alone (PR 4) |
| `guides/debugging-with-ai/debugging-with-ai.md` | Guide rewrite | 554 | High | Hold; ship alone (PR 5) |
| `guides/context-management/context-management.md` | Guide rewrite | 540 | High | Hold; ship alone (PR 6) |
| `guides/dependency-management/dependency-management.md` | Guide rewrite | 482 | High | Hold; ship alone (PR 7) |
| `guides/commenting-guidelines/commenting-guidelines.md` | Guide rewrite | 463 | High | Hold; ship alone (PR 8) |
| `guides/code-review-ai/code-review-ai.md` | Guide rewrite | 443 | High | Hold; ship alone (PR 9) |
| `guides/architecture-for-ai/architecture-for-ai.md` | Guide rewrite | 354 | High | Hold; ship alone (PR 10) |
| `guides/cicd-pipelines/cicd-pipelines.md` | Guide rewrite | 324 | High | Hold; ship alone (PR 11) |
| `guides/codebase-organization/codebase-organization.md` | Guide rewrite | 289 | High | Hold; ship alone (PR 12) |
| `guides/deployment-strategies/deployment-strategies.md` | Guide rewrite | 266 | High | Hold; ship alone (PR 13) |
| `guides/agents-md/agents-md-guidelines.md` | Guide rewrite | 247 | High | Hold; ship alone (PR 14) |
| `guides/database-indexing/database-indexing.md` | Guide update | 232 | Medium | Hold; bundle (PR 15) |
| `guides/prompting-patterns/prompting-patterns.md` | Guide update | 157 | Medium | Hold; bundle (PR 15) |
| `guides/planning-documentation/planning-documentation.md` | Guide update | 154 | Medium | Hold; bundle (PR 15) |
| `guides/logging-practices/logging-practices.md` | Guide update | 152 | Medium | Hold; bundle (PR 16) |
| `guides/multi-file-refactoring/multi-file-refactoring.md` | Guide update | 136 | Medium | Hold; bundle (PR 16) |
| `guides/prd-for-agents/prd-for-agents.md` | Guide update | 101 | Medium | Hold; bundle (PR 16) |
| `guides/writing-best-practices/writing-best-practices.md` | Guide update | 97 | Medium | Hold; bundle (PR 17) |
| `guides/privacy-compliance/privacy-compliance.md` | Guide update | 86 | Medium | Hold; bundle (PR 17) |
| `guides/security-boundaries/security-boundaries.md` | Guide update | 64 | Medium | Hold; bundle (PR 17) |
| `guides/observability-patterns/observability-patterns.md` | Guide update | 49 | Medium | Hold; bundle (PR 17) |
| `guides/tool-configuration/tool-configuration.md` | Guide update | 51 | Medium | Hold; bundle (PR 17) |
| `guides/testing-ai-code/testing-ai-code.md` | Guide update | 51 | Medium | Hold; bundle (PR 17) |
| `guides/resilience-patterns/resilience-patterns.md` | Guide update | 44 | Medium | Hold; bundle (PR 17) |
| `guides/supply-chain-security/supply-chain-security.md` | Guide update | 36 | Low | Hold; bundle (PR 17) |
| `guides/secure-coding/secure-coding.md` | Guide update | 33 | Low | Hold; bundle (PR 17) |
| `guides/static-analysis/static-analysis.md` | Guide update | 29 | Low | Hold; bundle (PR 17) |
| `guides/secrets-configuration/secrets-configuration.md` | Guide update | 27 | Low | Hold; bundle (PR 17) |
| `guides/testing-strategy/testing-strategy.md` | Guide update | 3 | Low | Hold; bundle (PR 17) |
| `guides/api-design/api-design.md` | Guide update | 3 | Low | Hold; bundle (PR 17) |
| `guides/documentation-guidelines/documentation-guidelines.md` | Guide update | 1 | Low | Hold; bundle (PR 17) |
