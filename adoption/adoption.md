# Adopting Best Practices

A guide for integrating this repository into your projects so AI coding assistants follow consistent standards.

> **Scope**: Works with any AI coding tool (Claude, Codex, Gemini, Cursor) across any number of projects.

## Contents

| Section |
| --- |
| [Quick Start](#quick-start) |
| [One-Time Setup](#one-time-setup) |
| [Per-Project Adoption](#per-project-adoption) |
| [The Reference Directive](#the-reference-directive) |
| [Project Template](#project-template) |
| [Drift Prevention](#drift-prevention) |
| [Maintenance](#maintenance) |
| [Troubleshooting](#troubleshooting) |

---

## Quick Start

```bash
# One-time: clone to standard location
git clone https://github.com/[org]/agentic-best-practices.git ~/agentic-best-practices

# Per-project: copy template and customize
cp ~/agentic-best-practices/adoption/template-agents.md ./AGENTS.md
ln -s AGENTS.md CLAUDE.md  # For Claude Code compatibility
# Edit AGENTS.md to fill in project-specific sections
```

---

## One-Time Setup

Clone this repository to a consistent location on your machine.

| Decision | Recommendation | Rationale |
| --- | --- | --- |
| **Location** | `~/agentic-best-practices` | Predictable path across all projects |
| **Method** | Direct clone (not submodule) | Single source of truth; updates propagate immediately |
| **Updates** | `git pull` periodically | Keep standards current |

```bash
git clone https://github.com/[org]/agentic-best-practices.git ~/agentic-best-practices
```

**Why not submodules?** Submodules version-lock each project to a specific commit. For standards, you typically want all projects to follow the *current* standards, not frozen snapshots. A single shared clone ensures consistency.

---

## Per-Project Adoption

For each project (new or existing):

| Step | Action |
| --- | --- |
| **1. Copy template** | `cp ~/agentic-best-practices/adoption/template-agents.md ./AGENTS.md` |
| **2. Symlink for Claude** | `ln -s AGENTS.md CLAUDE.md` |
| **3. Fill project sections** | Tech stack, commands, project-specific boundaries |
| **4. Verify reference path** | Ensure `~/agentic-best-practices` path is correct for your setup |
| **5. Commit** | Add `AGENTS.md` and `CLAUDE.md` to version control |

### Existing Projects

For projects that already have an AGENTS.md:

| Situation | Action |
| --- | --- |
| **No existing AGENTS.md** | Use template directly |
| **Has AGENTS.md, no conflicts** | Add the Reference Directive section |
| **Has AGENTS.md with local standards** | Migrate local standards to agentic-best-practices or mark as intentional overrides |

---

## The Reference Directive

The core mechanism is a directive in your project's AGENTS.md that tells AI to consult agentic-best-practices.

```markdown
## Standards Reference

This project follows organizational standards defined in `~/agentic-best-practices/`.

**Before implementing**, consult the relevant guide:

| Topic | Guide |
| --- | --- |
| Error handling | `~/agentic-best-practices/guides/error-handling/error-handling.md` |
| Logging | `~/agentic-best-practices/guides/logging-practices/logging-practices.md` |
| API design | `~/agentic-best-practices/guides/api-design/api-design.md` |
| Documentation | `~/agentic-best-practices/guides/documentation-guidelines/documentation-guidelines.md` |
| Code style | `~/agentic-best-practices/guides/coding-guidelines/coding-guidelines.md` |

For other topics, check `~/agentic-best-practices/README.md` for the full guide index (all guides are in `~/agentic-best-practices/guides/`).

**Deviation policy**: Do not deviate from these standards without explicit approval. If deviation is necessary, document it in the Project-Specific Overrides section with rationale.
```

### Why This Works

| Mechanism | Effect |
| --- | --- |
| **Explicit file paths** | AI can read the guides directly |
| **"Before implementing"** | AI checks standards before writing code |
| **Deviation policy** | AI asks before going off-script |
| **Guide table** | Quick lookup for common topics |
| **README fallback** | Covers topics not in the quick table |

---

## Project Template

Copy `~/agentic-best-practices/adoption/template-agents.md` to your project as `AGENTS.md`.

The template has three parts:

| Section | What to customize |
| --- | --- |
| **Project-Specific** | Tech stack, commands, boundaries unique to this project |
| **Standards Reference** | Usually unchanged; update path if not using `~/agentic-best-practices` |
| **Project-Specific Overrides** | Document any intentional deviations (ideally empty) |

See [template-agents.md](template-agents.md) for the full template.

---

## Drift Prevention

Standards are useless if projects slowly diverge. These mechanisms prevent drift.

### 1. Deviation Requires Justification

The template includes:

```markdown
## Project-Specific Overrides

<!-- Any deviation from ~/agentic-best-practices must be documented here with rationale -->
<!-- If this section is empty, the project follows all standards without exception -->
```

**Effect**: AI must document *why* before deviating. Visible overrides are auditable.

### 2. Periodic Consistency Check

Add to your project's AGENTS.md:

```markdown
## Maintenance

When starting a new major feature or quarterly:
1. Run `git -C ~/agentic-best-practices pull` to update standards
2. Review recent changes: `git -C ~/agentic-best-practices log --oneline -20`
3. Verify project patterns still align with current standards
```

**Effect**: Standards updates don't silently diverge from project practice.

### 3. No Silent Overrides

The reference directive includes:

```markdown
**Deviation policy**: Do not deviate from these standards without explicit approval.
```

**Effect**: AI asks before doing something that contradicts agentic-best-practices.

### 4. Audit Trail

When AI must deviate, it documents in the Overrides section:

```markdown
## Project-Specific Overrides

### Error Handling
**Standard**: Use Result pattern (error-handling.md)
**Override**: Use exceptions for this legacy codebase
**Rationale**: Codebase predates Result pattern adoption; migration planned for Q3
**Approved**: 2025-01-15
```

**Effect**: Deviations are visible, justified, and time-stamped.

---

## Maintenance

### Updating Standards

When agentic-best-practices is updated:

```bash
cd ~/agentic-best-practices && git pull
```

All projects automatically use the updated standards (no per-project action needed).

### Adding Project-Specific Patterns

| If the pattern is... | Then... |
| --- | --- |
| **Useful to other projects** | Add to agentic-best-practices, not project AGENTS.md |
| **Truly project-specific** | Add to project's AGENTS.md in Project-Specific section |
| **A deviation from standards** | Document in Overrides section with rationale |

### Reviewing Overrides

Periodically review the Overrides section:

| Question | Action |
| --- | --- |
| Is this override still needed? | Remove if no longer applicable |
| Should this be standard? | Propose change to agentic-best-practices |
| Is the rationale still valid? | Update or remove if circumstances changed |

---

## Troubleshooting

| Issue | Cause | Fix |
| --- | --- | --- |
| AI doesn't follow standards | Missing reference directive | Add Standards Reference section to AGENTS.md |
| AI can't find guides | Wrong path | Verify `~/agentic-best-practices` exists and path is correct |
| AI ignores directive | Directive too buried | Move Standards Reference near top of AGENTS.md |
| Different behavior across tools | Tool-specific files | Ensure CLAUDE.md symlinks to AGENTS.md |
| Standards seem outdated | Haven't pulled recently | Run `git -C ~/agentic-best-practices pull` |

### Verifying Setup

```bash
# Check best-practices is cloned
ls ~/agentic-best-practices/README.md

# Check project has AGENTS.md
ls ./AGENTS.md

# Check symlink for Claude
ls -la ./CLAUDE.md  # Should show -> AGENTS.md

# Check AGENTS.md references best-practices
grep "agentic-best-practices" ./AGENTS.md
```

---

## See Also

- [AGENTS.md Guidelines](../guides/agents-md/agents-md-guidelines.md) – Writing effective instruction files
- [Tool Configuration](../guides/tool-configuration/tool-configuration.md) – Configuring AI tools
- [Template](template-agents.md) – Ready-to-use project template
