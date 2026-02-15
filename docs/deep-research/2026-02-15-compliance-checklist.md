# Deep Research Compliance Checklist (2026-02-15)

Pass/fail checklist against the exact prompt constraints.

## Summary

| Report | Hard-gate result | Notes |
| --- | --- | --- |
| ChatGPT report | Fail | Missing explicit source list and traceable citations |
| Gemini report | Fail | Missing explicit source-list-first section, uses raw URLs, exceeds length target |

## Requirement-by-Requirement Check

| Requirement | ChatGPT | Gemini | Notes |
| --- | --- | --- | --- |
| 8-12 candidate sources listed first (with date + why) | Fail | Fail | Neither report starts with a compliant candidate-source block |
| Executive summary (10-15 bullets) | Pass | Partial | ChatGPT has bullet summary; Gemini summary is narrative-heavy |
| Decision matrix | Pass | Pass | Both include matrix sections |
| Baseline doc stack | Pass | Pass | Both provide starter stack guidance |
| Commenting/docstring actionable rules | Pass | Pass | Both include clear rules and examples |
| Agentic/AI-specific practices | Pass | Pass | Both cover repo instructions and workflow constraints |
| Anti-rot mechanisms | Pass | Pass | Both discuss CI/checklists/ownership patterns |
| Concrete templates | Pass | Partial | Gemini lacks explicit PR checklist template item |
| Cite important claims | Fail | Partial | ChatGPT has almost no traceable references; Gemini has references but weak claim mapping |
| If sources disagree, show both sides + conclusion | Partial | Partial | Both touch disagreements; neither does systematic conflict analysis |
| No raw URLs in output | Pass | Fail | Gemini works cited contains raw URLs |
| Include short direct quotes where possible | Partial | Partial | Limited and inconsistent attribution in both |
| Label weak evidence as low confidence | Fail | Fail | Neither systematically confidence-labels weak claims |
| Length target 2,000-4,000 words | Pass (3,219) | Fail (4,820) | Gemini exceeds upper target |

## Constraint Risk Notes

| Risk | ChatGPT | Gemini |
| --- | --- | --- |
| Traceability risk | High | Medium |
| Source quality risk | High | Medium-High |
| Policy-fit risk (prompt format constraints) | Medium | High |
