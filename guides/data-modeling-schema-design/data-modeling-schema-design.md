# Data Modeling & Schema Design

Best practices for modeling data structures that reflect domain rules, evolve safely, and stay aligned with APIs, queries, and ownership boundaries.

> **Scope**: Covers domain modeling, relational and document schema design, normalization trade-offs, schema evolution, ownership boundaries, and alignment between storage models and public interfaces. Applies to databases, events, APIs, and internal data contracts.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Model from Business Concepts](#model-from-business-concepts) |
| [Normalization and Denormalization](#normalization-and-denormalization) |
| [Schema Evolution](#schema-evolution) |
| [Ownership Boundaries](#ownership-boundaries) |
| [API Model Alignment](#api-model-alignment) |
| [Anti-Patterns](#anti-patterns) |
| [Red Flags](#red-flags) |
| [Checklist](#checklist) |
| [See Also](#see-also) |

---

## Quick Reference

| Topic | Prefer | Avoid |
| --- | --- | --- |
| **Entity design** | Stable business concepts with clear invariants | Tables shaped around one screen or report |
| **Normalization** | Normalize writes first, denormalize with purpose | Duplicating fields everywhere for convenience |
| **Evolution** | Additive changes and documented migrations | Silent column reuse or meaning changes |
| **Ownership** | One team or service owns each source of truth | Shared writes across many systems |
| **API alignment** | Separate storage model from public response model | Reusing DB rows as the API contract |

| Rule | Rationale |
| --- | --- |
| Model invariants before indexes and endpoints | Domain truth should drive storage shape |
| Store facts once, derive views elsewhere | Duplication creates drift and conflicting updates |
| Denormalize only for a measured read need | Premature denormalization grows write complexity |
| Keep lifecycle and ownership explicit | Unowned data rots fastest |
| Design for change from day one | Schemas outlive the original feature request |

---

## Core Principles

1. **Business concepts first** — Name entities and relationships after the domain, not the current UI.
2. **Source of truth is singular** — One place owns mutable facts; everything else is projection.
3. **Change should be additive when possible** — Add new fields and migrate consumers before removing old ones.
4. **Ownership is part of the schema** — Every table, collection, or contract should have a clear owner.
5. **Storage and presentation are different concerns** — Keep DB models, event models, and API models intentionally distinct.

---

## Model from Business Concepts

Start with nouns, identities, and invariants before designing tables or documents.

| Question | Why it matters |
| --- | --- |
| What are the stable entities? | Defines durable IDs and boundaries |
| What must always be true? | Drives constraints and validation |
| What changes often vs rarely? | Informs table splitting and indexes |
| What is derived rather than stored? | Prevents inconsistent copies |
| Who owns writes to this entity? | Prevents conflicting updates |

**Bad: schema shaped around one UI page**

```sql
CREATE TABLE dashboard_data (
  row_id BIGSERIAL PRIMARY KEY,
  customer_name TEXT,
  customer_email TEXT,
  latest_order_id TEXT,
  latest_order_total NUMERIC,
  latest_order_status TEXT,
  account_manager_name TEXT
);
```

**Good: entities and relationships reflect domain concepts**

```sql
CREATE TABLE customers (
  customer_id UUID PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  full_name TEXT NOT NULL
);

CREATE TABLE orders (
  order_id UUID PRIMARY KEY,
  customer_id UUID NOT NULL REFERENCES customers(customer_id),
  status TEXT NOT NULL,
  total_amount_cents BIGINT NOT NULL
);
```

| Modeling signal | Guidance |
| --- | --- |
| Same field repeated in many tables | Move it to the owning entity |
| Record needs many nullable columns for unrelated states | Split by lifecycle or subtype |
| "Latest" or "current" fields dominate the design | Consider a projection or read model |

---

## Normalization and Denormalization

Normalize transactional writes first. Denormalize only with a measured reason.

| Pattern | Use when | Trade-off |
| --- | --- | --- |
| **Normalized write model** | Multiple updates, strong consistency, clear ownership | More joins on reads |
| **Materialized read model** | High-volume reads, dashboards, search | Extra projection or sync logic |
| **Embedded document** | Child data has same lifecycle and no separate query needs | Harder independent updates |
| **Duplicated field** | Read path needs it and drift is actively managed | Write complexity rises |

| Denormalize only if... | Evidence |
| --- | --- |
| Join-heavy read is proven hot | Query profile or latency budget |
| Projection can be rebuilt safely | Replay or backfill plan exists |
| Duplication owner is explicit | One pipeline updates the copy |

---

## Schema Evolution

| Change type | Safe pattern | Unsafe pattern |
| --- | --- | --- |
| **Add field** | Add nullable or defaulted field, backfill later | Add required field with no migration path |
| **Rename field** | Add new field, dual-write, migrate readers, remove old field later | Reuse existing field name with new meaning |
| **Split entity** | Create new table/collection, backfill, cut traffic gradually | Hard cut with no compatibility window |
| **Delete field** | Prove no readers remain, then remove | Drop based on assumption |

| Evolution rule | Rationale |
| --- | --- |
| Never change the meaning of an existing field silently | Historical data becomes ambiguous |
| Keep migrations traceable | Operators need to reconstruct how data changed |
| Plan backfills as first-class work | Schema changes are not done when DDL merges |

---

## Ownership Boundaries

| Boundary question | Good answer |
| --- | --- |
| Who owns writes? | One service or team |
| Who may read directly? | Enumerated consumers with clear contract |
| Which fields are authoritative? | Named source of truth |
| How are derivatives rebuilt? | Replay, batch job, or migration plan |

| Boundary pattern | Benefit |
| --- | --- |
| **Write owner + published contract** | Consumers depend on stable interfaces, not private tables |
| **Read model owned by consumer** | Producer stays simple; consumer tunes for local queries |
| **Explicit foreign keys or references** | Relationships remain visible and auditable |

---

## API Model Alignment

APIs should reflect product needs, not leak storage shape directly.

**Bad: database row reused as public API**

```typescript
type UserRow = {
  user_id: string
  password_hash: string
  deleted_at: string | null
  marketing_opt_in: 0 | 1
}

export type UserResponse = UserRow
```

**Good: explicit translation from storage to response model**

```typescript
type UserRecord = {
  user_id: string
  password_hash: string
  deleted_at: string | null
  marketing_opt_in: 0 | 1
}

type UserResponse = {
  id: string
  isDeleted: boolean
  marketingOptIn: boolean
}

function presentUser(record: UserRecord): UserResponse {
  return {
    id: record.user_id,
    isDeleted: record.deleted_at !== null,
    marketingOptIn: record.marketing_opt_in === 1,
  }
}
```

| Alignment rule | Why |
| --- | --- |
| Translate storage names and types at the boundary | Prevents storage churn from breaking consumers |
| Do not expose internal flags blindly | Some persistence fields are operational, not product-facing |
| Keep event and API contracts separate from DB schema | Different audiences have different stability needs |

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| --- | --- | --- |
| **Screen-first schema** | Storage shape changes every time the UI changes | Model durable entities, then project views |
| **Everything embedded** | Updates and queries become brittle | Embed only when lifecycle is shared |
| **Meaningful null soup** | Hard to enforce invariants | Split states or use subtype tables/documents |
| **Reusing storage models everywhere** | DB decisions leak into APIs and events | Translate at boundaries |
| **Unowned denormalization** | Copies drift with no repair path | Assign an owner and rebuild strategy |

---

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| Same business field appears in many writable places | Re-establish one source of truth | Multiple writable copies drift |
| New schema proposal starts with column names, not domain entities | Step back and model the business concepts first | Column-first design bakes in accidental structure |
| A required field is added with no backfill or default strategy | Block rollout until evolution plan exists | Existing rows and consumers will break |
| API response mirrors internal table names exactly | Add a boundary translation layer | Public contracts should not depend on private storage |
| No team can answer who owns a table or collection | Assign ownership before expanding usage | Unowned data becomes operational debt |

---

## Checklist

- [ ] Entities and relationships are named after business concepts
- [ ] Source of truth is singular for every mutable fact
- [ ] Denormalization has a measured reason and owner
- [ ] Schema evolution path is documented for every breaking change
- [ ] Public API and event contracts do not leak raw storage models
- [ ] Ownership boundaries are explicit

---

## See Also

- [Database Migrations & Drift](../database-migrations-drift/database-migrations-drift.md) — Safe schema evolution
- [Database Indexing](../database-indexing/database-indexing.md) — Query-driven index design
- [API Design](../api-design/api-design.md) — Boundary contracts and compatibility
- [Codebase Organization](../codebase-organization/codebase-organization.md) — Ownership and module boundaries
