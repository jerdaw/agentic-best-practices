# Deployment Strategies

Best practices for AI agents on planning, executing, and monitoring safe deployments.

> **Scope**: Applies to CI/CD pipelines, release management, and production rollouts. Goal: Ensure high availability
> and rapid recovery through structured, automated deployment patterns.

## Contents

| Section |
| :--- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Deployment Patterns](#deployment-patterns) |
| [Verification and Smoke Tests](#verification-and-smoke-tests) |
| [Rollback Procedures](#rollback-procedures) |
| [Infrastructure as Code (IaC)](#infrastructure-as-code-iac) |
| [Anti-Patterns](#anti-patterns) |

---

## Quick Reference

| Category | Guidance | Rationale |
| :--- | :--- | :--- |
| **Safety** | Always test in staging first | Catches environmental issues |
| **Velocity** | Use small, frequent deployments | Reduces change risk and blast radius |
| **Recovery** | Define rollback triggers upfront | Pre-planned recovery is faster |
| **Monitoring** | Watch "Golden Signals" during rollout| Immediate feedback on health |
| **Gates** | Use manual approval for production | Human oversight for critical infra |

---

## Core Principles

1. **Automate everything** – Manual steps are errors waiting to happen.
2. **Immutable infrastructure** – Replace, don't patch, existing servers.
3. **Zero-downtime** – Users should not experience interruptions during rollout.
4. **Visibility** – Deployments must be visible and trackable by the whole team.
5. **Fail-safe** – If a deployment fails, the system should return to a known good state.

---

## Deployment Patterns

| Pattern | How it Works | Pros |
| :--- | :--- | :--- |
| **Blue/Green** | Switch traffic between two identical envs| Instant rollback, zero downtime |
| **Canary** | Rollout to 5% of users first | Limits blast radius of failures |
| **Rolling** | Update instances one by one | Resource efficient |
| **Shadow** | Route real traffic to new env (no output)| Tests performance with real load |

---

## Verification and Smoke Tests

A deployment is not "done" until it is verified.

1. **Health Check** – `GET /health` must return 200.
2. **Smoke Test** – Critical user path execution (e.g., "Can I log in?").
3. **Metric Analysis** – Compare 5xx error rates against the previous version.
4. **Log Review** – Check for new unique errors in the aggregator.

---

## Rollback Procedures

Pre-planned steps to undo a bad deployment.

| Trigger | Action |
| :--- | :--- |
| **High error rate** | Automated rollback to N-1 |
| **Performance drop** | Manual rollback after investigation |
| **Security flaw** | Emergency hotfix or immediate rollback |

---

## Infrastructure as Code (IaC)

Manage infrastructure with the same rigor as application code.

- **Version Control** – Track every infra change in Git.
- **Pull Requests** – Review infra changes like code changes.
- **Drift Detection** – Ensure real infra matches the code definition.

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| :--- | :--- | :--- |
| **Friday Deploys** | No support if things break | Deploy Monday-Thursday |
| **Big Bang Release** | High risk, hard to debug | Use feature flags and canaries |
| **Manual Config** | Environment drift, non-reproducible| Use IaC and config management |
| **No Monitoring** | Flying blind during rollout | Implement health checks and metrics |
| **Missing Rollback** | Stuck in a broken state | Test your rollback procedure |

---

## See Also

- [CI/CD Pipelines](../cicd-pipelines/cicd-pipelines.md) – Automated workflow
- [Observability Patterns](../observability-patterns/observability-patterns.md) – Monitoring health
- [Resilience Patterns](../resilience-patterns/resilience-patterns.md) – Handling failures
