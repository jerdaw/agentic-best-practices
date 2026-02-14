---
name: deployment
description: Plan and execute safe deployments with rollback procedures, verification, and monitoring
---

# Deployment

Plan and execute safe deployments — rollback procedures, verification steps, and monitoring.

## When to Use

- Preparing a production deployment
- Setting up deployment pipelines
- Defining rollback procedures
- Verifying a deployment post-release

## Workflow

### 1. Pre-Deployment Checklist

Before deploying:

- [ ] All tests pass in CI
- [ ] Staging deployment verified
- [ ] Rollback procedure documented
- [ ] Monitoring alerts configured
- [ ] Not deploying on Friday afternoon

### 2. Choose a Deployment Strategy

| Strategy | When | Risk |
| --- | --- | --- |
| Blue/Green | Need instant rollback | Low — traffic switch |
| Canary | Testing with real traffic | Low — limited blast radius |
| Rolling | Resource-constrained environments | Medium — gradual exposure |
| Direct | Non-critical services only | High — all-or-nothing |

### 3. Deploy

```bash
# Example: Kubernetes blue/green
kubectl apply -f deployment-green.yaml
kubectl rollout status deployment/myapp-green

# Verify health
curl -f https://myapp-green.internal/health/ready

# Cut traffic
kubectl patch service myapp -p '{"spec":{"selector":{"version":"green"}}}'
```

### 4. Post-Deployment Verification

1. **Health check** — `/health/ready` returns 200
2. **Smoke test** — Critical user path works (e.g., login)
3. **Metrics** — Error rate and latency within normal range
4. **Logs** — No new error patterns in aggregator

### 5. Rollback (if needed)

| Trigger | Action |
| --- | --- |
| Error rate > 1% for 5 minutes | Automated rollback to N-1 |
| Performance degradation > 50% | Manual rollback after investigation |
| Security vulnerability found | Emergency rollback immediately |

```bash
# Blue/Green rollback — switch selector back
kubectl patch service myapp -p '{"spec":{"selector":{"version":"blue"}}}'
```

### 6. Post-Deploy

- [ ] Confirm metrics stable for 30 minutes
- [ ] Update deployment log/changelog
- [ ] Communicate to team

## Red Flags

| Signal | Action |
| --- | --- |
| Friday afternoon deploy | Postpone to Monday |
| No rollback plan | Define triggers and procedure first |
| Skipping staging | Run in staging first |
| 100% traffic on first deploy | Use canary or blue/green |

## Related Skills

| Skill | When |
| --- | --- |
| [e2e-testing](../e2e-testing/SKILL.md) | Smoke testing after deploy |
| [secure-coding](../secure-coding/SKILL.md) | Security review before release |
| [logging](../logging/SKILL.md) | Verifying logs post-deploy |

## Backing Guide

- [Deployment Strategies](../../guides/deployment-strategies/deployment-strategies.md)
