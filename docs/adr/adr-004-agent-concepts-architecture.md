# ADR 004: Agent Concepts Architecture

| Status | Date | Decision Owner |
| :--- | :--- | :--- |
| **Accepted** | 2026-02-14 | Maintainers |

## Context

The landscape of AI coding tools has evolved from simple chat interfaces to complex ecosystems involving distinct concepts:

- **Repo Instructions** (governance)
- **Prompt Files** (task templates)
- **Custom Agents** (worker profiles)
- **Skills** (procedures)
- **Tools** (capabilities)
- **Context Rules** (visibility)
- **Memory** (state)
- **MCP** (integration plumbing)

As these concepts emerge, tools (Cursor, Claude Code, Copilot) are introducing proprietary configuration formats (e.g., `.cursorrules`, `.claude/agents`, `.copilotignore`).

We need to decide:

1. How `agentic-best-practices` supports these concepts without becoming a "config dump" for every specific tool.
2. Which concepts deserve dedicated guidance vs. being folded into existing guides.
3. How we define the boundaries between overlapping concepts (e.g., Skills vs Prompt Files).

## Decision

We adopt the following **8-Concept Taxonomy** and architectural stance:

### 1. Taxonomy Adoption

We officially recognize these 8 distinct elements of agentic AI coding:

| Concept | Definition | Distinct From | Implementation |
| :--- | :--- | :--- | :--- |
| **Repo Instructions** | Global, persistent governance (laws). | Task-specific prompts. | `AGENTS.md` |
| **Prompt Files** | Reusable task templates (requests). | Skills (logic/procedure). | `.prompts/*.md` |
| **Custom Agents** | Specialized worker profiles (personas). | Direct instructions. | Tool-specific config (abstracted in guide) |
| **Skills** | Repeatable procedures/logic (strategies). | Tools (atomic actions). | `skills/` directory |
| **Tools** | Atomic capabilities (execution). | Skills (orchestration). | Tool config guides |
| **Context Rules** | Visibility & authority gates. | Active memory. | `context-management` guide |
| **Memory** | Evolving state (scratchpad). | Static context. | `memory-patterns` guide |
| **MCP** | Integration plumbing/protocol. | Tools themselves. | *Deferred* |

### 2. Tool Agnosticism

We **REJECT** the inclusion of tool-specific configuration files (e.g., `.cursorrules`, `.claude/`) in the repository root, except where necessary for the repo's own development (e.g., a sample `.cursorignore`).

**Rationale**:

- Prevents fragmentation (maintaining N versions of every rule).
- Preserves the "principles-first" identity of the repo.
- Avoids obsolescence as tool formats change rapidly.

Instead, we provide **Guides** that explain the *principles* of configuration, with **Templates** that users can adapt to their specific tool.

### 3. Concept Coverage Strategy

- **New Guides**: Create dedicated guides for high-value gaps: `prompt-files`, `memory-patterns`, `custom-agents`.
- **Expansion**: Expand `context-management` to cover new visibility/authority concepts.
- **Deferral**: Defer `MCP` guidance until the specification and tooling ecosystem stabilizes.

### 4. Boundary Definitions

- **Prompt Files vs Skills**:
  - Use **Prompt Files** for linear, template-based tasks (e.g., "Review this PR").
  - Use **Skills** for multi-step, branching procedures (e.g., "Debug this error" → read → hypothesize → test → loop).
- **Custom Agents vs Repo Instructions**:
  - Use **Repo Instructions** (`AGENTS.md`) for universal rules that apply to *everyone*.
  - Use **Custom Agents** only when a role requires *restricted permissions* or *highly specialized outputs* that differ from the default.

## Consequences

**Positive**:

- Clear mental model for users navigating the complex agent ecosystem.
- Consistent, tool-agnostic guidance that outlasts specific tool versions.
- Focused "Skills" directory remains clean of simple templates.

**Negative**:

- Users of specific tools (e.g., Cursor) must manually translate our patterns into their config (`.cursorrules`) rather than just copying a file.
- We must maintain multiple guides (`prompting-patterns`, `prompt-files`, `skills`) and clearly explain the differences to avoid confusion.

## Compliance

- New guides must adhere to the definitions in this ADR.
- `AGENTS.md` template updates must respect the distinction between governance (Repo Instructions) and task templates (Prompt Files).
- Future MCP guidance will require a new ADR or amendment when ready.
