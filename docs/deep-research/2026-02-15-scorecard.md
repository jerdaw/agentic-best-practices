# Deep Research Scorecard (2026-02-15)

Scores calculated using `2026-02-15-evaluation-rubric.md`.

## Weighted Scores

| Category | Weight | ChatGPT | Gemini |
| --- | ---: | ---: | ---: |
| Prompt compliance | 30 | 17 | 20 |
| Evidence quality | 30 | 8 | 15 |
| Analytical rigor | 20 | 15 | 13 |
| Actionability | 10 | 8 | 9 |
| Security and compliance accuracy | 10 | 8 | 7 |
| **Total** | **100** | **56** | **64** |

## Gate Outcome

| Report | Hard-gate pass? | Adoptability |
| --- | --- | --- |
| ChatGPT | No | Use only after independent revalidation |
| Gemini | No | Use selectively after revalidation; reject low-confidence claims |

## Findings by Severity

| Severity | Finding |
| --- | --- |
| High | ChatGPT output lacks traceable source attribution for most key claims |
| High | Gemini output violates prompt constraint on raw URLs and exceeds length target |
| High | Both reports miss the required "candidate sources first" section |
| Medium | Gemini overuses low-signal sources (forums/Medium/SEO blogs) for normative claims |
| Medium | Both reports under-specify confidence labels for weak evidence |
| Low | Template quality is generally useful in both reports |

## Selection Strategy

| Strategy | Result |
| --- | --- |
| Keep only claims revalidated against `T1/T2` sources | Approved |
| Use report text as canonical source | Rejected |
| Translate approved claims into concrete repo guide updates | Approved |
