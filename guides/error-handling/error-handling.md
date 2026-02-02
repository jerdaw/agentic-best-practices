# Error Handling for AI Agents

Best practices for AI agents on handling errors—making code robust, debuggable, and user-friendly across any language or project.

> **Scope**: These guidelines are for AI agents performing coding tasks. Proper error handling is often overlooked; these patterns ensure reliable code.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Error Categories](#error-categories) |
| [Error Message Quality](#error-message-quality) |
| [Try-Catch Patterns](#try-catch-patterns) |
| [Return Values vs Exceptions](#return-values-vs-exceptions) |
| [Input Validation](#input-validation) |
| [Async Error Handling](#async-error-handling) |
| [Custom Error Types](#custom-error-types) |
| [Error Logging](#error-logging) |
| [User-Facing Errors](#user-facing-errors) |
| [Retry and Recovery](#retry-and-recovery) |
| [Cleanup and Resources](#cleanup-and-resources) |
| [Bounded Effort and Stopping Conditions](#bounded-effort-and-stopping-conditions) |
| [Anti-Patterns](#anti-patterns) |
| [Error Handling Checklist](#error-handling-checklist) |

---

## Quick Reference

### Guideline Summary

| Guideline | Rationale |
| --- | --- |
| **Handle Explicitly** | Silent failures make debugging impossible; always know *why* it failed. |
| **Provide Context** | "Error" is useless; "Failed to save user 123" is actionable. |
| **Fail Fast** | Catch bugs locally before they corrupt global state. |
| **Recover Gracefully** | Users should never see a crash; degrade functionality instead. |
| **Log Details** | You cannot fix what you cannot reproduce or understand. |

### Anti-Patterns Summary

| Avoid | Rationale |
| --- | --- |
| **Swallowing Errors** | `catch {}` hides bugs effectively forever. |
| **Internal Leaks** | Stack traces in UI scare users and help attackers. |
| **Flow via Exceptions** | Exceptions are slow and jumpy; use logic for normal flow. |
| **Catching All** | If you can't handle it, letting it crash is safer than guessing. |
| **Ignoring Returns** | C-style error codes ignored = undefined behavior. |

### Error Types

| Type | Handling | Rationale |
| --- | --- | --- |
| **Programming** | **Crash / Fix** | Null pointers and type errors are bugs; fix the code. |
| **Operational** | **Handle / Retry** | Network/Disk errors are facts of life; code must handle them. |

---

## Core Principles

| Principle | Rationale |
| --- | --- |
| **Explicit > Silent** | Hidden errors fester until they cause catastrophic failure. |
| **Fail Fast** | The closer the error is to the bug, the easier the fix. |
| **Informative** | An error message is a letter to your future debugging self. |
| **Granularity** | Catching too high loses context; too low adds noise. |
| **Separation** | Bugs need fixes; outage needs retries. distinguishing is key. |

---

## Error Categories

### Programming Errors vs Operational Errors

| Type | Examples | Handling | Rationale |
| --- | --- | --- | --- |
| **Programming** | Null ref, type error | **Crash / Fix** | These are bugs. Recovering hides the root cause. |
| **Operational** | Timeout, 404, invalid input | **Handle / Retry** | Users/Network are unpredictable; code must adapt. |

```text
Programming errors (bugs):
- Calling function with wrong argument types
- Accessing undefined property
- Off-by-one errors
- Assertion failures

Operational errors (expected):
- User provides invalid input
- Network request fails
- File doesn't exist
- Database connection lost
- Rate limit exceeded
```

### Handle Differently

```javascript
// Programming error: Let it crash, fix the bug
function processUser(user) {
  // If user is undefined, that's a bug in the caller
  // Don't silently handle it - let it fail visibly
  return user.name.toUpperCase()
}

// Operational error: Handle gracefully
async function fetchUser(userId) {
  try {
    const response = await api.get(`/users/${userId}`)
    return response.data
  } catch (error) {
    if (error.status === 404) {
      return null  // User not found is expected
    }
    throw error  // Other errors are unexpected
  }
}
```

---

## Error Message Quality

### Good Error Messages

| Component | Purpose | Example | Rationale |
| --- | --- | --- | --- |
| **What** | Immediate context | "Failed to save profile" | "Error 500" tells the user nothing about consequences. |
| **Why** | Root cause | "DB connection refused" | Essential for debugging the infrastructure. |
| **Data** | Debugging context | "userId: 123" | "It didn't work" is unfixable without the variable state. |
| **Fix** | Suggestion | "Check DB_URL" | Reduces mean-time-to-resolution (MTTR). |

### Message Patterns

```javascript
// BAD: Vague
throw new Error('Error')
throw new Error('Something went wrong')
throw new Error('Invalid input')

// GOOD: Informative
throw new Error('Failed to parse (config.json) - Invalid JSON')
throw new Error(`User not found: userId=${userId}`)
throw new Error(`Payment failed: amount=${amount}, reason=${gateway.error}`)
```

### Context Chain

Preserve context when re-throwing:

```javascript
// BAD: Lost original context
try {
  await saveToDatabase(data)
} catch (error) {
  throw new Error('Save failed')  // Original error lost
}

// GOOD: Preserve context
try {
  await saveToDatabase(data)
} catch (error) {
  throw new Error(`Failed to save user ${userId}: ${error.message}`, { cause: error })
}
```

---

## Try-Catch Patterns

### Catch at the Right Level

| Level | What to Catch | Example | Rationale |
| --- | --- | --- | --- |
| **Leaf** | Nothing | Utilities | Leaf nodes shouldn't guess; let errors bubble up. |
| **Logic** | Recoverable | Retry/Fallback | Handle specific expected failures (e.g., API timeout). |
| **Boundary** | Transform | API Response | Don't leak internals; format for the consumer. |
| **Root** | Everything | Global Handler | Last resort to prevent process crash or hanging. |

### Specific vs Generic Catches

```javascript
// BAD: Catch everything, handle nothing useful
try {
  await processOrder(order)
} catch (error) {
  console.log('Error occurred')
}

// GOOD: Catch specific errors, handle appropriately
try {
  await processOrder(order)
} catch (error) {
  if (error instanceof ValidationError) {
    return { status: 400, error: error.message }
  }
  if (error instanceof PaymentError) {
    await notifyPaymentTeam(order, error)
    return { status: 402, error: 'Payment failed' }
  }
  // Unexpected error: log and rethrow
  logger.error('Unexpected error processing order', { order, error })
  throw error
}
```

### Finally Blocks

Always clean up resources:

```javascript
async function withDatabaseConnection(fn) {
  const connection = await pool.getConnection()
  try {
    return await fn(connection)
  } finally {
    // Always release, whether success or error
    connection.release()
  }
}
```

---

## Return Values vs Exceptions

### When to Use Each

| Approach | When to Use | Rationale |
| --- | --- | --- |
| **Exceptions** | Unexpected | Interrupts flow for things that "shouldn't happen". |
| **Returns** | Expected | "User not found" is a valid state, not an explosion. |
| **Result** | Mixed | Forces caller to handle both success/failure paths explicitly. |

### Result Pattern

```javascript
// Result type approach
function parseConfig(text) {
  try {
    const config = JSON.parse(text)
    return { success: true, data: config }
  } catch (error) {
    return { success: false, error: `Invalid JSON: ${error.message}` }
  }
}

// Usage
const result = parseConfig(configText)
if (!result.success) {
  console.error(result.error)
  return useDefaultConfig()
}
return result.data
```

### Nullable Returns

```javascript
// Returning null for "not found" is often cleaner than throwing
async function findUser(userId) {
  const user = await db.users.findOne({ id: userId })
  return user || null  // Explicit null, not undefined
}

// Usage
const user = await findUser(userId)
if (!user) {
  return { status: 404, error: 'User not found' }
}
```

---

## Input Validation

### Validate at Boundaries

| Boundary | What to Validate | Rationale |
| --- | --- | --- |
| **API** | Body/Params | Never trust the client; they lie or are malicious. |
| **Public Fn** | Args | Protect internal consistency from bad caller usage. |
| **Config** | Settings | Fail startup instantly if keys/urls are missing. |
| **External** | Data | Third-party APIs change contracts without warning. |

### Validation Patterns

```javascript
// Validate early, fail fast
function createUser(data) {
  // Validate at entry point
  if (!data.email) {
    throw new ValidationError('Email is required')
  }
  if (!isValidEmail(data.email)) {
    throw new ValidationError(`Invalid email format: ${data.email}`)
  }
  if (!data.password || data.password.length < 8) {
    throw new ValidationError('Password must be at least 8 characters')
  }

  // After validation, core logic can assume valid data
  return doCreateUser(data)
}
```

### Validation Error Messages

```javascript
// BAD: Unhelpful
throw new Error('Validation failed')

// GOOD: Specific and actionable
throw new ValidationError('Email is required')
throw new ValidationError(`Invalid email format: "${email}"`)
throw new ValidationError('Password must be at least 8 characters, got 5')
throw new ValidationError('Age must be between 0 and 150, got -5')
```

---

## Async Error Handling

### Always Await or Return Promises

```javascript
// BAD: Unhandled promise rejection
function processData() {
  fetchData()  // Promise ignored
    .then(data => save(data))
}

// GOOD: Properly handled
async function processData() {
  const data = await fetchData()
  await save(data)
}
```

### Promise.all Error Handling

```javascript
// All fail if one fails
try {
  const [users, orders] = await Promise.all([
    fetchUsers(),
    fetchOrders()
  ])
} catch (error) {
  // One failed, but we don't know which
}

// Handle individually if needed
const results = await Promise.allSettled([
  fetchUsers(),
  fetchOrders()
])

const users = results[0].status === 'fulfilled' ? results[0].value : []
const orders = results[1].status === 'fulfilled' ? results[1].value : []

// Log failures
results.forEach((result, index) => {
  if (result.status === 'rejected') {
    logger.error(`Request ${index} failed`, { error: result.reason })
  }
})
```

---

## Custom Error Types

### When to Create Custom Errors

| Reason | Example | Rationale |
| --- | --- | --- |
| **Logic** | `ValidationError` | Need to catch and show user-friendly message. |
| **Context** | `HttpError(404)` | Carry metadata (status code) up the stack. |
| **Domain** | `FundsError` | Business logic requires specific branch for this case. |

### Custom Error Pattern

```javascript
class AppError extends Error {
  constructor(message, options = {}) {
    super(message)
    this.name = this.constructor.name
    this.code = options.code
    this.statusCode = options.statusCode
    this.context = options.context
    Error.captureStackTrace?.(this, this.constructor)
  }
}

class ValidationError extends AppError {
  constructor(message, field) {
    super(message, { code: 'VALIDATION_ERROR', statusCode: 400 })
    this.field = field
  }
}

class NotFoundError extends AppError {
  constructor(resource, id) {
    super(`${resource} not found: ${id}`, { code: 'NOT_FOUND', statusCode: 404 })
    this.resource = resource
    this.resourceId = id
  }
}

// Usage
throw new ValidationError('Invalid email format', 'email')
throw new NotFoundError('User', userId)
```

---

## Error Logging

### What to Log

| Level | When | Include | Rationale |
| --- | --- | --- | --- |
| **error** | Unexpected | Stack trace | Critical failures requiring immediate attention. |
| **warn** | Handled | Context | Something went wrong but system recovered; worth reviewing. |
| **info** | Normal | Events | Business intelligence and happy-path verification. |
| **debug** | Dev only | State | Deep introspection for local development. |

### Logging Pattern

```javascript
// Good error logging
try {
  await processPayment(order)
} catch (error) {
  logger.error('Payment processing failed', {
    orderId: order.id,
    userId: order.userId,
    amount: order.total,
    error: error.message,
    stack: error.stack,
    paymentMethod: order.paymentMethod
  })
  throw error
}
```

### Don't Log Sensitive Data

```javascript
// BAD: Logs sensitive data
logger.error('Login failed', {
  email: user.email,
  password: user.password,  // Never log passwords
  creditCard: user.creditCard  // Never log financial data
})

// GOOD: Redact sensitive data
logger.error('Login failed', {
  email: user.email,
  userId: user.id
  // Sensitive data omitted
})
```

---

## User-Facing Errors

### Separate Internal and External Messages

```javascript
// Internal logging: detailed for debugging
logger.error('Database query failed', {
  query: 'SELECT * FROM users WHERE...',
  error: dbError.message,
  connectionPool: pool.stats()
})

// External response: safe for users
return {
  status: 500,
  error: 'Unable to process request. Please try again later.',
  requestId: requestId  // For support reference
}
```

### User Error Message Guidelines

| Do | Don't | Rationale |
| --- | --- | --- |
| **Helpful/Clear** | Stack traces | Users can't read stacks; attackers can. |
| **Next Steps** | SQL queries | Tell them *what* to do, not *why* the DB failed. |
| **Ref IDs** | Architecture | "Error ID: 523" helps support; "Server 5" helps hackers. |
| **Polite** | Jargon | "Session expired" > "Token validation exception". |

```javascript
// GOOD user-facing errors
'Invalid email address. Please check and try again.'
'Your session has expired. Please log in again.'
'Unable to process payment. Please verify your card details.'
'Something went wrong. Reference: REQ-123456'

// BAD user-facing errors
'NullPointerException at line 247'
'ECONNREFUSED 127.0.0.1:5432'
'SELECT * FROM users WHERE id=123 failed'
```

---

## Retry and Recovery

### When to Retry

| Error Type | Retry? | Rationale |
| --- | --- | --- |
| **Network** | **Yes** | Transient glitches happen; backoff and try again. |
| **Rate Limit** | **Yes** | Respect the headers (429) and wait. |
| **Server (5xx)** | **Yes** | Server might be restarting; give it a moment. |
| **Client (4xx)** | **No** | You sent bad data; retrying won't fix logic. |
| **Auth** | **No** | Bad credentials don't become good with time. |

### Retry Pattern

```javascript
async function withRetry(fn, options = {}) {
  const { maxAttempts = 3, initialDelay = 1000, maxDelay = 30000 } = options

  let lastError
  let delay = initialDelay

  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await fn()
    } catch (error) {
      lastError = error

      if (!isRetryable(error) || attempt === maxAttempts) {
        throw error
      }

      logger.warn(`Attempt ${attempt} failed, retrying`, {
        error: error.message,
        nextAttempt: attempt + 1,
        delayMs: delay
      })

      await sleep(delay)
      delay = Math.min(delay * 2, maxDelay)
    }
  }
}

function isRetryable(error) {
  if (error.status >= 500) return true
  if (error.status === 429) return true
  if (error.code === 'ECONNREFUSED') return true
  if (error.code === 'ETIMEDOUT') return true
  return false
}
```

---

## Cleanup and Resources

### Always Clean Up

```javascript
// Pattern: Acquire, use, release
async function processWithFile(filepath, processor) {
  const handle = await fs.open(filepath)
  try {
    return await processor(handle)
  } finally {
    await handle.close()
  }
}

// Database transaction pattern
async function withTransaction(fn) {
  const transaction = await db.beginTransaction()
  try {
    const result = await fn(transaction)
    await transaction.commit()
    return result
  } catch (error) {
    await transaction.rollback()
    throw error
  }
}
```

---

## Bounded Effort and Stopping Conditions

For agent operations and automated processes, define explicit stopping conditions.

### Bounded Iteration

| Bound | Purpose | Example | Rationale |
| --- | --- | --- | --- |
| **Max attempts** | Prevent infinite retries | `maxRetries: 3` | Stop after reasonable effort; don't hammer the service. |
| **Max iter** | Prevent loops | `maxIterations: 100` | Halting problem safety; ensure termination. |
| **Max dur** | Prevent hanging | `timeout: 5min` | Stuck processes consume resources indefinitely. |
| **Max cost** | Budget cap | `maxTokens: 50k` | Avoid surprise bills from expensive APIs. |
| **Max depth** | Recursion limit | `depth: 10` | Prevent stack overflow in recursive logic. |

### Implementation Pattern

```javascript
async function boundedOperation(task, options = {}) {
  const {
    maxAttempts = 3,
    maxDuration = 300000,
    maxIterations = 100
  } = options

  const startTime = Date.now()
  let iterations = 0
  let attempts = 0

  while (attempts < maxAttempts) {
    attempts++

    try {
      while (!task.isComplete() && iterations < maxIterations) {
        if (Date.now() - startTime > maxDuration) {
          throw new TimeoutError(`Exceeded max duration: ${maxDuration}ms`)
        }

        iterations++
        await task.step()
      }

      if (task.isComplete()) {
        return task.result()
      }

      throw new IterationLimitError(`Exceeded max iterations: ${maxIterations}`)

    } catch (error) {
      if (!isRetryable(error) || attempts >= maxAttempts) {
        throw error
      }
      // Log and retry
    }
  }
}
```

### Escalation Pattern

When bounds are hit, escalate appropriately:

```javascript
function handleBoundExceeded(boundType, context) {
  logger.warn(`Bound exceeded: ${boundType}`, context)

  switch (boundType) {
    case 'max_retries':
      // Notify, but don't block
      return { action: 'fail', notify: true }

    case 'max_duration':
      // Save progress, allow resume
      return { action: 'checkpoint', notify: true }

    case 'max_cost':
      // Hard stop, require human approval to continue
      return { action: 'stop', requireApproval: true }

    default:
      return { action: 'fail' }
  }
}
```

### Stopping Condition Checklist

| Condition | Rationale |
| --- | --- |
| **Max Retry** | Prevent infinite loops in transient failure logic. |
| **Timeout** | External dependencies *will* hang eventually; don't wait forever. |
| **Iter Limit** | `while(true)` is a bug waiting to happen; cap it. |
| **Budget** | Paid APIs need hard stops to prevent billing incidents. |
| **Escalation** | When limits are hit, a human or supervisor system must know. |

---

## Anti-Patterns

| Anti-Pattern | Problem | Rationale |
| --- | --- | --- |
| **Silent Catch** | `catch {}` | Hides bugs; you can't fix what you can't see. |
| **Ret Null** | Ambiguity | Caller can't tell `null` (not found) from `error` (db down). |
| **Generic** | "Error" | "Something happened" is literally useless information. |
| **Bad Level** | Wrong Scope | Catching too high catches syntax errors; too low duplicates handling. |
| **Control Flow** | Slow/Jump | Exceptions are expensive and make control flow invisible. |
| **Ignoring** | Unchecked | Ignoring return codes leaves system in undefined state. |
| **Log+Throw** | Noise | Log OR throw; doing both creates double logs for one event. |
| **Base Class** | Too Broad | `catch (Error)` catches everything, including your `Ctrl+C`. |

---

## Error Handling Checklist

For each function that can fail:

### Final Review

| Question | Rationale |
| --- | --- |
| **Identified?** | Have you thought about what *could* go wrong? |
| **Type?** | Is this a bug (throw) or a state (return)? |
| **Context?** | Will the logs tell me *why* this happened at 3 AM? |
| **Logged?** | Is it visible to the operator? |
| **Cleanup?** | Did you close the file handle even if it crashed? |
| **handled?** | Did the caller actually check the return value? |
| **Safe?** | Did you accidentally show a stack trace to the user? |

---

## See Also

- [Logging Practices](../logging-practices/logging-practices.md) – How to log effectively
- [Coding Guidelines](../coding-guidelines/coding-guidelines.md) – General code quality
