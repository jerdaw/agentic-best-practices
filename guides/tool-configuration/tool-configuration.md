# Tool Configuration for AI Coding Assistants

> **Scope**: These configurations represent effective starting points. Tools evolve; verify against current
> documentation. Focus on patterns over specific settings.

## Contents

| Section |
| :--- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Toolchain Reproducibility](#toolchain-reproducibility) |
| [Runtime and Package Manager Pinning](#runtime-and-package-manager-pinning) |
| [Pre-Commit Orchestration](#pre-commit-orchestration) |
| [Claude Code](#claude-code) |
| [Cursor](#cursor) |
| [GitHub Copilot](#github-copilot) |
| [VS Code Integration](#vs-code-integration) |
| [JetBrains IDEs](#jetbrains-ides) |
| [Security Configuration](#security-configuration) |
| [Context Optimization](#context-optimization) |
| [Multi-Tool Workflows](#multi-tool-workflows) |
| [Keybinding Recommendations](#keybinding-recommendations) |
| [Troubleshooting](#troubleshooting) |
| [Failure Modes and Recovery](#failure-modes-and-recovery) |
| [Anti-Patterns](#anti-patterns) |

---

## Quick Reference

**Essential configurations**:

- Project-specific instructions (AGENTS.md, CLAUDE.md)
- Verification gates (commands that must pass before completion)
- Documentation map (where ADRs/runbooks/specs live)
- File/folder exclusions (node_modules, build outputs)
- Security boundaries (no secrets access)
- Keybindings for common actions

**Configuration priority**:

1. Security settings first
2. Project-specific instructions
3. Exclusions and context limits
4. Keybindings and efficiency

---

## Core Principles

1. **Security first** – Configure boundaries before features
2. **Project context** – Tool should understand your codebase
3. **Exclude noise** – Keep irrelevant files out of context
4. **Consistent patterns** – Similar config across tools when possible
5. **Document decisions** – Future you will thank you

---

## Toolchain Reproducibility

| Goal | Recommended artifact | Example files |
| --- | --- | --- |
| Runtime parity | Version pinning files committed | `.nvmrc`, `.tool-versions`, `.mise.toml` |
| Package manager parity | Single package manager lock + config | `pnpm-lock.yaml`, `.npmrc` |
| Formatting parity | Editor and formatter config in repo | `.editorconfig`, formatter config |
| Local/CI parity | CI uses same runtime resolver as local | `actions/setup-node` + pinned version |

| Good pattern | Bad pattern |
| --- | --- |
| `npm ci` or lockfile-strict install in CI | Floating install behavior across developers |
| One canonical runtime pin file strategy | Different teams pinning conflicting versions |

```yaml
# Good: CI pin aligns with repo runtime pin
- uses: actions/setup-node@v4
  with:
    node-version-file: '.nvmrc'
```

```yaml
# Bad: floating runtime in CI
- uses: actions/setup-node@v4
  with:
    node-version: 'latest'
```

---

## Runtime and Package Manager Pinning

| Component | Rule | Rationale |
| --- | --- | --- |
| Runtime | Pin major+minor where possible | Avoid silent runtime behavior changes |
| Package manager | Pin package manager and lockfile format | Stable dependency resolution |
| Lockfiles | Commit and treat as required | Reproducible dependency graph |
| Overrides/resolutions | Document why and expiry plan | Prevent stale dependency hacks |

| Pinning check | Verification |
| --- | --- |
| Runtime pin exists | CI step validates file present |
| Lockfile in sync | CI fails on lockfile drift |
| Tool install path documented | README/dev setup references exact commands |

---

## Pre-Commit Orchestration

| Hook stage | Recommended checks | Why |
| --- | --- | --- |
| `pre-commit` | Format/lint staged files | Fast feedback before push |
| `commit-msg` | Commit message policy | Consistent changelog and automation metadata |
| CI required checks | Full test + security + validation | Prevent bypass from local environment differences |

```bash
# Good: staged-only checks for speed
npx lint-staged
```

```bash
# Bad: heavyweight full test suite in pre-commit for every commit
npm test
```

| Design rule | Guidance |
| --- | --- |
| Keep hooks fast | Prefer staged-file checks under ~10-20s |
| Keep CI authoritative | Hooks help; CI must still enforce full policy |
| Keep failures actionable | Hook output should tell exactly what to run next |

---

## Claude Code

### Project Instructions

Create `AGENTS.md` in project root (standard format). For Claude Code compatibility, symlink `CLAUDE.md` to it:

```bash
ln -s AGENTS.md CLAUDE.md
```

```markdown
# AGENTS.md

## Agent Role
You are a [specific role] working on [project type]. Priorities:
1. [First priority]
2. [Second priority]
3. [Third priority]

## Tech Stack

| Layer | Technology | Version |
| :--- | :--- | :--- |
| Language | TypeScript | 5.x |
| Framework | Express | 4.x |
| Database | PostgreSQL | 15 |

## Key Commands

```bash
npm run dev          # Development server
npm test             # Run tests
npm run lint         # Lint code
npm run build        # Production build
```

## Verification Gates

```bash
npm run lint
npm test
npm run validate
```

## Documentation Map

| Documentation Type | Path |
| :--- | :--- |
| ADRs | docs/adr/ |
| Runbooks/process | docs/process/ |
| Planning/specs | docs/planning/ |

## Boundaries

### Always

- Run lint before committing
- Write tests for new functionality
- Update docs/docstrings/comments when behavior or API changes

### Ask First

- Database schema changes
- Adding new dependencies

### Never

- Access .env files
- Commit secrets
- Force push to main

```

### Settings Configuration

Claude Code settings are in `~/.claude/settings.json`:

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run *)",
      "Bash(git status)",
      "Bash(git diff*)",
      "Bash(git log*)"
    ],
    "deny": [
      "Bash(rm -rf*)",
      "Bash(git push --force*)",
      "Bash(*--no-verify*)"
    ]
  }
}
```

### Useful Slash Commands

| Command | Purpose |
| :--- | :--- |
| `/help` | Show available commands |
| `/clear` | Clear conversation |
| `/compact` | Compact conversation history |
| `/review` | Review code changes |
| `/commit` | Create a commit |

### Context Exclusions

Create `.claudeignore` to exclude files:

```markdown
# Build outputs
dist/
build/
.next/

# Dependencies
node_modules/

# Generated files
*.generated.ts
coverage/

# Large files
*.min.js
*.bundle.js

# Sensitive
.env*
secrets/
```

---

## Cursor

### Project-Level Settings

Create `.cursor/settings.json`:

```json
{
  "aiProvider": "anthropic",
  "contextFiles": {
    "include": ["src/**/*", "tests/**/*"],
    "exclude": ["node_modules/**", "dist/**"]
  }
}
```

### Rules File

Create `.cursorrules` for project-specific instructions:

```markdown
You are working on a TypeScript Express API.

Tech stack:
- TypeScript 5.x
- Express 4.x
- PostgreSQL with Prisma ORM
- Jest for testing

Conventions:
- Use async/await for all async operations
- Use the Result pattern for error handling
- Write JSDoc comments for public APIs only
- Follow existing patterns in the codebase

When writing code:
- Check existing code for patterns before implementing
- Run `npm run lint` after changes
- Always handle potential null values

Never:
- Use `any` type without justification
- Access environment variables directly (use config module)
- Write console.log (use logger)
```

### Keybindings

| Action | Default | Purpose |
| :--- | :--- | :--- |
| Open AI chat | Cmd/Ctrl + L | Start conversation |
| Edit with AI | Cmd/Ctrl + K | Inline edit |
| Accept suggestion | Tab | Accept completion |
| Reject suggestion | Esc | Dismiss completion |
| Toggle AI panel | Cmd/Ctrl + Shift + L | Show/hide panel |

### Composer Configuration

For multi-file operations:

| Setting | Recommended |
| :--- | :--- |
| Context scope | Current folder + imports |
| Max context files | 10-20 files |
| Include tests | When writing features |

---

## GitHub Copilot

### VS Code Settings

In `.vscode/settings.json`:

```json
{
  "github.copilot.enable": {
    "*": true,
    "plaintext": false,
    "markdown": true,
    "yaml": true
  },
  "github.copilot.advanced": {
    "length": 500,
    "temperature": 0.1
  }
}
```

### Instructions File

Create `.github/copilot-instructions.md`:

```markdown
# Copilot Instructions

## Project Context
This is a TypeScript React application using:
- React 18 with hooks
- TypeScript strict mode
- Tailwind CSS for styling
- React Query for server state

## Code Style
- Functional components only
- Custom hooks for shared logic
- Named exports (not default)
- Colocate tests with components

## Patterns to Follow
- Use `useQuery` and `useMutation` for API calls
- Handle loading and error states explicitly
- Use TypeScript discriminated unions for state

## Avoid
- Class components
- Redux (use React Query + context)
- CSS modules (use Tailwind)
- Any type without justification
```

### Keybindings

| Action | Windows/Linux | Mac |
| :--- | :--- | :--- |
| Accept suggestion | Tab | Tab |
| Dismiss suggestion | Esc | Esc |
| Next suggestion | Alt + ] | Option + ] |
| Previous suggestion | Alt + [ | Option + [ |
| Open Copilot panel | Ctrl + Enter | Ctrl + Enter |
| Trigger suggestion | Alt + \ | Option + \ |

### Excluding Files

In `.vscode/settings.json`:

```json
{
  "github.copilot.advanced": {
    "excludeFilePatterns": [
      "**/.env*",
      "**/secrets/**",
      "**/credentials/**",
      "**/*.key",
      "**/*.pem"
    ]
  }
}
```

---

## VS Code Integration

### General AI Settings

```json
{
  // Inline suggestions
  "editor.inlineSuggest.enabled": true,
  "editor.inlineSuggest.showToolbar": "always",

  // Suggestion delays
  "editor.quickSuggestionsDelay": 100,

  // Tab completion behavior
  "editor.tabCompletion": "on",

  // Auto-formatting on save
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.organizeImports": "explicit",
    "source.fixAll.eslint": "explicit"
  }
}
```

### Recommended Extensions

| Extension | Purpose |
| :--- | :--- |
| ESLint | Catches errors AI introduces |
| Prettier | Consistent formatting |
| TypeScript Hero | Import management |
| Error Lens | Inline error display |
| GitLens | Git context for AI decisions |

### Workspace-Specific Settings

Create `.vscode/settings.json` per project:

```json
{
  "typescript.tsdk": "node_modules/typescript/lib",
  "editor.defaultFormatter": "esbenp.prettier-vscode",

  // Project-specific file associations
  "files.associations": {
    "*.prisma": "prisma"
  },

  // Hide generated files
  "files.exclude": {
    "**/node_modules": true,
    "**/dist": true,
    "**/*.generated.ts": true
  },

  // Search exclusions (affects AI context)
  "search.exclude": {
    "**/node_modules": true,
    "**/dist": true,
    "**/coverage": true,
    "**/*.min.js": true
  }
}
```

---

## JetBrains IDEs

### AI Assistant Settings

In Settings → Tools → AI Assistant:

| Setting | Recommended |
| :--- | :--- |
| Enable suggestions | On |
| Delay before showing | 300ms |
| Max suggestions | 3 |
| Enable chat | On |

### Project Instructions

Create `.idea/ai-instructions.md`:

```markdown
# AI Instructions

## Project: [Name]
TypeScript Node.js backend service

## Stack
- Node.js 20
- TypeScript 5
- Express 4
- Jest

## Conventions
- Async/await for promises
- Repository pattern for data access
- Constructor injection for dependencies

## Commands
- `npm run dev` - Start development
- `npm test` - Run tests
- `npm run lint` - Lint code
```

### Exclusions

In `.idea/misc.xml`, ensure exclusions:

```xml
<component name="ExcludedFiles">
  <folder url="file://$PROJECT_DIR$/node_modules" />
  <folder url="file://$PROJECT_DIR$/dist" />
  <folder url="file://$PROJECT_DIR$/coverage" />
</component>
```

---

## Security Configuration

### Secrets Protection

All tools should exclude:

```markdown
# Environment files
.env
.env.*
*.env

# Key files
*.pem
*.key
id_rsa*

# Config with secrets
config/production.json
secrets/
credentials/

# Cloud provider configs
.aws/
.gcp/
```

### Boundary Commands

Block dangerous operations in tool configs:

```json
{
  "deny": [
    "rm -rf /",
    "rm -rf ~",
    "git push --force origin main",
    "git reset --hard",
    ":(){ :|:& };:",
    "chmod 777",
    "curl | sh",
    "wget | bash"
  ]
}
```

### Audit Logging

If available, enable:

| Setting | Purpose |
| :--- | :--- |
| Command logging | Track what AI executes |
| Prompt logging | Review what AI sees |
| Output logging | Debug unexpected behavior |

---

## Context Optimization

### What to Include

| Include | Why |
| :--- | :--- |
| Source files | Core context |
| Type definitions | AI needs types |
| Configuration | Project patterns |
| Key documentation | Requirements, ADRs |

### What to Exclude

| Exclude | Why |
| :--- | :--- |
| node_modules | Too large, not helpful |
| Build outputs | Generated code |
| Test snapshots | Large, low signal |
| Binary files | Can't read |
| Lock files | Noise |

### Size Limits

Keep AI context manageable:

| Content | Limit |
| :--- | :--- |
| Single file | < 500 lines preferred |
| Context files | < 20 files |
| Total context | < 100KB text |

---

## Multi-Tool Workflows

### Complementary Tool Combinations

| Workflow | Tools | Division |
| :--- | :--- | :--- |
| Writing + completion | Cursor + Copilot | Cursor for chat, Copilot for inline |
| CLI + IDE | Claude Code + VS Code | CLI for tasks, IDE for editing |
| Review + commit | Any AI + GitLens | AI for code, GitLens for git context |

### Avoiding Conflicts

| Issue | Solution |
| :--- | :--- |
| Overlapping suggestions | Disable one inline completer |
| Different style recommendations | Standardize rules files |
| Conflicting keybindings | Customize one tool's bindings |

### Configuration Sync

Keep consistent across tools:

| Sync Item | How |
| :--- | :--- |
| Exclusions | Same patterns in all tools |
| Project instructions | Reference same source |
| Security rules | Consistent boundaries |

---

## Keybinding Recommendations

### Essential Bindings

| Action | Suggested Key |
| :--- | :--- |
| Trigger AI | Alt/Option + Space |
| Accept suggestion | Tab |
| Dismiss suggestion | Esc |
| Open AI chat | Ctrl/Cmd + Shift + A |
| Inline edit | Ctrl/Cmd + I |
| Accept and continue | Ctrl/Cmd + Tab |

### Productivity Bindings

| Action | Suggested Key |
| :--- | :--- |
| Generate tests | Ctrl/Cmd + Shift + T |
| Explain selection | Ctrl/Cmd + Shift + E |
| Fix error at cursor | Ctrl/Cmd + . (VS Code default) |
| Format document | Ctrl/Cmd + Shift + F |

---

## Troubleshooting

### Common Issues

| Issue | Cause | Fix |
| :--- | :--- | :--- |
| Slow suggestions | Large context | Add exclusions |
| Wrong patterns | Missing instructions | Add rules file |
| Secrets in suggestions | Files not excluded | Add to ignore files |
| Conflicting tools | Multiple active | Disable one |
| Stale suggestions | Cached context | Restart tool/IDE |

### Verification Checklist

- [ ] Project instructions file exists
- [ ] Exclusions configured (node_modules, dist, etc.)
- [ ] Secrets excluded (.env, keys)
- [ ] Dangerous commands blocked
- [ ] Keybindings comfortable
- [ ] No tool conflicts

---

## Failure Modes and Recovery

| Failure mode | Symptom | Recovery |
| --- | --- | --- |
| Runtime mismatch | Works locally, fails in CI | Align runtime pins and setup commands |
| Lockfile drift | Frequent dependency-only PR noise | Enforce frozen lockfile installs in CI |
| Hook fatigue | Developers bypass hooks | Move slow checks to CI and keep local hooks lightweight |
| Conflicting AI rules | Inconsistent output style | Consolidate canonical rules and reference from tool-specific files |
| Stale instructions | AI follows outdated project context | Version and review tool instructions in PR workflow |

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| :--- | :--- | :--- |
| **No exclusions** | AI chokes on node_modules | Configure exclusions |
| **No project instructions** | AI doesn't know context | Add AGENTS.md/rules |
| **Default keybindings only** | Inefficient workflow | Customize for speed |
| **Multiple completion providers** | Conflicting suggestions | Choose one |
| **No security config** | AI might see secrets | Configure exclusions |
| **Overly aggressive AI** | Too many suggestions | Increase delay |

---

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| Tool config files not committed to version control | Commit them — consistency requires shared config | Uncommitted config means every dev has different behavior |
| Tool rules override each other with conflicting settings | Audit and reconcile overlapping configurations | Conflicting rules cause inconsistent formatting and false lint errors |
| AI tool has access to production secrets or credentials | Restrict tool permissions to development scope only | AI tools with prod access are a security breach waiting to happen |
| No `.editorconfig` or formatter config in the repo | Add one — consistent formatting prevents diff noise | Without shared config, every developer introduces formatting churn |

---

## See Also

- [Security Boundaries](../security-boundaries/security-boundaries.md) – Security requirements for AI tools
- [Cost & Token Management](../cost-token-management/cost-token-management.md) – Configuring cost controls
