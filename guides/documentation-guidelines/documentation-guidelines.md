# Documentation Guidelines for AI Agents

Best practices for AI agents on when and how to write documentation—READMEs, API docs, architectural decisions, and inline documentation.

> **Scope**: These guidelines are for AI agents performing coding tasks. Focus on documentation that provides value; avoid generating filler content.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [README Structure](#readme-structure) |
| [API Documentation](#api-documentation) |
| [Architectural Decision Records (ADRs)](#architectural-decision-records-adrs) |
| [Inline Documentation](#inline-documentation) |
| [Configuration Documentation](#configuration-documentation) |
| [Changelogs](#changelogs) |
| [Planning Documentation](#planning-documentation) |
| [Documentation Maintenance](#documentation-maintenance) |
| [What NOT to Document](#what-not-to-document) |
| [Anti-Patterns](#anti-patterns) |
| [Documentation Quality Checklist](#documentation-quality-checklist) |

---

## Quick Reference

| Always Document | Rationale |
| --- | --- |
| **Project Setup** | README must explain how to run/build/test to be actionable. |
| **API Contracts** | Public interfaces require explicit definitions for consumers. |
| **Architecture** | ADRs prevent regression by explaining "why" decisions were made. |
| **Environment** | Required dependencies must be stated to avoid setup failure. |
| **Breaking Changes** | Changes in behavior necessitate migration paths for users. |

| Don't Document | Rationale |
| --- | --- |
| **Obvious Logic** | Self-documenting code reduces noise and maintenance burden. |
| **Volatile Details** | Internal implementation that changes frequently leads to stale docs. |
| **Duplicates** | Multiple sources of truth lead to information drift and confusion. |
| **Aspirations** | Documenting what doesn't exist misleads users and developers. |

| Priority Order | Item | Rationale |
| :---: | --- | --- |
| **1** | **Working Code** | Functionality is the primary value; docs are supporting assets. |
| **2** | **Accurate Docs** | Misleading documentation is more harmful than missing documentation. |
| **3** | **Single Source** | Centralized truth ensures consistency across the codebase. |

---

## Core Principles

| Principle | Rationale |
| --- | --- |
| **Stability First** | Focus documentation on stable interfaces to reduce update frequency. |
| **Single Source** | Reference existing docs instead of duplicating to prevent drift. |
| **Recency Over Scope** | Keeping small docs updated is better than having large, stale ones. |
| **Document "Why"** | Code shows *what* but documentation explains *why* choices were made. |
| **Audience Target** | Tailoring detail level to the user (e.g., dev vs. end-user) improves utility. |

---

## README Structure

### Minimum Viable README

Every project needs at least:

```markdown
# Project Name

Brief description of what this project does.

## Quick Start

```bash
# Install
npm install

# Run
npm start

# Test
npm test
```

## Usage

[Basic usage example or link to docs]

```

### Full README Template

```markdown
# Project Name

One-paragraph description of what this does and why it exists.

### Getting Started

```bash
npm install
npm start
```

### Prerequisites

| Requirement | Minimum Version | Rationale |
| --- | --- | --- |
| **Node.js** | 20+ | Required for modern runtime features and ESM support. |
| **PostgreSQL** | 15+ | Necessary for advanced JSONB performance and security. |

### Installation

[Step-by-step setup instructions]

### Usage Examples

[Basic examples of how to use]

### Settings Configuration

| Variable | Description | Default | Rationale |
| --- | --- | --- | --- |
| `PORT` | Server port | `3000` | Standardizes web server entry point. |
| `DATABASE_URL` | DB connection | Required | Core dependency for state management. |

### Development Setup

```bash
npm run dev      # Start with hot reload
npm test         # Run tests
npm run lint     # Check code style
```

### Architecture Overview

[Brief overview or link to detailed docs]

### Contributing

[Contribution guidelines or link to CONTRIBUTING.md]

[License type]

```

### What Belongs in README vs Elsewhere

| Content | Location | Rationale |
| --- | --- | --- |
| **Overview** | README | Sets context for anyone visiting the repository. |
| **Quick Start** | README | Minimizes "time to hello world" for new developers. |
| **API Docs** | `docs/` or Auto-gen | Handles complexity without cluttering the landing page. |
| **Decisions** | `docs/adr/` | Records immutable history of architectural trade-offs. |
| **Contributing** | `CONTRIBUTING.md` | Separates project usage from project development rules. |
| **Changelog** | `CHANGELOG.md` | Provides a dedicated timeline of versioned changes. |
| **Config** | README / `config/` | Ensures environment setup is visible but detailed. |
| **Tutorials** | `docs/tutorials/` | Provides deep-dive learning paths away from reference material. |

---

## API Documentation

### When to Document APIs

| API Type | Level | Rationale |
| --- | --- | --- |
| **Public Library** | Comprehensive | Third-party users cannot see source; requires full contract. |
| **Internal Service** | Endpoint list | Team members need interface details but can read source. |
| **Private Helper** | Minimal | High-churn code; documentation should focus on logic "whys". |
| **Utilities** | None | Obvious string/math helpers should be self-evident. |

### API Doc Structure

```markdown
### Request Pattern

```text
POST /api/resource
```

**Headers**:

| Header | Required | Description | Rationale |
| --- | --- | --- | --- |
| **Authorization** | Yes | Bearer token | Necessary for identity and access control. |
| **Content-Type** | Yes | `application/json` | Defines the payload format for the parser. |

**Body**:

```json
{
  "field": "description of field",
  "optional?": "mark optional fields"
}
```

### Response

**Success (200)**:

```json
{
  "id": "created-resource-id",
  "field": "value"
}
```

**Errors**:

| Status | Meaning | Rationale |
| --- | --- | --- |
| **400** | Invalid body | Client provided data that fails validation schema. |
| **401** | Auth failure | Missing or expired credentials for a protected route. |
| **404** | Not found | The specific resource ID does not exist in the system. |

### curl Example

```bash
curl -X POST https://api.example.com/resource \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"field": "value"}'
```

```

### Code-Level API Docs

Use documentation comments for public functions:

```javascript
/**
 * Processes payment for an order.
 *
 * Validates the order, charges the payment method, and updates
 * order status. Sends confirmation email on success.
 *
 * @param orderId - The order to process
 * @param paymentMethod - Payment method identifier
 * @returns Payment confirmation with transaction ID
 * @throws {OrderNotFoundError} If order doesn't exist
 * @throws {PaymentDeclinedError} If payment fails
 * @throws {InvalidOrderStateError} If order already processed
 */
async function processPayment(orderId, paymentMethod) {
  // ...
}
```

---

## Architectural Decision Records (ADRs)

### When to Write ADRs

| Decision Type | ADR? | Rationale |
| --- | --- | --- |
| **Core Tech** | Yes | Changes to DB/Runtime affect the entire system lifecycle. |
| **Architecture** | Yes | Structural patterns determine long-term maintenance costs. |
| **Breaking API** | Yes | Downstream impacts require formal record of the "why". |
| **Coding Style** | No | Managed by linting tools; doesn't require narrative records. |
| **Dep Updates** | No | Version bumps are recorded in the lockfile/changelog. |
| **Bug Fixes** | No | Fixes are implementation details; ADRs are for designs. |

### ADR Template

```markdown
# ADR-001: Title of Decision

### Status

[Proposed | Accepted | Deprecated | Superseded by ADR-XXX]

### Context

What is the issue that we're seeing that is motivating this decision?

### Decision

What is the change that we're proposing and/or doing?

### Consequences

| Impact | Category | Rationale |
| --- | --- | --- |
| **Positive** | Benefit | Explicitly states the primary gains of the decision. |
| **Negative** | Drawback | Flags technical debt or constraints introduced. |
| **Neutral** | Observation | Notes side effects that aren't strictly good or bad. |
```

### ADR Example

```markdown
# ADR-003: Use PostgreSQL for Primary Database

## Status

Accepted

## Context

We need a database for storing user data and transactions. Requirements:
- ACID compliance for financial transactions
- Support for complex queries
- Horizontal read scaling
- Team familiarity

Options considered:
1. PostgreSQL
2. MySQL
3. MongoDB

## Decision

Use PostgreSQL 15 as the primary database.

## Consequences

### Positive
- Strong ACID compliance
- Excellent query planner
- Team has existing expertise
- Good tooling ecosystem

### Negative
- Requires more upfront schema design
- Horizontal write scaling is complex

### Neutral
- Will need read replicas for scaling reads
```

---

## Inline Documentation

### When Inline Docs Help

| Situation | Approach | Rationale |
| --- | --- | --- |
| **Complex Logic** | Explain approach | Clarifies intent for math or performance-optimized code. |
| **Business Rule** | Reference source | Links implementation to external requirements or tickets. |
| **Constraint** | Explain "why" | Prevents future devs from "fixing" a deliberate limitation. |
| **Workaround** | Link issue/PR | Tracks technical debt for future removal. |

### When to Skip Inline Docs

| Situation | Rationale |
| --- | --- |
| **Clear Code** | Redundant comments add noise and quickly become stale. |
| **Quick Churn** | Implementation details change too fast for documentation. |
| **Standard Pattern** | Common idioms are understood by competent developers. |

See [Commenting Guidelines](../commenting-guidelines/commenting-guidelines.md) for details.

---

## Configuration Documentation

### Environment Variables

| Variable | Required | Description | Rationale |
| :--- | :---: | :--- | --- |
| `DATABASE_URL` | **Yes** | DB connection string | Core link to persistent state. |
| `PORT` | **No** | Server port (3000) | Configures entry point for requests. |
| `LOG_LEVEL` | **No** | Verbosity (info) | Controls noise level in production logs. |
| `API_KEY` | **Yes** | External API key | Authenticates project to upstream services. |

### Example .env

```text
DATABASE_URL=postgres://localhost:5432/myapp_dev
PORT=3000
LOG_LEVEL=debug
```

> [!CAUTION]
> Never commit `.env` files to source control. Use `.env.example` as a template for secrets.

### Configuration File Layout

Configuration is loaded from `config/` directory:

| Setting | Type | Description | Rationale |
| --- | --- | --- | --- |
| `server.port` | `number` | HTTP server port | Defines the port the application listens on. |
| `database.pool` | `number` | Conn pool size | Managed DB resource allocation and limits. |
| `cache.ttl` | `number` | TTL in seconds | Determines how long data stays in memory. |

---

## Changelogs

### Changelog Format

```markdown
# Changelog

All notable changes to this project will be documented in this file.

Format based on [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

### Added
- New feature description

### Changed
- Change description

### Fixed
- Bug fix description

## [1.2.0] - 2024-01-15

### Added
- User profile API endpoint
- Rate limiting middleware

### Changed
- Improved error messages for validation failures

### Fixed
- Memory leak in WebSocket handler

## [1.1.0] - 2024-01-01

...
```

### Changelog Categories

| Category | Usage | Rationale |
| --- | --- | --- |
| **Added** | New features | Informs users of expanded capabilities. |
| **Changed** | Modified logic | Flags behavioral shifts in existing system parts. |
| **Deprecated** | Early warning | Provides a transition period before feature removal. |
| **Removed** | Deletions | Confirms cleanup and breaking changes. |
| **Fixed** | Bug fixes | Tracks resolution of reported or discovered issues. |
| **Security** | Vulnerabilities | Critical updates requiring immediate user attention. |

---

## Planning Documentation

For roadmaps, implementation plans, RFCs, and archiving practices, see [Planning Documentation](../planning-documentation/planning-documentation.md).

---

## Documentation Maintenance

### When to Update Docs

| Event | Documentation Action | Rationale |
| --- | --- | --- |
| **New Feature** | Add usage guide | Enables users to adopt the new capability immediately. |
| **API Change** | Update API contracts | Prevents integration failures for downstream users. |
| **Bug Fix** | Update documented behavior | Corrects misleading info if the bug changed system logic. |
| **Dependency** | Update setup/PRs | Keeps onboarding instructions valid and executable. |
| **Breaking** | Document migration | Reduces friction during major version upgrades. |

### Documentation Debt Signals

| Signal | Problem | Rationale |
| --- | --- | --- |
| **"TODO" tags** | Incomplete context | Signals that logic might be unreliable or unfinished. |
| **Broken Examples** | Out of date | Causes immediate developer frustration during setup. |
| **Version Drift** | Poor maintenance | Undermines trust in the entire documentation suite. |
| **Broken Links** | Neglected paths | Fragments the documentation experience for the reader. |

### Keeping Docs Current

| Practice | Implementation | Rationale |
| :--- | :--- | --- |
| **Review in PR** | Mandatory check | Ensures docs are never an after-thought. |
| **Test Examples** | CI verification | Guarantees that usage snippets stay executable. |
| **In-Repo Docs** | Version with code | Keeps docs logically tied to the implementation version. |
| **Prune Stale** | Delete low-value docs | Removing noise is better than maintaining lies. |

---

## What NOT to Document

### Skip These

| Item | Rationale |
| --- | --- |
| **Internal Implementation** | High volatility makes these docs stale within weeks. |
| **Self-Evident Code** | Obvious function names (e.g., `setUserId`) don't need prose. |
| **Roadmap Features** | Only document what is currently deployable and testable. |
| **Generated Assets** | Built files shouldn't be manually edited or documented here. |

## Anti-Patterns

| Anti-Pattern | Problem | Rationale |
| --- | --- | --- |
| **Mass Documentation** | High noise | Drowns critical info in a sea of trivial details. |
| **Prose Over Code** | Low density | Developers prefer reading patterns over paragraphs. |
| **Manual Sync** | High drift risk | Copying code into docs ensures they will become wrong. |
| **Auto-Filler** | Zero value | JSDoc templates without actual content provide no insight. |
| **No README** | High friction | Prevents any adoption by new developers. |
| **Stale Docs** | Risk of error | Actively misleads and causes system misuse. |
| **Duplication** | Drift | Guarantees that at least one version will eventually be wrong. |
| **Obviousness** | Low signal | Drowns important architectural data in noise. |

---

## Documentation Quality Checklist

| Question | Rationale |
| --- | --- |
| Does this information exist elsewhere? | Prevents documentation drift and "stale data" bugs. |
| Will this stay accurate for long? | Minimizes maintenance burden by avoiding volatility. |
| Who is the intended audience? | Tailors the level of detail to the reader's needs. |
| Can code show this instead? | Examples are more precise and testable than prose. |
| Is this the correct location? | Ensures developers can find info where they expect it. |
| Are instructions executable? | Verified docs build trust and reduce setup time. |

---

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| README setup instructions fail when followed | Fix immediately — test every command | Broken setup docs block every new contributor |
| Same information documented in 3+ places | Consolidate to a single source and link to it | Multiple sources of truth always drift apart |
| API docs describe endpoints that no longer exist | Delete stale entries, audit remaining docs | Stale docs are worse than no docs — they actively mislead |
| "Coming soon" or TODO sections in published docs | Remove or write the content now | Placeholder content signals neglect and erodes trust |
| Code changed but docs not updated in the same PR | Update docs in the same PR as the code change | Deferred doc updates become permanently deferred |

---

## See Also

* [Writing Best Practices](../writing-best-practices/writing-best-practices.md) – Guidelines for writing this documentation
* [Commenting Guidelines](../commenting-guidelines/commenting-guidelines.md) – Inline code comments
* [Documentation Maintenance](../doc-maintenance/doc-maintenance.md) – Keeping docs in sync with code changes
* [API Design](../api-design/api-design.md) – Designing APIs worth documenting
* [PRD for Agents](../prd-for-agents/prd-for-agents.md) – Writing specifications AI can consume
* [Architecture for AI](../architecture-for-ai/architecture-for-ai.md) – System docs that prevent hallucination
