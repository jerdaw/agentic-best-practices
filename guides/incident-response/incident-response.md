# Incident Response

Best practices for structured incident response — severity classification, escalation chains, communication protocols, and blameless postmortems.

> **Scope**: Covers the full incident lifecycle from detection through resolution and retrospective. Applies to any team operating production systems.

## Contents

| Section |
| :--- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Severity Classification](#severity-classification) |
| [Incident Roles](#incident-roles) |
| [Escalation and On-Call](#escalation-and-on-call) |
| [Incident Communication](#incident-communication) |
| [Runbook Design](#runbook-design) |
| [Postmortem Process](#postmortem-process) |
| [Anti-Patterns](#anti-patterns) |
| [Red Flags](#red-flags) |
| [Checklist](#checklist) |
| [See Also](#see-also) |

---

## Quick Reference

**Severity levels**:

| Level | Impact | Response Time | Postmortem Required |
| :--- | :--- | :--- | :--- |
| **SEV1** | Complete outage, data loss, security breach | 15 minutes | Yes |
| **SEV2** | Major feature degraded, significant user impact | 30 minutes | Yes |
| **SEV3** | Minor feature impacted, workaround exists | 4 hours | Optional |
| **SEV4** | Cosmetic issue, no user impact | Next business day | No |

**Key rules**:

- Always declare a severity level when opening an incident
- Always write a postmortem for SEV1 and SEV2 incidents
- Always assign an incident commander for SEV1 and SEV2
- Never skip the retrospective — even if the fix was "obvious"

---

## Core Principles

1. **Detect fast, communicate faster** — Automated alerting catches problems; immediate communication keeps responders aligned
2. **Severity drives response** — Severity level determines who is paged, how fast, and what process applies
3. **Blameless by default** — Focus on systemic contributing factors, never individual blame
4. **Runbooks over heroics** — Documented procedures produce consistent outcomes; tribal knowledge does not
5. **Every incident improves the system** — Each postmortem must produce concrete, tracked action items

---

## Severity Classification

### Severity Levels

| Level | Description | Response Time | Who Is Paged | Example Scenarios |
| :--- | :--- | :--- | :--- | :--- |
| **SEV1** | Complete outage or data integrity loss | 15 minutes | On-call engineer + engineering lead + incident commander | Production down, data corruption, active security breach |
| **SEV2** | Major degradation with broad user impact | 30 minutes | On-call engineer + team lead | Payment processing failing, login broken for 50%+ users |
| **SEV3** | Minor degradation, workaround available | 4 hours | On-call engineer | Search results slow, non-critical API returning errors |
| **SEV4** | Cosmetic or low-impact issue | Next business day | Team backlog | UI alignment bug, non-user-facing log noise |

### Classification Decision Flow

Use this sequence to assign severity:

```text
Is there a complete outage or data loss?
  → Yes → SEV1

Is a major feature degraded with broad user impact?
  → Yes → SEV2

Is a minor feature impacted but a workaround exists?
  → Yes → SEV3

Is the issue cosmetic or internal-only?
  → Yes → SEV4
```

When in doubt, **classify higher** and downgrade later. Over-escalation wastes minutes; under-escalation wastes hours.

---

## Incident Roles

| Role | Responsibility | Required For |
| :--- | :--- | :--- |
| **Incident Commander** | Owns the incident; coordinates response, delegates tasks, controls communication | SEV1, SEV2 |
| **Technical Lead** | Drives diagnosis and resolution; makes technical decisions | SEV1, SEV2 |
| **Communications Lead** | Posts internal/external updates on cadence; shields responders from status requests | SEV1 |
| **Scribe** | Records timeline, decisions, and actions in the incident channel | SEV1 |
| **On-Call Responder** | First responder; triages and begins investigation | All severities |

Role separation prevents context-switching. The incident commander should not be debugging code; the technical lead should not be writing status updates.

---

## Escalation and On-Call

### Escalation Triggers

| Condition | Escalation Action |
| :--- | :--- |
| No acknowledgment within response time SLA | Page backup on-call |
| Incident unresolved after 30 minutes (SEV1) | Page engineering lead and incident commander |
| Incident unresolved after 1 hour (SEV2) | Page team lead |
| Customer data confirmed compromised | Page security team and executive on-call |
| Multiple services affected simultaneously | Page platform/infrastructure team |
| Responder requests help | Page the requested team immediately |

### On-Call Rotation Design

```yaml
# Bad: single-person on-call
on_call:
  primary: alice
  backup: none
  rotation: never
  handoff: "ask Alice"
```

```yaml
# Good: proper rotation with backup and clear handoff
on_call:
  schedule: weekly rotation
  primary: current week's engineer
  secondary: previous week's engineer
  escalation: engineering manager
  handoff:
    - Written summary in #incidents channel at rotation boundary
    - Open incidents transferred with context document
    - 30-minute overlap window between rotations
  compensation:
    - Time-off credit for after-hours pages
    - No back-to-back weeks without consent
```

---

## Incident Communication

### Internal Updates

| Severity | First Update | Recurring Updates | Channel |
| :--- | :--- | :--- | :--- |
| **SEV1** | Within 5 minutes of declaration | Every 15 minutes | #incidents + war room |
| **SEV2** | Within 15 minutes | Every 30 minutes | #incidents |
| **SEV3** | Within 1 hour | Every 2 hours | #incidents |
| **SEV4** | When assigned | On resolution | Team channel |

### External Communication

| Phase | Action | Owner |
| :--- | :--- | :--- |
| Detection | Post "Investigating" to status page | Incident commander |
| Identification | Update status page with affected services | Incident commander |
| Mitigation applied | Post "Monitoring" with summary | Incident commander |
| Resolution confirmed | Post "Resolved" with duration and impact | Incident commander |
| Follow-up | Publish postmortem link if SEV1/SEV2 | Engineering lead |

### Templates

```markdown
<!-- Bad: vague status update -->
## Incident Update
We are experiencing some issues. The team is looking into it.
We will provide another update soon.
```

```markdown
<!-- Good: structured status update -->
## Incident Update — 2026-02-26 14:35 UTC

**Status**: Identified
**Severity**: SEV1
**Impact**: Payment processing failing for all users since 14:12 UTC
**Current action**: Rolling back deploy v2.34.1 to v2.34.0
**Next update**: 14:50 UTC or sooner if status changes
**Incident commander**: @ops-lead
```

---

## Runbook Design

### Runbook Structure

Every runbook should contain these sections:

| Section | Purpose | Required |
| :--- | :--- | :--- |
| **Name** | Descriptive title matching the alert | Yes |
| **Trigger** | Exact alert or condition that activates this runbook | Yes |
| **Steps** | Numbered, copy-pasteable commands | Yes |
| **Verification** | How to confirm the fix worked | Yes |
| **Rollback** | How to undo the fix if it makes things worse | Yes |
| **Escalation** | Who to page if steps do not resolve the issue | Yes |
| **Last tested** | Date the runbook was last validated | Yes |

### Runbook Examples

```yaml
# Bad: vague runbook
name: Fix database issues
steps:
  - Check the database
  - Fix any problems
  - Restart if needed
```

```yaml
# Good: structured runbook
name: Database connection pool exhaustion
trigger: Alert "db_pool_active > 95% for 5m"
steps:
  - Run: kubectl exec deploy/api -- curl localhost:9090/metrics | grep db_pool
  - If active > max_pool_size * 0.95: proceed to step 3
  - Run: kubectl rollout restart deploy/api
  - Verify: watch "curl -s api.internal/health | jq .database"
  - If not resolved within 10 minutes: escalate to database on-call
rollback: N/A (restart is non-destructive)
escalation: database-oncall@company.com
last_tested: 2026-01-15
```

---

## Postmortem Process

### Blameless Retrospectives

Schedule the postmortem within 48 hours of resolution for SEV1/SEV2. Invite all responders plus affected team leads. Focus on contributing factors, not individuals.

```markdown
<!-- Bad: blame-focused -->
## Root Cause
John deployed broken code without testing. The team failed to catch the issue.

## Action Items
- John needs to be more careful
- Review John's recent PRs
```

```markdown
<!-- Good: blameless, systemic -->
## Contributing Factors
- Deploy pipeline lacked integration test stage for payment service
- Monitoring alert threshold was set 2x above the actual failure point
- Runbook for payment failures did not exist

## Action Items
- [ ] Add payment integration test to CI pipeline — @platform-team, due 2026-03-07
- [ ] Lower payment error rate alert from 10% to 5% — @observability-team, due 2026-03-03
- [ ] Write payment failure runbook — @payments-team, due 2026-03-10
```

### Timeline Format

Every postmortem needs a precise timeline. Use UTC timestamps.

```markdown
<!-- Bad: vague timeline -->
## Timeline
- Something went wrong around 2pm
- We noticed it after a while
- Eventually we fixed it
```

```markdown
<!-- Good: precise timeline -->
## Timeline (all times UTC)
- **14:12** — Deploy v2.34.1 completed
- **14:15** — Payment error rate alert fires (threshold: 5%)
- **14:17** — On-call engineer acknowledges page
- **14:20** — Incident declared as SEV1; war room opened
- **14:25** — Root cause identified: missing env var in v2.34.1
- **14:32** — Rollback to v2.34.0 initiated
- **14:38** — Rollback complete; error rate returning to baseline
- **14:45** — Error rate at 0.1%; incident downgraded to monitoring
- **15:00** — Incident resolved; total duration 48 minutes
```

### Postmortem Document Structure

| Section | Content |
| :--- | :--- |
| **Title** | Descriptive name including date |
| **Severity** | SEV level assigned during incident |
| **Duration** | Detection time to resolution time |
| **Impact** | Number of users affected, revenue impact, data loss |
| **Timeline** | Timestamped sequence of events |
| **Contributing factors** | Systemic causes (not individuals) |
| **What went well** | Things that worked during response |
| **What could be improved** | Process gaps identified |
| **Action items** | Each with owner, deadline, and tracking link |

### Action Item Tracking

Every action item must have three fields:

| Field | Requirement |
| :--- | :--- |
| **Description** | Specific, actionable task |
| **Owner** | Team or individual responsible |
| **Deadline** | Date by which the item must be completed |

Track action items in the team's issue tracker, not in the postmortem document alone. Review completion weekly until all items are closed.

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| :--- | :--- | :--- |
| **No severity classification** | Every incident gets the same (wrong) response level | Define and enforce SEV1-SEV4 levels |
| **Hero-driven resolution** | One person holds all context; single point of failure | Rotate on-call, write runbooks, pair during incidents |
| **Blame-heavy postmortems** | Engineers hide mistakes instead of surfacing them | Enforce blameless format; focus on systemic factors |
| **Runbooks in someone's head** | Knowledge leaves when the person does | Document all procedures; test runbooks quarterly |
| **No communication cadence** | Stakeholders flood responders with status requests | Publish updates on a fixed schedule per severity |
| **Skipping postmortems** | Same incidents recur; no systemic improvement | Require postmortems for SEV1/SEV2; track completion |
| **Action items with no owner** | Nothing gets done after the postmortem | Every action item needs owner + deadline |
| **Incident declared too late** | Blast radius grows while team debates severity | Declare early, downgrade later |

---

## Red Flags

| Signal | Action | Rationale |
| :--- | :--- | :--- |
| Same incident recurring 3+ times | Escalate to leadership; prioritize systemic fix | Repeat incidents indicate postmortem actions are not being completed |
| Postmortem with zero action items | Reject the postmortem; identify at least one improvement | Every incident has something to teach; zero actions means the team did not dig deep enough |
| Single-person on-call with no backup | Add secondary on-call and rotation immediately | One person cannot sustain 24/7 coverage without burnout and risk |
| No severity levels defined | Establish SEV1-SEV4 definitions before the next incident | Without severity, every incident gets ad hoc (usually wrong) response |
| Mean time to detect exceeds 30 minutes | Improve alerting coverage and thresholds | Users should not find your outages before your monitoring does |
| Postmortem older than 30 days with open action items | Review and either complete or explicitly deprioritize | Stale action items erode trust in the postmortem process |

---

## Checklist

- [ ] Severity levels (SEV1-SEV4) are defined and documented
- [ ] On-call rotation exists with primary and secondary coverage
- [ ] Escalation paths are documented for each severity level
- [ ] Status page or equivalent is configured for external communication
- [ ] Communication cadence is defined per severity level
- [ ] Runbooks exist for known failure modes and are tested quarterly
- [ ] Postmortem template enforces blameless format
- [ ] Postmortem is required for all SEV1 and SEV2 incidents
- [ ] Action items from postmortems are tracked in the issue tracker with owners and deadlines
- [ ] Incident response process is rehearsed at least annually via game days

---

## See Also

- [Deployment Strategies](../deployment-strategies/deployment-strategies.md) — Rollback procedures and safe deploys
- [Observability Patterns](../observability-patterns/observability-patterns.md) — Alerting, metrics, and tracing
- [Logging Practices](../logging-practices/logging-practices.md) — Structured logging during incidents
- [Resilience Patterns](../resilience-patterns/resilience-patterns.md) — Circuit breakers, retries, graceful degradation
- [Backup, Restore & DR](../backup-restore-dr/backup-restore-dr.md) — Recovery procedures and RPO/RTO readiness
