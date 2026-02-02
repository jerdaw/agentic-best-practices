# Dependency Management for AI Agents

Best practices for AI agents on managing dependencies—when to add them, how to evaluate them, and how to keep them secure and current.

> **Scope**: These guidelines are for AI agents performing coding tasks. Dependencies introduce risk and maintenance burden; these patterns help make good decisions about when and what to add.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [When to Add a Dependency](#when-to-add-a-dependency) |
| [Evaluating Dependencies](#evaluating-dependencies) |
| [Security Considerations](#security-considerations) |
| [Version Management](#version-management) |
| [Updating Dependencies](#updating-dependencies) |
| [Dependency Organization](#dependency-organization) |
| [Reducing Dependency Count](#reducing-dependency-count) |
| [Documentation](#documentation) |
| [Common Dependency Decisions](#common-dependency-decisions) |
| [Anti-Patterns](#anti-patterns) |
| [Dependency Checklist](#dependency-checklist) |

---

## Quick Reference

### Pre-Check

| Question | Rationale |
| --- | --- |
| **Is it actually needed?** | YAGNI; code you don't write is code you don't maintain. |
| **Is it actively maintained?** | Unmaintained code is a security liability. |
| **Is it from a trusted source?** | Supply chain attacks often vector through obscure packages. |
| **Are there vulnerabilities?** | Known CVEs are non-starters for production code. |
| **Is the license compatible?** | Legal blockers can force expensive rewrites later. |

### Preference Matrix

| Instead of... | Prefer... | Rationale |
| --- | --- | --- |
| **External Packages** | **Standard Library** | Native implementations are faster, safer, and dependency-free. |
| **New Packages** | **Established Ones** | Battle-tested code has fewer known unknowns. |
| **Large Frameworks** | **Focused Packages** | Import cost should match utility; tree-shaking isn't magic. |
| **Many Dependencies** | **Fewer Dependencies** | Reduces attack surface and version conflict risk. |

### Avoid

| Practice | Rationale |
| --- | --- |
| **Trivial Functionality** | `left-pad` incidents prove that micro-packages introduce fragility. |
| **Unmaintained Packages** | "Works today" doesn't mean "works tomorrow" with security patches. |
| **Incompatible Licenses** | Viral licenses (GPL) can infect proprietary codebases. |

---

## Core Principles

| Principle | Rationale |
| --- | --- |
| **Minimize Dependencies** | Every dependency is a liability (security, size, maintenance). |
| **Evaluate Thoroughly** | It's easier to verify before adding than to remove after integration. |
| **Stay Current** | Lagging behind invites security rot and breaking change pile-ups. |
| **Audit Security** | Automated tools catch CVEs that manual review misses. |
| **Lock Versions** | Reproducible builds are impossible with floating versions. |

---

## When to Add a Dependency

### Decision Framework

```text
Do I need external code for this?
├─ Can standard library do it?
│   └─ Yes → Use standard library
│   └─ No ↓
├─ Is it trivial to implement?
│   └─ Yes → Implement it yourself
│   └─ No ↓
├─ Is it a solved problem with proven solutions?
│   └─ Yes → Consider a dependency
│   └─ No → Implement or research more
```

### Good Reasons to Add

| Reason | Example | Rationale |
| --- | --- | --- |
| **Complex Domain** | Cryptography, date/time, parsing | Experts have handled the edge cases you don't know about. |
| **Security Critical** | Auth, input sanitization | rolling your own security is a guaranteed vulnerability. |
| **Well-Tested Edge Cases** | Email validation, URL parsing | Regex is harder than it looks; use a proven implementation. |
| **High Effort** | Full-featured HTTP client | The maintenance cost of building it exceeds the dependency risk. |
| **Active Maintenance** | Database drivers | Protocols change; you need a team keeping up with them. |

### Bad Reasons to Add

| Reason | Why It's Bad | Rationale |
| --- | --- | --- |
| **"Everyone uses it"** | Popularity != Quality | Massive usage doesn't prevent massive security flaws (e.g. Log4j). |
| **"Saves lines"** | Maintenance > Lines | Lines of code are cheap; dependencies are expensive structural debt. |
| **"Might need later"** | YAGNI | Adding code "just in case" increases attack surface for zero value. |
| **"Looks cool"** | Not technical | Engineering decisions must be based on requirements, not hype. |
| **"Can't be bothered"** | Ignorance | If you don't understand the domain, you can't verify the package. |

### The Trivial Test

Don't add a dependency for:

```javascript
// BAD: Package for left-pad
import leftPad from 'left-pad'
leftPad('1', 3, '0')  // '001'

// GOOD: Just write it
const leftPad = (str, len, char) => str.padStart(len, char)
leftPad('1', 3, '0')  // '001'
```

```javascript
// BAD: Package for isArray
import isArray from 'is-array'

// GOOD: Built-in
Array.isArray(value)
```

---

## Evaluating Dependencies

### Evaluation Checklist

| Check | Why | How | Rationale |
| --- | --- | --- | --- |
| **Maintenance** | Unmaintained = risk | Last commit, issue response | Code that isn't updated accumulates vulnerabilities. |
| **Popularity** | Indicator of trust | Downloads, stars (cautiously) | "Wisdom of crowds" usually filters out totally broken packages. |
| **Security** | Known vulnerabilities | `npm audit`, Snyk | Never ship known holes; automated checks are fast and cheap. |
| **License** | Legal compliance | Check LICENSE file | Wrong license can force total rewrites or lawsuits. |
| **Size** | Bundle/install impact | Package size, dependencies | Large deps slow down CI and client load times. |
| **Quality** | Reliability | Tests, TypeScript, docs | Good engineering practices suggest good runtime behavior. |

### Maintenance Signals

| Signal | Good | Concerning | Rationale |
| --- | --- | --- | --- |
| **Last Commit** | < 6 months | > 2 years | Active dev means bugs/CVEs get fixed. |
| **Open Issues** | Responded to | Ignored | Ignored issues signal abandonment or overwhelmed maintainers. |
| **Pull Requests** | Reviewed | Stale | Stale PRs mean contributions are blocked; project is effectively dead. |
| **Releases** | Regular | Sporadic | Regular releases imply a healthy CI/CD pipeline. |
| **Documentation** | Current | Outdated | Good docs mean the maintainer cares about usage. |

### Red Flags

| Flag | Risk | Rationale |
| --- | --- | --- |
| **No LICENSE** | Legal ambiguity | You literally cannot legally use it. |
| **Single Maintainer** | Abandonment | Bus factor of 1 is too risky for core logic. |
| **Many CVEs** | Vulnerability | Shows a history of poor security practices. |
| **Deep Dep Tree** | Transitive risk | One break in the chain breaks your app. |
| **Network Scripts** | Supply chain attack | `postinstall` scripts are the #1 vector for malware. |
| **Very New** | Untested | Let others be the guinea pigs. |
| **Typosquatting** | Malicious | `react-dom` vs `reactdom` is a classic attack. |

---

## Security Considerations

### Before Installing

```bash
# Check for known vulnerabilities
npm audit
pip-audit
cargo audit

# Check package info
npm info <package>
pip show <package>
```

### Vulnerability Response

| Severity | Action | Rationale |
| --- | --- | --- |
| **Critical** | Update immediately or remove | Critical CVEs are often actively exploited in the wild. |
| **High** | Update within days | High severity implies verified exploitability; don't wait. |
| **Medium** | Update within weeks | Harder to exploit, but adds distinct risk to the posture. |
| **Low** | Update at convenience | Low risk, but clean reports are easier to audit. |

### Supply Chain Safety

| Practice | Why | Rationale |
| --- | --- | --- |
| **Use Lock Files** | Pin exact versions | Ensures that CI builds exactly what you tested locally. |
| **Audit Results** | Review vulnerabilities | Ignoring audits defeats the purpose of having them. |
| **Regular Updates** | Prevent staleness | Small, frequent updates are safer than massive, rare migrations. |
| **Advisories** | Awareness | Knowledge is the first line of defense against 0-days. |
| **Min Permissions** | Least privilege | `npm install` shouldn't be able to wipe your hard drive. |

---

## Version Management

### Semantic Versioning

```text
MAJOR.MINOR.PATCH (e.g., 2.1.3)

MAJOR: Breaking changes
MINOR: New features, backward compatible
PATCH: Bug fixes, backward compatible
```

### Version Constraints

| Constraint | Meaning | Use When | Rationale |
| --- | --- | --- | --- |
| **1.2.3** | Exact | Max reproducibility | Some critical systems cannot tolerate even patch changes. |
| **^1.2.3** | 1.x.x | Most packages | Gets non-breaking features/fixes automatically. |
| **~1.2.3** | Patch only | Conservative | Safest default if you don't trust the maintainer's semantic versioning. |
| **>=1.2.3** | Any new | Almost never | "Works on my machine" nightmare generator. |
| **\*** | Any ver | Never | Guaranteed to break production eventually. |

### Lock Files

| Tool | Lock File | Must Commit? | Rationale |
| --- | --- | --- | --- |
| **npm** | `package-lock.json` | **Yes** | Single source of truth for the entire tree. |
| **yarn** | `yarn.lock` | **Yes** | Ensures deterministic installs across teams. |
| **pip** | `requirements.txt` | **Yes** | Explicit pinning prevents drift. |
| **cargo** | `Cargo.lock` | **Yes** (Apps) | Apps need determinism; libs leave it to the consumer. |
| **go** | `go.sum` | **Yes** | Validates checksums to prevent tampering. |

```bash
# Generate lock file
npm install        # Creates package-lock.json
pip freeze > requirements.txt  # Pin versions

# Install from lock file (CI/production)
npm ci             # Uses package-lock.json exactly
pip install -r requirements.txt
```

---

## Updating Dependencies

### Update Strategy

| Frequency | What to Update | Rationale |
| --- | --- | --- |
| **Weekly** | Security patches | Smallest diffs = easiest reviews and safest deploys. |
| **Monthly** | Minor versions | Keeps technical debt manageable without constant churn. |
| **Quarterly** | Major versions | Requires dedicated planning for breaking changes. |
| **Immediate** | Critical CVEs | Security trumps process; drop everything and patch. |

### Safe Update Process

| Step | Action | Rationale |
| --- | --- | --- |
| **1. Audit** | `npm outdated` | Know what you're dealing with before changing state. |
| **2. Review** | Check changelogs | Spot breaking changes *before* they break functionality. |
| **3. Branch** | `git checkout -b deps/update-x` | Isolation allows safe rollback without affecting main. |
| **4. Test** | Run full suite | Unit tests catch regression; types catch API changes. |
| **5. Verify** | Manual smoke test | Automated tests rarely cover CSS or weird edge cases. |
| **6. Merge** | Squash & merge | keeps history clean; one commit per update is easier to revert. |

### Major Version Updates

| Step | Action | Rationale |
| --- | --- | --- |
| **1. Research** | Read migration guide | Major versions mean breaking changes; map them out first. |
| **2. Plan** | List breaking changes | Don't discover breaks during the upgrade; anticipate them. |
| **3. Isolate** | Dedicated branch | Major upgrades can take days; don't block other work. |
| **4. Increment** | One major at a time | Jumping v1 -> v3 hides which version broke the build. |
| **5. Fix** | Address breaks | Systematically fix compiler/test errors. |
| **6. Verify** | Full regression test | Major versions often change behavior, not just APIs. |

---

## Dependency Organization

### Direct vs Transitive

```text
Direct dependencies: You explicitly use
├── express (you import and use)
├── lodash (you import and use)
└── jest (you configure and run)

Transitive dependencies: Pulled in by direct deps
├── express depends on body-parser, cookie, ...
├── lodash depends on nothing
└── jest depends on babel, chalk, ...
```

### Dev vs Production Dependencies

| Type | What Goes Here | Production? | Rationale |
| --- | --- | --- | --- |
| **dependencies** | Runtime code | **Yes** | Required for the app to actually run. |
| **devDependencies** | Build/test tools | **No** | Bloats the slug; irrelevant to the running app. |
| **peerDependencies** | Shared libs | **Sometimes** | Prevents version conflicts in plugins/libraries. |

```bash
# Production dependency
npm install express

# Development only
npm install --save-dev jest

# Peer dependency (libraries)
# Listed in package.json peerDependencies
```

---

## Reducing Dependency Count

### Strategies

| Strategy | How | Rationale |
| --- | --- | --- |
| **Audit Usage** | Remove unused | Dead code is a security liability. |
| **Combine** | One lib, not five | Reduces overhead and unifies API patterns. |
| **Std Lib** | Native > External | Zero install size, zero exposure, 100% stability. |
| **Implement** | Write it yourself | Don't import a whole package for one helper function. |
| **Transitive** | Check sub-deps | Shallow trees break less often. |

### Finding Unused Dependencies

```bash
# JavaScript
npx depcheck

# Python
pip-autoremove --list

# Review imports vs package.json/requirements.txt
```

### Consolidation Example

```javascript
// Before: Many small packages
import isEmail from 'is-email'
import isUrl from 'is-url'
import isUuid from 'is-uuid'
import isIp from 'is-ip'

// After: One validation library (or write your own)
import { isEmail, isUrl, isUuid, isIp } from 'validator'
```

---

## Documentation

### Document Why

```jsonc
// package.json with comments (use a separate deps.md for real projects)
{
  "dependencies": {
    "express": "^4.18.0",           // Web framework
    "pg": "^8.11.0",                // PostgreSQL driver
    "bcrypt": "^5.1.0",             // Password hashing (don't roll own)
    "date-fns": "^2.30.0"           // Date manipulation (timezone handling)
  }
}
```

### Dependency Documentation

```markdown
# Dependencies

## Runtime

| Package | Purpose | Why Not Alternatives | Rationale |
| --- | --- | --- | --- |
| **express** | HTTP server | Team expertise | Default standard for Node.js; massive middleware ecosystem. |
| **pg** | Postgres client | Direct SQL | ORMs introduce latency and complexity; native is faster. |
| **bcrypt** | Hashing | Industry standard | Never roll your own crypto; audit history matters. |

## Development

| Package | Purpose | Rationale |
| --- | --- | --- |
| **jest** | Testing | Zero-config, massive adoption, includes assertion lib. |
| **eslint** | Linting | Catching bugs at compile time beats runtime crashes. |
| **prettier** | Formatting | End bikeshedding about code style instantly. |
```

---

## Common Dependency Decisions

### Things to Usually Import

| Domain | Reason | Rationale |
| --- | --- | --- |
| **Cryptography** | Security-critical | Logic errors here are catastrophic and often silent. |
| **Date/Time** | Timezones | Time is infinitely complex (leap seconds, history); don't DIY. |
| **Db Drivers** | Protocol impl | Implementing TCP protocols correctly is a full-time job. |
| **HTTP Clients** | Edge cases | Retries, timeouts, and streaming are hard to get right. |
| **Serialization** | Compatibility | Proto/schema parsing performance is heavily optimized. |
| **Testing** | Don't reinvent | Custom test runners lack integrations and features. |

### Things to Usually Write Yourself

| Domain | Reason | Rationale |
| --- | --- | --- |
| **String Utils** | One-liners | `left-pad` taught us that trivial deps are fragile. |
| **Array Helpers** | Built-in | `Array.prototype` has everything you need in modern JS. |
| **Validation** | Standard Lib | `URL` and `RegExp` are built into the runtime now. |
| **Config Load** | Simple read | Reading a JSON file doesn't require a 5mb package. |
| **Logging** | Single function | `console.log` or a 10-line wrapper is plenty for start. |

---

## Anti-Patterns

| Anti-Pattern | Problem | Rationale |
| --- | --- | --- |
| **Everything is a Dep** | Bloat | Attack surface grows linearly with dependency count. |
| **Never Updating** | Rot | Security vulnerabilities pile up until update is impossible. |
| **No Lock File** | Drift | "Works on my machine" breaks production/CI relative to dev. |
| **Ignoring Audit** | Risk | CVEs are open doors for automated exploits. |
| **Floating Versions** | Breakage | Upstream patch releases *do* break things (Hyrum's Law). |
| **Unused Deps** | Waste | Slows down `npm install` and CI for zero value. |
| **Duplication** | Confusion | 3 different UUID libs means 3 different data shapes. |
| **Skipping Changelogs** | Suprise | You cannot debug what you didn't read. |

---

## Dependency Checklist

### Pre-Add Checklist

| Question | Rationale |
| --- | --- |
| **Necessary?** | Dependencies are debt; only take debt for assets. |
| **Std Lib?** | Native is always faster and safer. |
| **Maintained?** | Dead code is a security hole. |
| **Vulnerabilities?** | Don't import CVEs. |
| **License?** | Legal checks are cheaper than lawsuits. |
| **Trusted?** | Supply chain attacks are real. |
| **Size?** | Performance budget is finite. |
| **Transitive?** | Check the whole tree, not just the root. |
| **Documented?** | If you don't write down *why*, you'll forget. |

### Update Checklist

| Question | Rationale |
| --- | --- |
| **Changelog?** | Read before you run; know what changed. |
| **Breaking?** | Major versions require migration plans. |
| **Tests Pass?** | CI is your safety net; trust it. |
| **Critical Paths?** | Automated tests miss visual/integration bugs. |
| **Lock Updated?** | Commit the artifact or the CI won't see usage. |

---

## See Also

- [Security Boundaries](../security-boundaries/security-boundaries.md) – Security considerations for dependencies
- [Code Review for AI Output](../code-review-ai/code-review-ai.md) – Reviewing dependency additions
