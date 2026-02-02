# PRD for AI Agents

Best practices for writing Product Requirements Documents and feature specifications that AI coding agents can consume effectively.

> **Scope**: These guidelines apply to any specification document given to AI agents—PRDs, feature specs, task descriptions, or issue bodies. The goal is structured input that produces predictable, high-quality output.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Specification Structure](#specification-structure) |
| [Writing Effective Requirements](#writing-effective-requirements) |
| [The CARE Framework](#the-care-framework) |
| [Decomposition Strategies](#decomposition-strategies) |
| [Anti-Patterns](#anti-patterns) |
| [Checklist](#checklist) |

---

## Quick Reference

### Essential Elements

| Element | Purpose | Example |
| --- | --- | --- |
| **Goal** | What success looks like | "Users can reset passwords via email" |
| **Inputs** | Data the agent will receive | "Email address, user ID, timestamp" |
| **Outputs** | Expected artifacts | "Password reset endpoint, email template" |
| **Constraints** | Boundaries and requirements | "Must use existing email service" |
| **Acceptance Criteria** | How to verify completion | "Reset link expires in 1 hour" |

### Common Mistakes

| Mistake | Impact | Fix |
| --- | --- | --- |
| **Vague goals** | Agent guesses at intent | Specific, measurable objectives |
| **Missing constraints** | Unwanted side effects | Explicit boundaries |
| **Prose-only format** | Hard to parse, easy to miss details | Tables and checklists |
| **Bundled requirements** | Context overload | One feature per spec |
| **No acceptance criteria** | No definition of done | Testable success conditions |

---

## Core Principles

| Principle | Guideline | Rationale |
| --- | --- | --- |
| **Structured over narrative** | Tables, checklists, explicit sections | Agents parse structure better than prose |
| **Decomposed over monolithic** | One feature per spec | Prevents context overload and partial completion |
| **Bounded over open-ended** | Explicit constraints and acceptance criteria | Reduces scope creep and hallucination |
| **Testable over aspirational** | Every requirement has verification | Enables agent self-check |
| **Iterative over comprehensive** | Start minimal, refine collaboratively | Catches misunderstandings early |

---

## Specification Structure

### Minimal Viable Spec

```markdown
## Feature: [Name]

### Goal
[One sentence: what this achieves for users]

### Inputs
- [Input 1]: [Type and source]
- [Input 2]: [Type and source]

### Outputs
- [Output 1]: [Format and location]

### Constraints
- [Constraint 1]
- [Constraint 2]

### Acceptance Criteria
- [ ] [Testable condition 1]
- [ ] [Testable condition 2]
```

### Full Spec Template

```markdown
## Feature: [Name]

### Goal
[One sentence describing what success looks like from user perspective]

### Background
[2-3 sentences of context the agent needs. Skip if obvious.]

### Inputs
| Input | Type | Source | Required |
| --- | --- | --- | --- |
| [Name] | [Type] | [Where it comes from] | Yes/No |

### Outputs
| Output | Format | Location |
| --- | --- | --- |
| [Name] | [File type/structure] | [Where it goes] |

### Constraints
| Constraint | Rationale |
| --- | --- |
| [Boundary] | [Why this matters] |

### Acceptance Criteria
- [ ] [Testable condition with specifics]
- [ ] [Another testable condition]

### Out of Scope
- [Explicitly excluded item]

### Related
- [Link to related spec or code]
```

---

## Writing Effective Requirements

### Goal Statements

| Bad | Good | Why |
| --- | --- | --- |
| "Improve login" | "Reduce login failures by validating email format before submission" | Specific, measurable |
| "Add caching" | "Cache user profiles for 5 minutes to reduce DB load" | Clear parameters |
| "Make it faster" | "Reduce API response time to under 200ms for 95th percentile" | Quantified target |

### Constraints That Matter

| Type | Example | Prevents |
| --- | --- | --- |
| **Scope** | "Only modify `auth/` directory" | Wrong-module changes |
| **Compatibility** | "Must work with Node 18+" | Version-specific bugs |
| **Dependencies** | "Use existing `EmailService`, no new packages" | Unnecessary additions |
| **Behavior** | "Don't change public API signatures" | Breaking changes |
| **Security** | "Never log passwords or tokens" | Security vulnerabilities |

### Acceptance Criteria Patterns

| Pattern | Template | Example |
| --- | --- | --- |
| **Given/When/Then** | Given [context], when [action], then [result] | Given valid email, when user submits, then reset email is sent |
| **Checklist** | - [ ] [Specific testable condition] | - [ ] Reset link expires after 1 hour |
| **Boundary** | [Edge case] results in [expected behavior] | Empty email shows validation error |

---

## The CARE Framework

Structure specifications for maximum clarity:

| Section | Purpose | Questions It Answers |
| --- | --- | --- |
| **Context** | Background and constraints | What does the agent need to know? What can't it change? |
| **Action** | What to build or modify | What code should be written? What files to touch? |
| **Result** | Expected outputs | What artifacts are produced? What state changes? |
| **Evaluation** | How to verify | How do we know it worked? What tests should pass? |

### CARE Example

```markdown
## Context
We have a user registration flow that currently accepts any email format.
The EmailValidator utility exists in `src/utils/validators.ts`.
Don't modify the registration API response format.

## Action
Add email format validation to the registration endpoint.
Use the existing EmailValidator.isValid() method.
Return a 400 error with message "Invalid email format" for invalid emails.

## Result
- Modified: `src/api/registration.ts`
- Invalid emails rejected before database insert
- Error response: `{ "error": "Invalid email format" }`

## Evaluation
- [ ] Unit test: valid email → registration proceeds
- [ ] Unit test: invalid email → 400 response
- [ ] Existing registration tests still pass
```

---

## Decomposition Strategies

### When to Split Specs

| Signal | Action | Rationale |
| --- | --- | --- |
| Spec mentions "and" repeatedly | Split on each "and" | Each feature is independently verifiable |
| Touches more than 3 files | Phase into multiple specs | Easier to review and verify |
| Multiple independent behaviors | Separate feature per behavior | Prevents partial completion |
| Requires decisions not yet made | Decision spec first | Clarify before committing to implementation |

### Phased Specification

```markdown
## Phase 1: Core Logic
Goal: Implement password reset token generation
Outputs: PasswordResetService.generateToken()
Acceptance: Token is 32 bytes, expires in 1 hour

## Phase 2: API Endpoint
Goal: Expose password reset via REST API
Depends: Phase 1 complete
Outputs: POST /api/auth/reset-password
Acceptance: Returns 200 with token, 404 for unknown email

## Phase 3: Email Integration
Goal: Send reset email with token link
Depends: Phase 2 complete
Outputs: Email template, integration with EmailService
Acceptance: Email sent within 5 seconds of request
```

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| --- | --- | --- |
| **Vague verbs** | "Handle", "Process", "Manage" | Specific actions: "Validate", "Save", "Send" |
| **Implied requirements** | Agent misses unstated needs | Make every requirement explicit |
| **Bundled features** | Context overflow, partial work | One focused spec per feature |
| **Missing boundaries** | Agent makes scope assumptions | Explicit "Out of Scope" section |
| **Prose paragraphs** | Hard to parse, easy to miss | Tables, lists, code blocks |
| **Aspirational features** | Documents what isn't real | Specify only what's being built |
| **No verification** | Can't confirm completion | Testable acceptance criteria |

---

## Checklist

Before giving a spec to an AI agent:

- [ ] Goal is specific and measurable?
- [ ] Inputs and outputs are explicit?
- [ ] Constraints are documented?
- [ ] Acceptance criteria are testable?
- [ ] Scope is bounded (scope section or single focus)?
- [ ] Format uses tables/lists over prose?
- [ ] Could be split into smaller specs?

---

## See Also

- [Prompting Patterns](../prompting-patterns/prompting-patterns.md) – Crafting effective prompts
- [Agentic Workflow](../agentic-workflow/agentic-workflow.md) – How agents consume specs (PLAN phase)
- [Documentation Guidelines](../documentation-guidelines/documentation-guidelines.md) – General documentation practices
