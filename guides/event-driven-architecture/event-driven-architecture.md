# Event-Driven Architecture

Best practices for designing systems around events — contracts, delivery semantics, replay safety, and clear boundaries between producers and consumers.

> **Scope**: Covers event-driven design for services, workflows, and internal platforms using queues, streams, or broker-based messaging. Focus is broader than sagas: event contracts, when to publish events, consumer design, versioning, and replay behavior.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [When to Use Events](#when-to-use-events) |
| [Event Contract Design](#event-contract-design) |
| [Delivery Semantics](#delivery-semantics) |
| [Idempotent Consumers](#idempotent-consumers) |
| [Replay and Versioning](#replay-and-versioning) |
| [Events vs Direct Calls vs Orchestration](#events-vs-direct-calls-vs-orchestration) |
| [Anti-Patterns](#anti-patterns) |
| [Red Flags](#red-flags) |
| [Checklist](#checklist) |
| [See Also](#see-also) |

---

## Quick Reference

| Topic | Prefer | Avoid |
| --- | --- | --- |
| **Event names** | Business facts like `order.shipped` | Transport-specific names like `queue_message_17` |
| **Contracts** | Versioned envelopes with IDs and timestamps | Free-form JSON blobs |
| **Delivery** | Design for at-least-once delivery | Assuming exactly-once by default |
| **Consumers** | Idempotent handlers with dedupe keys | Side effects with no replay protection |
| **Ownership** | One producer owns the schema | Shared mutation by many teams |

| Rule | Rationale |
| --- | --- |
| Publish facts, not commands in disguise | Events should describe what happened |
| Include enough metadata to debug and replay | Missing IDs and timestamps cripple recovery |
| Make consumers independently safe | Retries and replays are normal, not exceptional |
| Version contracts deliberately | Silent payload drift breaks consumers slowly |
| Choose events only when decoupling is worth the operational cost | Event-driven systems add latency and debugging overhead |

---

## Core Principles

1. **Events are contracts** — Treat every published event as a public interface.
2. **At-least-once is the safe default** — Consumers must tolerate duplicate delivery.
3. **Business meaning beats transport detail** — Name and structure events around domain facts.
4. **Replay is a feature, not an accident** — Design consumers and storage for reprocessing.
5. **Decoupling is not free** — Use events where loose coupling is worth eventual consistency and observability complexity.

---

## When to Use Events

| Situation | Use events? | Why |
| --- | --- | --- |
| One action triggers many downstream reactions | Yes | Fan-out without hard dependencies |
| Producer should not block on all consumers | Yes | Asynchronous decoupling |
| Workflow requires immediate, synchronous response | No | Direct call is simpler |
| One coordinator must enforce global ordering | Maybe not | Orchestration may be clearer |
| Consumers need independent retry/replay | Yes | Events preserve recoverability |

| Good fit | Weak fit |
| --- | --- |
| Audit trails, notifications, cache invalidation, analytics, async enrichment | Single request/response CRUD, tightly ordered transactions, low-latency reads |

---

## Event Contract Design

Use explicit envelopes with stable metadata and a versioning strategy.

**Bad: payload with no identity, time, or version**

```json
{
  "type": "user_update",
  "data": {
    "id": 42,
    "email": "new@example.com"
  }
}
```

**Good: business event with versioned envelope**

```json
{
  "event_id": "evt_01HTY1CK3P0W7T4A7P2R8JQ4Q9",
  "event_type": "user.email_changed",
  "event_version": 2,
  "occurred_at": "2026-04-20T14:05:00Z",
  "producer": "identity-service",
  "trace_id": "req_9f2d1c",
  "subject_id": "user_42",
  "data": {
    "old_email": "old@example.com",
    "new_email": "new@example.com"
  }
}
```

| Field | Why it matters |
| --- | --- |
| `event_id` | Dedupe, tracing, and replay safety |
| `event_type` | Stable routing key for consumers |
| `event_version` | Contract evolution without silent breakage |
| `occurred_at` | Ordering and incident reconstruction |
| `producer` | Ownership and escalation path |
| `trace_id` | Correlates distributed workflows |

---

## Delivery Semantics

| Delivery model | Practical meaning | Consumer requirement |
| --- | --- | --- |
| **At-most-once** | Message may be lost | Only acceptable for low-value telemetry |
| **At-least-once** | Message may be delivered more than once | Default for business events; consumers must dedupe |
| **Exactly-once** | Usually broker-scoped and expensive | Verify carefully before claiming it end-to-end |

| Question | Guidance |
| --- | --- |
| Can the producer retry? | Yes, but emit stable IDs |
| Can the broker redeliver? | Assume yes |
| Can the consumer crash mid-side-effect? | Make the side-effect idempotent or transactional |
| Can order change across partitions? | Design handlers to tolerate it unless strict ordering is guaranteed |

---

## Idempotent Consumers

Consumers must tolerate retries, duplicates, and replay.

**Bad: duplicate delivery doubles the side effect**

```python
def handle_order_paid(event):
    db.execute(
        "INSERT INTO invoices (order_id, amount) VALUES (?, ?)",
        [event["data"]["order_id"], event["data"]["amount"]],
    )
    email.send_receipt(event["data"]["customer_email"])
```

**Good: dedupe key and guarded side effects**

```python
def handle_order_paid(event):
    already_processed = db.fetch_one(
        "SELECT 1 FROM processed_events WHERE event_id = ?",
        [event["event_id"]],
    )
    if already_processed:
        return

    with db.transaction():
        db.execute(
            "INSERT INTO invoices (order_id, amount) VALUES (?, ?)",
            [event["data"]["order_id"], event["data"]["amount"]],
        )
        db.execute(
            "INSERT INTO processed_events (event_id, processed_at) VALUES (?, NOW())",
            [event["event_id"]],
        )

    email.send_receipt(event["data"]["customer_email"])
```

| Pattern | Use |
| --- | --- |
| **Processed-event table** | Default for relational consumers |
| **Idempotency key on write API** | Good when consumer calls another service |
| **Upsert by natural key** | Good for read models and projections |
| **Commutative updates** | Useful for counters and aggregates |

---

## Replay and Versioning

| Concern | Practice | Why |
| --- | --- | --- |
| **Replay** | Keep handlers deterministic and side effects guarded | Allows rebuilding projections safely |
| **Schema change** | Add fields before removing fields | Minimizes consumer breakage |
| **Breaking changes** | Publish a new event version or type | Consumers need explicit migration points |
| **Retention** | Document replay window and retention policy | Operators need to know what recovery is possible |

| Versioning pattern | When to use |
| --- | --- |
| `event_version` field | Same conceptual event with additive evolution |
| New event type | Semantics changed, not just shape |
| Upcaster or adapter | Old events must be replayable into a new handler model |

---

## Events vs Direct Calls vs Orchestration

| Need | Direct call | Event | Orchestrator |
| --- | --- | --- | --- |
| Immediate response | Best | Poor fit | Depends |
| Loose coupling | Weak | Best | Moderate |
| Ordered multi-step workflow | Weak | Moderate | Best |
| Simple operational model | Best | Weak | Moderate |
| Fan-out to many consumers | Weak | Best | Moderate |

| If the question is... | Prefer |
| --- | --- |
| "Do I need the answer before returning?" | Direct call |
| "Do multiple independent systems react later?" | Event |
| "Does one coordinator own the workflow state?" | Orchestrator |

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| --- | --- | --- |
| **Commands disguised as events** | Consumers become tightly coupled to producer intent | Publish domain facts instead |
| **Schema by convention** | Breaks silently across teams | Version and document contracts |
| **No dedupe strategy** | Retries create double side effects | Make consumers idempotent |
| **Everything is an event** | Debugging and latency spiral | Use direct calls where synchronous coupling is acceptable |
| **Undocumented replay behavior** | Operators do not know what recovery is safe | Publish replay and retention policy |

---

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| Event payloads differ by producer deployment with no version bump | Freeze rollout and add explicit versioning | Silent schema drift breaks consumers slowly |
| A consumer cannot explain what happens on duplicate delivery | Treat it as unsafe until dedupe exists | Duplicate delivery is normal in practice |
| Teams claim "exactly-once" end-to-end with no proof | Reframe design around at-least-once semantics | End-to-end exactly-once is rarely true |
| Broker topic mixes unrelated event types | Split by domain or add stable routing envelope | Mixed streams create ambiguous consumers |
| Event names reflect implementation details, not business facts | Rename the contract before wide adoption | Bad names lock in bad mental models |

---

## Checklist

- [ ] Event names describe business facts
- [ ] Contracts include IDs, timestamps, producer, and version
- [ ] Delivery semantics are documented explicitly
- [ ] Consumers are idempotent under replay and duplicate delivery
- [ ] Replay and retention policy is documented
- [ ] Direct calls and orchestrators were considered before choosing events

---

## See Also

- [Distributed Sagas](../distributed-sagas/distributed-sagas.md) — Multi-step workflows across services
- [Idempotency Patterns](../idempotency-patterns/idempotency-patterns.md) — Safe retry and deduplication
- [Resilience Patterns](../resilience-patterns/resilience-patterns.md) — Handling partial failures
- [API Design](../api-design/api-design.md) — Contract design and versioning
