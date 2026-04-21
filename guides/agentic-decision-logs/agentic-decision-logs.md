# Agentic Decision Logs

Best practices for recording AI-assisted decisions and rationale without leaking chain-of-thought, secrets, or unsafe prompt context.

> **Scope**: Covers durable logging of decisions made during AI-assisted work: what changed, why it changed, what evidence supported it, and who approved it. Does not recommend storing raw chain-of-thought, sensitive prompt context, or private data.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [What to Log](#what-to-log) |
| [Safe Log Schema](#safe-log-schema) |
| [Review and Retention](#review-and-retention) |
| [Anti-Patterns](#anti-patterns) |
| [Red Flags](#red-flags) |
| [Checklist](#checklist) |
| [See Also](#see-also) |

---

## Quick Reference

| Log this | Do not log this |
| --- | --- |
| Decision summary | Raw chain-of-thought or hidden reasoning traces |
| Inputs used at a high level | Full sensitive prompts, secrets, credentials |
| Alternatives considered | Entire chat transcripts by default |
| Evidence and validation links | PII or customer data unless explicitly approved |
| Human owner and reviewer | Internal-only context copied into general logs |

| Rule | Rationale |
| --- | --- |
| Store decision summaries, not thought transcripts | You need traceability, not private reasoning capture |
| Link to evidence instead of pasting everything | Smaller, safer, and easier to review |
| Record who approved the change | Accountability stays human |
| Keep logs durable but scoped | Decision logs are for future understanding, not full telemetry dumps |
| Define retention rules | Old logs can become liability if they contain sensitive context |

---

## Core Principles

1. **Traceability over verbosity** — Capture what was decided and why, not every intermediate thought.
2. **Safety over curiosity** — If context is sensitive, summarize it instead of storing it raw.
3. **Human accountability remains explicit** — Record the approving human owner or reviewer.
4. **Decision logs should be reviewable artifacts** — They must be concise enough that another engineer can trust and use them.
5. **Evidence should be linkable** — Prefer links to PRs, ADRs, specs, and tests over large pasted transcripts.

---

## What to Log

| Field | Include? | Why |
| --- | --- | --- |
| **Decision** | Yes | Future readers need the outcome |
| **Scope affected** | Yes | Tells readers where to look |
| **Alternatives considered** | Yes, briefly | Explains why a different path was chosen |
| **Rationale summary** | Yes | Captures the reasoning in reviewable form |
| **Evidence or validation links** | Yes | Grounds the decision in observable facts |
| **Human owner/reviewer** | Yes | Keeps accountability clear |
| **Raw prompt transcript** | No by default | Often too noisy and too sensitive |
| **Chain-of-thought** | No | Unnecessary and risky to persist |

| Trigger | Create or update a decision log? |
| --- | --- |
| AI proposes a non-obvious implementation trade-off | Yes |
| Policy or architecture decision changes | Yes |
| Routine formatting or boilerplate change | Usually no |
| Security-sensitive mitigation or incident decision | Yes, with extra care |

---

## Safe Log Schema

Use a concise structure that captures decisions without exposing sensitive reasoning traces.

**Bad: transcript dump with sensitive context**

```markdown
## Decision Log

The agent reasoned for twelve paragraphs about every possible fix.
Prompt included customer payloads, internal credentials, and raw stack traces.
Entire conversation copied below for posterity.
```

**Good: durable decision summary**

```markdown
## Decision: switch contract test to additive-only gate

- Date: 2026-04-20
- Scope: `docs/api/openapi.yaml`, `tests/contract/`
- Owner: platform-api
- Human reviewer: eng-manager
- Alternatives considered:
  - Keep manual review only
  - Add additive-only CI gate
- Decision: add additive-only gate and require version bump for breaking changes
- Rationale: repeated PR review misses breaking fields; existing contract tests already provide the right source of truth
- Evidence:
  - PR #184
  - `npm run test:contract`
  - ADR-005
```

**Good: machine-friendly JSON summary**

```json
{
  "decision_id": "dec_2026_04_20_contract_gate",
  "scope": ["docs/api/openapi.yaml", "tests/contract/"],
  "owner": "platform-api",
  "human_reviewer": "eng-manager",
  "decision": "Require additive-only changes without a version bump",
  "alternatives": ["manual review only", "full freeze on API changes"],
  "evidence_links": ["PR-184", "ADR-005", "npm run test:contract"]
}
```

| Schema rule | Why |
| --- | --- |
| Use short summaries and explicit fields | Easier to review and safer to store |
| Store links to evidence, not raw artifacts when possible | Reduces duplication and leak surface |
| Separate public/internal visibility if needed | Some decisions can be broadly shared, others cannot |

---

## Review and Retention

| Topic | Recommendation |
| --- | --- |
| **Review** | Human reviewers should confirm the summary is accurate and non-sensitive |
| **Storage** | Keep decision logs with the change artifact, ADR, or planning doc when durable context matters |
| **Retention** | Retain as long as the decision remains operationally relevant |
| **Redaction** | Remove secrets, user data, and internal-only prompt context before storage |
| **Access** | Restrict sensitive decision logs the same way you restrict the underlying source material |

| If the log contains... | Do this |
| --- | --- |
| Sensitive incident or security details | Store a redacted summary with restricted detailed evidence elsewhere |
| Large prompt or transcript excerpts | Replace with a short rationale summary and links |
| Temporary experiment notes | Promote only the final decision into the durable log |

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| --- | --- | --- |
| **Transcript hoarding** | High noise and leak risk | Store concise summaries and evidence links |
| **Chain-of-thought capture** | Unsafe and unnecessary | Record outcome and rationale summary instead |
| **Anonymous decisions** | No accountability path | Record human owner and reviewer |
| **No evidence links** | Future readers cannot validate the decision | Link tests, PRs, specs, or ADRs |
| **Permanent storage of temporary context** | Old logs become a liability | Apply retention and redaction policy |

---

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| Decision logs contain raw prompts with secrets or customer data | Redact immediately and rotate credentials if needed | Decision logs should not become a leak surface |
| Team wants logs "just in case" with no schema | Define a minimal structure first | Unstructured logs turn into useless archives |
| No human reviewer is recorded for consequential AI decisions | Add one before treating the log as authoritative | Accountability remains human |
| Logs repeat chain-of-thought verbatim | Replace with a short rationale summary | Reviewable traceability does not require hidden reasoning |
| Old decision logs no longer match current policy or code | Update, supersede, or archive them | Stale decision history misleads future changes |

---

## Checklist

- [ ] Decision logs capture outcome, scope, rationale summary, and owner
- [ ] Raw chain-of-thought is not stored
- [ ] Sensitive prompts, secrets, and customer data are excluded or redacted
- [ ] Evidence links point to PRs, tests, ADRs, or specs
- [ ] Human reviewer is named for consequential decisions
- [ ] Retention and access boundaries are defined

---

## See Also

- [Planning Documentation](../planning-documentation/planning-documentation.md) — Durable planning artifacts
- [Documentation Guidelines](../documentation-guidelines/documentation-guidelines.md) — ADRs and durable documentation patterns
- [Security Boundaries](../security-boundaries/security-boundaries.md) — Prompt and context safety
- [Spec-Driven Development](../spec-driven-development/spec-driven-development.md) — Specs as the source of truth
