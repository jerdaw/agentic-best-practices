# Performance Engineering

Best practices for profiling, load testing, benchmarking, and capacity planning — systematic performance work rather than ad hoc optimization.

> **Scope**: Covers performance engineering as a discipline: profiling, load/stress testing, benchmarking, optimization patterns, and capacity planning. Applies to backend services, APIs, and data-intensive systems.

## Contents

| Section |
| :--- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Profiling](#profiling) |
| [Load and Stress Testing](#load-and-stress-testing) |
| [Benchmarking](#benchmarking) |
| [Optimization Patterns](#optimization-patterns) |
| [Capacity Planning](#capacity-planning) |
| [Performance in CI](#performance-in-ci) |
| [Anti-Patterns](#anti-patterns) |
| [Red Flags](#red-flags) |
| [Checklist](#checklist) |
| [See Also](#see-also) |

---

## Quick Reference

**Performance discipline summary**:

| Activity | Purpose | Cadence |
| :--- | :--- | :--- |
| **Profiling** | Find where time is spent | On-demand, when latency degrades |
| **Load testing** | Validate throughput under expected traffic | Every release or infra change |
| **Stress testing** | Find breaking points | Quarterly or before major launches |
| **Benchmarking** | Track performance over time | Per commit in CI |
| **Capacity planning** | Forecast resource needs | Monthly or before growth events |

**Key rules**:

- Measure before optimizing — gut feeling is not data
- Benchmarks must be reproducible — same inputs, same environment
- Set budgets, not aspirations — define latency/throughput targets per endpoint

---

## Core Principles

1. **Measure before optimize** — Gut feeling is not data. Profile first, fix what the numbers show.
2. **Reproducible benchmarks** — Same inputs, same environment must yield comparable results. Document the setup.
3. **Performance is a feature** — Budget it like any other requirement. A p99 latency target is as real as a feature spec.
4. **Realistic conditions** — Test with production-like data volumes, concurrency levels, and access patterns.
5. **Set budgets** — Define latency and throughput targets per endpoint. Without a budget, you cannot detect a regression.

---

## Profiling

### When to Profile

| Situation | Action |
| :--- | :--- |
| p99 latency increased after deploy | Profile the affected endpoint |
| User reports slow page | Profile the backend handler |
| CPU or memory spike in monitoring | Profile the service under load |
| Before optimizing anything | Profile to confirm the bottleneck |
| Periodic health check | Profile hot paths quarterly |

Do not profile in response to hunches. Profile in response to data from monitoring or user reports.

### Tools by Language

| Language | Profiler | Type | Notes |
| :--- | :--- | :--- | :--- |
| Python | `py-spy` | Sampling | Low overhead, attaches to running process |
| Python | `cProfile` | Deterministic | Built-in, higher overhead |
| Node.js | `clinic` | Sampling + flamegraph | Comprehensive suite (doctor, flame, bubbleprof) |
| Node.js | `0x` | Flamegraph | Lightweight, good for quick analysis |
| Go | `pprof` | Sampling | Built into runtime, CPU + memory + goroutine |
| Java | JFR (Flight Recorder) | Sampling | Low overhead, production-safe |
| Java | `async-profiler` | Sampling | Captures native frames + JIT-compiled code |

### Interpreting Profiles

| Pattern | Indicates | Action |
| :--- | :--- | :--- |
| Single function dominates flamegraph | Hot spot | Optimize or cache that function |
| Wide flat flamegraph | No single bottleneck | Look for I/O waits or lock contention |
| Deep call stacks with repeated frames | Excessive recursion or abstraction layers | Simplify call chain |
| High GC time | Memory allocation pressure | Reduce allocations, pool objects |
| Lock contention visible | Thread starvation | Reduce critical section scope, use lock-free structures |

---

## Load and Stress Testing

### Load Test Design

```python
# Bad: unrealistic load test
from locust import HttpUser, task

class MyUser(HttpUser):
    @task
    def test(self):
        self.client.get("/api/users/1")  # single user, no variation
```

```python
# Good: realistic load test
from locust import HttpUser, task, between
import random

REAL_QUERIES = ["laptop", "headphones", "monitor", "keyboard", "webcam"]

class RealisticUser(HttpUser):
    wait_time = between(1, 5)

    @task(3)
    def browse(self):
        user_id = random.randint(1, 100_000)
        self.client.get(f"/api/users/{user_id}")

    @task(1)
    def search(self):
        self.client.get("/api/search", params={"q": random.choice(REAL_QUERIES)})
```

Realistic tests use varied inputs, weighted task distributions, and think-time between requests. A test that hammers a single endpoint with a single ID tells you nothing about production behavior.

### Stress vs Load

| Dimension | Load Testing | Stress Testing |
| :--- | :--- | :--- |
| **Goal** | Validate behavior at expected traffic | Find the breaking point |
| **Traffic level** | Normal to peak expected | Beyond expected capacity |
| **Duration** | Sustained (minutes to hours) | Ramp until failure |
| **Success criteria** | Latency and error rate within budget | System degrades gracefully, recovers after load drops |
| **Frequency** | Every release | Quarterly or pre-launch |
| **Outcome** | "We can handle 2,000 RPS at p99 < 200ms" | "At 5,000 RPS the database connection pool saturates" |

---

## Benchmarking

### Microbenchmark Pitfalls

| Pitfall | Problem | Mitigation |
| :--- | :--- | :--- |
| JIT warmup | First runs are slower due to compilation | Run warmup iterations before measuring |
| Dead code elimination | Compiler removes code with unused results | Consume the result (assign, return, or assert) |
| GC pauses | Garbage collection injects latency spikes | Report percentiles, not just mean; run GC before benchmark |
| CPU frequency scaling | Turbo boost skews short benchmarks | Pin CPU frequency or use long enough runs |
| Shared environment | Other processes compete for resources | Isolate benchmark runs, use dedicated CI runners |

### Reproducible Benchmarks

| Requirement | Rationale |
| :--- | :--- |
| Fixed dataset | Results are meaningless if inputs change between runs |
| Pinned dependencies | Library updates can shift performance |
| Documented hardware / VM spec | "My laptop" is not a benchmark environment |
| Warmup phase excluded from measurement | Cold start is not steady-state |
| Multiple iterations with statistical summary | A single run is noise, not signal |
| Version-controlled benchmark code | If the benchmark changes, you cannot compare results |

---

## Optimization Patterns

### Measure First

```typescript
// Bad: optimizing without measurement
function getUsers() {
  // "This must be slow, let's add caching"
  return cache.getOrSet("users", () => db.query("SELECT * FROM users"), 3600)
}
```

```typescript
// Good: profile-driven optimization
// Profile showed: getUsers p99 = 340ms, 80% time in JSON serialization
// Fix: return only needed fields instead of SELECT *
function getUsers(fields: string[]) {
  const cols = fields.join(", ")
  return db.query(`SELECT ${cols} FROM users WHERE active = true`)
}
```

The bad example adds caching based on a hunch. The good example profiles first, identifies serialization as the bottleneck, and fixes the root cause.

### N+1 Query Elimination

```python
# Bad: N+1 — one query per order to fetch the customer
def get_orders_with_customers(order_ids: list[int]):
    orders = db.query("SELECT * FROM orders WHERE id IN %s", (tuple(order_ids),))
    for order in orders:
        order["customer"] = db.query(
            "SELECT * FROM customers WHERE id = %s", (order["customer_id"],)
        )  # executes len(orders) times
    return orders
```

```python
# Good: batch fetch with a single JOIN
def get_orders_with_customers(order_ids: list[int]):
    return db.query("""
        SELECT o.*, c.name AS customer_name, c.email AS customer_email
        FROM orders o
        JOIN customers c ON c.id = o.customer_id
        WHERE o.id IN %s
    """, (tuple(order_ids),))  # single query regardless of list size
```

### Common Targets

| Target | Symptom | Fix |
| :--- | :--- | :--- |
| N+1 queries | Linear DB calls as list grows | Batch fetch or JOIN |
| Missing indexes | Full table scans on filtered queries | Add indexes matching WHERE/ORDER BY |
| Over-fetching (SELECT *) | Serializing unused columns | Select only needed fields |
| Connection pool exhaustion | Requests queue waiting for connections | Right-size pool, add connection timeout |
| Unbounded result sets | Memory spikes on large tables | Paginate with LIMIT/OFFSET or cursor |
| Synchronous I/O on hot path | Thread blocked during network call | Make async or offload to background |
| Excessive logging in hot loop | I/O per iteration | Log summary after loop, or sample |
| Large JSON serialization | CPU-bound on response encoding | Use streaming serialization or binary format |

---

## Capacity Planning

### Forecasting Growth

| Step | Activity | Output |
| :--- | :--- | :--- |
| 1. Baseline | Measure current resource usage at current traffic | CPU, memory, I/O, connection counts |
| 2. Growth model | Estimate traffic growth from business projections | Requests/sec over next 3-6 months |
| 3. Scaling factor | Map traffic growth to resource growth | "2x traffic = 1.8x CPU, 2.5x memory" |
| 4. Headroom | Add safety margin (20-30% above projected peak) | Target resource allocation |
| 5. Trigger points | Define thresholds that trigger scaling action | "Scale when avg CPU > 70% for 5 min" |
| 6. Review cycle | Re-evaluate forecasts monthly | Updated projections vs actuals |

### Resource Budgets

Define a latency budget per endpoint, not a single global target.

| Endpoint | p50 Budget | p99 Budget | Throughput Target |
| :--- | :--- | :--- | :--- |
| `GET /api/users/:id` | 20ms | 100ms | 5,000 RPS |
| `GET /api/search` | 80ms | 300ms | 1,000 RPS |
| `POST /api/orders` | 50ms | 200ms | 500 RPS |
| `GET /api/feed` | 100ms | 500ms | 2,000 RPS |

These budgets become acceptance criteria. A deploy that violates a budget is a regression, same as a broken test.

### Scaling Indicators

| Indicator | Meaning | Response |
| :--- | :--- | :--- |
| CPU sustained > 70% | Compute-bound | Scale horizontally or optimize hot paths |
| Memory growing linearly | Likely a leak or unbounded cache | Profile allocations, add eviction |
| Connection pool wait time increasing | Pool too small or queries too slow | Increase pool size or optimize query latency |
| Disk I/O wait > 20% | Storage-bound | Add read replicas, caching layer, or faster storage |
| Request queue depth growing | Throughput ceiling reached | Scale out, shed low-priority traffic |

---

## Performance in CI

### Regression Detection

```python
# Bad: no performance gate in CI
def test_search():
    response = client.get("/api/search?q=test")
    assert response.status_code == 200
    # No latency assertion — regressions ship silently
```

```python
# Good: performance assertion in CI
import time

def test_search_performance():
    start = time.monotonic()
    response = client.get("/api/search?q=test")
    elapsed_ms = (time.monotonic() - start) * 1000

    assert response.status_code == 200
    assert elapsed_ms < 300, f"Search p99 budget is 300ms, got {elapsed_ms:.0f}ms"
```

For robust regression detection, run dedicated benchmark suites (not unit tests with timers) on consistent hardware and compare against stored baselines.

| CI Integration Pattern | How It Works | Trade-off |
| :--- | :--- | :--- |
| Inline latency assertions | Assert p99 < threshold in test suite | Simple but environment-sensitive |
| Benchmark suite with baseline comparison | Run benchmark, compare to stored baseline, flag > N% regression | Reliable but needs dedicated runner |
| Separate perf pipeline | Nightly or per-merge perf suite on isolated hardware | Most accurate but slower feedback loop |
| Canary analysis | Deploy to subset, compare metrics to control | Production-grade but complex setup |

### Threshold Configuration

| Practice | Rationale |
| :--- | :--- |
| Store thresholds in version control | Thresholds are code, not config drift |
| Use relative thresholds (< 10% regression) | Absolute numbers vary by environment |
| Allow manual override with justification | Some regressions are intentional trade-offs |
| Alert on threshold breach, don't auto-block | Flaky perf tests erode trust if they block deploys |
| Review thresholds quarterly | Baselines shift as features grow |

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| :--- | :--- | :--- |
| **Premature optimization** | Wasted effort on non-bottlenecks | Profile first, optimize what matters |
| **Benchmarking in dev environment** | Results don't reflect production | Use dedicated, consistent benchmark infra |
| **Unrealistic test data** | Misses production pathologies (skewed distributions, large payloads) | Use anonymized production data or realistic generators |
| **One-shot testing** | Single load test before launch, never again | Automate in CI, run continuously |
| **Optimizing mean latency** | Hides tail latency problems | Track p50, p95, p99, p99.9 |
| **Caching without eviction** | Unbounded memory growth | Set TTL and max size on every cache |
| **Ignoring cold start** | First request after deploy is slow | Warm caches and connection pools on startup |

---

## Red Flags

| Signal | Action | Rationale |
| :--- | :--- | :--- |
| No performance budget defined for any endpoint | Define p99 and throughput targets before launch | Without a budget you cannot detect regressions |
| Load test uses fewer than 3 concurrent users | Redesign the test with realistic concurrency | Single-user tests miss contention, pool exhaustion, and lock issues |
| Optimization PR has no before/after measurements | Request measurements before merging | Unmeasured optimization is guesswork |
| No profiling story in the team | Adopt a profiler and document the workflow | Without profiling, teams optimize by intuition |
| Benchmark results vary > 20% between runs | Isolate the benchmark environment | Noisy benchmarks produce false signals |
| Production latency dashboards do not exist | Set up p50/p95/p99 dashboards per endpoint | You cannot improve what you do not observe |

---

## Checklist

- [ ] Latency budgets (p50, p99) defined per endpoint
- [ ] Profiling tool selected and documented for each service language
- [ ] Load tests use realistic data, concurrency, and think-time
- [ ] Stress tests run quarterly or before major launches
- [ ] Benchmarks run in CI with regression detection
- [ ] Benchmark thresholds stored in version control
- [ ] Capacity plan reviewed monthly with growth projections
- [ ] Optimization PRs include before/after measurements
- [ ] Production dashboards track p50, p95, p99 latency per endpoint
- [ ] Caches have TTL and max-size limits

---

## See Also

- [Testing Strategy](../testing-strategy/testing-strategy.md) -- Test pyramid, coverage
- [Observability Patterns](../observability-patterns/observability-patterns.md) -- Metrics, tracing, health checks
- [Database Indexing](../database-indexing/database-indexing.md) -- Query optimization
- [Resilience Patterns](../resilience-patterns/resilience-patterns.md) -- Retries, circuit breakers
- [Concurrency & Async Patterns](../concurrency-async/concurrency-async.md) -- Parallelism, async I/O
