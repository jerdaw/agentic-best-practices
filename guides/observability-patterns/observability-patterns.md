# Observability Patterns

Guidelines for making systems transparent and debuggable through metrics, tracing, and structured logging.

> **Scope**: Applies to any production system. Extends beyond logging to include metrics, distributed tracing, and
> alerting. Systems must be observable by default.

## Contents

| Section |
| :--- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Three Pillars](#three-pillars) |
| [Metrics](#metrics) |
| [Distributed Tracing](#distributed-tracing) |
| [Health Checks](#health-checks) |
| [Alerting](#alerting) |
| [Anti-Patterns](#anti-patterns) |

---

## Quick Reference

| Category | Guidance | Rationale |
| :--- | :--- | :--- |
| **Always** | Emit the four Golden Signals | Core health indicators |
| **Always** | Propagate trace context across services | Enables request tracing |
| **Always** | Include correlation IDs in logs | Links logs to requests |
| **Always** | Define health check endpoints | Enables automated recovery |
| **Prefer** | OpenTelemetry over vendor SDKs | Portable, vendor-neutral |
| **Prefer** | Structured logs over text | Machine-parseable |
| **Never** | Log sensitive data (PII, secrets) | Security and privacy risk |
| **Never** | Alert on non-actionable signals | Alert fatigue |

---

## Core Principles

| Principle | Guideline | Rationale |
| :--- | :--- | :--- |
| **Observable by default** | Instrumentation is not optional | Problems surface automatically |
| **Three pillars** | Logs + Metrics + Traces together | Each reveals different insights |
| **Context propagation** | Trace ID flows through entire request | Enables distributed debugging |
| **Actionable alerts** | Every alert has a runbook | Reduces mean time to recovery |
| **Cardinality awareness** | High-cardinality labels have costs | Prevents metric explosion |

---

## Three Pillars

| Pillar | What It Captures | Best For |
| :--- | :--- | :--- |
| **Logs** | Discrete events with context | Debugging specific issues |
| **Metrics** | Aggregated numeric measurements | Dashboards, alerting, trends |
| **Traces** | Request flow across services | Latency analysis, dependencies |

### When to Use Each

| Question | Use |
| :--- | :--- |
| "What happened with request X?" | **Logs** (filter by trace ID) |
| "Is the system healthy right now?" | **Metrics** (Golden Signals) |
| "Why is this request slow?" | **Traces** (waterfall view) |
| "What's the error rate trend?" | **Metrics** (time series) |
| "What path did the request take?" | **Traces** (service graph) |

---

## Metrics

### Golden Signals

| Signal | What to Measure | Example Metric |
| :--- | :--- | :--- |
| **Latency** | Time to serve requests | `http_request_duration_seconds` |
| **Traffic** | Demand on the system | `http_requests_total` |
| **Errors** | Rate of failed requests | `http_request_errors_total` |
| **Saturation** | How "full" the service is | `process_cpu_seconds_total` |

### Metric Types

| Type | Use Case | Example |
| :--- | :--- | :--- |
| **Counter** | Cumulative count (only increases) | Requests served, errors |
| **Gauge** | Current value (can go up/down) | Queue depth, connections |
| **Histogram** | Distribution of values | Request latency buckets |
| **Summary** | Pre-calculated quantiles | p50, p95, p99 latency |

### Implementation

```python
# Good: OpenTelemetry metrics
from opentelemetry import metrics

meter = metrics.get_meter("myservice")

request_counter = meter.create_counter(
    "http_requests_total",
    description="Total HTTP requests"
)

latency_histogram = meter.create_histogram(
    "http_request_duration_seconds",
    description="Request latency in seconds"
)

def handle_request(request):
    start_time = time.time()
    try:
        response = process(request)
        request_counter.add(1, {"status": "success", "path": request.path})
        return response
    except Exception:
        request_counter.add(1, {"status": "error", "path": request.path})
        raise
    finally:
        duration = time.time() - start_time
        latency_histogram.record(duration, {"path": request.path})
```

### Label Cardinality

| Label | Cardinality | Safe? |
| :--- | :--- | :--- |
| `status_code` | ~10 values | ✓ Yes |
| `endpoint` | ~50 values | ✓ Yes |
| `user_id` | Millions | ✗ No - use traces/logs |
| `request_id` | Unlimited | ✗ No - use traces/logs |

---

## Distributed Tracing

### Core Concepts

| Concept | Definition |
| :--- | :--- |
| **Trace** | End-to-end request journey across services |
| **Span** | Single unit of work within a trace |
| **Context** | Trace ID + Span ID propagated between services |
| **Baggage** | Key-value pairs propagated with context |

### Context Propagation

```python
# Good: Propagate trace context in HTTP calls
from opentelemetry import trace
from opentelemetry.propagate import inject

tracer = trace.get_tracer("myservice")

def call_downstream_service(url, data):
    with tracer.start_as_current_span("downstream-call") as span:
        span.set_attribute("http.url", url)

        headers = {}
        inject(headers)  # Injects trace context

        response = requests.post(url, json=data, headers=headers)
        span.set_attribute("http.status_code", response.status_code)
        return response
```

### Span Enrichment

| Attribute | Purpose | Example |
| :--- | :--- | :--- |
| `http.method` | Request method | `GET`, `POST` |
| `http.url` | Request URL | `/api/users/123` |
| `http.status_code` | Response status | `200`, `500` |
| `db.statement` | Database query | `SELECT * FROM users` |
| `user.id` | User identifier | `user_12345` |
| `error` | Whether span errored | `true` |

---

## Health Checks

### Health Endpoint Design

| Endpoint | Purpose | Response |
| :--- | :--- | :--- |
| `/health/live` | Is process running? | 200 if alive |
| `/health/ready` | Can accept traffic? | 200 if ready |
| `/health/startup` | Has initialization completed? | 200 if started |

### Health Check Implementation

```python
# Good: Comprehensive health check
@app.get("/health/ready")
async def readiness_check():
    checks = {}

    # Check database
    try:
        await db.execute("SELECT 1")
        checks["database"] = "healthy"
    except Exception as e:
        checks["database"] = f"unhealthy: {e}"
        return JSONResponse({"status": "unhealthy", "checks": checks}, status_code=503)

    # Check cache
    try:
        await cache.ping()
        checks["cache"] = "healthy"
    except Exception as e:
        checks["cache"] = f"unhealthy: {e}"
        return JSONResponse({"status": "unhealthy", "checks": checks}, status_code=503)

    return {"status": "healthy", "checks": checks}
```

### Kubernetes Probes

```yaml
spec:
  containers:
  - name: app
    livenessProbe:
      httpGet:
        path: /health/live
        port: 8080
      initialDelaySeconds: 10
      periodSeconds: 10
    readinessProbe:
      httpGet:
        path: /health/ready
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 5
```

---

## Alerting

### Alert Design Principles

| Principle | Guideline | Anti-pattern |
| :--- | :--- | :--- |
| **Actionable** | Every alert has a response | Alerts no one can act on |
| **Symptom-based** | Alert on user impact | Alert on internal metrics |
| **Low noise** | Tune thresholds to reduce false positives | Alert on every blip |
| **Runbooks** | Link to resolution steps | Alerts without context |

### Alert Priority

| Severity | Response Time | Examples |
| :--- | :--- | :--- |
| **P1 Critical** | Immediate | Service down, data loss |
| **P2 High** | <1 hour | Degraded performance |
| **P3 Medium** | <24 hours | Warning threshold crossed |
| **P4 Low** | Next business day | Capacity planning signals |

### Good Alerts

```yaml
# Good: Symptom-based, actionable
- alert: HighErrorRate
  expr: |
    (sum(rate(http_requests_total{status=~"5.."}[5m]))
    / sum(rate(http_requests_total[5m]))) > 0.01
  for: 5m
  labels:
    severity: critical
  annotations:
    summary: "Error rate above 1% for 5 minutes"
    runbook: "https://wiki/runbooks/high-error-rate"
```

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| :--- | :--- | :--- |
| **Log and forget** | No metrics or traces | Implement all three pillars |
| **High-cardinality** | Metric explosion, cost | Use labels with bounded values |
| **Missing trace context** | Can't follow requests | Propagate context headers |
| **Sensitive data** | Privacy/security risk | Sanitize before emitting |
| **Alerting on causes** | Miss novel failure modes | Alert on symptoms |
| **Alert fatigue** | Ignored alerts | Tune thresholds, reduce noise |
| **No correlation IDs** | Can't link logs to requests | Generate and propagate IDs |

---

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| Alert firing every day that nobody investigates | Tune threshold or delete the alert | Alert fatigue causes real incidents to be ignored |
| Metrics dashboard with all green but users reporting errors | Add user-facing symptom metrics (Golden Signals) | Internal metrics can mask user-visible failures |
| No trace context propagated between services | Add OpenTelemetry context propagation | Without traces, debugging distributed issues requires log correlation by hand |
| `user_id` used as a metric label | Move to traces/logs — use bounded labels for metrics | High-cardinality labels cause metric storage explosion |
| Health check always returns 200 even when database is down | Check actual dependencies in the health endpoint | A useless health check prevents orchestrators from routing around failures |

---

## See Also

- [Logging Practices](../logging-practices/logging-practices.md) – Structured logging patterns
- [Deployment Strategies](../deployment-strategies/deployment-strategies.md) – Monitoring during rollouts
- [Resilience Patterns](../resilience-patterns/resilience-patterns.md) – Circuit breaker metrics
