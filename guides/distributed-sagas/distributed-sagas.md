# Distributed Sagas

Guidelines for coordinating multi-step transactions across services when traditional ACID transactions aren't possible.

> **Scope**: Applies to operations spanning multiple services—order processing, payment flows, booking systems. Agents must ensure eventual consistency and reliable compensation.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [When to Use Sagas](#when-to-use-sagas) |
| [Saga Patterns](#saga-patterns) |
| [Compensation Design](#compensation-design) |
| [Implementation](#implementation) |
| [Anti-Patterns](#anti-patterns) |

---

## Quick Reference

| Category | Guidance | Rationale |
| --- | --- | --- |
| **Always** | Design compensating actions for each step | Enables rollback |
| **Always** | Make steps idempotent | Safe retry on failure |
| **Always** | Persist saga state | Survive crashes |
| **Prefer** | Choreography for simple sagas | Lower coupling |
| **Prefer** | Orchestration for complex sagas | Clearer flow |
| **Never** | Leave partial state without compensation | Data inconsistency |
| **Never** | Assume immediate consistency | Embrace eventual |

---

## Core Principles

| Principle | Guideline | Rationale |
| --- | --- | --- |
| **Eventual consistency** | Accept temporary inconsistency | Distributed systems reality |
| **Compensating actions** | Every step has an undo | Enables semantic rollback |
| **Idempotency** | Same request → same result | Safe retries |
| **Isolation** | Minimize cross-saga interference | Reduce conflicts |
| **Persistence** | Saga state survives failures | Reliable recovery |

---

## When to Use Sagas

### Decision Matrix

| Scenario | Use Saga? | Alternative |
| --- | --- | --- |
| Single database | No | ACID transaction |
| Multiple services, must succeed/fail together | Yes | — |
| Long-running (minutes/hours) | Yes | Avoid holding locks |
| Strong consistency required | No | Distributed transaction (2PC) |
| High availability priority | Yes | Accept eventual consistency |

### Example Use Cases

| Domain | Saga Steps |
| --- | --- |
| **Order fulfillment** | Reserve inventory → Charge payment → Ship order |
| **Travel booking** | Book flight → Book hotel → Book car |
| **Account creation** | Create user → Create wallet → Send welcome email |
| **Money transfer** | Debit source → Credit destination |

---

## Saga Patterns

### Choreography

Services react to events autonomously. Good for simple sagas.

```text
Order      Inventory    Payment     Shipping
  │            │            │            │
  ├──OrderCreated──►        │            │
  │            ├─InventoryReserved─►     │
  │            │            ├─PaymentCharged─►
  │            │            │            │
  ◄────────────────────────OrderShipped──┤
```

| Pros | Cons |
| --- | --- |
| Loose coupling | Hard to track flow |
| Simple to add services | Cyclic dependencies risk |
| No central point of failure | Difficult debugging |

### Orchestration

Central coordinator directs each step. Good for complex sagas.

```text
         ┌─────────────┐
         │ Orchestrator│
         └──────┬──────┘
                │
    ┌───────────┼───────────┐
    ▼           ▼           ▼
┌───────┐  ┌────────┐  ┌────────┐
│Inventory│ │Payment │ │Shipping│
└───────┘  └────────┘  └────────┘
```

| Pros | Cons |
| --- | --- |
| Clear flow | Central point of failure |
| Easy to understand | Tighter coupling to orchestrator |
| Simpler debugging | Can become complex |

---

## Compensation Design

### Compensation Types

| Step Type | Compensation | Example |
| --- | --- | --- |
| Reservable | Release | Release inventory hold |
| Pivot point | None (point of no return) | Credit card charged |
| Retriable | Retry until success | Send notification |
| Compensatable | Undo action | Refund payment |

### Compensation Order

Execute compensations in reverse order of successful steps.

```text
Step 1: Reserve inventory ──► Compensation: Release inventory
Step 2: Charge payment    ──► Compensation: Refund payment
Step 3: Create shipment   ──► Compensation: Cancel shipment

If Step 3 fails:
  Execute: Cancel shipment (maybe no-op)
  Execute: Refund payment
  Execute: Release inventory
```

### Semantic Rollback

Compensation may not be exact undo—it's "make right."

```python
# Original action
def charge_payment(order):
    transaction = payment_service.charge(order.total)
    return transaction.id

# Compensation (not just "undo")
def compensate_payment(transaction_id, reason):
    # May include additional business logic
    refund = payment_service.refund(transaction_id)
    notification_service.send_refund_notice(refund, reason)
    return refund.id
```

---

## Implementation

### Saga State Machine

```python
from enum import Enum

class SagaState(Enum):
    STARTED = "started"
    INVENTORY_RESERVED = "inventory_reserved"
    PAYMENT_CHARGED = "payment_charged"
    SHIPPING_CREATED = "shipping_created"
    COMPLETED = "completed"
    COMPENSATING = "compensating"
    COMPENSATED = "compensated"
    FAILED = "failed"

class OrderSaga:
    def __init__(self, order_id: str):
        self.order_id = order_id
        self.state = SagaState.STARTED
        self.completed_steps = []
    
    def execute(self):
        try:
            self._reserve_inventory()
            self._charge_payment()
            self._create_shipment()
            self.state = SagaState.COMPLETED
        except SagaStepError as e:
            self._compensate()
            raise
    
    def _compensate(self):
        self.state = SagaState.COMPENSATING
        # Reverse order compensation
        for step in reversed(self.completed_steps):
            step.compensate()
        self.state = SagaState.COMPENSATED
```

### Persistent State Store

```python
# Good: Persistent saga state for crash recovery
class SagaRepository:
    def save(self, saga: OrderSaga) -> None:
        self.db.upsert("sagas", {
            "id": saga.order_id,
            "state": saga.state.value,
            "completed_steps": [s.name for s in saga.completed_steps],
            "updated_at": datetime.now()
        })
    
    def load(self, saga_id: str) -> OrderSaga:
        data = self.db.get("sagas", saga_id)
        saga = OrderSaga(saga_id)
        saga.state = SagaState(data["state"])
        saga.completed_steps = self._reconstruct_steps(data["completed_steps"])
        return saga
```

### Recovery Process

```python
# Startup: Resume incomplete sagas
def recover_sagas():
    incomplete = saga_repo.find_by_states([
        SagaState.STARTED,
        SagaState.INVENTORY_RESERVED,
        SagaState.PAYMENT_CHARGED,
        SagaState.COMPENSATING
    ])
    
    for saga in incomplete:
        if saga.state == SagaState.COMPENSATING:
            saga.continue_compensation()
        else:
            saga.execute()  # Retry from current step
```

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| --- | --- | --- |
| **Missing compensation** | Partial state on failure | Design compensation for each step |
| **Non-idempotent steps** | Duplicate effects on retry | Make all steps idempotent |
| **In-memory state** | Lost on crash | Persist saga state |
| **Blocking on external** | Saga hangs | Add timeouts and retry |
| **Ignoring failures** | Silent data corruption | Compensate or alert |
| **Tight coupling** | Hard to modify | Use events or orchestrator |

---

## See Also

- [Idempotency Patterns](../idempotency-patterns/idempotency-patterns.md) – Safe retry strategies
- [Resilience Patterns](../resilience-patterns/resilience-patterns.md) – Handling failures
- [Error Handling](../error-handling/error-handling.md) – Error recovery patterns
