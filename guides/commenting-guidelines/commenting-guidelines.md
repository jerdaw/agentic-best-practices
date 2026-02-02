# Commenting Guidelines for AI Agents

Best practices for AI agents on when and how to write comments—prioritizing self-documenting code while knowing when comments add value.

> **Scope**: These guidelines are for AI agents performing coding tasks. The goal is code that's clear without comments, with comments reserved for genuinely valuable context.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [When to Comment](#when-to-comment) |
| [Self-Documenting Code vs Comments](#self-documenting-code-vs-comments) |
| [Comment Types](#comment-types) |
| [What Not to Comment](#what-not-to-comment) |
| [Documentation Comments for Public APIs](#documentation-comments-for-public-apis) |
| [Maintaining Comments](#maintaining-comments) |
| [Language-Agnostic Patterns](#language-agnostic-patterns) |
| [Comment Quality Checklist](#comment-quality-checklist) |
| [Anti-Patterns](#anti-patterns) |
| [Summary Decision Tree](#summary-decision-tree) |

---

## Quick Reference

### Do Comment

| Situation | Why |
| --- | --- |
| **Why (business rules)** | Explains decisions not visible in the code structure. |
| **Workarounds** | Prevents future maintainers from "fixing" necessary hacks. |
| **Complex algorithms** | Provides a high-level map for difficult logic. |
| **Public API docs** | Consumers cannot see the implementation details. |
| **Warnings** | Prevents subtle but dangerous misuse of code. |

### Don't Comment

| Situation | Why Not |
| --- | --- |
| **What (the code shows)** | Redundant noise that drifts from reality. |
| **How (the code shows)** | Implementation details belong in the code itself. |
| **Obvious behavior** | wasting reader bandwidth on "increment i". |
| **Every function/var** | clutter makes important comments hard to find. |
| **Bad code excuses** | Fix the code instead of apologizing for it. |

### Priority Order

| Priority | Action | Rationale |
| :---: | --- | --- |
| 1 | **Make code self-documenting** | The most robust form of documentation. |
| 2 | **Rename to clarify** | Good names persist better than separate comments. |
| 3 | **Refactor to simplify** | Simple code needs no explanation. |
| 4 | **Add comment** | The fallback when code alone cannot convey intent. |

---

## Core Principles

| Principle | Rationale |
| --- | --- |
| **Code is the source of truth** | Comments can lie or drift; code always executes as written. |
| **Why over what** | "What" is redundant; "Why" adds missing context. |
| **Refactor over explain** | If you have to explain complexity, remove the complexity first. |
| **Maintain with code** | A comment that contradicts the code is worse than no comment. |
| **Less is more** | A high signal-to-noise ratio ensures important comments are read. |

---

## When to Comment

### Comment-Worthy Situations

| Situation | Why Comment | Example |
| --- | --- | --- |
| Business rule | Not obvious from code | `// Tax exempt for orders over $500 per state regulation 12.3` |
| Non-obvious decision | Explains "why this way" | `// Using recursion here because the tree is always < 10 levels` |
| Workaround | Future maintainers need context | `// Workaround for Safari bug #12345, can remove after iOS 18` |
| Performance choice | Trade-off explanation | `// Pre-sorting for O(n) lookup; list is always < 100 items` |
| External dependency | Coupling explanation | `// Format required by Stripe API v3` |
| Warning | Prevent future mistakes | `// WARNING: Order matters here; auth must run before rate limit` |
| TODO with context | Tracked incompleteness | `// TODO(ticket-123): Add retry logic when API supports idempotency` |

### Not Comment-Worthy

| Situation | Why Not | What to Do Instead |
| --- | --- | --- |
| What the code does | Code shows this | Let code speak |
| How it works | Code shows this | Simplify if unclear |
| Variable purpose | Name should tell | Rename variable |
| Function behavior | Name should tell | Rename function |
| Obvious logic | Adds noise | Delete comment |
| Apologizing for bad code | Comment doesn't fix it | Refactor the code |

---

## Self-Documenting Code vs Comments

### Code That Doesn't Need Comments

```javascript
// BAD: Comment explains what code does
// Loop through users and check if any are admins
let hasAdmin = false
for (let i = 0; i < users.length; i++) {
  if (users[i].role === 'admin') {
    hasAdmin = true
    break
  }
}

// GOOD: Code explains itself
const hasAdmin = users.some(user => user.role === 'admin')
```

```javascript
// BAD: Comment explains variable
// The maximum number of times to retry
const n = 3

// GOOD: Name explains itself
const maxRetryAttempts = 3
```

```javascript
// BAD: Comment explains condition
// Check if user can edit the document
if (user.role === 'admin' || user.id === doc.ownerId) {
  // ...
}

// GOOD: Extract to named function
if (canEditDocument(user, doc)) {
  // ...
}

function canEditDocument(user, document) {
  return user.role === 'admin' || user.id === document.ownerId
}
```

### When Code Can't Be Self-Documenting

```javascript
// GOOD: Why comment - business rule not obvious from code
function calculateDiscount(order) {
  // Orders over $500 get 10% off per company policy dated 2024-01
  // This applies before tax calculation
  if (order.subtotal > 500) {
    return order.subtotal * 0.10
  }
  return 0
}
```

```javascript
// GOOD: Why comment - workaround explanation
function parseDate(dateString) {
  // Safari doesn't support 'YYYY-MM-DD' format in Date constructor
  // Must convert to 'YYYY/MM/DD' for cross-browser compatibility
  const safariSafe = dateString.replace(/-/g, '/')
  return new Date(safariSafe)
}
```

---

## Comment Types

### Inline Comments

For explaining a specific line or small block:

```javascript
// GOOD: Explains non-obvious "why"
const timeout = 30000  // 30s matches the load balancer timeout

// BAD: States the obvious
const timeout = 30000  // Set timeout to 30000
```

### Block Comments

For explaining larger sections or complex algorithms:

```javascript
/*
 * Binary search implementation with special handling for duplicates.
 * Returns the FIRST occurrence of the target value.
 *
 * When duplicates exist, we continue searching left even after finding
 * a match to ensure we return the earliest index.
 */
function binarySearchFirst(sortedArray, target) {
  // Implementation...
}
```

### Documentation Comments

For public APIs that others will consume:

```javascript
/**
 * Calculates shipping cost based on weight and destination.
 *
 * @param weight - Package weight in kilograms
 * @param destination - ISO 3166-1 alpha-2 country code
 * @returns Shipping cost in USD, or null if destination not supported
 * @throws {ValidationError} If weight is negative
 *
 * @example
 * calculateShipping(2.5, 'US')  // Returns 15.99
 * calculateShipping(2.5, 'XX')  // Returns null (unsupported)
 */
function calculateShipping(weight, destination) {
  // ...
}
```

### TODO Comments

Always include context and tracking:

```javascript
// GOOD: Actionable with context
// TODO(JIRA-1234): Add caching when traffic exceeds 1000 req/min
// TODO(@username): Refactor after auth service migration

// BAD: No context or tracking
// TODO: fix this
// TODO: make better
```

---

## What Not to Comment

### Obvious Code

```javascript
// BAD: Comment adds no value
i++  // Increment i
users.push(user)  // Add user to users array
return result  // Return the result

// GOOD: No comment needed
i++
users.push(user)
return result
```

### Code That Should Be Refactored

```javascript
// BAD: Comment explaining confusing code
// Calculate the final price with discount and tax
const p = a * (1 - d) * (1 + t)

// GOOD: Refactor to be clear
const discountedAmount = subtotal * (1 - discountRate)
const finalPrice = discountedAmount * (1 + taxRate)
```

### Change Logs

```javascript
// BAD: Change history in comments (use version control)
// Modified by John on 2024-01-15 to add validation
// Modified by Jane on 2024-02-01 to fix null bug

// GOOD: No comment - this is what git is for
```

### Commented-Out Code

```javascript
// BAD: Dead code left as comment
function processOrder(order) {
  // const legacyResult = oldProcessing(order)
  // if (legacyResult.error) {
  //   return handleLegacyError(legacyResult)
  // }
  // return newProcessing(order)
}

// GOOD: Just delete it (git preserves history)
function processOrder(order) {
  return newProcessing(order)
}
```

---

## Documentation Comments for Public APIs

### When to Write Doc Comments

| API Type | Doc Comment? | Rationale |
| --- | --- | --- |
| Public functions/methods | Yes | External consumers need docs |
| Public classes/types | Yes | Part of the contract |
| Internal helpers | Usually no | Code should be clear |
| Private methods | Usually no | Implementation detail |
| Complex algorithms | Yes | High-level explanation helps |

### Doc Comment Structure

```javascript
/**
 * [Brief one-line description]
 *
 * [Optional longer description explaining behavior,
 *  edge cases, or important details]
 *
 * @param paramName - Description of parameter
 * @returns Description of return value
 * @throws {ErrorType} When this error occurs
 *
 * @example
 * // Example usage showing typical case
 * functionName(args)  // Expected result
 */
```

### Good Doc Comments

```javascript
/**
 * Retries a function with exponential backoff.
 *
 * Starts with initialDelay and doubles after each failure,
 * up to maxDelay. Retries only on retryable errors.
 *
 * @param fn - Async function to retry
 * @param options - Retry configuration
 * @param options.maxAttempts - Maximum retry attempts (default: 3)
 * @param options.initialDelay - First retry delay in ms (default: 1000)
 * @param options.maxDelay - Maximum delay between retries (default: 30000)
 * @returns Result of successful function call
 * @throws {MaxRetriesExceededError} After all attempts fail
 *
 * @example
 * const result = await withRetry(
 *   () => fetchData(url),
 *   { maxAttempts: 5, initialDelay: 500 }
 * )
 */
async function withRetry(fn, options = {}) {
  // ...
}
```

---

## Maintaining Comments

### Comments Must Stay Current

| When Code Changes | Comment Action |
| --- | --- |
| Logic changes | Update or remove related comments |
| Refactoring | Review all comments in touched code |
| Bug fix | Check if comment caused confusion |
| Feature addition | Don't add comments just because new code |

### Signs of Stale Comments

| Signal | Problem |
| --- | --- |
| Comment contradicts code | Comment is wrong |
| Comment mentions deleted code | Comment is orphaned |
| Comment references old system | Context is outdated |
| Comment describes behavior code doesn't have | Comment drifted |

---

## Language-Agnostic Patterns

### Universal Comment Styles

| Style | Use For |
| --- | --- |
| `//` or `#` | Inline comments |
| `/* */` or `""" """` | Block comments |
| `/** */` or `///` | Documentation comments |

### Common Markers

| Marker | Meaning | Rationale |
| --- | --- | --- |
| `TODO` | Work to be done | Tracks incomplete tasks without blocking. |
| `FIXME` | Known issue needing fix | Flags bugs that must be addressed soon. |
| `HACK` | Workaround/not ideal | Warns maintainers of fragility. |
| `NOTE` | Important information | Highlights non-obvious context. |
| `WARNING` | Danger or gotcha | Prevents misuse of dangerous code. |
| `OPTIMIZE` | Known performance issue | Marks areas for future speedups. |

---

## Comment Quality Checklist

Before adding a comment, ask:

| Question | Goal/Rationale |
| --- | --- |
| **Can I rename something?** | Self-documenting names are better than comments. |
| **Can I extract a function?** | Small, named functions replace block comments. |
| **Can I restructure?** | Clear flow reduces the need for explanation. |
| **Is it "why" not "what"?** | "What" comments are redundant; "Why" adds value. |
| **Will it drift?** | Avoid commenting on volatile implementation details. |
| **Does it add value?** | If code is obvious, the comment is noise. |

If all refactoring options exhausted and still need explanation → write the comment.

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| --- | --- | --- |
| **Obvious comments** | Noise, ignored over time | Delete them |
| **Commented-out code** | Clutter, git exists | Delete it |
| **Comment instead of refactor** | Code stays bad | Fix the code |
| **Change log comments** | Duplicates version control | Use git |
| **Lying comments** | Actively misleading | Update or delete |
| **Over-documentation** | Maintenance burden | Document only public APIs |
| **No "why" comments** | Missing important context | Add where genuinely needed |
| **TODO without tracking** | Never addressed | Add ticket/owner reference |

---

## Summary Decision Tree

```text
Is the code unclear?
├─ Yes → Can you rename to clarify?
│        ├─ Yes → Rename, don't comment
│        └─ No → Can you extract a function?
│                ├─ Yes → Extract, don't comment
│                └─ No → Can you simplify?
│                        ├─ Yes → Simplify, don't comment
│                        └─ No → Is it "why" not "what"?
│                                ├─ Yes → Write the comment
│                                └─ No → Reconsider if needed
└─ No → Is it a public API?
        ├─ Yes → Write doc comment
        └─ No → Don't comment
```

---

## See Also

- [Coding Guidelines](../coding-guidelines/coding-guidelines.md) – Writing self-documenting code
- [Documentation Guidelines](../documentation-guidelines/documentation-guidelines.md) – When documentation is needed
