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

| Principle | Guideline | Rationale |
| :--- | :--- | :--- |
| **Automate everything** | Eliminate manual steps from the deploy path | Manual steps are errors waiting to happen |
| **Immutable infrastructure** | Replace, don't patch, existing servers | Prevents configuration drift and snowflake environments |
| **Zero-downtime** | Users should not experience interruptions during rollout | Downtime erodes trust and costs revenue |
| **Visibility** | Deployments must be visible and trackable by the whole team | Hidden deploys prevent diagnosis and coordination |
| **Fail-safe** | If a deployment fails, the system returns to a known good state | Unrecoverable failures compound into outages |

---

## Deployment Patterns

| Pattern | How it Works | Pros |
| :--- | :--- | :--- |
| **Blue/Green** | Switch traffic between two identical envs| Instant rollback, zero downtime |
| **Canary** | Rollout to 5% of users first | Limits blast radius of failures |
| **Rolling** | Update instances one by one | Resource efficient |
| **Shadow** | Route real traffic to new env (no output)| Tests performance with real load |

### Examples

**Good: Blue/Green deployment with instant rollback**

```yaml
# kubernetes/deployment.yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp
spec:
  selector:
    app: myapp
    version: blue  # Switch to 'green' to cut over
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-blue
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
      version: blue
  template:
    metadata:
      labels:
        app: myapp
        version: blue
    spec:
      containers:
      - name: myapp
        image: myapp:v1.2.3
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-green
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
      version: green
  template:
    metadata:
      labels:
        app: myapp
        version: green
    spec:
      containers:
      - name: myapp
        image: myapp:v1.2.4  # New version
```

Deploy green, verify health, update Service selector to `version: green`, instant cutover. Rollback = change selector back to `blue`.

**Bad: Direct in-place update**

```bash
# Update running containers directly
kubectl set image deployment/myapp myapp=myapp:v1.2.4
# If it fails, users see errors during rollback
```

**Good: Canary with gradual rollout**

```yaml
# 95% traffic to stable, 5% to canary
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: myapp
spec:
  http:
  - match:
    - headers:
        canary:
          exact: "true"
    route:
    - destination:
        host: myapp
        subset: canary
  - route:
    - destination:
        host: myapp
        subset: stable
      weight: 95
    - destination:
        host: myapp
        subset: canary
      weight: 5
```

Monitor error rates for canary subset. Increase weight if healthy, rollback if errors spike.

**Bad: All-or-nothing release**

```bash
# Deploy to all servers at once
ansible-playbook deploy.yml --limit production
# If bugs exist, 100% of users affected
```

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

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| Deploying to production on a Friday afternoon | Postpone to Monday unless critical | Weekend deploys have no support staff if things break |
| No rollback plan documented before deployment | Define rollback triggers and procedure first | Without a plan, rollback under incident pressure takes 10× longer |
| Deploying to production without staging verification | Run in staging first, then promote | Skipping staging makes production the test environment |
| All-at-once deployment to 100% of traffic | Use canary or blue/green to limit blast radius | Full rollout means 100% of users hit any bug simultaneously |
| Manual SSH into servers to deploy | Automate with CI/CD pipeline | Manual deploys are unreproducible and error-prone |

---

## See Also

- [CI/CD Pipelines](../cicd-pipelines/cicd-pipelines.md) – Automated workflow
- [Observability Patterns](../observability-patterns/observability-patterns.md) – Monitoring health
- [Resilience Patterns](../resilience-patterns/resilience-patterns.md) – Handling failures
- [Incident Response](../incident-response/incident-response.md) – When deployments cause incidents
