# Adoption Integration Hardening Plan (v0.2.0)

Implementation plan for improving downstream project adoption and AI-agent effectiveness.

| Field | Value |
| --- | --- |
| **Status** | Archived (Phase 4 Complete) |
| **Created** | 2026-02-08 |
| **Archived** | 2026-02-08 |
| **Owner** | Maintainer |
| **Scope** | Phase 1-4 completed (bootstrap, merge, pinned mode, migration docs, and pilot enablement assets) |

## Contents

| Section |
| --- |
| [Objectives](#objectives) |
| [Phase Overview](#phase-overview) |
| [Phase 1 Checklist](#phase-1-checklist) |
| [Phase 2 Checklist](#phase-2-checklist) |
| [Phase 3 Checklist](#phase-3-checklist) |
| [Phase 4 Checklist](#phase-4-checklist) |
| [Verification](#verification) |
| [Human-Dependent Follow-Up](#human-dependent-follow-up) |

---

## Objectives

| Objective | Success Signal |
| --- | --- |
| Reduce setup friction for new projects | Scripted bootstrap replaces manual copy/symlink steps |
| Make adoption quality measurable | Validation script detects unresolved placeholders and bad references |
| Validate onboarding continuously | CI runs downstream adoption smoke test |
| Improve portability | Standards path configurable instead of hardcoded-only usage |
| Enable external pilot execution | Pilot artifacts and runbook are generated consistently |

---

## Phase Overview

| Phase | Scope | Status |
| --- | --- | --- |
| **Phase 1** | Bootstrap script, validation script, smoke simulation, docs updates | Complete |
| **Phase 2** | Existing AGENTS.md merge tooling + stricter downstream checks | Complete |
| **Phase 3** | Optional pinned-version adoption mode + migration docs | Complete |
| **Phase 4** | Pilot prep automation, pilot templates, and execution playbook | Complete |

---

## Phase 1 Checklist

| Item | Status |
| --- | --- |
| Add `scripts/adopt-into-project.sh` | ✅ Done |
| Add `scripts/validate-adoption.sh` | ✅ Done |
| Add `scripts/simulate-adoption-check.sh` | ✅ Done |
| Wire package scripts for adoption checks | ✅ Done |
| Add CI job for adoption smoke simulation | ✅ Done |
| Update adoption documentation (`README.md`, `adoption/adoption.md`, `adoption/template-agents.md`) | ✅ Done |
| Update docs index and roadmap tracking | ✅ Done |
| Run validation + smoke tests and record results | ✅ Done |

---

## Phase 2 Checklist

| Item | Status |
| --- | --- |
| Add `scripts/merge-standards-reference.sh` | ✅ Done |
| Add merge mode support to `scripts/adopt-into-project.sh` | ✅ Done |
| Strengthen `scripts/validate-adoption.sh` structural checks | ✅ Done |
| Extend `scripts/simulate-adoption-check.sh` with merge scenario coverage | ✅ Done |
| Update docs for merge workflow (`README.md`, `adoption/adoption.md`) | ✅ Done |
| Run full verification and record Phase 2 results | ✅ Done |

---

## Phase 3 Checklist

| Item | Status |
| --- | --- |
| Add pinned snapshot tooling (`scripts/pin-standards-version.sh`) | ✅ Done |
| Add pinned adoption mode support to `scripts/adopt-into-project.sh` | ✅ Done |
| Update merge and validation scripts for relative/pinned standards paths | ✅ Done |
| Extend smoke simulation with pinned-mode scenario coverage | ✅ Done |
| Add migration documentation for latest ↔ pinned workflows | ✅ Done |
| Run full verification and record Phase 3 results | ✅ Done |

---

## Phase 4 Checklist

| Item | Status |
| --- | --- |
| Add `scripts/prepare-pilot-project.sh` for one-command pilot preparation | ✅ Done |
| Add pilot templates (`kickoff`, `weekly-checkin`, `retrospective`) in `docs/templates/` | ✅ Done |
| Add external pilot execution playbook in `docs/process/pilot-execution-playbook.md` | ✅ Done |
| Extend smoke simulation with pilot-prep scenario coverage | ✅ Done |
| Update adoption docs (`README.md`, `adoption/adoption.md`, `docs/README.md`) for pilot workflow | ✅ Done |
| Update tracking docs (`roadmap.md`, health dashboard) and record verification | ✅ Done |

---

## Verification

| Check | Command | Target |
| --- | --- | --- |
| Markdown lint | `npm run lint:md` | Pass |
| Repo navigation validation | `npm run validate` | Pass |
| Adoption smoke simulation | `bash scripts/simulate-adoption-check.sh` | Pass |
| Script syntax check | `bash -n scripts/*.sh` | Pass |

### Results

| Check | Result |
| --- | --- |
| `bash -n scripts/*.sh` | ✅ Pass |
| `bash scripts/prepare-pilot-project.sh --help` | ✅ Pass |
| `bash scripts/simulate-adoption-check.sh` | ✅ Pass |
| `npm run precommit` | ✅ Pass |

---

## Human-Dependent Follow-Up

| Item | Owner | Status | Notes |
| --- | --- | --- | --- |
| Select 1-2 pilot repos using `docs/planning/pilot-repo-selection.md` | Human maintainer | 🔴 Pending | Requires org priorities + team consent |
| Run pilot in selected repos for 6-8 weeks | Human maintainer + pilot owners | 🔴 Pending | Use `scripts/prepare-pilot-project.sh` + generated pilot artifacts |
| Feed pilot findings into guide/script updates | Human maintainer + contributors | 🔴 Pending | File issues using `docs/templates/feedback-template.md` |
