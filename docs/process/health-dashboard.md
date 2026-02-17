# Repository Health Dashboard

Real-time metrics tracking the health and readiness of agentic-best-practices.

> **Last Updated**: 2026-02-17
> **Status**: Pre-v1 (Self-audit refreshed)

## Contents

| Section |
| --- |
| [Content Metrics](#content-metrics) |
| [Quality Metrics](#quality-metrics) |
| [Self-Dogfooding](#self-dogfooding) |
| [Community Health](#community-health) |
| [v1 Readiness](#v1-readiness) |

---

## Content Metrics

| Metric | Target | Current | Status |
| --- | --- | --- | --- |
| Total Guides | All published guides tracked | 49 | ✅ Complete |
| Guides with Code Examples | 100% | 49/49 (100%) | ✅ Complete |
| Examples per Guide | 2+ | 49/49 (100%) | ✅ Complete |
| Cross-references | All guides linked | Yes | ✅ Complete |
| Navigation accuracy | 100% | 100% | ✅ Complete |

**Notes**:

- All published guides are indexed and link-validated
- All guides now meet the 2+ example target
- Navigation validation automated via `scripts/validate-navigation.sh`

---

## Quality Metrics

| Metric | Target | Current | Status |
| --- | --- | --- | --- |
| Broken internal links | 0 | 0 | ✅ Zero |
| Non-portable `file://` markdown links | 0 | 0 | ✅ Zero |
| Broken external links | < 5% | Monitored in CI | 🟡 Ongoing |
| Lint violations | 0 | 0 | ✅ Zero |
| Navigation drift | 0 | 0 | ✅ Zero |
| CLAUDE.md compliance | 100% | 100% | ✅ Complete |
| Adoption smoke simulation (new/merge/overwrite/pinned/pilot-prep/readiness/summary) | Pass | Pass | ✅ Complete |

**Notes**:

- Internal structure and guide indexes validated on every commit via pre-commit hook
- `validate-navigation.sh` now fails on non-portable `file://` markdown links
- External link checking added via CI workflow
- Markdown linting enforced automatically
- Downstream adoption simulation validates new project setup, merge workflow, overwrite workflow, pinned workflow, pilot-prep workflow, readiness checks, findings summary generation, and references

---

## Self-Dogfooding

| Metric | Target | Current | Status |
| --- | --- | --- | --- |
| CLAUDE.md exists | Yes | Yes | ✅ Complete |
| Follows writing-best-practices | Yes | Yes | ✅ Complete |
| Uses tables > bullets | Yes | Yes (table-first structure across guides) | ✅ Complete |
| Automated validation | Yes | Yes | ✅ Complete |

**Notes**:

- Repository demonstrates the practices it recommends; remediation items from the 2026-02-17 self-audit are complete
- CLAUDE.md actively used during development
- Guide index, contents tables, and file structure follow documented patterns

---

## Community Health

| Metric | Target | Current | Status |
| --- | --- | --- | --- |
| Issue templates | 4 types | 4 types | ✅ Complete |
| Feedback mechanism | Yes | Yes | ✅ Complete |
| Contributing guide | Yes | In CLAUDE.md | ✅ Complete |
| Code of Conduct | Yes | `CODE_OF_CONDUCT.md` present | ✅ Complete |
| License | Yes | `LICENSE` present (MIT) | ✅ Complete |

**Notes**:

- GitHub issue templates created (guide request, bug report, feedback)
- Discussion forum configured
- Community baseline files are present and versioned

---

## v1 Readiness

| Requirement | Status | Notes |
| --- | --- | --- |
| **Content Complete** | ✅ | All 49 guides exist and meet the 2+ example target |
| **Self-Dogfooding** | ✅ | CLAUDE.md, automated validation in place |
| **Infrastructure** | ✅ | CI validation, linting, link checks, and adoption smoke simulation enabled |
| **External Validation** | 🔴 | Pilot tooling complete; still needs human-selected pilot projects |
| **Maintenance Process** | ✅ | Dashboard, archive, validation scripts created |

**Overall Status**: **97% Ready**

**Blockers for v1**:

1. External validation requires pilot project selection (human decision)

**Non-Blockers** (can iterate post-v1):

- Maintenance cadence (recommended quarterly as per planning docs)
- External link monitoring (CI workflow created, will run on schedule)
- Community adoption metrics (tracked after launch)

---

## Updating This Dashboard

This dashboard should be updated when:

- New guides are added or removed
- Quality metrics change (e.g., broken links found/fixed)
- v1 requirements status changes
- Quarterly maintenance reviews occur

Run these commands to verify current state:

```bash
npm run validate         # Check navigation and links
npm run lint:md          # Check markdown quality
scripts/check-guide-freshness.sh  # Check guide age
```
