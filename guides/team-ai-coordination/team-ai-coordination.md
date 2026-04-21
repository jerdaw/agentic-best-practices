# Team AI Coordination

Best practices for coordinating multiple humans and AI agents on the same codebase without collisions, hidden changes, or accountability gaps.

> **Scope**: Covers team-level AI usage in active repositories: ownership rules, branch and worktree discipline, agent isolation, review policy, escalation paths, and coordination contracts between developers and agents.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Ownership Model](#ownership-model) |
| [Work Isolation Patterns](#work-isolation-patterns) |
| [Review and Verification Policy](#review-and-verification-policy) |
| [Escalation and Conflict Handling](#escalation-and-conflict-handling) |
| [Policy Defaults](#policy-defaults) |
| [Anti-Patterns](#anti-patterns) |
| [Red Flags](#red-flags) |
| [Checklist](#checklist) |
| [See Also](#see-also) |

---

## Quick Reference

| Topic | Prefer | Avoid |
| --- | --- | --- |
| **Ownership** | One human owner per change or workstream | "Everyone is responsible" |
| **Isolation** | Separate branches or worktrees per task | Many agents editing the same branch blindly |
| **Handoffs** | Structured task contracts with scope and checks | Vague "work on this" prompts |
| **Review** | Human review before merge | Unreviewed AI diffs in shared branches |
| **Escalation** | Explicit stop rules for uncertainty or collisions | Silent overwrites and parallel guessing |

| Rule | Rationale |
| --- | --- |
| A single human owns the final diff | Accountability cannot be delegated |
| File ownership must be explicit before parallel work starts | Merge conflicts are coordination failures, not bad luck |
| Agents should receive bounded scopes and validation steps | Clear contracts reduce duplicated or conflicting work |
| Shared branch history is for reviewed work, not active experiments | Work-in-progress needs isolation |
| Escalate ambiguity early | AI coordination degrades quickly when assumptions diverge |

---

## Core Principles

1. **Human owner is mandatory** — Every AI-assisted change has a responsible human reviewer and integrator.
2. **Isolation first** — Parallel work requires branch, worktree, or file-level isolation before implementation starts.
3. **Structured handoffs beat chat history** — Use explicit contracts for scope, inputs, outputs, and checks.
4. **Visibility beats convenience** — Team members should know where AI is operating and on whose behalf.
5. **Conflicts should stop work, not become merge puzzles** — If ownership is unclear, pause and reassign.

---

## Ownership Model

| Role | Responsibility |
| --- | --- |
| **Human task owner** | Defines scope, reviews output, decides merge |
| **Agent operator** | Supplies context, runs validations, keeps agent bounded |
| **Reviewer** | Checks correctness, safety, and policy compliance |
| **Repo maintainer** | Defines team-wide AI policy and escalation path |

| Ownership rule | Why |
| --- | --- |
| One workstream has one primary owner | Prevents "I thought someone else had it" failures |
| Shared interfaces are assigned before implementation | Parallel edits need stable seams |
| Unowned cleanup goes into backlog, not drive-by edits | Keeps AI sessions focused and reviewable |

---

## Work Isolation Patterns

| Pattern | When to use | Benefit |
| --- | --- | --- |
| **One branch per task** | Default for single developer + agent work | Clear review boundary |
| **One worktree per parallel track** | Multiple active changes in same repo | Avoids dirty-working-tree collisions |
| **File ownership matrix** | Fan-out work across agents or teammates | Prevents overlapping edits |
| **Shared spec + isolated implementation** | Work depends on one agreed contract | Reduces merge pain on interfaces |

**Bad: vague handoff with no scope or checks**

```markdown
Please work on the backend while I handle the rest.
Make whatever changes you think are needed.
```

**Good: bounded coordination contract**

```markdown
## Task Contract: billing retry policy

Owner: platform-backend
Write scope: `src/billing/retry.ts`, `src/billing/retry.test.ts`
Read-only context: `docs/adr/adr-007-retry-policy.md`
Constraints:
- Do not change public API signatures
- Do not edit files outside the listed scope
Verification:
- `npm test -- billing/retry`
- `npm run lint`
Escalate if:
- Retry behavior depends on changing shared config schema
```

**Good: isolated worktree for parallel changes**

```bash
git worktree add ../repo-billing codex/billing-retries
git worktree add ../repo-docs codex/docs-refresh
```

| Isolation signal | Action |
| --- | --- |
| Two people or agents need the same file | Split the task differently or sequence the work |
| Shared contract is undefined | Define it first in a small preparatory change |
| Dirty branch already contains unrelated edits | Create a fresh branch or worktree before delegating |

---

## Review and Verification Policy

| Policy | Why |
| --- | --- |
| Human review is required before merge | AI output carries correctness and security risk |
| Validation commands are part of the handoff | Review should include proof, not only diff reading |
| High-risk areas need stronger gates | Auth, payments, migrations, and security-sensitive docs need more scrutiny |
| Attribution is behavioral, not ceremonial | Review who made the decision, not who typed the text |

| Change type | Minimum review bar |
| --- | --- |
| **Low-risk docs or refactor** | Human diff review + local validation |
| **Code with logic changes** | Human review + relevant tests |
| **Security or production operations** | Human expert review + focused validation evidence |
| **Parallel multi-agent work** | Integration review after fan-in plus normal validation |

---

## Escalation and Conflict Handling

| Situation | Action | Rationale |
| --- | --- | --- |
| Unclear owner | Stop and assign one | Shared responsibility hides real responsibility |
| Interface change affects multiple tracks | Create a small contract-first change | Reduces downstream merge churn |
| Agent output conflicts with human edits | Re-read current branch state before retrying | Blind rewrites erase intent |
| Validation fails outside assigned scope | Escalate to owner; do not broaden task casually | Scope creep breaks coordination |

| Escalation trigger | Who resolves it |
| --- | --- |
| File ownership conflict | Human task owners or maintainer |
| Policy ambiguity | Maintainer or tech lead |
| Unsafe or unverifiable output | Human reviewer |
| Repeated agent thrash | Task owner decides to narrow scope or switch to manual work |

---

## Policy Defaults

| Default | Recommendation |
| --- | --- |
| **Transparency** | Note in PR or handoff when AI materially contributed |
| **Branching** | No direct commits to shared long-lived branches from active AI experimentation |
| **Scope** | One agent or one teammate gets one logical concern at a time |
| **Review** | Review output line-by-line before merge |
| **Retention** | Keep reusable prompts, specs, and task contracts in the repo if they matter later |

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| --- | --- | --- |
| **Shared branch swarm** | Unreviewed overlapping edits pile up | Isolate work in branches or worktrees |
| **Invisible AI usage** | Team cannot explain why changes happened | Make ownership and process visible |
| **Scope creep during delegation** | Agents start rewriting adjacent modules | Use explicit write boundaries |
| **No stop rule** | Teams keep retrying broken agent workflows | Define escalation points early |
| **Reviewer fatigue** | Too many unstructured AI diffs overwhelm humans | Shrink task size and improve handoffs |

---

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| Multiple agents or teammates edit the same file without an agreed owner | Pause and reassign scope | Merge conflicts are a symptom of unclear ownership |
| A PR author cannot explain what the agent changed or why | Block merge until they can | Ownership requires understanding |
| Shared branch contains unrelated AI experiments | Split work into isolated branches or worktrees | Reviewable history depends on isolation |
| Validation commands are missing from the handoff | Add them before delegating | Review without verification evidence is weak |
| Agent keeps broadening scope after failures | Stop and narrow the task or switch to manual work | Thrash compounds coordination risk |

---

## Checklist

- [ ] Every AI-assisted task has a human owner
- [ ] Write scope is explicit before parallel work begins
- [ ] Branch or worktree isolation is used for concurrent tracks
- [ ] Validation commands are part of the handoff contract
- [ ] Human review occurs before merge
- [ ] Escalation path is defined for scope or ownership conflicts

---

## See Also

- [Human-AI Collaboration](../human-ai-collaboration/human-ai-collaboration.md) — Choosing when humans vs AI should lead
- [Multi-Agent Orchestration](../multi-agent-orchestration/multi-agent-orchestration.md) — Parallel agent topology and handoffs
- [Git Workflows with AI](../git-workflows-ai/git-workflows-ai.md) — Branching and PR hygiene
- [Custom Agents](../custom-agents/custom-agents.md) — Scoped agent roles and permissions
