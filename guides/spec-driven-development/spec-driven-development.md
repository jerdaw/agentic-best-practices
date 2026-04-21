# Spec-Driven Development

Best practices for making the specification the source of truth before AI-assisted implementation begins.

> **Scope**: Covers a spec-first workflow for AI-assisted teams: defining goals, constraints, acceptance criteria, phased delivery, and verification hooks before code changes start. Applies to feature work, refactors, migrations, and operational changes where ambiguity would otherwise create drift.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Spec Lifecycle](#spec-lifecycle) |
| [Minimum Spec Shape](#minimum-spec-shape) |
| [Phased Delivery](#phased-delivery) |
| [Verification Hooks](#verification-hooks) |
| [Anti-Patterns](#anti-patterns) |
| [Red Flags](#red-flags) |
| [Checklist](#checklist) |
| [See Also](#see-also) |

---

## Quick Reference

| Topic | Prefer | Avoid |
| --- | --- | --- |
| **Goal** | One measurable objective | "Improve things" |
| **Scope** | Explicit in/out boundaries | Hidden assumptions in chat |
| **Acceptance** | Testable outcomes | "Looks right" |
| **Delivery** | Small phases with checkpoints | One giant implementation jump |
| **Verification** | Named tests, checks, or review gates | "We'll test later" |

| Rule | Rationale |
| --- | --- |
| Write the spec before asking the agent to implement | Clear input produces more reliable output |
| One spec should cover one coherent change | Bundled goals create partial completion and drift |
| Make constraints explicit | AI fills gaps with guesses |
| Pair each requirement with a verification hook | If it cannot be checked, it is not done |
| Keep the spec updated when scope changes | A stale spec becomes a source of bugs |

---

## Core Principles

1. **Spec before code** — The implementation should follow the spec, not discover it mid-flight.
2. **Small, testable slices beat broad ambition** — AI performs better on phased changes than on sprawling asks.
3. **Constraints are part of the requirement** — Compatibility, security, and ownership must be stated up front.
4. **Verification is part of the design** — Decide how the change will be proved before implementation starts.
5. **The spec is a shared artifact** — Humans and agents should both be able to refer back to the same source of truth.

---

## Spec Lifecycle

| Stage | Output | Why |
| --- | --- | --- |
| **Define** | Goal, constraints, acceptance criteria | Removes ambiguity |
| **Review** | Human confirmation of intent and risk | Catches product or architecture mistakes early |
| **Implement** | Bounded change against the approved spec | Keeps execution aligned |
| **Verify** | Tests, checks, and review evidence | Confirms the spec was met |
| **Update or close** | Revised spec or archived completion note | Preserves traceability |

| Scope signal | Action |
| --- | --- |
| Requirement contains several "and" clauses | Split into phases or separate specs |
| Interface is shared across teams | Review the spec before implementation |
| Validation path is unclear | Stop and define it before coding |

---

## Minimum Spec Shape

Use any file name or template you want, but include the same core fields.

**Bad: prompt-as-spec with hidden assumptions**

```markdown
Add better pagination to the API.
Make it scalable and clean.
Try not to break anything.
```

**Good: compact spec with decision-complete inputs**

```markdown
## Goal
Add cursor pagination to `GET /orders`.

## Inputs
- Existing endpoint: `src/api/orders.ts`
- Existing response shape must remain backward compatible

## Constraints
- No new database tables
- Default page size 20, maximum 100
- Existing offset pagination remains supported for one release

## Acceptance Criteria
- [ ] Cursor pagination works for forward navigation
- [ ] Invalid cursor returns 400
- [ ] Existing offset clients continue to work
- [ ] `npm test -- orders` passes
```

| Required field | Why |
| --- | --- |
| **Goal** | Defines success |
| **Inputs / context** | Anchors the agent to the right code and dependencies |
| **Constraints** | Prevents invalid or risky solutions |
| **Acceptance criteria** | Makes the result checkable |
| **Out of scope** | Prevents "while I'm here" sprawl |

---

## Phased Delivery

Break large work into phases with explicit dependencies.

**Good: phased implementation plan**

```markdown
## Phase 1: Contract
- Define request and response shape
- Add validation and tests for the contract only

## Phase 2: Storage / logic
- Implement cursor generation and query logic
- Add integration tests for forward navigation

## Phase 3: Compatibility and rollout
- Keep offset pagination available for one release
- Add docs and deprecation note
```

| Use phases when... | Benefit |
| --- | --- |
| Change spans multiple modules or teams | Review stays focused |
| Shared interfaces must stabilize first | Parallel work becomes safer |
| Rollout has compatibility or migration concerns | Each phase can prove readiness independently |

---

## Verification Hooks

| Requirement type | Verification hook |
| --- | --- |
| **Behavioral** | Unit, integration, or end-to-end test |
| **Contract** | Schema validation, API contract test, type check |
| **Performance** | Benchmark, latency threshold, load test |
| **Security** | Review checklist, policy gate, focused test |
| **Docs/process** | Navigation validation, lint, peer review |

| Verification rule | Why |
| --- | --- |
| Name commands or checks explicitly | Prevents "it probably works" completion |
| Include failure cases in acceptance criteria | AI often optimizes only for the happy path |
| Tie compatibility promises to concrete checks | Backward compatibility needs evidence |

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| --- | --- | --- |
| **Prompt-only implementation** | Intent remains implicit and unstable | Write a shared spec artifact first |
| **Bundled mega-spec** | Partial completion is hard to detect | Split into coherent phases |
| **No constraints** | AI invents dependencies or broadens scope | State boundaries explicitly |
| **No verification plan** | "Done" becomes subjective | Add named tests and checks |
| **Spec drift after implementation starts** | Code and docs diverge | Update the spec as soon as scope changes |

---

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| Spec goal is vague enough that two reviewers would implement different things | Rewrite the goal before coding | Ambiguous specs produce arbitrary output |
| Acceptance criteria are not testable | Replace them with observable outcomes | "Better" is not a completion condition |
| Agent needs to infer critical constraints from unrelated files | Pull those constraints into the spec | Hidden rules cause accidental breakage |
| Large change starts with implementation instead of interface or contract definition | Add a contract-first phase | Stable seams reduce rework |
| Spec is abandoned after the first code change | Keep it current or stop calling it the source of truth | Stale specs create false confidence |

---

## Checklist

- [ ] The goal is specific and measurable
- [ ] Inputs and constraints are explicit
- [ ] Acceptance criteria are testable
- [ ] Large work is phased with clear dependencies
- [ ] Verification hooks are named before implementation starts
- [ ] The spec is updated when scope changes

---

## See Also

- [PRD for Agents](../prd-for-agents/prd-for-agents.md) — Structured specification inputs
- [Planning Documentation](../planning-documentation/planning-documentation.md) — Planning artifacts and update discipline
- [Agentic Workflow](../agentic-workflow/agentic-workflow.md) — Plan before editing
- [Testing AI-Generated Code](../testing-ai-code/testing-ai-code.md) — Verifying implementation against the spec
