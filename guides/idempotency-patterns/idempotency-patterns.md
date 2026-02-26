# Idempotency & Safe Retry Patterns

Guidelines for designing operations that can be safely retried without causing duplicate effects or data corruption.

> **Scope**: Applies to any operation with side effects—API calls, database writes, payment processing, resource creation. Critical for autonomous agents who cannot manually verify "did that go through?"

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [HTTP Method Safety](#http-method-safety) |
| [Implementation Patterns](#implementation-patterns) |
| [Database Patterns](#database-patterns) |
| [Retry Strategies](#retry-strategies) |
| [Anti-Patterns](#anti-patterns) |
| [Verification](#verification) |

---

## Quick Reference

| Category | Guidance | Rationale |
| --- | --- | --- |
| **Always** | Generate idempotency keys before first attempt | Enables safe retry without duplicate effects |
| **Always** | Persist idempotency key across retries | Same key must be used for all attempts |
| **Always** | Use exponential backoff for retries | Prevents thundering herd; respects rate limits |
| **Always** | Treat timeout as "unknown", not "failed" | Request may have succeeded on server |
| **Prefer** | Atomic upserts over check-then-insert | Eliminates race conditions |
| **Prefer** | PUT over POST for resource updates | PUT is inherently idempotent |
| **Never** | Retry without idempotency key on POST/PATCH | Causes duplicate transactions |
| **Never** | Generate new idempotency key on retry | Defeats the purpose of idempotency |

---

## Core Principles

| Principle | Guideline | Rationale |
| --- | --- | --- |
| **Same input, same effect** | Repeated calls with same parameters yield same result | Enables fearless retries |
| **Client-generated keys** | Caller creates unique ID before first attempt | Server can detect duplicates |
| **Immutable responses** | Return stored result for duplicate requests | Consistency across retries |
| **Timeout ≠ failure** | Unknown state requires same handling as success | Prevents duplicate transactions |
| **Deterministic recovery** | Retry logic should be mechanical, not manual | Enables autonomous agent operation |

---

## HTTP Method Safety

| Method | Idempotent | Safe | Agent Strategy |
| --- | --- | --- | --- |
| **GET** | ✓ | ✓ | Safe to retry indefinitely |
| **HEAD** | ✓ | ✓ | Safe to retry indefinitely |
| **OPTIONS** | ✓ | ✓ | Safe to retry indefinitely |
| **PUT** | ✓ | ✗ | Safe to retry; replaces entire resource |
| **DELETE** | ✓ | ✗ | Safe to retry; 404 on subsequent calls is success |
| **POST** | ✗ | ✗ | **Requires idempotency key** |
| **PATCH** | ✗ | ✗ | **Requires idempotency key or ETag** |

### When POST Becomes Idempotent

```http
// Good: Idempotency key in header
POST /payments
Idempotency-Key: 550e8400-e29b-41d4-a716-446655440000
Content-Type: application/json

{"amount": 100, "currency": "USD"}

// Server response (first call)
201 Created
{"id": "pay_123", "status": "completed"}

// Server response (duplicate call with same key)
200 OK  // or 201 - implementation varies
{"id": "pay_123", "status": "completed"}  // Same result, no new charge
```

---

## Implementation Patterns

### Pattern 1: Idempotency Keys

Generate a unique key **before** the first request attempt. Persist it for all retries.

| Step | Action | Rationale |
| --- | --- | --- |
| 1 | Generate UUID v4 | Globally unique, no coordination needed |
| 2 | Store key with request context | Survives process crashes |
| 3 | Include in request header | Server tracks processed keys |
| 4 | Reuse same key on retry | Server returns cached response |

```python
# Good: Key persisted before first attempt
idempotency_key = str(uuid.uuid4())
save_to_journal(operation_id, idempotency_key)

for attempt in range(max_retries):
    response = client.post(
        "/payments",
        headers={"Idempotency-Key": idempotency_key},
        json=payload
    )
    if response.status_code < 500:
        break
    await exponential_backoff(attempt)
```

```python
# Bad: New key on each attempt
for attempt in range(max_retries):
    response = client.post(
        "/payments",
        headers={"Idempotency-Key": str(uuid.uuid4())},  # Wrong!
        json=payload
    )
```

### Pattern 2: Natural Idempotency Keys

When requests have natural unique identifiers, use them instead of generated UUIDs.

| Domain | Natural Key | Example |
| --- | --- | --- |
| Orders | Order ID | `order_2024_00123` |
| Payments | Invoice + attempt | `inv_456_payment_1` |
| User actions | User + action + timestamp | `user_789_signup_20240202` |
| File uploads | Content hash | `sha256:abc123...` |

---

## Database Patterns

### Atomic Upserts

Replace "check-then-insert" with atomic operations.

```sql
-- Good: Atomic upsert (PostgreSQL)
INSERT INTO users (email, name, created_at)
VALUES ('user@example.com', 'Alice', NOW())
ON CONFLICT (email) DO UPDATE SET
    name = EXCLUDED.name,
    updated_at = NOW();

-- Bad: Race condition between check and insert
SELECT id FROM users WHERE email = 'user@example.com';
-- Another process inserts here
INSERT INTO users (email, name) VALUES ('user@example.com', 'Alice');
-- Fails or creates duplicate
```

### Unique Constraints as Guards

| Technique | SQL Example | Effect |
| --- | --- | --- |
| Unique constraint | `UNIQUE(order_id, payment_id)` | DB rejects duplicates |
| Composite key | `PRIMARY KEY(user_id, action, date)` | Natural deduplication |
| Idempotency table | `INSERT INTO processed_requests(key)` | Track processed operations |

```sql
-- Idempotency tracking table
CREATE TABLE processed_requests (
    idempotency_key VARCHAR(255) PRIMARY KEY,
    response_body JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

-- In transaction: check and process atomically
BEGIN;
INSERT INTO processed_requests (idempotency_key, response_body)
VALUES ($1, $2)
ON CONFLICT (idempotency_key) DO NOTHING;

-- If insert succeeded (1 row affected), process the operation
-- If conflict (0 rows affected), return stored response
COMMIT;
```

---

## Retry Strategies

### Exponential Backoff with Jitter

| Attempt | Base Delay | With Jitter | Rationale |
| --- | --- | --- | --- |
| 1 | 1s | 0.5-1.5s | Immediate retry unlikely to help |
| 2 | 2s | 1-3s | Give server time to recover |
| 3 | 4s | 2-6s | Increasing gaps reduce load |
| 4 | 8s | 4-12s | Jitter prevents thundering herd |
| 5 | 16s | 8-24s | Max reasonable wait |

```python
import random

def exponential_backoff(attempt: int, base: float = 1.0, max_delay: float = 30.0) -> float:
    delay = min(base * (2 ** attempt), max_delay)
    jitter = delay * random.uniform(0.5, 1.5)
    return jitter
```

### When to Retry

| Response | Retry? | Rationale |
| --- | --- | --- |
| 2xx Success | No | Operation completed |
| 4xx Client Error | No | Request is invalid; retry won't help |
| 400 Bad Request | No | Fix the request first |
| 401/403 Auth Error | No | Retry with new credentials |
| 404 Not Found | No | Resource doesn't exist |
| 409 Conflict | Maybe | Re-fetch state, resolve conflict, retry |
| 429 Rate Limited | Yes | After `Retry-After` delay |
| 5xx Server Error | Yes | With exponential backoff |
| Timeout | Yes | **With same idempotency key** |
| Connection Error | Yes | With exponential backoff |

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| --- | --- | --- |
| **New key per retry** | Each attempt creates new transaction | Persist key before first attempt |
| **Check-then-act** | Race condition window | Use atomic operations |
| **Immediate retry** | Overwhelms failing service | Exponential backoff with jitter |
| **Infinite retries** | Never surfaces real errors | Cap at 3-5 attempts, then escalate |
| **Retry on 4xx** | Wastes resources; will never succeed | Only retry transient failures |
| **Timeout = failure** | May cause duplicate operations | Treat as unknown; use idempotency key |
| **Client-side dedup only** | Breaks on client restart | Server must enforce idempotency |

---

## Verification

### Testing Idempotency

| Test Case | Method | Expected Result |
| --- | --- | --- |
| Duplicate request | Send same request + key twice | Same response both times |
| Different key, same data | Send same data with different key | Two separate operations |
| Concurrent duplicates | Race two requests with same key | Exactly one operation |
| Retry after timeout | Timeout first request, retry | Single operation, success response |

```python
def test_idempotency():
    key = str(uuid.uuid4())
    
    # First request
    response1 = client.post("/orders", 
        headers={"Idempotency-Key": key},
        json={"item": "widget", "qty": 1})
    
    # Duplicate request
    response2 = client.post("/orders",
        headers={"Idempotency-Key": key},
        json={"item": "widget", "qty": 1})
    
    # Same order ID returned, no duplicate created
    assert response1.json()["id"] == response2.json()["id"]
    assert Order.count() == 1
```

---

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| Payment endpoint can be called twice and charge twice | Add an idempotency key check before processing | Double-charging is a critical bug with legal and trust consequences |
| Idempotency key stored only in memory | Use durable storage (database/Redis) for key tracking | In-memory keys are lost on restart, defeating the purpose |
| Retry logic on a non-idempotent endpoint | Make the endpoint idempotent first, then add retries | Retrying non-idempotent operations causes duplicate side effects |
| No expiration on idempotency keys | Add TTL-based expiration | Unbounded key storage grows forever and wastes resources |

---

## See Also

- [Resilience Patterns](../resilience-patterns/resilience-patterns.md) – Circuit breakers and fallbacks
- [API Design](../api-design/api-design.md) – Designing consistent interfaces
- [Error Handling](../error-handling/error-handling.md) – Handling failures gracefully
- [Concurrency & Async Patterns](../concurrency-async/concurrency-async.md) – Safe retry under concurrency
