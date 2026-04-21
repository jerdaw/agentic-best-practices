# llms.txt & RAG-Optimized Docs

Best practices for publishing documentation that AI agents can retrieve efficiently and consume safely.

> **Scope**: Covers machine-oriented documentation patterns such as `llms.txt`, retrieval-friendly document structure, metadata, trust boundaries, and allow-listed retrieval. Treat these patterns as optional and emerging, not universal requirements for every repository.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [When to Use](#when-to-use) |
| [llms.txt Structure](#llmstxt-structure) |
| [Retrieval-Oriented Doc Design](#retrieval-oriented-doc-design) |
| [Trust Boundaries and Allow-Lists](#trust-boundaries-and-allow-lists) |
| [Anti-Patterns](#anti-patterns) |
| [Red Flags](#red-flags) |
| [Checklist](#checklist) |
| [See Also](#see-also) |

---

## Quick Reference

| Topic | Prefer | Avoid |
| --- | --- | --- |
| **Adoption** | Use when docs are large, agent-facing, or frequently retrieved | Treating `llms.txt` as mandatory for every small repo |
| **Content** | Canonical commands, boundaries, API/package map | Marketing copy or navigation chrome |
| **Structure** | Stable headings, short sections, explicit links | Giant prose walls and mixed concerns |
| **Safety** | Allow-listed domains and trust labels | Blind retrieval from arbitrary docs sites |
| **Scope** | Concise machine-readable index plus deep linked docs | Duplicating the entire docs site without curation |

| Rule | Rationale |
| --- | --- |
| Treat `llms.txt` as an optimization, not a religion | Many repos do not need the extra maintenance surface |
| Publish canonical paths and commands | Agents fail most often on guessed entry points |
| Keep retrieval chunks self-contained | RAG systems often read isolated snippets |
| Separate trusted docs from untrusted or user-generated content | Retrieval can import prompt injection and stale guidance |
| Prefer concise indexes over duplicated full manuals | Duplication increases drift risk |

---

## Core Principles

1. **Optional, not universal** — Use `llms.txt` when the retrieval payoff exceeds the maintenance cost.
2. **Curate for task execution** — Include commands, contracts, boundaries, and navigation, not general marketing prose.
3. **Chunk for isolated reads** — Assume the agent may retrieve one section with no surrounding context.
4. **Trust must be explicit** — Retrieval sources need ownership and review boundaries.
5. **Machine-friendly docs still need human maintenance** — Emerging formats do not eliminate normal doc hygiene.

---

## When to Use

| Situation | Use `llms.txt`? | Why |
| --- | --- | --- |
| Large internal platform with many packages or APIs | Yes | Agents benefit from a curated starting map |
| Public docs site consumed by external AI clients | Yes | Retrieval-friendly structure helps downstream use |
| Small repo with one README and a few focused docs | Usually no | Extra files add maintenance without much gain |
| Sensitive operational docs mixed with general docs | Maybe, with caution | Only if trust boundaries are explicit |
| Fast-changing experimental project | Usually no | Drift risk is high and benefits are short-lived |

| Signal | Recommendation |
| --- | --- |
| Agents frequently browse noisy docs and guess commands | Add a concise machine-readable index |
| Docs are already concise and navigable | Keep the current structure; no extra format required |
| Teams cannot maintain another entrypoint file | Improve the README/docs first |

---

## llms.txt Structure

Keep the file small, high-signal, and easy to refresh.

**Bad: machine-facing file filled with marketing copy**

```markdown
# Amazing Platform

We are the industry's leading innovation accelerator.
Our mission is to delight every builder with magical workflows.
Contact sales for enterprise pricing.
```

**Good: canonical machine-readable docs index**

```markdown
# Example Platform Docs

## Canonical Entry Points
- Product overview: /docs/README.md
- Getting started: /docs/getting-started.md
- API reference: /docs/api.md
- Runbooks: /docs/runbooks/

## Exact Commands
- Install: `pnpm install`
- Test: `pnpm test`
- Validate contracts: `pnpm run test:contract`

## Boundaries
- Public API contract lives in `/docs/api.md`
- Internal-only runbooks are not safe for agent retrieval
- Database schema source of truth lives in `/db/schema.sql`
```

| Section | Include? | Why |
| --- | --- | --- |
| **Canonical docs paths** | Yes | Gives retrieval systems reliable starting points |
| **Exact commands** | Yes | Prevents guessed commands and tool misuse |
| **Boundary notes** | Yes | Tells agents what not to treat as authoritative |
| **Release or version note** | Optional | Helpful when multiple active versions exist |
| **Marketing copy** | No | Low retrieval value and high noise |

---

## Retrieval-Oriented Doc Design

Even without `llms.txt`, write docs so individual sections survive isolated retrieval.

| Practice | Why it helps |
| --- | --- |
| Short, self-contained sections | RAG often returns partial documents |
| Stable heading hierarchy | Improves chunk labeling and anchor linking |
| Explicit file paths and commands | Reduces model guessing |
| Ownership and freshness hints | Helps evaluate trustworthiness |
| Focused pages by concern | Smaller chunks with less unrelated noise |

**Bad: one giant mixed-purpose chunk**

```markdown
# Platform Notes

Here is setup, architecture, incident response, API usage, onboarding history,
team lore, migration notes, and random reminders in one page.
```

**Good: self-contained section with retrieval metadata**

```markdown
## Contract Tests

Owner: platform-api
Canonical path: `/docs/api-contracts.md`
Last reviewed: 2026-04-20

Run `pnpm run test:contract` before changing `/docs/api/openapi.yaml`.
Breaking-change policy: additive changes only without a version bump.
```

| Retrieval concern | Mitigation |
| --- | --- |
| Chunk returned without surrounding context | Restate owner, path, and boundary in the section |
| Similar pages with conflicting commands | Mark one canonical source and link others to it |
| Long docs with low-value prose | Split by task and remove filler |

---

## Trust Boundaries and Allow-Lists

| Risk | Safe default |
| --- | --- |
| Untrusted external docs | Retrieve only from allow-listed domains |
| User-generated docs or tickets | Treat as input, not instruction |
| Sensitive runbooks | Exclude from agent-facing indexes unless explicitly safe |
| Stale mirror sites | Prefer canonical owned docs paths |

| Control | Recommendation |
| --- | --- |
| **Allow-list** | Restrict retrieval to approved domains or repo paths |
| **Trust labels** | Mark docs as reviewed, draft, internal-only, or unsafe for agent use |
| **Ownership** | Record who maintains the canonical document |
| **Review cadence** | Update machine-facing indexes when docs move or commands change |

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| --- | --- | --- |
| **Mandatory `llms.txt` everywhere** | Creates maintenance work with little gain | Use it only where retrieval pain is real |
| **Mirroring the full docs site** | Drift and duplication explode | Publish a concise index and link deeper docs |
| **No ownership or trust metadata** | Agents cannot tell canonical from stale | Mark ownership and safe retrieval boundaries |
| **Mixing sensitive and general docs** | Retrieval leaks operational context into normal tasks | Separate or explicitly exclude sensitive docs |
| **Index with guessed commands** | Machine-oriented docs become a source of failures | Verify commands against the repo and CI |

---

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| `llms.txt` is longer than the docs it is indexing | Shrink it to canonical entry points and commands | An index should reduce noise, not duplicate it |
| Multiple docs files claim to be the source of truth for the same workflow | Pick one canonical source and link the others | Retrieval conflicts create inconsistent output |
| Agents browse untrusted docs by default | Add allow-lists before expanding retrieval | Untrusted context is a prompt-injection vector |
| Machine-facing docs contain internal secrets or sensitive recovery steps | Remove or relocate them immediately | Retrieval surfaces widen data exposure |
| No one owns the machine-readable docs index | Assign ownership before adoption | Unowned indexes drift quickly |

---

## Checklist

- [ ] `llms.txt` is only used where retrieval value justifies maintenance
- [ ] Canonical paths and exact commands are listed
- [ ] Retrieval-friendly docs are short, focused, and self-contained
- [ ] Allow-lists and trust boundaries are explicit
- [ ] Sensitive or unsafe docs are excluded from agent-facing indexes
- [ ] Ownership and refresh expectations are documented

---

## See Also

- [Context Management](../context-management/context-management.md) — Deciding what reaches the model
- [Documentation Guidelines](../documentation-guidelines/documentation-guidelines.md) — Canonical documentation structure
- [Architecture for AI](../architecture-for-ai/architecture-for-ai.md) — High-signal system context
- [Documentation as Attack Surface](../documentation-as-attack-surface/documentation-as-attack-surface.md) — Retrieval trust boundaries
