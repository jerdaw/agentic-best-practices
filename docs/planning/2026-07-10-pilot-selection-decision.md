# Pilot Selection Decision

| Field | Value |
| --- | --- |
| Status | Ready for human commitment |
| Recommended pilot | `old-reddit-enhanced` |
| Proposed owner | Jeremy Dawson — not committed until approved |
| Recommended pilot count | One |
| Recommended duration | 6 weeks, with weekly asynchronous check-ins |
| External actions performed | None |

## Recommendation

Select `old-reddit-enhanced` as the first and only pilot. It is the strongest bounded technical fit: near the rubric's preferred size ceiling, recently active, extensively tested, cross-browser, CI-enabled, and isolated from production infrastructure or private user data.

Do not start a second pilot until week 3. A second repository would increase feedback overhead before the first pilot proves that the cadence and evidence are sustainable.

## Evidence Snapshot

| Candidate | Code LOC | Commits (60 days) | Test files | CI workflows | Provisional score | Score after owner + feedback commitment | Decision |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| `old-reddit-enhanced` | 9,775 | 26 | 30 | 3 | 69.0 / 95 | 79.0 / 95 | Recommend |
| `voicecard` | 103,966 | 105 | 86 | 2 | 58.5 / 95 | 68.5 / 95 | Pass for first pilot: excessive size and manual blast radius |
| `mcat-remnote-workflow` | 2,725 | 3 | 8 | 0 | 54.0 / 95 | 64.0 / 95 | Fallback after official RemNote toolchain recovery |
| `career-advisor` | 1,759 | 0 | 7 | 0 | 47.0 / 95 | 57.0 / 95 | Pass: insufficient recent activity |

The provisional score intentionally assigns `2/5` to team willingness and feedback capacity for every candidate. Under the selection rules, that disqualifies all candidates until a human explicitly commits. The conditional score changes only those two fields to `4/5`; it does not inflate technical evidence.

## Primary Candidate Scorecard

| Criterion | Score | Weight | Weighted | Evidence |
| --- | ---: | ---: | ---: | --- |
| Codebase size | 5 | 2x | 10.0 | 9,775 tracked code LOC |
| Active development | 4 | 2x | 8.0 | 26 commits in 60 days |
| Tech-stack diversity | 4 | 1x | 4.0 | Manifest V3, Chrome/Firefox, JavaScript, CSS, Make packaging |
| Existing AGENTS.md | 5 | 0.5x | 2.5 | Mature project-specific instructions |
| CI/CD maturity | 5 | 1x | 5.0 | Three workflows and extensive local gates |
| Team willingness | 2 | 3x | 6.0 | Not yet explicitly confirmed |
| Feedback capacity | 2 | 2x | 4.0 | Six weekly check-ins not yet accepted |
| Stakeholder visibility | 3 | 1x | 3.0 | Public project, limited operational dependency |
| Representative use case | 4 | 2x | 8.0 | Real maintenance, browser behavior, docs, testing, release artifacts |
| Risk tolerance | 4 | 1x | 4.0 | Pilot can stay documentation/process-only |
| Timeline alignment | 4 | 2x | 8.0 | Active browser smoke and maintenance work exists |
| Support availability | 4 | 1x | 4.0 | Maintainer owns both standards and candidate repos |
| Isolation | 5 | 0.5x | 2.5 | No deployment or live-data dependency required |
| Total |  |  | 69.0 / 95 | Provisional; human commitment gate fails |

## Disposable Rehearsal

| Check | Result |
| --- | --- |
| Source | Fresh local single-branch clone; remote removed before adoption |
| Existing instructions | Merge mode preserved project-specific `AGENTS.md` content |
| Standards change | Managed Standards Reference added; 21-line tracked diff |
| Topic scope | Five recurring topics from `pilot-old-reddit-adoption.env` |
| Pilot artifacts | Kickoff, weekly template, retrospective template, README |
| Strict adoption validation | Passed, 0 errors and 0 warnings |
| Initial readiness | Passed with 0 weekly files required, 0 errors and 0 warnings |
| Real candidate worktree | Remained clean at `master...origin/master` |
| Remote writes, issues, messages, or schedules | None |

The first rehearsal exposed a false-positive structure warning because the mature candidate uses `Quick Reference`, `Project Overview`, and `Critical Rules` instead of generic template headings.

The validator, pilot preparation, readiness checker, documentation, and smoke simulation now support explicit merge-aware section aliases while retaining the original strict behavior for generated/overwritten instructions.

The adoption script creates a timestamped `AGENTS.md.bak.*` file. In a real pilot, review that backup locally and remove it before committing the managed change; do not commit the backup.

## Proposed Pilot Contract

| Item | Proposal |
| --- | --- |
| Owner | Jeremy Dawson |
| Support owner | Jeremy Dawson |
| Duration | 6 weeks |
| Weekly effort | 15 minutes asynchronous |
| Bi-weekly review | 30 minutes, only if a blocker or actionable gap exists |
| Scope | Normal maintenance work; no new product feature required for the pilot |
| Adoption mode | Latest, merge into existing `AGENTS.md` |
| Failure posture | Remove the managed block and pilot artifacts; preserve original instructions |
| Release/deployment | Out of scope |
| Browser CI | Existing policy remains authoritative; no new local Playwright requirement |

## Approval

One-line approval:

> Approve `old-reddit-enhanced` as the single 6-week agentic-best-practices pilot, with Jeremy Dawson as pilot and support owner and up to 15 minutes of weekly asynchronous feedback. Authorize local pilot-branch preparation only; do not push, deploy, release, publish, or use browser accounts.

After approval:

1. create an isolated candidate worktree;
2. apply `pilot-old-reddit-adoption.env` in merge mode;
3. review and remove the local backup file;
4. complete kickoff fields and record the actual start date;
5. run strict adoption/readiness validation;
6. commit the setup as one reviewable local batch;
7. keep push/PR creation deferred until GitHub billing is restored or separately authorized.
