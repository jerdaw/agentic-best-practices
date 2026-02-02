# Database Indexing Strategy

Guidelines for creating indexes that improve query performance without degrading write speed.

> **Scope**: Applies to relational databases (PostgreSQL, MySQL) and document stores. Agents must create targeted indexes based on query patterns, not guesswork.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Index Types](#index-types) |
| [When to Index](#when-to-index) |
| [Index Design](#index-design) |
| [Maintenance](#maintenance) |
| [Anti-Patterns](#anti-patterns) |

---

## Quick Reference

| Category | Guidance | Rationale |
| --- | --- | --- |
| **Always** | Index foreign keys | Enables efficient joins |
| **Always** | Index columns in WHERE clauses | Speeds up filtering |
| **Always** | Monitor slow queries first | Data-driven decisions |
| **Prefer** | Composite indexes for multi-column queries | Single scan |
| **Prefer** | Partial indexes when applicable | Smaller, faster |
| **Never** | Index every column | Slows writes, wastes space |
| **Never** | Guess at indexes | Analyze actual queries |

---

## Core Principles

| Principle | Guideline | Rationale |
| --- | --- | --- |
| **Query-driven** | Index based on actual queries | Not theoretical needs |
| **Selectivity matters** | High-cardinality columns first | Better filtering |
| **Write cost** | Each index slows inserts/updates | Balance read vs write |
| **Measure impact** | EXPLAIN before and after | Verify improvement |
| **Iterative** | Add indexes as patterns emerge | Avoid premature optimization |

---

## Index Types

### Common Index Types

| Type | Use Case | Example |
| --- | --- | --- |
| **B-tree** (default) | Equality, range, sorting | Most queries |
| **Hash** | Equality only | Cache lookups |
| **GIN** | Full-text, arrays, JSONB | Search, document fields |
| **GiST** | Geometric, range types | Location queries |
| **BRIN** | Large, naturally ordered tables | Time-series data |

### Type Selection

```sql
-- B-tree: Range queries (default)
CREATE INDEX idx_orders_date ON orders (created_at);

-- GIN: JSONB containment
CREATE INDEX idx_users_tags ON users USING GIN (tags);

-- BRIN: Time-series, huge tables
CREATE INDEX idx_events_time ON events USING BRIN (timestamp);
```

---

## When to Index

### Index Priority Matrix

| Query Pattern | Priority | Index Type |
| --- | --- | --- |
| Primary key lookup | Auto (PK) | B-tree |
| Foreign key joins | High | B-tree on FK |
| Frequent WHERE column | High | B-tree |
| ORDER BY + LIMIT | High | B-tree (match order) |
| Text search | Medium | GIN/GiST |
| Range scans on large tables | Medium | B-tree or BRIN |
| Low-cardinality columns | Low | Usually skip |

### Query Analysis

```sql
-- Step 1: Identify slow queries
SELECT query, calls, mean_time, total_time
FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 10;

-- Step 2: Analyze query plan
EXPLAIN ANALYZE
SELECT * FROM orders
WHERE customer_id = 123
  AND status = 'pending'
ORDER BY created_at DESC;

-- Look for: Seq Scan, high cost, slow actual time
```

---

## Index Design

### Single vs Composite Indexes

```sql
-- Single column index
CREATE INDEX idx_orders_customer ON orders (customer_id);

-- Composite index for multi-column queries
CREATE INDEX idx_orders_customer_status 
ON orders (customer_id, status);

-- The composite index also covers customer_id-only queries
-- No need for separate single-column index
```

### Column Order Matters

| Query | Best Index |
| --- | --- |
| `WHERE a = ? AND b = ?` | `(a, b)` or `(b, a)` |
| `WHERE a = ? AND b > ?` | `(a, b)` — equality first |
| `WHERE a = ? ORDER BY b` | `(a, b)` — match order |
| `WHERE a > ? AND b = ?` | `(b, a)` — equality first |

```sql
-- Good: Equality column first, then range
CREATE INDEX idx_orders_filter 
ON orders (customer_id, created_at);

-- Supports both:
-- WHERE customer_id = 123
-- WHERE customer_id = 123 AND created_at > '2024-01-01'
```

### Partial Indexes

Index only rows that matter.

```sql
-- Only index active users (smaller, faster)
CREATE INDEX idx_active_users 
ON users (email) 
WHERE status = 'active';

-- Only index recent orders
CREATE INDEX idx_pending_orders 
ON orders (created_at) 
WHERE status = 'pending';
```

### Covering Indexes

Include columns to avoid table lookup.

```sql
-- Covering index: all needed columns in index
CREATE INDEX idx_orders_summary 
ON orders (customer_id) 
INCLUDE (total, status, created_at);

-- Query satisfied entirely from index (index-only scan)
SELECT total, status, created_at 
FROM orders 
WHERE customer_id = 123;
```

---

## Maintenance

### Monitoring Index Usage

```sql
-- Find unused indexes (PostgreSQL)
SELECT schemaname, tablename, indexname, idx_scan
FROM pg_stat_user_indexes
WHERE idx_scan = 0
  AND indexrelname NOT LIKE '%_pkey';

-- Find duplicate indexes
SELECT pg_size_pretty(sum(pg_relation_size(idx))::bigint) as size,
       (array_agg(idx))[1] as idx1, (array_agg(idx))[2] as idx2,
       indkey
FROM (
  SELECT indexrelid::regclass as idx, indrelid, indkey
  FROM pg_index
) sub
GROUP BY indrelid, indkey
HAVING count(*) > 1;
```

### Index Maintenance Tasks

| Task | Frequency | Command |
| --- | --- | --- |
| Reindex bloated indexes | Weekly/monthly | `REINDEX INDEX idx_name` |
| Analyze statistics | After bulk loads | `ANALYZE table_name` |
| Review unused indexes | Monthly | Drop if unused |
| Check index bloat | Monthly | `pgstattuple` extension |

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| --- | --- | --- |
| **Index everything** | Slow writes, wasted space | Index based on queries |
| **No indexes** | Slow reads, table scans | Add based on slow query log |
| **Duplicate indexes** | Wasted space and maintenance | Audit and remove |
| **Wrong column order** | Index not used | Equality first, then range |
| **Ignoring cardinality** | Low-cardinality indexes useless | Index high-selectivity columns |
| **Never reindexing** | Index bloat over time | Regular maintenance |
| **Not measuring** | Unknown effectiveness | EXPLAIN ANALYZE |

---

## See Also

- [API Design](../api-design/api-design.md) – Query design affects indexing
- [Observability Patterns](../observability-patterns/observability-patterns.md) – Monitoring query performance
- [Testing Strategy](../testing-strategy/testing-strategy.md) – Performance testing
