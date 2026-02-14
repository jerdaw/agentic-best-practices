# Supply Chain Security

Best practices for AI agents on securing the software supply chain—dependencies, build provenance, artifact integrity,
and CI/CD security.

> **Scope**: These guidelines help AI agents make secure choices about dependencies, builds, and CI/CD pipelines.
> Supply chain attacks are high-impact; prevention requires discipline at every step.

## Contents

| Section |
| :--- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Dependency Provenance](#dependency-provenance) |
| [SLSA Compliance](#slsa-compliance) |
| [Dependency Pinning](#dependency-pinning) |
| [CI/CD Security](#cicd-security) |
| [Software Bill of Materials (SBOM)](#software-bill-of-materials-sbom) |
| [Artifact Signing](#artifact-signing) |
| [Vulnerability Management](#vulnerability-management) |
| [Third-Party Code Review](#third-party-code-review) |
| [Anti-Patterns](#anti-patterns) |
| [Supply Chain Checklist](#supply-chain-checklist) |

---

## Quick Reference

**SLSA Framework** (Supply-chain Levels for Software Artifacts):

| Level | Requirements | Trust |
| :--- | :--- | :--- |
| 0 | No guarantees | None |
| 1 | Build process documented | Low |
| 2 | Signed provenance, hosted build | Medium |
| 3 | Hardened builds, non-falsifiable provenance | High |
| 4 | Hermetic, reproducible, two-party review | Very High |

**Key practices**:

- Pin dependencies to exact versions
- Pin CI actions to commit SHAs
- Verify provenance before trusting artifacts
- Generate and publish SBOMs
- Use signed commits and artifacts

---

## Core Principles

1. **Trust but verify** – Don't assume dependencies are safe
2. **Pin everything** – Reproducibility prevents supply chain drift
3. **Provenance matters** – Know where artifacts come from
4. **Minimize surface** – Fewer dependencies = smaller attack surface
5. **Verify signatures** – Signed artifacts provide accountability

---

## Dependency Provenance

### What is Provenance?

Provenance answers: Who built this? From what source? Using what process?

| Question | Why It Matters |
| :--- | :--- |
| Who published? | Trust the publisher |
| What source? | Verify it matches expectations |
| How built? | Ensure no tampering in build |
| When built? | Detect stale or backdated artifacts |

### Verifying Provenance

```bash
# npm - check package info
npm info <package> --json

# Verify npm package signatures (npm 8.x+)
npm audit signatures

# Python - check package source
pip show <package>
pip download --no-deps <package>  # Inspect before installing

# Go - verify module checksums
go mod verify

# Verify sigstore signatures
cosign verify <artifact>
```

### Provenance Red Flags

| Flag | Risk | Action |
| :--- | :--- | :--- |
| No source repository | Can't audit code | Find alternative |
| Source doesn't match package | Possible tampering | Investigate or avoid |
| No build pipeline | Local builds are risky | Prefer CI-built packages |
| Unsigned artifacts | No accountability | Require signatures |

---

## SLSA Compliance

### SLSA Levels Explained

**Level 1**: Documentation

- Build process is documented
- Automated build exists

**Level 2**: Provenance

- Signed provenance generated
- Build runs on hosted service
- Provenance includes source and build info

**Level 3**: Security

- Hardened build platform
- Non-falsifiable provenance
- Isolated build environment

**Level 4**: Highest Assurance

- Hermetic builds (no network, pinned tools)
- Reproducible builds
- Two-party review for source changes

### Implementing SLSA

| Level | Implementation Steps |
| :--- | :--- |
| 1 | Document build in README, use CI |
| 2 | Add provenance generation to CI, sign artifacts |
| 3 | Use hardened runners, isolated builds |
| 4 | Pin all build tools, hermetic environment |

### GitHub Actions Provenance

```yaml
# Generate SLSA provenance with GitHub Actions
jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      id-token: write  # Required for signing
      contents: read
      attestations: write
    steps:
      - uses: actions/checkout@v4
      - name: Build
        run: npm run build
      - name: Generate provenance
        uses: actions/attest-build-provenance@v1
        with:
          subject-path: 'dist/*'
```

---

## Dependency Pinning

### Why Pin?

| Unpinned | Pinned | Risk Reduction |
| :--- | :--- | :--- |
| `^1.2.3` | `1.2.3` | No surprise updates |
| `>=1.0.0` | `1.0.0` | Reproducible builds |
| `latest` | `2.1.0` | No version drift |

### Pinning Strategies

**Lock files** (always commit):

| Tool | Lock File |
| :--- | :--- |
| npm | `package-lock.json` |
| yarn | `yarn.lock` |
| pnpm | `pnpm-lock.yaml` |
| pip | `requirements.txt` (pinned) or `poetry.lock` |
| Go | `go.sum` |
| Rust | `Cargo.lock` |

**Install from lock file in CI**:

```bash
# npm - use ci instead of install
npm ci

# pip - use exact versions
pip install -r requirements.txt --require-hashes

# yarn - frozen lockfile
yarn install --frozen-lockfile
```

### Updating Pinned Dependencies

```bash
# Update deliberately, not accidentally
npm update <package>  # Update specific package
npm audit fix         # Fix vulnerabilities

# Review changes
git diff package-lock.json

# Test before committing
npm test
```

---

## CI/CD Security

### GitHub Actions Hardening

**Pin actions to SHA** (not tags):

```yaml
# BAD: Tags can be moved
- uses: actions/checkout@v4

# GOOD: SHA is immutable
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11
```

**Minimal token permissions**:

```yaml
# Default to read-only
permissions:
  contents: read

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write  # Only what's needed
```

**Restrict allowed actions**:

```yaml
# In organization/repo settings
# Only allow actions from:
# - actions/* (GitHub's official)
# - Your organization
# - Explicitly allowed third-party
```

### CI Security Checklist

```markdown
□ All actions pinned to SHA
□ GITHUB_TOKEN has minimal permissions
□ Secrets not exposed to PRs from forks
□ Third-party actions audited
□ No shell injection via user input
□ Artifacts signed before publishing
```

### Shell Injection Prevention

```yaml
# BAD: User input in shell command
- run: echo "Hello ${{ github.event.issue.title }}"

# GOOD: Use environment variable
- run: echo "Hello $TITLE"
  env:
    TITLE: ${{ github.event.issue.title }}

# GOOD: Use intermediate step with validation
- name: Validate input
  run: |
    if [[ ! "$TITLE" =~ ^[a-zA-Z0-9\ ]+$ ]]; then
      echo "Invalid title format"
      exit 1
    fi
  env:
    TITLE: ${{ github.event.issue.title }}
```

---

## Software Bill of Materials (SBOM)

### What is SBOM?

An SBOM is an inventory of all components in your software:

- Direct dependencies
- Transitive dependencies
- Versions
- Licenses
- Vulnerabilities (when scanned)

### SBOM Formats

| Format | Use Case |
| :--- | :--- |
| SPDX | ISO standard, broad tool support |
| CycloneDX | Security-focused, vulnerability correlation |
| SWID | Software identification tags |

### Generating SBOMs

```bash
# npm - using @cyclonedx/bom
npx @cyclonedx/cyclonedx-npm --output-file sbom.json

# Python - using cyclonedx-py
cyclonedx-py requirements -r requirements.txt -o sbom.json

# Container images - using syft
syft <image> -o spdx-json > sbom.json

# Multi-format - using trivy
trivy sbom --format cyclonedx <target>
```

### SBOM in CI

```yaml
jobs:
  sbom:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@<sha>
      - name: Generate SBOM
        uses: anchore/sbom-action@<sha>
        with:
          format: spdx-json
          output-file: sbom.spdx.json
      - name: Upload SBOM
        uses: actions/upload-artifact@<sha>
        with:
          name: sbom
          path: sbom.spdx.json
```

---

## Artifact Signing

### Why Sign?

| Without Signing | With Signing |
| :--- | :--- |
| Can't verify origin | Proven publisher |
| Tampering undetected | Integrity verified |
| No accountability | Traceable to signer |

### Signing with Sigstore/Cosign

```bash
# Sign a container image
cosign sign <image>

# Verify a signed image
cosign verify <image>

# Sign a blob/file
cosign sign-blob --bundle artifact.sig artifact.tar.gz

# Verify a signed blob
cosign verify-blob --bundle artifact.sig artifact.tar.gz
```

### Keyless Signing (Sigstore)

Uses OIDC identity (GitHub Actions, GitLab CI):

```yaml
# GitHub Actions with keyless signing
jobs:
  sign:
    runs-on: ubuntu-latest
    permissions:
      id-token: write  # Required for keyless
    steps:
      - name: Sign image
        run: cosign sign ${{ env.IMAGE }}
```

---

## Vulnerability Management

### Continuous Scanning

```yaml
# GitHub Actions with Trivy
jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@<sha>
      - name: Scan for vulnerabilities
        uses: aquasecurity/trivy-action@<sha>
        with:
          scan-type: 'fs'
          severity: 'CRITICAL,HIGH'
          exit-code: '1'  # Fail on vulnerabilities
```

### Vulnerability Response

| Severity | Response Time | Action |
| :--- | :--- | :--- |
| Critical | Immediate | Patch or remove |
| High | Within days | Plan remediation |
| Medium | Within sprint | Schedule update |
| Low | Next maintenance | Bundle with other updates |

### Handling Vulnerabilities

```markdown
1. Assess: Is this vulnerability exploitable in our context?
2. Prioritize: Severity + exploitability + exposure
3. Remediate: Update dependency or apply workaround
4. Verify: Confirm vulnerability is resolved
5. Document: Record decision and rationale
```

---

## Third-Party Code Review

### Before Adding Dependencies

| Check | How |
| :--- | :--- |
| Maintenance status | Last commit, open issues |
| Security history | Past CVEs, response time |
| Dependency count | Fewer = smaller surface |
| License | Compatible with your use |
| Publisher reputation | Verified, trusted org |

### Auditing Dependencies

```bash
# npm audit
npm audit

# Detailed report
npm audit --json

# Python
pip-audit

# Go
go list -m -json all | nancy sleuth

# Multi-language
snyk test
```

### Dependency Firewall

```yaml
# Only allow packages from approved sources
# npm - use .npmrc
registry=https://registry.npmjs.org/
@myorg:registry=https://npm.pkg.github.com/

# Block known-malicious packages
# Use tools like Socket, Snyk, or internal proxy
```

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| :--- | :--- | :--- |
| **Unpinned dependencies** | Version drift, surprise breaks | Pin all versions |
| **Tags in CI actions** | Tags can be moved maliciously | Pin to SHA |
| **Overly broad token perms** | Excessive access if compromised | Minimal permissions |
| **No SBOM** | Can't respond to vulnerabilities | Generate and publish |
| **Unsigned artifacts** | Can't verify integrity | Sign with Sigstore |
| **Ignored audit results** | Known vulnerabilities | Fix or document |
| **Shell injection in CI** | RCE via user input | Sanitize inputs |

---

## Supply Chain Checklist

For every project:

- [ ] Dependencies pinned to exact versions
- [ ] Lock file committed and used in CI
- [ ] CI actions pinned to SHA
- [ ] GITHUB_TOKEN has minimal permissions
- [ ] Vulnerability scanning in CI
- [ ] SBOM generated and published
- [ ] Artifacts signed
- [ ] Third-party actions audited

---

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| CI actions pinned to tags (`@v4`) instead of SHA | Pin to commit SHA | Tags can be moved — a compromised action tag affects every consumer |
| `npm audit` reports critical vulnerabilities ignored for weeks | Fix or document a risk-acceptance decision | Known unfixed vulnerabilities are breaches waiting to happen |
| New dependency added with zero GitHub stars and one maintainer | Evaluate alternatives or vendoring | Low-trust packages are prime supply chain attack vectors |
| No lock file committed to version control | Commit lock files and use `npm ci` in CI | Without lock files, builds are non-reproducible and vulnerable to version drift |
| `GITHUB_TOKEN` has `write-all` permissions | Scope to minimal required permissions | Over-permissioned tokens, if leaked, give attackers full repository access |

---

## See Also

- [Dependency Management](../dependency-management/dependency-management.md) – Evaluating and updating dependencies
- [Security Boundaries](../security-boundaries/security-boundaries.md) – General security practices
