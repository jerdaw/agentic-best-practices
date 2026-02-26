# Cost & Token Management

Best practices for controlling AI API costs — token budgets, model selection trade-offs, context window optimization, and spend alerting.

> **Scope**: Covers the economics of AI-assisted development: API cost tracking, token budget enforcement, model selection for
> cost-effectiveness, and organizational spend governance. Applies to any team using LLM APIs in development or production.

## Contents

| Section |
| :--- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Token Budget Design](#token-budget-design) |
| [Model Selection](#model-selection) |
| [Context Window Optimization](#context-window-optimization) |
| [Cost Monitoring and Alerting](#cost-monitoring-and-alerting) |
| [Batch vs Streaming](#batch-vs-streaming) |
| [Anti-Patterns](#anti-patterns) |
| [Red Flags](#red-flags) |
| [Checklist](#checklist) |
| [See Also](#see-also) |

---

## Quick Reference

**Cost control summary**:

| Rule | Detail |
| :--- | :--- |
| **Budget before build** | Set a dollar cap before writing the first prompt |
| **Right-size the model** | Use the cheapest model that meets quality needs |
| **Alert at 70%** | Catch runaway spend early, not after the budget is gone |
| **Attribute every call** | Tag requests by team, task, and environment |
| **Measure per-task cost** | Track cost-per-code-review, cost-per-refactor, not just totals |

**Key numbers**:

- Haiku-class models: ~$0.80/M input, $4/M output
- Sonnet-class models: ~$3/M input, $15/M output
- Opus-class models: ~$15/M input, $75/M output
- 1 token ~ 0.75 English words; 1,000 lines of code ~ 10K-15K tokens

---

## Core Principles

1. **Budget before build** — Set cost limits before starting any AI-powered workflow. A missing budget is an unlimited budget.
2. **Right-size the model** — Use the cheapest model that meets quality needs. Formatting tasks do not need frontier reasoning.
3. **Measure per-task cost** — Attribute spend to specific workflows so you know where the money goes and where to optimize.
4. **Context efficiency = cost efficiency** — Fewer tokens in the prompt means lower bills. Strip what the model does not need.
5. **Alert early** — Catch runaway spend at 70% of budget, not 100%. By the time you hit the ceiling, the damage is done.

---

## Token Budget Design

### Per-Task Budgets

Estimate token usage per task type and set soft caps.

| Task | Typical Input | Typical Output | Total Budget | Notes |
| :--- | :--- | :--- | :--- | :--- |
| Code review (single file) | ~3K tokens | ~1K tokens | ~4K tokens | File + diff + instructions |
| Code review (PR) | ~10K tokens | ~3K tokens | ~13K tokens | Multiple files, summaries |
| Simple refactor | ~8K tokens | ~12K tokens | ~20K tokens | Source + rewrite |
| Bug diagnosis | ~6K tokens | ~2K tokens | ~8K tokens | Logs + stack trace + code |
| Architecture analysis | ~15K tokens | ~5K tokens | ~20K tokens | Multi-file context |
| Documentation generation | ~5K tokens | ~3K tokens | ~8K tokens | Source + template |
| Test generation | ~6K tokens | ~8K tokens | ~14K tokens | Source + existing tests |

### Organizational Tiers

Set budget tiers by environment to prevent development experimentation from blowing production budgets.

| Tier | Monthly Cap | Rate Limit | Approval Required |
| :--- | :--- | :--- | :--- |
| **Development** | $500/developer | 100 req/hour | Self-service |
| **CI/CD** | $2,000/pipeline | 200 req/hour | Team lead |
| **Staging** | $1,000/environment | 150 req/hour | Team lead |
| **Production** | $10,000/service | 500 req/hour | Engineering manager |

### Budget Enforcement

Enforce budgets at the call site, not just in dashboards.

```typescript
// Bad: no budget check — relies on post-hoc invoice review
async function reviewCode(diff: string): Promise<string> {
  const response = await client.messages.create({
    model: "claude-sonnet-4-6",
    max_tokens: 4096,
    messages: [{ role: "user", content: `Review this diff:\n${diff}` }],
  })
  return response.content[0].text
}
```

```typescript
// Good: pre-flight budget check prevents overspend
async function reviewCode(diff: string): Promise<string> {
  const estimatedTokens = estimateTokens(diff) + 1000 // input + expected output
  const budget = await getBudget("ci", "code-review")

  if (budget.remaining < estimateCost(estimatedTokens, "claude-sonnet-4-6")) {
    throw new BudgetExceededError(
      `Code review budget exhausted. Remaining: $${budget.remaining.toFixed(2)}`
    )
  }

  const response = await client.messages.create({
    model: "claude-sonnet-4-6",
    max_tokens: 1024, // constrain output to what code review actually needs
    messages: [{ role: "user", content: `Review this diff:\n${diff}` }],
  })

  await recordSpend("ci", "code-review", response.usage)
  return response.content[0].text
}
```

---

## Model Selection

### Cost vs Capability Matrix

| Model Tier | Cost (Input/Output per M) | Strengths | Weaknesses |
| :--- | :--- | :--- | :--- |
| **Haiku-class** | ~$0.80 / $4 | Fast, cheap, simple tasks | Weak on multi-step reasoning |
| **Sonnet-class** | ~$3 / $15 | Balanced cost/quality, good reasoning | Overkill for trivial tasks |
| **Opus-class** | ~$15 / $75 | Best reasoning, complex analysis | 5-20x costlier than Haiku |

### Routing Strategies

Route tasks to the cheapest model that produces acceptable quality.

| Task Type | Recommended Tier | Rationale |
| :--- | :--- | :--- |
| Formatting, linting fixes | Haiku | Deterministic transforms, no reasoning needed |
| Commit message generation | Haiku | Short output, structured format |
| Code review | Sonnet | Needs reasoning about correctness |
| Bug diagnosis | Sonnet | Requires multi-step analysis |
| Test generation | Sonnet | Must understand edge cases |
| Architecture decisions | Opus | Complex trade-off analysis |
| Security audit | Opus | Subtle vulnerability detection |

### When to Downgrade

| Signal | Action |
| :--- | :--- |
| Task has deterministic output (JSON conversion, reformatting) | Use Haiku |
| Output quality is the same across tiers (measured, not assumed) | Drop to cheaper tier |
| Latency matters more than depth | Use Haiku for speed |
| Budget is nearly exhausted | Downgrade non-critical tasks first |

```typescript
// Bad: using the most expensive model for everything
const response = await anthropic.messages.create({
  model: "claude-opus-4-6",  // $15/M input tokens for a simple formatting task
  messages: [{ role: "user", content: "Convert this list to JSON" }],
})
```

```typescript
// Good: routing by task complexity
type TaskType = "formatting" | "code_review" | "architecture"

function selectModel(task: TaskType): string {
  const routing: Record<TaskType, string> = {
    formatting: "claude-haiku-4-5-20251001",   // $0.80/M — simple transforms
    code_review: "claude-sonnet-4-6",           // $3/M — reasoning needed
    architecture: "claude-opus-4-6",            // $15/M — complex analysis
  }
  return routing[task]
}

const response = await anthropic.messages.create({
  model: selectModel("formatting"),
  messages: [{ role: "user", content: "Convert this list to JSON" }],
})
```

---

## Context Window Optimization

### Token-Efficient Patterns

| Technique | Token Savings | Trade-off |
| :--- | :--- | :--- |
| Send only relevant functions, not full files | 60-90% | Requires extraction logic |
| Use diffs instead of full before/after files | 50-80% | Less surrounding context |
| Summarize long conversation history | 40-70% | Loses some detail |
| Strip comments and docstrings from context | 10-30% | Model loses documentation cues |
| Use structured references instead of inlining | 30-50% | Model must infer structure |
| Compress repeated patterns into templates | 20-40% | Slightly harder to parse |

### Chunking vs Full-Context

| Strategy | When to Use | Cost Impact |
| :--- | :--- | :--- |
| **Full file** | File is < 200 lines and all relevant | Acceptable |
| **Function extraction** | Need one function from a large file | 60-90% savings |
| **Sliding window** | Processing a long document sequentially | Predictable per-chunk cost |
| **Map-reduce** | Summarizing many files | Higher total but parallelizable |
| **RAG retrieval** | Large codebase, need specific context | Only pay for retrieved chunks |

```python
# Bad: sending entire file as context (2,400 tokens wasted)
with open("models/user.py") as f:
    context = f.read()  # 500-line file, only need 1 function

prompt = f"Review this code:\n{context}"
```

```python
# Good: extracting only relevant code (200 tokens)
import ast

source = open("models/user.py").read()
tree = ast.parse(source)
func = next(
    n for n in ast.walk(tree)
    if isinstance(n, ast.FunctionDef) and n.name == "validate_email"
)
context = ast.get_source_segment(source, func)

prompt = f"Review this function:\n{context}"
```

### Response Caching

Cache responses for deterministic or near-deterministic prompts. Identical inputs should not be billed twice.

| Cache Strategy | Use Case | TTL |
| :--- | :--- | :--- |
| Exact-match prompt cache | Deterministic transforms (format, convert) | 24 hours |
| Content-hash cache | Same code content, different file paths | 1 hour |
| Prompt prefix caching | Shared system prompt across requests | Session lifetime |
| Semantic cache | Similar (not identical) questions | 30 minutes |

---

## Cost Monitoring and Alerting

### Tracking by Team and Task

Tag every API call with metadata for attribution. Without tags, you cannot optimize.

```python
# Bad: no attribution — impossible to track who or what spent the budget
response = client.messages.create(
    model="claude-sonnet-4-6",
    messages=[{"role": "user", "content": prompt}],
)
```

```python
# Good: tagged request with team, task, and environment metadata
response = client.messages.create(
    model="claude-sonnet-4-6",
    messages=[{"role": "user", "content": prompt}],
    metadata={"user_id": "team-backend-ci"},
)

# Log cost attribution separately
log_usage(
    team="backend",
    task="code-review",
    environment="ci",
    input_tokens=response.usage.input_tokens,
    output_tokens=response.usage.output_tokens,
    model=response.model,
    estimated_cost=calculate_cost(response),
)
```

### Alert Thresholds

| Threshold | Action | Notification Target |
| :--- | :--- | :--- |
| **50% of budget** | Informational alert; review spend trends | Team Slack channel |
| **70% of budget** | Warning; review top-spending workflows | Team lead + on-call |
| **90% of budget** | Critical; downgrade non-essential tasks to cheaper models | Engineering manager |
| **100% of budget** | Hard stop or emergency approval required | VP Engineering |

### Dashboards

Track spend at multiple granularities. Aggregate-only dashboards hide the workflows that matter.

| Metric | Granularity | Purpose |
| :--- | :--- | :--- |
| Total spend | Daily / weekly / monthly | Budget tracking |
| Spend per team | Weekly | Accountability |
| Spend per task type | Daily | Optimization targeting |
| Spend per model | Daily | Model routing effectiveness |
| Cost per unit of work | Per-PR, per-deploy | Efficiency benchmarking |
| Token waste ratio | Weekly | Context optimization signal |

---

## Batch vs Streaming

### When to Batch

| Scenario | Batch | Stream | Rationale |
| :--- | :--- | :--- | :--- |
| CI pipeline code review | Yes | No | No human waiting; batch is cheaper |
| Interactive chat | No | Yes | User expects progressive output |
| Bulk test generation | Yes | No | Throughput > latency |
| Documentation generation | Yes | No | Output consumed after completion |
| Live coding assistant | No | Yes | Real-time feedback needed |
| Nightly codebase audit | Yes | No | Scheduled, no urgency |

### Streaming Cost Implications

| Factor | Batch | Streaming |
| :--- | :--- | :--- |
| Token cost | Same | Same (tokens are tokens) |
| API overhead | Lower (one request) | Higher (connection held open) |
| Batch API discount | Up to 50% off (provider-dependent) | Not available |
| Abort savings | None (full response generated) | Can abort early if output is wrong |
| Timeout risk | Higher for long outputs | Lower (progressive delivery) |

Use batch APIs when available. Many providers offer 50% discounts for asynchronous batch endpoints where latency is not a constraint.

### Batch Cost Example

```text
Nightly code review of 50 PRs, ~10K tokens each:

Streaming (real-time):  50 x 10K tokens x $3/M  = $1.50
Batch API (async):      50 x 10K tokens x $1.50/M = $0.75

Annual savings from batch alone: ~$275 on one workflow
```

Scale this across all non-interactive workflows for significant savings.

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| :--- | :--- | :--- |
| **Unlimited API keys** | No spend ceiling; one bug can drain the account | Set per-key spend limits and rate caps |
| **Always biggest model** | 5-20x overspend on simple tasks | Route by task complexity |
| **Full-file context** | Paying for thousands of irrelevant tokens | Extract only the code the model needs |
| **No cost attribution** | Cannot identify what is expensive | Tag every request with team, task, env |
| **Retry without backoff** | Multiplies cost on failures | Exponential backoff; cap retries at 3 |
| **Ignoring output tokens** | Output tokens cost 3-5x more than input | Constrain output length where possible |
| **Prompt stuffing** | Cramming "just in case" context | Measure whether extra context improves quality |
| **No caching** | Identical prompts re-sent and re-billed | Cache responses for deterministic inputs |

---

## Red Flags

| Signal | Action | Rationale |
| :--- | :--- | :--- |
| Spend growing 20%+ week-over-week without new use cases | Audit top-spending workflows immediately | Indicates waste or uncontrolled adoption |
| Single workflow consuming > 50% of total spend | Optimize or downgrade that workflow | Concentration risk; one bug bankrupts budget |
| No alerts configured on any budget tier | Add 50/70/90% thresholds today | You will not notice runaway spend until the invoice arrives |
| Context regularly hitting model max window | Chunk or summarize; investigate why full context is needed | Max-context calls are the most expensive possible |
| Output token count consistently > input token count | Review whether the model is being too verbose | Output tokens cost 3-5x more; constrain when possible |
| Development environment spend exceeds production | Investigate; dev should cost less than prod | Likely uncontrolled experimentation or missing rate limits |

---

## Checklist

- [ ] Budget caps set for every environment (dev, CI, staging, prod)
- [ ] API keys have per-key spend limits and rate caps
- [ ] Task-to-model routing implemented (not everything on the most expensive model)
- [ ] Every API call tagged with team, task type, and environment
- [ ] Alert thresholds configured at 50%, 70%, and 90% of budget
- [ ] Context sent to models is minimized (no full-file dumps for single-function tasks)
- [ ] Batch API used for non-interactive workloads where provider offers discounts
- [ ] Cost dashboard tracks spend per team, per task, and per model
- [ ] Output token limits set where maximum response length is known
- [ ] Monthly cost review scheduled with spend-by-workflow breakdown

---

## See Also

- [Context Management](../context-management/context-management.md) — Managing what context reaches the model
- [Prompting Patterns](../prompting-patterns/prompting-patterns.md) — Writing efficient, effective prompts
- [Custom Agents](../custom-agents/custom-agents.md) — Specialized agents with scoped capabilities
- [Tool Configuration](../tool-configuration/tool-configuration.md) — Configuring AI tool settings and limits
- [Observability Patterns](../observability-patterns/observability-patterns.md) — Metrics, tracing, and dashboards
