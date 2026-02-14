# Secrets & Configuration Management

Guidelines for separating configuration from code and handling secrets securely.

> **Scope**: Applies to application configuration, environment variables, API keys, database credentials, and any
> sensitive values. Agents must never hardcode secrets or commit them to repositories.

## Contents

| Section |
| :--- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Configuration Hierarchy](#configuration-hierarchy) |
| [Secrets Handling](#secrets-handling) |
| [Environment-Specific Config](#environment-specific-config) |
| [Anti-Patterns](#anti-patterns) |
| [Verification](#verification) |

---

## Quick Reference

| Category | Guidance | Rationale |
| :--- | :--- | :--- |
| **Always** | Read secrets from environment or secret store | Never embedded in code |
| **Always** | Add secret files to `.gitignore` | Prevents accidental commits |
| **Always** | Use different secrets per environment | Limits blast radius of leaks |
| **Always** | Default to secure/production settings | Dev overrides, not prod |
| **Prefer** | Secret managers over env files | Rotation, audit, encryption |
| **Prefer** | Structured config files over env vars | Easier validation and defaults |
| **Never** | Commit secrets to version control | Even "temporarily" |
| **Never** | Log or print secret values | Exposes in logs/traces |
| **Never** | Hardcode URLs, ports, or credentials | Config varies by environment |

**The Litmus Test**: Could this codebase be open-sourced right now without leaking secrets?

---

## Core Principles

| Principle | Guideline | Rationale |
| :--- | :--- | :--- |
| **Config ≠ Code** | Configuration changes without code changes | Different deploy/release cycles |
| **Secrets are special** | Encrypted, rotated, audited separately | Higher security requirements |
| **Environment parity** | Same code, different config per env | Reduces "works on my machine" |
| **Secure defaults** | Production-safe unless overridden | Fail-safe in unknown environments |
| **12-Factor compliance** | Store config in environment | Industry-proven pattern |

---

## Configuration Hierarchy

Configuration should be loaded in layers, with later sources overriding earlier ones:

| Priority | Source | Use Case | Example |
| :--- | :--- | :--- | :--- |
| 1 (lowest) | Hardcoded defaults | Sensible fallbacks | `timeout: 30s` |
| 2 | Config file | Base configuration | `config.yaml` |
| 3 | Environment-specific file | Per-environment overrides | `config.prod.yaml` |
| 4 | Environment variables | Container/cloud config | `DATABASE_URL` |
| 5 (highest) | Secret manager | Sensitive credentials | Vault, AWS Secrets Manager |

### What Goes Where

| Config Type | Location | Rationale |
| :--- | :--- | :--- |
| App behavior (timeouts, limits) | Config file | Version controlled, reviewable |
| Feature flags | Config file or remote | Toggleable without deploy |
| Service URLs | Environment variable | Varies by deployment |
| Database credentials | Secret manager | Encrypted, audited, rotated |
| API keys | Secret manager | Same as credentials |
| Encryption keys | Secret manager | Never in code or env files |

---

## Secrets Handling

### Pattern 1: Environment Variable Injection

Secrets injected at runtime, never stored in code.

```python
# Good: Read from environment
import os

db_password = os.environ["DATABASE_PASSWORD"]
api_key = os.environ.get("API_KEY")  # Optional with None default

# Good: Fail fast if required secret missing
def get_required_env(name: str) -> str:
    value = os.environ.get(name)
    if not value:
        raise RuntimeError(f"Required environment variable {name} not set")
    return value
```

```python
# Bad: Hardcoded secret
db_password = "super_secret_123"  # Never do this

# Bad: Secret in config file that gets committed
# config.yaml
# database:
#   password: super_secret_123
```

### Pattern 2: Secret Manager Integration

For production systems, use dedicated secret managers.

| Provider | Tool | Use Case |
| :--- | :--- | :--- |
| Multi-cloud | HashiCorp Vault | Self-hosted, full control |
| AWS | Secrets Manager | Native AWS integration |
| GCP | Secret Manager | Native GCP integration |
| Azure | Key Vault | Native Azure integration |
| Kubernetes | External Secrets Operator | K8s-native approach |

```python
# Good: Fetch from secret manager at startup
from secret_manager import get_secret

class Config:
    def __init__(self):
        self.db_password = get_secret("prod/database/password")
        self.api_key = get_secret("prod/external-api/key")
```

### Pattern 3: Sidecar/Init Container

Application never directly accesses secret store; sidecar populates a volume.

```yaml
# Kubernetes: secrets mounted as files
containers:
  - name: app
    volumeMounts:
      - name: secrets
        mountPath: /secrets
        readOnly: true
volumes:
  - name: secrets
    secret:
      secretName: app-secrets
```

```python
# Application reads from mounted path
with open("/secrets/database-password") as f:
    db_password = f.read().strip()
```

---

## Environment-Specific Config

### File Structure

```text
config/
├── config.yaml          # Base config (committed)
├── config.dev.yaml      # Dev overrides (committed, no secrets)
├── config.prod.yaml     # Prod structure (committed, no secrets)
└── .env.local           # Local secrets (gitignored)
```

### Loading Pattern

```python
# Good: Layered config loading
import yaml
import os

def load_config():
    # 1. Load base config
    with open("config/config.yaml") as f:
        config = yaml.safe_load(f)

    # 2. Load environment-specific overrides
    env = os.environ.get("APP_ENV", "dev")
    env_file = f"config/config.{env}.yaml"
    if os.path.exists(env_file):
        with open(env_file) as f:
            env_config = yaml.safe_load(f)
            deep_merge(config, env_config)

    # 3. Environment variables override file config
    if db_url := os.environ.get("DATABASE_URL"):
        config["database"]["url"] = db_url

    return config
```

### Secure Defaults

```yaml
# config.yaml - Production-safe defaults
security:
  debug: false           # Never expose debug info by default
  ssl_verify: true       # Always verify certificates
  csrf_enabled: true     # Always enable CSRF protection

# config.dev.yaml - Dev overrides (explicit)
security:
  debug: true            # OK in dev only
```

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| :--- | :--- | :--- |
| **Hardcoded secrets** | Committed to repo, exposed forever | Environment/secret manager |
| **Secrets in logs** | Visible in monitoring systems | Redact before logging |
| **Same secret everywhere** | One breach exposes all | Per-environment secrets |
| **Secrets in error messages** | Exposed to users/attackers | Generic error messages |
| **Long-lived API keys** | Harder to rotate, more exposure | Short-lived tokens where possible |
| **Secrets in Docker images** | Visible in layers | Inject at runtime |
| **`.env` committed** | Common mistake | Add to `.gitignore` immediately |
| **Config in code comments** | "Temporarily" becomes forever | Delete, use proper config |

### Gitignore Template

```gitignore
# Secrets and local config
.env
.env.local
.env.*.local
*.pem
*.key
secrets/
config/local/

# Editor/IDE files that may contain secrets
.idea/
.vscode/settings.json
```

---

## Verification

### Pre-Commit Checks

| Check | Tool | Purpose |
| :--- | :--- | :--- |
| Secret scanning | `gitleaks`, `trufflehog` | Detect committed secrets |
| Env file check | Custom script | Ensure `.env` is gitignored |
| Config validation | Schema validator | Catch missing required config |

```bash
# Example: gitleaks pre-commit
gitleaks detect --source . --verbose
```

### Runtime Checks

```python
# Good: Validate config at startup
def validate_config(config: dict) -> None:
    required = ["database.url", "api.base_url"]
    for key in required:
        if not get_nested(config, key):
            raise ConfigError(f"Missing required config: {key}")

    # Warn about insecure settings in production
    if os.environ.get("APP_ENV") == "prod":
        if config.get("security", {}).get("debug"):
            raise ConfigError("Debug mode cannot be enabled in production")
```

### Checklist

- [ ] No secrets in repository (run `gitleaks`)
- [ ] `.env` and secret files in `.gitignore`
- [ ] Different credentials per environment
- [ ] Secrets loaded from environment or secret manager
- [ ] Debug/development settings OFF by default
- [ ] Config validated at startup

---

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| Hardcoded API key, password, or token in source code | Move to environment variable or secret manager immediately | Committed secrets persist in git history even after "deletion" |
| `.env` file not in `.gitignore` | Add it to `.gitignore` before the next commit | A committed `.env` leaks every secret in the file |
| Same database password used in dev, staging, and prod | Generate unique credentials per environment | One breach exposes all environments |
| Secret value appearing in application logs | Add redaction — log "provided: true/false" instead | Logs are often stored in broadly accessible systems |
| Secret rotation has never been performed | Schedule rotation and verify the rotation procedure works | Unrotated secrets have unlimited exposure windows |
| Debug mode enabled in production config | Disable immediately | Debug mode exposes stack traces, config values, and internal state |

---

## See Also

- [Security Boundaries](../security-boundaries/security-boundaries.md) – Security requirements for AI development
- [Logging Practices](../logging-practices/logging-practices.md) – Ensure secrets aren't logged
- [Error Handling](../error-handling/error-handling.md) – Avoid exposing secrets in errors
