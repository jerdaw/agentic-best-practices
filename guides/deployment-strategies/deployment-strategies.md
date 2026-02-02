# Deployment Strategies

Guidelines for releasing changes to production safely with minimal risk.

> **Scope**: Applies to any system deployment—APIs, web apps, background workers, infrastructure. Agents must deploy with quick rollback capability and minimal user impact.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Deployment Patterns](#deployment-patterns) |
| [Feature Flags](#feature-flags) |
| [Rollback Strategies](#rollback-strategies) |
| [Monitoring During Rollout](#monitoring-during-rollout) |
| [Anti-Patterns](#anti-patterns) |

---

## Quick Reference

| Category | Guidance | Rationale |
| --- | --- | --- |
| **Always** | Deploy to staging first | Catches issues before production |
| **Always** | Have a rollback plan before deploying | Recovery must be instant |
| **Always** | Monitor error rates during rollout | Detect issues within minutes |
| **Prefer** | Feature flags over big-bang releases | Decouple deploy from release |
| **Prefer** | Gradual rollouts over all-at-once | Limits blast radius |
| **Prefer** | Blue-green or canary over in-place | Zero downtime, instant rollback |
| **Never** | Deploy without tested rollback | Traps you if something breaks |
| **Never** | Deploy during incidents or off-hours | Reduced response capacity |
| **Never** | Skip staging for "simple" changes | Simple changes can still break prod |

---

## Core Principles

| Principle | Guideline | Rationale |
| --- | --- | --- |
| **Fast rollback** | Seconds to revert, not minutes | Limits user impact |
| **Progressive delivery** | Start small, expand gradually | Early detection, limited blast |
| **Decouple deploy from release** | Code ships first, activation later | Separate deployment risk from feature risk |
| **Observable changes** | Every deploy is monitored | Know instantly when things break |
| **Backward compatible** | Old clients work with new code | Enables safe rollback |

---

## Deployment Patterns

### Pattern Comparison

| Pattern | Downtime | Rollback Speed | Resource Cost | Complexity | Best For |
| --- | --- | --- | --- | --- | --- |
| **Rolling** | None | Minutes | 1x | Low | Stateless services |
| **Blue-Green** | None | Seconds | 2x | Medium | Critical services |
| **Canary** | None | Seconds | 1.1x | Medium | User-facing changes |
| **Feature Flag** | None | Milliseconds | 1x | Low-Medium | Gradual feature rollout |

### Rolling Deployment

Old instances replaced one at a time. Simple but slower to rollback.

```yaml
# Kubernetes rolling update
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
```

| Phase | State | Effect |
| --- | --- | --- |
| Start | 4 old instances | 100% on old version |
| Mid | 2 old, 2 new | 50% each version |
| End | 4 new instances | 100% on new version |

### Blue-Green Deployment

Two identical environments. Switch traffic instantly via load balancer.

| Step | Action | Rollback |
| --- | --- | --- |
| 1 | Deploy new version to Green | N/A |
| 2 | Run smoke tests on Green | Delete Green |
| 3 | Switch LB from Blue → Green | Switch LB back to Blue |
| 4 | Monitor for issues | Switch LB back to Blue |
| 5 | Decommission Blue | N/A |

```text
                 ┌─────────────┐
                 │   Load      │
                 │  Balancer   │
                 └──────┬──────┘
                        │
         ┌──────────────┼──────────────┐
         ▼              │              ▼
   ┌─────────┐          │        ┌─────────┐
   │  Blue   │◄─────────┘        │  Green  │
   │  (v1)   │   (active)        │  (v2)   │
   └─────────┘                   └─────────┘
```

### Canary Deployment

Route small percentage of traffic to new version. Expand if healthy.

| Stage | Traffic Split | Duration | Action on Failure |
| --- | --- | --- | --- |
| Deploy | 0% canary | Immediate | No impact |
| Canary | 5% canary | 10-30 min | Route all to stable |
| Expand | 25% canary | 30 min | Route all to stable |
| Expand | 50% canary | 1 hour | Route all to stable |
| Full | 100% canary | N/A | Rollback deploy |

```yaml
# Istio canary routing
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
spec:
  http:
  - route:
    - destination:
        host: myservice
        subset: stable
      weight: 95
    - destination:
        host: myservice
        subset: canary
      weight: 5
```

---

## Feature Flags

Decouple code deployment from feature activation.

### Flag Lifecycle

| Phase | State | Purpose |
| --- | --- | --- |
| **Create** | Off | Code deployed but feature disabled |
| **Test** | Internal only | QA and dogfooding |
| **Rollout** | 5% → 25% → 50% → 100% | Gradual user exposure |
| **Stable** | 100% for 30+ days | Ready for cleanup |
| **Cleanup** | Remove flag code | Eliminate tech debt |

### Implementation

```python
# Good: Feature flag with consistent user bucketing
def is_feature_enabled(user_id: str, feature: str, percentage: int = 100) -> bool:
    # Consistent hash ensures same user always gets same experience
    bucket = hash(f"{user_id}:{feature}") % 100
    return bucket < percentage

# Usage
if is_feature_enabled(user.id, "new_checkout", percentage=10):
    return new_checkout_flow(cart)
else:
    return legacy_checkout_flow(cart)
```

```python
# Bad: Random assignment (inconsistent experience)
if random.random() < 0.1:  # User sees different versions each time
    return new_checkout_flow(cart)
```

### Flag Cleanup Rules

| Signal | Action |
| --- | --- |
| Flag at 100% for 30+ days | Schedule cleanup PR |
| Flag at 0% for 14+ days | Remove feature and flag |
| Flag unchanged for 90 days | Review: stale or forgotten |

---

## Rollback Strategies

### Rollback Decision Matrix

| Signal | Threshold | Action |
| --- | --- | --- |
| Error rate spike | >1% increase | Investigate immediately |
| Error rate sustained | >2% for 5 min | Rollback |
| Latency spike | >50% p99 increase | Investigate |
| Latency sustained | >100% p99 for 5 min | Rollback |
| Customer reports | 3+ related issues | Investigate |

### Rollback Mechanisms

| Method | Speed | Scope | Use When |
| --- | --- | --- | --- |
| Feature flag off | Milliseconds | Feature only | Flag-controlled feature |
| Traffic shift | Seconds | All traffic | Blue-green/canary |
| Revert deploy | Minutes | Full codebase | Rolling deployment |
| Revert commit | Minutes (needs deploy) | Specific change | Post-incident fix |

### Rollback Checklist

Before any deployment:

- [ ] Rollback mechanism identified
- [ ] Rollback tested in staging
- [ ] Monitoring dashboards open
- [ ] On-call aware of deployment
- [ ] Deployment window appropriate (not Friday 5pm)

---

## Monitoring During Rollout

### Golden Signals

| Signal | Metric | Alert Threshold |
| --- | --- | --- |
| **Latency** | p50, p95, p99 response time | >50% increase from baseline |
| **Traffic** | Requests per second | Unexpected drop (>20%) |
| **Errors** | Error rate (5xx / total) | >1% or 2x baseline |
| **Saturation** | CPU, memory, queue depth | >80% capacity |

### Deployment Monitoring

```python
# Good: Automated rollback on error spike
async def monitored_rollout(deployment):
    baseline_error_rate = get_current_error_rate()
    
    await deployment.start()
    
    for _ in range(30):  # Check every minute for 30 min
        await asyncio.sleep(60)
        current_error_rate = get_current_error_rate()
        
        if current_error_rate > baseline_error_rate * 2:
            await deployment.rollback()
            alert("Deployment rolled back due to error spike")
            return False
    
    return True
```

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| --- | --- | --- |
| **Big-bang deploys** | All-or-nothing risk | Progressive rollout |
| **Friday deploys** | Reduced response capacity | Deploy early in week |
| **No rollback plan** | Stuck when things break | Test rollback before deploy |
| **Skipping staging** | Prod is the first test | Always stage first |
| **Ignoring metrics** | Issues found by users | Monitor during rollout |
| **Long-lived feature flags** | Tech debt accumulates | Cleanup after stability |
| **Breaking changes without migration** | Old clients fail | Backward compatibility first |

---

## See Also

- [Resilience Patterns](../resilience-patterns/resilience-patterns.md) – Handling failures gracefully
- [Idempotency Patterns](../idempotency-patterns/idempotency-patterns.md) – Safe retry during deployments
- [Git Workflows with AI](../git-workflows-ai/git-workflows-ai.md) – Version control for releases
