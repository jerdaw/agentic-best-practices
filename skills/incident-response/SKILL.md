---
name: incident-response
description: Use when handling incidents, outages, severe regressions, or operational emergencies before attempting broad fixes
---

# Incident Response

**Announce at start:** "Following the incident-response skill — stabilize, contain, communicate."

## Core Rule

**Stabilize first, speculate later.** During an incident, the fastest safe path is containment, not cleverness.

## Process

### 1. Classify Impact

Before changing anything, establish:

- [ ] Severity level
- [ ] Affected users, systems, and regions
- [ ] Start time or first known bad signal
- [ ] Current blast radius
- [ ] Incident owner / commander

### 2. Contain the Blast Radius

Choose the smallest safe action that reduces harm:

| Trigger | Containment action |
| --- | --- |
| Recent deploy caused regression | Roll back or disable via feature flag |
| Traffic spike or bad client behavior | Rate-limit, shed load, or block source |
| Broken dependency or integration | Fail closed or switch to degraded mode |
| Data corruption risk | Freeze writes before attempting repair |

### 3. Preserve Evidence

Capture enough evidence to debug and review later:

- [ ] Logs around incident start
- [ ] Metrics and traces for the failing path
- [ ] Exact version / commit / config involved
- [ ] Timeline of key events and actions taken
- [ ] Screenshots or links to dashboards if helpful

### 4. Communicate Clearly

Use short status updates with a next update time:

```markdown
Severity: SEV-2
Impact: Checkout errors for ~35% of requests in us-east
Current action: Rolling back deployment `2026.04.20-3`
Owner: platform-oncall
Next update: 15 minutes
```

### 5. Mitigate Safely

After containment, apply the minimal change that restores service:

- Prefer rollback over novel code under pressure
- Change one thing at a time
- Verify after each action before stacking another
- Keep a written timeline of decisions and outcomes

### 6. Verify Recovery

Recovery is not complete until the system is stable:

- [ ] Health checks green
- [ ] Error rate back to normal range
- [ ] Latency within acceptable bounds
- [ ] Critical user path works
- [ ] Monitoring quiet for a defined watch window

### 7. Close Out

After service is stable:

- [ ] Write a blameless incident summary
- [ ] Capture follow-up actions with owners
- [ ] Update runbooks or alerts if gaps were found
- [ ] Record durable decision notes if response policy changed

## Red Flags — STOP

| Signal | Action |
| --- | --- |
| Multiple responders pushing unrelated fixes at once | Assign a single incident owner and sequence actions |
| No one can state current user impact | Reassess severity and scope before more changes |
| Deleting logs or rotating evidence before capture | Preserve evidence first |
| Rewriting broad areas of code during outage | Prefer rollback or minimal mitigation |
| Silent status gap longer than agreed cadence | Send an update immediately |

## Verification Checklist

- [ ] Impact, severity, and owner were identified
- [ ] Containment reduced blast radius before deep debugging
- [ ] Evidence was preserved before cleanup
- [ ] Recovery was verified with metrics and user-path checks
- [ ] Follow-up work was recorded after stabilization

## Related Skills

| When | Invoke |
| --- | --- |
| Need root cause after stabilization | [debugging](../debugging/SKILL.md) |
| Incident requires rollback or traffic control | [deployment](../deployment/SKILL.md) |
| Need better incident logging or redaction | [logging](../logging/SKILL.md) |
| Response touches security-sensitive systems | [secure-coding](../secure-coding/SKILL.md) |

## Deep Reference

For principles, rationale, anti-patterns, and examples:

- `guides/incident-response/incident-response.md`
- `guides/observability-patterns/observability-patterns.md`
- `guides/logging-practices/logging-practices.md`
