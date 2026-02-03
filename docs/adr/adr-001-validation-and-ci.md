# ADR-001: Treat documentation validation as the primary test suite

## Status

Accepted (2026-02-03)

## Context

This repository is documentation-first. Most regressions are:

| Regression type | Example |
| --- | --- |
| Navigation drift | Guide added but not indexed |
| Broken internal links | README/AGENTS links to non-existent files |
| Stale contents tables | Contents table entries no longer exist |

Traditional unit/integration tests do not cover these failures well. We need fast, reliable checks that run locally and in CI.

## Decision

Adopt documentation integrity checks as the primary quality gate:

| Decision | Implementation |
| --- | --- |
| Standardize the local gate | `npm run precommit` runs markdown lint + navigation validation |
| Validate indices | `scripts/validate-navigation.sh` checks `AGENTS.md` and `README.md` completeness + link targets |
| Run in CI | `.github/workflows/lint.yml` runs lint + validation on PRs and on a weekly schedule |

## Consequences

| Impact | Category | Rationale |
| --- | --- | --- |
| **Positive** | Reliability | Drift is detected before merge |
| **Positive** | Low cost | Checks run quickly and don’t require environments/services |
| **Neutral** | Scope | These checks don’t validate “semantic correctness” of guidance |
| **Negative** | Maintenance | The validator script must evolve as structure evolves |
