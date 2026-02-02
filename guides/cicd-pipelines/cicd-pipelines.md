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

1. **Security first** – CI/CD is the most sensitive part of the system; agents need strict boundaries.
2. **Deterministic steps** – Avoid "magic" scripts; make every pipeline stage explicit.
3. **Fail fast** – Run the fastest, most critical checks first (lint, types).
4. **Immutable artifacts** – Build once, deploy across environments.
5. **Auditable changes** – Every pipeline change must be human-reviewed.

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

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| :--- | :--- | :--- |
| **Monolithic script** | AI can't debug partial failures | Break into distinct pipeline steps |
| **Broad permissions** | Agent could leak all secrets | Use scoped OIDC/Identity Federation |
| **No version pinning** | Breaking changes from actions | Pin to exact commit SHAs |
| **Skipping CI** | Untested code reaches prod | Enforce branch protection rules |
| **Implicit state** | Flaky, non-reproducible builds | Use containers for build environments |

---

## See Also

- [Security Boundaries](../security-boundaries/security-boundaries.md) – General agent safety
- [Supply Chain Security](../supply-chain-security/supply-chain-security.md) – Hardening dependencies
- [Observability Patterns](../observability-patterns/observability-patterns.md) – Monitoring deployments
