# Testing Strategy

Guidelines for building reliable test suites that catch bugs without slowing development.

> **Scope**: Applies to all test types—unit, integration, end-to-end. Agents must write tests that verify behavior,
> not implementation, and maintain appropriate coverage.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Test Pyramid](#test-pyramid) |
| [Test Types](#test-types) |
| [Integration Environment Realism](#integration-environment-realism) |
| [Contract Testing Placement](#contract-testing-placement) |
| [Environment Matrix](#environment-matrix) |
| [Coverage Guidelines](#coverage-guidelines) |
| [Test Design](#test-design) |
| [Test Organization](#test-organization) |
| [Anti-Patterns](#anti-patterns) |

---

## Quick Reference

| Category | Guidance | Rationale |
| --- | --- | --- |
| **Always** | Test behavior, not implementation | Tests survive refactoring |
| **Always** | Make tests deterministic | Flaky tests erode trust |
| **Always** | Write tests for bug fixes | Prevent regressions |
| **Prefer** | Many unit tests, few E2E tests | Fast feedback, manageable cost |
| **Prefer** | Readable tests over DRY tests | Tests are documentation |
| **Prefer** | Fakes over mocks where possible | More realistic behavior |
| **Never** | Test private methods directly | Implementation detail |
| **Never** | Share mutable state between tests | Non-deterministic failures |
| **Never** | Skip tests without tracking issue | Tech debt accumulates |

---

## Core Principles

| Principle | Guideline | Rationale |
| --- | --- | --- |
| **Testing pyramid** | More unit tests than integration, more integration than E2E | Balances speed and confidence |
| **Test behavior** | Verify what code does, not how | Enables safe refactoring |
| **Fast feedback** | Tests run quickly, fail loudly | Developers run them often |
| **Deterministic** | Same inputs → same results | No flakes, no false failures |
| **Isolated** | Tests don't affect each other | Order-independent execution |

---

## Test Pyramid

| Layer | Quantity | Speed | Scope | Cost to Maintain |
| --- | --- | --- | --- | --- |
| **E2E/UI** | Few (10s) | Slow (minutes) | Full system | High |
| **Integration** | Some (100s) | Medium (seconds) | Components | Medium |
| **Unit** | Many (1000s) | Fast (milliseconds) | Functions | Low |

### Distribution Targets

| Codebase Type | Unit | Integration | E2E |
| --- | --- | --- | --- |
| Library/SDK | 80% | 15% | 5% |
| Backend API | 60% | 30% | 10% |
| Web Application | 50% | 30% | 20% |

---

## Test Types

### Unit Tests

Test individual functions or classes in isolation.

```python
# Good: Tests behavior, uses clear inputs/outputs
def test_calculate_discount_applies_percentage():
    order = Order(subtotal=100.00)
    discount = calculate_discount(order, percentage=10)
    assert discount == 10.00

def test_calculate_discount_caps_at_maximum():
    order = Order(subtotal=1000.00)
    discount = calculate_discount(order, percentage=50, max_discount=100)
    assert discount == 100.00
```

```python
# Bad: Tests implementation details
def test_calculate_discount_calls_helper():
    with patch('module.internal_helper') as mock:
        calculate_discount(order, 10)
        mock.assert_called_once()  # Breaks if implementation changes
```

### Integration Tests

Test interactions between components (database, APIs, services).

```python
# Good: Tests real database interaction
@pytest.fixture
def test_db():
    db = create_test_database()
    yield db
    db.cleanup()

def test_user_repository_saves_and_retrieves(test_db):
    repo = UserRepository(test_db)
    user = User(email="test@example.com", name="Test")
    
    repo.save(user)
    retrieved = repo.find_by_email("test@example.com")
    
    assert retrieved.name == "Test"
```

### End-to-End Tests

Test complete user flows through the full system.

```python
# Good: Tests critical user journey
def test_checkout_flow_completes_purchase(browser):
    browser.navigate("/products/123")
    browser.click("add-to-cart")
    browser.click("checkout")
    browser.fill("card-number", "4242424242424242")
    browser.click("pay-now")
    
    assert browser.contains("Order confirmed")
    assert Order.count() == 1
```

---

## Integration Environment Realism

Integration tests should run against realistic dependencies (database, queue, cache) rather than mocked protocol stubs when validating wiring behavior.

| Approach | Use when | Tradeoff |
| --- | --- | --- |
| In-memory fakes | Pure domain logic and fast feedback | Lowest realism |
| Containerized dependencies (e.g., Testcontainers) | Repository, migration, and adapter behavior | Higher runtime cost, higher confidence |
| Shared staging environment | Final pre-release confidence | Slowest and highest coordination cost |

```ts
// Good: integration test using ephemeral real dependency
it('persists and retrieves user', async () => {
  const db = await startEphemeralPostgres()
  const repo = new UserRepository(db)

  await repo.save({ email: 'test@example.com' })
  const found = await repo.findByEmail('test@example.com')

  expect(found?.email).toBe('test@example.com')
})
```

```ts
// Bad: integration test still mocking persistence
it('persists and retrieves user', async () => {
  const repo = new UserRepository({ save: vi.fn(), findByEmail: vi.fn() })
  // This is effectively a unit test, not an integration test.
})
```

| Realism rule | Guidance |
| --- | --- |
| Test migrations with real engine | Run schema setup and migration tests on same DB family used in prod |
| Test critical adapters with real protocol | Avoid mocking HTTP/DB drivers for integration coverage |
| Keep integration data isolated | Fresh schema/database per test or suite |

---

## Contract Testing Placement

| Contract type | Recommended location | Why |
| --- | --- | --- |
| API producer contract tests | `tests/contract/` or service-level contract suite | Verifies implementation matches published spec |
| Consumer contract tests | Consumer repo CI | Catches integration assumptions early |
| Schema compatibility checks | CI pre-merge gate | Stops breaking changes before merge |

| Contract test should verify | Example |
| --- | --- |
| Response shape and required fields | Endpoint returns required OpenAPI fields |
| Status-code behavior | Error scenarios map to documented codes |
| Backward compatibility | Existing request payloads remain valid |

---

## Environment Matrix

Define expected environments so failures are diagnosable and intentional.

| Test layer | Local default | CI default | Release gate |
| --- | --- | --- | --- |
| Unit | In-process only | Parallelized | Required |
| Integration | Ephemeral local/container dependencies | Containerized services | Required for backend changes |
| Contract | Local optional, CI mandatory | Compare against baseline contract | Required for API changes |
| E2E | Selective smoke | Stable smoke subset | Required for critical user journeys |

| Matrix rule | Policy |
| --- | --- |
| Any environment-specific skip | Must include issue reference and expiry date |
| New dependency added | Update matrix and CI provisioning in same PR |
| Flaky environment test | Triage immediately; do not silently quarantine indefinitely |

---

## Coverage Guidelines

### Target Coverage

| Type | Minimum | Target | Rationale |
| --- | --- | --- | --- |
| **Line coverage** | 70% | 80% | Baseline protection |
| **Branch coverage** | 60% | 75% | Catches conditional logic |
| **Critical paths** | 100% | 100% | Payments, auth, data mutations |

### What to Prioritize

| High Priority | Medium Priority | Low Priority |
| --- | --- | --- |
| Business logic | Utility functions | Generated code |
| Data mutations | Read-only queries | Configuration |
| Security/auth | Error handling | UI styling |
| Payment flows | Integration points | Third-party wrappers |

### Coverage Anti-Patterns

| Pattern | Problem |
| --- | --- |
| 100% coverage mandate | Encourages low-value tests |
| Coverage = quality assumption | Tests may not assert correctly |
| Testing getters/setters | No value added |
| Excluding hard-to-test code | Often hides bugs |

---

## Test Design

### Arrange-Act-Assert (AAA)

```python
# Good: Clear AAA structure
def test_order_total_includes_tax():
    # Arrange
    order = Order(items=[Item(price=100)])
    tax_calculator = TaxCalculator(rate=0.08)
    
    # Act
    total = order.calculate_total(tax_calculator)
    
    # Assert
    assert total == 108.00
```

### Test Naming

| Pattern | Example |
| --- | --- |
| `test_<unit>_<scenario>` | `test_login_with_invalid_password` |
| `test_<unit>_<scenario>_<expected>` | `test_discount_exceeds_max_caps_at_max` |
| `should_<behavior>_when_<condition>` | `should_reject_when_password_too_short` |

### Test Data

```python
# Good: Explicit test data, minimal fixtures
def test_user_age_calculation():
    user = User(birth_date=date(1990, 1, 15))
    assert user.age_on(date(2024, 1, 15)) == 34

# Good: Builder pattern for complex objects
def test_order_with_discount():
    order = OrderBuilder().with_item(100).with_discount(10).build()
    assert order.total == 90
```

```python
# Bad: Magic fixtures with hidden setup
def test_order_total(default_order):  # What's in default_order?
    assert default_order.total == 90  # Why 90?
```

---

## Test Organization

### File Structure

```text
src/
  orders/
    order.py
    order_service.py
tests/
  unit/
    orders/
      test_order.py
      test_order_service.py
  integration/
    test_order_repository.py
  e2e/
    test_checkout_flow.py
```

### Test Configuration

```python
# pytest.ini or pyproject.toml
[tool.pytest.ini_options]
markers = [
    "unit: Fast, isolated tests",
    "integration: Tests with external systems",
    "e2e: Full system tests",
    "slow: Tests taking >1s",
]
testpaths = ["tests"]
```

```bash
# Run only unit tests (fast feedback)
pytest -m unit

# Run full suite (CI)
pytest
```

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| --- | --- | --- |
| **Ice cream cone** | Too many E2E, few unit tests | Invert the pyramid |
| **Mocking everything** | Tests don't reflect reality | Use real implementations or fakes |
| **Shared mutable state** | Test order matters | Isolate each test |
| **Testing implementation** | Tests break on refactoring | Test behavior and outcomes |
| **Ignoring flaky tests** | Erodes trust in suite | Fix or delete immediately |
| **No assertions** | Test passes but proves nothing | Every test needs assertions |
| **Copy-paste tests** | Hard to maintain | Extract builders/helpers |
| **Skipped tests pile up** | Unknown coverage gaps | Track in issues, clean regularly |

---

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| Feature shipped with zero tests | Write tests before or immediately after deployment | Untested features break silently and compound risk over time |
| Tests break on every refactor without behavior change | Rewrite to test behavior, not implementation | Brittle tests slow development and erode trust in the suite |
| Integration tests skipped "because they're slow" | Optimize or run in CI, but don't skip | Unit tests alone miss boundary and wiring bugs |
| Test suite takes 30+ minutes to run | Parallelize, split, or identify bottlenecks | Slow suites get skipped, reducing their value to zero |
| Flaky test ignored with `skip` annotation | Fix the root cause or delete the test | Skipped tests accumulate and hide real failures |

---

## See Also

- [Testing AI-Generated Code](../testing-ai-code/testing-ai-code.md) – Testing AI output
- [E2E Testing](../e2e-testing/e2e-testing.md) – End-to-end testing patterns
- [Coding Guidelines](../coding-guidelines/coding-guidelines.md) – Code structure patterns
- [Error Handling](../error-handling/error-handling.md) – Testing error paths
