# Feedback Triage Rubric (v0.1.0)

How to classify and act on incoming feedback with minimal human time.

| Field | Value |
| --- | --- |
| **Version** | `0.1.0` |
| **Last updated** | 2026-02-02 |
| **Input** | Issues/notes using `docs/templates/feedback-template.md` |
| **Output** | Clear next action: fix, clarify, cross-link, or defer |

## Contents

| Section |
| --- |
| [Triage Goals](#triage-goals) |
| [Classification Table](#classification-table) |
| [Severity and Priority](#severity-and-priority) |
| [Resolution Patterns](#resolution-patterns) |
| [Validation](#validation) |

---

## Triage Goals

| Goal | Why |
| --- | --- |
| Reduce “opinion fights” | Focus on reproducible outcomes |
| Preserve trust in standards | Wrong guidance is worse than missing guidance |
| Keep changes reviewable | Small PRs and isolated guide edits |
| Make decisions cheap | Prefer Yes/No and repeatable patterns |

---

## Classification Table

Use the first row that matches best.

| Type | Definition | Example signal | Default action |
| --- | --- | --- | --- |
| **Bug (wrong guidance)** | Guide recommends something unsafe/incorrect in common scenarios | “Following X caused data loss” | Patch guide + add Bad example |
| **Gap (missing guidance)** | Guide doesn’t cover a common real-world constraint | “No guidance for idempotency keys” | Add a small section + cross-links |
| **Conflict** | Two guides or two sections disagree | “Retry guidance contradicts idempotency guidance” | Add tie-break rule + See Also links |
| **Ambiguity** | Wording causes misinterpretation | “Prefer” read as “must” | Clarify language + add example |
| **Preference** | Team style choice, not universally correct | “We dislike exceptions” | Defer or add as optional note |
| **Domain-specific** | Only applies to a niche stack/regulation | “HIPAA logging rules” | Add to relevant guide only if broadly useful; otherwise recommend local override |

---

## Severity and Priority

### Severity (impact)

| Severity | Meaning | Example |
| --- | --- | --- |
| **High** | Security/data-loss/compliance risk | PII logged, auth bypass, duplicate charges |
| **Medium** | Correctness/operational risk | Unhandled errors, flaky retries, poor observability |
| **Low** | Style/clarity | Example formatting, wording improvements |

### Priority (when to act)

| Priority | Default rule |
| --- | --- |
| **P0** | High severity + reproducible + common |
| **P1** | Medium severity + reproducible or common |
| **P2** | Low severity or not reproducible |

---

## Resolution Patterns

Prefer the smallest change that fixes the issue.

| Pattern | When to use | What to change |
| --- | --- | --- |
| Add a Bad example | Guidance is correct but easy to misuse | Add “Bad → Why → Good” block |
| Add a tie-break rule | Two sections conflict | Add a short “If X and Y conflict…” note |
| Add cross-links | Issue spans multiple guides | Add “See Also” rows to both guides |
| Add an explicit boundary | Guidance depends on context | Add “Only when…” / “Never when…” table |
| Defer | Preference/domain-specific | Close with rationale + suggest local override in project AGENTS.md |

---

## Validation

| Check | How |
| --- | --- |
| Small diff | Isolated PR; avoid broad refactors |
| No drift | `npm run precommit` green |
| Fix matches report | Example/repro now addressed explicitly |
