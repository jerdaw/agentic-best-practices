# Code Review for AI-Generated Code

A reference for reviewing code produced by AI coding assistants—what to verify, common mistakes, and red flags to catch.

> **Scope**: These patterns apply to output from any AI coding assistant. AI-generated code requires the same rigor as human code, plus awareness of AI-specific failure modes.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Review Checklist](#review-checklist) |
| [Common AI Mistakes](#common-ai-mistakes) |
| [Hallucination Patterns](#hallucination-patterns) |
| [Security Red Flags](#security-red-flags) |
| [Performance Blind Spots](#performance-blind-spots) |
| [Review Workflow](#review-workflow) |
| [Testing AI-Generated Code](#testing-ai-generated-code) |
| [Anti-Patterns](#anti-patterns) |

---

## Quick Reference

**Always Verify**:

| Check | Why |
| --- | --- |
| **Compiles/Runs** | AI code often hallucinates syntax or imports. |
| **Tests pass** | Verification is the only proof of correctness. |
| **Edge cases** | AI optimizes for the "happy path" and ignores errors. |
| **Security** | AI lacks threat modeling awareness. |
| **No hallucinations** | AI invents APIs, libraries, and methods. |

**Common AI Mistakes**:

| Mistake | Impact |
| --- | --- |
| **Off-by-one** | loops and slices break on boundary conditions. |
| **Missing checks** | `null`/`undefined` cause runtime crashes. |
| **Async errors** | Missing `await` leads to race conditions. |
| **Hallucinations** | Calls to non-existent code cause build failures. |
| **Outdated APIs** | Uses deprecated methods from training data. |

**Red Flags (Inspect Closely)**:

| Flag | Risk |
| --- | --- |
| **Auth logic** | Bypasses or weak checks compromise security. |
| **DB queries** | SQL injection or unoptimized N+1 queries. |
| **File I/O** | Path traversal or data corruption. |
| **External APIs** | Leaked secrets or incorrect parameters. |
| **Crypto** | Weak algorithms (MD5) or bad entropy. |

---

## Core Principles

| Principle | Rationale |
| --- | --- |
| **Compile before reading** | Don't waste time reviewing code that is syntax-invalid. |
| **Tests before trusting** | Confidence != Correctness. Only tests prove function. |
| **Edge cases always** | AI defaults to the simplest case; specific prompts act as constraints. |
| **Verify external calls** | AI's knowledge cutoffs cause API hallucinations. |
| **Security is non-negotiable** | AI generates functional but often insecure code by default. |

---

## Review Checklist

### Universal Checks

| Check | What to Look For | Rationale |
| --- | --- | --- |
| **Compiles/Runs** | No syntax errors, imports resolve, types check. | Basic validity gate. |
| **Tests pass** | All existing tests still pass. | Prevents regressions. |
| **New tests exist** | New functionality has test coverage. | Ensures future stability. |
| **Edge cases** | Null, empty, zero, negative, max values handled. | Robustness against real-world data. |
| **Error handling** | Errors caught, logged, and handled appropriately. | System resilience. |
| **API verification** | All function/method calls exist in actual codebase. | catches hallucinations. |

### Language-Specific Checks

**JavaScript/TypeScript**:

| Check | Common AI Mistake | Fix/Rationale |
| --- | --- | --- |
| `await` on promises | Missing await causes silent bugs. | Ensure all Promises are awaited or returned. |
| `null` vs `undefined` | Wrong nullish check (`== null` vs `=== null`). | Use `??` or strict checks. |
| Array methods | Off-by-one in `.slice()`, wrong comparator in `.sort()`. | Verify indices and sort logic. |
| `this` binding | Arrow vs regular function in callbacks. | Check scope requirements. |
| Optional chaining | Overuse hiding bugs (`?.` everywhere). | Use only when null is valid. |

**Python**:

| Check | Common AI Mistake | Fix/Rationale |
| --- | --- | --- |
| Indentation | Mixed tabs/spaces after editing. | Enforce linting/formatting. |
| Mutable defaults | `def foo(items=[])` creates shared list. | Use `None` as default. |
| Exception handling | Bare `except:` catching everything. | Catch specific exceptions. |
| Type hints | Incorrect types that mypy would catch. | Verify matches implementation. |
| Import errors | Importing from wrong module or nonexistent path. | Verify module paths. |

**Go**:

| Check | Common AI Mistake | Fix/Rationale |
| --- | --- | --- |
| Error handling | Ignoring returned errors (`result, _ := foo()`). | Always check errors. |
| Nil checks | Missing nil checks on pointers. | Guard against panics. |
| Goroutine leaks | No cancellation/timeout context. | Use `context.Context`. |
| Defer order | Deferred calls execute in wrong order. | Remember LIFO execution. |
| Interface satisfaction | Type doesn't implement interface. | Verify implementation compliance. |

**Rust**:

| Check | Common AI Mistake | Fix/Rationale |
| --- | --- | --- |
| Ownership | Borrow checker violations. | Check lifetimes and borrows. |
| Error handling | Unwrapping without checking (`unwrap()`). | Use `match` or `?` operator. |
| Lifetimes | Incorrect lifetime annotations. | Verify scope validity. |
| Pattern matching | Non-exhaustive matches. | Handle all enum variants. |
| Unsafe blocks | Unnecessary or incorrect unsafe usage. | Avoid `unsafe` unless mandatory. |

---

## Common AI Mistakes

### Off-by-One Errors

**Watch for**: Loop bounds, array indices, string slicing, pagination.

```typescript
// AI often writes
for (let i = 0; i <= arr.length; i++)  // Bug: includes arr.length (out of bounds)

// Should be
for (let i = 0; i < arr.length; i++)
```

```typescript
// AI often writes
const lastThree = items.slice(-3, items.length)  // Redundant but works

// Simpler
const lastThree = items.slice(-3)
```

### Null/Undefined Handling

**Watch for**: Chained property access, optional parameters, API responses.

```typescript
// AI often writes
const name = user.profile.displayName  // Crashes if profile is undefined

// Should be
const name = user.profile?.displayName ?? 'Anonymous'
```

### Async/Await Errors

**Watch for**: Missing await, unhandled rejections, parallel vs sequential.

```typescript
// AI often writes
const data = fetchData()  // Missing await - data is a Promise
console.log(data.name)    // Bug: Promise has no .name property

// Should be
const data = await fetchData()
console.log(data.name)
```

```typescript
// AI often writes (sequential when parallel would work)
const user = await getUser(id)
const posts = await getPosts(id)

// Could be parallel
const [user, posts] = await Promise.all([getUser(id), getPosts(id)])
```

### Outdated Syntax/APIs

**Watch for**: Deprecated methods, version-specific features, changed APIs.

| Library | AI Often Uses | Current Approach |
| --- | --- | --- |
| React | Class components | Function components + hooks |
| Express | Callback-based middleware | Async handlers |
| Jest | `done` callbacks | Async/await |
| Node.js | `require()` | ESM `import` (depending on config) |
| Python | `asyncio.get_event_loop()` | `asyncio.run()` |

### Logic Errors in Conditions

**Watch for**: Incorrect boolean logic, wrong operator precedence.

```typescript
// AI often writes
if (!user || user.isAdmin)  // Allows access if no user (wrong)

// Should be
if (user && user.isAdmin)  // Requires user AND admin status
```

---

## Hallucination Patterns

AI invents functions, parameters, and APIs that don't exist.

### Common Hallucinations

| Type | Example | How to Catch |
| --- | --- | --- |
| **Fake methods** | `array.contains()` | Check docs; JavaScript uses `.includes()` |
| **Wrong parameters** | `fs.readFile(path, 'text')` | Verify with actual API docs |
| **Invented packages** | `import { validate } from 'validator-utils'` | Check if package exists |
| **Mixed APIs** | Combining React Query v3 and v5 syntax | Verify against version in use |
| **Fake config options** | `{ cache: 'aggressive' }` | Check valid options |

### Verification Steps

| Step | Rationale/Question |
| --- | --- |
| **1. Check imports** | Does each imported function/class exist in the actual library or project? |
| **2. Verify signatures** | Do parameters match the actual API documentation? |
| **3. Test happy path** | Does it actually work with real data in the local environment? |
| **4. Search codebase** | If uncertain, search the project to see if the function exists elsewhere. |

**Example hallucination**:
```typescript
// AI generated
import { parseJSON } from 'lodash'
const data = parseJSON(response.body)

// Reality: lodash has no parseJSON function
// Correct:
const data = JSON.parse(response.body)
```

---

## Security Red Flags

AI lacks threat modeling. Scrutinize security-sensitive code closely.

### Injection Vulnerabilities

| Type | What AI Does Wrong | What to Check |
| --- | --- | --- |
| **SQL Injection** | String concatenation in queries | Use parameterized queries |
| **XSS** | Unescaped user input in HTML | Escape or use safe templating |
| **Command Injection** | User input in shell commands | Validate and escape input |
| **Path Traversal** | User input in file paths | Validate against allowed paths |

**SQL Injection example**:
```typescript
// AI often writes (VULNERABLE)
const query = `SELECT * FROM users WHERE id = '${userId}'`

// Should be (parameterized)
const query = 'SELECT * FROM users WHERE id = $1'
db.query(query, [userId])
```

**XSS example**:
```typescript
// AI often writes (VULNERABLE)
element.innerHTML = `<div>${userInput}</div>`

// Should be (escaped)
element.textContent = userInput
// Or use a sanitization library
```

### Authentication/Authorization Issues

| Issue | What AI Misses | What to Check |
| --- | --- | --- |
| **Missing auth check** | Forgets to verify logged in | Every protected route checks auth |
| **Broken access control** | Forgets to verify ownership | Users can only access their data |
| **Token handling** | Stores in localStorage | Use httpOnly cookies for tokens |
| **Password handling** | Logs or returns passwords | Never log or echo passwords |

### Cryptography Mistakes

| Mistake | AI Often Does | Correct Approach |
| --- | --- | --- |
| Weak hashing | MD5 for passwords | bcrypt, argon2, scrypt |
| DIY crypto | Custom encryption | Use standard libraries |
| Hardcoded secrets | API keys in code | Environment variables |
| Insecure random | `Math.random()` for tokens | Crypto-secure random |

---

## Performance Blind Spots

AI optimizes for readability, not always performance.

| Issue | AI Pattern | Better Approach |
| --- | --- | --- |
| **N+1 queries** | Loop with query inside | Batch query outside loop |
| **Unnecessary iterations** | Multiple `.map()/.filter()` chains | Combine into single loop |
| **Memory leaks** | Event listeners not removed | Cleanup on unmount/destroy |
| **Blocking operations** | Sync file I/O | Async alternatives |
| **Unbound growth** | Arrays/maps that never clear | Implement eviction policy |

**N+1 query example**:
```typescript
// AI often writes (N+1 queries)
const users = await getUsers()
for (const user of users) {
  user.posts = await getPosts(user.id)  // Query per user
}

// Should be (2 queries total)
const users = await getUsers()
const userIds = users.map(u => u.id)
const allPosts = await getPostsByUserIds(userIds)
const postsByUser = groupBy(allPosts, 'userId')
for (const user of users) {
  user.posts = postsByUser[user.id] ?? []
}
```

---

## Review Workflow

### Before Accepting AI Code

| Step | Action | Question |
| --- | --- | --- |
| 1 | **Compile/run** | Does it execute without errors? |
| 2 | **Run tests** | Do all tests pass? |
| 3 | **Manual test** | Does it work as expected? |
| 4 | **Check imports** | Do all imported functions exist? |
| 5 | **Review security** | Any red flags in security-sensitive areas? |
| 6 | **Edge cases** | How does it handle null, empty, errors? |
| 7 | **Read the diff** | Do you understand every change? |

### Review Depth by Risk Level

| Risk Level | Code Type | Review Approach |
| --- | --- | --- |
| **Critical** | Auth, payments, crypto | Line-by-line; verify against docs |
| **High** | Database queries, file I/O | Test edge cases; check inputs |
| **Medium** | Business logic | Verify correctness; check tests |
| **Low** | UI, formatting | Quick review; trust tests |

### Red Flags Requiring Deep Review

| Flag | Why it's risky |
| --- | --- |
| **Authentication/Authorization** | Privilege escalation potential. |
| **DB Queries (User Input)** | Injection vulnerabilities. |
| **File System (User Input)** | Data corruption or traversal. |
| **External API Calls** | Privacy leaks or cost overruns. |
| **Cryptography** | Irreversible implementation flaws. |
| **Security Config** | Opening vulnerable ports/methods. |
| **Privilege Escalation** | Admin access leakage. |

---

## Testing AI-Generated Code

### Minimum Test Requirements

| Change Type | Required Tests |
| --- | --- |
| New function | At least one happy path test |
| Bug fix | Test that reproduces the bug |
| Edge case handling | Test each edge case handled |
| Security fix | Test that verifies the fix |

### AI-Specific Test Focus

Test what AI tends to miss:

```typescript
describe('parseUserInput', () => {
  // Happy path (AI usually handles)
  it('parses valid input', () => { /* ... */ })

  // Edge cases (AI often misses)
  it('handles null input', () => { /* ... */ })
  it('handles empty string', () => { /* ... */ })
  it('handles whitespace-only input', () => { /* ... */ })
  it('handles maximum length input', () => { /* ... */ })
  it('handles special characters', () => { /* ... */ })
  it('handles unicode', () => { /* ... */ })
})
```

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| --- | --- | --- |
| **Blind acceptance** | Copy-paste without reading | Always review before committing |
| **Trusting AI confidence** | "This should work" means nothing | Test it |
| **Skipping tests** | "AI code is correct" | AI is often wrong; tests catch it |
| **Assuming security** | AI lacks threat awareness | Security review is mandatory |
| **No verification** | Taking API calls at face value | Verify functions exist |
| **Ignoring warnings** | Dismissing type/lint errors | Warnings often catch AI bugs |

---

## See Also

- [Security Boundaries](../security-boundaries/security-boundaries.md) – Security requirements for AI-assisted development
- [Testing AI-Generated Code](../testing-ai-code/testing-ai-code.md) – Verification strategies
