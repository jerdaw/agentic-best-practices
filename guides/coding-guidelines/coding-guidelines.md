# Coding Guidelines

Best practices for writing clean, maintainable code that remains readable for both humans and AI coding agents.

> **Scope**: These guidelines apply to general coding practices across any language. They prioritize clarity,
> predictability, and explicit intent to minimize misunderstandings by AI agents.

## Contents

| Section |
| :--- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Variables and Naming](#variables-and-naming) |
| [Functions and Methods](#functions-and-methods) |
| [Control Flow](#control-flow) |
| [Error Handling](#error-handling-1) |
| [Classes and Objects](#classes-and-objects) |
| [Anti-Patterns](#anti-patterns) |
| [Checklist](#checklist) |

---

## Quick Reference

| Category | Guidance | Rationale |
| :--- | :--- | :--- |
| **Naming** | Be descriptive and explicit | Prevents ambiguity for AI |
| **Functions** | Keep them small and single-purpose | Easier to test and reason about |
| **Logic** | Prefer early returns and flat flow | Reduces cognitive load |
| **State** | Minimize global/mutable state | Prevents hidden side effects |
| **Errors** | Use explicit error types | Enables precise error handling |

---

## Core Principles

1. **Clarity over cleverness** – Readable code is better than "smart" code.
2. **Explicit over implicit** – Don't make the agent guess your intent.
3. **Consistency** – Follow the same patterns throughout the codebase.
4. **Self-documenting** – Intent should be clear from names and structure.
5. **Least surprise** – Code should do exactly what its name suggests.

---

## Variables and Naming

Names should reflect the *content* and *purpose* of the variable.

| Pattern | Bad | Good |
| :--- | :--- | :--- |
| **Descriptive** | `d`, `data` | `userProfile`, `monthlyRevenue` |
| **Boolean** | `ready`, `set` | `isReady`, `hasData` |
| **Boolean** | `success` | `wasSuccessful`, `isProcessing` |

---

## Functions and Methods

Functions should do one thing and do it well.

| Attribute | Guideline |
| :--- | :--- |
| **Size** | Aim for < 20 lines |
| **Parameters** | Limit to 3 max (use objects for more) |
| **Purpose** | Single responsibility (SRP) |
| **Naming** | Start with a strong verb (`calculate`, `validate`) |

---

## Control Flow

Keep the logic flat and predictable.

| Do | Avoid |
| :--- | :--- |
| Use early returns | Deeply nested if/else |
| Use ternary for simple assignments | Complex nested ternaries |
| Use specific loops (`find`, `map`) | Generic `for` loops |

```typescript
// Good: Early returns
function processUser(user) {
  if (!user) return null
  if (!user.isActive) return { error: "inactive" }
  
  // Core logic begins here, unnested
  return save(user)
}
```

---

## Error Handling 1

Treat errors as first-class citizens, not an afterthought.

1. **Be specific** – Use custom error classes (e.g., `ValidationError`).
2. **No silent failures** – Never catch and ignore errors.
3. **Contextualize** – Include clean messages and relevant data (no secrets).

---

## Classes and Objects

| Concept | Guideline |
| :--- | :--- |
| **Composition**| Favor composition over inheritance |
| **Immutability**| Default to immutable data structures |
| **Privacy** | Hide internals; expose only minimal API |

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| :--- | :--- | :--- |
| **Magic numbers** | Obscures meaning | Use named constants |
| **Global state** | Side effects everywhere| Use dependency injection |
| **Long functions**| Hard to unit test | Break into smaller helpers |
| **God objects** | Too many responsibilities| Decompose into smaller units |

---

## Checklist

- [ ] Variable names describe purpose?
- [ ] Function is single-purpose?
- [ ] No deeply nested logic?
- [ ] Errors handled explicitly?
- [ ] No magic numbers or strings?


## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| Function exceeds 40 lines | Split into smaller functions | Long functions are untestable and hard to reason about |
| Variable named `data`, `temp`, `result` | Rename to describe content | Vague names force readers to trace assignments |
| More than 3 levels of nesting | Refactor with early returns or extraction | Deep nesting hides bugs and increases cognitive load |
| Ignoring compiler/linter warnings | Fix them — they exist for a reason | Warnings become errors in production |
| "This is just a quick hack" | Write it properly — hacks become permanent | Technical debt compounds exponentially |

---

## See Also

- [Commenting Guidelines](../commenting-guidelines/commenting-guidelines.md) – When to explain
- [Error Handling Patterns](../error-handling/error-handling.md) – Advanced logic
- [Secure Coding](../secure-coding/secure-coding.md) – Safety guidelines
