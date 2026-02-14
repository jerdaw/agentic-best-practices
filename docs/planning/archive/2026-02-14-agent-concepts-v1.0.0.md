# New Guides: Prompt Files, Memory Patterns, Context Rules Expansion, Custom Agents

Add 3 new guides and expand 1 existing guide to close the remaining gaps in the agentic AI coding taxonomy. These cover the concepts not yet addressed by the existing 40 guides and 14 skills.

## User Review Required

> [!IMPORTANT]
> **Custom Agents** is the newest and most speculative of these. If you'd rather defer it until the tooling landscape stabilizes, we can drop it without affecting the other three. Let me know.
> [!NOTE]
> **MCP** is intentionally excluded for now — the spec is evolving too fast. A section can be added to `tool-configuration` later once it stabilizes.

## Taxonomy Mapping

Shows how the 8 concepts map to existing and proposed coverage:

| Concept | Existing Guide | Action |
|---|---|---|
| (a) Repo Instructions | `agents-md-guidelines` (350 lines) | ✅ Already strong — no changes |
| (b) Prompt Files | None | **NEW guide** |
| (c) Custom Agents | None | **NEW guide** |
| (d) Agent Skills | `skills/README.md` + 14 skills | ✅ Just built — no changes |
| (e) Tools | `tool-configuration` (639 lines) | ✅ Already strong — no changes |
| (f) Context Rules | `context-management` (160 lines) | **EXPAND existing** |
| (g) Memory | None | **NEW guide** |
| (h) MCP | None | ⏸️ Deferred (too early) |

---

## Proposed Changes

### [NEW] [adr-004-agent-concepts-architecture.md](file:///home/jer/localsync/agentic-best-practices/docs/adr/adr-004-agent-concepts-architecture.md)

**Context**: The emergence of distinct agent concepts (Prompt Files, Custom Agents, Memory, Context Rules, MCP) requires a unified architectural decision on how this repo supports them.

**Decision**:

1. **Tool Agnosticism**: Reject tool-specific config files (e.g., `.cursorrules`) in the repo root to maintain platform neutrality.
2. **Concept Coverage**: Address new concepts via **Guides** (principles) and **Templates** (patterns), not raw config.
3. **Taxonomy**: Adopt the 8-concept taxonomy (Repo Instructions, Prompts, Custom Agents, Skills, Tools, Context, Memory, MCP).
4. **Deferred**: Defer MCP guidance until the spec stabilizes.

### Guide 1: Prompt Files

#### [NEW] [prompt-files.md](file:///home/jer/localsync/agentic-best-practices/guides/prompt-files/prompt-files.md)

**What it covers**: How to author, organize, and maintain reusable `.prompt.md` files (task templates) that agents consume on demand.

**Distinction from `prompting-patterns`**: That guide teaches *how to write good prompts in a chat*. This guide teaches *how to author reusable prompt files as project artifacts*.

**Proposed sections**:

- Quick Reference (table: what prompt files are, when to use them, file naming)
- Core Principles (reusability, specificity, composability, versioning)
- Anatomy of a Prompt File (frontmatter, context injection, parameters, constraints)
- When to Use Prompt Files vs Skills vs Repo Instructions (decision table)
- File Organization (where to store, naming conventions, discoverability)
- Prompt File Patterns (bug triage, code review, test generation, PR description, refactoring)
- Parameterization (template variables, dynamic context, conditional sections)
- Testing Prompt Files (how to validate effectiveness, iteration workflow)
- Anti-Patterns
- Self-Assessment Checklist
- Red Flags
- See Also → `prompting-patterns`, `agents-md-guidelines`, `prd-for-agents`

**Estimated length**: 200-300 lines

---

### Guide 2: Memory Patterns

#### [NEW] [memory-patterns.md](file:///home/jer/localsync/agentic-best-practices/guides/memory-patterns/memory-patterns.md)

**What it covers**: Patterns for maintaining AI agent state across steps and sessions — scratchpads, project state files, decision logs, and what to persist vs discard.

**Distinction from `agentic-workflow`**: That guide covers the MAP-PLAN-PATCH-PROVE-PR *workflow*. This guide covers *state management* — the evolving record of decisions, progress, and context that persists across workflow iterations and sessions.

**Proposed sections**:

