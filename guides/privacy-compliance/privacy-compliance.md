# Privacy & Compliance

Guidelines for building systems that respect user privacy and meet regulatory requirements by design.

> **Scope**: Applies to any system handling personal data. Agents must treat privacy as a first-class requirement, not an afterthought.

## Contents

| Section |
| --- |
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
| --- | --- | --- |
| **Always** | Classify data before collecting | Know what requires protection |
| **Always** | Document purpose for each data field | Regulatory requirement |
| **Always** | Apply retention policies | Don't keep data forever |
| **Always** | Log access to PII | Audit trails for compliance |
| **Prefer** | Pseudonymization over raw PII | Reduces risk if breached |
| **Prefer** | Server-side over client-side storage for PII | Central control |
| **Never** | Collect data without stated purpose | Violates data minimization |
| **Never** | Store payment card data directly | Use tokenization/PCI-compliant providers |

---

## Core Principles

| Principle | Guideline | Rationale |
| --- | --- | --- |
| **Privacy by Design** | Build privacy in from the start | Cheaper than retrofitting |
| **Data minimization** | Collect only what's needed | Less data = less risk |
| **Purpose limitation** | Use data only for stated purpose | Regulatory requirement |
| **Retention limits** | Delete when no longer needed | Reduces liability |
| **Transparency** | Users know what data you have | Trust and compliance |

---

## Data Classification

### Classification Levels

| Level | Definition | Examples | Handling |
| --- | --- | --- | --- |
| **Public** | No restrictions | Marketing content | Standard handling |
| **Internal** | Business-only access | Employee lists | Access controls |
| **Confidential** | Sensitive business data | Financial reports | Encryption at rest |
| **Restricted/PII** | Personal or regulated data | SSN, health records | Encryption + audit |

### PII Identification

| Category | Examples | Special Handling |
| --- | --- | --- |
| **Direct identifiers** | Name, email, SSN, phone | Always restricted |
| **Indirect identifiers** | IP address, device ID, location | May be PII in context |
| **Sensitive PII** | Health, race, religion, biometrics | Highest protection |
| **Financial** | Bank accounts, card numbers | PCI-DSS compliance |

---

## Collection & Consent

### Consent Requirements

| Data Type | Consent Model | Implementation |
| --- | --- | --- |
| Essential (contract) | Implicit | Terms of service |
| Analytics | Opt-out | Cookie banner |
| Marketing | Opt-in | Checkbox, unchecked by default |
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
| --- | --- | --- |
| At rest | AES-256 | Database encryption, encrypted volumes |
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
| --- | --- | --- |
| Display | Partial masking | `****1234` |
| Analytics | Pseudonymization | Hash of user ID |
| Logs | Redaction | `[REDACTED]` |
| Dev/Test | Synthetic data | Faker-generated |

---

## Data Subject Rights

### Required Capabilities

| Right | Description | Implementation |
| --- | --- | --- |
| **Access** | User can request their data | Export endpoint |
| **Rectification** | User can correct data | Edit functionality |
| **Erasure** | "Right to be forgotten" | Delete cascade |
| **Portability** | Machine-readable export | JSON/CSV export |
| **Objection** | Opt out of processing | Consent withdrawal |

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
| --- | --- | --- |
| **GDPR** | EU residents | Consent, DPO, 72h breach notification |
| **CCPA/CPRA** | California residents | Disclosure, opt-out of sale |
| **HIPAA** | US health data | PHI protection, BAAs |
| **PCI-DSS** | Card data | Tokenization, audit, network security |
| **SOC 2** | Service providers | Trust principles, controls |

### Compliance Checklist

- [ ] Data inventory documented
- [ ] Privacy policy published
- [ ] Consent mechanisms implemented
- [ ] Data subject request process defined
- [ ] Breach notification procedure documented
- [ ] Vendor DPAs in place
- [ ] Retention periods configured
- [ ] Access logging enabled

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| --- | --- | --- |
| **Collect everything** | Data liability | Collect only what's needed |
| **Keep forever** | Increases breach impact | Enforce retention limits |
| **PII in logs** | Compliance violation | Redact before logging |
| **PII in URLs** | Cached, logged everywhere | Use POST, request body |
| **No access logging** | Can't audit or investigate | Log all PII access |
| **Dev uses prod data** | Unnecessary exposure | Use synthetic data |
| **Email as identifier** | Hard to change | Use opaque user IDs |

---

## See Also

- [Secure Coding](../secure-coding/secure-coding.md) – Security implementation patterns
- [Secrets & Configuration](../secrets-configuration/secrets-configuration.md) – Protecting credentials
- [Logging Practices](../logging-practices/logging-practices.md) – Safe logging
