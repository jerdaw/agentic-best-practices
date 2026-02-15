# Source Audit (2026-02-15)

Objective source-quality audit for the two reports.

## Topline

| Report | Citation traceability | Source mix quality | Confidence impact |
| --- | --- | --- | --- |
| ChatGPT report | Low | Low-Unknown | High risk: claims are hard to verify |
| Gemini report | Medium | Mixed (broad but noisy) | Medium-High risk: many low-signal citations |

## ChatGPT Report Audit

| Metric | Result |
| --- | --- |
| Explicit source list | Not present |
| In-text citation system | Not usable (single stray `[8]` marker) |
| Primary-source ratio | Not measurable |
| Overall evidence confidence | Low |

## Gemini Report Audit

### Domain distribution (works cited)

| Domain type | Approx count | Examples |
| --- | --- | --- |
| Official/primary (`T1`) | ~10 | `cloud.google.com`, `code.claude.com`, `github.blog`, `adr.github.io`, `owasp.org` (topic referenced) |
| Reputable practitioner (`T2`) | ~8 | `simonwillison.net`, `addyosmani.com`, `aider.chat`, `thenewstack.io` |
| Medium/low-signal (`T3/T4`) | ~29 | `medium.com`, `dev.to`, `reddit.com`, `news.ycombinator.com`, various marketing blogs |

### Key quality findings

| Finding | Impact |
| --- | --- |
| Very broad bibliography (47 URLs) but many low-signal sources | Lowers trust in strong normative claims |
| Several sources appear only loosely related to specific claims | Increases hallucination and overgeneralization risk |
| References are listed, but claim-to-citation mapping is sparse | Hard to audit individual recommendations |
| Raw URL format violates prompt output constraint | Compliance failure |

## Source-Audit Decision

| Report | Evidence outcome |
| --- | --- |
| ChatGPT report | Do not adopt claims without independent verification |
| Gemini report | Use as idea pool only; adopt only claims revalidated against `T1/T2` sources |
