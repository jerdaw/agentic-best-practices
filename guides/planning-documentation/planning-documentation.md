# Planning Documentation

Best practices for creating, maintaining, and archiving planning artifacts—roadmaps, implementation plans, RFCs, and
proposals.

> **Scope**: These guidelines apply to project planning documentation. For recording architectural decisions after
> they're made, see [ADRs in Documentation Guidelines](../documentation-guidelines/documentation-guidelines.md#architectural-decision-records-adrs).

## Contents

| Section |
| :--- |
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
| :--- | :--- | :--- | :--- |
| **Roadmap** | Project/quarter start | Updated quarterly, items archived | `docs/roadmap.md` |
| **Implementation Plan** | Before feature work | Archived on completion | `docs/planning/` |
| **RFC/Proposal** | When seeking input | Archived after decision | `docs/rfcs/` |
| **Spike** | Before unfamiliar work | Deleted or converted | `docs/planning/` |

| Always | Rationale |
| :--- | :--- |
| **Version control planning docs** | Changes are tracked and reviewable |
| **Link plans to roadmap items** | Traceability from goal to execution |
| **Archive, don't delete** | Preserves context for future reference |
| **Date-stamp archived files** | Enables chronological lookup |

| Never | Rationale |
| :--- | :--- |
| **Keep stale plans active** | Causes confusion about current direction |
| **Document aspirations as facts** | Misleads about current state |
| **Duplicate between docs** | Creates drift between sources |

---

## Core Principles

| Principle | Guideline | Rationale |
| :--- | :--- | :--- |
| **Living until complete** | Update plans as work progresses | Reflects reality |
| **Archive after extraction** | Move key info to docs before archiving | Docs are permanent |
| **Single source of truth** | One roadmap, one active plan per feature | Prevents conflicting info |
| **Outcome over intent** | Record what was built, not just planned | Enables learning |
| **Minimal viable planning** | Plan enough to start; refine as you learn | Avoids wasted effort |

> [!IMPORTANT]
> **Archives are historical relics, not documentation.** Archived plans will quickly become outdated and should never
> be relied upon as authoritative. Before archiving, extract any valuable information into official documentation.
> The entire archive directory should be deletable at any time without losing critical project knowledge.

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
| :--- | :--- | :--- |
| **Keep it scannable** | Table format, not prose | Quick status checks |
| **Link to details** | Implementation plans, issues | Roadmap stays light |
| **Show status clearly** | Not Started / In Progress / Complete | Visible at glance |
| **Archive completed** | Move to "Completed" section | Reduces active noise |
| **Review quarterly** | Prune, reprioritize, update | Stays relevant |

---

## Document Workflow

Planning documents move through defined stages, with clear locations and responsibilities at each phase.

### Stage-by-Stage Flow

| Stage | Location | Naming | Actions |
| :--- | :--- | :--- | :--- |
| **1. Draft** | `docs/planning/` | `PLAN-NNN-feature.md` | Write, iterate, seek feedback |
| **2. Review** | `docs/planning/` | Same | Gather stakeholder input |
| **3. Approved** | `docs/planning/` | Same | Link from roadmap |
| **4. In Progress** | `docs/planning/` | Same | Update as work progresses |
| **5. Complete** | — | — | Extract to docs, then archive |
| **6. Archived** | `docs/planning/archive/` | `YYYY-MM-DD-PLAN-NNN.md` | Reference only |

### Version Numbering

| Element | Format | Example | Rationale |
| :--- | :--- | :--- | :--- |
| **Plan number** | `PLAN-NNN` | `PLAN-017` | Sequential ID |
| **Project version** | `vX.Y` | `v2.3` | Ties plan to release |
| **Combined** | `PLAN-NNN-vX.Y` | `PLAN-017-v2.3` | Associates plan with release |

### Filename Convention

| Stage | Format | Example |
| :--- | :--- | :--- |
| **Active** | `PLAN-NNN-short-name.md` | `PLAN-017-user-auth.md` |
| **Archived** | `YYYY-MM-DD-PLAN-NNN-name.md` | `2024-01-15-PLAN-017-auth.md` |

---

## Implementation Plans

### When to Write a Plan

| Scope | Plan? | Rationale |
| :--- | :--- | :--- |
| **Multi-day feature** | Yes | Coordinates work, enables review |
| **Cross-team changes** | Yes | Aligns stakeholders |
| **Significant refactor** | Yes | Documents approach |
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

| Phase | State | Actions |
| :--- | :--- | :--- |
| **Draft** | Seeking review | Share for feedback, iterate |
| **Approved** | Ready for execution | Link from roadmap |
| **In Progress** | Implementing | Update checkboxes |
| **Completed** | Finished | Add outcome, archive |
| **Abandoned** | Stopped | Note why, archive |

### Archiving Completed Plans

> [!CAUTION]
> **Archives are not documentation.** They are historical artifacts that will become stale. Before archiving, you MUST
> extract any valuable information to official docs.

| Step | Action | Rationale |
| :--- | :--- | :--- |
| **1. Extract** | Move ADRs, insights to permanent docs | Official docs survive |
| **2. Outcome** | Note at top: built vs. planned | Historial reference |
| **3. Date-stamp** | `2024-01-15-PLAN-NNN-feature.md` | Chronological sorting |
| **4. Archive** | Move to `docs/planning/archive/` | Separate active from historical |
| **5. Roadmap** | Link to archived location | Preserves traceability |

### What to Extract Before Archiving

| Extract This | Destination | Rationale |
| :--- | :--- | :--- |
| **Architectural decisions** | ADRs (`docs/adr/`) | Decisions are permanent record |
| **API contracts** | API documentation | Interfaces must be documented |
| **Config changes** | README or config docs | Users need current setup info |
| **Lessons learned** | Runbooks or guidelines | Team knowledge preserved |

### Archive Deletion Policy

The archive directory exists for historical curiosity, not as a source of truth.

| Policy | Rationale |
| :--- | :--- |
| **Archives may be deleted** | Forces extraction of valuable info |
| **No critical info in archive** | Single source of truth in docs |
| **Retention is optional** | Reduces clutter |
| **Bulk deletion is safe** | If extraction was done properly |

---

## RFCs and Proposals

### When to Write an RFC

| Situation | RFC? | Rationale |
| :--- | :--- | :--- |
| **Significant architectural change** | Yes | Needs broad input |
| **Breaking API changes** | Yes | Affects consumers |
| **New technology adoption** | Yes | Team should weigh in |
| **Process changes** | Maybe | Depends on impact |

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
```

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| :--- | :--- | :--- |
| **Phantom roadmap** | Never updated | Review quarterly or delete |
| **Plan everything** | Slows execution | Plan only significant work |
| **Never archive** | Clutters active docs | Archive on completion |
| **Delete history** | Lose context | Archive instead |
| **Aspiration** | Lists wishes | Only include planned work |
| **No deadline** | Drags indefinitely | Set review period |

---

## Directory Structure

```text
docs/
├── roadmap.md              # Current roadmap
├── planning/
│   ├── active-plan.md      # Active implementation plans
│   └── archive/
│       ├── 2024-01-15.md
│       └── 2024-02-01.md
└── rfcs/
    ├── 001-active.md       # Active RFCs
    └── archive/
        └── 000-rejected.md
```

---

## See Also

- [Documentation Guidelines](../documentation-guidelines/documentation-guidelines.md) – READMEs, API docs, ADRs
- [PRD for Agents](../prd-for-agents/prd-for-agents.md) – Feature specifications for AI
- [Agentic Workflow](../agentic-workflow/agentic-workflow.md) – PLAN phase consumes these docs
