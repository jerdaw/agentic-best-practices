---
name: cost-management
description: Use when controlling AI spend, token budgets, model routing, or workflow efficiency before scaling usage
---

# Cost Management

**Announce at start:** "Following the cost-management skill — budget before build."

## Core Rule

**Every AI workflow needs a budget and attribution.** Cost you cannot segment or cap will eventually surprise you.

## Process

### 1. Identify the Workflow

Define what is being measured:

- [ ] Workflow name (`code_review`, `test_generation`, `incident_triage`, etc.)
- [ ] Team or owner
- [ ] Environment (`dev`, `ci`, `staging`, `prod`)
- [ ] Expected frequency

### 2. Set a Budget Before Use

Choose a default cap before requests start flowing:

| Budget scope | Example |
| --- | --- |
| Per task | `$0.25 per PR review` |
| Per user | `$100/month per developer` |
| Per team | `$2,000/month for CI workflows` |
| Per environment | Stricter caps in development than production |

### 3. Right-Size the Model

Route by task complexity, not habit:

| Task | Default tier |
| --- | --- |
| Formatting or classification | Cheapest capable model |
| Code review or test generation | Mid-tier reasoning model |
| High-risk architecture or security analysis | Highest tier only when justified |

### 4. Reduce Token Waste

Before spending more, shrink the context:

- Send only relevant files or functions
- Use diffs instead of full before/after files when possible
- Cap output tokens to the needed response length
- Summarize long history instead of replaying all of it
- Fix retry loops before upgrading model tier

### 5. Instrument Spend

Every request should carry attribution and outcome data:

- [ ] Team
- [ ] Workflow
- [ ] Environment
- [ ] Model tier
- [ ] Token or cost usage
- [ ] Retry count

### 6. Review and Adjust

Use review cadence, not only invoices:

- [ ] Watch for high-cost workflows with weak outcomes
- [ ] Downgrade models if quality is unchanged
- [ ] Add alerts at budget thresholds
- [ ] Stop or redesign workflows that thrash

## Red Flags — STOP

| Signal | Action |
| --- | --- |
| Most expensive model is the default for all tasks | Add explicit routing rules |
| No request tags for team/workflow/env | Add attribution before scaling usage |
| Full repositories sent for tiny tasks | Trim context and re-measure |
| Cost review happens only after the invoice arrives | Add pre-flight caps and threshold alerts |
| Same workflow retries many times with flat quality | Fix prompts/process before spending more |

## Verification Checklist

- [ ] Workflow owner and budget were defined
- [ ] Model tier matches task complexity
- [ ] Context was trimmed to the minimum useful scope
- [ ] Requests are tagged with team, workflow, and environment
- [ ] Alerts or review cadence exist for ongoing spend

## Related Skills

| When | Invoke |
| --- | --- |
| Need better prompts to reduce retries | [prompting](../prompting/SKILL.md) |
| Designing specialized agents with bounded scope | [refactoring](../refactoring/SKILL.md) or [planning](../planning/SKILL.md) |
| Keeping spend policy reflected in docs | [doc-maintenance](../doc-maintenance/SKILL.md) |

## Deep Reference

For principles, rationale, anti-patterns, and examples:

- `guides/cost-token-management/cost-token-management.md`
- `guides/ai-agent-evaluation-metrics/ai-agent-evaluation-metrics.md`
- `guides/context-management/context-management.md`
