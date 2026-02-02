# Testing AI-Generated Code

A reference for verifying correctness of AI-generated code through testing—what to test, how to test, and what AI typically misses.

> **Scope**: These patterns help catch bugs in AI-generated code. AI optimizes for the happy path; testing must cover what AI ignores.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Verification Strategy](#verification-strategy) |
| [Edge Cases AI Misses](#edge-cases-ai-misses) |
| [Error Handling Tests](#error-handling-tests) |
| [Async Testing Patterns](#async-testing-patterns) |
| [Property-Based Testing](#property-based-testing) |
| [Mutation Testing](#mutation-testing) |
| [Test Generation Prompts](#test-generation-prompts) |
| [Coverage Considerations](#coverage-considerations) |
| [Anti-Patterns](#anti-patterns) |
| [Golden Tasks and Regression Suites](#golden-tasks-and-regression-suites) |
| [Checklist: AI Code Test Review](#checklist-ai-code-test-review) |

---

## Quick Reference

**Always test these in AI code**:
- Edge cases (null, empty, zero, max values)
- Error conditions (network failures, invalid input)
- Boundary conditions (off-by-one, limits)
- Type coercion issues (JavaScript especially)
- Async behavior (race conditions, timeouts)

**AI-generated tests need review for**:
- Missing edge cases
- Tautological assertions (testing the implementation)
- Mocking too much (tests pass but code fails)
- Happy path bias

**Testing priorities for AI code**:
1. Does it compile/run?
2. Does it handle null/undefined?
3. Does it match expected behavior?
4. Does it handle errors gracefully?

---

## Core Principles

1. **Test the boundaries** – AI focuses on typical cases; bugs live at edges
2. **Test failure paths** – AI often implements only success scenarios
3. **Trust tests, not AI confidence** – AI can be confidently wrong
4. **Verify AI tests** – AI-generated tests may share blind spots with AI code
5. **Run tests before reading** – Don't waste time reviewing broken code

---

## Verification Strategy

### Before Reviewing Code

```
1. Does it compile/typecheck?     → If no, stop and fix
2. Do existing tests pass?        → If no, stop and fix
3. Does the new functionality work? → If no, stop and fix
4. Then review the code
```

### Test Pyramid for AI Code

| Level | What to Test | AI Reliability |
|-------|--------------|----------------|
| **Unit tests** | Individual functions | Medium—AI writes happy path |
| **Integration tests** | Component interactions | Low—AI misses boundaries |
| **Edge case tests** | Unusual inputs | Low—must add manually |
| **Error handling tests** | Failure scenarios | Low—AI often skips |

---

## Edge Cases AI Misses

AI optimizes for typical inputs. Explicitly test these:

### Null and Undefined

```typescript
describe('processUser', () => {
  // AI typically writes this
  it('processes valid user', () => {
    expect(processUser({ name: 'Alice' })).toBe('Alice')
  })

  // AI typically misses these
  it('handles null user', () => {
    expect(processUser(null)).toBe(null)
  })

  it('handles undefined user', () => {
    expect(processUser(undefined)).toBe(null)
  })

  it('handles user with null name', () => {
    expect(processUser({ name: null })).toBe('Anonymous')
  })
})
```

### Empty Values

```typescript
describe('searchItems', () => {
  // Test empty inputs
  it('returns empty for empty array', () => {
    expect(searchItems([], 'query')).toEqual([])
  })

  it('returns all for empty query', () => {
    expect(searchItems(items, '')).toEqual(items)
  })

  it('handles whitespace-only query', () => {
    expect(searchItems(items, '   ')).toEqual(items)
  })
})
```

### Boundary Values

```typescript
describe('pagination', () => {
  // Boundary conditions
  it('handles page 0', () => {
    expect(paginate(items, 0, 10)).toEqual(/* first page */)
  })

  it('handles page beyond data', () => {
    expect(paginate(items, 999, 10)).toEqual([])
  })

  it('handles page size of 0', () => {
    expect(paginate(items, 1, 0)).toEqual([])
  })

  it('handles page size larger than data', () => {
    expect(paginate([1, 2], 1, 100)).toEqual([1, 2])
  })

  it('handles negative page', () => {
    expect(() => paginate(items, -1, 10)).toThrow()
  })
})
```

### Type Coercion (JavaScript)

```typescript
describe('type handling', () => {
  // JavaScript type coercion edge cases
  it('handles numeric strings', () => {
    expect(addNumbers('5', 3)).toBe(8)  // or throws, depending on design
  })

  it('handles NaN', () => {
    expect(addNumbers(NaN, 5)).toBe(/* expected behavior */)
  })

  it('handles Infinity', () => {
    expect(divide(10, 0)).toBe(/* Infinity or error */)
  })

  it('handles boolean coercion', () => {
    expect(processValue(false)).not.toBe(processValue(0))
  })
})
```

---

## Error Handling Tests

AI often implements happy path only. Force error conditions:

### Network Failures

```typescript
describe('fetchData', () => {
  it('handles network timeout', async () => {
    jest.spyOn(global, 'fetch').mockRejectedValue(new Error('timeout'))

    await expect(fetchData('url')).rejects.toThrow('Failed to fetch')
  })

  it('handles 404 response', async () => {
    jest.spyOn(global, 'fetch').mockResolvedValue({
      ok: false,
      status: 404
    })

    const result = await fetchData('url')
    expect(result).toBeNull()
  })

  it('handles 500 response', async () => {
    jest.spyOn(global, 'fetch').mockResolvedValue({
      ok: false,
      status: 500
    })

    await expect(fetchData('url')).rejects.toThrow('Server error')
  })

  it('handles malformed JSON response', async () => {
    jest.spyOn(global, 'fetch').mockResolvedValue({
      ok: true,
      json: () => Promise.reject(new SyntaxError('Invalid JSON'))
    })

    await expect(fetchData('url')).rejects.toThrow()
  })
})
```

### Database Failures

```typescript
describe('saveUser', () => {
  it('handles connection failure', async () => {
    db.connect.mockRejectedValue(new Error('Connection refused'))

    await expect(saveUser(user)).rejects.toThrow('Database unavailable')
  })

  it('handles unique constraint violation', async () => {
    db.insert.mockRejectedValue({
      code: 'UNIQUE_VIOLATION',
      constraint: 'users_email_key'
    })

    await expect(saveUser(user)).rejects.toThrow('Email already exists')
  })

  it('handles timeout', async () => {
    db.insert.mockRejectedValue(new Error('Query timeout'))

    await expect(saveUser(user)).rejects.toThrow('Request timeout')
  })
})
```

### File System Errors

```typescript
describe('readConfig', () => {
  it('handles missing file', async () => {
    jest.spyOn(fs.promises, 'readFile').mockRejectedValue({
      code: 'ENOENT'
    })

    const config = await readConfig('missing.json')
    expect(config).toEqual(defaultConfig)
  })

  it('handles permission denied', async () => {
    jest.spyOn(fs.promises, 'readFile').mockRejectedValue({
      code: 'EACCES'
    })

    await expect(readConfig('protected.json')).rejects.toThrow('Permission denied')
  })

  it('handles corrupted file', async () => {
    jest.spyOn(fs.promises, 'readFile').mockResolvedValue('not json')

    await expect(readConfig('corrupt.json')).rejects.toThrow('Invalid config')
  })
})
```

---

## Async Testing Patterns

AI often misses async edge cases:

### Race Conditions

```typescript
describe('caching', () => {
  it('handles concurrent requests for same key', async () => {
    let fetchCount = 0
    fetchData.mockImplementation(async () => {
      fetchCount++
      await delay(100)
      return 'data'
    })

    // Start two requests simultaneously
    const [result1, result2] = await Promise.all([
      cache.get('key'),
      cache.get('key')
    ])

    expect(result1).toBe('data')
    expect(result2).toBe('data')
    expect(fetchCount).toBe(1)  // Should only fetch once
  })
})
```

### Timeout Handling

```typescript
describe('withTimeout', () => {
  it('resolves if operation completes in time', async () => {
    const fast = () => Promise.resolve('done')

    const result = await withTimeout(fast(), 1000)
    expect(result).toBe('done')
  })

  it('rejects if operation exceeds timeout', async () => {
    const slow = () => new Promise(r => setTimeout(() => r('done'), 2000))

    await expect(withTimeout(slow(), 100)).rejects.toThrow('Timeout')
  })

  it('cleans up after timeout', async () => {
    const cleanup = jest.fn()
    const slow = () => new Promise((_, reject) => {
      const id = setTimeout(() => reject('done'), 2000)
      return () => { clearTimeout(id); cleanup() }
    })

    await expect(withTimeout(slow(), 100)).rejects.toThrow()
    expect(cleanup).toHaveBeenCalled()
  })
})
```

### Order Dependencies

```typescript
describe('initialization', () => {
  it('waits for dependencies before proceeding', async () => {
    const order: string[] = []

    const initDb = jest.fn(async () => {
      await delay(50)
      order.push('db')
    })

    const initCache = jest.fn(async () => {
      order.push('cache')
    })

    await initApp({ initDb, initCache })

    expect(order).toEqual(['db', 'cache'])  // DB must complete first
  })
})
```

---

## Property-Based Testing

When AI code handles many input types, property-based testing finds edge cases:

### Example with fast-check

```typescript
import fc from 'fast-check'

describe('sortUsers', () => {
  it('always returns sorted array', () => {
    fc.assert(
      fc.property(
        fc.array(fc.record({ name: fc.string(), age: fc.integer() })),
        (users) => {
          const sorted = sortUsers(users)

          // Property: result is sorted
          for (let i = 1; i < sorted.length; i++) {
            expect(sorted[i].name >= sorted[i-1].name).toBe(true)
          }
        }
      )
    )
  })

  it('preserves all elements', () => {
    fc.assert(
      fc.property(
        fc.array(fc.record({ name: fc.string(), age: fc.integer() })),
        (users) => {
          const sorted = sortUsers(users)

          // Property: same elements
          expect(sorted.length).toBe(users.length)
          for (const user of users) {
            expect(sorted).toContainEqual(user)
          }
        }
      )
    )
  })
})
```

### Properties to Test

| Property | Description | Example |
|----------|-------------|---------|
| **Idempotence** | Applying twice = applying once | `parse(stringify(x)) = parse(stringify(parse(stringify(x))))` |
| **Roundtrip** | Encode then decode = original | `decode(encode(x)) = x` |
| **Invariants** | Property preserved | `sort(xs).length = xs.length` |
| **Commutativity** | Order doesn't matter | `merge(a, b) = merge(b, a)` |
| **Bounds** | Output within expected range | `0 <= normalize(x) <= 1` |

---

## Mutation Testing

Verify test quality by mutating code and checking if tests catch it:

### Mutation Types

| Mutation | Original | Mutated |
|----------|----------|---------|
| Boundary | `<` | `<=` |
| Constant | `0` | `1` |
| Negation | `if (x)` | `if (!x)` |
| Return value | `return result` | `return null` |
| Remove call | `validate(x)` | (removed) |

### Using Stryker (JavaScript)

```bash
# Install
npm install --save-dev @stryker-mutator/core

# Run
npx stryker run

# Output shows surviving mutants = missing tests
```

### Interpreting Results

| Score | Meaning | Action |
|-------|---------|--------|
| 100% | All mutants killed | Tests are thorough |
| 80-99% | Some gaps | Review surviving mutants |
| < 80% | Significant gaps | Add tests for uncovered logic |

---

## Test Generation Prompts

Ask AI to generate tests, but verify they're comprehensive:

### Effective Prompts

**Generate edge case tests**:
```
Write tests for this function, focusing on edge cases:
- null/undefined inputs
- empty arrays/strings
- boundary values
- error conditions

```typescript
function parseDate(input: string): Date | null {
  // implementation
}
```
```

**Generate failure tests**:
```
Write tests that verify error handling for this API call:
- Network failures
- 4xx responses
- 5xx responses
- Invalid response body
- Timeout

```typescript
async function fetchUser(id: string): Promise<User> {
  // implementation
}
```
```

**Generate property tests**:
```
Write property-based tests using fast-check for:
- Round-trip (serialize/deserialize)
- Invariants (length preservation, order)
- Idempotence where applicable

```typescript
function sortUsers(users: User[]): User[]
function serializeUser(user: User): string
function deserializeUser(data: string): User
```
```

### Review AI-Generated Tests

| Check | What to Look For |
|-------|------------------|
| **Real assertions** | Tests actually check behavior, not just call functions |
| **Independence** | Tests don't depend on each other |
| **No implementation leak** | Tests check behavior, not internal details |
| **Edge coverage** | Includes null, empty, boundary cases |
| **Error paths** | Tests verify error handling |
| **Meaningful names** | Test names describe expected behavior |

**Red flag** – Tautological test:
```typescript
// BAD: Tests the implementation, not behavior
it('returns processed data', () => {
  const result = process(input)
  expect(result).toEqual(process(input))  // Always passes
})

// GOOD: Tests expected behavior
it('uppercases the name', () => {
  const result = process({ name: 'alice' })
  expect(result.name).toBe('ALICE')
})
```

---

## Coverage Considerations

### Coverage Targets

| Code Type | Target | Rationale |
|-----------|--------|-----------|
| AI-generated business logic | 80%+ | AI misses edge cases |
| AI-generated utilities | 90%+ | Should be well-defined |
| Error handling paths | 100% | Critical for reliability |
| Security-sensitive code | 100% | Non-negotiable |

### Coverage Gaps to Watch

| Gap | Risk | Action |
|-----|------|--------|
| Catch blocks not covered | Error handling untested | Force errors in tests |
| Else branches not covered | Edge case untested | Add specific tests |
| Early returns not covered | Validation untested | Test invalid inputs |
| Default cases not covered | Unexpected input handling unknown | Test unusual inputs |

### Coverage Commands

```bash
# JavaScript/TypeScript (Jest)
npm test -- --coverage

# Python
pytest --cov=src tests/

# Go
go test -cover ./...

# View uncovered lines
npm test -- --coverage --coverageReporters=text
```

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| **Happy path only** | Edge cases untested | Explicitly test boundaries |
| **Tautological tests** | Tests pass by definition | Test expected behavior, not implementation |
| **Over-mocking** | Tests pass, code fails | Integration tests with real dependencies |
| **Flaky tests** | Unreliable signal | Fix timing issues, add proper waits |
| **Testing implementation** | Breaks on refactor | Test behavior, not structure |
| **No error path tests** | Errors unhandled in production | Force and test all error conditions |

---

## Golden Tasks and Regression Suites

Use canonical examples to verify AI agent behavior consistently.

### What Are Golden Tasks?

Golden tasks are hand-crafted, well-understood test cases that verify an AI agent produces expected outputs for known inputs.

| Component | Description | Example |
|-----------|-------------|---------|
| **Input** | Specific, reproducible prompt | "Add null check to function X" |
| **Expected behavior** | What agent should do | Read file, add guard clause, run tests |
| **Expected output** | Verifiable result | Specific code change pattern |
| **Success criteria** | How to evaluate | Tests pass, no new errors |

### Building a Golden Task Suite

```yaml
# golden-tasks/null-check.yaml
name: Add null check
category: defensive-coding
input:
  prompt: "Add null check to processUser function"
  context_files:
    - src/users/processor.ts

expected:
  files_modified:
    - src/users/processor.ts
  pattern_present: "if (!user) { return"
  tests_pass: true
  no_regressions: true

validation:
  - grep "if (!user)" src/users/processor.ts
  - npm test
  - git diff --stat | grep "1 file changed"
```

### Running Golden Tasks

```typescript
async function runGoldenTask(task: GoldenTask): Promise<TestResult> {
  // Setup: Create isolated environment
  const env = await createTestEnvironment(task.context_files)

  // Execute: Run agent with task input
  const result = await agent.execute(task.input.prompt, {
    context: env.files
  })

  // Validate: Check all success criteria
  const validations = await Promise.all([
    checkPatternPresent(env, task.expected.pattern_present),
    checkTestsPass(env),
    checkNoRegressions(env),
    checkFilesModified(env, task.expected.files_modified)
  ])

  return {
    task: task.name,
    passed: validations.every(v => v.passed),
    details: validations
  }
}
```

### Regression Detection

Run golden tasks after any agent changes:

| Trigger | Action |
|---------|--------|
| Agent code change | Run full golden suite |
| Prompt update | Run affected golden tasks |
| Model upgrade | Run full suite, compare results |
| Weekly schedule | Detect drift over time |

### Golden Task Categories

| Category | Purpose | Examples |
|----------|---------|----------|
| **Core operations** | Basic functionality | Read file, edit file, run tests |
| **Error handling** | Failure scenarios | Invalid input, missing file |
| **Edge cases** | Boundary behavior | Empty files, large files |
| **Security** | Sensitive operations | No secrets logged, no injection |
| **Multi-step** | Complex workflows | Refactor across files |

### Evaluating Results

```
Golden Task Suite Results
─────────────────────────
Total: 25
Passed: 23
Failed: 2
Skipped: 0

Failed tasks:
  - large-file-handling: Timeout exceeded (300s)
  - unicode-filename: File not found error

Action required: Review failed tasks before deployment
```

---

## Checklist: AI Code Test Review

Before accepting AI-generated code:

- [ ] Code compiles/runs without errors
- [ ] All existing tests pass
- [ ] New tests cover happy path
- [ ] Tests cover null/undefined inputs
- [ ] Tests cover empty values
- [ ] Tests cover boundary conditions
- [ ] Tests cover error conditions
- [ ] Tests cover async edge cases
- [ ] No tautological assertions
- [ ] Coverage meets targets
- [ ] Test names describe behavior
- [ ] Golden tasks pass (if agent work)

---

## See Also

- [Code Review for AI Output](../code-review-ai/code-review-ai.md) – Overall review workflow
- [Debugging with AI](../debugging-with-ai/debugging-with-ai.md) – When tests reveal bugs
