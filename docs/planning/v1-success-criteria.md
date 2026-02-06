# v1 Success Criteria and Maintenance Cadence

Proposed success criteria for v1 release and ongoing maintenance schedule options.

| Field | Value |
| --- | --- |
| **Status** | Draft - awaiting human decision |
| **Created** | 2026-02-05 |
| **Decision owner** | Human (product/ownership decision) |

## Contents

| Section |
| --- |
| [v1 Success Criteria Options](#v1-success-criteria-options) |
| [Maintenance Cadence Options](#maintenance-cadence-options) |
| [Metrics Tracking Approach](#metrics-tracking-approach) |
| [Decision Framework](#decision-framework) |

---

## v1 Success Criteria Options

### Option A: Pilot-Validated (Recommended)

**Philosophy**: v1 means proven in real usage, not just written.

| Criterion | Target | Verification Method |
| --- | --- | --- |
| **Pilot completion** | 1-2 repos complete 6-8 week pilot | Pilot retrospective documents |
| **Core guides validated** | Top 10 guides referenced in real commits | Pilot feedback + commit analysis |
| **Documented gaps addressed** | All critical feedback items resolved | GitHub issues closed |
| **Template proven** | AGENTS.md template used successfully | Pilot repos using template |
| **No critical blockers** | Zero "can't use this" issues outstanding | Issue tracker review |

**Pros**: De-risks adoption, validates actual utility
**Cons**: Requires pilot(s) first, delays v1 label
**Timeline**: 8-12 weeks from pilot start

---

### Option B: Content-Complete

**Philosophy**: v1 means all planned guides exist, regardless of validation.

| Criterion | Target | Verification Method |
| --- | --- | --- |
| **All guides written** | 100% of guides in Guide Index exist | File check |
| **Navigation validated** | `npm run validate` passes | CI check |
| **Examples in all guides** | Every guide has ≥2 code examples | Manual review |
| **Cross-links complete** | No broken internal links | Link checker |
| **Adoption docs ready** | Adoption guide + template finalized | Docs exist |

**Pros**: Faster to achieve, clear checklist
**Cons**: Unvalidated patterns may need rework post-v1
**Timeline**: 2-4 weeks from current state

---

### Option C: Hybrid (Baseline + Pilot Signal)

**Philosophy**: v1 means content-complete with minimal validation signal.

| Criterion | Target | Verification Method |
| --- | --- | --- |
| **Content complete** | All planned guides exist | File check |
| **Self-dogfooding** | agentic-best-practices itself uses AGENTS.md | AGENTS.md exists and followed |
| **1 external validation** | At least 1 non-author used successfully | Testimonial or case study |
| **Critical guides tested** | Top 5 guides validated in real usage | Commit evidence |
| **No known blockers** | Zero "unusable" issues | Issue review |

**Pros**: Balances speed with validation
**Cons**: Minimal validation may miss edge cases
**Timeline**: 4-6 weeks

---

### Option D: MVP (Minimal Viable Product)

**Philosophy**: v1 means enough to be useful, not comprehensive.

| Criterion | Target | Verification Method |
| --- | --- | --- |
| **Core guides only** | 10 most critical guides complete | Subset of guide index |
| **Adoption path exists** | Template + adoption guide done | Docs exist |
| **Basic validation** | Used by maintainer on 1 project | Commit history |
| **Foundation solid** | Navigation, structure, templates working | CI passes |

**Pros**: Fastest to ship, learns from usage
**Cons**: Incomplete coverage, may frustrate users expecting more
**Timeline**: 1-2 weeks

---

## Maintenance Cadence Options

### Option 1: Continuous (Event-Driven)

| Activity | Trigger | Owner |
| --- | --- | --- |
| **Update guide** | Pattern evolves or feedback received | Maintainer |
| **Add guide** | Gap identified in real usage | Maintainer |
| **Quarterly review** | Every 3 months | Maintainer + stakeholders |
| **Breaking changes** | Never (guidance is additive) | N/A |

**Effort**: Low ongoing, spikes with feedback
**Best for**: Active projects with frequent AI usage

---

### Option 2: Scheduled Releases

| Activity | Frequency | Owner |
| --- | --- | --- |
| **Patch release** | Monthly (bug fixes, clarifications) | Maintainer |
| **Minor release** | Quarterly (new guides, enhancements) | Maintainer |
| **Major release** | Yearly (structure changes, major rewrites) | Maintainer + stakeholders |
| **Hotfix** | As needed (critical corrections) | Maintainer |

**Effort**: Predictable, batchable work
**Best for**: Stable projects with infrequent changes

---

### Option 3: Issue-Driven (Reactive)

| Activity | Trigger | Owner |
| --- | --- | --- |
| **Address feedback** | Issue/PR filed | Maintainer reviews weekly |
| **Batch updates** | Monthly (collect + resolve batch) | Maintainer |
| **No scheduled reviews** | Only when issues surface | N/A |

**Effort**: Minimal unless problems arise
**Best for**: Low-traffic projects or post-stabilization

---

### Option 4: Hybrid (Recommended)

| Activity | Trigger | Frequency | Owner |
| --- | --- | --- | --- |
| **Hotfixes** | Critical errors found | Immediate | Maintainer |
| **Content updates** | Feedback/new patterns | Continuous (as needed) | Maintainer |
| **Quarterly health check** | Calendar | Every 3 months | Maintainer |
| **Annual architecture review** | Calendar | Yearly | Maintainer + stakeholders |

**Effort**: Low steady state, predictable checkpoints
**Best for**: Most projects

---

## Metrics Tracking Approach

### Adoption Metrics

| Metric | Collection Method | Frequency | Target (Optional) |
| --- | --- | --- | --- |
| **Active projects using** | Self-reported or GitHub stars/forks | Quarterly | 5+ by end of year 1 |
| **Guides referenced** | Survey or commit message analysis | Quarterly | All core guides used ≥1x |
| **Template usage** | GitHub search for AGENTS.md with template | Quarterly | 50% of adopters use template |

### Quality Metrics

| Metric | Collection Method | Frequency | Target (Optional) |
| --- | --- | --- | --- |
| **Broken links** | CI link checker | Every commit | 0 broken links |
| **Navigation drift** | `npm run validate` | Every commit | 0 drift |
| **Issue resolution time** | GitHub issue tracker | Monthly | < 2 weeks median |
| **Stale content** | Manual review of "Last updated" dates | Quarterly | No guide >6 months stale |

### Impact Metrics (Aspirational)

These are harder to measure but valuable for assessing actual impact:

| Metric | Collection Method | Frequency |
| --- | --- | --- |
| **Code review comments reduced** | Pilot repos: before/after analysis | Post-pilot |
| **AI commit quality** | Pilot teams: subjective rating | Pilot surveys |
| **Time saved** | Developer self-report | Pilot surveys |
| **Pattern consistency** | Code review: frequency of "follow pattern X" | Post-pilot |

### Metrics Dashboard Template

```markdown
## agentic-best-practices Health Dashboard

**Last updated**: YYYY-MM-DD

### Adoption
- **Active projects**: [N]
- **Template users**: [N]
- **Most-referenced guides**: [Top 5]

### Quality
- **Broken links**: [N] ([CI link])
- **Navigation drift**: [Pass/Fail] ([CI link])
- **Open issues**: [N] ([link to issues])
- **Avg issue resolution**: [N days]

### Recent Activity
- **Guides added this quarter**: [N]
- **Guides updated this quarter**: [N]
- **Feedback items addressed**: [N]

### Action Items
- [ ] [Any urgent issues]
```

---

## Decision Framework

### Questions to Answer Before Choosing

| Question | Why It Matters |
| --- | --- |
| **What's the adoption urgency?** | High urgency → faster v1 (Option B or D) |
| **How risk-tolerant are we?** | Low tolerance → validated v1 (Option A or C) |
| **What's the maintenance capacity?** | Limited capacity → event-driven or reactive cadence |
| **Who are the initial users?** | Early adopters tolerate gaps; later users expect polish |
| **What's the cost of being wrong?** | Low cost → ship fast and iterate; high cost → validate first |

### Decision Template

```markdown
## v1 Definition Decision

**Chosen approach**: [Option A/B/C/D]

**Rationale**:
- [Why this fits our situation]

**Tradeoffs accepted**:
- [What we're giving up]

**Success looks like**:
- [Specific, measurable outcome]

**Timeline**:
- [Expected v1 date]

---

## Maintenance Cadence Decision

**Chosen approach**: [Option 1/2/3/4]

**Rationale**:
- [Why this fits our capacity]

**Owner**:
- [Name/role]

**Review trigger**:
- [When to revisit this decision]
```

---

## Recommended Approach

Based on the current state of agentic-best-practices (comprehensive guides already exist, navigation tooling in place, but unvalidated in external usage):

**v1 Success Criteria**: **Option C - Hybrid**
✓ Content complete (nearly there already)
✓ Self-dogfooding (add AGENTS.md to this repo)
✓ 1 external validation (pick easiest pilot)
✓ Top 5 guides tested
✓ No blockers

**Maintenance Cadence**: **Option 4 - Hybrid**
✓ Hotfixes immediate
✓ Content updates continuous
✓ Quarterly health check
✓ Annual architecture review

**Timeline**: 4-6 weeks to v1
**Effort**: ~4-6 hours/month steady state

---

## See Also

- [Pilot Repo Selection](pilot-repo-selection.md) - Choosing validation repos
- [Roadmap Process](../process/roadmap-process.md) - How this feeds into roadmap
- [Release Process](../process/release-process.md) - How to cut releases
