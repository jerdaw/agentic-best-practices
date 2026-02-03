# Roadmap Process (v0.1.0)

How we maintain the project roadmap with minimal drift and minimal human time.

| Field | Value |
| --- | --- |
| **Version** | `0.1.0` |
| **Last updated** | 2026-02-03 |
| **Roadmap location** | `README.md` → “Roadmap” section |
| **Quality gate** | `npm run validate` verifies guide index completeness |

## Contents

| Section |
| --- |
| [Goals](#goals) |
| [What Belongs in the Roadmap](#what-belongs-in-the-roadmap) |
| [Statuses and Lifecycle](#statuses-and-lifecycle) |
| [Update Cadence](#update-cadence) |
| [Archiving Completed Work](#archiving-completed-work) |

---

## Goals

| Goal | Why |
| --- | --- |
| Keep the roadmap truthful | A wrong roadmap wastes time and erodes trust |
| Minimize noise | Completed items should not crowd active work |
| Keep detail out of the roadmap | Roadmap links to plans/issues; it stays scannable |
| Make updates cheap | Prefer tables and simple status transitions |

---

## What Belongs in the Roadmap

| Item type | Include? | Where details go |
| --- | --- | --- |
| Adoption milestones | Yes | Issues / `docs/implementation-plan.md` |
| New guides | Yes | Issue + target file path |
| Tooling/validation improvements | Yes | PR(s) + `docs/release-process.md` notes |
| One-off cleanup chores | No | Commit/PR description |
| “Nice ideas” without scope | No | Issues backlog |

---

## Statuses and Lifecycle

Use the smallest set of statuses that stays accurate.

| Status | Meaning | Rule |
| --- | --- | --- |
| **Planned** | Not started | Must have a clear deliverable |
| **In Progress** | Work is active | Only for current focus items |
| **Blocked** | Waiting on a decision/resource | Must state what unblocks |
| **Done** | Completed and merged | Remove from the roadmap (see archiving) |

---

## Update Cadence

| When | Update |
| --- | --- |
| After merging roadmap-relevant PRs | Update `README.md` Roadmap immediately |
| At start of a new adoption pilot | Add/adjust pilot-related items |
| Monthly (or quarterly) | Prune stale items; validate priorities |

---

## Archiving Completed Work

Completed items should not remain in the roadmap table.

| Action | Why | How |
| --- | --- | --- |
| Remove Done items from Roadmap | Keeps focus on active work | Edit `README.md` table |
| Preserve traceability | “Where did this go?” remains answerable | Link PRs/releases in Git history and `docs/release-process.md` |
