# Release Process (v0.1.0)

How we ship updates to `agentic-best-practices` safely with minimal human time.

| Field | Value |
| --- | --- |
| **Version** | `0.1.0` |
| **Last updated** | 2026-02-08 |
| **Release unit** | Git tag + GitHub Release notes |
| **Quality gate** | `npm run precommit` must be green |
| **Default posture** | Small, reviewable changes; easy rollback via revert |

## Contents

| Section |
| --- |
| [Goals](#goals) |
| [Release Types](#release-types) |
| [What Counts as Breaking](#what-counts-as-breaking) |
| [Release Checklist](#release-checklist) |
| [Release Notes Template](#release-notes-template) |
| [Rollout and Rollback](#rollout-and-rollback) |

---

## Goals

| Goal | Why |
| --- | --- |
| Make updates easy to consume | Downstream repos just `git pull` |
| Support deterministic adoption | Pinned consumers can target exact tags/SHAs |
| Minimize human time | Prefer Yes/No approvals and repeatable steps |
| Preserve trust | Releases are small, validated, and documented |
| Enable fast rollback | Bad guidance is worse than no guidance |

---

## Release Types

We use SemVer-style tags: `vMAJOR.MINOR.PATCH`.

| Type | Tag bump | Typical changes | Downstream impact |
| --- | --- | --- | --- |
| Patch | `PATCH += 1` | Typos, formatting, clarifications, tooling fixes | None; safe to pull |
| Minor | `MINOR += 1` | New guides, new sections, improved patterns | Usually safe; review notes |
| Major | `MAJOR += 1` | Breaking guidance changes or adoption workflow changes | Requires downstream attention |

---

## What Counts as Breaking

Breaking means: “a downstream project following the old standard is now considered wrong (or unsafe) without intentional opt-in”.

| Change | Breaking? | Example |
| --- | --- | --- |
| Rename/move a guide path | Yes | `guides/logging-practices/...` moved elsewhere |
| Replace a recommended pattern with a different one | Sometimes | “Prefer exceptions” → “Prefer Result” |
| Tighten a rule in a way that forces refactors | Yes | “May log PII” → “Never log PII” |
| Add a new optional recommendation | No | New “Nice to have” section |
| Improve examples without changing guidance | No | More Good/Bad snippets |

---

## Release Checklist

### 1. Prepare

| Step | Command | Expected result |
| --- | --- | --- |
| Ensure clean working tree | `git status --porcelain=v1` | No output (or only expected files) |
| Verify commit author identity | `git config user.name && git config user.email` | Human maintainer identity configured |
| Update dependencies (if needed) | `npm ci` | Installs cleanly |

### 2. Validate

| Step | Command | Expected result |
| --- | --- | --- |
| Run quality gate | `npm run precommit` | All checks pass |

### 3. Tag and publish

| Step | Command | Expected result |
| --- | --- | --- |
| Pick next version | (manual) | `vMAJOR.MINOR.PATCH` selected |
| Create tag | `git tag -a vX.Y.Z -m \"vX.Y.Z\"` | Annotated tag exists |
| Push commit + tag | `git push && git push --tags` | Tag visible on remote |
| Create GitHub Release | (UI) | Release notes published |

---

## Release Notes Template

Use this for GitHub Releases.

| Section | What to include |
| --- | --- |
| **Summary** | 1–2 lines: what changed and why it matters |
| **Highlights** | 3–7 bullets max |
| **Breaking changes** | Explicit, actionable migration guidance |
| **Adoption impact** | Whether downstream repos should update immediately |
| **Pinned adoption impact** | Which tag/SHA pinned consumers should move to |
| **Validation** | Paste `npm run precommit` output (or confirm green) |

Example structure:

```markdown
## Summary
[1–2 lines]

## Highlights
- ...

## Breaking changes
- None

## Adoption impact
- Safe to pull: Yes/No

## Pinned adoption impact
- Recommended target: vX.Y.Z

## Validation
- npm run precommit: ✅
```

---

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| **Red CI / Failed checks** | **STOP**. Fix the error. | The quality gate is absolute. Bypassing it destroys trust. |
| **Breaking change in Patch** | Bump to MAJOR or revert the change | SemVer is the contract; breaking it breaks downstream updates. |
| **"Just a quick fix"** | Follow the full process | Skipping steps is how bad releases happen. |
| **No migration steps** | Write specific "how to upgrade" instructions | Users need to know *what to do*, not just *what changed*. |

---

## Rollout and Rollback

| Scenario | Rollout | Rollback |
| --- | --- | --- |
| Tooling/validation change | Ship first in its own PR | Revert PR; re-run `npm run precommit` |
| Guide content change | Ship in isolated PRs | Revert PR for that guide |
| Adoption template change | Announce clearly in release notes | Revert template + document revert |
| Pinned-mode relevant release | Publish clear target tag in notes | Revert and publish corrected guidance tag |
