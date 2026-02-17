# Custom Agents

Best practices for designing, configuring, and maintaining specialized AI agent personas (worker profiles) that bundle instructions, tools, and permissions for specific roles.

> **Scope**: Covers the design patterns for creating purpose-built agent configurations across tools (Claude, Cursor,
> Copilot, Gemini). Focus is on *when and how to create specialized agents* — not on repo-wide instructions
> (see [AGENTS.md Guidelines](../agents-md/agents-md-guidelines.md)) or on individual prompt files
> (see [Prompt Files](../prompt-files/prompt-files.md)).

## Contents

| Section |
| :--- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Anatomy of a Custom Agent](#anatomy-of-a-custom-agent) |
| [When to Use Custom Agents](#when-to-use-custom-agents) |
| [Common Agent Profiles](#common-agent-profiles) |
| [Designing Permissions](#designing-permissions) |
| [Configuration Patterns](#configuration-patterns) |
| [Anti-Patterns](#anti-patterns) |
| [Self-Assessment Checklist](#self-assessment-checklist) |
| [Red Flags](#red-flags) |
| [See Also](#see-also) |

---

## Quick Reference

| Category | Guidance | Rationale |
| :--- | :--- | :--- |
| **Purpose** | Specialized worker profiles for distinct roles | Different tasks need different permissions, tone, and focus |
| **Default posture** | Start with repo instructions; create agents only when roles diverge | Over-specialization adds complexity without value |
| **Permissions** | Least privilege per role | Security auditors shouldn't push to main |
| **Naming** | Role-based, descriptive | `security-auditor` not `agent-2` |
| **Count** | 3-5 agents per project maximum | Too many agents = too many contexts to maintain |

---

## Core Principles

1. **Single responsibility** – Each agent has one clear role. A "do everything" agent is just the default.
2. **Least privilege** – Grant only the tools and permissions the role requires. A reviewer doesn't need write access.
3. **Explicit boundaries** – State what the agent should NOT do as clearly as what it should do.
4. **Composable over monolithic** – Prefer focused agents that hand off to each other over one mega-agent.
5. **Human in the loop** – Destructive actions require human approval regardless of the agent's role.

---

## Anatomy of a Custom Agent

A custom agent bundles five elements:

| Element | Purpose | Example |
| :--- | :--- | :--- |
| **Name** | Identity and discoverability | `security-auditor` |
| **Role description** | What the agent is responsible for | "Review code for security vulnerabilities" |
| **Default instructions** | Standing rules for this agent | "Flag any use of `eval()` or dynamic SQL" |
| **Allowed tools** | What the agent can do | Read files, search code — but NOT run commands |
| **Output format** | How the agent should respond | Structured findings with severity ratings |

### Example Configuration

```yaml
name: security-auditor
description: Reviews code changes for security vulnerabilities and compliance issues.

instructions: |
  You are a security-focused code reviewer. Your job is to identify
  vulnerabilities, not to fix them or suggest features.

  Focus areas:
  - Input validation and sanitization
  - Authentication and authorization
  - Secret handling and exposure
  - SQL injection, XSS, and CSRF
  - Dependency vulnerabilities

  For each finding, provide:
  1. File and line number
  2. Severity (Critical / High / Medium / Low)
  3. CWE category if applicable
  4. Specific remediation recommendation

  Do NOT:
  - Suggest feature improvements
  - Rewrite code (suggest fixes only)
  - Approve changes (you only flag issues)

tools:
  allow:
    - read_file
    - search_code
    - list_directory
  deny:
    - write_file
    - run_command
    - git_commit

output_format: |
  ## Security Review: [File/PR]

  ### Findings
  | # | Severity | File:Line | Issue | CWE | Recommendation |
  | --- | --- | --- | --- | --- | --- |

  ### Summary
  - Critical: [N]
  - High: [N]
  - Medium: [N]
  - Low: [N]
```

---

## When to Use Custom Agents

| Situation | Use | Why |
| :--- | :--- | :--- |
| Different tasks need different permissions | **Custom agent** | Security auditor vs code writer need different tool access |
| Task needs a specific output format every time | **Custom agent** | Bundling format with role ensures consistency |
| Everyone on the team does the same task the same way | **Prompt file** | Shared template is simpler than a full agent config |
| Global rules that apply to all tasks | **Repo instructions** | `AGENTS.md` is the right place for universal rules |
| Multi-step procedure with decision points | **Skill** | Skills handle branching; agents handle identity |

### Decision Flow

```
Does this task need different permissions from the default agent?
├── Yes → Custom agent (permission boundary is the key differentiator)
└── No
    ├── Does it need a specific persona/tone/output format?
    │   ├── Yes → Custom agent (role identity matters)
    │   └── No → Prompt file or repo instructions
    └── Is it a one-off task?
        ├── Yes → Chat prompt
        └── No → Prompt file
```

---

## Common Agent Profiles

### Security Auditor

| Element | Value |
| :--- | :--- |
| **Role** | Review code for vulnerabilities |
| **Tools** | Read-only (no writes, no commands) |
| **Focus** | OWASP Top 10, secrets, input validation |
| **Output** | Structured finding table with severity |

### Code Reviewer

| Element | Value |
| :--- | :--- |
| **Role** | Review code for quality, maintainability, correctness |
| **Tools** | Read-only + run tests (no writes) |
| **Focus** | Logic errors, edge cases, naming, patterns |
| **Output** | Line-level comments with severity |

### Test Writer

| Element | Value |
| :--- | :--- |
| **Role** | Generate tests for specified code |
| **Tools** | Read + write test files + run tests |
| **Focus** | Coverage, edge cases, existing test patterns |
| **Output** | Test files matching project conventions |

### Documentation Writer

| Element | Value |
| :--- | :--- |
| **Role** | Generate or update documentation |
| **Tools** | Read all + write docs only |
| **Focus** | API docs, README, architectural docs |
| **Output** | Markdown following project doc conventions |

### Refactoring Specialist

| Element | Value |
| :--- | :--- |
| **Role** | Improve code structure without changing behavior |
| **Tools** | Read + write source + run tests |
| **Focus** | Reduce duplication, improve naming, simplify logic |
| **Output** | Refactored code with passing tests as proof |

---

## Designing Permissions

### Permission Levels

| Level | Can Do | Use For |
| :--- | :--- | :--- |
| **Read-only** | Read files, search code, list directories | Auditors, reviewers |
| **Read + test** | Above + run test commands | Reviewers who verify claims |
| **Read + write scoped** | Above + write to specific directories | Test writers (write to `__tests__/` only) |
| **Read + write broad** | Above + write anywhere in source | Feature development, refactoring |
| **Full** | Above + run arbitrary commands, git operations | Trusted automation (use sparingly) |

### Permission Design Checklist

For each custom agent, answer:

| Question | Why |
| :--- | :--- |
| What files can it read? | Prevent exposure to secrets or irrelevant code |
| What files can it write? | Prevent unintended modifications |
| What commands can it run? | Prevent destructive operations |
| Can it access the network? | Prevent data exfiltration |
| Can it modify git history? | Usually no — humans own the commit log |

---

## Configuration Patterns

How custom agents map to current tooling:

### Claude Code

```
.claude/
└── agents/
    ├── security-auditor.md
    ├── test-writer.md
    └── doc-writer.md
```

Each file contains the agent's instructions, which override or supplement the root `CLAUDE.md`.

### Cursor

```
.cursor/
└── agents/
    ├── security-auditor.md
    └── test-writer.md
```

Agent files define persona instructions and are invoked via `@agent` in chat.

### Tool-Agnostic Pattern

If your tool doesn't natively support custom agents, simulate them:

1. **Create a prompt file** that includes role, instructions, and constraints
2. **Reference it** at the start of each session: "Follow the instructions in `.prompts/security-auditor.prompt.md`"
3. **Track the persona** in your `AGENTS.md` under a "Available Agent Profiles" section

---

### Good vs Bad Example

| Pattern | Example | Why |
| :--- | :--- | :--- |
| **Good** | `security-auditor` agent with read/search tools only and fixed findings format | Enforces least privilege and consistent review output |
| **Bad** | `agent-2` with full read/write/exec and vague "be helpful" instructions | Overprivileged and unpredictable behavior |

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| :--- | :--- | :--- |
| **"God agent"** | One agent with all permissions for everything | Split into focused roles with minimal permissions |
| **Too many agents** | 15 agents, each slightly different | Consolidate to 3-5 with clear role boundaries |
| **No permission boundaries** | Custom agent exists but has full access | Define explicit allow/deny lists per role |
| **Duplicated instructions** | Same rules in repo instructions AND agent config | Keep universal rules in `AGENTS.md`; agent config adds only role-specific rules |
| **Stale agent configs** | Agent references deleted files or outdated patterns | Review agent configs during regular maintenance |
| **Agent without a use case** | Created "just in case" | Delete it — unused config is noise |

---

## Self-Assessment Checklist

Before creating a custom agent:

- [ ] Does this role genuinely need different permissions from the default?
- [ ] Is the role description clear enough that a new team member would understand it?
- [ ] Are permissions explicitly defined (not inherited from defaults)?
- [ ] Is the output format specified (not left to the agent's discretion)?
- [ ] Are universal rules in `AGENTS.md`, not duplicated in the agent config?
- [ ] Have you tested the agent against a real task?

---

## Red Flags

| Signal | Action | Rationale |
| :--- | :--- | :--- |
| Agent has full read/write/execute permissions | Tighten to least privilege immediately | Overprivileged agents are a security and correctness risk |
| More than 5 custom agents in one project | Consolidate overlapping roles | Complexity grows faster than value |
| Agent instructions duplicate `AGENTS.md` content | Move shared rules to `AGENTS.md`, keep only role-specific rules in agent config | Duplication causes drift |
| Custom agent created but never used | Delete it | Unused config is maintenance burden and noise |
| Agent instructions are vague ("be helpful") | Rewrite with specific focus areas and output format | Vague instructions produce unpredictable results |

---

## See Also

- [AGENTS.md Guidelines](../agents-md/agents-md-guidelines.md) – Repo-wide instructions (the governance layer agents operate under)
- [Prompt Files](../prompt-files/prompt-files.md) – Reusable task templates (simpler than full agent configs)
- [Tool Configuration](../tool-configuration/tool-configuration.md) – Setting up AI coding tools
- [Context Management](../context-management/context-management.md) – Managing what information agents can see
- [Agent Skills](../../skills/README.md) – Repeatable procedures agents follow (distinct from agent identity)
