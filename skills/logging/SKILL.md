---
name: logging
description: Implement structured, secure logging with proper levels, correlation IDs, and redaction
---

# Logging

Implement effective logging — structured format, appropriate levels, correlation IDs, and sensitive data protection.

## When to Use

- Adding logging to new services or features
- Reviewing existing logging for security and quality
- Setting up observability infrastructure
- Debugging production issues through log analysis

## Workflow

### 1. Choose a Structured Logger

Use a logging library that supports structured (JSON) output — not `console.log`.

| Language | Library |
| --- | --- |
| JavaScript/TS | pino, winston |
| Python | structlog, python-json-logger |
| Go | zerolog, zap |
| Java | SLF4J + Logback |

### 2. Set Log Levels

| Level | When | Example |
| --- | --- | --- |
| `error` | Unexpected failure | Database connection lost |
| `warn` | Concerning but handled | Retry succeeded |
| `info` | Business events | User registered |
| `debug` | Dev details (off in prod) | Function parameters |

### 3. Include Correlation IDs

Every request should carry a unique ID through all log entries:

```javascript
// Generate at entry point
const requestId = req.headers['x-request-id'] || uuid()

// Include in all logs
logger.info('Order processed', { requestId, orderId, userId })
```

### 4. Redact Sensitive Data

**Never log**: passwords, tokens, API keys, PII, credit card numbers

```javascript
// BAD
logger.info('Login', { email, password })

// GOOD
logger.info('Login', { email, passwordProvided: !!password })
```

### 5. Configure Per-Environment

| Setting | Development | Production |
| --- | --- | --- |
| Level | debug | info |
| Format | Pretty printed | JSON |
| Output | Console | Log aggregator |

### 6. Verify

- [ ] No sensitive data in log output
- [ ] Structured format (key-value pairs)
- [ ] Correlation IDs present
- [ ] Appropriate log levels used
- [ ] Error logs include stack traces

## Red Flags

| Signal | Action |
| --- | --- |
| Secrets appearing in logs | Add redaction immediately |
| `console.log` in production code | Replace with structured logger |
| Debug logging enabled in production | Set level to `info` or higher |
| Error logged AND re-thrown | Choose one — log or throw |

## Related Skills

| Skill | When |
| --- | --- |
| [debugging](../debugging/SKILL.md) | Using logs to debug issues |
| [secure-coding](../secure-coding/SKILL.md) | Ensuring logs don't leak data |

## Backing Guide

- [Logging Practices](../../guides/logging-practices/logging-practices.md)
