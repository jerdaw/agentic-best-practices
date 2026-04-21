---
name: performance
description: Use when investigating latency, throughput, resource saturation, or performance regressions before changing implementation details
---

# Performance

**Announce at start:** "Following the performance skill — measure before optimizing."

## Core Rule

**No optimization without measurement.** Pick the bottleneck based on evidence, not intuition.

## Process

### 1. Define the Symptom

Start with a concrete performance problem:

- [ ] Which metric is bad: latency, throughput, CPU, memory, I/O, query time?
- [ ] What is the target or SLO?
- [ ] Which path, endpoint, job, or query is affected?
- [ ] Is the issue new, recurring, or load-dependent?

### 2. Capture a Baseline

Record current behavior before changing code:

- [ ] Representative benchmark or load test
- [ ] Relevant production or staging metrics
- [ ] Current percentile numbers (`p50`, `p95`, `p99`) where relevant
- [ ] Environment details and dataset size

### 3. Profile and Isolate

Use the right tool for the suspected bottleneck:

| Suspected bottleneck | First tool |
| --- | --- |
| CPU-bound code | Profiler or flame graph |
| Slow DB path | Query plan and slow query log |
| I/O wait | Trace spans and dependency timings |
| Memory growth | Heap snapshot / allocation profile |
| End-to-end path | Load test plus tracing |

### 4. Choose the Highest-Leverage Fix

Change the hottest confirmed bottleneck first:

- Remove unnecessary work before parallelizing it
- Fix query shape before adding more hardware
- Reduce data moved before adding caches
- Prefer reversible changes with clear rollback paths

### 5. Re-Measure

After each change:

- [ ] Re-run the same benchmark or test
- [ ] Compare to the baseline with the same dataset
- [ ] Check for regressions in adjacent metrics
- [ ] Confirm the change improves the original bottleneck

### 6. Roll Out Carefully

If the improvement is worth keeping:

- [ ] Document the before/after measurement
- [ ] Add a regression check if practical
- [ ] Monitor after release for real workload confirmation

## Red Flags — STOP

| Signal | Action |
| --- | --- |
| "This code looks slow" with no measurement | Establish a baseline first |
| Microbenchmark used to justify system-wide change | Re-test with representative workload |
| Query or cache change improves one metric but hurts another | Re-evaluate end-to-end outcome |
| Proposed optimization adds major complexity for small gain | Compare maintenance cost to measured benefit |
| Same benchmark not used before and after | Results are not comparable |

## Verification Checklist

- [ ] The performance symptom and target were explicit
- [ ] A baseline was captured before changes
- [ ] The chosen optimization matched the measured bottleneck
- [ ] Before/after results were collected with the same method
- [ ] Adjacent regressions were checked

## Related Skills

| When | Invoke |
| --- | --- |
| Need root-cause diagnosis before tuning | [debugging](../debugging/SKILL.md) |
| Need tests or regression guards | [testing](../testing/SKILL.md) |
| Releasing a risky optimization | [deployment](../deployment/SKILL.md) |
| Need better metrics or tracing first | [logging](../logging/SKILL.md) |

## Deep Reference

For principles, rationale, anti-patterns, and examples:

- `guides/performance-engineering/performance-engineering.md`
- `guides/observability-patterns/observability-patterns.md`
- `guides/database-indexing/database-indexing.md`
