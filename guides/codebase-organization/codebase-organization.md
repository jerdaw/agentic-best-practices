# Codebase Organization

Guidelines for structuring projects to be navigable, maintainable, and scalable.

> **Scope**: Applies to any codebase—backend services, web apps, libraries. Agents must create consistent, predictable structures that developers can navigate without guidance.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Directory Structure](#directory-structure) |
| [Module Organization](#module-organization) |
| [Layered Architecture](#layered-architecture) |
| [Dependency Direction](#dependency-direction) |
| [Anti-Patterns](#anti-patterns) |

---

## Quick Reference

| Category | Guidance | Rationale |
| --- | --- | --- |
| **Always** | Group by feature/domain, not by type | Co-locate related code |
| **Always** | Keep entry points obvious | `main.py`, `index.ts`, `cmd/` |
| **Always** | Separate business logic from infrastructure | Enables testing and swapping |
| **Prefer** | Flat over deeply nested structures | Easier navigation |
| **Prefer** | Explicit imports over magic | Traceable dependencies |
| **Never** | Mix layers (UI → DB directly) | Tight coupling, untestable |
| **Never** | Create god classes/modules | Single responsibility violation |
| **Never** | Scatter related code across tree | Reduces discoverability |

---

## Core Principles

| Principle | Guideline | Rationale |
| --- | --- | --- |
| **Screaming architecture** | Structure reveals purpose | Navigate without documentation |
| **Feature cohesion** | Related code lives together | Change locality |
| **Explicit dependencies** | Imports state requirements | No hidden coupling |
| **Layered boundaries** | Clear separation of concerns | Testable, swappable |
| **Consistent conventions** | Same patterns everywhere | Reduced cognitive load |

---

## Directory Structure

### By Feature (Recommended)

Group code by business domain, not technical role.

```text
src/
├── users/
│   ├── user_service.py
│   ├── user_repository.py
│   ├── user_controller.py
│   └── user_test.py
├── orders/
│   ├── order_service.py
│   ├── order_repository.py
│   ├── order_controller.py
│   └── order_test.py
├── shared/
│   ├── database.py
│   └── auth.py
└── main.py
```

| Advantage | Why |
| --- | --- |
| Change locality | Feature changes touch one directory |
| Team ownership | Teams own domains, not layers |
| Deletability | Remove feature by deleting folder |
| Discoverability | Feature code is co-located |

### By Layer (Avoid for Large Projects)

```text
# Avoid: Scatters related code
src/
├── controllers/
│   ├── user_controller.py
│   └── order_controller.py
├── services/
│   ├── user_service.py
│   └── order_service.py
├── repositories/
│   ├── user_repository.py
│   └── order_repository.py
```

| Disadvantage | Why |
| --- | --- |
| Change scatter | Feature changes touch many directories |
| Coupling temptation | Easy to share too much |
| Navigation overhead | Jump between folders constantly |

---

## Module Organization

### File Sizing Guidelines

| Size | Action | Rationale |
| --- | --- | --- |
| <200 lines | Keep as is | Easily digestible |
| 200-500 lines | Consider splitting | Getting complex |
| >500 lines | Split required | Too much cognitive load |

### Single Responsibility per File

```python
# Good: One focused module
# user_service.py
class UserService:
    def create_user(self, data): ...
    def get_user(self, id): ...
    def update_user(self, id, data): ...
```

```python
# Bad: Kitchen sink module
# utils.py
def format_date(): ...
def send_email(): ...
def validate_user(): ...
def calculate_tax(): ...
def generate_pdf(): ...
```

### Public API Surface

```python
# Good: Explicit exports via __init__.py
# users/__init__.py
from .user_service import UserService
from .user_model import User

# External code imports from package
from users import UserService, User
```

---

## Layered Architecture

### Standard Layers

| Layer | Responsibility | Depends On |
| --- | --- | --- |
| **Presentation** | HTTP handlers, CLI, UI | Application |
| **Application** | Use cases, orchestration | Domain |
| **Domain** | Business logic, entities | Nothing (pure) |
| **Infrastructure** | Database, external APIs | Domain interfaces |

### Layer Boundaries

```text
┌─────────────────────────────────────┐
│           Presentation              │
│   (Controllers, Routes, CLI)        │
└─────────────────┬───────────────────┘
                  │ calls
                  ▼
┌─────────────────────────────────────┐
│           Application               │
│   (Use Cases, Services)             │
└─────────────────┬───────────────────┘
                  │ uses
                  ▼
┌─────────────────────────────────────┐
│             Domain                  │
│   (Entities, Business Rules)        │
└─────────────────────────────────────┘
                  ▲
                  │ implements
┌─────────────────────────────────────┐
│          Infrastructure             │
│   (Database, APIs, File System)     │
└─────────────────────────────────────┘
```

### Implementation Example

```python
# domain/user.py - Pure, no dependencies
class User:
    def __init__(self, id: str, email: str):
        self.id = id
        self.email = email
    
    def can_access(self, resource: str) -> bool:
        # Business rule: pure logic
        return resource in self.permissions

# domain/user_repository.py - Interface only
class UserRepository(Protocol):
    def find_by_id(self, id: str) -> User | None: ...
    def save(self, user: User) -> None: ...

# infrastructure/postgres_user_repository.py - Implementation
class PostgresUserRepository(UserRepository):
    def __init__(self, db: Database):
        self.db = db
    
    def find_by_id(self, id: str) -> User | None:
        row = self.db.query("SELECT * FROM users WHERE id = %s", id)
        return User(**row) if row else None
```

---

## Dependency Direction

### The Dependency Rule

> Dependencies point inward. Inner layers know nothing about outer layers.

| Layer | Can Depend On | Cannot Depend On |
| --- | --- | --- |
| Presentation | Application, Domain | — |
| Application | Domain | Presentation, Infrastructure |
| Domain | Nothing | All outer layers |
| Infrastructure | Domain (interfaces) | Application, Presentation |

### Dependency Inversion

```python
# Good: Application depends on abstraction
class OrderService:
    def __init__(self, payment_gateway: PaymentGateway):  # Interface
        self.payment_gateway = payment_gateway
    
    def checkout(self, order: Order):
        self.payment_gateway.charge(order.total)

# Infrastructure implements the abstraction
class StripePaymentGateway(PaymentGateway):
    def charge(self, amount: Decimal):
        stripe.Charge.create(amount=amount)
```

```python
# Bad: Application depends on concrete implementation
class OrderService:
    def __init__(self):
        self.stripe = stripe.Client(api_key="...")  # Tight coupling
    
    def checkout(self, order: Order):
        self.stripe.Charge.create(amount=order.total)
```

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| --- | --- | --- |
| **God module** | One file does everything | Split by responsibility |
| **Circular imports** | A imports B imports A | Extract shared code to third module |
| **Layer skipping** | Controller → Database directly | Enforce layer boundaries |
| **Deep nesting** | `src/a/b/c/d/e/f/file.py` | Flatten or restructure |
| **Type-based grouping** | `controllers/`, `services/` | Group by feature instead |
| **Shared global state** | Modules modify globals | Pass dependencies explicitly |
| **Utils junk drawer** | Unrelated code in one file | Split into focused modules |

---

## See Also

- [Coding Guidelines](../coding-guidelines/coding-guidelines.md) – Code style and conventions
- [Documentation Guidelines](../documentation-guidelines/documentation-guidelines.md) – Documenting architecture
- [API Design](../api-design/api-design.md) – Interface boundaries
