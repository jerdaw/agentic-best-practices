---
name: testing
description: Use when writing tests, designing test strategy, or verifying AI-generated code
---

# Testing

**Announce at start:** "Following the testing skill for test design."

## Core Rule

**Test behavior, not implementation.** Tests must survive refactoring.

## Test Pyramid

Write tests in this ratio:

| Layer | Quantity | Speed | Focus |
| --- | --- | --- | --- |
| **Unit** | Many (1000s) | Fast (ms) | Individual functions/classes |
| **Integration** | Some (100s) | Medium (s) | Component interactions |
| **E2E** | Few (10s) | Slow (min) | Full user flows |

## Writing Tests

### 1. Structure: Arrange-Act-Assert

Every test follows AAA:

```python
def test_order_total_includes_tax():
    # Arrange
    order = Order(items=[Item(price=100)])
    tax = TaxCalculator(rate=0.08)

    # Act
    total = order.calculate_total(tax)

    # Assert
    assert total == 108.00
```

### 2. Naming: Describe Behavior

| Pattern | Example |
| --- | --- |
| `test_<unit>_<scenario>` | `test_login_with_invalid_password` |
| `test_<unit>_<scenario>_<expected>` | `test_discount_exceeds_max_caps_at_max` |

### 3. Data: Explicit, Not Magic

- Use explicit test data in each test
- Avoid shared fixtures with hidden setup
- Use builder patterns for complex objects

## Coverage Priorities

| Priority | What to Test |
| --- | --- |
| **High** | Business logic, data mutations, security/auth, payments |
| **Medium** | Utility functions, error handling, integration points |
| **Low** | Generated code, configuration, UI styling |

**Critical paths (payments, auth, data mutations) always require 100% coverage.**

## AI-Specific Rules

- [ ] Verify AI-generated tests actually assert something meaningful
- [ ] Check that tests fail when the code is wrong (not just pass when right)
- [ ] Use fakes over mocks where possible — more realistic behavior
- [ ] Never test private methods directly
- [ ] Never share mutable state between tests

## Bug Fix Tests

Every bug fix must include a regression test that:

1. Fails before the fix (proves the bug)
2. Passes after the fix (proves the fix)
3. Prevents recurrence

## Related Skills

| When | Invoke |
| --- | --- |
| Test reveals a bug | [debugging](../debugging/SKILL.md) |
| Need E2E tests specifically | [e2e-testing](../e2e-testing/SKILL.md) |
| Tests pass, ready to submit | [pr-writing](../pr-writing/SKILL.md) |
| Code needs review before tests | [code-review](../code-review/SKILL.md) |

## Deep Reference

For principles, rationale, anti-patterns, and examples:

- `guides/testing-strategy/testing-strategy.md`
- `guides/testing-ai-code/testing-ai-code.md`
