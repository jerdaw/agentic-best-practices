# Deep Research Evaluation Rubric (2026-02-15)

Objective rubric for evaluating deep-research outputs about documentation and comments in agentic coding.

## Scope

| Item | Value |
| --- | --- |
| Evaluated files | `chatgpt-agentic-documentation-and-comments-2026-02-15.md`, `gemini-agentic-documentation-and-comments-2026-02-15.md` |
| Evaluator date | 2026-02-15 |
| Intended use | Select high-confidence guidance for repo standards updates |

## Hard Gates

A report fails hard-gate compliance if any required item is missing.

| Gate | Requirement | Pass rule |
| --- | --- | --- |
| `HG-1` | Candidate sources listed first | 8-12 sources with date + relevance before main report |
| `HG-2` | Required sections A-H | Executive summary, decision matrix, baseline stack, commenting/docstring rules, agentic practices, anti-rot, templates, citations |
| `HG-3` | Source attribution | Important claims have traceable citations |
| `HG-4` | URL format constraint | No raw URLs in report body/output |
| `HG-5` | Length constraint | 2,000-4,000 words (excluding appendices/templates) |

## Weighted Scoring

| Category | Weight | Scoring rule |
| --- | --- | --- |
| Prompt compliance | 30 | Start from 30, subtract for each unmet explicit requirement |
| Evidence quality | 30 | Source mix quality, recency, and primary-source coverage |
| Analytical rigor | 20 | Handles disagreement, applies conditional recommendations, avoids unsupported jumps |
| Actionability | 10 | Provides concrete, reusable rules/templates/checklists |
| Security and compliance accuracy | 10 | Correct handling of secrets, sensitive ops data, and safe runbook guidance |

## Source Tier Model

| Tier | Definition | Examples |
| --- | --- | --- |
| `T1` | Primary authoritative | Official docs/specs/style guides, standards bodies |
| `T2` | High-signal practitioner | Major engineering org blogs, well-scoped maintainers |
| `T3` | Medium signal | Independent blogs with clear methods |
| `T4` | Low signal | SEO content farms, generic listicles, weakly sourced social posts |

## Confidence Labels

| Label | Rule |
| --- | --- |
| High | Supported by >=2 independent `T1/T2` sources or one clear authoritative source |
| Medium | Supported by one `T1/T2` plus weaker corroboration |
| Low | Based on `T3/T4` only, or missing verification |

## Decision Rule

| Total score | Outcome |
| --- | --- |
| >=85 and no hard-gate failures | Adopt directly with minor edits |
| 70-84 or minor hard-gate failures | Adopt selectively with explicit caveats |
| <70 or major hard-gate failures | Use only as brainstorming input |
