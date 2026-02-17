# Privacy & Compliance

Guidelines for building systems that respect user privacy and meet regulatory requirements by design.

> **Scope**: Applies to any system handling personal data. Agents must treat privacy as a first-class requirement, not
> an afterthought.

## Contents

| Section |
| :--- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Data Classification](#data-classification) |
| [Collection & Consent](#collection--consent) |
| [Storage & Access](#storage--access) |
| [Data Subject Rights](#data-subject-rights) |
| [Regulatory Mapping](#regulatory-mapping) |
| [Anti-Patterns](#anti-patterns) |

---

## Quick Reference

| Category | Guidance | Rationale |
| :--- | :--- | :--- |
| **Always** | Classify data before collecting | Know what requires protection |
| **Always** | Document purpose for each field | Regulatory requirement |
| **Always** | Apply retention policies | Don't keep data forever |
| **Always** | Log access to PII | Audit trails for compliance |
| **Prefer** | Pseudonymization over raw PII | Reduces risk if breached |
| **Prefer** | Server-side over client-side | Central control |
| **Never** | Collect data without purpose | Violates data minimization |
| **Never** | Store payment data directly | Use PCI-compliant providers |

---

## Core Principles

| Principle | Guideline | Rationale |
| :--- | :--- | :--- |
| **Privacy by Design** | Build privacy in from the start | Cheaper than retrofitting |
| **Data minimization** | Collect only what's needed | Less data = less risk |
| **Purpose limitation** | Use only for stated purpose | Regulatory requirement |
| **Retention limits** | Delete when no longer needed | Reduces liability |
| **Transparency** | Users know what data you have | Trust and compliance |

---

## Data Classification

### Classification Levels

| Level | Definition | Examples | Handling |
| :--- | :--- | :--- | :--- |
| **Public** | No restrictions | Marketing content | Standard handling |
| **Internal** | Business-only | Employee lists | Access controls |
| **Confidential** | Sensitive business | Financial reports | Encryption at rest |
| **Restricted/PII** | Personal/regulated | SSN, health | Encryption + audit |

### PII Identification

| Category | Examples | Special Handling |
| :--- | :--- | :--- |
| **Direct** | Name, email, SSN | Always restricted |
| **Indirect** | IP address, location | May be PII in context |
| **Sensitive PII** | Health, religion | Highest protection |
| **Financial** | Bank accounts | PCI-DSS compliance |

---

## Collection & Consent

### Consent Requirements

| Data Type | Consent Model | Implementation |
| :--- | :--- | :--- |
| Essential | Implicit | Terms of service |
| Analytics | Opt-out | Cookie banner |
| Marketing | Opt-in | Checkbox (unchecked) |
| Sensitive PII | Explicit opt-in | Separate consent form |

### Implementation Pattern

```python
# Good: Purpose-bound data collection
class UserRegistration:
    def register(self, data: dict, consents: dict):
        user = User(
            email=data["email"],        # Required for account
            name=data.get("name"),      # Optional
        )

        # Only collect marketing if consented
        if consents.get("marketing"):
            user.marketing_preferences = data.get("preferences")
            user.marketing_consent_date = datetime.now()

        # Log purpose for audit
        audit_log.record(
            action="user_registration",
            data_fields=list(data.keys()),
            consents=consents,
            purpose="account_creation"
        )

        return user
```

---

## Storage & Access

### Encryption Requirements

| Data State | Requirement | Implementation |
| :--- | :--- | :--- |
| At rest | AES-256 | Database encryption |
| In transit | TLS 1.2+ | HTTPS everywhere |
| In use | Minimize exposure | Decrypt only when needed |

### Access Control

```python
# Good: Audit-logged PII access
class UserRepository:
    def get_by_id(self, user_id: str, accessor: str, purpose: str) -> User:
        # Log every PII access
        audit_log.record(
            action="pii_access",
            resource=f"user:{user_id}",
            accessor=accessor,
            purpose=purpose,
            timestamp=datetime.now()
        )

        return self.db.query(User).get(user_id)
```

### Data Masking

| Use Case | Technique | Example |
| :--- | :--- | :--- |
| Display | Partial masking | `****1234` |
| Analytics | Pseudonymization | Hash of user ID |
| Logs | Redaction | `[REDACTED]` |
| Dev/Test | Synthetic data | Faker-generated |

---

## Data Subject Rights

### Required Capabilities

| Right | Description | Implementation |
| :--- | :--- | :--- |
| **Access** | Request their data | Export endpoint |
| **Rectification** | Correct data | Edit functionality |
| **Erasure** | "Right to be forgotten" | Delete cascade |
| **Portability** | Machine-readable export | JSON/CSV export |
| **Objection** | Opt out | Consent withdrawal |

### Erasure Implementation

```python
# Good: Complete deletion with cascade
def delete_user(user_id: str) -> None:
    # Delete from all systems
    user_db.delete(user_id)
    analytics_db.anonymize(user_id)
    logs.redact_user(user_id)
    backups.queue_deletion(user_id)

    # Notify downstream services
    event_bus.publish("user.deleted", {"user_id": user_id})

    # Record for compliance
    deletion_log.record(
        user_id=user_id,
        completed_at=datetime.now(),
        systems=["user_db", "analytics", "logs", "backups"]
    )
```

---

## Regulatory Mapping

| Regulation | Scope | Key Requirements |
| :--- | :--- | :--- |
| **GDPR** | EU residents | Consent, DPO, 72h notification |
| **CCPA/CPRA** | CA residents | Disclosure, opt-out of sale |
| **HIPAA** | US health data | PHI protection, BAAs |
| **PCI-DSS** | Card data | Tokenization, audit |
| **SOC 2** | Service providers | Trust principles, controls |

### Compliance Checklist

- [ ] Data inventory documented
- [ ] Privacy policy published
- [ ] Consent mechanisms implemented
- [ ] Data subject request process defined
- [ ] Breach notification procedure documented
- [ ] Retention periods configured
- [ ] Access logging enabled

---

### Good vs Bad Example

| Pattern | Example | Why |
| :--- | :--- | :--- |
| **Good** | Collect email with stated purpose, retention period, and redacted logs | Meets minimization and auditability requirements |
| **Bad** | Collect birth date "just in case" and log raw PII in app logs | Violates purpose limitation and increases breach impact |

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| :--- | :--- | :--- |
| **Collect everything** | Data liability | Collect only what's needed |
| **Keep forever** | Increases breach impact | Enforce retention limits |
| **PII in logs** | Compliance violation | Redact before logging |
| **PII in URLs** | Cached, logged | Use POST, request body |
| **No access logging** | Can't audit | Log all PII access |
| **Dev uses prod data** | Exposure | Use synthetic data |
| **Email as identifier** | Hard to change | Use opaque user IDs |

---

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| PII (email, name, IP) appearing in application logs | Add redaction filters before logging | Logged PII violates GDPR/CCPA and exposes data to anyone with log access |
| User data collected with no documented purpose | Remove the collection or document the purpose | Data without purpose violates data minimization — a core GDPR principle |
| No data retention policy — data kept indefinitely | Define and enforce retention periods | Unbounded retention increases breach impact and regulatory liability |
| Production database used for development/testing | Use anonymized or synthetic data for dev/test | Dev environments have weaker controls — real PII in dev is a breach risk |
| No mechanism for users to request data deletion | Implement a data subject rights endpoint | "Right to be forgotten" is a legal requirement in GDPR and CCPA |

---

## See Also

- [Secure Coding](../secure-coding/secure-coding.md) – Security implementation patterns
- [Secrets & Configuration](../secrets-configuration/secrets-configuration.md) – Protecting credentials
- [Logging Practices](../logging-practices/logging-practices.md) – Safe logging
