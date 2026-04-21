# AI Agent Evaluation & Metrics

Best practices for measuring whether AI-assisted workflows actually improve delivery quality, speed, safety, and cost.

> **Scope**: Covers evaluation of AI-assisted development workflows over time: baseline design, experiment design, quality and productivity metrics, review cadence, and guardrails. Applies to individual developers, teams, and internal platform programs adopting AI coding tools.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Metric Layers](#metric-layers) |
| [Baseline and Experiment Design](#baseline-and-experiment-design) |
| [Review Cadence](#review-cadence) |
| [Instrumentation Pattern](#instrumentation-pattern) |
| [Anti-Patterns](#anti-patterns) |
| [Red Flags](#red-flags) |
| [Checklist](#checklist) |
| [See Also](#see-also) |

---

## Quick Reference

| Area | Prefer | Avoid |
| --- | --- | --- |
| **Quality** | Escaped defects, rework rate, review findings | "Looks good" surveys only |
| **Speed** | Cycle time, time-to-first-draft, review turnaround | Raw lines changed per day |
| **Cost** | Cost per workflow, token spend per task, retry rate | Monthly total spend with no attribution |
| **Safety** | Security regressions, incident rate, rollback rate | Assuming faster = safer |
| **Adoption** | Active usage by workflow and team | Seat count or licenses purchased |

| Rule | Rationale |
| --- | --- |
| Measure workflows, not vibes | Subjective enthusiasm is useful context, not evidence |
| Keep a human baseline | You need a comparator to know if the tool helped |
| Use guardrails as well as targets | Faster output is not success if regressions rise |
| Review trends, not one-off wins | AI workflow quality is noisy week to week |
| Instrument at the task boundary | Evaluation is impossible when events are unstructured |

---

## Core Principles

1. **Evaluate outcomes, not output volume** — More code or more prompts do not prove better engineering.
2. **Baseline before rollout** — Measure the current workflow before introducing tooling changes.
3. **Pair every speed metric with a quality metric** — Faster delivery with more regressions is a failed experiment.
4. **Attribute spend and retries** — Cost and retry loops reveal whether the workflow is efficient or thrashing.
5. **Use review cadence, not dashboard worship** — Metrics need regular interpretation and follow-up action.

---

## Metric Layers

Measure the workflow at multiple layers so you can tell where gains or regressions originate.

| Layer | Example metrics | Source | Why it matters |
| --- | --- | --- | --- |
| **Task** | Time to first draft, retries per task, prompt count | IDE or workflow logs | Reveals immediate agent efficiency |
| **Change** | Review cycle time, comments per PR, rework commits | Git + code review system | Shows whether output survives peer review |
| **Quality** | Escaped defects, flaky tests introduced, rollback rate | Issue tracker, CI, incident logs | Protects against "fast but wrong" rollouts |
| **Cost** | Dollars per PR, tokens per workflow, expensive-model share | Provider usage + internal tags | Prevents hidden spend growth |
| **Adoption** | Weekly active users, workflows used, abandonment rate | Tool telemetry, surveys | Distinguishes curiosity from habit |

| Metric type | Good default | Poor substitute |
| --- | --- | --- |
| **Speed** | PR cycle time p50/p90 | Commits per developer |
| **Quality** | Escaped defects per 100 PRs | "Code quality score" with no definition |
| **Safety** | Security findings, rollback rate, incidents | Manual confidence rating only |
| **Cost** | Cost per workflow and per team | Total invoice without segmentation |
| **Satisfaction** | Structured survey with concrete prompts | Anecdotes from one loud adopter |

---

## Baseline and Experiment Design

Use lightweight experiments with explicit baselines and stop conditions.

| Step | Requirement | Why |
| --- | --- | --- |
| **Pick one workflow** | Example: code review, test generation, bug triage | Mixed workflows hide signal |
| **Capture a baseline window** | 2-4 weeks is usually enough | Shorter windows are too noisy |
| **Define guardrails** | Zero critical security regressions, no increase in incidents | Prevents harmful "wins" |
| **Choose a decision rule** | Example: improve cycle time 15% with flat defect rate | Makes the result actionable |
| **Review by cohort** | Team, repo, workflow, task type | One global average hides outliers |

**Bad: no comparator, no decision rule**

```yaml
experiment:
  workflow: "use AI for code review"
  result: "felt faster"
  owner: "eng"
```

**Good: baseline, guardrails, and exit criteria**

```yaml
experiment:
  workflow: "pull request review"
  baseline_window: "2026-03-01..2026-03-28"
  trial_window: "2026-04-01..2026-04-28"
  success_metrics:
    - review_cycle_time_p50
    - escaped_defects_per_100_prs
    - dollars_per_pr
  guardrails:
    - critical_security_regressions == 0
    - rollback_rate_change <= 0
  decision_rule: "Adopt if cycle time improves >= 15% and quality guardrails hold"
```

| Experiment shape | When to use | Trade-off |
| --- | --- | --- |
| **Before/after within one team** | Small rollout, limited tooling | Cheap, but sensitive to seasonality |
| **Team A vs Team B** | Similar teams and repos exist | Better comparator, harder coordination |
| **Workflow-level holdout** | One tool used for only one task class | Cleanest signal, requires discipline |

---

## Review Cadence

Use a regular review rhythm so metrics drive decisions instead of piling up.

| Cadence | Review focus | Owner |
| --- | --- | --- |
| **Weekly** | Retry spikes, cost spikes, major regressions | Team lead or pilot owner |
| **Bi-weekly** | Workflow adoption, friction points, policy exceptions | Team + maintainer |
| **Monthly** | Baseline comparison, keep/kill decisions, tooling changes | Engineering manager or platform owner |
| **Quarterly** | Portfolio view across teams and workflows | Org or platform leadership |

| Trigger | Action |
| --- | --- |
| Guardrail breached | Pause or narrow the workflow immediately |
| Speed improves but quality drops | Keep experiment open; fix prompt/process before expansion |
| Cost grows with flat outcomes | Downgrade model, tighten context, or stop the workflow |
| Adoption drops after week 1 | Interview users before declaring success or failure |

---

## Instrumentation Pattern

Capture structured events at task boundaries so analysis is mechanical, not manual.

**Bad: unstructured success note**

```json
{
  "message": "AI helped with review",
  "status": "ok"
}
```

**Good: structured workflow event with quality and cost hooks**

```json
{
  "workflow": "code_review",
  "repo": "payments-api",
  "team": "backend",
  "task_id": "pr-1842",
  "model_tier": "sonnet",
  "attempt_count": 2,
  "input_tokens": 8432,
  "output_tokens": 1211,
  "estimated_cost_usd": 0.09,
  "time_to_first_draft_seconds": 47,
  "accepted_without_rewrite": false,
  "review_findings_count": 3,
  "security_regression": false
}
```

| Field | Required? | Why |
| --- | --- | --- |
| `workflow` | Yes | Segments usage by task type |
| `repo` / `team` | Yes | Enables cohort comparison |
| `model_tier` | Yes | Explains cost and quality differences |
| `attempt_count` | Yes | Reveals thrash and prompt churn |
| `cost or token usage` | Yes | Required for budget analysis |
| `quality outcome` | Yes | Needed to avoid speed-only dashboards |

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| --- | --- | --- |
| **Vanity dashboards** | Usage counts rise while code quality worsens | Pair adoption with outcome metrics |
| **One metric to rule them all** | Single scores hide trade-offs | Track speed, quality, cost, and safety separately |
| **No baseline** | Improvement claims cannot be defended | Measure the manual workflow first |
| **Survey-only evaluation** | Sentiment drifts with novelty | Combine perception with operational data |
| **No cost attribution** | Expensive workflows remain invisible | Tag requests by team, repo, and workflow |

---

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| A rollout report says "productivity improved" with no comparator | Reject the claim until a baseline is added | Improvement without baseline is storytelling |
| Speed metrics improve while rollback or defect rate rises | Treat the rollout as failing | Fast regressions are still regressions |
| Spend is tracked only at org level | Add team and workflow tags before scaling usage | You cannot optimize what you cannot segment |
| Review cadence slips for multiple weeks | Schedule a metrics review before expanding use | Unreviewed dashboards become decoration |
| Teams optimize for accepted suggestions instead of shipped outcomes | Re-anchor metrics around workflow results | Acceptance rate is not the product outcome |

---

## Checklist

- [ ] Every AI workflow has a named baseline and owner
- [ ] Speed metrics are paired with quality and safety guardrails
- [ ] Cost is attributed by workflow, repo, and team
- [ ] Review cadence is scheduled and documented
- [ ] Expansion decisions have explicit keep/kill criteria
- [ ] Structured events capture retries and task outcomes

---

## See Also

- [Cost & Token Management](../cost-token-management/cost-token-management.md) — Measuring spend per workflow
- [Testing AI-Generated Code](../testing-ai-code/testing-ai-code.md) — Verifying output quality
- [Observability Patterns](../observability-patterns/observability-patterns.md) — Metrics, dashboards, and alerting
- [Team AI Coordination](../team-ai-coordination/team-ai-coordination.md) — Team-level rollout and review policy
