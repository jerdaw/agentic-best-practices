# Concurrency & Async Patterns

Best practices for writing concurrent and asynchronous code — threading, async/await, race condition prevention, and structured concurrency.

> **Scope**: Covers concurrency and asynchronous programming: threading models, async/await patterns, race condition prevention, deadlock avoidance, and structured concurrency. Applies to backend services, CLI tools, and any code handling parallel work.

## Contents

| Section |
| :--- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Concurrency Models](#concurrency-models) |
| [Async/Await Patterns](#asyncawait-patterns) |
| [Race Conditions](#race-conditions) |
| [Deadlock Prevention](#deadlock-prevention) |
| [Structured Concurrency](#structured-concurrency) |
| [Bounded Parallelism](#bounded-parallelism) |
| [Anti-Patterns](#anti-patterns) |
| [Red Flags](#red-flags) |
| [Checklist](#checklist) |
| [See Also](#see-also) |

---

## Quick Reference

**Concurrency model selection**:

| Workload Type | Recommended Model | Rationale |
| :--- | :--- | :--- |
| I/O-bound (HTTP, DB, file) | Async/await | Single thread, no context-switch overhead |
| CPU-bound (compression, crypto) | Multiprocess / worker threads | Bypasses GIL; uses multiple cores |
| Mixed I/O + CPU | Hybrid (async loop + process pool) | Offload CPU work from the event loop |
| Short, independent tasks | Thread pool | Simple model when tasks are brief |

**Key limits**:

- Always bound parallelism — unbounded concurrency exhausts sockets, file descriptors, and memory
- Always propagate cancellation — orphaned tasks leak resources and delay shutdown

---

## Core Principles

1. **Structured concurrency** — Every task has a clear owner, scope, and lifecycle. No orphans.
2. **Share nothing** — Prefer message passing and immutable data over shared mutable state.
3. **Bound parallelism** — Always limit concurrent work with semaphores, pools, or queue depth.
4. **Cancellation required** — Every async operation must support cancellation and respect it promptly.
5. **Test under contention** — Concurrent bugs only surface under load; unit tests alone are insufficient.

---

## Concurrency Models

### Threads vs Async vs Multiprocess

| Factor | Threads | Async/Await | Multiprocess |
| :--- | :--- | :--- | :--- |
| Best for | Blocking I/O, legacy libs | High-volume I/O | CPU-heavy computation |
| Overhead | Medium (OS threads) | Low (coroutines) | High (process spawn) |
| Shared state | Yes (needs locks) | Single-threaded (cooperative) | No (IPC required) |
| GIL impact (Python) | Blocks CPU parallelism | N/A (single thread) | Bypasses GIL |
| Complexity | High (data races) | Medium (color problem) | Low (isolation) |

### Choosing the Right Model

| Situation | Model | Example |
| :--- | :--- | :--- |
| 100+ concurrent HTTP requests | Async | API gateway, web scraper |
| Image/video processing pipeline | Multiprocess | Thumbnail generation |
| Database connection pooling | Async or thread pool | ORM query execution |
| Mixed API calls + data transform | Hybrid | Fetch data, then crunch |
| Legacy blocking library | Thread pool wrapper | `asyncio.to_thread()` |

---

## Async/Await Patterns

### Proper Async Usage

```python
# Bad: forgotten await — returns coroutine object, never executes
async def process_order(order_id: str):
    result = validate_order(order_id)  # Missing await!
    save_order(result)                 # result is a coroutine, not data

# Good: every async call awaited
async def process_order(order_id: str):
    result = await validate_order(order_id)
    await save_order(result)
```

```typescript
// Bad: error swallowed silently in async callback
app.get('/users', async (req, res) => {
  fetchUsers().then(users => res.json(users))
  // No .catch() — unhandled rejection on failure
})

// Good: await with proper error handling
app.get('/users', async (req, res, next) => {
  try {
    const users = await fetchUsers()
    res.json(users)
  } catch (error) {
    next(error)
  }
})
```

### Error Handling in Async Code

| Approach | Behavior on Failure | Use When |
| :--- | :--- | :--- |
| `asyncio.gather(*tasks)` | First exception cancels nothing; raises on `await` | All-or-nothing, simple cases |
| `asyncio.TaskGroup()` | Cancels remaining tasks on first exception | Structured concurrency (Python 3.11+) |
| `Promise.all()` | Rejects on first failure, remaining run to completion | Fail-fast semantics |
| `Promise.allSettled()` | Waits for all, returns status per promise | Need partial results |

```python
# Bad: gather swallows errors from other tasks
results = await asyncio.gather(
    fetch_users(),
    fetch_orders(),
    fetch_inventory(),
    return_exceptions=True,  # Errors silently mixed into results
)

# Good: TaskGroup cancels siblings on failure
async with asyncio.TaskGroup() as tg:
    users = tg.create_task(fetch_users())
    orders = tg.create_task(fetch_orders())
    inventory = tg.create_task(fetch_inventory())
# All tasks complete or all are cancelled
```

```typescript
// Bad: Promise.all loses partial results on single failure
const [users, orders] = await Promise.all([
  fetchUsers(),
  fetchOrders(), // If this throws, users result is lost
])

// Good: allSettled preserves partial results
const results = await Promise.allSettled([
  fetchUsers(),
  fetchOrders(),
])
const users = results[0].status === 'fulfilled' ? results[0].value : []
const orders = results[1].status === 'fulfilled' ? results[1].value : []
```

---

## Race Conditions

### Common Patterns

| Pattern | Description | Example |
| :--- | :--- | :--- |
| TOCTOU (time-of-check-to-time-of-use) | State changes between check and action | Check file exists, then open |
| Unprotected shared state | Multiple writers without synchronization | Counter incremented from two threads |
| Read-modify-write | Non-atomic update cycle | Read balance, compute new, write back |
| Lost update | Concurrent writes overwrite each other | Two users edit same record |

### Prevention Strategies

| Strategy | Mechanism | Best For |
| :--- | :--- | :--- |
| Locks / mutexes | Serialize access to critical section | Short, infrequent critical sections |
| Atomic operations | Hardware-level indivisible ops | Counters, flags |
| Message passing | Channels, queues, actors | Cross-thread communication |
| Optimistic concurrency | Version check before write | Database updates |
| Immutable data | No mutation possible | Functional pipelines |

```python
import threading

# Bad: unprotected shared state
counter = 0
def increment():
    global counter
    counter += 1  # Not atomic — read-modify-write race

# Good: atomic update with lock
counter = 0
lock = threading.Lock()
def increment():
    global counter
    with lock:
        counter += 1
```

```typescript
// Bad: race condition on shared map in concurrent handlers
const cache = new Map<string, number>()
async function handleRequest(key: string) {
  const current = cache.get(key) ?? 0
  // Another handler can read stale value here
  cache.set(key, current + 1)
}

// Good: serialize access with a mutex
import { Mutex } from 'async-mutex'
const cache = new Map<string, number>()
const mutex = new Mutex()
async function handleRequest(key: string) {
  const release = await mutex.acquire()
  try {
    const current = cache.get(key) ?? 0
    cache.set(key, current + 1)
  } finally {
    release()
  }
}
```

---

## Deadlock Prevention

### Lock Ordering

Acquire locks in a globally consistent order to prevent circular waits.

| Rule | Rationale |
| :--- | :--- |
| Define a total ordering on locks | Prevents ABBA deadlocks |
| Always acquire in ascending order | Deterministic acquisition |
| Release in reverse order | Matches stack-like discipline |
| Document lock hierarchy | Makes ordering reviewable |

```python
# Bad: inconsistent lock ordering — deadlock risk
async def transfer(from_acct, to_acct, amount):
    async with from_acct.lock:      # Thread 1: locks A, then B
        async with to_acct.lock:
            from_acct.balance -= amount
            to_acct.balance += amount

# Good: always lock lower ID first
async def transfer(from_acct, to_acct, amount):
    first, second = sorted([from_acct, to_acct], key=lambda a: a.id)
    async with first.lock:
        async with second.lock:
            from_acct.balance -= amount
            to_acct.balance += amount
```

### Timeout on Acquisition

Never wait forever for a lock. Apply a timeout and handle acquisition failure.

```python
# Good: timeout prevents deadlock hang
import asyncio

async def safe_acquire(lock, timeout=5.0):
    try:
        await asyncio.wait_for(lock.acquire(), timeout=timeout)
        return True
    except asyncio.TimeoutError:
        logger.warning("Lock acquisition timed out")
        return False
```

```typescript
// Good: Promise.race for lock acquisition timeout
async function acquireWithTimeout(
  mutex: Mutex,
  timeoutMs: number
): Promise<() => void> {
  const release = mutex.acquire()
  const timeout = new Promise<never>((_, reject) =>
    setTimeout(() => reject(new Error('Lock timeout')), timeoutMs)
  )
  return Promise.race([release, timeout])
}
```

---

## Structured Concurrency

### Task Groups and Scopes

Structured concurrency guarantees that child tasks cannot outlive their parent scope. When the scope exits, all children are awaited or cancelled.

```python
# Bad: fire-and-forget task — no ownership, no error handling
asyncio.create_task(send_notification(user_id))

# Good: structured concurrency — parent owns child lifecycle
async with asyncio.TaskGroup() as tg:
    tg.create_task(send_notification(user_id))
# Task is guaranteed complete (or cancelled) when scope exits
```

```typescript
// Bad: unhandled promise — no tracking, swallowed errors
sendNotification(userId)

// Good: tracked with AbortController
const controller = new AbortController()
try {
  await Promise.all([
    sendNotification(userId, { signal: controller.signal }),
  ])
} catch (error) {
  controller.abort()
  throw error
}
```

### Cancellation Propagation

| Pattern | Cancellation Behavior | Lifecycle Guarantee |
| :--- | :--- | :--- |
| `asyncio.TaskGroup` | Cancels siblings on first failure | All tasks done at scope exit |
| `AbortController` | Signal propagates to all listeners | Manual, but composable |
| `context.Context` (Go-style) | Deadline/cancel propagates down call tree | Convention-enforced |
| Fire-and-forget | None | None — resource leak risk |

```python
# Bad: task outlives request — resource leak
async def handle_request(request):
    asyncio.create_task(audit_log(request))  # Orphaned if server shuts down
    return Response(200)

# Good: task bound to request lifecycle
async def handle_request(request):
    async with asyncio.TaskGroup() as tg:
        tg.create_task(audit_log(request))
        response = await process(request)
    return response
```

---

## Bounded Parallelism

### Semaphores

Limit concurrent access to a shared resource without a full worker pool.

```python
# Bad: unbounded — 10,000 concurrent connections
await asyncio.gather(*[fetch(url) for url in urls])

# Good: bounded with semaphore
sem = asyncio.Semaphore(20)
async def bounded_fetch(url):
    async with sem:
        return await fetch(url)
await asyncio.gather(*[bounded_fetch(url) for url in urls])
```

```typescript
// Bad: unbounded Promise.all overwhelms target service
const results = await Promise.all(
  urls.map(url => fetch(url)) // 10,000 concurrent requests
)

// Good: concurrency-limited with p-limit
import pLimit from 'p-limit'
const limit = pLimit(20)
const results = await Promise.all(
  urls.map(url => limit(() => fetch(url)))
)
```

### Worker Pools

Use worker pools when tasks are CPU-intensive or require process isolation.

| Pool Type | Language | Use Case |
| :--- | :--- | :--- |
| `ProcessPoolExecutor` | Python | CPU-bound work (image processing, hashing) |
| `ThreadPoolExecutor` | Python | Blocking I/O wrappers |
| Worker Threads | Node.js | CPU-intensive tasks off the event loop |
| `workerpool` | Node.js | Managed pool with task queuing |

```python
from concurrent.futures import ProcessPoolExecutor
import asyncio

# Good: offload CPU work to process pool
async def process_images(paths: list[str]) -> list[bytes]:
    loop = asyncio.get_event_loop()
    with ProcessPoolExecutor(max_workers=4) as pool:
        results = await asyncio.gather(*[
            loop.run_in_executor(pool, compress_image, path)
            for path in paths
        ])
    return results
```

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| :--- | :--- | :--- |
| **Fire-and-forget** | Orphaned tasks, swallowed errors, resource leaks | Use task groups or track all promises |
| **Shared mutable state without sync** | Race conditions, corrupted data | Locks, atomics, or message passing |
| **Unbounded concurrency** | Socket/FD/memory exhaustion | Semaphores or worker pools |
| **Holding locks across await** | Blocks event loop, increases contention window | Minimize critical section; release before await |
| **Busy-wait polling** | CPU waste, latency | Use `asyncio.Event`, `Condition`, or OS-level signals |
| **Blocking call on async event loop** | Starves all other coroutines | Use `asyncio.to_thread()` or `run_in_executor()` |
| **Ignoring cancellation signals** | Graceful shutdown impossible | Check `signal.aborted` / `CancelledError` |
| **Global mutable singleton** | Hidden coupling, untestable concurrency | Dependency injection, thread-local, or context vars |

---

## Red Flags

| Signal | Action | Rationale |
| :--- | :--- | :--- |
| Unawaited coroutine or floating promise | Add `await` or attach to a task group | Silently drops errors and results |
| Lock acquired with no timeout | Add `asyncio.wait_for()` or `Promise.race()` timeout | Hangs forever on deadlock |
| Global mutable accessed from multiple threads | Add lock, use `threading.local()`, or redesign | Data corruption under concurrency |
| Unlimited parallel HTTP requests | Cap with semaphore or `p-limit` | Exhausts sockets, triggers rate limits |
| `asyncio.gather(return_exceptions=True)` without checking results | Inspect each result for exceptions | Errors pass silently as return values |
| `time.sleep()` inside async function | Replace with `await asyncio.sleep()` | Blocks the entire event loop |
| No `AbortController` on long-lived fetch calls | Pass signal to support cancellation | Leaked connections on timeout or shutdown |

---

## Checklist

- [ ] Concurrency model chosen based on workload type (I/O vs CPU vs mixed)
- [ ] All async calls properly awaited; no floating promises
- [ ] Parallelism bounded by semaphore, pool, or queue depth
- [ ] Locks have timeouts; acquisition order is documented
- [ ] Shared mutable state protected or eliminated
- [ ] Cancellation propagated through task groups or `AbortController`
- [ ] No blocking calls on the async event loop
- [ ] Fire-and-forget tasks replaced with structured concurrency
- [ ] Race conditions tested with concurrent load (not just serial unit tests)
- [ ] Graceful shutdown waits for in-flight tasks before exit

---

## See Also

- [Error Handling](../error-handling/error-handling.md) -- Async error propagation and exception safety
- [Resilience Patterns](../resilience-patterns/resilience-patterns.md) -- Retries, circuit breakers, timeouts
- [Idempotency Patterns](../idempotency-patterns/idempotency-patterns.md) -- Safe retry under concurrency
- [Testing Strategy](../testing-strategy/testing-strategy.md) -- Testing concurrent code paths
- [Performance Engineering](../performance-engineering/performance-engineering.md) -- Throughput and latency optimization
