# Resilience Patterns

Best practices for AI agents on building resilient systems—retries, circuit breakers, fallbacks, and graceful degradation.

> **Scope**: These patterns help AI agents write code that handles failures gracefully. Distributed systems fail; resilient code recovers.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Retry Pattern](#retry-pattern) |
| [Circuit Breaker Pattern](#circuit-breaker-pattern) |
| [Timeout Pattern](#timeout-pattern) |
| [Fallback Pattern](#fallback-pattern) |
| [Bulkhead Pattern](#bulkhead-pattern) |
| [Combining Patterns](#combining-patterns) |
| [Health Checks](#health-checks) |
| [Graceful Degradation](#graceful-degradation) |
| [Anti-Patterns](#anti-patterns) |
| [Durable Execution and Checkpointing](#durable-execution-and-checkpointing) |
| [Checklist](#checklist) |

---

## Quick Reference

**Core patterns**:

| Pattern | Purpose | When to Use |
|---------|---------|-------------|
| **Retry** | Recover from transient failures | Network blips, temporary errors |
| **Circuit Breaker** | Prevent cascade failures | Failing dependencies |
| **Timeout** | Bound waiting time | All external calls |
| **Fallback** | Provide alternative | Degraded service acceptable |
| **Bulkhead** | Isolate failures | Critical vs non-critical paths |

**Key numbers**:
- Retry: 3 attempts max, exponential backoff
- Timeout: Always set one (default: 30s for APIs)
- Circuit breaker: Trip after 5 consecutive failures

---

## Core Principles

1. **Failures are normal** – Design for failure, not just success
2. **Fail fast** – Don't wait forever; timeout early
3. **Fail gracefully** – Degrade rather than crash
4. **Isolate failures** – Don't let one failure cascade
5. **Recover automatically** – Self-heal when possible

---

## Retry Pattern

### When to Retry

| Error Type | Retry? | Rationale |
|------------|--------|-----------|
| Network timeout | Yes | Transient |
| Connection refused | Yes (with backoff) | Server may be restarting |
| 5xx server error | Yes | Server may recover |
| 429 rate limited | Yes (with delay) | Wait and retry |
| 4xx client error | No | Request is wrong |
| Validation error | No | Fix the input |
| Authentication error | No | Credentials are wrong |

### Retry with Exponential Backoff

```
Attempt 1: Immediate
Attempt 2: Wait 1 second
Attempt 3: Wait 2 seconds
Attempt 4: Wait 4 seconds
(Cap at max delay, e.g., 30 seconds)
```

### Implementation

```python
async def with_retry(fn, max_attempts=3, initial_delay=1.0, max_delay=30.0):
    """Retry with exponential backoff."""
    delay = initial_delay
    last_error = None

    for attempt in range(1, max_attempts + 1):
        try:
            return await fn()
        except RetryableError as e:
            last_error = e
            if attempt == max_attempts:
                raise

            # Add jitter to prevent thundering herd
            jitter = random.uniform(0, delay * 0.1)
            wait_time = min(delay + jitter, max_delay)

            logger.warning(f"Attempt {attempt} failed, retrying in {wait_time:.2f}s",
                          error=str(e))
            await asyncio.sleep(wait_time)
            delay *= 2

    raise last_error
```

```typescript
async function withRetry<T>(
  fn: () => Promise<T>,
  options: { maxAttempts?: number; initialDelay?: number; maxDelay?: number } = {}
): Promise<T> {
  const { maxAttempts = 3, initialDelay = 1000, maxDelay = 30000 } = options
  let delay = initialDelay
  let lastError: Error

  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await fn()
    } catch (error) {
      lastError = error as Error

      if (!isRetryable(error) || attempt === maxAttempts) {
        throw error
      }

      const jitter = Math.random() * delay * 0.1
      const waitTime = Math.min(delay + jitter, maxDelay)

      console.warn(`Attempt ${attempt} failed, retrying in ${waitTime}ms`)
      await sleep(waitTime)
      delay *= 2
    }
  }

  throw lastError!
}

function isRetryable(error: unknown): boolean {
  if (error instanceof NetworkError) return true
  if (error instanceof HttpError && error.status >= 500) return true
  if (error instanceof HttpError && error.status === 429) return true
  return false
}
```

### Retry Anti-Patterns

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| Infinite retries | Resource exhaustion | Cap at max attempts |
| No backoff | Hammers failing service | Exponential backoff |
| Retry non-idempotent | Duplicate operations | Only retry safe operations |
| No jitter | Thundering herd | Add random jitter |
| Retry everything | Wastes resources | Only retry transient errors |

---

## Circuit Breaker Pattern

### How It Works

```
CLOSED (normal operation)
    ↓ failures exceed threshold
OPEN (fail fast, no calls)
    ↓ wait timeout expires
HALF-OPEN (test with one call)
    ↓ success → CLOSED
    ↓ failure → OPEN
```

### States

| State | Behavior |
|-------|----------|
| **Closed** | Normal operation; track failures |
| **Open** | Reject immediately; don't call service |
| **Half-Open** | Allow one test call; decide next state |

### Implementation

```python
class CircuitBreaker:
    def __init__(self, failure_threshold=5, recovery_timeout=30):
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
        self.failures = 0
        self.state = "closed"
        self.last_failure_time = None

    async def call(self, fn):
        if self.state == "open":
            if self._should_attempt_reset():
                self.state = "half-open"
            else:
                raise CircuitOpenError("Circuit breaker is open")

        try:
            result = await fn()
            self._on_success()
            return result
        except Exception as e:
            self._on_failure()
            raise

    def _on_success(self):
        self.failures = 0
        self.state = "closed"

    def _on_failure(self):
        self.failures += 1
        self.last_failure_time = time.time()
        if self.failures >= self.failure_threshold:
            self.state = "open"

    def _should_attempt_reset(self):
        return time.time() - self.last_failure_time >= self.recovery_timeout
```

```typescript
class CircuitBreaker {
  private failures = 0
  private state: 'closed' | 'open' | 'half-open' = 'closed'
  private lastFailureTime?: number

  constructor(
    private failureThreshold = 5,
    private recoveryTimeout = 30000
  ) {}

  async call<T>(fn: () => Promise<T>): Promise<T> {
    if (this.state === 'open') {
      if (this.shouldAttemptReset()) {
        this.state = 'half-open'
      } else {
        throw new CircuitOpenError('Circuit breaker is open')
      }
    }

    try {
      const result = await fn()
      this.onSuccess()
      return result
    } catch (error) {
      this.onFailure()
      throw error
    }
  }

  private onSuccess(): void {
    this.failures = 0
    this.state = 'closed'
  }

  private onFailure(): void {
    this.failures++
    this.lastFailureTime = Date.now()
    if (this.failures >= this.failureThreshold) {
      this.state = 'open'
    }
  }

  private shouldAttemptReset(): boolean {
    return Date.now() - (this.lastFailureTime ?? 0) >= this.recoveryTimeout
  }
}
```

### When to Use Circuit Breakers

| Scenario | Use Circuit Breaker? |
|----------|---------------------|
| External API calls | Yes |
| Database connections | Yes |
| Microservice calls | Yes |
| Local computations | No |
| Cache lookups | Usually no |

---

## Timeout Pattern

### Always Set Timeouts

Every external call needs a timeout. No exceptions.

| Operation | Suggested Timeout |
|-----------|-------------------|
| HTTP API call | 30 seconds |
| Database query | 10 seconds |
| Cache lookup | 1 second |
| Health check | 5 seconds |
| File upload | 5 minutes |

### Implementation

```python
async def with_timeout(fn, timeout_seconds):
    """Execute with timeout."""
    try:
        return await asyncio.wait_for(fn(), timeout=timeout_seconds)
    except asyncio.TimeoutError:
        raise TimeoutError(f"Operation timed out after {timeout_seconds}s")
```

```typescript
async function withTimeout<T>(
  promise: Promise<T>,
  timeoutMs: number
): Promise<T> {
  const timeout = new Promise<never>((_, reject) => {
    setTimeout(() => reject(new TimeoutError(`Timeout after ${timeoutMs}ms`)), timeoutMs)
  })
  return Promise.race([promise, timeout])
}
```

### Timeout Considerations

| Factor | Impact |
|--------|--------|
| Network latency | Add buffer for slow networks |
| Operation complexity | Complex queries need more time |
| User expectations | Balance UX vs reliability |
| Downstream timeouts | Your timeout < downstream timeout |

---

## Fallback Pattern

### Fallback Strategies

| Strategy | When to Use |
|----------|-------------|
| Default value | Missing data acceptable |
| Cached data | Stale data acceptable |
| Alternative service | Redundant provider available |
| Degraded response | Partial functionality acceptable |
| Error response | Must inform user |

### Implementation

```python
async def with_fallback(primary_fn, fallback_fn):
    """Try primary, fall back on failure."""
    try:
        return await primary_fn()
    except Exception as e:
        logger.warning(f"Primary failed, using fallback: {e}")
        return await fallback_fn()
```

```typescript
async function withFallback<T>(
  primary: () => Promise<T>,
  fallback: () => Promise<T>
): Promise<T> {
  try {
    return await primary()
  } catch (error) {
    console.warn('Primary failed, using fallback:', error)
    return fallback()
  }
}

// Usage
const userData = await withFallback(
  () => fetchUserFromApi(userId),
  () => fetchUserFromCache(userId)
)
```

### Fallback Hierarchy

```
1. Try primary source
   ↓ fail
2. Try secondary source
   ↓ fail
3. Try cache
   ↓ fail
4. Return default/error
```

---

## Bulkhead Pattern

### Isolate Failure Domains

Prevent one failing component from exhausting resources for others.

| Resource | Isolation Method |
|----------|-----------------|
| Thread pools | Separate pools per dependency |
| Connection pools | Separate pools per service |
| Rate limits | Per-endpoint limits |
| Memory | Bounded queues |

### Implementation

```python
class Bulkhead:
    def __init__(self, max_concurrent: int):
        self.semaphore = asyncio.Semaphore(max_concurrent)

    async def execute(self, fn):
        async with self.semaphore:
            return await fn()

# Separate bulkheads for different services
api_bulkhead = Bulkhead(max_concurrent=10)
db_bulkhead = Bulkhead(max_concurrent=5)

# Usage
result = await api_bulkhead.execute(lambda: call_external_api())
```

```typescript
class Bulkhead {
  private current = 0

  constructor(private maxConcurrent: number) {}

  async execute<T>(fn: () => Promise<T>): Promise<T> {
    if (this.current >= this.maxConcurrent) {
      throw new BulkheadFullError('Bulkhead capacity exceeded')
    }

    this.current++
    try {
      return await fn()
    } finally {
      this.current--
    }
  }
}
```

---

## Combining Patterns

### Resilience Pipeline

```
Request
  → Timeout (outermost)
    → Circuit Breaker
      → Bulkhead
        → Retry
          → Actual Call
        ← Fallback (on final failure)
```

### Combined Example

```typescript
async function resilientCall<T>(
  fn: () => Promise<T>,
  options: {
    timeout: number
    fallback: () => Promise<T>
    circuitBreaker: CircuitBreaker
    bulkhead: Bulkhead
    maxRetries: number
  }
): Promise<T> {
  const { timeout, fallback, circuitBreaker, bulkhead, maxRetries } = options

  try {
    // Timeout wraps everything
    return await withTimeout(
      // Circuit breaker checks if we should even try
      circuitBreaker.call(async () => {
        // Bulkhead limits concurrent calls
        return bulkhead.execute(async () => {
          // Retry handles transient failures
          return withRetry(fn, { maxAttempts: maxRetries })
        })
      }),
      timeout
    )
  } catch (error) {
    // Fallback on any failure
    return fallback()
  }
}
```

---

## Health Checks

### Liveness vs Readiness

| Check | Question | Failed Response |
|-------|----------|-----------------|
| **Liveness** | Is the process alive? | Restart the process |
| **Readiness** | Can it handle requests? | Stop sending traffic |

### Health Check Implementation

```typescript
interface HealthStatus {
  status: 'healthy' | 'degraded' | 'unhealthy'
  checks: Record<string, { status: string; latency?: number }>
}

async function checkHealth(): Promise<HealthStatus> {
  const checks: Record<string, { status: string; latency?: number }> = {}

  // Check database
  const dbStart = Date.now()
  try {
    await db.query('SELECT 1')
    checks.database = { status: 'ok', latency: Date.now() - dbStart }
  } catch {
    checks.database = { status: 'failed' }
  }

  // Check cache
  const cacheStart = Date.now()
  try {
    await cache.ping()
    checks.cache = { status: 'ok', latency: Date.now() - cacheStart }
  } catch {
    checks.cache = { status: 'failed' }
  }

  // Determine overall status
  const allOk = Object.values(checks).every(c => c.status === 'ok')
  const allFailed = Object.values(checks).every(c => c.status === 'failed')

  return {
    status: allOk ? 'healthy' : allFailed ? 'unhealthy' : 'degraded',
    checks
  }
}
```

---

## Graceful Degradation

### Degradation Strategies

| Situation | Degradation |
|-----------|-------------|
| Recommendation service down | Show popular items |
| Search slow | Return cached results |
| Payment provider down | Queue for later processing |
| Analytics failing | Skip tracking, continue |

### Feature Flags for Degradation

```typescript
async function getRecommendations(userId: string): Promise<Product[]> {
  if (featureFlags.isEnabled('recommendations')) {
    try {
      return await recommendationService.getForUser(userId)
    } catch (error) {
      logger.warn('Recommendation service failed', { error })
      // Fall through to degraded mode
    }
  }

  // Degraded: return popular items
  return getPopularProducts()
}
```

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| **No timeout** | Requests hang forever | Always set timeouts |
| **Retry storms** | Overwhelm recovering service | Exponential backoff + jitter |
| **Cascade failures** | One failure takes down system | Circuit breakers + bulkheads |
| **Silent failures** | Problems go unnoticed | Log and alert on fallbacks |
| **Retry non-idempotent** | Duplicate side effects | Only retry safe operations |
| **Tight coupling** | Can't degrade gracefully | Design for partial failures |

---

## Durable Execution and Checkpointing

For long-running agent operations, implement checkpointing to enable resumption.

### When to Checkpoint

| Scenario | Checkpoint? | Rationale |
|----------|-------------|-----------|
| Multi-step operations | Yes | Resume from last step |
| Expensive computations | Yes | Don't repeat work |
| External API sequences | Yes | Continue after rate limits |
| User-interruptible tasks | Yes | Allow pause/resume |
| Quick, idempotent operations | No | Cheaper to restart |

### Checkpoint Pattern

```typescript
interface Checkpoint {
  taskId: string
  step: number
  state: Record<string, unknown>
  timestamp: string
  expiresAt: string
}

async function durableTask(taskId: string, steps: Step[]) {
  // Load existing checkpoint
  let checkpoint = await loadCheckpoint(taskId)
  let startStep = checkpoint?.step ?? 0
  let state = checkpoint?.state ?? {}

  for (let i = startStep; i < steps.length; i++) {
    const step = steps[i]

    try {
      state = await step.execute(state)

      // Save progress after each step
      await saveCheckpoint({
        taskId,
        step: i + 1,
        state,
        timestamp: new Date().toISOString(),
        expiresAt: addHours(new Date(), 24).toISOString()
      })

    } catch (error) {
      if (isResumable(error)) {
        // Checkpoint saved, can retry later
        throw new ResumableError(taskId, i, error)
      }
      throw error
    }
  }

  // Clean up on completion
  await deleteCheckpoint(taskId)
  return state
}
```

### Resumption Pattern

```typescript
async function resumeTask(taskId: string): Promise<Result> {
  const checkpoint = await loadCheckpoint(taskId)

  if (!checkpoint) {
    throw new Error(`No checkpoint found for task ${taskId}`)
  }

  if (isExpired(checkpoint)) {
    await deleteCheckpoint(taskId)
    throw new Error(`Checkpoint expired for task ${taskId}`)
  }

  logger.info('Resuming task from checkpoint', {
    taskId,
    step: checkpoint.step,
    age: Date.now() - new Date(checkpoint.timestamp).getTime()
  })

  return durableTask(taskId, getSteps(taskId))
}
```

### Checkpoint Storage

| Storage | Use Case | Durability |
|---------|----------|------------|
| Memory | Development, short tasks | None (lost on restart) |
| File system | Single-node, local tasks | Good |
| Redis | Distributed, medium duration | Good with persistence |
| Database | Long-running, critical tasks | High |

### Idempotency Requirements

For durable execution, steps should be idempotent:

```typescript
// BAD: Not idempotent - sends duplicate emails on retry
async function notifyUser(state) {
  await sendEmail(state.userId, 'Task complete')
  return state
}

// GOOD: Idempotent - checks if already done
async function notifyUser(state) {
  if (state.notificationSent) {
    return state
  }

  await sendEmail(state.userId, 'Task complete')
  return { ...state, notificationSent: true }
}
```

---

## Checklist

For resilient code:

- [ ] All external calls have timeouts
- [ ] Transient failures are retried with backoff
- [ ] Circuit breakers protect against failing dependencies
- [ ] Fallbacks exist for critical paths
- [ ] Resources are isolated with bulkheads
- [ ] Health checks monitor dependencies
- [ ] Failures are logged with context
- [ ] Degradation is graceful, not catastrophic
- [ ] Long operations have checkpoints
- [ ] Steps are idempotent for safe resumption

---

## See Also

- [Error Handling](../error-handling/error-handling.md) – Handling errors in code
- [Logging Practices](../logging-practices/logging-practices.md) – Logging resilience events
