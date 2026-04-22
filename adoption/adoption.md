# Adopting Best Practices

A guide for integrating this repository into your projects so AI coding assistants work from a consistent set of recommended defaults.

> **Scope**: Works with any AI coding tool (Claude, Codex, Gemini, Cursor) across any number of projects.

## Contents

| Section |
| --- |
| [Decision-First Onboarding](#decision-first-onboarding) |
| [Quick Start](#quick-start) |
| [One-Time Setup](#one-time-setup) |
| [Adoption Modes](#adoption-modes) |
| [Per-Project Adoption](#per-project-adoption) |
| [Skills Installation](#skills-installation) |
| [Config-Driven Customization](#config-driven-customization) |
| [Existing Projects](#existing-projects) |
| [Migration Workflows](#migration-workflows) |
| [Pilot Enablement](#pilot-enablement) |
| [The Reference Directive](#the-reference-directive) |
| [Project Template](#project-template) |
| [Drift Prevention](#drift-prevention) |
| [Maintenance](#maintenance) |
| [Troubleshooting](#troubleshooting) |

---

## Decision-First Onboarding

Use onboarding to encode deliberate project choices, not to silently import the entire standards catalog.

These standards are prima facie good defaults. The repository recommends them as a starting point, but each project should decide objectively whether to adopt them as-is, adopt a modified version, or decline specific pieces because a better project-specific approach exists.

| Decision | Choose | Recommendation | Why |
| --- | --- | --- | --- |
| **Standards path mode** | `latest` or `pinned` | Start with `latest`; use `pinned` for regulated or high-risk repos | Controls update speed and reproducibility |
| **Existing file strategy** | `fail`, `merge`, or `overwrite` | Use `merge` for any repo that already has local agent instructions | Preserves local context while adding the managed standards block |
| **Standards shortlist** | `STANDARDS_TOPICS` entries | Start with `3-6` recurring concerns, not the full guide index | Keeps the default reference table relevant and reviewable |
| **Skills** | Install or skip | Start with `skip` unless the repo clearly benefits from local auto-discovered procedures | Avoids copying workflow baggage the repo will not use |
| **Command defaults** | Auto-detected or overridden | Only override when stack detection is wrong or incomplete | Prevents stale or misleading commands |
| **Intentional deviations** | Follow standard or record override | Put exceptions in `Project-Specific Overrides` | Makes non-standard behavior explicit and auditable |

### Recommended first pass for a real repo

| Step | Action |
| --- | --- |
| **1. Copy config** | Create `.agentic-best-practices/adoption.env` from the template |
| **2. Edit topics** | Replace the sample `STANDARDS_TOPICS` list with the repo's recurring concerns |
| **3. Choose mode** | Decide `latest` vs `pinned` before rendering |
| **4. Bootstrap safely** | Use `--existing-mode merge` for established repos |
| **5. Review intent** | Check the generated diff and capture any justified exceptions in `Project-Specific Overrides` |

### How to evaluate a default objectively

| Question | If yes | If no |
| --- | --- | --- |
| Does this default address a recurring problem in the repo? | Keep it in `STANDARDS_TOPICS` | Leave it out of the shortlist |
| Would following it reduce risk, inconsistency, or rework here? | Adopt it as-is | Consider a narrower or modified version |
| Does the repo already have a better established pattern? | Document the project-specific pattern in `Project-Specific Overrides` | Prefer the shared default |
| Would adopting it add ceremony with little benefit? | Keep it optional or omit it | Keep it as a recommended default |

```bash
mkdir -p .agentic-best-practices
cp "$AGENTIC_BEST_PRACTICES_HOME/adoption/template-adoption-config.env" .agentic-best-practices/adoption.env

# Edit .agentic-best-practices/adoption.env before rendering.
# Most importantly: choose a small, project-specific STANDARDS_TOPICS list.

bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/adopt-into-project.sh" \
  --project-dir . \
  --standards-path "$AGENTIC_BEST_PRACTICES_HOME" \
  --config-file .agentic-best-practices/adoption.env \
  --existing-mode merge
```

---

## Quick Start

Use this after you have made the decisions above. If you have not chosen topics, mode, and merge strategy yet, start with [Decision-First Onboarding](#decision-first-onboarding).

| Situation | Start with |
| --- | --- |
| **Existing repo or anything important** | Config file + `--existing-mode merge` |
| **Brand-new repo or quick experiment** | Plain bootstrap defaults |

```bash
# One-time: clone to standard location
git clone https://github.com/[org]/agentic-best-practices.git ~/agentic-best-practices

# Set standards path (customize if needed)
export AGENTIC_BEST_PRACTICES_HOME="${AGENTIC_BEST_PRACTICES_HOME:-$HOME/agentic-best-practices}"

# Recommended for real repos: copy config and make deliberate choices first
mkdir -p .agentic-best-practices
cp "$AGENTIC_BEST_PRACTICES_HOME/adoption/template-adoption-config.env" .agentic-best-practices/adoption.env

# After editing STANDARDS_TOPICS and other values, render with config
bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/adopt-into-project.sh" \
  --project-dir . \
  --standards-path "$AGENTIC_BEST_PRACTICES_HOME" \
  --config-file .agentic-best-practices/adoption.env

# Existing repo with AGENTS.md: merge standards section in-place
bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/adopt-into-project.sh" \
  --project-dir . \
  --standards-path "$AGENTIC_BEST_PRACTICES_HOME" \
  --config-file .agentic-best-practices/adoption.env \
  --existing-mode merge

# Fastest baseline for a brand-new repo or quick experiment
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
| **Method** | Direct clone (not submodule) | Shared local install; updates are easy to review and reuse |
| **Updates** | `git pull` periodically | Keep standards current |

```bash
git clone https://github.com/[org]/agentic-best-practices.git ~/agentic-best-practices
export AGENTIC_BEST_PRACTICES_HOME="${AGENTIC_BEST_PRACTICES_HOME:-$HOME/agentic-best-practices}"
```

**Why not submodules?** Submodules version-lock each project to a specific commit. For teams using latest-mode adoption, a normal clone usually makes it easier to review and reuse shared guidance across multiple repos.

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
| **1. Choose decisions** | Pick mode, merge strategy, shortlist topics, skill install, and any command overrides |
| **2. Run bootstrap** | Render `AGENTS.md` and `CLAUDE.md` with the selected options |
| **3. Review output** | Verify generated role, priorities, topics, commands, and boundaries are correct for your project |
| **4. Validate** | `bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/validate-adoption.sh" --project-dir . --expect-standards-path "$AGENTIC_BEST_PRACTICES_HOME"` |
| **5. Commit** | Add `AGENTS.md` and `CLAUDE.md` (symlink or copy) to version control |

### Bootstrap script behavior

| Behavior | Result |
| --- | --- |
| `AGENTS.md` missing | Creates and renders from template |
| `CLAUDE.md` missing | Creates symlink by default; falls back to copy if needed |
| Project stack detected (`package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `pom.xml`) | Pre-fills language/runtime/testing metadata and default command set for that stack |
| `--adoption-mode pinned` | Creates/uses pinned snapshot and writes relative standards paths |
| Existing files + `--existing-mode fail` (default) | Fails safely (no overwrite) |
| Existing files + `--existing-mode overwrite` | Overwrites and creates timestamped backups |
| Existing files + `--existing-mode merge` | Merges managed Standards Reference block into existing file |

---

## Skills Installation

Optionally install procedural workflow skills alongside AGENTS.md. Skills are concise, step-by-step instructions that agents can auto-discover. Each skill wraps one or more deep guides.

### What Skills Are

| Concept | Purpose |
| --- | --- |
| **Guides** (in `guides/`) | Explain *why* — principles, rationale, anti-patterns |
| **Skills** (in `skills/`) | Tell agents *what to do* — imperative, procedural steps |

Skills reference guides for deeper understanding. Agents use both.

### Installing Skills

```bash
# Install skills alongside AGENTS.md
bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/adopt-into-project.sh" \
  --project-dir . \
  --standards-path "$AGENTIC_BEST_PRACTICES_HOME" \
  --install-skills \
  --skills-agent claude
```

### Target Directory by Agent

| `--skills-agent` | Target Directory |
| --- | --- |
| `claude` (default) | `.claude/skills/` |
| `gemini` | `.gemini/skills/` |
| `generic` | `skills/` |

### Available Skills

See `skills/README.md` for the full list of available skills.

---

## Config-Driven Customization

Use a project-local config file when you want reproducible customization without long command flags.

### Recommended setup

```bash
mkdir -p .agentic-best-practices
cp "$AGENTIC_BEST_PRACTICES_HOME/adoption/template-adoption-config.env" .agentic-best-practices/adoption.env
```

### Run bootstrap with config

```bash
bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/adopt-into-project.sh" \
  --project-dir . \
  --standards-path "$AGENTIC_BEST_PRACTICES_HOME" \
  --config-file .agentic-best-practices/adoption.env
```

### Supported config keys

| Key | Purpose |
| --- | --- |
| `PROJECT_NAME` | Override rendered project name in AGENTS |
| `AGENT_ROLE` | Set the default agent role text |
| `PROJECT_DESCRIPTION` | Set short project description in Agent Role section |
| `PRIORITY_ONE`, `PRIORITY_TWO`, `PRIORITY_THREE` | Set ordered decision priorities |
| `STANDARDS_TOPICS` | Customize Standards Reference rows (`Topic\|path;Topic\|path`) |
| `DECISION_POLICY` | Override default decision-policy sentence |
| `DEV_CMD`, `TEST_CMD`, `COVERAGE_CMD`, `LINT_CMD`, `TYPECHECK_CMD`, `BUILD_CMD` | Override generated command entries |

### Notes

| Rule | Behavior |
| --- | --- |
| CLI wins over config | If both are set, explicit CLI arguments take precedence |
| Config path reuse | `--config-file` also applies to merge mode and pilot prep workflow |
| Guide path formats | `STANDARDS_TOPICS` supports absolute paths, repo-relative paths, or `{{STANDARDS_PATH}}` token |
| Legacy policy key | Older configs using `DEVIATION_POLICY` still work, but `DECISION_POLICY` is the preferred key |
| Shortlists should stay small | Start with `3-6` topics and expand only when the repo repeatedly needs more |
| Command override defaults | Optional command override keys are commented out in template config; enable only when needed |

### Choosing `STANDARDS_TOPICS` intentionally

| Pattern | Use when | Example topics |
| --- | --- | --- |
| **Minimal** | Small repo with narrow scope | Error handling, Testing strategy, Logging |
| **Balanced** | Typical service or application | Error handling, Logging, API design, Testing strategy, Security boundaries |
| **Specialized** | Repo has one or two dominant technical concerns | Add Event-Driven Architecture, Database Migrations & Drift, Incident Response, or Multi-Agent Orchestration only when they are recurring concerns |

The Standards Reference table is a curated shortlist of recommended defaults for recurring work in that repo. It is not an attempt to mirror every guide in this repository, and it does not imply that every project should adopt the same shortlist.

---

## Existing Projects

For projects that already have an `AGENTS.md`:

| Situation | Action |
| --- | --- |
| **No existing AGENTS.md** | Use bootstrap command directly |
| **Has AGENTS.md and you want to preserve local content** | Run bootstrap with `--existing-mode merge` |
| **Has AGENTS.md and you want to replace with template** | Run bootstrap with `--existing-mode overwrite` (or `--force`) |
| **Has AGENTS.md with local standards** | Merge and keep local standards in Project-Specific/Overrides sections |

For most external repos and pilots, `merge` should be the default starting point because it keeps onboarding additive and reviewable.

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
| 3. Run readiness check | Run `check-pilot-readiness.sh` | Early warning for missing artifacts/cadence |
| 4. Track weekly outcomes | Copy weekly template each week | Measurable friction and impact data |
| 5. Generate findings summary | Run `summarize-pilot-findings.sh` | Consolidated pilot evidence and backlog checklist |
| 6. Close with retrospective | Fill retrospective template | Rollout/iterate decision |

### One-command pilot setup

```bash
bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/prepare-pilot-project.sh" \
  --project-dir /path/to/project \
  --standards-path "$AGENTIC_BEST_PRACTICES_HOME" \
  --config-file /path/to/project/.agentic-best-practices/adoption.env \
  --existing-mode merge \
  --pilot-owner "Team Name"
```

### Pilot readiness check

```bash
bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/check-pilot-readiness.sh" \
  --project-dir /path/to/project \
  --min-weekly-checkins 0 \
  --strict
```

### Pilot findings summary

```bash
bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/summarize-pilot-findings.sh" \
  --project-dir /path/to/project \
  --pilot-dir ".agentic-best-practices/pilot" \
  --require-retrospective
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

This project uses shared guidance from `{{STANDARDS_PATH}}/` as its working defaults.

**Before implementing**, consult the relevant guide:

| Topic | Guide |
| --- | --- |
| Error handling | `{{STANDARDS_PATH}}/guides/error-handling/error-handling.md` |
| Logging | `{{STANDARDS_PATH}}/guides/logging-practices/logging-practices.md` |
| API design | `{{STANDARDS_PATH}}/guides/api-design/api-design.md` |
| Documentation | `{{STANDARDS_PATH}}/guides/documentation-guidelines/documentation-guidelines.md` |
| Code style | `{{STANDARDS_PATH}}/guides/coding-guidelines/coding-guidelines.md` |

For other topics, check `{{STANDARDS_PATH}}/README.md` for the full guide index.

**Decision policy**: Treat these as recommended defaults. If this project chooses a different approach, document the rationale in Project-Specific Overrides so the decision stays explicit and reviewable.
```

### Why this works

| Mechanism | Effect |
| --- | --- |
| **Explicit file paths** | AI can read guides directly |
| **Before implementing** | AI checks standards before writing code |
| **Decision policy** | Alternative project-specific choices stay explicit instead of being silently invented |
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
| **Standards Reference** | Keep the topic table intentionally scoped to recommended defaults that fit the repo |
| **Project-Specific Overrides** | Record intentional changes, omissions, or better local patterns with rationale |

---

## Drift Prevention

Standards lose value if projects drift over time. These controls reduce drift.

### 1. Differences should be explicit

| Rule | Effect |
| --- | --- |
| Every intentional change from the recommended defaults should be documented in `Project-Specific Overrides` | Project-specific choices are visible and auditable |

### 2. Periodic consistency check

| Trigger | Action |
| --- | --- |
| New major feature | Pull latest standards and re-check key patterns |
| Quarterly | Review standards updates and project overrides |

### 3. No silent drift

| Rule | Effect |
| --- | --- |
| Do not silently replace a recommended default with an undocumented local pattern | Projects make conscious decisions instead of accidental drift |

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
| Pilot readiness check reports missing artifacts | Pilot files or cadence docs not created yet | Run `prepare-pilot-project.sh`, then add weekly/retrospective files and re-run readiness check |
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
