# Repository Governance

Best practices for repository-level controls that keep code quality, ownership, and security standards enforceable at scale.

> **Scope**: CODEOWNERS, branch protection, policy-as-code, and PR/issue workflow governance.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Ownership Model](#ownership-model) |
| [Branch Protection as Code](#branch-protection-as-code) |
| [PR and Issue Governance](#pr-and-issue-governance) |
| [Automation and Compliance Checks](#automation-and-compliance-checks) |
| [Good/Bad Governance Patterns](#goodbad-governance-patterns) |
| [Anti-Patterns](#anti-patterns) |
| [Red Flags](#red-flags) |

---

## Quick Reference

| Category | Guidance | Rationale |
| --- | --- | --- |
| **Ownership** | Define path-based owners for critical directories | Ensures accountable review |
| **Main branch** | Require status checks and review approvals | Prevents unreviewed risky changes |
| **Policy** | Store protection rules in version-controlled config | Makes governance auditable |
| **Triage** | Use labels/templates for issue intake | Keeps backlog actionable |
| **Automation** | Verify governance rules continuously in CI | Detects policy drift early |

---

## Core Principles

| Principle | Guideline | Rationale |
| --- | --- | --- |
| **Governance is code** | Keep branch/repo policies declarative in git | Policy should be reviewed like product code |
| **Least privilege** | Minimize who can bypass protections | Reduces accidental or malicious risk |
| **Transparent ownership** | Contributors can discover code owners quickly | Speeds review routing and escalation |
| **Fail closed** | If checks fail or are missing, block merge | Safety over convenience on protected branches |

---

## Ownership Model

| Asset | Ownership requirement | Example |
| --- | --- | --- |
| Critical code paths | At least one accountable team | `apps/api/ @platform-team` |
| Security-sensitive paths | Security reviewer required | `security/ @security-team` |
| Build/release configs | Platform or release team ownership | `.github/workflows/ @release-team` |

```text
# Good CODEOWNERS excerpt
/apps/api/            @platform-team
/packages/domain-*/   @domain-owners
/.github/workflows/   @release-team
```

```text
# Bad CODEOWNERS excerpt
* @everyone
```

| Ownership rule | Enforcement |
| --- | --- |
| Every top-level area has owner | CI script validates uncovered paths |
| Owners are active maintainers | Quarterly owner audit |
| Escalation path defined | Team alias or documented fallback owner |

---

## Branch Protection as Code

| Protection | Minimum baseline |
| --- | --- |
| Pull request required | Enabled for default branch |
| Required checks | Lint, test, and security checks |
| Required reviews | At least 1-2 human approvals |
| Force push/delete | Disabled on protected branches |
| Up-to-date branch | Require merge-base freshness for critical repos |

```json
{
  "required_pull_request_reviews": {
    "required_approving_review_count": 2
  },
  "required_status_checks": {
    "strict": true,
    "contexts": ["ci", "security"]
  },
  "allow_force_pushes": false
}
```

| Governance workflow | Pattern |
| --- | --- |
| Policy definition | Keep in `.github/*.json` or equivalent config |
| Policy apply | Scripted apply step with auth |
| Policy verify | Scheduled CI job checks drift |

---

## PR and Issue Governance

| Workflow element | Best practice | Rationale |
| --- | --- | --- |
| PR templates | Require problem, change, risk, validation | Improves review quality |
| Issue templates | Structured bug/feature intake | Reduces triage ambiguity |
| Labels | Standard taxonomy (`type`, `priority`, `area`) | Enables reporting and automation |
| Merge policy | Squash/rebase rules documented | Consistent history and traceability |

| Required PR checks | Why |
| --- | --- |
| Linked issue/ADR for non-trivial changes | Keeps decision history discoverable |
| Validation evidence | Prevents untested merges |
| Docs impact statement | Avoids code/doc drift |

---

## Automation and Compliance Checks

| Check | Frequency | Action on failure |
| --- | --- | --- |
| Branch protection drift | Daily or per-merge | Open blocking issue / fail workflow |
| CODEOWNERS coverage | Per PR | Fail check until uncovered paths resolved |
| Required workflow presence | Per PR | Block removal of critical checks |
| Dependency/security policy | Daily | Alert + prioritized remediation |

```yaml
# Good: governance verification as CI
name: governance
on:
  pull_request:
  schedule:
    - cron: '0 4 * * *'
jobs:
  verify:
    steps:
      - run: node scripts/verify-branch-protection.mjs
      - run: node scripts/verify-codeowners-coverage.mjs
```

---

## Good/Bad Governance Patterns

| Area | Good | Bad |
| --- | --- | --- |
| Ownership | Precise path ownership | Global fallback owner only |
| Merge controls | Required checks + approvals | Admin bypass by default |
| Policy management | Versioned JSON + verification scripts | Manual UI-only toggles |
| Backlog hygiene | Templated issues + triage labels | Free-form issues with no categorization |

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| --- | --- | --- |
| "Temporary" branch protection bypass | Permanent control erosion | Time-boxed exception with issue tracking |
| No owner for critical files | Stalled or low-quality reviews | Add explicit CODEOWNERS mapping |
| Governance defined only in web UI | Unreviewed policy drift | Move to policy-as-code and CI verification |
| Security checks optional on main | Risky merges during pressure | Make checks mandatory |

---

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| Default branch allows direct pushes | Enable PR-only workflow immediately | Direct pushes bypass all controls |
| Protected branch checks differ from documented policy | Run policy re-apply and drift audit | Documentation-policy mismatch breaks trust |
| Critical directories have no CODEOWNERS | Add owner mapping before further feature work | Unowned code accumulates risk quickly |

---

## See Also

- [Git Workflows with AI](../git-workflows-ai/git-workflows-ai.md)
- [Secure Coding](../secure-coding/secure-coding.md)
- [Supply Chain Security](../supply-chain-security/supply-chain-security.md)
- [Release Engineering & Versioning](../release-engineering-versioning/release-engineering-versioning.md)
- [Monorepo Workspaces](../monorepo-workspaces/monorepo-workspaces.md)
