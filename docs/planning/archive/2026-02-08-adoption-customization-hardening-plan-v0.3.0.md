# Adoption Customization Hardening Plan (v0.3.0)

Implementation plan for improving downstream project customization and AI-agent effectiveness during adoption.

| Field | Value |
| --- | --- |
| **Status** | Archived (Phase 4 complete) |
| **Created** | 2026-02-08 |
| **Archived** | 2026-02-08 |
| **Owner** | Maintainer |
| **Scope** | Config-driven customization, stack-aware defaults, human-led pilot execution enablement, and pilot evidence handoff automation |

## Contents

| Section |
| --- |
| [Objectives](#objectives) |
| [Phase 1 Checklist](#phase-1-checklist) |
| [Phase 2 Checklist](#phase-2-checklist) |
| [Phase 3 Checklist](#phase-3-checklist) |
| [Phase 4 Checklist](#phase-4-checklist) |
| [Verification](#verification) |
| [Follow-Up](#follow-up) |

---

## Objectives

| Objective | Success Signal |
| --- | --- |
| Reduce manual setup for non-default projects | A single config file can drive adoption output without many CLI flags |
| Improve downstream AI effectiveness | Rendered AGENTS includes project-relevant standards references and clear policy text |
| Keep adoption workflows safe and repeatable | Merge, bootstrap, and pilot prep all support the same config path |
| Preserve release quality | Simulation and validation cover the new customization path |

---

## Phase 1 Checklist

| Item | Status |
| --- | --- |
| Add plan + track implementation progress in repo docs | ✅ Complete |
| Add adoption config template for downstream projects | ✅ Complete |
| Add `--config-file` support to `scripts/adopt-into-project.sh` | ✅ Complete |
| Add `--config-file` support to `scripts/merge-standards-reference.sh` | ✅ Complete |
| Add `--config-file` forwarding in `scripts/prepare-pilot-project.sh` | ✅ Complete |
| Make standards references configurable in `adoption/template-agents.md` | ✅ Complete |
| Update docs (`README.md`, `adoption/adoption.md`, `docs/README.md`) | ✅ Complete |
| Extend smoke simulation to validate config-driven adoption | ✅ Complete |
| Run verification and record outcomes | ✅ Complete |
| Update `roadmap.md` with completed work | ✅ Complete |

---

## Phase 2 Checklist

| Item | Status |
| --- | --- |
| Add stack detection for Node/Python/Go/Rust/JVM projects in bootstrap rendering | ✅ Complete |
| Generate stack-aware default commands for non-Node projects | ✅ Complete |
| Populate stack-aware language/runtime/testing metadata in rendered template | ✅ Complete |
| Populate critical file paths using detected stack/project structure | ✅ Complete |
| Prevent accidental TODO command overrides in config template defaults | ✅ Complete |
| Extend smoke simulation with non-Node stack scenario | ✅ Complete |
| Update adoption docs to reflect stack-aware defaults | ✅ Complete |
| Re-run verification suite and record outcomes | ✅ Complete |
| Update `roadmap.md` with Phase 2 completion | ✅ Complete |

---

## Phase 3 Checklist

| Item | Status |
| --- | --- |
| Add explicit human-led execution track and walkthrough steps to `roadmap.md` | ✅ Complete |
| Add pilot readiness checker script for setup/cadence/retrospective gates | ✅ Complete |
| Integrate readiness checker into smoke simulation coverage | ✅ Complete |
| Update pilot documentation to include readiness check workflow | ✅ Complete |
| Add package script help entry for pilot readiness checker | ✅ Complete |
| Re-run verification suite and record outcomes | ✅ Complete |
| Update `roadmap.md` with Phase 3 evidence | ✅ Complete |

---

## Phase 4 Checklist

| Item | Status |
| --- | --- |
| Add pilot findings summary script (`scripts/summarize-pilot-findings.sh`) | ✅ Complete |
| Add package script help entry for pilot summary command | ✅ Complete |
| Extend smoke simulation with pilot findings summary scenario | ✅ Complete |
| Update pilot workflow docs to include findings summary step | ✅ Complete |
| Update adoption guide to include findings summary command | ✅ Complete |
| Add/expand human-led roadmap items for findings-summary handoff | ✅ Complete |
| Re-run verification suite and record outcomes | ✅ Complete |
| Update `roadmap.md` with Phase 4 evidence | ✅ Complete |

---

## Verification

| Check | Command | Target | Result |
| --- | --- | --- | --- |
| Script syntax | `bash -n scripts/*.sh` | Pass | ✅ Pass |
| Navigation/link validation | `npm run validate` | Pass | ✅ Pass |
| Adoption smoke simulation (includes config + Rust stack + readiness + findings-summary scenarios) | `bash scripts/simulate-adoption-check.sh` | Pass | ✅ Pass |
| Markdown lint | `npm run lint:md` | Pass | ✅ Pass |

---

## Follow-Up

| Item | Owner | Status | Notes |
| --- | --- | --- | --- |
| Execute external pilot in 1-2 selected repos | Human maintainer | 🔴 Pending | Still required for external validation evidence |
| Feed pilot feedback into next hardening cycle | Human maintainer + contributors | 🔴 Pending | Use feedback template and pilot artifacts |
