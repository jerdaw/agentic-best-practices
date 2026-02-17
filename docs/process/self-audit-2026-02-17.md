# Repository Self-Audit (2026-02-17)

Thorough audit of `agentic-best-practices` to verify the project follows its own documented standards.

> **Audit Date**: 2026-02-17
> **Scope**: Repo-wide checks (`guides/`, `adoption/`, `skills/`, `docs/`, scripts, and top-level governance docs)
> **Overall Result**: Pass (all tracked remediation items complete)

## Contents

| Section |
| --- |
| [Audit Method](#audit-method) |
| [Automated Evidence](#automated-evidence) |
| [Compliance Matrix](#compliance-matrix) |
| [Findings and Disposition](#findings-and-disposition) |
| [Open Follow-Ups](#open-follow-ups) |
| [Verification Re-Run](#verification-re-run) |

---

## Audit Method

| Method | What it validated |
| --- | --- |
| Built-in validators | Markdown linting, guide index integrity, navigation structure, adoption smoke simulation |
| Link/portability scans | Non-portable links and markdown link resolution behavior outside code fences |
| Style heuristics | Contents-table presence, table-first structure signals, prose density, Good/Bad contrast signal |
| Manual spot checks | Confirmed true defects vs intentional examples in docs |

---

## Automated Evidence

| Check | Command | Result |
| --- | --- | --- |
| Markdown lint | `npm run lint:md` | Pass (0 errors) |
| Navigation validation | `bash scripts/validate-navigation.sh` | Pass |
| Adoption smoke simulation | `npm run validate:adoption:sim` | Pass |
| Guide freshness | `bash scripts/check-guide-freshness.sh` | Pass (49 guides; 0 stale >180 days) |
| Script syntax | `bash -n scripts/*.sh` | Pass |
| Markdown portability scan | `rg -n "\(file:///" docs guides README.md AGENTS.md` | Pass after remediation |

---

## Compliance Matrix

| Requirement Source | Requirement | Result | Evidence |
| --- | --- | --- | --- |
| `AGENTS.md` Operational Rules | Fix broken links always | Pass after remediation | Removed non-portable `file://` links in archived planning doc; added validator guard |
| `AGENTS.md` Operational Rules | Avoid AI attribution metadata | Pass | No `Co-authored-by` trailers in recent commit history scan; no AI-authorship phrases detected |
| `AGENTS.md` Maintenance Rules | Guide index and README discoverability | Pass | `validate-navigation.sh` guide/index checks pass |
| `AGENTS.md` Maintenance Rules | Contents tables maintained | Pass | All 49 guides include a `## Contents` section |
| `writing-best-practices` | Tables over prose (scannability) | Pass (heuristic) | 49/49 guides have table-first structure; 48/49 have more table lines than prose lines |
| `writing-best-practices` | Avoid prose walls | Pass (heuristic) | Longest prose run is 6 lines; 48/49 guides have max prose run <=5 |
| `writing-best-practices` | Examples per guide (2+) | Pass | 49/49 guides now include at least two fenced example blocks |
| `writing-best-practices` | Good/Bad contrast examples | Pass | All 49 guides now include explicit Good/Bad contrast examples |
| `AGENTS.md` Style/Structure | Guides in predictable locations | Pass | All guide files remain under `guides/<topic>/<topic>.md` |

---

## Findings and Disposition

| Severity | Finding | Disposition |
| --- | --- | --- |
| High | `guides/testing-ai-code/testing-ai-code.md` had malformed fenced blocks (odd fence count) | Fixed |
| High | `docs/planning/archive/2026-02-14-agent-concepts-v1.0.0.md` used non-portable `file://` links | Fixed |
| Medium | Validator gap: non-portable `file://` links were not previously enforced | Fixed (`scripts/validate-navigation.sh` now checks) |
| Medium | `docs/process/health-dashboard.md` contained stale guide-count metrics (38 vs 49) | Fixed |
| Medium | Two guides had only one fenced example block (`cicd-pipelines`, `coding-guidelines`) vs 2+ example target | Fixed |
| Low | 12 guides did not have explicit `good` + `bad` lexical pattern | Fixed |

---

## Open Follow-Ups

No open follow-ups. SA-01, SA-02, and SA-03 are complete.

---

## Verification Re-Run

| Command | Post-fix status |
| --- | --- |
| `npm run lint:md` | Pass |
| `bash scripts/validate-navigation.sh` | Pass |
| `npm run validate:adoption:sim` | Pass |
| `bash scripts/check-guide-freshness.sh` | Pass |
| `rg -n "\(file:///" docs guides README.md AGENTS.md` | No matches |
