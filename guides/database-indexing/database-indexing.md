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

| Principle | Guideline | Rationale |
| :--- | :--- | :--- |
| **Read-Write balance** | Evaluate write cost before adding any index | Every index speeds up reads but slows down writes |
| **Cardinality awareness** | Index columns with many unique values | Low-cardinality indexes waste space without benefit |
| **Selectivity** | Prefer indexes that filter out most rows | An index filtering 99% of rows is far more useful than one filtering 5% |
| **Coverage** | Design indexes for the most frequent queries | Unused indexes cost writes without improving reads |
| **Cost of ownership** | Monitor index size and maintenance overhead | Index bloat degrades performance over time |

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

### Examples

**Good: Analyze before indexing**

```sql
-- Before: Sequential scan on large table
EXPLAIN ANALYZE
SELECT * FROM orders
WHERE customer_id = 12345 AND status = 'pending';

-- Output shows: Seq Scan on orders (cost=0.00..1234567.00 rows=50)

-- Add composite index
CREATE INDEX CONCURRENTLY idx_orders_customer_status
ON orders(customer_id, status);

-- After: Index scan
EXPLAIN ANALYZE
SELECT * FROM orders
WHERE customer_id = 12345 AND status = 'pending';

-- Output shows: Index Scan using idx_orders_customer_status (cost=0.42..12.45 rows=50)
```

**Bad: Index without analysis**

```sql
-- "Slow queries? Index everything!"
CREATE INDEX idx_orders_col1 ON orders(col1);
CREATE INDEX idx_orders_col2 ON orders(col2);
CREATE INDEX idx_orders_col3 ON orders(col3);
-- Result: Write performance tanks, most indexes unused
```

**Good: Partial index for subset**

```sql
-- Only index active users (90% of queries)
CREATE INDEX idx_users_active_email
ON users(email)
WHERE status = 'active';

-- Query uses index
SELECT * FROM users WHERE email = 'user@example.com' AND status = 'active';
```

**Bad: Full index for rare queries**

```sql
-- Indexes ALL users including 99% inactive accounts
CREATE INDEX idx_users_email ON users(email);
-- Wastes space on rows never queried
```

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

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| Query doing a full table scan on a million+ row table | Add an index on the filter/join columns | Full scans on large tables cause timeouts and lock contention |
| Index on every column "just in case" | Remove unused indexes — they slow writes | Each index costs write performance and storage |
| Composite index with columns in wrong order | Put highest-selectivity columns first | Wrong column order makes the index useless for the query |
| No `EXPLAIN` analysis before adding an index | Run `EXPLAIN` to verify the index is actually used | Unused indexes waste resources without improving query speed |

---

## See Also

- [Observability Patterns](../observability-patterns/observability-patterns.md) – Tracking query performance
- [Architecture for AI](../architecture-for-ai/architecture-for-ai.md) – Data modeling
- [Resilience Patterns](../resilience-patterns/resilience-patterns.md) – Handling slow queries
- [Performance Engineering](../performance-engineering/performance-engineering.md) – Query optimization and profiling
