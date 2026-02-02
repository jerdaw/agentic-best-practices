# CI/CD Pipeline Design

Guidelines for building continuous integration and delivery pipelines that are fast, reliable, and maintainable.

> **Scope**: Applies to build automation, test execution, and deployment workflows. Agents must create pipelines that provide fast feedback while maintaining quality gates.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Pipeline Stages](#pipeline-stages) |
| [Build Stage](#build-stage) |
| [Test Stage](#test-stage) |
| [Deploy Stage](#deploy-stage) |
| [Pipeline Patterns](#pipeline-patterns) |
| [Anti-Patterns](#anti-patterns) |

---

## Quick Reference

| Category | Guidance | Rationale |
| --- | --- | --- |
| **Always** | Fail fast—run quick checks first | Faster feedback for common errors |
| **Always** | Use caching for dependencies | Speeds up builds significantly |
| **Always** | Pin dependency versions | Reproducible builds |
| **Always** | Treat main/master as always deployable | Trunk-based development |
| **Prefer** | Parallel stages over sequential | Faster overall pipeline |
| **Prefer** | Small, focused jobs over monolithic | Easier debugging and rerunning |
| **Never** | Store secrets in pipeline files | Use secret management |
| **Never** | Skip tests to "ship faster" | Tech debt compounds |
| **Never** | Allow failed pipelines to merge | Protects main branch |

---

## Core Principles

| Principle | Guideline | Rationale |
| --- | --- | --- |
| **Fast feedback** | Pipeline results in <10 min | Developers stay in flow |
| **Fail fast** | Cheap checks run first | Quick rejection of bad commits |
| **Reproducible** | Same commit → same result | Debuggable, trusted builds |
| **Parallelized** | Independent stages run concurrently | Optimizes total time |
| **Trunk-based** | Main is always deployable | Continuous delivery |

---

## Pipeline Stages

### Recommended Stage Order

| Order | Stage | Duration | Parallel? |
| --- | --- | --- | --- |
| 1 | **Lint & Format** | <1 min | Yes (with 2) |
| 2 | **Build** | 1-3 min | Yes (with 1) |
| 3 | **Unit Tests** | 1-3 min | After build |
| 4 | **Integration Tests** | 3-10 min | After unit |
| 5 | **Security Scan** | 2-5 min | Yes (with 3-4) |
| 6 | **Deploy Staging** | 2-5 min | After tests pass |
| 7 | **E2E Tests** | 5-15 min | On staging |
| 8 | **Deploy Production** | 2-5 min | Manual gate or auto |

### Stage Dependencies

```text
      ┌─────────────┐
      │  Checkout   │
      └──────┬──────┘
             │
    ┌────────┼────────┐
    ▼        ▼        ▼
┌──────┐ ┌──────┐ ┌──────┐
│ Lint │ │Build │ │SecScan│
└──┬───┘ └──┬───┘ └──┬───┘
   │        │        │
   └────────┼────────┘
            ▼
      ┌───────────┐
      │ Unit Test │
      └─────┬─────┘
            ▼
   ┌─────────────────┐
   │ Integration Test │
   └────────┬────────┘
            ▼
      ┌───────────┐
      │  Staging  │
      └─────┬─────┘
            ▼
    ┌──────────────┐
    │ E2E on Stage │
    └──────┬───────┘
            ▼
      ┌───────────┐
      │Production │
      └───────────┘
```

---

## Build Stage

### Caching Strategy

| Cache Target | Key Pattern | Invalidate On |
| --- | --- | --- |
| Dependencies | `hash(lockfile)` | Lockfile changes |
| Build artifacts | `hash(src) + hash(config)` | Source changes |
| Docker layers | Previous image layers | Dockerfile changes |

```yaml
# GitHub Actions caching example
- uses: actions/cache@v3
  with:
    path: ~/.npm
    key: npm-${{ hashFiles('package-lock.json') }}
    restore-keys: npm-

- uses: actions/cache@v3
  with:
    path: node_modules
    key: node-modules-${{ hashFiles('package-lock.json') }}
```

### Dependency Pinning

```json
// package-lock.json - exact versions locked
// requirements.txt - pin exact versions
flask==2.3.2
requests==2.31.0
```

---

## Test Stage

### Test Selection

| Trigger | Test Scope | Rationale |
| --- | --- | --- |
| Pull request | Unit + changed integration | Fast PR feedback |
| Merge to main | Full test suite | Comprehensive validation |
| Nightly | Full + E2E + performance | Catch slow-burning issues |
| Release tag | Full + regression | Release confidence |

### Test Parallelization

```yaml
# Matrix strategy for parallel test runs
test:
  strategy:
    matrix:
      shard: [1, 2, 3, 4]
  steps:
    - run: pytest --shard-id=${{ matrix.shard }} --num-shards=4
```

### Test Failure Handling

| Failure Type | Action |
| --- | --- |
| Flaky test | Retry once, then fail and alert |
| Timeout | Fail with diagnostic info |
| Infrastructure error | Retry job, not individual test |
| Consistent failure | Block merge, require fix |

---

## Deploy Stage

### Environment Progression

| Environment | Auto-deploy? | Purpose |
| --- | --- | --- |
| **Dev** | Yes | Individual feature branches |
| **Staging** | Yes (on main) | Integration testing |
| **Production** | Manual gate or canary | User-facing traffic |

### Deployment Configuration

```yaml
# Environment-specific config, not hardcoded
deploy:
  staging:
    replicas: 2
    resources:
      memory: 512Mi
  production:
    replicas: 10
    resources:
      memory: 2Gi
```

### Rollback Triggers

| Condition | Action |
| --- | --- |
| Deploy timeout | Rollback automatically |
| Health check fails | Rollback automatically |
| Error rate spike | Alert + manual decision or auto-rollback |

---

## Pipeline Patterns

### Fail-Fast Pipeline

Order checks from cheapest to most expensive.

```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm run lint  # Fails in seconds

  build:
    needs: lint  # Don't waste time if lint fails
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm run build

  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - run: npm test
```

### Branch Protection

| Rule | Effect |
| --- | --- |
| Require status checks | CI must pass to merge |
| Require up-to-date branch | Rebase before merge |
| Require code review | At least 1 approval |
| No force push to main | Protect history |

```yaml
# GitHub branch protection (settings.yml format)
branches:
  - name: main
    protection:
      required_status_checks:
        strict: true
        contexts:
          - lint
          - test
          - build
      required_pull_request_reviews:
        required_approving_review_count: 1
```

### Secret Management

| Practice | Implementation |
| --- | --- |
| Never hardcode | Use CI secret storage |
| Mask in logs | CI should redact automatically |
| Rotate regularly | Automate with secret manager |
| Least privilege | Scope secrets to environments |

```yaml
# Good: Secrets from CI secret storage
deploy:
  steps:
    - run: ./deploy.sh
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| --- | --- | --- |
| **30+ minute pipelines** | Too slow for feedback loops | Parallelize, cache, fail fast |
| **Flaky tests tolerated** | Erodes trust in CI | Fix or remove immediately |
| **Secrets in repo** | Security vulnerability | Use CI secret management |
| **Works on my machine** | Not reproducible | Pin versions, use containers |
| **Skip CI escape hatch** | Bypasses quality gates | Remove or require approval |
| **Manual deployment steps** | Error-prone, slow | Automate everything |
| **One mega-job** | Hard to debug, can't rerun | Split into focused jobs |
| **Testing in production** | User impact | Test in staging first |

---

## See Also

- [Deployment Strategies](../deployment-strategies/deployment-strategies.md) – Release patterns
- [Testing Strategy](../testing-strategy/testing-strategy.md) – Test pyramid and coverage
- [Git Workflows with AI](../git-workflows-ai/git-workflows-ai.md) – Branch strategies
- [Secrets & Configuration](../secrets-configuration/secrets-configuration.md) – Secret handling
