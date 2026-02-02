# Testing Strategy

Guidelines for building reliable test suites that catch bugs without slowing development.

> **Scope**: Applies to all test types—unit, integration, end-to-end. Agents must write tests that verify behavior, not implementation, and maintain appropriate coverage.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Test Pyramid](#test-pyramid) |
| [Test Types](#test-types) |
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

## See Also

- [Testing AI-Generated Code](../testing-ai-generated-code/testing-ai-generated-code.md) – Testing AI output
- [Coding Guidelines](../coding-guidelines/coding-guidelines.md) – Code structure patterns
- [Error Handling](../error-handling/error-handling.md) – Testing error paths
