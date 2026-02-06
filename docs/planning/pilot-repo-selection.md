# Pilot Repository Selection Criteria

Evaluation framework for choosing 1-2 adoption pilot repositories.

| Field | Value |
| --- | --- |
| **Status** | Draft - awaiting human decision |
| **Created** | 2026-02-05 |
| **Decision owner** | Human (requires org priorities + stakeholders) |

## Contents

| Section |
| --- |
| [Evaluation Criteria](#evaluation-criteria) |
| [Scoring Rubric](#scoring-rubric) |
| [Candidate Evaluation Template](#candidate-evaluation-template) |
| [Feedback Capture Plan](#feedback-capture-plan) |

---

## Evaluation Criteria

### Technical Fit

| Criterion | Weight | Why It Matters |
| --- | --- | --- |
| **Codebase size** | High | Medium-sized repos (1k-10k LOC) easier to validate than tiny or massive |
| **Active development** | High | Need real usage to validate patterns; stagnant repos won't test adequately |
| **Tech stack diversity** | Medium | Testing across languages/frameworks validates generalizability |
| **Existing AGENTS.md/CLAUDE.md** | Low | Easier with existing, but not required |
| **CI/CD maturity** | Medium | Validates integration with existing tooling |

### Organizational Fit

| Criterion | Weight | Why It Matters |
| --- | --- | --- |
| **Team willingness** | Critical | Pilots fail without engaged participants |
| **Feedback capacity** | High | Need team time to document what works/doesn't |
| **Stakeholder visibility** | Medium | Success needs witnesses; too high-profile adds pressure |
| **Representative use case** | High | Pilot should reflect typical org usage patterns |
| **Risk tolerance** | Medium | Some friction expected; choose teams that can handle it |

### Practical Constraints

| Criterion | Weight | Why It Matters |
| --- | --- | --- |
| **Timeline alignment** | High | Pilot needs to coincide with actual feature work |
| **Support availability** | Medium | Someone needs to help teams when patterns unclear |
| **Isolation** | Low | Can pilot fail without blocking critical work? |

---

## Scoring Rubric

Rate each candidate repo on a 1-5 scale for each criterion.

| Score | Meaning |
| --- | --- |
| 5 | Ideal fit |
| 4 | Strong fit |
| 3 | Acceptable fit |
| 2 | Weak fit (needs mitigation) |
| 1 | Poor fit (likely blocker) |

### Weighting

| Weight | Multiplier | Usage |
| --- | --- | --- |
| Critical | 3x | Must-have; score < 3 disqualifies |
| High | 2x | Important; low scores need strong compensating factors |
| Medium | 1x | Considered but not decisive |
| Low | 0.5x | Nice-to-have |

---

## Candidate Evaluation Template

Copy this table for each candidate repository:

```markdown
### [Repository Name]

| Criterion | Score (1-5) | Weight | Weighted | Notes |
| --- | --- | --- | --- | --- |
| **Technical Fit** |
| Codebase size | | High (2x) | | [LOC count, complexity] |
| Active development | | High (2x) | | [Commits/week, recent PRs] |
| Tech stack diversity | | Medium (1x) | | [Languages, frameworks] |
| Existing AGENTS.md | | Low (0.5x) | | [Yes/No, quality if yes] |
| CI/CD maturity | | Medium (1x) | | [CI setup, test coverage] |
| **Organizational Fit** |
| Team willingness | | Critical (3x) | | [Explicit buy-in or assumption?] |
| Feedback capacity | | High (2x) | | [Team size, sprint slack] |
| Stakeholder visibility | | Medium (1x) | | [Who's watching?] |
| Representative use case | | High (2x) | | [How typical is this repo?] |
| Risk tolerance | | Medium (1x) | | [Team culture, deadlines] |
| **Practical Constraints** |
| Timeline alignment | | High (2x) | | [Upcoming work planned?] |
| Support availability | | Medium (1x) | | [Who helps when stuck?] |
| Isolation | | Low (0.5x) | | [Blast radius if pilot fails] |
| **Total** | | | [Sum] | |

**Recommendation**: [Select / Maybe / Pass]

**Key Strengths**:
- [What makes this a strong candidate]

**Key Risks**:
- [What could go wrong]

**Mitigation Plan** (if selected):
- [How to address risks]
```

---

## Feedback Capture Plan

### What to Track

| Category | Metrics | Collection Method |
| --- | --- | --- |
| **Adoption friction** | Time to first AI commit, blocker frequency | Weekly check-in |
| **Pattern effectiveness** | Which guides referenced most, which ignored | Survey + usage logs |
| **Quality impact** | Code review feedback volume, bug rates | Repo metrics |
| **Developer sentiment** | NPS, qualitative feedback | Mid-point + end survey |
| **Documentation gaps** | Which patterns were unclear, what's missing | Issue tracker |

### Feedback Channels

| Channel | Frequency | Owner |
| --- | --- | --- |
| **Weekly async check-in** | Weekly | Pilot team posts update |
| **Sync debrief** | Bi-weekly | 30-min call with pilot team |
| **Mid-point survey** | Week 3-4 | Structured questionnaire |
| **Final retrospective** | End of pilot (Week 6-8) | 60-min facilitated session |
| **Ad-hoc issues** | As needed | GitHub issues in agentic-best-practices repo |

### Feedback Template

```markdown
## Pilot Feedback: [Repository Name] - Week [N]

### What Worked

| Pattern/Guide | How It Helped |
| --- | --- |
| [Guide name] | [Concrete example] |

### What Didn't Work

| Pattern/Guide | Problem | Suggested Fix |
| --- | --- | --- |
| [Guide name] | [What went wrong] | [How to improve] |

### Gaps Discovered

| Situation | Missing Guidance | Workaround Used |
| --- | --- | --- |
| [What you tried to do] | [What wasn't documented] | [How you solved it] |

### Metrics (if available)

- **AI commits this week**: [N]
- **Guides referenced**: [List]
- **Blockers encountered**: [N]
- **Time saved estimate**: [Hours/week]

### Other Observations

[Free-form notes]
```

---

## Decision Checklist

Before finalizing pilot selection, verify:

- [ ] At least one pilot team has explicitly committed (not just assumed willingness)
- [ ] Feedback capture owner is identified and has capacity
- [ ] Support plan exists for when teams get stuck
- [ ] Timeline allows for 6-8 week pilot + retrospective
- [ ] Success criteria defined (see `v1-success-criteria.md`)
- [ ] Stakeholders aligned on pilot goals and acceptable failure modes

---

## See Also

- [v1 Success Criteria](v1-success-criteria.md) - What defines a successful pilot
- [Adoption Guide](../../adoption/adoption.md) - How teams integrate agentic-best-practices
- [Roadmap Process](../process/roadmap-process.md) - How this feeds back into roadmap
