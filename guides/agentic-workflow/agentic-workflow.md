# Agentic Workflow Discipline

Best practices for AI agents on operating safely and effectively in codebases—the MAP-FIRST workflow for understanding before changing.

> **Scope**: These guidelines define how AI agents should approach coding tasks. Understanding before editing prevents thrash, wrong-module changes, and breaking hidden contracts.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Phase 0: Establish Scope and Safety](#phase-0-establish-scope-and-safety) |
| [Phase 1: MAP-FIRST (Understanding)](#phase-1-map-first-understanding) |
| [Phase 2: PLAN (Design)](#phase-2-plan-design) |
| [Phase 3: PATCH (Edit)](#phase-3-patch-edit) |
| [Phase 4: PROVE (Verify)](#phase-4-prove-verify) |
| [Phase 5: PR (Package for Review)](#phase-5-pr-package-for-review) |
| [Escalation Rules](#escalation-rules) |
| [Tool Discipline](#tool-discipline) |
| [Anti-Patterns](#anti-patterns) |

---

## Quick Reference

**The workflow**: MAP → PLAN → PATCH → PROVE → PR

| Phase | Purpose | Output |
| --- | --- | --- |
| **MAP** | Understand the codebase | Mental model, repo map |
| **PLAN** | Design small, reversible changes | Change plan with rollback |
| **PATCH** | Make minimal, focused edits | Code changes |
| **PROVE** | Verify with tests and evidence | Test results, proof |
| **PR** | Package for review | Review-ready submission |

**Core invariants**:

- No edits before understanding (MAP-FIRST)
- No writes without dry-run first
- No destructive actions without approval
- Always run tests before proposing merge

---

## Core Principles

1. **Understand before editing** – MAP-FIRST prevents wrong-module changes
2. **Plan before patching** – Small, reversible changes reduce risk
3. **Prove before proposing** – Tests and evidence build confidence
4. **Dry-run before write** – Preview changes before applying
5. **Escalate when uncertain** – Ask humans for ambiguous situations

---

## Phase 0: Establish Scope and Safety

Before any work, clarify the boundaries.

### Scope Confirmation

| Clarify | Why |
| --- | --- |
| **Goal** | What exactly should change? |
| **Constraints** | What must NOT change? |
| **Definition of done** | How do we know it's complete? |
| **Approval gates** | What requires human sign-off? |

### Safety Boundaries

Restate before starting:

| Boundary | Description | Purpose |
| --- | --- | --- |
| **Goal** | [Specific objective] | Focuses the effort |
| **Constraints** | [What to preserve] | Prevents regressions |
| **Out of scope** | [What NOT to touch] | Prevents scope creep |
| **Approval needed** | [Destructive actions] | Security and stability gate |

### Destructive Actions Requiring Approval

| Action | Why Approval Required |
| --- | --- |
| **Merge to main/master** | Permanent history change |
| **Deploy to production** | User-facing impact |
| **Delete resources** | Data loss risk |
| **Rotate secrets/keys** | Access disruption |
| **Modify CI permissions** | Security boundary change |
| **Cross-service changes** | Coordination required |

---

## Phase 1: MAP-FIRST (Understanding)

**Never edit before mapping.** Build a mental model first.

### MAP Checklist

| Category | Action | Why |
| --- | --- | --- |
| **Read** | README, CONTRIBUTING, ARCHITECTURE.md | Understand high-level intent and patterns |
| **Read** | SECURITY.md, CODEOWNERS | Identify safety boundaries and reviewers |
| **Identify** | Build system and commands | Know how to compile and run the project |
| **Identify** | Test strategy (unit/integration/e2e) | Know how to verify correctness |
| **Locate** | CI workflows (.github/workflows, etc.) | Understand automated quality gates |
| **Sketch** | Package/module boundaries | Prevent circular/invalid dependencies |
| **Sketch** | Service dependencies | Understand upstream/downstream impact |

### Key Questions to Answer

| Question | Where to Look |
| --- | --- |
| **How do I build this?** | README, package.json, Makefile |
| **How do I run tests?** | README, CI config, package.json |
| **What's the architecture?** | ARCHITECTURE.md, directory structure |
| **Who owns what?** | CODEOWNERS, team structure |
| **What are the conventions?** | CONTRIBUTING, existing code patterns |

### MAP Output (Good vs Bad)

**Poor Map** (Too vague, skips mechanics):

```markdown
## Map
I read the code. It's a React app. I'll change the login button.
```

**Better Map** (Actionable and mechanical):

```markdown
## Repo Map: [auth-service]

### Build & Test
- Build: `npm run build` | Test: `npm test`
- CI: GitHub Actions on PR (requires 100% test coverage)

### Structure
- `src/handlers/` - Entry points for API gateway
- `src/logic/` - Business logic (pure functions)
- `src/db/` - DynamoDB access patterns

### Invariants
- `src/logic` must never import from `src/db` (strictly pure)
```

### MAP Anti-Patterns

| Anti-Pattern | Problem | Fix |
| --- | --- | --- |
| **Editing before understanding** | Wrong-module changes | Complete MAP first |
| **Skipping CI analysis** | Breaking builds | Always check CI config |
| **Ignoring CODEOWNERS** | Wrong reviewers | Respect ownership |
| **Missing test discovery** | Untested changes | Find test patterns |

---

## Phase 2: PLAN (Design)

Design changes that are small, reversible, and testable.

### Planning Rules

| Rule | Rationale |
| --- | --- |
| **Small PRs** | Easier to review, test, rollback |
| **One concern per change** | Clear scope, clear testing |
| **Behavior change = flag** | Gradual rollout, easy rollback |
| **Refactor vs feature** | Isolate mechanical from behavioral |

### Plan Template

```markdown
## Change Plan

### Objective
[What we're trying to achieve]

### Hypothesis
[Why we believe this approach will work]

### Changes
1. [File/function] - [What changes]
2. [File/function] - [What changes]

### Tests
- [ ] Add: [New test for new behavior]
- [ ] Verify: [Existing tests still pass]

### Rollback Plan
[How to undo if something goes wrong]

### Risks
- [Risk 1] - Mitigation: [How to handle]
- [Risk 2] - Mitigation: [How to handle]

### Requires Approval
- [ ] [Any destructive actions]
```

### Change Size Guidelines

| Size | Recommendation |
| --- | --- |
| **1-50 lines** | Ideal—easy to review |
| **50-200 lines** | Acceptable—focused |
| **200-500 lines** | Split if possible |
| **500+ lines** | Must split |

### Reversibility Strategies

| Strategy | When to Use |
| --- | --- |
| **Feature flag** | Behavior changes |
| **Config toggle** | Environment-specific changes |
| **Separate PR** | Refactors before features |
| **Staged rollout** | High-risk changes |

---

## Phase 3: PATCH (Edit)

Make changes with surgical precision.

### Editing Discipline

| Do | Don't |
| --- | --- |
| **Smallest surface area** | Wide-ranging changes |
| **Match existing style** | Introduce new conventions |
| **Preserve formatting** | Reformat unrelated code |
| **One logical change** | Mixed concerns |

### Patch Workflow

| Step | Action | Rationale |
| --- | --- | --- |
| **1. Dry-run** | Preview diff / check flags | Final check before mutation |
| **2. Minimal Edit** | Surgical change | Minimizes unintended side effects |
| **3. Verify Mechanics** | Compile / Lint / Typecheck | Catches syntax/packaging errors fast |
| **4. Run Fast Tests** | Target unit tests | Immediate feedback on logic |
| **5. Atomic Commit** | Clear, focused message | Clean history for debugging/reverting |

### Dry-Run Pattern

Before any write operation:

```text
# For file changes
Preview diff before applying

# For commands
Use --dry-run flag where available

# For infrastructure
Use plan/preview mode
```

### Commit Discipline

| Guideline | Example |
| --- | --- |
| **One logical change** | "Add validation for email field" |
| **Clear, imperative** | "Fix null check in user lookup" |
| **Reference issue** | "Fixes #123: Handle empty input" |
| **Separate refactors** | "Refactor: Extract validation logic" |

---

## Phase 4: PROVE (Verify)

Verify changes with tests and evidence before proposing.

### Verification Hierarchy

| Layer | Action | Rationale |
| --- | --- | --- |
| **1. Unit** | Run targeted logic tests | Fastest feedback, isolates logic |
| **2. Integration** | Run tests for module interactions | Verifies wiring and contracts |
| **3. Build** | Full compilation / build | Detects packaging/dependency issues |
| **4. Manual** | Human/Browser validation | Catches visual/UX regressions |

### Evidence (Good vs Bad)

**Vague Evidence** (Untrustworthy):

```text
I ran tests and they passed. I also checked the UI.
```

**Concrete Evidence** (Verifiable):

```markdown
### Verification Results
- [x] `npm test src/logic/auth.test.ts` (14/14 passed)
- [x] Verified `login_error` metric fires on invalid credentials in local logs.
- [Screenshot: Error state appearing correctly on mobile viewport]
```

### Proof Template

```markdown
## Verification

### Tests Run
- `npm test` - ✓ All passed
- `npm run test:integration` - ✓ All passed

### Evidence
- [Screenshot/output of test results]
- [Relevant log output]

### Skipped Tests (with rationale)
- [Test name] - Reason: [Why skipped]

### Manual Verification
- [x] [Scenario tested manually]
```

### When Tests Are Weak

| Situation | Action | Rationale |
| --- | --- | --- |
| **No tests exist** | Add tests for changed behavior | Establishes a baseline for safety |
| **Edge cases missed** | Add specific regression tests | Prevents "whack-a-mole" bug fixing |
| **Can't add tests** | Escalate to human | Prevents unverified logic deployment |
| **Tests are flaky** | Note flakiness, isolation test | Distinguishes logic bugs from noise |

---

## Phase 5: PR (Package for Review)

Create a review-ready submission.

### PR Checklist

| Item | Why |
| --- | --- |
| **Clear title** | Defines scope for the reviewer immediately |
| **Impact Summary** | Explains the "why" and "so what" of the change |
| **Verification Proof** | Moves the burden of proof from reviewer to author |
| **Rollback Plan** | Shows operational maturity and foresight |
| **Links** | Connects code to requirements/tickets |

### PR Template

```markdown
## Summary
[One paragraph: what this PR does and why]

## Changes
- [Bullet list of key changes]

## Testing
- [x] Unit tests pass
- [x] Integration tests pass
- [ ] Manual testing: [what was tested]

## Evidence
[Test output, screenshots, or other proof]

## Risks and Rollback
- Risk: [What could go wrong]
- Rollback: [How to undo]

## Related
- Issue: #123
- Depends on: #124 (if applicable)
```

---

## Escalation Rules

### Ask a Human When

| Situation | Why Escalate |
| --- | --- |
| **Ambiguous requirements** | Need clarification |
| **Conflicting specs** | Need decision |
| **Cross-service changes** | Need coordination |
| **Security-sensitive code** | Need expert review |
| **Tests failing, cause unclear** | Need debugging help |
| **Bounded effort exceeded** | Avoid infinite loops |

### Destructive Actions Always Require Approval

| Action | Impact |
| --- | --- |
| **Merge to main/master** | Permanent history |
| **Deploy to production** | User impact |
| **Delete data/resources** | Data loss |
| **Rotate secrets/keys** | Access control |
| **Modify CI/CD** | Pipeline security |
| **Change access** | Auth boundaries |

### Escalation Format

```markdown
## Escalation: [Brief title]

### Situation
[What's happening]

### What I've Tried
1. [Attempt 1 and result]
2. [Attempt 2 and result]

### Options
A. [Option and tradeoffs]
B. [Option and tradeoffs]

### Recommendation
[What I suggest, or "need guidance"]

### Urgency
[Blocking / Can wait / FYI]
```

---

## Tool Discipline

### Tool Usage Rules

| Rule | Rationale |
| --- | --- |
| **Batch related reads** | Reduce round trips |
| **Explicit inputs** | Reproducibility |
| **Record outputs** | Traceability |
| **Handle errors** | Don't crash on failures |

### Error Handling in Tool Calls

| If tool fails... | Then... | Why? |
| --- | --- | --- |
| **Is it transient?** | Retry with backoff (max 3) | Network glitches happen. |
| **Is input wrong?** | Fix input, retry | Agent error is correctable. |
| **Is it persistent?** | Escalate to human | Don't spin wheels. |
| **Always** | Never infinite retry | Avoid loops and waste. |

### Resource Limits

| Resource | Limit | Rationale |
| --- | --- | --- |
| **Files per operation** | ~50 | Context limits |
| **Timeout per tool** | 60s default | Prevent hangs |
| **Retries** | 3 max | Avoid loops |
| **Context size** | Respect limits | Stay focused |

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| --- | --- | --- |
| **Edit before MAP** | Wrong-module changes | MAP-FIRST always |
| **Big bang changes** | Unreviewable, risky | Small, focused PRs |
| **Skip dry-run** | Unintended side effects | Always preview first |
| **Skip tests** | Unverified changes | Prove before PR |
| **Ignore failures** | Silent breakage | Handle or escalate |
| **Infinite retry** | Resource waste | Bounded retries |
| **Assume approval** | Unauthorized actions | Explicit gates |


## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| Editing code before reading the codebase | Stop and go back to the MAP phase | Changes without understanding create more bugs than they fix |
| "This is too simple to need a plan" | It's not — write a plan anyway | Simple-seeming tasks hide complexity; skipping planning causes rework |
| Batching more than 3 tasks before a checkpoint | Break into smaller batches and report | Large batches without feedback accumulate errors silently |
| Guessing when blocked on requirements | Stop and ask the human | Assumptions create wasted work when they're wrong |
| No rollback strategy defined | Define how to undo before starting | Every change needs a way to reverse it |

---

## See Also

- [Coding Guidelines](../coding-guidelines/coding-guidelines.md) – Writing quality code
- [Git Workflows with AI](../git-workflows-ai/git-workflows-ai.md) – Commit and PR practices
- [Multi-File Refactoring](../multi-file-refactoring/multi-file-refactoring.md) – Large change coordination
- [PRD for Agents](../prd-for-agents/prd-for-agents.md) – Writing specs that agents consume in PLAN phase
