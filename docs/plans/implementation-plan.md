# Implementation Plan (v0.1.4)

Highly detailed, agent-first execution plan for evolving `agentic-best-practices` with minimal human time.

| Field | Value |
| --- | --- |
| **Version** | `0.1.4` |
| **Last updated** | 2026-02-03 |
| **Primary constraint** | Human time is scarce; prefer agent-executable work |
| **Quality gates** | `npm run precommit` (Markdown lint + navigation validation) |
| **Source of truth** | `README.md` + `AGENTS.md` + `guides/` + `adoption/` |

## Contents

| Section |
| --- |
| [Summary of Current State](#summary-of-current-state) |
| [Project Goals and Non-Goals](#project-goals-and-non-goals) |
| [Key Constraints](#key-constraints) |
| [Unknowns and Assumptions](#unknowns-and-assumptions) |
| [Work Selection: Next Batch](#work-selection-next-batch) |
| [Validation and Evidence](#validation-and-evidence) |
| [Phased Plan](#phased-plan) |
| [Timeline and Milestones](#timeline-and-milestones) |
| [Rollout and Rollback](#rollout-and-rollback) |
| [Risks and Mitigations](#risks-and-mitigations) |
| [Decision Points (Yes/No)](#decision-points-yesno) |

---

## Summary of Current State

| Area | Current state |
| --- | --- |
| **Purpose** | Repo provides opinionated, scannable best-practice guides for humans and AI agents; adoption is via copying `adoption/template-agents.md` into other repos. |
| **Structure** | Guides live under `guides/<topic>/<topic>.md` (one level deep). Adoption materials in `adoption/`. References for humans in `docs/reference/references.md`. |
| **Tooling** | Node-based Markdown linting (`markdownlint-cli2`) and a repo-specific navigation validator (`scripts/validate-navigation.sh`). |
| **CI** | GitHub Actions runs markdown lint and navigation validation (`.github/workflows/lint.yml`). |
| **Local quality gates** | `npm run precommit` runs `lint:md` then `validate`. Husky pre-commit invokes the same gates. |
| **Notable work-in-progress** | Maintenance mode: keep gates green, keep roadmap accurate, and iterate based on adoption feedback. |

---

## Project Goals and Non-Goals

### Goals

| Goal | What “success” looks like |
| --- | --- |
| **Agent-consumable standards** | Guides remain scannable, current, and consistent; agents can reliably follow them without guessing. |
| **Easy adoption** | A project can adopt standards in <10 minutes using the template. |
| **Low maintenance cost** | Navigation/link drift and lint issues are caught automatically before merge. |
| **Safe evolution** | Changes ship in small, reviewable increments with straightforward rollback. |

### Non-Goals (for this plan)

| Non-goal | Rationale |
| --- | --- |
| Build a complex website/docs portal | Adds operational overhead; not required for adoption. |
| Turn this into an executable “skills” system | Repo explicitly focuses on standards, not capabilities (see `README.md`). |
| Perfect semantic correctness across all domains | Prefer incremental improvements validated by adoption feedback. |

---

## Key Constraints

| Constraint | Implication for the plan |
| --- | --- |
| **Minimal human time** | Work must be agent-driven; humans only do quick Yes/No approvals or choose between 2 options. |
| **Docs-first repo** | Validation and drift detection are the primary “tests”; changes must keep gates green. |
| **No major restructuring without asking** | Prefer additive changes within existing folders; avoid taxonomy churn. |

---

## Unknowns and Assumptions

| Topic | Assumption (used unless contradicted) | Why it matters |
| --- | --- | --- |
| “v1” definition | A “v1” is: stable adoption workflow + green quality gates + a small set of adoption pilots | Determines milestone completion |
| Where adoption feedback lives | Feedback captured as GitHub Issues in this repo | Drives iteration loop |
| Acceptable dependency policy | Dev-deps can be upgraded when security advisories appear, provided gates stay green | Affects audit response |
| Release process | Tag-and-note releases are sufficient (no packaging) | Affects rollout mechanics |

Blocking unknowns (require human time) are intentionally kept out of the critical path.

---

## Work Selection: Next Batch

The next batch is selected to (a) reduce review risk and (b) make incremental shipping easy.

| Priority | Work item | Why now | Human input |
| --- | --- | --- | --- |
| P0 | Maintain repo hygiene and docs navigation | Keeps the repo trustworthy and easy to contribute to | None (agent-only) |
| P0 | Keep CI + local gates aligned | Prevents drift between local and CI validation | None (agent-only) |
| P1 | Add lightweight release hygiene (tag + changelog discipline) | Makes it easy to pull updates into downstream repos | Yes/No on release format |
| P1 | Add adoption feedback loop scaffolding | Converts “standards” into “standards that work in practice” | Choose pilot repos (separate human-led item) |

Phase 1 execution artifacts (produced by the agent):

| Artifact | Purpose |
| --- | --- |
| `docs/archive/phase-1-pr-split.md` | Proposed PR sequence and exact staging commands |
| `docs/archive/phase-1-ship-revert-summary.md` | Fast “ship vs hold” checklist for all modified files |

Phase 2 execution artifacts (produced by the agent):

| Artifact | Purpose |
| --- | --- |
| `docs/process/release-process.md` | Tagging + release notes + rollback guidance for low-maintenance shipping |

Phase 3 execution artifacts (produced by the agent):

| Artifact | Purpose |
| --- | --- |
| `docs/templates/feedback-template.md` | Structured prompts for reporting guide gaps/conflicts |
| `docs/rubrics/triage-rubric.md` | Minimal-human rubric for classifying and resolving feedback |

Phase 4 execution artifacts (produced by the agent):

| Artifact | Purpose |
| --- | --- |
| `.github/workflows/lint.yml` | Adds scheduled and manual runs for quality gates |
| `scripts/validate-navigation.sh` | Extends drift detection to include `README.md` |

---

## Validation and Evidence

### Quality Gates (must pass every phase)

| Gate | Command | Evidence to record |
| --- | --- | --- |
| Markdown lint | `npm run lint:md` | Command output in PR description |
| Navigation validation | `npm run validate` | Command output in PR description |
| Combined | `npm run precommit` | Single green run before merge |

### Reviewability Targets (docs repo “tests”)

| Target | Threshold | Validation method |
| --- | --- | --- |
| PR size | Prefer <500 lines changed | `git diff --stat` |
| Guide integrity | No broken internal links | `npm run validate` |
| Style consistency | No new lint violations | `npm run lint:md` |

---

## Phased Plan

### Phase 0 — Baseline and Guardrails (completed / keep stable)

| Goal | Deliverable | Validation | Rollback |
| --- | --- | --- | --- |
| Stable local + CI checks | `npm run precommit` is the universal gate | `npm run precommit` green | Revert the gating change commit |
| Script robustness | Validator counts errors correctly and handles anchors sanely | `npm run validate` green | Revert validator changes |

### Phase 1 — Make Current Changes Reviewable (next execution focus)

| Work item | Deliverable | Dependency | Validation | Human decision |
| --- | --- | --- | --- | --- |
| Split into patch sets | Two (or three) patch sets: `tooling+deps` vs `docs-content` (optional `docs-formatting`) | Clean working tree categorization | Each patch set individually passes `npm run precommit` | Yes/No on split |
| Ship/revert summary | A single checklist table mapping file → “formatting only” vs “meaning change” | Patch sets exist | Reviewer can approve in minutes | Yes/No per bucket |
| Merge order | PR order: tooling first, then docs | None | Each PR green | Yes/No on order |

### Phase 2 — Release and Update Mechanics

| Work item | Deliverable | Validation | Human decision |
| --- | --- | --- | --- |
| Release convention | `docs/process/release-process.md` specifying tagging, release notes, and rollback | Lint + validate | Yes/No on proposed convention |
| Downstream update guidance | “Updating Standards” snippet in `README.md` and “Release Notes and Tags” in `adoption/adoption.md` | Lint + validate | Yes/No on wording |

### Phase 3 — Adoption Feedback Loop (minimal-human variant)

| Work item | Deliverable | Validation | Human decision |
| --- | --- | --- | --- |
| Feedback capture template | `docs/templates/feedback-template.md` (structured prompts for “what confused the agent?”) | Lint + validate | Yes/No on template |
| Issue triage rubric | `docs/rubrics/triage-rubric.md` (bug vs gap vs conflict vs preference) | Lint + validate | Yes/No |

### Phase 4 — Continuous Maintenance Automation

| Work item | Deliverable | Validation | Human decision |
| --- | --- | --- | --- |
| Scheduled validation | Optional weekly CI run to detect drift early | CI green | Yes/No on enabling scheduled workflow |
| “Guide index drift” checks | Extend validator to check README index as well (not just AGENTS) | `npm run validate` green | Yes/No |

---

## Timeline and Milestones

Timeline assumes an agent does the work and a human spends only minutes per decision.

| Week | Milestone | Deliverables |
| --- | --- | --- |
| Week 1 | Reviewability milestone | Phase 1 patch sets + ship/revert summary |
| Week 2 | Release hygiene milestone | Phase 2 release/update docs |
| Week 3 | Feedback loop milestone | Phase 3 templates + rubric |
| Week 4 | Automation milestone | Phase 4 scheduled validation (optional) |

---

## Rollout and Rollback

| Change type | Rollout approach | Rollback approach |
| --- | --- | --- |
| Tooling/CI changes | Land in a standalone PR first | `git revert` the PR commit(s) |
| Guide content changes | Land in small topical PRs | Revert PR or revert specific guide changes |
| Adoption template changes | Announce in changelog + keep backwards compatibility where possible | Revert template; document revert in release notes |

---

## Risks and Mitigations

| Risk | Impact | Mitigation | Validation |
| --- | --- | --- | --- |
| Large diffs hide meaning changes | Trust loss, accidental policy changes | Phase 1 split + “ship/revert” summary | Reviewer can approve fast |
| Lint rule changes create noisy diffs | Slows contributions | Prefer disabling low-signal rules vs mass reformatting | `npm run lint:md` stays stable |
| Adoption advice diverges from real usage | Standards ignored | Phase 3 feedback loop | Pilot feedback incorporated |

---

## Decision Points (Yes/No)

These are intentionally binary to minimize your time.

| Decision | Default | When asked |
| --- | --- | --- |
| Accept the proposed PR split | Yes | After I generate a split proposal |
| Ship “formatting-only” doc changes | Yes | After I produce the ship/revert summary |
| Adopt the proposed release convention | Yes | When Phase 2 draft is ready |
| Enable weekly scheduled CI validation | No | When Phase 4 is proposed |
