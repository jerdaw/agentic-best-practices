# Coding Guidelines for AI Agents

Best practices for AI agents writing code—principles that produce maintainable, correct, and safe code across any language or project.

> **Scope**: These guidelines are for AI agents performing coding tasks. Some practices differ from human conventions due to the agent's context limitations and the human's need to review and maintain the output.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Naming Conventions](#naming-conventions) |
| [Function Design](#function-design) |
| [Control Flow](#control-flow) |
| [Data Handling](#data-handling) |
| [Code Organization](#code-organization) |
| [Constants and Configuration](#constants-and-configuration) |
| [Matching Codebase Patterns](#matching-codebase-patterns) |
| [Avoiding Over-Engineering](#avoiding-over-engineering) |
| [Traceability](#traceability) |
| [Code Review Readiness](#code-review-readiness) |
| [Anti-Patterns](#anti-patterns) |

---

## Quick Reference

### Always

| Guideline | Why |
| --- | --- |
| **Prefer clarity over cleverness** | Code is read more often than written; unclear code hides bugs. |
| **Match existing patterns** | Consistency reduces cognitive load for maintainers. |
| **Handle edge cases explicitly** | AI tends to optimistically ignore nulls/empty states. |
| **Validate inputs at boundaries** | Prevents runtime errors and security vulnerabilities. |
| **Keep functions focused** | Small, single-purpose functions are easier to test and debug. |

### Never

| Anti-Pattern | Impact |
| --- | --- |
| **Unnecessary complexity** | Increases technical debt and maintenance cost. |
| **Magic numbers/strings** | Obscures intent and makes changes error-prone. |
| **Ignored errors** | Causes silent failures and difficult debugging. |
| **Input assumptions** | leads to crashes when data format changes. |
| **Incomplete implementation** | Leaves "TODOs" that break logical flow or user trust. |

### Priority Order

| Priority | Goal | Why |
| :---: | --- | --- |
| 1 | **Correctness** | Valid logic is the baseline requirement. |
| 2 | **Security** | Vulnerabilities are unacceptable risks. |
| 3 | **Clarity** | Humans must understand what the AI wrote. |
| 4 | **Consistency** | Visual integration with the codebase. |
| 5 | **Performance** | Optimization only matters if 1-4 are met. |

---

## Core Principles

| Principle | Rationale |
| --- | --- |
| **Explicit over implicit** | Hidden behavior confuses reviewers. State intentions clearly. |
| **Simple over clever** | "Clever" code is hard to debug. Readable code is durable. |
| **Consistent over novel** | Integrating seamlessly is better than introducing "better" but alien patterns. |
| **Complete over partial** | Handle failures and edge cases, not just the happy path. |
| **Conservative over aggressive** | When uncertain, strict safety checks prevent regressions. |

---

## Naming Conventions

### General Rules

| Element | Convention | Example |
| --- | --- | --- |
| Variables | Descriptive, reveal intent | `remainingAttempts` not `r` |
| Functions | Verb + noun, describe action | `calculateShippingCost` not `calc` |
| Booleans | Question form | `isValid`, `hasPermission`, `canRetry` |
| Constants | Describe the value's meaning | `MAX_RETRY_ATTEMPTS` not `THREE` |
| Collections | Plural nouns | `users`, `orderItems` |

### Naming Quality Checks

| Bad | Good | Why |
| --- | --- | --- |
| `data` | `userProfile` | Reveals what data |
| `temp` | `unprocessedItems` | Reveals purpose |
| `flag` | `isRetryEnabled` | Reveals meaning |
| `result` | `validationErrors` | Reveals content |
| `process()` | `validateAndSaveOrder()` | Reveals what it does |
| `handle()` | `retryFailedRequest()` | Reveals the action |

### Avoid

| Pattern | Problem | Alternative |
| --- | --- | --- |
| Single letters | Unclear meaning | Full descriptive names |
| Abbreviations | Ambiguous | Spell it out |
| Generic names | No information | Specific to context |
| Type in name | Redundant, can drift | Let types speak |
| Negated booleans | Confusing logic | Positive form |

```javascript
// Avoid
const arr = []
const str = ''
const num = 0
const isNotValid = false

// Prefer
const pendingOrders = []
const errorMessage = ''
const retryCount = 0
const isValid = true
```

---

## Function Design

### Size and Focus

| Guideline | Rationale |
| --- | --- |
| One responsibility | Easier to test, understand, reuse |
| < 30 lines preferred | Fits in one screen, reviewable |
| < 5 parameters | More suggests object parameter needed |
| Single return type | Predictable behavior |
| No side effects when possible | Easier to reason about |

### Function Patterns

#### Good: Focused, single responsibility

```javascript
function calculateSubtotal(items) {
  return items.reduce((sum, item) => sum + item.price * item.quantity, 0)
}

function applyDiscount(subtotal, discountPercent) {
  return subtotal * (1 - discountPercent / 100)
}

function calculateTax(amount, taxRate) {
  return amount * taxRate
}

function calculateOrderTotal(items, discountPercent, taxRate) {
  const subtotal = calculateSubtotal(items)
  const discounted = applyDiscount(subtotal, discountPercent)
  const tax = calculateTax(discounted, taxRate)
  return discounted + tax
}
```

#### Bad: Doing too much

```javascript
function processOrder(items, discount, tax, user, sendEmail, saveToDb) {
  // Calculates totals AND sends email AND saves to database
  // Too many responsibilities, hard to test
}
```

### Parameter Design

| Pattern | When to Use | Rationale |
| --- | --- | --- |
| **Individual params** | < 3 related params | Simple, type-safe, and self-documenting. |
| **Options object** | Many/optional params | Prevents long, confusing parameter lists. |
| **Builder pattern** | Complex construction | Step-by-step validation of complex objects. |

```javascript
// Too many individual parameters (Avoid)
function createUser(name, email, age, city, country, phone, role, dept) { }

// Better: Options object
function createUser(options) {
  const { name, email, age, location, contact, role } = options
}

// Best for required + optional
function createUser(name, email, options = {}) {
  const { age, location, role = 'user' } = options
}
```

---

## Control Flow

### Conditionals

| Guideline | Rationale/Context |
| --- | --- |
| **Early returns** | Eliminates indentation depth and keeps happy path at bottom. |
| **Positive conditions** | `if (isValid)` is much easier to parse than `if (!isInvalid)`. |
| **No nested ternaries** | Ternaries are for simple assignments; `if/else` is for logic. |
| **Explicit else** | Use when both branches have equal weight or side effects. |

#### Good: Early returns

```javascript
function processPayment(order) {
  if (!order) {
    return { error: 'Order required' }
  }

  if (!order.items.length) {
    return { error: 'Order has no items' }
  }

  if (order.status !== 'pending') {
    return { error: 'Order already processed' }
  }

  // Main logic here, not nested in conditions
  return chargePayment(order)
}
```

#### Bad: Deep nesting

```javascript
function processPayment(order) {
  if (order) {
    if (order.items.length) {
      if (order.status === 'pending') {
        return chargePayment(order)
      } else {
        return { error: 'Order already processed' }
      }
    } else {
      return { error: 'Order has no items' }
    }
  } else {
    return { error: 'Order required' }
  }
}
```

### Loops

| Guideline | Rationale |
| --- | --- |
| Use appropriate iteration method | map for transform, filter for subset, reduce for aggregate |
| Avoid mutating loop variables | Harder to follow state |
| Named callbacks | Clearer than inline |
| Break early when possible | Don't continue unnecessary work |

```javascript
// Good: Named callbacks, appropriate methods
const activeUsers = users.filter(isActiveUser)
const userEmails = activeUsers.map(getUserEmail)
const totalSpend = orders.reduce(sumOrderTotal, 0)

// Avoid: Anonymous callbacks hiding logic
const result = users.filter(u => u.status === 'active' && u.lastLogin > threshold)
  .map(u => ({ email: u.email, name: u.profile?.name || 'Unknown' }))
```

---

## Data Handling

### Immutability Preference

| Pattern | Benefit |
| --- | --- |
| Don't mutate function arguments | Prevents side effects |
| Create new objects/arrays | State changes are explicit |
| Use spread/destructuring | Clear data transformations |

```javascript
// Good: Returns new object
function updateUserEmail(user, newEmail) {
  return { ...user, email: newEmail, updatedAt: new Date() }
}

// Bad: Mutates input
function updateUserEmail(user, newEmail) {
  user.email = newEmail
  user.updatedAt = new Date()
  return user
}
```

### Null and Undefined Handling

| Situation | Approach |
| --- | --- |
| Optional values | Explicit null checks |
| Missing properties | Provide defaults |
| Function returns | Document nullable returns |
| Chains | Guard each step or use optional chaining |

```javascript
// Good: Explicit handling
function getUserDisplayName(user) {
  if (!user) {
    return 'Anonymous'
  }

  if (user.displayName) {
    return user.displayName
  }

  if (user.firstName && user.lastName) {
    return `${user.firstName} ${user.lastName}`
  }

  return user.email || 'Unknown User'
}
```

---

## Code Organization

### File Structure

| Principle | Rationale |
| --- | --- |
| One concept per file | Easier to find, understand |
| Related code together | Reduces cognitive load |
| Public API at top | Easier to understand module |
| Implementation details below | Progressive disclosure |

### Ordering Within Files

| Order | Element | Rationale |
| :---: | --- | --- |
| 1 | **Imports** | Explicitly declares all external dependencies. |
| 2 | **Constants/Config** | Centralized configuration for easy updates. |
| 3 | **Types/Interfaces** | Defines the data contract for the file. |
| 4 | **Public API** | Most important code; should be seen first. |
| 5 | **Implementation** | Private helpers and details follow the "What" before "How". |

### Module Boundaries

| Do | Don't | Rationale |
| --- | --- | --- |
| Export only what's needed | Export everything "just in case" | Maintains a clean API surface area. |
| Clear public interface | Leak implementation details | Encapsulation allows for inner refactoring. |
| Depend on abstractions | Depend on concrete implementations | Improves testability and modularity. |
| Single entry point | Multiple ways to access same functionality | Eliminates ambiguity for consumers. |

---

## Constants and Configuration

### Magic Values

| Bad | Good | Why |
| --- | --- | --- |
| `if (retries > 3)` | `if (retries > MAX_RETRIES)` | Meaning is clear |
| `setTimeout(fn, 5000)` | `setTimeout(fn, CONNECTION_TIMEOUT_MS)` | Intent documented |
| `status === 2` | `status === OrderStatus.SHIPPED` | Self-documenting |

### Configuration Patterns

```javascript
// Good: Named constants with context
const MAX_RETRY_ATTEMPTS = 3
const RETRY_DELAY_MS = 1000
const REQUEST_TIMEOUT_MS = 5000

// Good: Grouped configuration
const RetryConfig = {
  maxAttempts: 3,
  initialDelayMs: 1000,
  maxDelayMs: 30000,
  backoffMultiplier: 2
}

// Bad: Magic numbers inline
while (attempts < 3) {
  await sleep(1000 * Math.pow(2, attempts))
}
```

---

## Matching Codebase Patterns

### Before Writing Code

| Check | Why |
| --- | --- |
| Existing similar functionality | Maintain consistency |
| Naming conventions used | Match the style |
| Error handling patterns | Use same approach |
| File organization | Put code where expected |
| Test patterns | Match testing style |

### Pattern Matching Rules

| If codebase uses | Then use |
| --- | --- |
| callbacks | callbacks (not promises) |
| promises | promises (not async/await) |
| async/await | async/await |
| classes | classes |
| functional style | functions |
| snake_case | snake_case |
| camelCase | camelCase |

### When Patterns Conflict

| Situation | Action |
| --- | --- |
| Codebase inconsistent | Match the nearest/most recent code |
| Pattern is clearly outdated | Ask before modernizing |
| Pattern is dangerous | Note concern, follow instructions |

---

## Avoiding Over-Engineering

### Signs of Over-Engineering

| Pattern | Problem |
| --- | --- |
| Premature abstraction | Abstracts before pattern repeats |
| Excessive indirection | Many layers to follow |
| Configuration for hypotheticals | Handles cases that don't exist |
| Generic solution for specific problem | More complex than needed |

### Right-Sizing Guidelines

| Situation | Approach |
| --- | --- |
| First implementation | Concrete, specific, minimal |
| Second similar case | Consider extraction if obvious |
| Third similar case | Now abstract if beneficial |
| Hypothetical future need | Don't build for it yet |

```javascript
// Over-engineered: Factory for one type (Avoid)
class UserNotificationStrategyFactory {
  createStrategy(type) {
    const strategies = { email: new EmailStrategy() }
    return strategies[type]
  }
}

// Right-sized: Just send the email
function sendUserNotification(user, message) {
  return sendEmail(user.email, message)
}
```

---

## Traceability

Include references that connect code changes to their context.

### Reference Patterns

| Reference Type | When to Include | Format | Rationale |
| --- | --- | --- | --- |
| **Issue/ticket** | Bug fixes, features | `// Fixes #123` | Connects code directly to the original requirement. |
| **Commit SHA** | Reverts, related changes | `// Reverts abc1234` | Provides audit trail for history-sensitive changes. |
| **File path** | Cross-file dependencies | `// See validator.ts` | Explains external logic without duplication. |
| **Line reference** | Specific locations | `// Related: auth.ts:45` | Pinpoints relevant logic in other files. |
| **Documentation** | Non-obvious requirements | `// Per RFC-7231` | Justifies complex logic with external standards. |

### When Traceability Matters

| Context | Traceability Level | Rationale |
| --- | --- | --- |
| Bug fixes | High—link to issue | Future maintainers need to know *why* specific logic exists. |
| Security patches | High—link to CVE/advisory | Auditable proof of mitigation. |
| Feature work | Medium—link to spec/ticket | Connects code to requirements. |
| Refactoring | Low—commit message sufficient | Code structure usually explains itself. |
| Trivial changes | None needed | Noise reduction. |

### Examples

```typescript
// Good: Links change to context
// Fixes #456: Handle null user in formatName
function formatName(user: User | null): string {
  if (!user) return 'Unknown'  // #456: Added null check
  return `${user.firstName} ${user.lastName}`
}

// Good: References related code
// Validation rules mirror src/api/validators.ts:validateEmail
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

// Good: Links to external requirement
// Token expiry per OAuth 2.0 spec (RFC 6749, Section 4.2.2)
const TOKEN_EXPIRY_SECONDS = 3600
```

### Avoid Over-Referencing

```javascript
// Too much: Every line referenced (Avoid)
function add(a, b) {  // #100: Created add function
  const sum = a + b   // #100: Calculate sum
  return sum          // #100: Return result
}

// Right amount: One reference for the change
// Implements #100: Basic math utilities
function add(a, b) {
  return a + b
}
```

---

## Code Review Readiness

### Self-Review Checklist

Before submitting code, verify:

| Check | Why/Fix |
| --- | --- |
| **Names are clear and descriptive** | If you need to explain the name, rename it. |
| **Functions have single responsibility** | Split complex functions into helpers. |
| **Edge cases handled** | Check nulls, empty lists, infinite loops. |
| **No magic numbers or strings** | Extract to named constants. |
| **Matches codebase patterns** | Don't introduce alien styles (e.g., classes in FP code). |
| **No dead/commented code** | Remove unused artifacts before commit. |
| **Error handling is appropriate** | Catch specific errors, don't swallow exceptions. |
| **No security issues** | Validate all external inputs. |
| **Traceability included** | Link to issue IDs for non-obvious logic. |

### Making Code Reviewable

| Practice | Why |
| --- | --- |
| Small, focused changes | Easier to review |
| Clear commit messages | Context for changes |
| Separate refactoring | Don't mix with features |
| Note areas of concern | Guide reviewer attention |

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| --- | --- | --- |
| **Clever code** | Hard to understand and maintain | Simple and obvious |
| **Copy-paste with tweaks** | Duplicates bugs, hard to update | Extract shared logic |
| **God functions** | Do too much, untestable | Split by responsibility |
| **Stringly typed** | No compiler help, runtime errors | Use types/enums |
| **Boolean parameters** | Unclear at call site | Options object or separate functions |
| **Deep nesting** | Hard to follow | Early returns, extraction |
| **Premature optimization** | Complexity without benefit | Profile first, then optimize |
| **Incomplete implementation** | TODO left behind | Complete or note clearly |

---

## See Also

- [Error Handling](../error-handling/error-handling.md) – Handling errors properly
- [Commenting Guidelines](../commenting-guidelines/commenting-guidelines.md) – When and how to comment
- [Documentation Guidelines](../documentation-guidelines/documentation-guidelines.md) – Documenting code
