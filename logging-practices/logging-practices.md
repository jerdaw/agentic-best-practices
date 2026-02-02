# Logging Practices for AI Agents

Best practices for AI agents on implementing effective logging—what to log, how to structure it, and what to avoid.

> **Scope**: These guidelines are for AI agents performing coding tasks. Good logging makes systems debuggable and observable; bad logging creates noise or security risks.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Log Levels](#log-levels) |
| [Structured Logging](#structured-logging) |
| [What to Log](#what-to-log) |
| [What NOT to Log](#what-not-to-log) |
| [Correlation and Tracing](#correlation-and-tracing) |
| [Performance Logging](#performance-logging) |
| [Log Configuration](#log-configuration) |
| [Log Messages](#log-messages) |
| [Testing and Logs](#testing-and-logs) |
| [Observability for AI Agents](#observability-for-ai-agents) |
| [Anti-Patterns](#anti-patterns) |
| [Logging Checklist](#logging-checklist) |

---

## Quick Reference

**Always log**:
- Application startup and configuration
- Errors with full context
- Security events (auth failures, access denials)
- Significant state changes
- External service interactions

**Never log**:
- Passwords, tokens, API keys
- Personal data (PII) unless required
- Credit card numbers, SSNs
- Full request/response bodies in production
- Every function entry/exit

**Log levels**:
- `error`: Something failed that shouldn't have
- `warn`: Something concerning but handled
- `info`: Significant business events
- `debug`: Development details (off in production)

---

## Core Principles

1. **Structured over unstructured** – Key-value pairs, not string concatenation
2. **Contextual over isolated** – Include correlation IDs and relevant data
3. **Appropriate level** – Right verbosity for the situation
4. **Secure by default** – Assume logs will be compromised
5. **Actionable over verbose** – Log what helps debugging

---

## Log Levels

### When to Use Each Level

| Level | When | Example |
|-------|------|---------|
| `error` | Unexpected failure requiring attention | Database connection lost, unhandled exception |
| `warn` | Concerning but handled | Retry succeeded, deprecated API used, rate limit approaching |
| `info` | Significant business events | User registered, order completed, job started |
| `debug` | Development/troubleshooting details | Function parameters, intermediate state |
| `trace` | Very detailed (rarely used) | Every database query, full objects |

### Level Selection Guide

```
error:
- Unhandled exceptions
- Failed operations that impact users
- Data corruption detected
- Security breaches

warn:
- Transient failures recovered from
- Approaching resource limits
- Deprecated functionality used
- Unexpected but handled conditions

info:
- Service started/stopped
- Configuration loaded
- User authentication success
- Transaction completed
- Scheduled job execution

debug:
- Function entry with parameters
- Query execution details
- Cache hits/misses
- State transitions
```

---

## Structured Logging

### Format: Key-Value Pairs

```
// BAD: Unstructured string
logger.info(`User ${userId} logged in from ${ip} at ${time}`)

// GOOD: Structured data
logger.info('User logged in', {
  userId,
  ip,
  timestamp: new Date().toISOString(),
  userAgent
})
```

### Why Structured Matters

| Unstructured | Structured |
|--------------|------------|
| Hard to parse | Machine-readable |
| Hard to search | Queryable fields |
| Inconsistent format | Consistent schema |
| Hard to filter | Easy filtering |

### Standard Fields

| Field | Purpose | Example |
|-------|---------|---------|
| `timestamp` | When it happened | ISO 8601 format |
| `level` | Severity | info, error, etc. |
| `message` | Human description | "Order processed" |
| `requestId` | Correlation | UUID |
| `userId` | Who | User identifier |
| `service` | What system | "payment-service" |
| `duration` | How long | Milliseconds |

```
// Example structured log entry
{
  "timestamp": "2024-01-15T10:30:00.000Z",
  "level": "info",
  "message": "Order processed",
  "requestId": "req-123-456",
  "userId": "user-789",
  "orderId": "ord-111",
  "amount": 99.99,
  "duration": 245,
  "service": "order-service"
}
```

---

## What to Log

### Application Lifecycle

```
// Startup
logger.info('Application starting', {
  version: process.env.APP_VERSION,
  environment: process.env.NODE_ENV,
  port: config.port
})

// Ready
logger.info('Application ready', {
  startupTime: Date.now() - startTime
})

// Shutdown
logger.info('Application shutting down', {
  reason: signal,
  uptime: process.uptime()
})
```

### Request Handling

```
// Request received (at entry point)
logger.info('Request received', {
  requestId,
  method: req.method,
  path: req.path,
  userId: req.user?.id
})

// Request completed
logger.info('Request completed', {
  requestId,
  status: res.statusCode,
  duration: Date.now() - startTime
})
```

### Error Events

```
// Error with full context
logger.error('Payment processing failed', {
  requestId,
  userId,
  orderId,
  amount,
  error: error.message,
  errorCode: error.code,
  stack: error.stack
})
```

### Security Events

```
// Authentication
logger.info('User authenticated', { userId, method: 'password' })
logger.warn('Authentication failed', { email, reason: 'invalid_password', ip })
logger.warn('Authentication failed', { email, reason: 'account_locked', ip })

// Authorization
logger.warn('Access denied', { userId, resource, action, reason })

// Suspicious activity
logger.warn('Rate limit exceeded', { userId, endpoint, count })
```

### External Service Calls

```
// Before call
logger.debug('Calling external service', {
  service: 'stripe',
  operation: 'createCharge',
  requestId
})

// After call
logger.info('External service responded', {
  service: 'stripe',
  operation: 'createCharge',
  success: true,
  duration: 150,
  requestId
})

// On failure
logger.error('External service failed', {
  service: 'stripe',
  operation: 'createCharge',
  error: error.message,
  duration: 30000,
  requestId
})
```

---

## What NOT to Log

### Sensitive Data

| Never Log | Why | Alternative |
|-----------|-----|-------------|
| Passwords | Security | Log "password provided: yes/no" |
| API keys/tokens | Security | Log "token valid: yes/no" |
| Credit card numbers | PCI compliance | Log last 4 digits only |
| Social Security Numbers | Privacy | Log "SSN provided: yes/no" |
| Full medical records | HIPAA | Log event type only |
| Personal addresses | Privacy | Log country/region only |
| Session contents | Security | Log session ID only |

### Sanitization Patterns

```
// BAD
logger.info('User login', { email, password })
logger.info('Payment', { cardNumber, cvv, expiry })
logger.debug('Request body', req.body)

// GOOD
logger.info('User login', { email, passwordProvided: !!password })
logger.info('Payment', { cardLastFour: cardNumber.slice(-4), amountCents })
logger.debug('Request received', {
  path: req.path,
  bodySize: JSON.stringify(req.body).length
})
```

### Excessive Logging

```
// BAD: Too verbose, fills logs
function add(a, b) {
  logger.debug('Entering add function')
  logger.debug('Parameter a', { a })
  logger.debug('Parameter b', { b })
  const result = a + b
  logger.debug('Calculated result', { result })
  logger.debug('Exiting add function')
  return result
}

// GOOD: Log what matters
function processOrder(order) {
  logger.info('Processing order', { orderId: order.id })
  // ... do work ...
  logger.info('Order processed', { orderId: order.id, status: 'completed' })
}
```

---

## Correlation and Tracing

### Request IDs

```
// Generate at entry point
function requestMiddleware(req, res, next) {
  req.requestId = req.headers['x-request-id'] || generateUUID()
  res.setHeader('x-request-id', req.requestId)
  next()
}

// Include in all logs
logger.info('Processing request', { requestId: req.requestId, ... })
```

### Correlation Across Services

```
// Pass request ID to downstream services
async function callDownstream(requestId, data) {
  return await fetch(url, {
    headers: {
      'x-request-id': requestId,
      'x-correlation-id': requestId
    },
    body: JSON.stringify(data)
  })
}
```

### Context Propagation

```
// Create logger with context
function createContextLogger(baseLogger, context) {
  return {
    info: (message, data) => baseLogger.info(message, { ...context, ...data }),
    error: (message, data) => baseLogger.error(message, { ...context, ...data }),
    // ... other levels
  }
}

// Usage
function handleRequest(req, res) {
  const log = createContextLogger(logger, {
    requestId: req.requestId,
    userId: req.user?.id
  })

  log.info('Starting request processing')
  // All logs from here include requestId and userId
}
```

---

## Performance Logging

### Duration Tracking

```
// Track operation duration
const start = Date.now()
await performOperation()
const duration = Date.now() - start

logger.info('Operation completed', {
  operation: 'database_query',
  duration,
  slow: duration > 1000
})
```

### Threshold Warnings

```
// Log slow operations
const SLOW_THRESHOLD_MS = 1000

async function trackedOperation(name, fn) {
  const start = Date.now()
  try {
    return await fn()
  } finally {
    const duration = Date.now() - start
    if (duration > SLOW_THRESHOLD_MS) {
      logger.warn('Slow operation detected', { operation: name, duration })
    }
  }
}
```

---

## Log Configuration

### Environment-Based Levels

```
// Development: verbose
const logLevel = process.env.NODE_ENV === 'production' ? 'info' : 'debug'

// Or per-component
const logConfig = {
  default: 'info',
  'database': 'warn',      // Quiet
  'http': 'debug',         // Verbose
  'auth': 'info'
}
```

### Production vs Development

| Setting | Development | Production |
|---------|-------------|------------|
| Level | debug | info or warn |
| Format | Pretty printed | JSON |
| Output | Console | Aggregator |
| Sampling | None | May sample high-volume |

---

## Log Messages

### Message Guidelines

| Do | Don't |
|----|-------|
| Start with what happened | Start with "Error:" |
| Use present tense | Use past tense |
| Be specific | Be vague |
| Use consistent terminology | Mix terms |

```
// Good messages
'User registered'
'Order payment processed'
'Cache miss, fetching from database'
'Rate limit exceeded'
'Database connection established'

// Bad messages
'Error: something went wrong'
'Done'
'OK'
'Processing...'
'An error has occurred'
```

### Error Messages

```
// Include actionable information
logger.error('Database connection failed', {
  host: config.db.host,
  port: config.db.port,
  error: error.message,
  code: error.code,
  suggestion: 'Check DATABASE_URL environment variable'
})
```

---

## Testing and Logs

### Testing Logging

```
// Mock logger for tests
const mockLogger = {
  logs: [],
  info: function(msg, data) { this.logs.push({ level: 'info', msg, data }) },
  error: function(msg, data) { this.logs.push({ level: 'error', msg, data }) }
}

// Test that logging occurs
test('logs order completion', async () => {
  await processOrder(order, { logger: mockLogger })

  expect(mockLogger.logs).toContainEqual({
    level: 'info',
    msg: 'Order processed',
    data: expect.objectContaining({ orderId: order.id })
  })
})
```

### Avoiding Test Noise

```
// Suppress logs in tests
beforeAll(() => {
  jest.spyOn(logger, 'info').mockImplementation(() => {})
  jest.spyOn(logger, 'debug').mockImplementation(() => {})
})

// Or use test log level
process.env.LOG_LEVEL = 'error'  // Only show errors in tests
```

---

## Observability for AI Agents

When logging agent operations, additional observability patterns apply.

### Run Identification

Every agent operation should have a unique run ID:

```
// Generate at operation start
const runId = generateUUID()

logger.info('Agent operation started', {
  runId,
  task: 'code-review',
  inputTokens: prompt.length,
  model: 'claude-3-sonnet'
})

// Include in all subsequent logs
logger.info('Tool invoked', { runId, tool: 'read_file', file: path })
logger.info('Operation completed', {
  runId,
  duration: elapsed,
  outputTokens: response.length,
  success: true
})
```

### Token and Cost Tracking

Track resource consumption for budgeting:

```
{
  "timestamp": "2024-01-15T10:30:00Z",
  "runId": "run-123",
  "event": "llm_call",
  "model": "claude-3-sonnet",
  "inputTokens": 1500,
  "outputTokens": 800,
  "estimatedCost": 0.012,
  "cumulativeTokens": 12500,
  "budgetRemaining": 0.45
}
```

### SLO Metrics

Log metrics that support service level objectives:

| Metric | Purpose | Example |
|--------|---------|---------|
| `latency_ms` | Response time tracking | `{ latency_ms: 2300 }` |
| `tokens_used` | Cost control | `{ inputTokens: 500, outputTokens: 200 }` |
| `retry_count` | Reliability | `{ attempts: 2, maxAttempts: 3 }` |
| `tool_calls` | Behavior analysis | `{ toolCalls: ['read', 'edit', 'read'] }` |
| `error_rate` | Quality monitoring | Log every error with category |

### Agent-Specific Fields

| Field | Purpose | Example |
|-------|---------|---------|
| `runId` | Correlate across operations | UUID |
| `parentRunId` | Link sub-agents to parent | Parent's UUID |
| `taskType` | Categorize operations | "code-review", "refactor" |
| `toolName` | Track tool usage | "read_file", "edit" |
| `budgetUsed` | Cost tracking | Percentage or absolute |

```
// Good agent logging structure
logger.info('Agent task completed', {
  runId: 'run-abc-123',
  parentRunId: 'run-parent-456',  // If sub-agent
  taskType: 'code-review',
  duration: 45000,
  toolCalls: 12,
  tokens: { input: 5000, output: 2000 },
  files: { read: 8, modified: 2 },
  success: true
})
```

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| **Logging sensitive data** | Security breach | Redact or omit |
| **Unstructured strings** | Hard to parse | Use key-value pairs |
| **No context** | Hard to trace | Include IDs, user, operation |
| **Wrong level** | Noise or missed alerts | Choose level carefully |
| **Log and throw** | Duplicate entries | Do one or the other |
| **console.log in production** | Not aggregated | Use proper logger |
| **Logging every line** | Performance, noise | Log meaningful events |
| **Inconsistent format** | Hard to query | Standardize fields |
| **No run ID** | Can't trace agent operations | Include runId in all logs |
| **No cost tracking** | Budget overruns | Log token usage |

---

## Logging Checklist

When adding logging:

- [ ] Using appropriate log level?
- [ ] Message is clear and specific?
- [ ] Includes relevant context (IDs, user, operation)?
- [ ] No sensitive data logged?
- [ ] Structured format (not string concatenation)?
- [ ] Error includes stack trace where appropriate?
- [ ] Correlation ID included for request tracing?
- [ ] Performance-sensitive paths not over-logged?

---

## See Also

- [Error Handling](../error-handling/error-handling.md) – When and what to log on errors
- [Security Boundaries](../security-boundaries/security-boundaries.md) – Protecting sensitive data
