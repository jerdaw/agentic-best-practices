# API Design for AI Agents

Best practices for AI agents on designing APIs—whether HTTP APIs, library interfaces, or internal module contracts.

> **Scope**: These guidelines are for AI agents performing coding tasks. Good API design enables correct usage and
> prevents misuse; these patterns apply to any interface you create.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Function/Method API Design](#functionmethod-api-design) |
| [HTTP API Design](#http-api-design) |
| [Error Response Design](#error-response-design) |
| [Input Validation](#input-validation) |
| [Versioning](#versioning) |
| [Pagination](#pagination) |
| [Library/Module API Design](#librarymodule-api-design) |
| [Tool Interface Design](#tool-interface-design) |
| [Consistency Patterns](#consistency-patterns) |
| [Documentation](#documentation) |
| [Evolution and Compatibility](#evolution-and-compatibility) |
| [Anti-Patterns](#anti-patterns) |
| [API Design Checklist](#api-design-checklist) |

---

## Quick Reference

**Always**:

| Principle | Why |
| --- | --- |
| **Caller-centric** | Design for usage, not implementation convenience. |
| **Consistent** | Reduces cognitive load and guesswork. |
| **Validated** | Fail early and specifically at boundaries. |
| **Predictable** | Use typed, consistent responses (no `null` vs `undefined`). |
| **Explicit Errors** | Don't fail silently; use specific error codes. |

**Never**:

| Anti-Pattern | Impact |
| --- | --- |
| **Leaky Internals** | Prevents refactoring; couples client to implementation. |
| **Over-fetching** | Wastes bandwidth; security risk if sensitive data leaks. |
| **Ambiguity** | Causes client-side bugs (e.g., returning mixed types). |
| **Silent Breaks** | Destroys trust; breaks production clients. |
| **Accidental Design** | Inconsistent, hard-to-maintain surface area. |

**Priority Order**:

| Priority | Factor | Why |
| :---: | --- | --- |
| 1 | **Correctness** | Does what it claims; reliable. |
| 2 | **Clarity** | Hard to misunderstand; obvious usage. |
| 3 | **Consistency** | Matches patterns; easy to learn. |
| 4 | **Completeness** | Handles edge cases; robust. |
| 5 | **Convenience** | Syntactic sugar; nice to have. |

---

## Core Principles

| Principle | Rationale |
| --- | --- |
| **Caller-centric** | Design from usage, not implementation. Prevents "leaky" abstractions. |
| **Minimal surface** | Expose only what's needed. Reduces maintenance and security risk. |
| **Predictable** | Same inputs produce same outputs. Enables testing and reliability. |
| **Hard to misuse** | Make wrong usage obvious or impossible. Safety by design. |
| **Evolvable** | Can change without breaking callers. Ensures longevity. |

---

## Function/Method API Design

### Signature Design

| Guideline | Example |
| --- | --- |
| Required params first | `createUser(email, name, options?)` |
| Use options object for many params | `search({ query, limit, offset, filters })` |
| Return consistent types | Always `User` or always `null`, not sometimes `undefined` |
| Prefer specific types | `userId: string` not `id: any` |

### Good vs Bad Signatures

```javascript
// BAD: Unclear what parameters mean
function process(data, flag1, flag2, flag3) { }

// GOOD: Self-documenting
function processOrder(order, options = {}) {
  const { validateInventory = true, sendNotification = true } = options
}
```

```javascript
// BAD: Inconsistent returns
function findUser(id) {
  if (!id) return false
  const user = db.find(id)
  if (!user) return undefined
  return user
}

// GOOD: Consistent returns
function findUser(id) {
  if (!id) return null
  return db.find(id) || null
}
```

### Options Pattern

```javascript
// When you have many optional parameters
function fetchData(url, options = {}) {
  const {
    method = 'GET',
    headers = {},
    timeout = 5000,
    retries = 3,
    cache = true
  } = options

  // Implementation
}

// Usage is clear
fetchData('/api/users', {
  timeout: 10000,
  retries: 5
})
```

### Builder Pattern for Complex Construction

```javascript
// When construction is complex
const query = new QueryBuilder()
  .select(['id', 'name', 'email'])
  .from('users')
  .where('status', '=', 'active')
  .orderBy('created_at', 'desc')
  .limit(10)
  .build()
```

---

## HTTP API Design

### Resource Naming

| Do | Don't | Rationale |
| --- | --- | --- |
| `/users` | `/getUsers` | Use nouns for resources; methods express actions. |
| `/users/123` | `/user?id=123` | Path parameters identify specific resources. |
| `/users/123/orders` | `/getUserOrders?userId=123` | Sub-resources represent relationships. |
| `/orders/456/items` | `/order-items?orderId=456` | Hierarchy clarifies ownership and scope. |

### HTTP Methods

| Method | Purpose | Idempotent | Example |
| --- | --- | --- | --- |
| GET | Read resource | Yes | `GET /users/123` |
| POST | Create resource | No | `POST /users` |
| PUT | Replace resource | Yes | `PUT /users/123` |
| PATCH | Update resource | No* | `PATCH /users/123` |
| DELETE | Remove resource | Yes | `DELETE /users/123` |

### Status Codes

| Code | When to Use |
| --- | --- |
| 200 | Success with body |
| 201 | Created (POST) |
| 204 | Success, no body (DELETE) |
| 400 | Invalid request (client error) |
| 401 | Not authenticated |
| 403 | Not authorized |
| 404 | Resource not found |
| 409 | Conflict (duplicate, state mismatch) |
| 422 | Valid syntax but semantic error |
| 429 | Rate limited |
| 500 | Server error |

### Request/Response Structure

```http
// Request
POST /api/users
Content-Type: application/json

{
  "email": "user@example.com",
  "name": "User Name"
}

// Success Response
HTTP/1.1 201 Created
Content-Type: application/json

{
  "id": "user_123",
  "email": "user@example.com",
  "name": "User Name",
  "createdAt": "2024-01-15T10:30:00Z"
}

// Error Response
HTTP/1.1 400 Bad Request
Content-Type: application/json

{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid email format",
    "field": "email"
  }
}
```

---

## Error Response Design

### Consistent Error Format

```json
// Standard error response structure
{
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "User not found",
    "details": {
      "resource": "user",
      "id": "user_123"
    }
  }
}

// Multiple errors (validation)
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "errors": [
      { "field": "email", "message": "Invalid email format" },
      { "field": "age", "message": "Must be a positive number" }
    ]
  }
}
```

### Error Codes

| Code Pattern | Example |
| --- | --- |
| Resource errors | `USER_NOT_FOUND`, `ORDER_NOT_FOUND` |
| Validation errors | `INVALID_EMAIL`, `MISSING_FIELD` |
| State errors | `ORDER_ALREADY_SHIPPED`, `ACCOUNT_LOCKED` |
| Auth errors | `INVALID_TOKEN`, `INSUFFICIENT_PERMISSIONS` |
| System errors | `DATABASE_ERROR`, `SERVICE_UNAVAILABLE` |

---

## Input Validation

### Validate at the Boundary

```javascript
// API endpoint validates all input
function createUserEndpoint(req, res) {
  // 1. Validate presence
  if (!req.body.email) {
    return res.status(400).json({
      error: { code: 'MISSING_FIELD', field: 'email' }
    })
  }

  // 2. Validate format
  if (!isValidEmail(req.body.email)) {
    return res.status(400).json({
      error: { code: 'INVALID_EMAIL', field: 'email' }
    })
  }

  // 3. Validate constraints
  if (req.body.name && req.body.name.length > 100) {
    return res.status(400).json({
      error: { code: 'VALUE_TOO_LONG', field: 'name', maxLength: 100 }
    })
  }

  // 4. Proceed with validated data
  return createUser(req.body)
}
```

### Schema Validation

```javascript
// Define expected shape
const createUserSchema = {
  email: { type: 'string', required: true, format: 'email' },
  name: { type: 'string', required: true, maxLength: 100 },
  age: { type: 'integer', minimum: 0, maximum: 150 }
}

// Validate against schema
function validateRequest(data, schema) {
  const errors = []
  for (const [field, rules] of Object.entries(schema)) {
    if (rules.required && !data[field]) {
      errors.push({ field, message: `${field} is required` })
    }
    // ... more validation
  }
  return errors
}
```

---

## Versioning

### When to Version

| Change Type | Versioning Needed? | Rationale |
| --- | --- | --- |
| **Add optional field** | No | Existing clients ignore unknown fields. |
| **Add new endpoint** | No | Discovered by clients; no impact on existing. |
| **Remove field** | Yes (breaking) | Clients expecting the field will fail. |
| **Change field type** | Yes (breaking) | Deserialization or logic will break. |
| **Change behavior** | Yes (breaking) | Silent changes in logic cause semantic bugs. |

### Versioning Strategies

| Strategy | Example | Rationale/Context |
| --- | --- | --- |
| **URL Path** | `/api/v1/users` | Most explicit; easy to route and cache. |
| **Custom Header** | `Accept: application/vnd.api+json; version=2` | Clean URLs; keeps multiple versions on one path. |
| **Query Param** | `/api/users?version=2` | Simple for browser testing; but harder to cache. |

### Deprecation Pattern

```http
// Response header indicating deprecation
HTTP/1.1 200 OK
Deprecation: true
Sunset: Sat, 01 Jan 2025 00:00:00 GMT
Link: </api/v2/users>; rel="successor-version"

{
  "data": { "status": "deprecated" }
}
```

---

## Pagination

### Offset-Based

```http
// Request
GET /api/users?offset=20&limit=10

// Response
{
  "data": [...],
  "pagination": {
    "offset": 20,
    "limit": 10,
    "total": 95
  }
}
```

### Cursor-Based (Preferred for Large Data)

```http
// Request
GET /api/users?cursor=eyJpZCI6MTAwfQ&limit=10

// Response
{
  "data": [...],
  "pagination": {
    "nextCursor": "eyJpZCI6MTEwfQ",
    "hasMore": true
  }
}
```

### Pagination Guidelines

| Guideline | Reason |
| --- | --- |
| Default limit | Prevent unbounded queries and memory exhaustion. |
| Maximum limit | Protect server resources from malicious/heavy requests. |
| Include metadata | Caller knows total, position, and next steps. |
| Consistent ordering | Results are reproducible; crucial for multi-page fetches. |

---

## Library/Module API Design

### Export Only What's Needed

```javascript
// index.js - public API
export { createUser, updateUser, deleteUser } from './users'
export { UserNotFoundError, ValidationError } from './errors'
export type { User, CreateUserInput } from './types'

// Don't export internal helpers
// Don't export implementation details
```

### Clear Contracts

```typescript
// Define what the function promises
/**
 * Creates a new user account.
 *
 * @param input - User data
 * @returns Created user with generated ID
 * @throws {ValidationError} If input is invalid
 * @throws {DuplicateEmailError} If email already exists
 */
function createUser(input: CreateUserInput): Promise<User>
```

### Defensive Design

```typescript
// Make misuse difficult
function setAge(age: number) {
  if (age < 0) {
    throw new Error('Age cannot be negative')
  }
  if (age > 150) {
    throw new Error('Age cannot exceed 150')
  }
  this.age = age
}
```

---

## Tool Interface Design

When designing tools for AI agents or automation systems, additional safety constraints are required.

### Safe Defaults

| Default | Why |
| --- | --- |
| `dry_run: true` | Preview before executing destructive actions. |
| Read-only mode | Prevent accidental writes in non-interactive tasks. |
| Bounded limits | Prevent resource exhaustion or infinite loops. |
| Explicit confirmation | Destructive actions require human opt-in. |

### Tool Schema Pattern

```json
{
  "type": "object",
  "additionalProperties": false,
  "required": ["target", "dry_run"],
  "properties": {
    "target": {
      "type": "string",
      "description": "Resource to operate on"
    },
    "dry_run": {
      "type": "boolean",
      "default": true,
      "description": "Preview without executing"
    },
    "max_files": {
      "type": "integer",
      "minimum": 1,
      "maximum": 100,
      "default": 10
    },
    "timeout_ms": {
      "type": "integer",
      "minimum": 1000,
      "maximum": 300000,
      "default": 30000
    }
  }
}
```

### Tool Design Rules

| Rule | Rationale |
| --- | --- |
| **Strict schemas** | Validate all inputs; reject unknown fields to prevent "halucination" leakage. |
| **No free-form code fields** | Prevent injection and unsafe execution paths. |
| **Explicit resource limits** | Cap files, bytes, time, iterations to ensure predictable performance. |
| **Idempotent when possible** | Safe to retry without side effects; improves robustness. |
| **Structured output** | Machine-parseable responses enable automated verification. |
| **Include call IDs** | Enable tracing, debugging, and audit trails. |

### Dry-Run Pattern

Every write operation should support dry-run:

```typescript
interface ToolResult {
  call_id: string
  dry_run: boolean
  would_modify?: string[]  // Files that would change
  diff?: string            // Preview of changes
  executed?: boolean       // True only if actually executed
}

async function editFile(params: EditParams): Promise<ToolResult> {
  const { file, changes, dry_run = true } = params

  const diff = computeDiff(file, changes)

  if (dry_run) {
    return {
      call_id: generateId(),
      dry_run: true,
      would_modify: [file],
      diff,
      executed: false
    }
  }

  await applyChanges(file, changes)
  return {
    call_id: generateId(),
    dry_run: false,
    would_modify: [file],
    diff,
    executed: true
  }
}
```

### Resource Constraints

Always enforce limits:

```typescript
interface ToolConstraints {
  max_files: number        // Max files to process
  max_bytes: number        // Max data size
  timeout_ms: number       // Operation timeout
  max_iterations: number   // Loop bounds
  allowed_paths: string[]  // Path allowlist
}

function validateConstraints(params: unknown, constraints: ToolConstraints): void {
  if (params.files?.length > constraints.max_files) {
    throw new Error(`Exceeds max_files limit of ${constraints.max_files}`)
  }
  // ... validate other constraints
}
```

### Tool Security Classification

| Classification | Examples | Controls |
| --- | --- | --- |
| **Read-only** | Search, list, get | Minimal restrictions; no side effects. |
| **Write** | Create, update | Require `dry_run` first; logged. |
| **Destructive** | Delete, overwrite | Human approval required; explicit opt-in. |
| **Privileged** | Deploy, rotate secrets | Explicit authorization; high audit level. |

### Tool Output Redaction

Redact sensitive data in tool outputs:

```typescript
function redactOutput(output: unknown): unknown {
  const patterns = [
    /sk-[a-zA-Z0-9]{48}/g,           // API keys
    /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/g,  // Emails
    /-----BEGIN.*PRIVATE KEY-----/gs  // Private keys
  ]

  let result = JSON.stringify(output)
  for (const pattern of patterns) {
    result = result.replace(pattern, '[REDACTED]')
  }
  return JSON.parse(result)
}
```

---

## Consistency Patterns

### Naming Consistency

| Category | Recommended | Avoid | Rationale |
| --- | --- | --- | --- |
| **CRUD** | `create`, `get`, `update`, `delete` | `add`, `fetch`, `modify`, `remove` | Standardizes operations; reduces guesswork. |
| **Collections** | `list`, `find`, `search` | `getAll`, `query`, `retrieve` | Clarifies if it returns many vs one. |
| **State** | `activate`, `suspend`, `archive` | `on`, `stop`, `bin` | Use clear, predictable action verbs. |
| **Booleans** | `is_active`, `has_permission`, `can_edit` | `active`, `permission`, `edit` | Clearer cognitive map for predicates. |

```javascript
// Consistent naming
userService.createUser()
userService.getUser()
userService.updateUser()
userService.deleteUser()
userService.listUsers()

// Inconsistent naming (avoid)
userService.addUser()
userService.fetchUser()
userService.modifyUser()
userService.removeUser()
userService.getAllUsers()
```

### Response Consistency

```javascript
// Same structure for single and collection responses
// Single
{
  "data": { "id": "123", "name": "User" }
}

// Collection
{
  "data": [
    { "id": "123", "name": "User 1" },
    { "id": "456", "name": "User 2" }
  ]
}

// Error (same structure regardless of endpoint)
{
  "error": { "code": "...", "message": "..." }
}
```

---

## Documentation

### Self-Documenting Design

```typescript
// Good: Name reveals intent
async function sendPasswordResetEmail(email: string): Promise<void>

// Bad: Name is vague
async function process(data: any): Promise<any>
```

### Inline Documentation for APIs

```typescript
/**
 * Searches users by various criteria.
 *
 * @example
 * // Find active users named "John"
 * const users = await searchUsers({
 *   name: 'John',
 *   status: 'active',
 *   limit: 10
 * })
 */
async function searchUsers(criteria: SearchCriteria): Promise<User[]>
```

---

## Evolution and Compatibility

### Adding Without Breaking (Safe Changes)

| Change | Rationale |
| --- | --- |
| **New optional field in response** | Clients expecting old fields continue working. |
| **New optional parameter** | Callers using old signature are unaffected. |
| **New endpoint** | Independent surface area; no impact on existing. |
| **New error code** | Only impacts clients specifically looking for it. |

### Breaking Changes (Versioning Required)

| Change | Impact |
| --- | --- |
| **Removing field** | Runtime failure/deserialization error for clients. |
| **Changing field type** | Type mismatches and logic failures. |
| **Changing required field** | Contract violation; existing clients lack data. |
| **Changing endpoint URL** | Resource becomes unreachable (404). |
| **Changing behavior** | Subtle, dangerous semantic bugs. |

### Backward Compatible Changes

```javascript
// Version 1
{
  "name": "John Doe"
}

// Version 2: Add field without removing old
{
  "name": "John Doe",
  "firstName": "John",
  "lastName": "Doe"
}

// Later: Deprecate old field
{
  "name": "John Doe",          // Deprecated
  "firstName": "John",
  "lastName": "Doe"
}
```

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| --- | --- | --- |
| **Exposing internals** | Coupling to implementation | Abstract behind interface |
| **Inconsistent responses** | Hard to consume | Standardize response format |
| **No validation** | Runtime errors, security | Validate at boundary |
| **Verbs in URLs** | Not RESTful | Use nouns + HTTP methods |
| **Accepting extra fields** | Security risk | Reject unknown fields |
| **Giant response objects** | Performance, complexity | Return only what's needed |
| **Ambiguous errors** | Hard to debug | Specific error codes |
| **Silent breaking changes** | Surprise failures | Version or deprecate |

---

## API Design Checklist

When designing an API:

| Check | Why |
| --- | --- |
| **Named from caller's perspective?** | Ensures usability and intuitive discovery. |
| **Minimal parameters required?** | Reduces cognitive load and complexity. |
| **Consistent with existing patterns?** | Lowers learning curve; follows least surprise. |
| **Input validated at boundary?** | Prevents corruption, attacks, and runtime errors. |
| **Return type predictable?** | Simplifies client consumption logic. |
| **Errors clearly documented?** | Enables robust error handling. |
| **Edge cases handled?** | Prevents unexpected failures in production. |
| **Hard to misuse?** | Safety by design (defensive programming). |
| **Can evolve without breaking?** | Ensures longevity and backward compatibility. |
| **Documented with examples?** | Accelerates integration and correctness. |

---

## See Also

- [Error Handling](../error-handling/error-handling.md) – Handling and returning errors
- [Documentation Guidelines](../documentation-guidelines/documentation-guidelines.md) – Documenting APIs
