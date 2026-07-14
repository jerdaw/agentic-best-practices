# Documentation Validation Maintenance Plan

| Field | Value |
| --- | --- |
| **Status** | In progress |
| **Owner** | Jeremy Dawson |
| **Started** | 2026-07-13 |
| **Scope** | Documentation validation, maintainer runtime, and CI action maintenance |

## Goal

Restore reliable documentation validation with a current supported toolchain,
without changing guide policy or pilot-selection decisions.

## Work Plan

| Step | Deliverable | Status |
| --- | --- | --- |
| 1 | Replace the broken Google documentation citation with its maintained source | Complete |
| 2 | Upgrade `markdownlint-cli2` and document its Node 22 runtime floor | Complete |
| 3 | Exclude repository-local worktrees from Markdown lint traversal | Complete |
| 4 | Upgrade first-party workflow actions and the lint runner to supported majors | Complete |
| 5 | Run clean-install audits, the full pre-commit gate, and command-surface smoke checks | Complete |
| 6 | Verify hosted pull-request checks, merge, and archive this plan | Pending |

## Risk Controls

| Risk | Control |
| --- | --- |
| Unsupported action major | Verify tags and current releases in the official action repositories |
| Runtime mismatch | Keep `package.json`, maintainer docs, and CI on the same Node 22 minimum |
| Linked-worktree lint failures | Exclude `.worktrees` in the canonical lint commands |
| Unrelated policy changes | Keep guide content and pilot-selection documents out of scope |

## Acceptance Criteria

- [x] `npm ci` completes on Node 22 or newer.
- [x] Production-only and full dependency audits report zero vulnerabilities.
- [x] `npm run precommit` passes.
- [x] All documented command-surface help checks exit successfully.
- [x] The branch diff is clean and human-authored.
- [ ] Required hosted checks pass and the branch is merged.
- [ ] This plan is archived with an outcome summary.