- Quick Reference (table: memory types, persistence levels, use cases)
- Core Principles (temporal state, minimal persistence, structured over freeform, decay)
- Memory Types (session scratchpad, project state file, decision log, TODO tracker, learned constraints)
- State File Design (format, what to include, what to omit, when to prune)
- Cross-Session Continuity (handoff summaries, checkpoint files, resumption patterns)
- Memory Scope (task-local vs project-wide vs org-wide, lifecycle management)
- Storage Patterns (file-based, tool-provided, hybrid)
- Anti-Patterns (hoarding everything, no structure, stale state, memory as documentation)
- Self-Assessment Checklist
- Red Flags
- See Also → `agentic-workflow`, `planning-documentation`, `context-management`

**Estimated length**: 250-350 lines

---

### Guide 3: Expand Context Management (Context Rules)

#### [MODIFY] [context-management.md](file:///home/jer/localsync/agentic-best-practices/guides/context-management/context-management.md)

**Currently**: 160 lines covering basic context selection, pruning, and session management.

**Gap**: No coverage of *rules-based* context control — exclusion patterns (`.cursorignore`, `.gitignore`), trust hierarchies (which sources are authoritative), or authority rules (what overrides what).

**New sections to add** (inserted between "Context Pruning" and "Managing Long Sessions"):

- **Context Exclusion Rules** — patterns for what to exclude (`.cursorignore`, build outputs, vendored code, generated files), how exclusions interact across tools
- **Trust Hierarchies** — which sources should be authoritative (`AGENTS.md > inline comments`, `architecture.md > stale README`), how to signal priority to the agent
- **Authority & Override Rules** — how scoped context rules work (directory-level override, repo-level defaults, org-level policy), resolution order when rules conflict
- **Context Rules by Tool** — practical comparison table showing how Cursor, Claude, Copilot, and Gemini each implement context gating

**Also update**: Contents table, Red Flags (add trust/authority signals), See Also (link to new guides)

**Estimated additions**: 100-150 lines (bringing total to ~300 lines)

---

### Guide 4: Custom Agents

#### [NEW] [custom-agents.md](file:///home/jer/localsync/agentic-best-practices/guides/custom-agents/custom-agents.md)

**What it covers**: How to design, configure, and maintain specialized AI agent personas (worker profiles) that bundle instructions, tools, and permissions for specific roles.

**Proposed sections**:

- Quick Reference (table: what custom agents are, when to use them, current tool support)
- Core Principles (single responsibility, least privilege, explicit boundaries, composability)
- Anatomy of a Custom Agent (name, role description, default instructions, allowed tools, output format, permissions)
- When to Use Custom Agents vs Repo Instructions vs Prompt Files (decision table)
- Common Agent Profiles (Security Auditor, Code Reviewer, Test Writer, Documentation Writer, Refactoring Specialist)
- Designing Permissions (read-only vs read-write, tool whitelisting, destructive action gates)
- Configuration Patterns (how profiles map to Claude, Cursor, and Copilot agent config)
- Anti-Patterns
- Self-Assessment Checklist
- Red Flags
- See Also → `agents-md-guidelines`, `tool-configuration`, `prompt-files`

**Estimated length**: 200-300 lines

---

## Navigation Updates

After creating guides, update these files:

### [MODIFY] [guide-index.md](file:///home/jer/localsync/agentic-best-practices/guides/guide-index.md)

- Add entries for `prompt-files`, `memory-patterns`, `custom-agents`

### [MODIFY] [README.md](file:///home/jer/localsync/agentic-best-practices/README.md)

- Add entries to the guide table

### [MODIFY] [AGENTS.md](file:///home/jer/localsync/agentic-best-practices/AGENTS.md)

- Add entries to guide references

---

## Implementation Order

| Order | Guide | Rationale |
|---|---|---|
| 1 | **Prompt Files** | Clearest gap, most mature concept, directly complements existing `prompting-patterns` |
| 2 | **Memory Patterns** | Second biggest gap, addresses a hard problem with no existing coverage |
| 3 | **Context Management expansion** | Builds on existing content, benefits from patterns established in guides 1-2 |
| 4 | **Custom Agents** | Most speculative, but architecturally important; informed by all previous work |

---

## Verification Plan

### Automated Tests

- `npm run validate` — confirms navigation, Contents tables, anchor links, and skills all pass
- `npx markdownlint-cli2 "**/*.md" "#node_modules"` — confirms 0 lint errors

### Manual Verification

- Each new guide follows the standard structure (Quick Reference, Core Principles, Anti-Patterns, Red Flags, See Also)
- Cross-references between guides are bidirectional
- Decision tables (prompt files vs skills vs repo instructions) are consistent across guides
