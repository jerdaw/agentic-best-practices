# Pilot Selection Readiness Plan

| Field | Value |
| --- | --- |
| Status | Complete; pilot recommendation ready for owner commitment |
| Prepared | 2026-07-10 |
| Decision owner | Human maintainer |
| Scope | Score local candidates and rehearse setup in disposable clones |

## Goal

Reduce the blocked pilot-selection milestone to an evidence-backed one-line owner decision without modifying a candidate repository or assuming team willingness.

## Guardrails

| Rule | Requirement |
| --- | --- |
| Candidate safety | Inspect tracked source and Git history read-only |
| Rehearsal isolation | Run adoption only in fresh disposable local clones |
| Human commitment | Keep willingness below the qualifying threshold until explicitly confirmed |
| Ownership | Recommend an owner, but do not record commitment without approval |
| External actions | Do not push, create issues, contact people, schedule meetings, or start a real pilot |
| Candidate changes | Do not modify any candidate worktree, branch, instruction file, or roadmap |

## Candidate Shortlist

| Candidate | Code LOC | Commits (60 days) | Test files | CI workflows | Existing AGENTS.md | Initial fit |
| --- | ---: | ---: | ---: | ---: | --- | --- |
| `old-reddit-enhanced` | 9,775 | 26 | 30 | 3 | Yes | Strong technical fit |
| `mcat-remnote-workflow` | 2,725 | 3 | 8 | 0 | Yes | Strong safety/process contrast; lower activity |
| `voicecard` | 103,966 | 105 | 86 | 2 | Yes | Highly active but too large/risky for first pilot |
| `career-advisor` | 1,759 | 0 | 7 | 0 | Yes | Isolated but currently inactive |

Metrics are point-in-time local evidence from tracked code and the current checked-out history. They are selection inputs, not proof of organizational readiness.

## Batches

### 1. Score candidates

1. Apply the repository's weighted 1-5 rubric.
2. Mark team willingness and feedback capacity as unconfirmed rather than inferred.
3. Recommend one primary and one fallback candidate.

### 2. Rehearse the primary candidate

1. Clone the candidate locally with no remote credentials or working-tree changes.
2. Run `prepare-pilot-project.sh` in merge mode with a proposed human owner.
3. Run strict adoption and initial pilot-readiness validation.
4. Record generated-file inventory, validation output, and any conflict or cleanup need.
5. Delete the disposable clone only after recording non-sensitive evidence.

### 3. Prepare the owner decision

1. Record the recommendation, accepted tradeoffs, support plan, cadence, and rollback.
2. Provide one-line approval text that confirms willingness, owner, and timeline.
3. Keep the roadmap blocked until that exact commitment is received.

## Validation

| Check | Required evidence |
| --- | --- |
| Candidate integrity | All candidate main worktrees remain clean and unchanged |
| Rehearsal | Pilot preparation and strict readiness commands pass in disposable clone |
| Repository quality | `npm run precommit` passes |
| Documentation | Navigation and internal links pass |
| Git | `git diff --check` passes |

## Human Gate

The real pilot starts only after the maintainer confirms:

- selected repository;
- named willing owner;
- weekly feedback capacity for 6-8 weeks;
- support owner;
- acceptable failure/isolation posture;
- kickoff date.

## Completion Evidence

| Requirement | Evidence |
| --- | --- |
| Candidate scoring | Four candidates measured and scored in `2026-07-10-pilot-selection-decision.md` |
| Primary recommendation | `old-reddit-enhanced`; one pilot only |
| Configuration | `pilot-old-reddit-adoption.env` with five recurring topics and repo-native commands |
| Disposable setup | Merge-mode preparation passed in a remote-free clone |
| Strict readiness | 0 errors, 0 warnings, 0 weekly check-ins required at setup |
| Candidate integrity | Real `old-reddit-enhanced` worktree remained clean |
| Tooling regression | Merge-aware section aliases covered by adoption smoke scenario 8 |
| External effects | No candidate writes, pushes, issues, messages, schedules, or releases |

The decision remains human-owned because explicit willingness and feedback capacity are critical rubric criteria and cannot be inferred from repository state.
