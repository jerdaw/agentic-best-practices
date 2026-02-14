# Prompt Files

Best practices for authoring, organizing, and maintaining reusable prompt files that AI coding agents consume as task templates.

> **Scope**: Covers `.prompt.md` files and equivalent task templates across tools (Cursor, Claude, Copilot). Focuses on
> the *authoring and maintenance* of prompt files as project artifacts — not on how to write good prompts in a chat
> session (see [Prompting Patterns](../prompting-patterns/prompting-patterns.md) for that).

## Contents

| Section |
| :--- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Anatomy of a Prompt File](#anatomy-of-a-prompt-file) |
| [When to Use Prompt Files](#when-to-use-prompt-files) |
| [File Organization](#file-organization) |
| [Prompt File Patterns](#prompt-file-patterns) |
| [Parameterization](#parameterization) |
| [Testing and Iteration](#testing-and-iteration) |
| [Anti-Patterns](#anti-patterns) |
| [Self-Assessment Checklist](#self-assessment-checklist) |
| [Red Flags](#red-flags) |
| [See Also](#see-also) |

---

## Quick Reference

| Category | Guidance | Rationale |
| :--- | :--- | :--- |
| **Purpose** | Reusable task templates for recurring jobs | Eliminates re-typing and ensures consistency |
| **File format** | Markdown (`.prompt.md` or `.md`) | Human-readable, version-controllable, tool-agnostic |
| **Storage** | `.prompts/` directory at repo root or relevant subdirectory | Discoverable, co-located with the code they operate on |
| **Naming** | `verb-noun.prompt.md` (e.g., `review-pr.prompt.md`) | Scannable, self-documenting, sorts well |
| **Scope** | One task per file | Prevents overloaded prompts and keeps files composable |

---

## Core Principles

1. **Reusability over one-off** – If you've typed a prompt twice, it should be a file.
2. **Specificity over generality** – A prompt file for "write unit tests for React hooks" is better than "write tests."
3. **Composability over monoliths** – Small, focused prompts that can be chained beat mega-prompts.
4. **Version control** – Prompt files are code artifacts; commit, review, and iterate on them.
5. **Context-aware** – Reference specific project files, conventions, and constraints — not generic advice.

---

## Anatomy of a Prompt File

A well-structured prompt file has three layers:

### Metadata (Optional Frontmatter)

```yaml
---
description: Generate unit tests for a React component
tools: [read_file, run_terminal_command]
context: [src/components/, src/test-utils/]
---
```

| Field | Purpose |
| :--- | :--- |
| `description` | One-line summary — helps discovery and tooling |
| `tools` | Which tools the agent may need (some tools support this) |
| `context` | Files/directories the agent should read before starting |

### Task Body

The core instruction. Structure it as:

```markdown
## Task

Write unit tests for the component at `{{FILE_PATH}}`.

## Requirements

- Test all user-facing behavior (renders, interactions, edge cases)
- Use the testing patterns in `src/test-utils/render-helpers.ts`
- Use `vitest` and `@testing-library/react`
- Achieve >90% branch coverage

## Constraints

- Do NOT modify the component itself
- Do NOT add new dependencies
- Match the test file naming convention: `ComponentName.test.tsx`
```

### Context References

Explicitly point the agent at what it needs:

```markdown
## Context

- Component source: `{{FILE_PATH}}`
- Existing test examples: `src/components/__tests__/Button.test.tsx`
- Test utilities: `src/test-utils/`
- Project test config: `vitest.config.ts`
```

---

## When to Use Prompt Files

| Situation | Use | Why |
| :--- | :--- | :--- |
| Recurring task (PR review, test writing, migration) | **Prompt file** | Eliminates re-typing, ensures consistency |
| One-off debugging session | **Chat prompt** | Not worth creating an artifact |
| Multi-step procedure with decision points | **Skill** | Skills handle branching logic; prompt files are linear |
| Global behavior rule ("always use TypeScript") | **Repo instructions** (`AGENTS.md`) | Rules apply to all tasks, not just one |
| Complex specification with acceptance criteria | **PRD** | PRDs are richer than prompt files |

### Decision Flow

```
Is this a recurring task?
├── No → Use a chat prompt
└── Yes
    ├── Does it need branching logic or multi-step decisions?
    │   ├── Yes → Write a Skill
    │   └── No → Write a Prompt File
    └── Is it a global behavior rule?
        ├── Yes → Add to AGENTS.md
        └── No → Write a Prompt File
```

---

## File Organization

### Directory Structure

```
.prompts/
├── review-pr.prompt.md          # PR review rubric
├── write-tests.prompt.md        # Unit test generation
├── explain-module.prompt.md     # Architecture explanation
└── migrate-api.prompt.md        # API migration steps
```

For larger projects, co-locate with the code:

```
src/
├── auth/
│   ├── .prompts/
│   │   └── audit-auth-flow.prompt.md
│   └── auth.service.ts
├── api/
│   ├── .prompts/
│   │   └── add-endpoint.prompt.md
│   └── router.ts
```

### Naming Convention

| Pattern | Example | When to use |
| :--- | :--- | :--- |
| `verb-noun.prompt.md` | `review-pr.prompt.md` | Default — clear action |
| `noun-verb.prompt.md` | `component-test.prompt.md` | When grouping by domain |
| Avoid generic names | ~~`helper.prompt.md`~~ | Never — too vague to discover |

---

## Prompt File Patterns

### PR Review

```markdown
## Task

Review the changes in this PR for correctness, security, and maintainability.

## Review Checklist

- [ ] No security vulnerabilities introduced
- [ ] Error handling is explicit (no silent failures)
- [ ] Tests cover the new behavior
- [ ] No unnecessary complexity added
- [ ] API contracts are preserved (or breaking changes documented)

## Output Format

For each finding:
1. **File:Line** — location
2. **Severity** — Critical / Warning / Suggestion
3. **Issue** — what's wrong
4. **Fix** — concrete recommendation
```

### Test Generation

```markdown
## Task

Write unit tests for `{{FILE_PATH}}`.

## Requirements

- Test all exported functions/components
- Cover happy path, edge cases, and error cases
- Use existing test patterns from `{{TEST_EXAMPLES_DIR}}`
- Use the project's test framework (check `package.json`)

## Constraints

- Do NOT modify source code
- Do NOT add dependencies
- Match existing test file naming convention
```

### Code Migration

```markdown
## Task

Migrate `{{FILE_PATH}}` from {{OLD_PATTERN}} to {{NEW_PATTERN}}.

## Steps

1. Read the current implementation
2. Identify all instances of {{OLD_PATTERN}}
3. Replace with {{NEW_PATTERN}} following the example in `{{EXAMPLE_FILE}}`
4. Run tests to verify no regressions

## Constraints

- Preserve all existing behavior
- Do NOT change the public API
- One file at a time
```

---

## Parameterization

Use template variables to make prompt files reusable across different targets.

### Variable Syntax

Use `{{VARIABLE_NAME}}` for parameters the user fills in:

```markdown
## Task

Refactor `{{MODULE_PATH}}` to extract `{{FUNCTION_NAME}}` into a shared utility.
```

### Common Variables

| Variable | Purpose | Example value |
| :--- | :--- | :--- |
| `{{FILE_PATH}}` | Target file | `src/auth/login.ts` |
| `{{MODULE_PATH}}` | Target module/directory | `src/auth/` |
| `{{TEST_EXAMPLES_DIR}}` | Where to find test patterns | `src/__tests__/` |
| `{{FUNCTION_NAME}}` | Specific function to operate on | `validateToken` |
| `{{OLD_PATTERN}}` | Pattern being replaced | `callback-based async` |
| `{{NEW_PATTERN}}` | Pattern being adopted | `async/await` |

### Conditional Sections

For prompts that adapt to context:

```markdown
## Task

Write tests for `{{FILE_PATH}}`.

<!-- If the file is a React component -->
## React-Specific

- Use `@testing-library/react` for rendering
- Test user interactions, not implementation details

<!-- If the file is a utility function -->
## Utility-Specific

- Test pure input/output behavior
- Include property-based tests for mathematical functions
```

---

## Testing and Iteration

Prompt files are never "done" — they improve through use.

### Iteration Workflow

| Step | Action | Output |
| :--- | :--- | :--- |
| **1. Draft** | Write the initial prompt file | `v0` committed |
| **2. Test** | Run against 2-3 real targets | Observed behavior |
| **3. Evaluate** | Compare output quality to manual work | Gap list |
| **4. Refine** | Tighten constraints, add examples, fix gaps | `v1` committed |
| **5. Share** | Team uses it; collect feedback | Usage data |

### Quality Signals

| Signal | Meaning |
| :--- | :--- |
| Agent asks clarifying questions | Prompt is underspecified — add the missing context |
| Output requires heavy editing | Constraints are too loose — tighten requirements |
| Output is too rigid/templated | Over-constrained — relax and let the agent reason |
| Different team members get different results | Add concrete examples to anchor behavior |

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| :--- | :--- | :--- |
| **Mega-prompt** | 500-line prompt file covering everything | Split into focused, composable files |
| **No context references** | Agent guesses at project conventions | Point to specific example files |
| **Copy-paste prompts** | Same prompt in 5 places, all slightly different | One prompt file, parameterized |
| **Outdated references** | Prompt references files that no longer exist | Review prompt files during doc maintenance |
| **No constraints** | Agent makes risky assumptions | State what NOT to do explicitly |
| **Chat-style writing** | "Hey, can you maybe..." | Direct, imperative instructions |

---

## Self-Assessment Checklist

Before committing a prompt file:

- [ ] Task is clearly stated in the first 2-3 lines?
- [ ] Constraints explicitly listed?
- [ ] Context references point to real, existing files?
- [ ] Parameters use `{{VARIABLE}}` syntax for reusable parts?
- [ ] File name follows `verb-noun.prompt.md` convention?
- [ ] Tested against at least one real target?

---

## Red Flags

| Signal | Action | Rationale |
| :--- | :--- | :--- |
| Prompt file over 100 lines | Split into smaller, composable files | Long prompts lose focus and are hard to maintain |
| Team members rewriting the same prompt from memory each time | Create a shared `.prompts/` directory | Duplication wastes time and produces inconsistent results |
| Prompt references deleted files or outdated patterns | Update references during regular doc maintenance | Stale prompts produce stale output |
| No constraints section | Add explicit "do NOT" rules | Unconstrained agents make risky assumptions |
| Prompt file that works for only one specific case | Parameterize with `{{VARIABLES}}` | Non-reusable prompts don't justify being files |

---

## See Also

- [Prompting Patterns](../prompting-patterns/prompting-patterns.md) – How to write effective prompts in chat sessions
- [AGENTS.md Guidelines](../agents-md/agents-md-guidelines.md) – Global repo instructions (not task-specific)
- [PRD for Agents](../prd-for-agents/prd-for-agents.md) – Structured specs for complex features
- [Agent Skills](../../skills/README.md) – Repeatable procedures with branching logic
