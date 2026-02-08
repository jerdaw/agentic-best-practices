# Adopting Best Practices

A guide for integrating this repository into your projects so AI coding assistants follow consistent standards.

> **Scope**: Works with any AI coding tool (Claude, Codex, Gemini, Cursor) across any number of projects.

## Contents

| Section |
| --- |
| [Quick Start](#quick-start) |
| [One-Time Setup](#one-time-setup) |
| [Adoption Modes](#adoption-modes) |
| [Per-Project Adoption](#per-project-adoption) |
| [Existing Projects](#existing-projects) |
| [Migration Workflows](#migration-workflows) |
| [Pilot Enablement](#pilot-enablement) |
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

# Set standards path (customize if needed)
export AGENTIC_BEST_PRACTICES_HOME="${AGENTIC_BEST_PRACTICES_HOME:-$HOME/agentic-best-practices}"

# Per-project: render AGENTS.md + CLAUDE.md with defaults
bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/adopt-into-project.sh" \
  --project-dir . \
  --standards-path "$AGENTIC_BEST_PRACTICES_HOME"

# Optional: pin standards to a release tag or commit SHA
bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/adopt-into-project.sh" \
  --project-dir . \
  --standards-path "$AGENTIC_BEST_PRACTICES_HOME" \
  --adoption-mode pinned \
  --pinned-ref v1.0.0

# Validate the generated adoption files
bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/validate-adoption.sh" \
  --project-dir . \
  --expect-standards-path "$AGENTIC_BEST_PRACTICES_HOME"
# For pinned mode, validate without --expect-standards-path (or pass the pinned path from AGENTS.md)

# Optional: prepare pilot artifacts for a 6-8 week validation run
bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/prepare-pilot-project.sh" \
  --project-dir . \
  --standards-path "$AGENTIC_BEST_PRACTICES_HOME" \
  --existing-mode merge \
  --pilot-owner "Team Name"
```

---

## One-Time Setup

Clone this repository to a consistent location on your machine.

| Decision | Recommendation | Rationale |
| --- | --- | --- |
| **Location** | `~/agentic-best-practices` or custom path in `AGENTIC_BEST_PRACTICES_HOME` | Predictable path across projects |
| **Method** | Direct clone (not submodule) | Single source of truth; updates propagate immediately |
| **Updates** | `git pull` periodically | Keep standards current |

```bash
git clone https://github.com/[org]/agentic-best-practices.git ~/agentic-best-practices
export AGENTIC_BEST_PRACTICES_HOME="${AGENTIC_BEST_PRACTICES_HOME:-$HOME/agentic-best-practices}"
```

**Why not submodules?** Submodules version-lock each project to a specific commit. For standards, you typically want all projects to follow the current standards, not frozen snapshots.

---

## Adoption Modes

Choose one of two supported modes:

| Mode | Best for | Behavior |
| --- | --- | --- |
| **Latest** (default) | Teams that want fast propagation of updates | AGENTS points to shared standards repo path |
| **Pinned** | Regulated/risk-sensitive repos needing deterministic standards | Creates project-local snapshot at a chosen git ref |

### Latest mode

```bash
bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/adopt-into-project.sh" \
  --project-dir . \
  --standards-path "$AGENTIC_BEST_PRACTICES_HOME" \
  --adoption-mode latest
```

### Pinned mode

```bash
# Use a release tag (recommended) or commit SHA
bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/adopt-into-project.sh" \
  --project-dir . \
  --standards-path "$AGENTIC_BEST_PRACTICES_HOME" \
  --adoption-mode pinned \
  --pinned-ref v1.0.0 \
  --pinned-dir .agentic-best-practices/pinned
```

Pinned mode writes snapshot metadata to:

- `<project>/.agentic-best-practices/pinned/<ref>-<sha>/.abp-pin.json`

---

## Per-Project Adoption

For each project (new or existing):

| Step | Action |
| --- | --- |
| **1. Run bootstrap** | `bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/adopt-into-project.sh" --project-dir . --standards-path "$AGENTIC_BEST_PRACTICES_HOME"` |
| **2. Review output** | Verify generated role/priorities/commands are correct for your project |
| **3. Validate** | `bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/validate-adoption.sh" --project-dir . --expect-standards-path "$AGENTIC_BEST_PRACTICES_HOME"` |
| **4. Commit** | Add `AGENTS.md` and `CLAUDE.md` (symlink or copy) to version control |

### Bootstrap script behavior

| Behavior | Result |
| --- | --- |
| `AGENTS.md` missing | Creates and renders from template |
| `CLAUDE.md` missing | Creates symlink by default; falls back to copy if needed |
| `--adoption-mode pinned` | Creates/uses pinned snapshot and writes relative standards paths |
| Existing files + `--existing-mode fail` (default) | Fails safely (no overwrite) |
| Existing files + `--existing-mode overwrite` | Overwrites and creates timestamped backups |
| Existing files + `--existing-mode merge` | Merges managed Standards Reference block into existing file |

---

## Existing Projects

For projects that already have an `AGENTS.md`:

| Situation | Action |
| --- | --- |
| **No existing AGENTS.md** | Use bootstrap command directly |
| **Has AGENTS.md and you want to preserve local content** | Run bootstrap with `--existing-mode merge` |
| **Has AGENTS.md and you want to replace with template** | Run bootstrap with `--existing-mode overwrite` (or `--force`) |
| **Has AGENTS.md with local standards** | Merge and keep local standards in Project-Specific/Overrides sections |

### Safe merge workflow

```bash
# 1) Preview your current file
git show -- AGENTS.md

# 2) Merge managed Standards Reference block (keeps other sections)
bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/adopt-into-project.sh" \
  --project-dir . \
  --standards-path "$AGENTIC_BEST_PRACTICES_HOME" \
  --existing-mode merge \
  --claude-mode skip

# 3) Validate and then review diff
bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/validate-adoption.sh" \
  --project-dir . \
  --expect-standards-path "$AGENTIC_BEST_PRACTICES_HOME" \
  --strict
git diff -- AGENTS.md
```

### Safe overwrite workflow

```bash
# Replace AGENTS.md with rendered template and back up old file
bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/adopt-into-project.sh" \
  --project-dir . \
  --standards-path "$AGENTIC_BEST_PRACTICES_HOME" \
  --existing-mode overwrite
```

---

## Migration Workflows

### Latest → Pinned

```bash
# 1) Choose a ref to pin (tag recommended)
PIN_REF="v1.0.0"

# 2) Merge in-place to preserve existing AGENTS content while switching path mode
bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/adopt-into-project.sh" \
  --project-dir . \
  --standards-path "$AGENTIC_BEST_PRACTICES_HOME" \
  --adoption-mode pinned \
  --pinned-ref "$PIN_REF" \
  --existing-mode merge

# 3) Validate strict
bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/validate-adoption.sh" --project-dir . --strict
```

### Pinned → Latest

```bash
# Switch AGENTS references back to shared standards path
bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/adopt-into-project.sh" \
  --project-dir . \
  --standards-path "$AGENTIC_BEST_PRACTICES_HOME" \
  --adoption-mode latest \
  --existing-mode merge

# Validate expected path explicitly
bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/validate-adoption.sh" \
  --project-dir . \
  --expect-standards-path "$AGENTIC_BEST_PRACTICES_HOME" \
  --strict
```

### Updating an Existing Pin

```bash
# Re-run pinned mode with a new ref; AGENTS path updates to the new snapshot
bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/adopt-into-project.sh" \
  --project-dir . \
  --standards-path "$AGENTIC_BEST_PRACTICES_HOME" \
  --adoption-mode pinned \
  --pinned-ref v1.1.0 \
  --existing-mode merge
```

---

## Pilot Enablement

Use this workflow when validating adoption in a real external repository.

| Step | Action | Output |
| --- | --- | --- |
| 1. Select pilot repo | Apply `docs/planning/pilot-repo-selection.md` | Candidate repo and owner |
| 2. Prepare repo | Run `prepare-pilot-project.sh` | Validated adoption files + pilot templates |
| 3. Track weekly outcomes | Copy weekly template each week | Measurable friction and impact data |
| 4. Close with retrospective | Fill retrospective template | Rollout/iterate decision |

### One-command pilot setup

```bash
bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/prepare-pilot-project.sh" \
  --project-dir /path/to/project \
  --standards-path "$AGENTIC_BEST_PRACTICES_HOME" \
  --existing-mode merge \
  --pilot-owner "Team Name"
```

Generated artifacts (default path: `.agentic-best-practices/pilot/`):

| File | Purpose |
| --- | --- |
| `kickoff.md` | Kickoff checklist and pilot metadata |
| `weekly-checkin-template.md` | Weekly status capture template |
| `retrospective-template.md` | End-of-pilot retrospective template |
| `README.md` | Pilot artifact usage instructions |

### Pinned-mode pilot setup

```bash
bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/prepare-pilot-project.sh" \
  --project-dir /path/to/project \
  --standards-path "$AGENTIC_BEST_PRACTICES_HOME" \
  --adoption-mode pinned \
  --pinned-ref v1.0.0 \
  --existing-mode merge \
  --pilot-owner "Team Name"
```

---

## The Reference Directive

The core mechanism is a directive in your project's `AGENTS.md` telling AI to consult the standards repo before implementation.

```markdown
## Standards Reference

This project follows organizational standards defined in `{{STANDARDS_PATH}}/`.

**Before implementing**, consult the relevant guide:

| Topic | Guide |
| --- | --- |
| Error handling | `{{STANDARDS_PATH}}/guides/error-handling/error-handling.md` |
| Logging | `{{STANDARDS_PATH}}/guides/logging-practices/logging-practices.md` |
| API design | `{{STANDARDS_PATH}}/guides/api-design/api-design.md` |
| Documentation | `{{STANDARDS_PATH}}/guides/documentation-guidelines/documentation-guidelines.md` |
| Code style | `{{STANDARDS_PATH}}/guides/coding-guidelines/coding-guidelines.md` |

For other topics, check `{{STANDARDS_PATH}}/README.md` for the full guide index.

**Deviation policy**: Do not deviate from these standards without explicit approval. If deviation is necessary, document it in the Project-Specific Overrides section with rationale.
```

### Why this works

| Mechanism | Effect |
| --- | --- |
| **Explicit file paths** | AI can read guides directly |
| **Before implementing** | AI checks standards before writing code |
| **Deviation policy** | AI asks before going off-script |
| **Guide table** | Quick lookup for common topics |
| **README fallback** | Covers topics not in the quick table |

---

## Project Template

Use `adoption/template-agents.md` as the source template.

| Mode | Recommended command |
| --- | --- |
| **Automated** | `bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/adopt-into-project.sh" --project-dir . --standards-path "$AGENTIC_BEST_PRACTICES_HOME"` |
| **Automated (Pinned)** | `bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/adopt-into-project.sh" --project-dir . --adoption-mode pinned --pinned-ref v1.0.0` |
| **Manual fallback** | Copy template, replace `{{STANDARDS_PATH}}`, remove setup placeholders, and validate |

| Template section | What to customize |
| --- | --- |
| **Project-Specific** | Role, stack, commands, boundaries |
| **Standards Reference** | Usually unchanged after bootstrap; ensure path is correct |
| **Project-Specific Overrides** | Intentional, justified deviations only |

---

## Drift Prevention

Standards lose value if projects drift over time. These controls reduce drift.

### 1. Deviation requires justification

| Rule | Effect |
| --- | --- |
| Every intentional override must be documented in `Project-Specific Overrides` | Deviations are visible and auditable |

### 2. Periodic consistency check

| Trigger | Action |
| --- | --- |
| New major feature | Pull latest standards and re-check key patterns |
| Quarterly | Review standards updates and project overrides |

### 3. No silent overrides

| Rule | Effect |
| --- | --- |
| Do not deviate without explicit approval | Agents ask before conflicting with standards |

### 4. Auditable history

| Rule | Effect |
| --- | --- |
| Keep override rationale with approval date | Historical context remains clear |

---

## Maintenance

### Updating standards

```bash
git -C "$AGENTIC_BEST_PRACTICES_HOME" pull
```

### Updating pinned projects

```bash
# Pinned projects do not auto-follow git pull. Re-pin explicitly.
bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/adopt-into-project.sh" \
  --project-dir . \
  --standards-path "$AGENTIC_BEST_PRACTICES_HOME" \
  --adoption-mode pinned \
  --pinned-ref v1.0.1 \
  --existing-mode merge
```

### Release notes and tags

| Task | Command |
| --- | --- |
| View recent commits | `git -C "$AGENTIC_BEST_PRACTICES_HOME" log --oneline -20` |
| Fetch tags (optional) | `git -C "$AGENTIC_BEST_PRACTICES_HOME" fetch --tags` |
| List recent tags | `git -C "$AGENTIC_BEST_PRACTICES_HOME" tag --sort=-creatordate \| head -20` |

### Adding project-specific patterns

| If the pattern is... | Then... |
| --- | --- |
| **Useful to other projects** | Add to agentic-best-practices, not project `AGENTS.md` |
| **Truly project-specific** | Add to project `AGENTS.md` Project-Specific section |
| **A deviation from standards** | Document in Overrides section with rationale |

---

## Troubleshooting

| Issue | Cause | Fix |
| --- | --- | --- |
| Bootstrap fails due to existing files | Safe overwrite protection | Re-run with `--force` after review |
| Merge inserted duplicate standards section | Existing manual Standards Reference present | Re-run merge; tool replaces existing standards section with managed block |
| AI doesn't follow standards | Missing or broken reference directive | Re-run bootstrap or fix `Standards Reference` section |
| AI can't find guides | Wrong standards path | Validate with `--expect-standards-path` |
| Different behavior across tools | `CLAUDE.md` missing or out of sync | Regenerate with bootstrap or copy/symlink `AGENTS.md` |
| Strict validation fails on structure | Missing recommended sections or TODO commands | Add missing sections (`Agent Role`, `Tech Stack`, `Key Commands`, `Boundaries`) and replace TODO commands |
| Pinned mode fails to create snapshot | Ref does not exist or standards path is not a git repo | Verify `--pinned-ref` and run `git -C "$AGENTIC_BEST_PRACTICES_HOME" fetch --tags` |
| Pilot prep script skips files | Pilot artifact files already exist | Re-run with `--overwrite` to refresh generated pilot files |
| Standards seem outdated | Haven't pulled recently | Run `git -C "$AGENTIC_BEST_PRACTICES_HOME" pull` |

### Verifying setup

```bash
# Check standards repo exists
ls "$AGENTIC_BEST_PRACTICES_HOME/README.md"

# Check project files
ls ./AGENTS.md
ls -la ./CLAUDE.md

# Validate rendered adoption files
bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/validate-adoption.sh" --project-dir .
```

---

## See Also

- [AGENTS.md Guidelines](../guides/agents-md/agents-md-guidelines.md) – Writing effective instruction files
- [Tool Configuration](../guides/tool-configuration/tool-configuration.md) – Configuring AI tools
- [Template](template-agents.md) – Ready-to-use project template
