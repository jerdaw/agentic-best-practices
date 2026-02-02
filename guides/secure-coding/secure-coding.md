# Secure Coding Patterns

Guidelines for writing code that defends against common vulnerabilities.

> **Scope**: Applies to all code handling user input, authentication, data access, or external communication. Agents must
> bake security in by default, not bolt it on later.

## Contents

| Section |
| :--- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Input Validation](#input-validation) |
| [Injection Prevention](#injection-prevention) |
| [Authentication & Authorization](#authentication--authorization) |
| [Data Protection](#data-protection) |
| [Error Handling](#error-handling) |
| [Anti-Patterns](#anti-patterns) |
| [Verification](#verification) |

---

## Quick Reference

| Category | Guidance | Rationale |
| :--- | :--- | :--- |
| **Always** | Validate all external input | Untrusted data is attack vector |
| **Always** | Use parameterized queries | Prevents SQL injection |
| **Always** | Encode output for context | Prevents XSS |
| **Always** | Check authorization on every request | Don't trust client state |
| **Always** | Use secure defaults (HTTPS, secure cookies) | Fail-safe configuration |
| **Prefer** | Allowlists over denylists | Denylists miss attack variants |
| **Prefer** | Framework security features | Battle-tested, maintained |
| **Never** | Trust client-provided data | All user input is hostile |
| **Never** | Expose stack traces to users | Information disclosure |
| **Never** | Roll custom crypto | Use established libraries |

---

## Core Principles

| Principle | Guideline | Rationale |
| :--- | :--- | :--- |
| **Defense in depth** | Multiple layers of protection | Single failure doesn't compromise all |
| **Least privilege** | Minimum permissions needed | Limits blast radius |
| **Fail securely** | On error, deny access | Errors shouldn't open backdoors |
| **Secure defaults** | Secure unless explicitly loosened | Opt-in to risk, not opt-out |
| **Input = untrusted** | All external data is hostile | Assume malicious intent |

---

## Input Validation

### Validation Strategy

| Technique | When to Use | Example |
| :--- | :--- | :--- |
| **Allowlist** | Known valid patterns | Email regex, enum values |
| **Type coercion** | Expected data types | `parseInt()`, schema validation |
| **Length limits** | Buffer overflow prevention | Max 255 chars for name |
| **Range checks** | Numeric boundaries | Age between 0-150 |
| **Format validation** | Structured data | UUID, date, phone number |

### Implementation

```python
# Good: Allowlist validation with explicit patterns
import re
from dataclasses import dataclass
from typing import Optional

EMAIL_PATTERN = re.compile(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')

def validate_email(email: str) -> Optional[str]:
    if not email or len(email) > 254:
        return None
    if not EMAIL_PATTERN.match(email):
        return None
    return email.lower()

# Good: Schema validation
@dataclass
class CreateUserRequest:
    email: str
    name: str
    age: int

    def validate(self) -> list[str]:
        errors = []
        if not validate_email(self.email):
            errors.append("Invalid email format")
        if not (1 <= len(self.name) <= 100):
            errors.append("Name must be 1-100 characters")
        if not (0 <= self.age <= 150):
            errors.append("Age must be 0-150")
        return errors
```

```python
# Bad: No validation
def create_user(data: dict):
    user = User(
        email=data["email"],      # Could be anything
        name=data["name"],        # Could be empty or huge
        age=data["age"]           # Could be negative or string
    )
    db.save(user)
```

---

## Injection Prevention

### SQL Injection

| Approach | Security | Example |
| :--- | :--- | :--- |
| **Parameterized queries** | ✓ Safe | `WHERE id = ?` with bound params |
| **ORMs with bound params** | ✓ Safe | `User.find_by(id: params[:id])` |
| **String concatenation** | ✗ Vulnerable | `"WHERE id = " + user_id` |
| **f-strings/interpolation** | ✗ Vulnerable | `f"WHERE id = {user_id}"` |

```python
# Good: Parameterized query
cursor.execute(
    "SELECT * FROM users WHERE email = %s AND status = %s",
    (email, status)
)

# Good: ORM with safe querying
User.objects.filter(email=email, status=status)
```

```python
# Bad: String interpolation (SQL injection vulnerable)
cursor.execute(f"SELECT * FROM users WHERE email = '{email}'")

# Bad: String concatenation
query = "SELECT * FROM users WHERE id = " + user_id
```

### Command Injection

```python
# Good: Use library functions, avoid shell
import subprocess
subprocess.run(["ls", "-la", directory], shell=False, check=True)

# Good: Allowlist permitted commands
ALLOWED_COMMANDS = {"list": ["ls", "-la"], "disk": ["df", "-h"]}
def run_command(name: str) -> str:
    if name not in ALLOWED_COMMANDS:
        raise ValueError(f"Command not allowed: {name}")
    return subprocess.check_output(ALLOWED_COMMANDS[name])
```

```python
# Bad: Shell injection vulnerable
os.system(f"ls -la {user_provided_path}")

# Bad: Unsanitized input to shell
subprocess.run(f"convert {filename} output.png", shell=True)
```

### XSS Prevention

```python
# Good: Context-aware encoding
from markupsafe import escape

def render_username(username: str) -> str:
    return f"<span class='user'>{escape(username)}</span>"

# Good: Use templating engine with auto-escaping
# Jinja2, React, Vue all auto-escape by default
```

```html
<!-- Bad: Unescaped user input -->
<div>Welcome, {{ user.name | safe }}</div>  <!-- 'safe' disables escaping -->

<!-- Bad: innerHTML with user data -->
<script>
  element.innerHTML = userProvidedContent;  // XSS vector
</script>
```

---

## Authentication & Authorization

### Authentication Patterns

| Pattern | Use Case | Implementation |
| :--- | :--- | :--- |
| Password hashing | User passwords | bcrypt, Argon2 (never MD5/SHA1) |
| Token validation | API access | JWT with signature verification |
| Session management | Web apps | Secure, HttpOnly, SameSite cookies |
| MFA | High-security | TOTP, WebAuthn |

```python
# Good: Secure password hashing
import bcrypt

def hash_password(password: str) -> bytes:
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt(rounds=12))

def verify_password(password: str, hashed: bytes) -> bool:
    return bcrypt.checkpw(password.encode(), hashed)
```

```python
# Bad: Insecure hashing
import hashlib
hashed = hashlib.md5(password.encode()).hexdigest()  # Weak, no salt
```

### Authorization Patterns

```python
# Good: Explicit authorization check on every request
def get_document(user: User, document_id: str) -> Document:
    document = Document.find(document_id)
    if document is None:
        raise NotFoundError()

    # Check user has access
    if not user.can_access(document):
        raise ForbiddenError()  # Don't reveal existence

    return document
```

```python
# Bad: Trusting client-provided ownership
def get_document(document_id: str, user_id: str) -> Document:
    # user_id comes from client - can be forged!
    return Document.find(document_id)
```

### Secure Cookie Settings

| Attribute | Value | Purpose |
| :--- | :--- | :--- |
| `HttpOnly` | `true` | Prevents JavaScript access |
| `Secure` | `true` | HTTPS only |
| `SameSite` | `Strict` or `Lax` | CSRF protection |
| `Max-Age` | Session-appropriate | Limits exposure window |

---

## Data Protection

### Sensitive Data Handling

| Data Type | Protection | Example |
| :--- | :--- | :--- |
| Passwords | Hash with bcrypt/Argon2 | Never store plaintext |
| API keys | Encrypt at rest | Use secret manager |
| PII | Minimize collection | Only store what's needed |
| Financial | Encrypt + audit log | Track all access |

### Logging Safety

```python
# Good: Redact sensitive fields before logging
def sanitize_for_logging(data: dict) -> dict:
    sensitive_keys = {"password", "token", "api_key", "ssn", "credit_card"}
    return {
        k: "[REDACTED]" if k.lower() in sensitive_keys else v
        for k, v in data.items()
    }

logger.info("User login attempt", extra=sanitize_for_logging(request_data))
```

```python
# Bad: Logging sensitive data
logger.info(f"Login attempt with password: {password}")  # Exposed in logs
```

---

## Error Handling

### Secure Error Responses

| Audience | Detail Level | Example |
| :--- | :--- | :--- |
| End user | Generic message | "Something went wrong" |
| Logs | Full technical detail | Stack trace, context |
| Monitoring | Structured error codes | `ERR_AUTH_FAILED` |

```python
# Good: Generic user message, detailed internal log
try:
    result = process_payment(order)
except PaymentError as e:
    logger.error("Payment failed", exc_info=True, extra={
        "order_id": order.id,
        "error_code": e.code
    })
    raise HTTPException(
        status_code=400,
        detail="Payment could not be processed"  # Generic
    )
```

```python
# Bad: Exposing internal details
except Exception as e:
    return {"error": str(e), "stack": traceback.format_exc()}  # Info leak
```

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| :--- | :--- | :--- |
| **String concatenation in queries** | SQL injection | Parameterized queries |
| **`eval()` on user input** | Code execution | Never use eval with untrusted data |
| **Disabled SSL verification** | MITM attacks | Always verify certificates |
| **`shell=True` with user input** | Command injection | Use subprocess with list args |
| **Custom crypto** | Weak implementation | Use established libraries |
| **Storing passwords in plaintext** | Credential theft | bcrypt/Argon2 hashing |
| **Same error for all failures** | No debuggability | Log details internally |
| **Trusting client-side validation** | Bypass via API | Validate on server |

---

## Verification

### Security Testing

| Test Type | Purpose | Tools |
| :--- | :--- | :--- |
| SAST | Static code analysis | Semgrep, Bandit, CodeQL |
| DAST | Runtime vulnerability scanning | OWASP ZAP, Burp Suite |
| Dependency scan | Known CVEs | Dependabot, Snyk |
| Penetration testing | Real-world attack simulation | Manual + automated |

### Checklist

- [ ] All user input validated and sanitized
- [ ] All database queries use parameterized statements
- [ ] All output encoded for its context (HTML, URL, JS)
- [ ] Authentication on protected endpoints
- [ ] Authorization checked for every resource access
- [ ] Passwords hashed with bcrypt/Argon2
- [ ] Sensitive data not logged
- [ ] Error messages don't expose internals
- [ ] HTTPS enforced, secure cookie flags set

---

## See Also

- [Security Boundaries](../security-boundaries/security-boundaries.md) – Security requirements for AI development
- [Secrets & Configuration Management](../secrets-configuration/secrets-configuration.md) – Handling secrets securely
- [Error Handling](../error-handling/error-handling.md) – Handling errors gracefully
- [Code Review for AI Output](../code-review-ai/code-review-ai.md) – Reviewing AI-generated code
