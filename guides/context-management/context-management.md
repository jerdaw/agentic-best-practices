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
| [Context Exclusion Rules](#context-exclusion-rules) |
| [Trust Hierarchies](#trust-hierarchies) |
| [Context Rules by Tool](#context-rules-by-tool) |
| [Managing Long Sessions](#managing-long-sessions) |
| [Anti-Patterns](#anti-patterns) |
| [Self-Assessment Checklist](#self-assessment-checklist) |
| [Red Flags](#red-flags) |
| [See Also](#see-also) |

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
| **Doc stripping** | Remove redundant "what" comments; keep required "why/invariant" comments |
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

## Context Exclusion Rules

Exclusion rules control what the agent **cannot see**. They are the first line of defense against context pollution.

### What to Exclude

| Category | Examples | Why |
| :--- | :--- | :--- |
| **Build outputs** | `dist/`, `build/`, `.next/` | Generated code — large volume, zero signal |
| **Dependencies** | `node_modules/`, `vendor/` | Third-party code creates noise and confusion |
| **Generated files** | `*.min.js`, `*.map`, lockfiles | Machine-generated, not human-authored |
| **Binary assets** | Images, fonts, compiled binaries | Agent can't meaningfully read these |
| **Secrets** | `.env`, `*.key`, `credentials/` | Security risk — never expose to AI tooling |
| **Test snapshots** | `__snapshots__/` | Large, low-signal, frequently changing |
| **IDE/editor config** | `.idea/`, `.vscode/` (selectively) | Usually not relevant to the task |

### Exclusion File Patterns

| Tool | File | Syntax |
| :--- | :--- | :--- |
| **Cursor** | `.cursorignore` | Gitignore-style globs |
| **Copilot** | `.copilotignore` | Gitignore-style globs |
| **Claude Code** | `.claude/settings.json` | JSON `ignorePaths` array |
| **All tools** | `.gitignore` | Most tools respect `.gitignore` as a baseline |

### Example `.cursorignore`

```gitignore
# Build outputs
dist/
build/
.next/

# Dependencies
node_modules/
vendor/

# Generated
*.min.js
*.map
coverage/

# Secrets
.env*
*.key
```

> **Tip**: Start with your `.gitignore` and add tool-specific exclusions. If your `.gitignore` is well-maintained, it covers 80% of exclusion needs.

---

## Trust Hierarchies

Not all sources are equally authoritative. When information conflicts, the agent needs to know which source wins.

### Default Trust Order

| Priority | Source | Why |
| :--- | :--- | :--- |
| **1 (highest)** | `AGENTS.md` / repo instructions | Explicit human-authored governance; the "law" |
| **2** | Architecture docs (`ARCHITECTURE.md`, ADRs) | Deliberate design decisions |
| **3** | Type definitions and interfaces | Machine-enforced contracts |
| **4** | Test files | Executable specifications of expected behavior |
| **5** | Source code | Current implementation (may have bugs) |
| **6** | README files | Often stale; describes intent, not reality |
| **7** | Inline comments | Highest risk of being outdated |
| **8 (lowest)** | Commit messages | Historical context only; may describe reverted changes |

### Signaling Authority

Help the agent resolve conflicts by being explicit:

**Good** (explicit authority):

```text
Fix the login bug. The correct behavior is defined in
src/auth/__tests__/login.test.ts — trust the test, not the
inline comments in auth.service.ts (they're outdated).
```

**Bad** (ambiguous authority):

```text
Fix the login bug. Here's the service file and the test file.
```

### Override Rules

When scoped rules exist at multiple levels, narrower scope wins:

| Level | File | Scope |
| :--- | :--- | :--- |
| **Directory-level** | `src/auth/AGENTS.md` | Only `src/auth/` |
| **Repo-level** | `AGENTS.md` (root) | Entire repository |
| **Org-level** | Shared standards repo | All repositories |

**Resolution order**: Directory-level > Repo-level > Org-level. A directory-level `AGENTS.md` can override repo-level rules for its subdirectory.

---

## Context Rules by Tool

How major AI coding tools implement context gating:

| Feature | Claude Code | Cursor | GitHub Copilot | Gemini CLI |
| :--- | :--- | :--- | :--- | :--- |
| **Repo instructions** | `CLAUDE.md` | `.cursor/rules/` | `.github/copilot-instructions.md` | `GEMINI.md` |
| **Exclusion file** | `.claude/settings.json` | `.cursorignore` | `.copilotignore` | Respects `.gitignore` |
| **Context selection** | Automatic + manual `@file` | Automatic + manual `@file` | Automatic | Automatic + manual |
| **Scoped rules** | Directory `CLAUDE.md` | Directory `.cursor/rules/*.mdc` | Not supported | Directory `GEMINI.md` |
| **Trust signaling** | Via `CLAUDE.md` content | Via rules content | Limited | Via `GEMINI.md` content |

> **Principle**: Write your context rules in `AGENTS.md` (tool-agnostic), then symlink or reference from tool-specific files. This avoids maintaining parallel rule sets.

---

## Managing Long Sessions

As conversations grow, the "attention" of the AI diminishes.

1. **Checkpoints** – Periodically summarize the state of the work.
2. **Fresh Sessions** – When starting a new feature, start a new chat.
3. **Context Refresh** – Re-share modern versions of files if they changed significantly.
4. **Explicit Forgetting** – Tell the AI to ignore previous, failed attempts.

---

## Self-Assessment Checklist

Before starting a task, verify:

- [ ] Only relevant files are in the context (not the entire `src/`)?
- [ ] Exclusion rules configured (`.cursorignore` or equivalent)?
- [ ] Critical instructions are at the top of the prompt?
- [ ] Authority is explicit when sources conflict?
- [ ] Context window has room for the agent's response?
- [ ] Previous session state is cleared for unrelated tasks?

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
- [Prompt Files](../prompt-files/prompt-files.md) – Reusable task templates with context references
- [Memory Patterns](../memory-patterns/memory-patterns.md) – State management across sessions
- [AGENTS.md Guidelines](../agents-md/agents-md-guidelines.md) – Persistent repo-level context
- [Tool Configuration](../tool-configuration/tool-configuration.md) – Tool-specific setup including exclusions
- [Multi-File Refactoring](../multi-file-refactoring/multi-file-refactoring.md) – Large scale context
