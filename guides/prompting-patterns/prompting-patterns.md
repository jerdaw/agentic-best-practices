# Prompting Patterns for AI Coding Assistants

A reference for crafting effective prompts that get better results from AI coding tools.

> **Scope**: These patterns apply to any AI coding assistant (Claude, Copilot, Cursor, etc.). Examples use generic
> scenarios; adapt to your specific tools and workflows.

## Contents

| Section |
| :--- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Task Decomposition](#task-decomposition) |
| [Context Provision](#context-provision) |
| [Constraint Specification](#constraint-specification) |
| [Iterative Refinement](#iterative-refinement) |
| [Patterns by Task Type](#patterns-by-task-type) |
| [Anti-Patterns](#anti-patterns) |
| [Context Window Awareness](#context-window-awareness) |

---

## Quick Reference

**Five elements of effective prompts**:

1. **Task** – What you want done (verb + object)
2. **Context** – Relevant code, constraints, environment
3. **Format** – How you want the output structured
4. **Constraints** – What to avoid, boundaries to respect
5. **Examples** – Concrete samples of desired output

**Most common mistakes**:

- Vague requests ("make it better")
- Missing context (no code, no error messages)
- Overloaded prompts (multiple unrelated tasks)
- No constraints (agent makes risky assumptions)
- Asking for explanations when you want code (and vice versa)

---

## Core Principles

1. **Specific over vague** – "Add null check for user.email before sending" beats "fix the bug"
2. **Incremental over monolithic** – Break large tasks into steps; validate between each
3. **Constrained over open-ended** – Explicit boundaries prevent unwanted changes
4. **Examples over descriptions** – Show the pattern you want, don't just describe it
5. **Verify over trust** – Review output critically; AI can be confidently wrong

---

## Task Decomposition

Large tasks fail more often. Break them into steps the AI can complete reliably.

| Task Size | Success Rate | Strategy |
| :--- | :--- | :--- |
| Single function | High | Direct request |
| Multiple related functions | Medium | One at a time, verify each |
| Cross-file changes | Low | Explicit file list, order of operations |
| Architectural changes | Very low | Plan first, implement in phases |

### Decomposition Pattern

**Bad** (monolithic):

```text
Implement user authentication with login, registration, password reset,
email verification, OAuth support, and session management.
```

**Good** (decomposed):

```text
Step 1: Create a login function that accepts email/password and returns
a session token. Use bcrypt for password comparison. Return appropriate
error messages for invalid credentials.
```

Then after validation:

```text
Step 2: Create a registration function. Use the same password hashing
as the login function we just created. Validate email format before saving.
```

### When to Decompose

| Signal | Action |
| :--- | :--- |
| Task mentions "and" multiple times | Split on each "and" |
| Touches more than 2-3 files | Do one file at a time |
| Requires decisions you haven't made | Decide first, then implement |
| You can't verify correctness easily | Smaller units are easier to verify |

---

## Context Provision

AI can only use what you provide. Missing context leads to hallucinated solutions.

### What to Include

| Context Type | When to Include | Example |
| :--- | :--- | :--- |
| Error message | Bug fixes | Full stack trace, not just the message |
| Relevant code | Always | The function being modified, its callers |
| Type definitions | Type-related work | Interfaces, types that constrain the solution |
| Constraints | When non-obvious | "Must work in Node 18", "No external deps" |
| Test cases | When behavior matters | Existing tests that must pass |

### Context Ordering

Order matters. Put the most important context first.

**Effective order**:

1. The specific code you want changed
2. Error messages or unexpected behavior
3. Type definitions and interfaces
4. Related functions that interact with this code
5. Project conventions or patterns to follow

**Bad** (buries the task):

```text
Our project uses TypeScript 5.0 with strict mode. We have a custom
logging system in src/logger.ts. The database is PostgreSQL 15.
We use Prisma as our ORM. The API follows REST conventions.

[... 50 more lines of general context ...]

Can you fix the bug in the login function?
```

**Good** (task first, context after):

````text
Fix the null reference error in login():

```typescript
async function login(email: string, password: string) {
  const user = await db.user.findUnique({ where: { email } })
  return user.id  // Error: user might be null
}
```

The function should return null if user not found, or throw
AuthError("Invalid credentials") if password doesn't match.
````

---

## Constraint Specification

Unconstrained AI makes assumptions. Make boundaries explicit.

### Constraint Types

| Constraint | Purpose | Example |
| :--- | :--- | :--- |
| **Scope** | What files/functions to touch | "Only modify the render() method" |
| **Compatibility** | Version/environment limits | "Must work without ES6 modules" |
| **Style** | Code conventions | "Use early returns, no else after return" |
| **Dependencies** | What can/can't be used | "No new dependencies" |
| **Behavior** | What must/must not change | "Don't change the public API" |
| **Performance** | Resource constraints | "Must handle 10k items without blocking" |

### Constraint Template

```text
[Task description]

Constraints:
- Only modify: [specific files or functions]
- Must preserve: [existing behavior, API, tests]
- Don't use: [forbidden dependencies, patterns]
- Must support: [versions, environments, edge cases]
```

**Example**:

```text
Refactor the validation logic in src/forms/user-form.ts to reduce duplication.

Constraints:
- Only modify user-form.ts (don't create new files)
- All existing tests in user-form.test.ts must pass
- Don't change the public validate() function signature
- Don't add new dependencies
- Keep the same error message format
```

---

## Iterative Refinement

First attempts rarely perfect. Plan for iteration.

### Refinement Workflow

```text
Initial prompt → Review output → Identify issues → Targeted follow-up
```

### Follow-up Patterns

| Issue | Follow-up Pattern |
| :--- | :--- |
| Missing edge case | "Also handle the case where X is empty/null/undefined" |
| Wrong approach | "Instead of X, use Y because [reason]" |
| Partial solution | "Good, now also add [specific missing piece]" |
| Style mismatch | "Rewrite using [pattern] like in [example file]" |
| Over-engineered | "Simplify this—we don't need [feature]. Just [core requirement]" |

### Refinement Examples

**Missing edge case**:

```text
Good start, but also handle:
- Empty array input (should return empty array)
- Array with single item (shouldn't call compare function)
```

**Wrong approach**:

```text
This uses polling, but we need WebSockets for real-time updates.
Rewrite using the ws library to match our existing chat implementation.
```

**Over-engineered**:

```text
This is more complex than needed. Remove the factory pattern
and caching layer. Just return the parsed config directly.
```

---

## Patterns by Task Type

### Bug Fixes

**Template**:

````text
Bug: [One-line description]

Error: [Exact error message or unexpected behavior]

Code:
```[language]
[The buggy code with context]
```

Expected: [What should happen]
Actual: [What currently happens]

[Optional: Your hypothesis about the cause]
````

**Example**:

````text
Bug: User registration fails silently when email already exists

Error: No error thrown, but user not created and no feedback shown

Code:
```typescript
async function register(email: string, password: string) {
  const existing = await db.user.findUnique({ where: { email } })
  if (existing) return  // Silent failure here
  await db.user.create({ data: { email, password: hashPassword(password) } })
}
```

Expected: Throw an error or return a result indicating email taken
Actual: Returns undefined, caller has no way to know what happened
````

### Feature Implementation

**Template**:

```text
Add [feature] to [component/module].

Behavior:
- When [trigger], it should [action]
- [Additional behaviors]

Constraints:
- [Scope limits]
- [What must not change]

Match the pattern in [existing similar code] for consistency.
```

**Example**:

```text
Add retry logic to the API client's fetch() method.

Behavior:
- On 5xx errors, retry up to 3 times with exponential backoff
- On 4xx errors, don't retry (fail immediately)
- Log each retry attempt at debug level

Constraints:
- Only modify src/api/client.ts
- Don't change the fetch() function signature
- Use the existing logger from src/utils/logger.ts

Match the retry pattern in src/services/email.ts for consistency.
```

### Refactoring

**Template**:

```text
Refactor [target] to [goal].

Current problem: [What's wrong with current code]

Desired outcome:

- [Specific improvement 1]
- [Specific improvement 2]

Constraints:

- All tests in [test file] must pass
- Don't change public API
```

**Example**:

```text
Refactor the UserService class to use dependency injection.

Current problem: UserService instantiates its own dependencies,
making it hard to test and tightly coupled to implementations.

Desired outcome:

- Constructor accepts repository and logger as parameters
- No direct instantiation of dependencies inside the class
- Default parameter values for production use

Constraints:

- All tests in user-service.test.ts must pass
- Don't change the method signatures (only constructor)
- Update the DI container registration in src/container.ts
```

### Code Explanation

**Template**:

````text
Explain [what you want explained]:

```[language]
[The code]
```

Focus on: [Specific aspects you want clarified]
Skip: [What you already understand]
````

**Example**:

````text
Explain the control flow in this Redux middleware:

```typescript
const apiMiddleware = store => next => action => {
  if (action.type !== 'API_CALL') return next(action)
  // ... rest of implementation
}
```

Focus on: Why there are three arrow functions nested like this
Skip: Basic Redux concepts (I know what middleware does)
````

### Code Review Requests

**Template**:

````text
Review this code for [focus areas]:

```[language]
[The code]
```

Look for: [Specific concerns]
Context: [Relevant background]
````

**Example**:

````text
Review this authentication middleware for security issues:

```typescript
const authMiddleware = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1]
  const decoded = jwt.decode(token)
  req.user = decoded
  next()
}
```

Look for: Security vulnerabilities, missing validation, edge cases
Context: This runs on every authenticated route in our Express app
````

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| :--- | :--- | :--- |
| **Vague request** | AI guesses what you want | Be specific: what, where, how |
| **Missing context** | AI invents details | Include relevant code |
| **Overloaded prompt** | AI loses focus | One task at a time |
| **Implicit constraints** | AI violates assumptions | State all boundaries |
| **Asking to "improve"** | No success criteria | Define "better" |
| **Leading questions** | Confirms bias | Ask neutral questions |
| **No examples** | AI picks wrong pattern | Show what you want |
| **Explaining solution** | Biases AI | Describe the problem |

### Anti-Pattern Examples

**Vague** (bad):

```text
Make the search faster.
```

**Specific** (good):

```text
The search function in src/search.ts takes 3+ seconds for queries
with >1000 results. Add pagination to return 50 results at a time
with a cursor for fetching more.
```

**Overloaded** (bad):

```text
Fix the login bug, add password reset, update the tests, and refactor
the user service to be cleaner.
```

**Focused** (good):

```text
Fix the login bug where users with '+' in their email can't log in.
The email is being URL-decoded somewhere, converting '+' to space.
```

**Implicit constraints** (bad):

```text
Add a cache to the API.
```

**Explicit constraints** (good):

```text
Add in-memory caching to the getUser API endpoint.

- Cache for 5 minutes
- Use the existing cache utility in src/utils/cache.ts
- Invalidate on user update
```

---

## Context Window Awareness

AI has limited context. Large conversations degrade response quality.

| Symptom | Cause | Fix |
| :--- | :--- | :--- |
| AI forgets instructions | Context pushed out | Repeat key constraints |
| Contradicts previous | Lost history | Start fresh session |
| Ignores code | Code too far back | Re-share relevant snippets |
| Generic responses | Overloaded context | Reduce scope |

### Managing Long Sessions

**Do**:

- Start fresh for unrelated tasks
- Re-state critical constraints
- Share only relevant code
- Summarize decisions

**Don't**:

- Keep adding to one endless conversation
- Assume AI remembers everything
- Share entire codebase "for context"
- Mix multiple unrelated topics

---

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| Third attempt at the same prompt with no progress | Switch to manual or completely reframe the task | Repeating failed prompts wastes time; the approach is wrong |
| Prompt is longer than the expected output | Simplify — you're over-constraining | Over-specified prompts confuse the model |
| Response requires heavy editing to use | Break the task into smaller prompts | Large prompts produce low-quality output |
| AI confidently produces wrong code | Verify assumptions — provide tests or examples | Confident errors are the most dangerous kind |
| "Make it better" without criteria | Define what "better" means — faster, cleaner, safer | Vague requests get vague results |

---

## See Also

- [Context Management](../context-management/context-management.md) – Managing what context to provide
- [Debugging with AI](../debugging-with-ai/debugging-with-ai.md) – Effective error reporting patterns
- [PRD for Agents](../prd-for-agents/prd-for-agents.md) – Structured specs for complex prompts
- [Cost & Token Management](../cost-token-management/cost-token-management.md) – Token-efficient prompting
