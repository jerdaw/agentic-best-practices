# Synthesized Recommendations (2026-02-15)

High-confidence recommendations distilled from both reports after source revalidation.

## Default Baseline

| Area | Baseline recommendation | Confidence |
| --- | --- | --- |
| External docs | Keep concise README + focused `docs/` for architecture, runbooks, and onboarding | High |
| Repo-level agent instructions | Maintain `AGENTS.md`/tool-specific instruction files with exact commands + boundaries | High |
| Docstrings | Require docstrings for public APIs/modules; treat as interface contract | High |
| Inline comments | Prefer sparse "why" comments for non-obvious constraints/invariants | High |
| ADRs | Record architecturally significant decisions with rationale and consequences | High |
| Verification | Tie documentation claims to tests/examples/CI checks where feasible | High |
| Anti-rot | Update docs in same PR, run lint/link/nav checks in CI, assign ownership | High |
| Security | Never document secrets; classify sensitive operational guidance | High |

## Context-Specific Tuning

| Context | Recommended intensity |
| --- | --- |
| Prototype / solo | Minimal stack: README + core commands + essential comments/docstrings |
| Team / long-lived service | Full stack: README + `docs/` + ADRs + doc CI + ownership |
| Public library/API | Strong docstrings + generated API docs + versioned changelog |
| Regulated/safety-critical | Full traceability from requirements to code/tests/runbooks |

## Rejected or Downgraded Claims

| Claim | Decision | Reason |
| --- | --- | --- |
| "Every file must have top-level docstring" | Rejected as universal | No strong authoritative source supports universal mandate |
| "All teams must publish llms.txt" | Downgraded to optional emerging pattern | Emerging practice, not mature universal standard |
| "Log agent thinking in detail" | Restricted | Keep decision/rationale logs only; avoid chain-of-thought and sensitive context capture |

## Implementation Policy for This Repo

| Policy | Action |
| --- | --- |
| Only high-confidence recommendations become guide standards | Enforce via review and CI |
| Low-confidence recommendations can appear as optional notes | Must be clearly labeled as emerging |
| Security-sensitive documentation guidance must remain explicit | Keep in docs + templates + checklists |
