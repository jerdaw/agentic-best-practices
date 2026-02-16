# API Contract Governance

Best practices for treating API contracts as versioned products with linting, compatibility gates, and consumer-safe evolution.

> **Scope**: Contract source-of-truth ownership, OpenAPI linting, breaking-change enforcement, and contract test placement.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Contract Source of Truth](#contract-source-of-truth) |
| [Contract Linting](#contract-linting) |
| [Breaking Change Gates](#breaking-change-gates) |
| [Consumer Compatibility](#consumer-compatibility) |
| [Good/Bad Contract Governance](#goodbad-contract-governance) |
| [Anti-Patterns](#anti-patterns) |
| [Red Flags](#red-flags) |

---

## Quick Reference

| Category | Guidance | Rationale |
| --- | --- | --- |
| **Source of truth** | Keep one canonical contract file per API surface | Prevents spec drift |
| **Linting** | Enforce naming, schema, and security conventions in CI | Maintains consistency |
| **Compatibility** | Run automated breaking-change checks on pull requests | Protects consumers |
| **Testing** | Back contract with runtime verification tests | Ensures implementation matches spec |
| **Versioning** | Tie breaking changes to SemVer and migration notes | Makes impact explicit |

---

## Core Principles

| Principle | Guideline | Rationale |
| --- | --- | --- |
| **Contract-first visibility** | PRs show contract diffs clearly | Reviewers can assess compatibility |
| **Automated policy** | Lint and break checks are mandatory | Manual review is not enough |
| **Consumer safety** | Assume unknown external clients exist | Avoids accidental breakage |
| **Spec-runtime parity** | Tests validate implemented behavior against contract | Prevents stale or aspirational specs |

---

## Contract Source of Truth

| Contract artifact | Requirement |
| --- | --- |
| OpenAPI/AsyncAPI file | Stored in repo under `docs/api/` or equivalent |
| Example payloads | Versioned beside contract |
| Generation inputs | Deterministic and reproducible in CI |
| Ownership | CODEOWNERS mapped to API team |

| Rule | Good | Bad |
| --- | --- | --- |
| Spec location | Single canonical `openapi.yaml` | Multiple inconsistent specs |
| Spec updates | Updated in same PR as endpoint change | "Will update docs later" |
| Ownership | Explicit reviewers for API paths | No designated contract owners |

---

## Contract Linting

| Lint category | Typical checks | Why |
| --- | --- | --- |
| Naming | Consistent operation/schema naming | Improves discoverability |
| Semantics | Status code and response shape conventions | Predictable client behavior |
| Security | Auth schemes and sensitive field policies | Reduces accidental exposure |
| Quality | Description/examples present for public endpoints | Better integrator experience |

```yaml
# Good: contract lint in CI
- run: spectral lint docs/api/openapi.yaml
```

```yaml
# Bad: deploy without contract quality gate
- run: npm run deploy
```

---

## Breaking Change Gates

| Breaking change example | Gate response |
| --- | --- |
| Remove endpoint/field | Fail CI unless version strategy + migration approved |
| Change field type/enum semantics | Fail CI as compatibility break |
| Tighten required parameters | Fail CI unless major change path documented |

| Gate implementation | Pattern |
| --- | --- |
| Baseline comparison | Compare PR spec with main branch spec |
| Exception path | Explicit approval label + migration section |
| Output | Human-readable report in CI artifact/comment |

```bash
# Example contract gate command
node scripts/openapi-breaking-check.mjs
```

---

## Consumer Compatibility

| Compatibility strategy | Use when | Notes |
| --- | --- | --- |
| Additive changes only | Ongoing minor releases | Safest default |
| Parallel version endpoint | Major migration windows | Supports phased client upgrades |
| Deprecation headers/docs | Planned retirement | Give time-bounded migration runway |
| Consumer contract tests | Known critical consumers | Catches hidden assumptions |

| Compatibility checklist | Required |
| --- | --- |
| New optional fields only in minor versions | Yes |
| Breaking changes include migration guide | Yes |
| SDK/client regen and tests run | Yes |
| Changelog marks contract-impacting entries | Yes |

---

## Good/Bad Contract Governance

| Area | Good | Bad |
| --- | --- | --- |
| Contract ownership | Named API owners + review gates | Contract changes merged without API review |
| CI policy | Lint + break checks required | Optional checks or manual-only reviews |
| Spec-runtime parity | Contract tests in CI | Spec and runtime diverge silently |
| Change communication | Explicit migration notes | Breaking change hidden in generic release notes |

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| --- | --- | --- |
| Spec generated from stale code and never reviewed | Public contract becomes unreliable | Review spec diff as first-class artifact |
| Contract checks run only before release | Breaks merged too late | Run checks on every PR |
| Disabling break checks for "internal" APIs | Internal consumers still break | Keep same baseline governance |
| No examples in complex schemas | Integrators misinterpret payloads | Add realistic request/response examples |

---

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| Endpoint behavior changed but contract file unchanged | Block merge and reconcile | Implementation-contract drift is a reliability issue |
| Breaking-change tool reports removal in patch/minor release | Require major-version process | Version policy must reflect compatibility impact |
| Consumers report breakage with passing tests | Add consumer contract tests and strengthen compatibility gates | Current test scope is insufficient |

---

## See Also

- [API Design](../api-design/api-design.md)
- [Testing Strategy](../testing-strategy/testing-strategy.md)
- [CI/CD Pipelines](../cicd-pipelines/cicd-pipelines.md)
- [Release Engineering & Versioning](../release-engineering-versioning/release-engineering-versioning.md)
- [Repository Governance](../repository-governance/repository-governance.md)
