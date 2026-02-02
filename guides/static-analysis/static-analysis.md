# Static Analysis Integration

Guidelines for integrating linters, formatters, and security scanners into development workflows.

> **Scope**: Applies to automated code quality tools run during development and CI. Agents must configure and respect static analysis rules to maintain code quality automatically.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Tool Categories](#tool-categories) |
| [Configuration Patterns](#configuration-patterns) |
| [CI Integration](#ci-integration) |
| [Handling Results](#handling-results) |
| [Anti-Patterns](#anti-patterns) |

---

## Quick Reference

| Category | Guidance | Rationale |
| --- | --- | --- |
| **Always** | Run linters in CI before merge | Catches issues automatically |
| **Always** | Commit analysis configuration | Reproducible across environments |
| **Always** | Fix findings rather than disable rules | Maintains quality baseline |
| **Prefer** | Format on save over manual formatting | Consistent, zero effort |
| **Prefer** | Incremental scans for large codebases | Fast feedback in PRs |
| **Never** | Disable security findings without review | May mask real vulnerabilities |
| **Never** | Commit code with lint errors | Broken windows effect |

---

## Core Principles

| Principle | Guideline | Rationale |
| --- | --- | --- |
| **Automate enforcement** | Tools catch what humans miss | Consistent, tireless checking |
| **Fast feedback** | Run locally and early in CI | Fix before code review |
| **Baseline, don't regress** | New code must pass; fix legacy over time | Gradual improvement |
| **Configuration as code** | Version control all tool settings | Reproducible, reviewable |
| **Minimal friction** | Auto-fix where possible | Developers stay productive |

---

## Tool Categories

### Tool Types

| Category | Purpose | Examples |
| --- | --- | --- |
| **Formatter** | Consistent code style | Prettier, Black, gofmt |
| **Linter** | Code quality, bugs | ESLint, Pylint, golangci-lint |
| **Type Checker** | Type safety | TypeScript, mypy, Pyright |
| **SAST** | Security vulnerabilities | Semgrep, Bandit, CodeQL |
| **Dependency Scanner** | Known CVEs | Snyk, Dependabot, osv-scanner |

### Recommended Stack

| Language | Formatter | Linter | Type Checker | SAST |
| --- | --- | --- | --- | --- |
| JavaScript/TS | Prettier | ESLint | TypeScript | Semgrep |
| Python | Black, isort | Ruff or Pylint | mypy or Pyright | Bandit |
| Go | gofmt | golangci-lint | Built-in | gosec |
| Java | google-java-format | Checkstyle | Built-in | SpotBugs |
| Rust | rustfmt | Clippy | Built-in | cargo-audit |

---

## Configuration Patterns

### Shared Configuration Files

```text
project/
├── .eslintrc.json      # Linter rules
├── .prettierrc         # Formatter rules
├── pyproject.toml      # Python tool config (Black, mypy, ruff)
├── .editorconfig       # Cross-editor settings
└── .pre-commit-config.yaml  # Git hooks
```

### Rule Severity Levels

| Level | Action | Use For |
| --- | --- | --- |
| **Error** | Block commit/merge | Security, bugs, breaking issues |
| **Warning** | Show but allow | Style preferences, tech debt |
| **Off** | Disabled | Rules that don't fit project |

### Extending Base Configs

```javascript
// .eslintrc.json - Extend standard config
{
  "extends": ["eslint:recommended", "plugin:@typescript-eslint/recommended"],
  "rules": {
    "@typescript-eslint/no-unused-vars": "error",
    "@typescript-eslint/explicit-function-return-type": "warn"
  }
}
```

```toml
# pyproject.toml - Ruff configuration
[tool.ruff]
select = ["E", "F", "W", "I", "S", "B"]  # Enable rule categories
ignore = ["E501"]  # Line length handled by formatter
line-length = 100

[tool.ruff.per-file-ignores]
"tests/*" = ["S101"]  # Allow assert in tests
```

---

## CI Integration

### Pipeline Placement

| Stage | Tools | Fail On |
| --- | --- | --- |
| Pre-commit | Formatter, fast linter | Any error |
| PR Check | Full linter, type check | Any error |
| Scheduled | SAST, dependency scan | New high/critical findings |

### Example CI Configuration

```yaml
# GitHub Actions
name: Lint and Check
on: [pull_request]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Format Check
        run: npm run format:check
        
      - name: Lint
        run: npm run lint
        
      - name: Type Check
        run: npm run typecheck
        
      - name: Security Scan
        run: npx semgrep --config=auto
```

### Incremental Analysis

```bash
# Only analyze changed files (faster PR feedback)
FILES=$(git diff --name-only origin/main...HEAD -- '*.py')
ruff check $FILES
```

---

## Handling Results

### Fixing vs Ignoring

| Situation | Action | Method |
| --- | --- | --- |
| Real issue | Fix the code | Preferred |
| False positive | Inline disable with comment | `// eslint-disable-next-line` |
| Project-wide exception | Config file exclusion | Add to ignore list |
| Legacy code | Baseline and fix incrementally | Track tech debt |

### Inline Disable Format

```python
# Good: Specific disable with reason
user_input = request.get("data")  # noqa: S105 - Input sanitized upstream

# Bad: Blanket disable without reason
result = eval(code)  # noqa
```

```javascript
// Good: Specific rule with comment
// eslint-disable-next-line @typescript-eslint/no-explicit-any -- Legacy API requires any
const data: any = legacyApiCall();

// Bad: File-wide disable
/* eslint-disable */
```

### Baseline for Legacy Code

```bash
# Generate baseline of existing issues
ruff check . --output-format=json > .ruff-baseline.json

# Only fail on new issues
ruff check . --diff-against-baseline=.ruff-baseline.json
```

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| --- | --- | --- |
| **Blanket disables** | Hides real issues | Disable specific rules with reasons |
| **Ignoring warnings** | Issues accumulate | Fix or promote to errors |
| **Tool sprawl** | Conflicting/overlapping rules | Consolidate tools |
| **Stale baseline** | Never fixing legacy issues | Schedule baseline reduction |
| **CI-only linting** | Late feedback | Add pre-commit hooks |
| **Too strict initially** | Developer frustration | Start lenient, tighten gradually |
| **No auto-fix** | Manual toil | Enable formatters on save |

---

## See Also

- [CI/CD Pipelines](../cicd-pipelines/cicd-pipelines.md) – Pipeline design patterns
- [Secure Coding](../secure-coding/secure-coding.md) – Security-focused analysis
- [Coding Guidelines](../coding-guidelines/coding-guidelines.md) – Style conventions
