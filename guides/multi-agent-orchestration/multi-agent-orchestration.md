# Multi-Agent Orchestration

Best practices for coordinating multiple AI agents — delegation chains, result synthesis, handoff patterns, and
conflict prevention.

> **Scope**: Covers patterns for multi-agent systems where two or more AI agents collaborate on a task. Focus is on
> orchestration, not individual agent design (see [Custom Agents](../custom-agents/custom-agents.md)). Applies to
> agent-to-agent workflows in coding, review, and automation.

## Contents

| Section |
| :--- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Orchestration Patterns](#orchestration-patterns) |
| [Delegation and Handoff](#delegation-and-handoff) |
| [Shared Context Management](#shared-context-management) |
| [Conflict Prevention](#conflict-prevention) |
| [Result Synthesis](#result-synthesis) |
| [Anti-Patterns](#anti-patterns) |
| [Red Flags](#red-flags) |
| [Checklist](#checklist) |
| [See Also](#see-also) |

---

## Quick Reference

**Orchestration pattern summary**:

| Pattern | Topology | When to Use |
| :--- | :--- | :--- |
| **Coordinator-Worker** | One lead, N workers | Default choice; clear authority, simple routing |
| **Pipeline** | Agent A -> Agent B -> Agent C | Sequential stages (generate -> review -> test) |
| **Fan-Out/Fan-In** | Coordinator fans to N, merges results | Parallelizable subtasks with independent scopes |

**Key rules**:

| Rule | Rationale |
| :--- | :--- |
| Single coordinator owns the plan | Prevents conflicting decisions and duplicated work |
| Explicit handoff contracts | Each agent knows its inputs, outputs, and success criteria |
| Minimize shared state | Pass structured data, not conversation history |
| Fail individual, not collective | One agent's failure does not halt the pipeline |
| Human gates on synthesis | Require human review before merging multi-agent output |

---

## Core Principles

1. **Single coordinator** -- One agent owns the plan. It decomposes work, assigns agents, and merges results. No
   leaderless swarms.
2. **Explicit handoff contracts** -- Every delegation defines inputs, outputs, file scope, and success criteria before
   work begins. Vague instructions produce vague results.
3. **Minimize shared state** -- Pass structured data between agents, not raw conversation history. Each agent receives
   only the context it needs.
4. **Fail individual, not collective** -- Isolate agent failures. If one worker fails, the coordinator retries or
   reassigns that task without discarding results from other workers.
5. **Human gates on synthesis** -- Multi-agent output is higher risk than single-agent output. Require human review
   before merging combined results into the codebase.

---

## Orchestration Patterns

### Coordinator-Worker

A single coordinator agent decomposes the task, delegates subtasks to worker agents, and merges their results.

```text
           Coordinator
          /     |     \
     Worker A  Worker B  Worker C
         \      |      /
          Coordinator (merge)
```

| Aspect | Detail |
| :--- | :--- |
| Topology | Star: coordinator at center, workers on edges |
| Coordinator role | Decompose task, assign work, resolve conflicts, merge output |
| Worker role | Execute scoped subtask, return structured result |
| When to use | Default pattern; works for most multi-agent tasks |
| Weakness | Coordinator is a single point of failure; keep it simple |

### Pipeline

Agents execute in sequence. Each agent's output becomes the next agent's input.

```text
Agent A (generate) -> Agent B (review) -> Agent C (test)
```

| Aspect | Detail |
| :--- | :--- |
| Topology | Linear chain: Agent A -> Agent B -> Agent C |
| Example | Generate code -> Review code -> Write tests |
| When to use | Stages have clear ordering and each stage transforms output |
| Weakness | Latency scales linearly; blocked by slowest stage |

### Fan-Out/Fan-In

The coordinator dispatches independent subtasks in parallel and merges results when all complete.

```text
           Coordinator
          / | | | \        (fan-out)
         A  B  C  D  E    (parallel workers)
          \ | | | /        (fan-in)
           Coordinator     (merge)
```

| Aspect | Detail |
| :--- | :--- |
| Topology | Coordinator fans out to N workers, then collects results |
| Example | Refactor 5 independent modules in parallel |
| When to use | Subtasks have no shared file dependencies |
| Weakness | Merge conflicts if file boundaries are not clean |

### Pattern Selection

| Factor | Coordinator-Worker | Pipeline | Fan-Out/Fan-In |
| :--- | :--- | :--- | :--- |
| Task parallelism | Mixed | None (sequential) | High |
| Dependency between subtasks | Some allowed | Each depends on prior | None |
| Coordination complexity | Medium | Low | Medium |
| Latency | Medium | High (serial) | Low (parallel) |
| Conflict risk | Low (coordinator mediates) | Low (sequential) | Medium (merge phase) |

### Failure Handling by Pattern

| Pattern | On Worker Failure | On Coordinator Failure |
| :--- | :--- | :--- |
| **Coordinator-Worker** | Coordinator retries or reassigns the subtask | Pipeline halts; checkpoint and resume |
| **Pipeline** | Retry current stage; do not re-run completed stages | Pipeline halts; resume from last checkpoint |
| **Fan-Out/Fan-In** | Re-dispatch failed subtask; keep completed results | Merge phase lost; re-collect from workers |

---

## Delegation and Handoff

### Task Decomposition

| Principle | Detail |
| :--- | :--- |
| One agent, one concern | Each worker handles a single logical unit of work |
| File-level boundaries | Assign non-overlapping file sets to prevent merge conflicts |
| Testable outputs | Each subtask produces output that can be validated independently |
| Right-sized scope | A subtask should be completable in a single agent session |

### Decomposition Example

A task like "Add user profile feature with API, UI, and tests" decomposes as:

| Subtask | Agent | Scope | Depends On |
| :--- | :--- | :--- | :--- |
| Define shared types | Coordinator | `src/types/user.ts` | Nothing |
| Implement API endpoints | api-agent | `src/api/routes/`, `src/api/schemas/` | Shared types |
| Implement UI components | ui-agent | `src/components/`, `src/hooks/` | Shared types, API contract |
| Write integration tests | test-agent | `src/tests/integration/` | API + UI complete |
| Wire routes and merge | Coordinator | `src/app.ts`, `src/routes.ts` | All subtasks complete |

The coordinator handles shared types first, then fans out API and UI work in parallel, then runs the test agent
sequentially after both complete.

### Handoff Contracts

Every delegation must define a structured contract. The contract eliminates ambiguity and lets the coordinator validate
results mechanically.

| Field | Required | Description |
| :--- | :--- | :--- |
| `agent` | Yes | Agent identifier or role name |
| `scope` | Yes | File paths or directories the agent may modify |
| `inputs` | Yes | References, specs, or data the agent needs |
| `outputs` | Yes | Expected deliverables (files, endpoints, components) |
| `success_criteria` | Yes | How to verify the work is done correctly |
| `constraints` | No | Style rules, library restrictions, patterns to follow |

```python
# Bad: vague delegation
tasks = [
    {"agent": "agent-1", "instruction": "Work on the backend"},
    {"agent": "agent-2", "instruction": "Work on the frontend"},
]
```

```python
# Good: structured handoff contract
tasks = [
    {
        "agent": "api-agent",
        "scope": ["src/api/routes/users.py", "src/api/schemas/user.py"],
        "inputs": {"spec": "docs/api-spec.yaml#/paths/~1users"},
        "outputs": {"endpoints": ["GET /users", "POST /users"]},
        "success_criteria": "All endpoint tests pass; OpenAPI spec validates",
    },
    {
        "agent": "ui-agent",
        "scope": ["src/components/UserList.tsx", "src/hooks/useUsers.ts"],
        "inputs": {"api_contract": "GET /users -> { users: User[] }"},
        "outputs": {"components": ["UserList", "useUsers hook"]},
        "success_criteria": "Component renders with mock data; no TypeScript errors",
    },
]
```

---

## Shared Context Management

### Context Passing Strategies

| Strategy | How It Works | Token Cost | When to Use |
| :--- | :--- | :--- | :--- |
| **Full forward** | Pass entire prior conversation to next agent | Very high | Almost never; only tiny conversations |
| **Structured contract** | Pass only inputs, outputs, and constraints | Low | Default choice for most handoffs |
| **Shared artifact** | Agents read/write a shared file (spec, schema, plan) | Medium | Agents need ongoing access to evolving state |

### Avoiding Context Bloat

Forwarding full conversation history between agents is the single most common multi-agent waste. Each hop amplifies
token cost and degrades signal.

```typescript
// Bad: context telephone — full conversation forwarded
const agent2Input = {
  context: agent1.fullConversationHistory, // 50,000 tokens of chat history
  task: "Continue the work",
}
```

```typescript
// Good: structured contract — minimal context
const agent2Input = {
  task: "Implement UserList component",
  contract: {
    apiEndpoint: "GET /api/users",
    responseShape: "{ users: Array<{ id: string; name: string; email: string }> }",
    dependencies: ["src/types/user.ts"],
  },
  constraints: ["Use React Query for data fetching", "Follow existing component patterns in src/components/"],
}
```

---

## Conflict Prevention

### File Ownership

Assign non-overlapping file sets to each agent. The coordinator is the only entity that may touch shared files.

| Rule | Detail |
| :--- | :--- |
| Exclusive file assignment | Each file is owned by at most one worker agent |
| Coordinator-only shared files | Config files, shared types, and entry points are coordinator-managed |
| Lock before write | If a file must be shared, agents claim it explicitly before editing |
| Interface-first contracts | Agents agree on interfaces (types, API shapes) before implementing |

### Overlapping Responsibilities

```yaml
# Bad: two agents assigned overlapping files
agent_a:
  scope:
    - src/api/routes.ts      # <-- shared file
    - src/api/middleware.ts
agent_b:
  scope:
    - src/api/routes.ts      # <-- conflict: same file
    - src/api/controllers.ts
```

```yaml
# Good: isolated boundaries with coordinator merge
coordinator:
  owns:
    - src/api/routes.ts      # coordinator merges route registrations
agent_a:
  scope:
    - src/api/middleware.ts
    - src/api/middleware.test.ts
  outputs:
    exported_middleware: "authMiddleware, rateLimitMiddleware"
agent_b:
  scope:
    - src/api/controllers.ts
    - src/api/controllers.test.ts
  outputs:
    exported_handlers: "getUsers, createUser"
# Coordinator wires middleware + handlers into routes.ts after both complete
```

---

## Result Synthesis

### Combining Outputs

| Strategy | How It Works | When to Use |
| :--- | :--- | :--- |
| **File concatenation** | Each agent produces distinct files; coordinator assembles | Non-overlapping file scopes |
| **Interface stitching** | Agents produce implementations; coordinator wires them via imports | Module-boundary work |
| **Sequential refinement** | Agent B refines Agent A's output | Review, test-writing, documentation |
| **Coordinator rewrite** | Coordinator reads all outputs, writes final version | Small outputs needing unified voice |

### Synthesis Pitfalls

```typescript
// Bad: coordinator blindly concatenates agent outputs without checking interfaces
function mergeResults(agentOutputs: AgentResult[]): string {
  return agentOutputs.map(o => o.code).join("\n")
}
```

```typescript
// Good: coordinator validates interface compatibility before merging
async function mergeResults(agentOutputs: AgentResult[]): Promise<string> {
  // Verify all agents produced expected exports
  for (const output of agentOutputs) {
    const missing = output.contract.outputs.filter(
      name => !output.code.includes(`export ${name}`)
    )
    if (missing.length > 0) {
      throw new SynthesisError(`Agent ${output.agent} missing exports: ${missing.join(", ")}`)
    }
  }

  // Assemble files, then run type checker
  const assembled = assembleFiles(agentOutputs)
  await runTypeCheck(assembled)
  return assembled
}
```

### Quality Gates

Validate combined output before it reaches the codebase.

| Gate | Validation |
| :--- | :--- |
| Type check | Combined output compiles without errors |
| Test suite | All existing and new tests pass |
| Lint | No new lint violations introduced |
| Diff review | Human reviews the combined diff, not individual agent diffs |
| Contract check | Each agent's `success_criteria` is verified |
| Integration test | Components from different agents work together |

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| :--- | :--- | :--- |
| **Leaderless swarm** | No coordinator; agents step on each other, duplicate work | Always designate a single coordinator agent |
| **Context telephone** | Full conversation history forwarded between agents; token waste, signal loss | Pass structured contracts with only the data each agent needs |
| **Redundant agents** | Multiple agents assigned the same task "for safety" | One agent per task; use review as a separate stage instead |
| **No quality gate** | Multi-agent output merged without validation | Run type checks, tests, and lint before merging combined output |
| **Coordinator as bottleneck** | Coordinator does most of the work itself instead of delegating | Keep coordinator thin: plan, delegate, merge. No implementation. |
| **Over-orchestration** | Using 4 agents where 1 would suffice | Use multi-agent only when task scope exceeds single-agent capacity |

---

## Red Flags

| Signal | Action | Rationale |
| :--- | :--- | :--- |
| Conflicting edits to the same file | Reassign file ownership; one agent per file | Merge conflicts waste time and introduce bugs |
| Orchestration cost exceeds 3x single-agent cost | Drop to single-agent or reduce agent count | Coordination overhead has exceeded the parallelism benefit |
| Coordinator re-explaining context to workers | Improve handoff contracts with explicit inputs | Re-explanation signals that contracts are incomplete |
| No human review step before merge | Add a mandatory human gate | Multi-agent output compounds errors across agents |
| Workers producing inconsistent interfaces | Add an interface-agreement step before implementation | Agents must agree on shared types and API shapes first |
| Agent idle time exceeds 50% of total wall clock | Restructure task decomposition or switch to pipeline | Poor parallelization signals wrong pattern choice |

---

## Checklist

- [ ] A single coordinator agent owns the plan and delegates all subtasks
- [ ] Every delegation includes a structured handoff contract (scope, inputs, outputs, success criteria)
- [ ] File ownership is exclusive — no two agents edit the same file
- [ ] Context is passed as structured data, not raw conversation history
- [ ] Individual agent failures are isolated; one failure does not discard other results
- [ ] Combined output passes type checks, tests, and lint before merging
- [ ] A human reviews the merged diff before it reaches the codebase
- [ ] Orchestration pattern (coordinator-worker, pipeline, fan-out/fan-in) is chosen deliberately
- [ ] Shared interfaces are agreed upon before agents begin implementation
- [ ] Total orchestration cost is monitored and justified against single-agent alternatives

---

## See Also

- [Custom Agents](../custom-agents/custom-agents.md) -- Individual agent design and specialization
- [Agentic Workflow](../agentic-workflow/agentic-workflow.md) -- MAP-FIRST workflow for single-agent tasks
- [Context Management](../context-management/context-management.md) -- Managing context within agent sessions
- [Human-AI Collaboration](../human-ai-collaboration/human-ai-collaboration.md) -- Human-in-the-loop patterns
- [Memory Patterns](../memory-patterns/memory-patterns.md) -- State persistence across sessions
- [Cost & Token Management](../cost-token-management/cost-token-management.md) -- Controlling multi-agent token spend
- [Concurrency & Async Patterns](../concurrency-async/concurrency-async.md) -- Parallel execution primitives
