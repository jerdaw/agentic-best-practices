# CI/CD Pipelines with AI

Best practices for managing CI/CD pipelines while working with AI coding agents.

> **Scope**: Applies to the creation, modification, and maintenance of CI/CD workflows (GitHub Actions, GitLab CI, etc.).
> Goal: Enable AI to work within safety boundaries while ensuring automated deployments remain secure and robust.

## Contents

| Section |
| :--- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Workflow Structure](#workflow-structure) |
| [Security Boundaries](#security-boundaries) |
| [Testing in CI](#testing-in-ci) |
| [Deployment Gates](#deployment-gates) |
| [Anti-Patterns](#anti-patterns) |

---

## Quick Reference

| Category | Guidance | Rationale |
| :--- | :--- | :--- |
| **Always** | Require manual approval for production | Prevent automated rogue deployments |
| **Always** | Use short-lived OIDC tokens for cloud | Avoid permanent secrets in CI |
| **Always** | Pin action versions to full SHAs | Prevent supply chain attacks |
| **Always** | Run security scans in the pipeline | Automate vulnerability detection |
| **Prefer** | Smaller, modular workflows | Easier for AI to reason about |
| **Never** | Allow AI to modify deployment secrets | Protects critical infrastructure |

---

## Core Principles

| Principle | Guideline | Rationale |
| :--- | :--- | :--- |
| **Security first** | Agents need strict boundaries in CI/CD | CI/CD is the most sensitive part of the system |
| **Deterministic steps** | Make every pipeline stage explicit | "Magic" scripts hide failures and hinder debugging |
| **Fail fast** | Run the fastest, most critical checks first (lint, types) | Early failures save time and compute |
| **Immutable artifacts** | Build once, deploy across environments | Eliminates "works in staging" drift |
| **Auditable changes** | Every pipeline change must be human-reviewed | Prevents unauthorized infrastructure modifications |

---

## Workflow Structure

Break pipelines into logical stages that agents can understand and verify independently.

### Recommended Stages

| Stage | Actions | Goal |
| :--- | :--- | :--- |
| **1. Validate** | Lint, Type-check, Format check | Code quality gate |
| **2. Test** | Unit tests, Integration tests | Functional correctness |
| **3. Security** | SAST, Dependency scan, Secret scan | Attack surface reduction |
| **4. Build** | Compile, Containerize, Sign | Artifact creation |
| **5. Deploy** | Update infra, Run migrations | Release execution |

### GitHub Actions Pattern

```yaml
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Lint
        run: npm run lint
      - name: Type-check
        run: npm run typecheck

  test:
    needs: validate
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Unit Tests
        run: npm test
```

---

## Security Boundaries

Strict rules for agents when modifying CI/CD infrastructure.

| Action | Policy | Rationale |
| :--- | :--- | :--- |
| **Secret Access** | **Never** share with agent | Agents should only know secret *names* |
| **Token Scopes** | **Minimum** required | Limits blast radius of compromised runs |
| **Approval** | **Human Review** always | Prevents automated infrastructure changes |
| **Pinning** | **Always** use SHAs | `actions/checkout@v4` → `actions/checkout@[sha]` |

---

## Testing in CI

Automate the verification of agent-produced code.

| Type | Best Practice |
| :--- | :--- |
| **Coverage** | Block PRs that decrease coverage threshold |
| **Regression**| Run targeted tests on changed modules |
| **E2E** | Run in ephemeral environments before merge |
| **Performance**| Track bundle size and API latency trends |

---

## Deployment Gates

Safety mechanisms to prevent bad deployments.

| Gate | Implementation |
| :--- | :--- |
| **Manual Trigger**| `on: workflow_dispatch` in GitHub Actions |
| **Environment** | Use GitHub Environments with required reviewers |
| **Rollback** | Automated rollback on health check failure |
| **Smoke Test** | Post-deployment validation in staging |

### Production Gate Example

```yaml
name: Deploy Production

on:
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://app.example.com
    permissions:
      id-token: write
      contents: read
    steps:
      - uses: actions/checkout@v4
      - name: Build once
        run: npm run build
      - name: Deploy
        run: npm run deploy:prod
      - name: Smoke test
        run: npm run smoke:prod
```

---

### Good vs Bad Example

| Pattern | Example | Why |
| :--- | :--- | :--- |
| **Good** | Separate `validate`, `test`, and `deploy` jobs with production environment approvals | Isolates failures and prevents unsafe automatic releases |
| **Bad** | One script does build + deploy with broad credentials and no approval gate | Hard to debug and high risk if anything fails or is compromised |

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| :--- | :--- | :--- |
| **Monolithic script** | AI can't debug partial failures | Break into distinct pipeline steps |
| **Broad permissions** | Agent could leak all secrets | Use scoped OIDC/Identity Federation |
| **No version pinning** | Breaking changes from actions | Pin to exact commit SHAs |
| **Skipping CI** | Untested code reaches prod | Enforce branch protection rules |
| **Implicit state** | Flaky, hard to debug | Explicit inputs |

---

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| Skipping tests to ship faster | Restore the test stage — speed without safety is recklessness | Untested code in production causes outages |
| Hardcoded secrets in CI workflow files | Move to encrypted secrets / vault | Secrets in code are visible to everyone with repo access |
| No rollback plan for the deployment | Define rollback before deploying | Every deployment needs an undo strategy |
| Manual deployment steps mixed with automation | Automate fully or document the manual steps explicitly | Partially automated deploys are the most dangerous kind |
| CI pipeline takes > 30 minutes | Parallelize stages and cache dependencies | Slow pipelines get bypassed |

---

## See Also

- [Security Boundaries](../security-boundaries/security-boundaries.md) – General agent safety
- [Supply Chain Security](../supply-chain-security/supply-chain-security.md) – Hardening dependencies
- [Observability Patterns](../observability-patterns/observability-patterns.md) – Monitoring deployments
