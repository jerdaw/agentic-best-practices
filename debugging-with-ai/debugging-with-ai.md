# Debugging with AI Assistants

A reference for effectively debugging code with AI assistance—how to report errors, structure debugging sessions, and know when to change approaches.

> **Scope**: These patterns help you get useful debugging assistance from AI. Clear problem statements lead to accurate diagnoses.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Error Reporting Format](#error-reporting-format) |
| [Stack Trace Presentation](#stack-trace-presentation) |
| [Reproduction Steps](#reproduction-steps) |
| [Log Formatting for AI](#log-formatting-for-ai) |
| [Iterative Debugging Workflow](#iterative-debugging-workflow) |
| [Structured Debugging Session](#structured-debugging-session) |
| [When to Switch Approaches](#when-to-switch-approaches) |
| [Environment Information](#environment-information) |
| [Anti-Patterns](#anti-patterns) |
| [Debugging Prompt Templates](#debugging-prompt-templates) |

---

## Quick Reference

| Best Practice | Description | Rationale |
| --- | --- | --- |
| **Report Errors** | Exact message, relevant stack trace, and reproduction steps. | Eliminates guesswork and identifies the specific failure point. |
| **Avoid Vague** | "It doesn't work", paraphrased errors, or screenshots. | Paraphrasing loses technical details critical for diagnosis. |
| **Workflow** | Reproduce → Gather Info → Present to AI → Try Fix. | Ensures the fix is verifiable and targets the right symptoms. |

---

## Core Principles

| Principle | Rationale |
| --- | --- |
| **Precision Matters** | Exact errors lead to exact solutions; summaries lead to guesses. |
| **Context is Key** | The error text alone is rarely enough; show the code that caused it. |
| **Reproduce First** | If you can't reproduce it, you (and the AI) can't verify the fix. |
| **One at a Time** | Fix one error chain at a time to avoid confusion. |
| **Know When to Stop** | If AI is stuck in a loop, switch to manual debugging. |

---

## Error Reporting Format

### Template

```markdown
**Error**: [Exact error message]

**Stack trace**:
[Full or relevant stack trace]

**Code**:
[The code where error occurs]

**Expected**: [What should happen]
**Actual**: [What actually happens]

**Reproduction steps**:
1. [Step 1]
2. [Step 2]
3. [Error occurs at step N]
```

### Good vs Bad Reports

**Bad**:

```text
My function doesn't work when I call it.
```

**Good**:

```markdown
**Error**: TypeError: Cannot read property 'name' of undefined

**Stack trace**:
TypeError: Cannot read property 'name' of undefined
    at formatUser (src/utils/format.ts:15:20)
    at Array.map (src/api/users.ts:42:30)
    at getFormattedUsers (src/api/users.ts:41:15)

**Code**:
\`\`\`typescript
function formatUser(user: User) {
  return `${user.name} <${user.email}>`  // Line 15
}

async function getFormattedUsers() {
  const users = await db.users.findMany()  // Line 41
  return users.map(formatUser)             // Line 42
}
\`\`\`

**Expected**: Return array of formatted user strings
**Actual**: Crashes with TypeError

**Reproduction**: Call getFormattedUsers() when database has a deleted user record with null values
```

---

## Stack Trace Presentation

### What to Include

| Component | When to Include | Rationale |
| --- | --- | --- |
| **Error type and message** | Always | Defines the problem. |
| **First 5-10 frames** | Always | Shows existing context. |
| **Frames in your code** | Always | Identifies your bug location. |
| **Framework internals** | Only if relevant | Usually noise unless debugging the framework. |
| **Full trace** | Only if short (< 20 lines) | Avoids overwhelming token limits. |

### Trimming Stack Traces

**Full trace** (too long):

```text
TypeError: Cannot read property 'name' of undefined
    at formatUser (src/utils/format.ts:15:20)
    at Array.map (<anonymous>)
    at getFormattedUsers (src/api/users.ts:42:30)
    at async processRequest (src/server/handler.ts:78:15)
    at async Router.<anonymous> (node_modules/express/lib/router/index.js:284:5)
    at async Layer.handle (node_modules/express/lib/router/layer.js:95:5)
    at async next (node_modules/express/lib/router/route.js:144:13)
    [... 30 more lines of framework code ...]
```

**Trimmed** (focus on your code):

```text
TypeError: Cannot read property 'name' of undefined
    at formatUser (src/utils/format.ts:15:20)
    at Array.map (...)
    at getFormattedUsers (src/api/users.ts:42:30)
    at async processRequest (src/server/handler.ts:78:15)
    [truncated: Express middleware chain]
```

### Multiple Error Types

For different errors, be explicit about which is which:

```markdown
**Primary error** (what the user sees):
Error: Failed to load user profile

**Underlying error** (from logs):
PostgreSQL Error: connection refused
    at Connection.connect (node_modules/pg/lib/connection.js:45:11)
```

The user-facing error wraps a database connection issue.

---

## Reproduction Steps

### Minimal Reproduction

Narrow down to the smallest case that triggers the error:

| Type | Steps | Rationale |
| --- | --- | --- |
| **Too broad** | 1. Start App; 2. Log in; 3. Navigate to settings; 4. Change theme; 5. Go to profile; 6. Error | **Ineffective** - Includes irrelevant possibilities. |
| **Minimal** | 1. Call `getUserProfile(userId)` where userId is a soft-deleted user; 2. Error occurs | **Effective** - Isolates the exact cause. |

### Reproduction Types

| Type | When to Use | Example | Rationale |
| --- | --- | --- | --- |
| **Code snippet** | Can reproduce in isolation | `runThisFunction()` crashes | Fastest loop; no external deps needed. |
| **API call** | HTTP-triggered issues | `curl -X POST /api/users` fails | Isolates backend logic from UI state. |
| **User flow** | UI-dependent issues | Click button X, then Y, see error | Captures complex state interactions. |
| **Data state** | Data-dependent issues | Happens only with this record | Pinpoints edge cases in data handling. |

### Intermittent Issues

For non-deterministic bugs:

```markdown
**Error**: Connection timeout

**Frequency**: ~1 in 10 requests

**Pattern observed**:
- More frequent under load
- Usually happens on first request after idle period
- Never happens in development, only in production

**What I've tried**:
- Increased timeout from 5s to 30s (still occurs)
- Added connection pooling (still occurs)
- Checked database logs (no errors on DB side)
```

---

## Log Formatting for AI

### Effective Log Presentation

**Structure logs for clarity**:

```text
**Request flow** (timestamps and correlation ID: abc123):

10:42:01.234 [abc123] INFO  Received POST /api/orders
10:42:01.235 [abc123] DEBUG Validating request body
10:42:01.240 [abc123] DEBUG Fetching user from database
10:42:01.350 [abc123] DEBUG User found: id=user_789
10:42:01.351 [abc123] DEBUG Creating order
10:42:01.450 [abc123] ERROR Failed to create order: UNIQUE_VIOLATION
10:42:01.451 [abc123] INFO  Returning 400 response

**Relevant code**:
\`\`\`typescript
// src/services/order.ts:45
await db.order.create({ data: orderData })
\`\`\`
```

### What to Highlight

| Log Type | Presentation | Rationale |
| --- | --- | --- |
| **Error logs** | Full entry with context | AI needs the specific failure details. |
| **Surrounding logs** | Include to show flow | Context helps AI understand state before failure. |
| **Previous successful request** | Show for comparison | Helps spot deviation patterns. |
| **Irrelevant logs** | Omit or summarize | Reduces noise and token usage. |

### Log Comparison

Show working vs broken for comparison:

```text
**Working request** (order created successfully):
10:40:01 Received POST /api/orders
10:40:01 Validating request body
10:40:01 Creating order
10:40:01 Order created: order_123
10:40:01 Returning 201 response

**Failing request** (same endpoint, different data):
10:42:01 Received POST /api/orders
10:42:01 Validating request body
10:42:01 Creating order
10:42:01 ERROR: UNIQUE_VIOLATION on orders.external_id
10:42:01 Returning 400 response

**Difference**: Failing request has external_id that already exists
```

---

## Iterative Debugging Workflow

### Initial Report → Fix Attempt → Iteration

**Step 1**: Report the issue clearly

```markdown
Error: User not found after registration

After calling registerUser(), the subsequent getUserById()
returns null even though registration succeeded.

[code and stack trace]
```

**Step 2**: AI suggests fix, you try it

**Step 3**: Report results

```markdown
Your suggestion to await the database write didn't fix it.

New observation: The user IS in the database (verified with raw query),
but getUserById() still returns null.

Here's the getUserById code:
[code]
```

**Step 4**: Continue iterating with new information

### Reporting Fix Attempts

When AI's suggestion doesn't work:

| Guideline | Rationale |
| --- | --- |
| **Report failure specifics** | Generic "didn't work" gives AI zero new information. |
| **Share new error state** | The error often changes (e.g., from crash to logical error). |
| **Report what changed** | Partial fixes are clues to the root cause. |
| **Don't assume AI context** | AI doesn't see your screen; explicit reporting is required. |

**Good follow-up**:

```markdown
I tried your suggestion to add null check on line 15.

The original error is gone, but now I get a different error:
"User email is required" at line 23.

Here's the updated code:
[code]

It seems the user object is now `{}` instead of undefined.
```

---

## Structured Debugging Session

### Session Template

```markdown
## Problem Summary
[One sentence describing the symptom]

## Error Details
[Exact error, stack trace, code]

## What I've Tried
1. [Attempt 1 and result]
2. [Attempt 2 and result]

## Current Hypothesis
[What you think might be wrong]

## Questions
1. [Specific question]
2. [Specific question]
```

### Example Session

```markdown
## Problem Summary
WebSocket connections drop silently after ~30 seconds of inactivity.

## Error Details
No error thrown. Connection just closes with code 1006 (abnormal closure).

Client code:
\`\`\`javascript
const ws = new WebSocket('wss://api.example.com/ws')
ws.onclose = (e) => console.log('Closed:', e.code, e.reason)
// Logs: "Closed: 1006 ''"
\`\`\`

Server code:
\`\`\`javascript
wss.on('connection', (ws) => {
  console.log('Client connected')
  // No heartbeat/ping configured
})
\`\`\`

## What I've Tried
1. Added client-side ping every 15s - still disconnects
2. Checked server logs - no errors, no close event logged
3. Tested locally - works fine, only fails in production

## Current Hypothesis
Something between client and server (load balancer? proxy?) is closing
idle connections. The 30-second timing is suspiciously round.

## Questions
1. How do I implement proper WebSocket keep-alive?
2. What production infrastructure might cause this?
```

---

## When to Switch Approaches

### Signs AI Debugging Isn't Working

| Signal | What It Means | Action | Rationale |
| --- | --- | --- | --- |
| **3+ failed suggestions** | May need more context | Share more code, try different angle | Definition of insanity: attempting same fix repeatedly. |
| **Going in circles** | Same suggestions repeated | Step back, gather more info | AI is stuck in a local minimum; needs fresh data. |
| **AI guessing without data** | Insufficient information | Add logging, reproduce more carefully | Hallucination risk increases when data is scarce. |
| **Problem beyond AI scope** | Infrastructure/environment issue | Debug manually or consult specialist | AI cannot see your network or server configs directly. |

### Alternative Approaches

| When AI Struggles | Try Instead | Rationale |
| --- | --- | --- |
| **Intermittent failures** | Add extensive logging | Patterns only emerge from large datasets. |
| **Performance issues** | Use profiler, measure first | Guessing at bottlenecks is usually wrong. |
| **Infrastructure problems** | Check configs, network | The bug is likely outside the code logic. |
| **Concurrency bugs** | Use debugger, add assertions | Timing issues are hard to catch with static analysis. |
| **Memory issues** | Use memory profiler | Leaks are invisible in source code snippets. |

### When to Debug Manually

| Situation | Manual is Better | Rationale |
| --- | --- | --- |
| **Step-through needed** | Use debugger | AI simulates execution; debuggers show reality. |
| **State observation** | Use logging | Seeing the data transform is truth. |
| **Environmental** | Check configs | You have access to the machine; AI does not. |
| **Learning** | Read code yourself | Building your own mental model is critical long-term. |
| **Repeated failure** | Trust your investigation | Human intuition beats AI hallucination in edge cases. |

---

## Environment Information

### What to Include When Relevant

| Category | Include | Rationale |
| --- | --- | --- |
| **Runtime** | Node 20.10.0, Python 3.11, etc. | Features and bugs vary wildly by version. |
| **OS** | macOS 14, Ubuntu 22.04, Windows 11 | Path separators, signals, and shells differ. |
| **Package versions** | Specific dependencies involved | Breaking changes happen; exact versions matter. |
| **Environment** | Development, staging, production | Configurations (DB, auth) differ by env. |
| **Configuration** | Relevant settings that differ | "It works on my machine" is usually config drift. |

### Info Template

```markdown
**Environment**:
- Runtime: Node.js 20.10.0
- OS: Ubuntu 22.04
- Relevant packages: express@4.18.2, pg@8.11.0
- Environment: Production
- Note: Works in development, fails in production only
```

---

## Anti-Patterns

| Anti-Pattern | Problem | Rationale |
| --- | --- | --- |
| **Vague reports** | "It doesn't work" | Provides zero diagnostic data for the AI. |
| **Paraphrased errors** | Loss of detail | Omits specific error codes or memory addresses. |
| **Missing code** | Zero visibility | AI cannot analyze what it cannot see. |
| **Screenshot of text** | Machine unreadable | Prevents efficient copy-pasting and analysis. |
| **Too much context** | High noise | Drowns the signal in irrelevant logic. |
| **Not trying fixes** | Stale iteration | Prevents moving to the next potential solution. |
| **Silent failure** | Loop risk | If the AI doesn't know it failed, it will repeat the mistake. |
| **Guessing fixes** | Inefficient | Leads to architectural thrash without verification. |

---

## Debugging Prompt Templates

### Standard Bug

```markdown
I'm getting an error in [function/file]:

**Error**: [exact error message]

**Stack trace**:
\`\`\`
[stack trace]
\`\`\`

**Code**:
\`\`\`[language]
[relevant code]
\`\`\`

**Expected**: [what should happen]
**Actual**: [what happens instead]

What could cause this?
```

### Not An Error, But Wrong Behavior

```markdown
This code runs without errors but produces wrong results:

\`\`\`[language]
[code]
\`\`\`

**Input**: [sample input]
**Expected output**: [what it should return]
**Actual output**: [what it returns]

Where's the logic error?
```

### Performance Issue

```markdown
This code is too slow:

\`\`\`[language]
[code]
\`\`\`

**Input size**: [how much data]
**Current time**: [how long it takes]
**Target time**: [acceptable duration]

**Profiler output** (if available):
[profiler results]

What's causing the slowdown?
```

### Intermittent Issue

```markdown
This issue happens intermittently:

**Error** (when it occurs): [error message]

**Frequency**: [how often]

**Pattern**:
- Happens when: [conditions]
- Never happens when: [other conditions]

**What I've tried**:
1. [attempt and result]

What could cause intermittent behavior?
```

---

## See Also

- [Prompting Patterns](../prompting-patterns/prompting-patterns.md) – Structuring effective prompts
- [Context Management](../context-management/context-management.md) – Providing the right context
