---
name: prompting
description: Use when crafting prompts for AI tools, managing context in AI conversations, or decomposing tasks for AI
---

# Prompting

**Announce at start:** "Following the prompting skill for effective AI interaction."

## Core Rule

**Task first, context after.** Lead with what you want, then provide supporting information.

## Prompt Structure

### 1. State the Task Clearly

```text
[Specific, actionable task description]

Context:
- [Relevant code or file references]
- [Constraints and boundaries]
- [Expected behavior]
```

### 2. Decompose Large Tasks

| Signal | Action |
| --- | --- |
| Task mentions "and" multiple times | Split on each "and" |
| Touches more than 2-3 files | Do one file at a time |
| Multiple behaviors to implement | One behavior per prompt |
| "While you're at it..." | Separate prompt |

### 3. Set Explicit Constraints

```text
[Task description]

Constraints:
- Only modify: [specific files or functions]
- Must preserve: [existing behavior, API, tests]
- Don't use: [forbidden dependencies, patterns]
- Must support: [versions, environments, edge cases]
```

### 4. Provide Focused Context

| Do | Don't |
| --- | --- |
| Share the specific functions mentioned in the error | Dump the entire codebase |
| Include relevant types and interfaces | Include unrelated modules |
| Show error messages and stack traces | Describe errors vaguely |
| Reference existing patterns to match | Assume AI knows your conventions |

## Context Management

### Session Hygiene

- Start fresh sessions for unrelated tasks
- Re-state critical constraints when context grows long
- Share only code relevant to the current task
- Summarize decisions made earlier in the session

### When Context Gets Stale

| Symptom | Cause | Fix |
| --- | --- | --- |
| AI forgets instructions | Context pushed out | Repeat key constraints |
| AI contradicts previous output | Lost history | Start fresh session |
| AI ignores shared code | Code too far back | Re-share relevant snippets |
| Generic responses | Overloaded context | Reduce scope |

## Prompt Templates

### Bug Fix

```text
Fix this error: [full error message]

Stack trace: [full stack trace]

Code: [relevant function]

Expected: [correct behavior]
Actual: [current behavior]
```

### Feature Addition

```text
Add [feature] to [component].

Behavior:
- When [trigger], it should [action]

Constraints:
- [Scope limits]
- [What must not change]

Match the pattern in [existing similar code].
```

## Related Skills

| When | Invoke |
| --- | --- |
| Prompting for a multi-step task | [planning](../planning/SKILL.md) |
| Prompting for debugging help | [debugging](../debugging/SKILL.md) |
| Prompting for code review | [code-review](../code-review/SKILL.md) |

## Deep Reference

For principles, rationale, anti-patterns, and examples:

- `guides/prompting-patterns/prompting-patterns.md`
- `guides/context-management/context-management.md`
