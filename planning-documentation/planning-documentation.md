# Planning Documentation

Best practices for creating, maintaining, and archiving planning artifacts—roadmaps, implementation plans, RFCs, and proposals.

> **Scope**: These guidelines apply to project planning documentation. For recording architectural decisions after they're made, see [ADRs in Documentation Guidelines](../documentation-guidelines/documentation-guidelines.md#architectural-decision-records-adrs).

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Roadmaps](#roadmaps) |
| [Document Workflow](#document-workflow) |
| [Implementation Plans](#implementation-plans) |
| [RFCs and Proposals](#rfcs-and-proposals) |
| [Anti-Patterns](#anti-patterns) |
| [Directory Structure](#directory-structure) |

---

## Quick Reference

| Document Type | When to Create | Lifecycle | Location |
| --- | --- | --- | --- |
| **Roadmap** | Project/quarter start | Updated quarterly, items archived | `docs/roadmap.md` or `ROADMAP.md` |
| **Implementation Plan** | Before significant feature work | Archived on completion | `docs/planning/` → `docs/planning/archive/` |
| **RFC/Proposal** | When seeking input on approach | Archived after decision | `docs/rfcs/` |
| **Spike/Investigation** | Before unfamiliar work | Deleted or converted to plan | `docs/planning/` |

| Always | Rationale |
| --- | --- |
| **Version control planning docs** | Changes are tracked and reviewable |
| **Link plans to roadmap items** | Traceability from goal to execution |
| **Archive, don't delete** | Preserves context for future reference |
| **Date-stamp archived files** | Enables chronological lookup |

| Never | Rationale |
| --- | --- |
| **Keep stale plans active** | Causes confusion about current direction |
| **Document aspirations as facts** | Misleads about current state |
| **Duplicate between docs** | Creates drift between sources |

---

## Core Principles

| Principle | Guideline | Rationale |
| --- | --- | --- |
| **Living until complete** | Update plans as work progresses | Reflects reality, not original assumptions |
| **Archive after extraction** | Move key info to official docs before archiving | Archives are disposable; docs are permanent |
| **Single source of truth** | One roadmap, one active plan per feature | Prevents conflicting information |
| **Outcome over intent** | Record what was built, not just what was planned | Closing the loop enables learning |
| **Minimal viable planning** | Plan enough to start; refine as you learn | Avoids wasted effort on wrong paths |

> [!IMPORTANT]
> **Archives are historical relics, not documentation.** Archived plans will quickly become outdated and should never be relied upon as authoritative. Before archiving, extract any valuable information into official documentation. The entire archive directory should be deletable at any time without losing critical project knowledge.

---

## Roadmaps

### Roadmap Structure

```markdown
# Roadmap

## Current Quarter (Q1 2024)

| Priority | Feature | Status | Plan |
| --- | --- | --- | --- |
| P0 | User authentication | In Progress | [Plan](planning/auth-implementation.md) |
| P1 | API rate limiting | Not Started | — |
| P2 | Dashboard redesign | Not Started | — |

## Completed

| Feature | Completed | Plan |
| --- | --- | --- |
| Database migration | 2024-01-15 | [Archived](planning/archive/2024-01-15-db-migration.md) |
```

### Roadmap Best Practices

| Practice | Implementation | Rationale |
| --- | --- | --- |
| **Keep it scannable** | Table format, not prose | Quick status checks |
| **Link to details** | Implementation plans, issues | Roadmap stays light |
| **Show status clearly** | Not Started / In Progress / Complete | Current state visible at glance |
| **Archive completed items** | Move to "Completed" section | Reduces active noise |
| **Review quarterly** | Prune, reprioritize, update | Stays relevant |

---

## Document Workflow

Planning documents move through defined stages, with clear locations and responsibilities at each phase.

### Stage-by-Stage Flow

| Stage | Location | Naming | Actions |
| --- | --- | --- | --- |
| **1. Draft** | `docs/planning/` | `PLAN-NNN-feature-name.md` | Write, iterate, seek feedback |
| **2. Under Review** | `docs/planning/` | Same | Gather stakeholder input |
| **3. Approved** | `docs/planning/` | Same | Link from roadmap |
| **4. In Progress** | `docs/planning/` | Same | Update as work progresses |
| **5. Complete** | — | — | Extract to official docs, then archive |
| **6. Archived** | `docs/planning/archive/` | `YYYY-MM-DD-PLAN-NNN-feature-name.md` | Reference only (not authoritative) |

### Version Numbering

| Element | Format | Example | Rationale |
| --- | --- | --- | --- |
| **Plan number** | `PLAN-NNN` | `PLAN-017` | Sequential ID for cross-referencing |
| **Project version** | `vX.Y` | `v2.3` | Ties plan to release cycle |
| **Combined** | `PLAN-NNN-vX.Y` | `PLAN-017-v2.3` | Associates plan with target release |

### Filename Convention

| Stage | Format | Example |
| --- | --- | --- |
| **Active** | `PLAN-NNN-short-name.md` | `PLAN-017-user-auth.md` |
| **Archived** | `YYYY-MM-DD-PLAN-NNN-short-name.md` | `2024-01-15-PLAN-017-user-auth.md` |

---

## Implementation Plans

### When to Write a Plan

| Scope | Plan? | Rationale |
| --- | --- | --- |
| **Multi-day feature** | Yes | Coordinates work, enables review |
| **Cross-team changes** | Yes | Aligns stakeholders |
| **Significant refactor** | Yes | Documents approach before disruption |
| **Bug fix** | No | Just fix it |
| **Small enhancement** | No | Issue description suffices |

### Implementation Plan Template

```markdown
# Implementation Plan: [Feature Name]

## Goal
[One sentence: what this achieves]

## Approach
[2-3 paragraphs: how you'll build it]

## Phases

### Phase 1: [Name]
- [ ] Task 1
- [ ] Task 2

### Phase 2: [Name]
- [ ] Task 3

## Risks
| Risk | Mitigation |
| --- | --- |
| [Risk] | [How to handle] |

## Success Criteria
- [ ] [Measurable outcome]
```

### Plan Lifecycle

| Phase | Document State | Actions |
| --- | --- | --- |
| **Draft** | Created, seeking review | Share for feedback, iterate |
| **Approved** | Ready for execution | Link from roadmap |
| **In Progress** | Being implemented | Update checkboxes, note changes |
| **Completed** | Work finished | Add outcome summary, archive |
| **Abandoned** | Work stopped | Note why, archive or delete |

### Archiving Completed Plans

> [!CAUTION]
> **Archives are not documentation.** They are historical artifacts that will become stale. Before archiving, you MUST extract any valuable information to official docs.

| Step | Action | Rationale |
| --- | --- | --- |
| **1. Extract to official docs** | Move ADRs, architectural insights, and lessons learned to permanent documentation | Official docs survive; archives don't |
| **2. Add outcome summary** | Note at top: what was actually built vs. planned | Captures delta for historical reference |
| **3. Date-stamp filename** | `2024-01-15-PLAN-NNN-feature.md` | Chronological sorting |
| **4. Move to archive** | `docs/planning/archive/` | Separates active from historical |
| **5. Update roadmap** | Link to archived location | Preserves traceability |

### What to Extract Before Archiving

| Extract This | Destination | Rationale |
| --- | --- | --- |
| **Architectural decisions** | ADRs (`docs/adr/`) | Decisions are permanent record |
| **API contracts** | API documentation | Interfaces must be documented |
| **Configuration changes** | README or config docs | Users need current setup info |
| **Lessons learned** | Runbooks or guidelines | Team knowledge preserved |
| **Nothing unique** | Just archive | Plan was purely coordination |

### Archive Deletion Policy

The archive directory exists for historical curiosity, not as a source of truth.

| Policy | Rationale |
| --- | --- |
| **Archives may be deleted at any time** | Forces extraction of valuable info upfront |
| **No critical info should live only in archive** | Single source of truth in official docs |
| **Retention is optional (6-12 months typical)** | Reduces clutter while allowing recent reference |
| **Bulk deletion is safe** | If extraction was done properly |

---

## RFCs and Proposals

### When to Write an RFC

| Situation | RFC? | Rationale |
| --- | --- | --- |
| **Significant architectural change** | Yes | Needs broad input |
| **Breaking API changes** | Yes | Affects consumers |
| **New technology adoption** | Yes | Team should weigh in |
| **Process changes** | Maybe | Depends on impact |
| **Implementation details** | No | Put in implementation plan |

### RFC Template

```markdown
# RFC: [Title]

## Status
[Draft | Under Review | Accepted | Rejected | Superseded]

## Summary
[One paragraph: what you're proposing]

## Motivation
[Why this change is needed]

## Proposal
[Detailed description of the approach]

## Alternatives Considered
| Alternative | Pros | Cons |
| --- | --- | --- |
| [Option A] | [Benefits] | [Drawbacks] |
| [Option B] | [Benefits] | [Drawbacks] |

## Open Questions
- [ ] [Question 1]
- [ ] [Question 2]
```

### RFC Lifecycle

| Status | Meaning | Duration |
| --- | --- | --- |
| **Draft** | Author still developing | Until ready for review |
| **Under Review** | Seeking feedback | 1-2 weeks typical |
| **Accepted** | Approved for implementation | Final state |
| **Rejected** | Not moving forward | Final state |
| **Superseded** | Replaced by newer RFC | Links to replacement |

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| --- | --- | --- |
| **Phantom roadmap** | Exists but never updated | Review quarterly or delete |
| **Plan everything** | Over-planning slows execution | Plan only significant work |
| **Never archive** | Old plans clutter active docs | Archive on completion |
| **Delete history** | Lose context for future decisions | Archive instead |
| **Aspirational roadmaps** | Lists wishes, not commitments | Only include planned work |
| **RFC without deadline** | Review drags indefinitely | Set review period |
| **Plans without outcomes** | Never close the loop | Add completion summary |

---

## Directory Structure

```
docs/
├── roadmap.md              # Current roadmap
├── planning/
│   ├── current-feature.md  # Active implementation plans
│   └── archive/
│       ├── 2024-01-15-auth.md
│       └── 2024-02-01-api-v2.md
└── rfcs/
    ├── 001-new-auth.md     # Active RFCs
    └── archive/
        └── 000-rejected-idea.md
```

---

## See Also

- [Documentation Guidelines](../documentation-guidelines/documentation-guidelines.md) – READMEs, API docs, ADRs
- [PRD for Agents](../prd-for-agents/prd-for-agents.md) – Feature specifications for AI
- [Agentic Workflow](../agentic-workflow/agentic-workflow.md) – PLAN phase consumes these docs
