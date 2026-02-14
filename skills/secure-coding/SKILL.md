---
name: secure-coding
description: Use when writing security-sensitive code, handling authentication, processing user input, or managing secrets
---

# Secure Coding

**Announce at start:** "Following the secure-coding skill for security-sensitive work."

## OWASP Top 10 Quick Check

Before submitting security-sensitive code, verify against these categories:

- [ ] **Injection** — parameterized queries, no string concatenation for SQL/commands
- [ ] **Broken Auth** — secure session management, strong password hashing
- [ ] **Sensitive Data** — encryption at rest and in transit, no PII in logs
- [ ] **XXE** — disable external entity processing in XML parsers
- [ ] **Broken Access Control** — authorization checks on every endpoint
- [ ] **Misconfig** — no default credentials, security headers present
- [ ] **XSS** — output encoding, CSP headers
- [ ] **Insecure Deserialization** — validate and sanitize before deserializing
- [ ] **Known Vulnerabilities** — dependencies up to date, no known CVEs
- [ ] **Insufficient Logging** — log security events, never log secrets

## Input Validation

All user input is untrusted. Validate everything.

| Rule | Example |
| --- | --- |
| **Allowlist over denylist** | Accept known-good patterns, reject everything else |
| **Validate type, length, range** | `age: int, 0-150` not just `age: any` |
| **Sanitize before use** | Escape HTML before rendering, parameterize SQL |
| **Validate on the server** | Client-side validation is for UX, not security |

## Secret Handling

| Do | Don't |
| --- | --- |
| Use environment variables or secret managers | Hardcode secrets in source |
| Rotate secrets regularly | Share secrets in chat/email |
| Use different secrets per environment | Reuse production secrets in dev |
| Add secret files to `.gitignore` | Commit `.env` files |

## Security Review Triggers

Request a security-focused review when changes touch:

| Area | Why |
| --- | --- |
| Authentication/authorization | Identity and access control |
| Payment processing | Financial data |
| File uploads | Path traversal, malware |
| API endpoints | Injection, rate limiting |
| Cryptography | Algorithm choice, key management |
| External service integration | Trust boundary crossing |

## When to Escalate

**Always escalate to a human for:**

- Cryptographic algorithm selection
- Authentication flow design
- Access control policy changes
- Secret rotation procedures
- Security incident response

## Related Skills

| When | Invoke |
| --- | --- |
| Security code needs review | [code-review](../code-review/SKILL.md) |
| Need to test security controls | [testing](../testing/SKILL.md) |
| Ready to submit security changes | [pr-writing](../pr-writing/SKILL.md) |

## Deep Reference

For principles, rationale, anti-patterns, and examples:

- `guides/secure-coding/secure-coding.md`
- `guides/security-boundaries/security-boundaries.md`
