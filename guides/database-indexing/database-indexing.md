# Database Indexing Patterns

Best practices for AI agents on designing, implementing, and optimizing database indexes.

> **Scope**: Applies to relational (PostgreSQL, MySQL) and NoSQL (MongoDB, DynamoDB) indexing strategies.
> Goal: Balance query performance with write overhead and storage costs.

## Contents

| Section |
| :--- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Index Types](#index-types) |
| [Query Analysis](#query-analysis) |
| [Optimization Strategies](#optimization-strategies) |
| [Maintenance](#maintenance) |
| [Anti-Patterns](#anti-patterns) |

---

## Quick Reference

| Category | Guidance | Rationale |
| :--- | :--- | :--- |
| **Always** | Index foreign keys | Prevents slow join operations |
| **Always** | Profile queries before indexing | Prevents unnecessary indexes |
| **Always** | Use partial indexes where possible | Reduces index size and write cost |
| **Prefer** | Composite indexes for filtering | Multi-column filtering is faster |
| **Never** | Index high-cardinality columns blindly | Increases write latency significantly |
| **Never** | Use indexes on small tables | Sequential scan is faster for small sets |

---

## Core Principles

1. **Read-Write balance** – Every index speeds up reads but slows down writes.
2. **Cardinality awareness** – Indexes work best on columns with many unique values.
3. **Selectivity** – An index that filters 99% of rows is better than one filtering 5%.
4. **Coverage** – Design indexes that cover the most frequent queries.
5. **Cost of ownership** – Monitor index size and maintenance overhead (bloat).

---

## Index Types

| Type | When to Use | Example |
| :--- | :--- | :--- |
| **B-Tree** | Equality, Range, Sorting | Primary keys, timestamps |
| **Hash** | Exact equality only | Equality-only lookups |
| **GIN** | Full-text, JSONB, Arrays | Search tags, logs |
| **GiST** | Geometric, Nearest neighbor | Geospatial coordinates |
| **Partial** | Subset of data | `WHERE status = 'active'` |

---

## Query Analysis

Never index without investigating.

1. **EXPLAIN ANALYZE** – Understand how the database plans and executes the query.
2. **Identification** – Find sequential scans on large tables.
3. **Review** – Check filter conditions (`WHERE`) and join conditions (`ON`).
4. **Verification** – Run `EXPLAIN` again after adding the index.

---

## Optimization Strategies

| Strategy | Pattern | Impact |
| :--- | :--- | :--- |
| **Composite** | `(col_a, col_b)` | Speeds up multi-column filters |
| **Covering** | `INCLUDE (col_c)` | Prevents table lookups (Read-only) |
| **Ordering** | `(timestamp DESC)` | Optimizes `ORDER BY` and `LIMIT` |
| **Expression** | `LOWER(email)` | Indexes the result of a function |

---

## Maintenance

| Action | Rationale |
| :--- | :--- |
| **Identify unused** | Remove indexes that aren't being queried |
| **Reindex** | Fix index bloat (common in PostgreSQL) |
| **Monitor size** | Prevent indexes from exceeding RAM capacity |
| **Concurrent** | Always create/drop indexes `CONCURRENTLY` in prod |

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| :--- | :--- | :--- |
| **Index everything** | Massive write latency | Index only critical query paths |
| **Duplicate indexes** | Wastes disk and RAM | Remove redundant overlapping indexes |
| **Wrong order** | Composite index is ignored | Put most selective column first |
| **Functions** | Bypasses standard index | Use expression index or avoid functions |
| **Low cardinality** | Sequential scan is faster | Don't index booleans or small enums |

---

## See Also

- [Observability Patterns](../observability-patterns/observability-patterns.md) – Tracking query performance
- [Architecture for AI](../architecture-for-ai/architecture-for-ai.md) – Data modeling
- [Resilience Patterns](../resilience-patterns/resilience-patterns.md) – Handling slow queries
