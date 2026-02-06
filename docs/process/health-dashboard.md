# Repository Health Dashboard

Real-time metrics tracking the health and readiness of agentic-best-practices.

> **Last Updated**: 2026-02-06
> **Status**: Pre-v1 (Approaching readiness)

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
| Total Guides | 38 | 38 | ✅ Complete |
| Guides with Code Examples | 38 (100%) | 38 (100%) | ✅ Complete |
| Examples per Guide | 2+ | 2-4 avg | ✅ Complete |
| Cross-references | All guides linked | Yes | ✅ Complete |
| Navigation accuracy | 100% | 100% | ✅ Complete |

**Notes**:

- All planned guides for v1 exist
- All guides now have 2+ realistic code examples
- Navigation validation automated via `scripts/validate-navigation.sh`

---

## Quality Metrics

| Metric | Target | Current | Status |
| --- | --- | --- | --- |
| Broken internal links | 0 | 0 | ✅ Zero |
| Broken external links | < 5% | TBD | 🟡 Needs CI |
| Lint violations | 0 | 0 | ✅ Zero |
| Navigation drift | 0 | 0 | ✅ Zero |
| CLAUDE.md compliance | 100% | 100% | ✅ Complete |

**Notes**:

- Internal links validated on every commit via pre-commit hook
- External link checking added via CI workflow
- Markdown linting enforced automatically

---

## Self-Dogfooding

| Metric | Target | Current | Status |
| --- | --- | --- | --- |
| CLAUDE.md exists | Yes | Yes | ✅ Complete |
| Follows writing-best-practices | Yes | Yes | ✅ Complete |
| Uses tables > bullets | Yes | Yes | ✅ Complete |
| Automated validation | Yes | Yes | ✅ Complete |

**Notes**:

- Repository demonstrates all practices it recommends
- CLAUDE.md actively used during development
- Guide index, contents tables, and file structure follow documented patterns

---

## Community Health

| Metric | Target | Current | Status |
| --- | --- | --- | --- |
| Issue templates | 4 types | 4 types | ✅ Complete |
| Feedback mechanism | Yes | Yes | ✅ Complete |
| Contributing guide | Yes | In CLAUDE.md | ✅ Complete |
| Code of Conduct | Yes | TBD | 🔴 Missing |
| License | Yes | TBD | 🔴 Missing |

**Notes**:

- GitHub issue templates created (guide request, bug report, feedback)
- Discussion forum configured
- Need to add CODE_OF_CONDUCT.md and LICENSE file before v1

---

## v1 Readiness

| Requirement | Status | Notes |
| --- | --- | --- |
| **Content Complete** | ✅ | All 38 guides exist with examples |
| **Self-Dogfooding** | ✅ | CLAUDE.md, automated validation in place |
| **Infrastructure** | 🟡 | CI link checker added, missing CoC/License |
| **External Validation** | 🔴 | Needs pilot projects (not automatable) |
| **Maintenance Process** | ✅ | Dashboard, archive, validation scripts created |

**Overall Status**: **85% Ready**

**Blockers for v1**:

1. Add CODE_OF_CONDUCT.md (can copy from standard template)
2. Add LICENSE file (recommend MIT or Apache 2.0)
3. External validation requires pilot project selection (human decision)

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
