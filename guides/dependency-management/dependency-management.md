# Dependency Management

Best practices for AI agents on managing project dependencies, auditing for security, and preventing bloat.

> **Scope**: Applies to package managers (npm, pip, cargo, etc.) and third-party library selection. Goal: Maintain a
> lean, secure, and modern dependency tree.

## Contents

| Section |
| :--- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Selection Criteria](#selection-criteria) |
| [Security Auditing](#security-auditing) |
| [Version Pinning](#version-pinning) |
| [Cleanup and Pruning](#cleanup-and-pruning) |
| [Anti-Patterns](#anti-patterns) |

---

## Quick Reference

| Category | Guidance | Rationale |
| :--- | :--- | :--- |
| **Addition** | Always ask before adding a library | Impacts bundle size and security |
| **Auditing** | Run `audit` on every new installation | Catches known vulnerabilities early |
| **Pinning** | Use lockfiles and exact versions | Ensures reproducible builds |
| **Pruning** | Remove unused dependencies regularly | Reduces attack surface and bloat |
| **Licenses** | Check for restrictive licenses | Legal and compliance safety |

---

## Core Principles

1. **Minimalism** – Every dependency is a liability; use only what is truly necessary.
2. **Security by default** – Audit constantly and favor well-maintained libraries.
3. **Reproducibility** – Builds should yield the same output across environments.
4. **Current but stable** – Stay reasonably up-to-date while avoiding "alpha" versions.
5. **Transparency** – Document why a specific dependency was chosen.

---

## Selection Criteria

Before adding a new dependency, an agent should evaluate:

| Criterion | Target | Why |
| :--- | :--- | :--- |
| **Popularity** | > 100k downloads/month | Larger community for support |
| **Maintenance** | Last commit < 3 months | Active development is safer |
| **Security** | 0 critical vulnerabilities | Found via `npm audit` or equivalent |
| **Size** | < 100kb (minified) | Keeps production bundles lean |
| **License** | MIT / Apache / BSD | Broad compatibility |

---

## Security Auditing

| Action | Command (Example) |
| :--- | :--- |
| **Initial Audit** | `npm audit` |
| **Deep Scan** | `snyk test` or `trivy` |
| **License Check** | `license-checker` |
| **Outdated Check** | `npm outdated` |

---

## Version Pinning

| Level | Example | When to Use |
| :--- | :--- | :--- |
| **Exact** | `1.2.3` | Critical libraries (security, core) |
| **Patch** | `~1.2.3` | Libraries with stable patch releases |
| **Minor** | `^1.2.3` | General use (default in most tools) |
| **Ranges** | `>=1.0.0` | Library authors (peer dependencies) |

### Examples

**Good: Lockfile prevents version drift**

```json
// package.json
{
  "dependencies": {
    "express": "^4.18.2"
  }
}

// package-lock.json (committed to git)
{
  "dependencies": {
    "express": {
      "version": "4.18.2",
      "resolved": "https://registry.npmjs.org/express/-/express-4.18.2.tgz"
    }
  }
}
```

CI, staging, and production all install Express 4.18.2 - no surprises.

**Bad: No lockfile = version drift**

```json
// package.json only, no lockfile
{
  "dependencies": {
    "express": "^4.18.0"
  }
}
```

Dev has 4.18.0, CI installs 4.18.5, production gets 4.19.0 - inconsistent behavior.

**Good: Audit before adding dependency**

```bash
# Check security before install
npm audit
npm install lodash
npm audit  # Verify no new vulnerabilities

# Output: 0 vulnerabilities
```

**Bad: Blindly adding packages**

```bash
npm install left-pad micro-dep tiny-util another-util
# No security check, unknown provenance, potential supply chain risk
```

---

## Cleanup and Pruning

Regularly run maintenance commands:

1. **depcheck** – Find unused dependencies.
2. **npm prune** – Remove packages not in `package.json`.
3. **Duplication check** – Ensure multiple versions of the same library aren't installed.

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| :--- | :--- | :--- |
| **Implicit deps** | Code relies on non-listed library | Add explicitly to `package.json` |
| **Ghost dependencies**| Unused packages left in tree | Use `depcheck` and remove |
| **Version drift** | Dev and CI use different versions | Commit and use lockfiles |
| **Micro-packages** | "left-pad" style risk | Use built-in language features |
| **Blind updates** | Breaking changes reach prod | Use CI to verify dependency updates |

---

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| Adding a dependency for a trivial task (< 10 lines of code) | Write it yourself | Micro-packages introduce supply chain risk for minimal value |
| Multiple libraries serving the same purpose | Pick one and remove the others | Duplicate deps bloat the bundle and create version conflicts |
| Ignoring `npm audit` / `pip audit` warnings | Fix or document as accepted risk | Known vulnerabilities in your deps are your vulnerabilities |
| No lockfile committed to version control | Commit it immediately | Without a lockfile, builds are non-reproducible |
| Dependency has no recent commits (> 12 months) | Evaluate alternatives or fork | Abandoned deps won't get security patches |

---

## See Also

- [Supply Chain Security](../supply-chain-security/supply-chain-security.md) – Advanced auditing
- [Architecture for AI](../architecture-for-ai/architecture-for-ai.md) – Design boundaries
- [Secure Coding](../secure-coding/secure-coding.md) – Safe library usage
