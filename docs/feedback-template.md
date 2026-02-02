# Adoption Feedback Template (v0.1.0)

Structured prompts for reporting “the standards didn’t work in practice” with minimal back-and-forth.

| Field | Value |
| --- | --- |
| **Version** | `0.1.0` |
| **Last updated** | 2026-02-02 |
| **Audience** | Humans filing feedback; agents can help draft |
| **Goal** | Turn vague complaints into actionable guide updates |

## Contents

| Section |
| --- |
| [When to Use This](#when-to-use-this) |
| [Fast Checklist](#fast-checklist) |
| [Copy-Paste Template](#copy-paste-template) |
| [Good vs Bad Reports](#good-vs-bad-reports) |
| [Privacy and Safety](#privacy-and-safety) |

---

## When to Use This

| Situation | Use this template? | Why |
| --- | --- | --- |
| Agent followed a guide and still produced a bad outcome | Yes | Guide likely missing constraints/examples |
| Two guides conflict | Yes | We need a tie-break rule or cross-links |
| You disagree with a recommendation (preference) | Maybe | Might be domain-specific; capture context |
| Tool bug unrelated to guidance | No | File in the tool’s repo instead |

---

## Fast Checklist

| Required | Item | Notes |
| --- | --- | --- |
| Yes | What you expected vs what happened | 1–2 sentences each |
| Yes | Exact guide file(s) used | Path(s) under `guides/` |
| Yes | Minimal reproduction or snippet | Smallest example that shows the issue |
| Yes | Environment/tool | “Codex CLI”, “Claude Code”, etc. |
| Recommended | Proposed fix | “Add a note under X”, “Add a Bad example”, etc. |

---

## Copy-Paste Template

Paste this into a GitHub Issue (or any tracker).

| Field | Value |
| --- | --- |
| **Title** | `[Guide Gap] <short summary>` |
| **Severity** | `Low` / `Medium` / `High` |
| **Category** | `Bug (wrong guidance)` / `Gap (missing guidance)` / `Conflict` / `Preference` |

### Summary

| Prompt | Answer |
| --- | --- |
| What happened? |  |
| What did you expect? |  |
| Why does it matter? |  |

### Reproduction

| Prompt | Answer |
| --- | --- |
| Minimal code/config snippet |  |
| Command(s) run |  |
| Observed output/error |  |

### Standards Context

| Prompt | Answer |
| --- | --- |
| Guide file(s) referenced |  |
| Section(s) referenced |  |
| Deviation policy involved? | Yes/No (and why) |

### Environment

| Prompt | Answer |
| --- | --- |
| Tool |  |
| Language/runtime |  |
| OS |  |

### Proposed Fix (optional but recommended)

| Proposed change | Where |
| --- | --- |
|  | `guides/<topic>/<topic>.md` section `<heading>` |

---

## Good vs Bad Reports

### Bad (too vague)

| Issue | Why it’s hard to fix |
| --- | --- |
| “Agents keep doing the wrong thing with errors.” | No guide/section, no repro, no expected outcome |

### Good (actionable)

| Field | Example |
| --- | --- |
| What happened | Agent added retries around a non-idempotent write and caused duplicates |
| Expected | Guide should warn “don’t retry non-idempotent writes without idempotency keys” |
| Guide | `guides/resilience-patterns/resilience-patterns.md` + `guides/idempotency-patterns/idempotency-patterns.md` |
| Repro | Minimal pseudocode + duplicate record screenshot/log snippet |
| Proposed fix | Add a “Retry + Idempotency” cross-link section with a Bad example |

---

## Privacy and Safety

| Rule | Rationale |
| --- | --- |
| Remove secrets (keys, tokens, passwords) | Prevent credential leaks |
| Remove private customer data | Avoid compliance/privacy violations |
| Minimize proprietary code | Prefer pseudocode or minimal excerpts |
