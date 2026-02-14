# Commenting Guidelines

Best practices for writing code comments that clarify intent for both humans and AI coding agents.

> **Scope**: These guidelines apply to all inline comments and documentation blocks. The focus is on explaining "why"
> rather than "what," as AI agents can usually infer the "what" from the code itself.

## Contents

| Section |
| :--- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [When to Comment](#when-to-comment) |
| [Documentation Blocks](#documentation-blocks) |
| [Inline Comments](#inline-comments) |
| [TODOs and FIXMEs](#todos-and-fixmes) |
| [Comment Anti-Patterns](#comment-anti-patterns) |

---

## Quick Reference

| Category | Guidance | Rationale |
| :--- | :--- | :--- |
| **Logic** | Don't explain what the code does | Code should be self-documenting |
| **Rationale**| Explain why it was done this way | Context the AI can't infer |
| **Warnings** | Document non-obvious side effects | Prevents agents from breaking things |
| **TODOs** | Include name, date, and issue link | Enables tracking and follow-up |
| **Types** | Use type hints/JSDoc for interfaces| Provides critical contract context |

---

## Core Principles

1. **Self-documenting first** – If you need a comment to explain "what," refactor the code instead.
2. **Context is king** – Explain business rules, external constraints, and intentional trade-offs.
3. **Keep it current** – Stale comments are worse than no comments.
4. **Be concise** – Agents consume tokens; don't waste them on fluff.
5. **Standardized format** – Use consistent styles for doc blocks within the project.

---

## When to Comment

| Situation | Comment? | Why |
| :--- | :--- | :--- |
| Complex algorithm | Yes | Explains the "how" and "why" |
| Business rule | Yes | Context not present in the code |
| Workaround | Yes | Prevents "fixes" that re-introduce bugs |
| Standard logic | No | AI can read the code faster |
| Getter/Setter | No | Redundant and noisy |

---

## Documentation Blocks

Use structured documentation for public APIs and complex internal functions.

```typescript
/**
 * Calculates the final price including tax and shipping.
 * 
 * @param amount - The base price in cents.
 * @param region - Used to determine tax rate (must be ISO-2).
 * @returns The total price in cents.
 * @throws {ValidationError} If region is invalid.
 */
function calculateTotal(amount: number, region: string): number {
  // ...
}
```

---

## Inline Comments

Keep these brief and focused on specific non-obvious lines.

```typescript
// Good: Explaining a non-obvious business constraint
if (retryCount > 3) {
  return fail() // 3 retries is the maximum allowed by PaymentProvider
}

// Bad: Explaining obvious code
const count = items.length // Get the length of items
```

---

## TODOs and FIXMEs

Always include owner and context.

| Tag | Purpose | Example |
| :--- | :--- | :--- |
| `TODO` | Feature/improvement | `// TODO(alice): Use Redis for caching (Issue #45)` |
| `FIXME` | Known bug | `// FIXME(bob): This fails on leap years` |
| `NOTE` | Important context | `// NOTE: This must stay in sync with API v2` |

---

## Comment Anti-Patterns

| Anti-Pattern | Problem | Fix |
| :--- | :--- | :--- |
| **The "What" Comment** | Redundant noise | Replace with better naming |
| **The Novel** | Too long to read | Be concise or use external docs |
| **The Ghost** | Outdated info | Update or delete |
| **The Apology** | "I'm sorry this is messy"| Clean up the code instead |
| **Commented-out code** | Clutters codebase | Delete it; use Git history |

---

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| Comment restates what the code already says (`// increment i`) | Delete the comment | Redundant comments add noise and go stale |
| Comment explains "what" instead of "why" | Rewrite to explain intent or business reason | Code shows what — only comments explain why |
| TODO comment with no owner or issue link | Add a tracker link or delete | Ownerless TODOs never get resolved |
| Large block of commented-out code checked in | Delete it — use git history instead | Dead code confuses readers and AI agents |

---

## See Also

- [Coding Guidelines](../coding-guidelines/coding-guidelines.md) – Clean code practices
- [Documentation Guidelines](../documentation-guidelines/documentation-guidelines.md) – High-level docs
- [Code Review with AI](../code-review-ai/code-review-ai.md) – Checking for comment quality
