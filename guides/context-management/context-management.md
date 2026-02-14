# Context Management for AI

Best practices for providing the right amount of context to AI coding agents to ensure high-quality results.

> **Scope**: Applies to managing context windows in AI chat and agentic workflows. Focus is on maximizing the relevance
> of information while minimizing token waste and noise.

## Contents

| Section |
| :--- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Context Elements](#context-elements) |
| [Context Pruning](#context-pruning) |
| [Managing Long Sessions](#managing-long-sessions) |
| [Anti-Patterns](#anti-patterns) |

---

## Quick Reference

| Category | Guidance | Rationale |
| :--- | :--- | :--- |
| **Selection** | Provide only relevant files | Prevents model distraction |
| **Hierarchy** | Put critical instructions at top/bottom | Better attention at the "poles" |
| **State** | Clear the context between unrelated tasks | Prevents cross-task contamination |
| **Limits** | Respect the model's context window | Prevents information loss |
| **Feedback** | Ask the agent if it has enough context | Self-correction by the agent |

---

## Core Principles

1. **Relevance over volume** – More context is not always better.
2. **Contextual grounding** – Connect abstract tasks to concrete code and tests.
3. **Signal-to-noise** – Every token provided should serve the current task.
4. **Incremental context** – Add context as it becomes necessary.
5. **Clean state** – Don't carry baggage from previous unrelated conversations.

---

## Context Elements

What an agent needs to succeed:

| Element | Level | Example |
| :--- | :--- | :--- |
| **Task** | Required | "Fix the login bug in `auth.service.ts`" |
| **Source** | Required | The content of relevant files |
| **Types** | High | Interface definitions and schemas |
| **Tests** | High | Existing behavior specifications |
| **Logs** | High | Error messages and stack traces |
| **Env** | Medium | OS, Runtime, and dependencies |

---

## Context Pruning

Techniques to keep the context window focused.

| Technique | Implementation |
| :--- | :--- |
| **Snippet selection** | Provide only the relevant function, not the whole file |
| **Outline mode** | Provide only function signatures/headers |
| **Doc stripping** | Remove verbose comments from shared code |
| **Focus area** | Explicitly tell the AI which 2-3 files are critical |

### Examples

**Good: Focused context with file tree**

```
I need to fix authentication. Relevant structure:
src/
  auth/
    auth.service.ts    # Contains validateToken()
    auth.controller.ts # Route handlers
  types/
    user.types.ts      # User interface

Error: "Invalid token" on line 42 of auth.service.ts
```

**Bad: Context dump**

```
Here's my entire src/ folder (150 files)...
Can you fix authentication?
```

**Good: Snippet with types**

```typescript
// user.types.ts
interface User {
  id: string;
  email: string;
  role: 'admin' | 'user';
}

// auth.service.ts - Line 42 fails here
function validateToken(token: string): User | null {
  const decoded = jwt.verify(token, SECRET); // Error: SECRET undefined
  return decoded as User;
}
```

**Bad: Missing type context**

```typescript
// Just the broken function, AI doesn't know what User is
function validateToken(token: string) {
  return jwt.verify(token, SECRET);
}
```

---

## Managing Long Sessions

As conversations grow, the "attention" of the AI diminishes.

1. **Checkpoints** – Periodically summarize the state of the work.
2. **Fresh Sessions** – When starting a new feature, start a new chat.
3. **Context Refresh** – Re-share modern versions of files if they changed significantly.
4. **Explicit Forgetting** – Tell the AI to ignore previous, failed attempts.

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| :--- | :--- | :--- |
| **Context Dump** | Sharing the whole `src/` folder | Share only related files |
| **Missing Types** | AI doesn't know the contracts | Always include relevant interfaces |
| **Stale Code** | AI works on old versions | Refresh context after major changes |
| **Infinite Chat** | AI loses track of the goal | Refresh session after 10-15 turns |
| **Implicit Rules** | AI violates project norms | Use `AGENTS.md` for persistent rules |

---

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| Sharing the entire `src/` folder as context | Share only the 2-3 relevant files | Context dumps dilute signal and waste tokens |
| Continuing a stale session past 15+ turns | Start a fresh session with a summary | AI attention degrades as context grows |
| Mixing unrelated tasks in one session | Start separate sessions per task | Cross-task context causes hallucinations and contradictions |
| Not re-sharing files after significant edits | Refresh context with current versions | AI is working with outdated code |
| Ignoring context window limits | Prune and prioritize — include types and tests first | Exceeding limits causes silent information loss |

---

## See Also

- [Prompting Patterns](../prompting-patterns/prompting-patterns.md) – Crafting effective prompts
- [AGENTS.md Guidelines](../agents-md/agents-md-guidelines.md) – Persistent context
- [Multi-File Refactoring](../multi-file-refactoring/multi-file-refactoring.md) – Large scale context
