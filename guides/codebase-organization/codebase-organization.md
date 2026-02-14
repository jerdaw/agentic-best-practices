# Codebase Organization

Best practices for structuring codebases to be easily navigable and understandable for both humans and AI coding
agents.

> **Scope**: Applies to project structure, file naming, and directory hierarchy. A logical organization reduces context
> window consumption and helps agents find relevant code faster.

## Contents

| Section |
| :--- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Standard Directory Layout](#standard-directory-layout) |
| [Naming Conventions](#naming-conventions) |
| [Module Boundaries](#module-boundaries) |
| [Configuration vs Code](#configuration-vs-code) |
| [Anti-Patterns](#anti-patterns) |

---

## Quick Reference

| Category | Guidance | Rationale |
| :--- | :--- | :--- |
| **Hierarchy** | Prefer flat-ish structures over deep nesting | Reduces path complexity for AI |
| **Naming** | Use descriptive, consistent file names | Enables discovery via file search |
| **Location** | Group by feature, not by technical type | Keeps related logic together |
| **Entry** | Define clear entry points for every module | Grounding point for agents |
| **Tests** | Keep tests alongside source code | Immediate context for behavior |

---

## Core Principles

1. **Discoverability** – An agent should find any file in 3 seconds via path/name alone.
2. **Locality** – Code that changes together should live together.
3. **Predictability** – Once a pattern is established, stick to it everywhere.
4. **Encapsulation** – Modules should expose only what's necessary (clean interfaces).
5. **Self-Documenting** – The folder structure should reflect the domain model.

---

## Standard Directory Layout

A recommended structure for most agentic-friendly projects.

```text
/
├── docs/               # System documentation, architecture, ADRs
├── scripts/            # Build, deploy, and maintenance scripts
├── src/
│   ├── api/            # External interfaces (HTTP, CLI)
│   ├── core/           # Domain logic, purely business rules
│   ├── infra/          # DB, External APIs, Cloud services
│   └── utils/          # Generic helper functions
├── tests/              # Multi-module integration and E2E tests
├── AGENTS.md           # Instructions for AI coding agents
└── README.md           # Instructions for Humans
```

### Feature-Based Organization (Preferred)

For larger apps, group by domain feature rather than technical layer.

```text
src/
├── users/              # Everything related to users
│   ├── user.service.ts
│   ├── user.repository.ts
│   └── user.test.ts
├── billing/            # Everything related to payments
│   ├── invoice.ts
│   ├── stripe.client.ts
│   └── billing.test.ts
```

---

## Naming Conventions

Consistent naming is the primary way agents find code.

| Type | Convention | Example |
| :--- | :--- | :--- |
| **Files** | kebab-case or PascalCase | `user-validator.ts` |
| **Directories**| kebab-case | `payment-processing/` |
| **Tests** | `*.test.*` or `*.spec.*` | `auth.service.test.ts` |
| **Constants** | `*.config.*` | `database.config.json` |

---

## Module Boundaries

Define clear interfaces between modules to prevent global spaghetti.

1. **index.ts** – Use as a public "barrel" to export only public APIs.
2. **internal/** – Mark private logic that should not be imported elsewhere.
3. **types/** – Share interfaces in a dedicated folder for cross-module use.

---

## Configuration vs Code

Keep static configuration separate from executable logic.

| Configuration | Location |
| :--- | :--- |
| **Environment Vars** | `.env.example` (templates) |
| **Build Settings** | Root level (`tsconfig.json`, `package.json`) |
| **Feature Flags** | `src/config/flags.ts` |
| **Constants** | `src/config/constants.ts` |

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| :--- | :--- | :--- |
| **The "misc" folder** | Becomes a dumping ground | Find a specific domain home |
| **Deep nesting** | Path strings get too long | Flatten to 3-4 levels max |
| **Generic names** | `index.ts`, `util.ts` | Use descriptive names: `auth.router.ts` |
| **Circular deps** | Impossible to reason about | Extract shared logic to a base module |
| **Shadowing** | Same name in different folders | Use prefix: `api-user` vs `db-user` |

---

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| Circular dependency detected | Extract shared logic to a base module | Circular deps make builds and reasoning impossible |
| `utils/` or `helpers/` folder growing past 10 files | Break into domain-specific modules | Junk drawer folders destroy discoverability |
| Importing from another module's internals | Import through the public barrel (`index.ts`) | Direct internal imports create tight coupling |
| Directory nesting deeper than 4 levels | Flatten — reorganize by feature | Deep paths waste context window tokens |
| Same concept named differently in different modules | Standardize terminology across the codebase | Inconsistent naming creates confusion and duplication |

---

## See Also

- [Architecture for AI](../architecture-for-ai/architecture-for-ai.md) – Mapping code to design
- [Coding Guidelines](../coding-guidelines/coding-guidelines.md) – Internal code style
- [Dependency Management](../dependency-management/dependency-management.md) – External organization
