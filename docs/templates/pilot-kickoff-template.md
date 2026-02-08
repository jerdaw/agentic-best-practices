# Pilot Kickoff Checklist

Kickoff template for an external adoption pilot.

| Field | Value |
| --- | --- |
| Project | {{PROJECT_NAME}} |
| Project Directory | {{PROJECT_DIR}} |
| Pilot Owner | {{PILOT_OWNER}} |
| Start Date | {{START_DATE}} |
| Adoption Mode | {{ADOPTION_MODE}} |
| Standards Path | {{STANDARDS_PATH}} |

## Objectives

| Objective | Success Signal | Status |
| --- | --- | --- |
| Validate adoption setup path | `prepare-pilot-project.sh` run succeeds | Not started |
| Validate day-to-day usability | Team reports low friction in weekly updates | Not started |
| Capture gaps for upstream fixes | Issues/feedback filed with concrete reproductions | Not started |

## Kickoff Checklist

| Item | Owner | Status | Notes |
| --- | --- | --- | --- |
| Project selected and team consent confirmed | {{PILOT_OWNER}} | Not started | |
| `AGENTS.md`/`CLAUDE.md` generated or merged | {{PILOT_OWNER}} | Not started | |
| `validate-adoption.sh --strict` passes | {{PILOT_OWNER}} | Not started | |
| Weekly check-in cadence agreed | {{PILOT_OWNER}} | Not started | |
| Feedback issue workflow agreed | {{PILOT_OWNER}} | Not started | |
| Pilot success criteria agreed | {{PILOT_OWNER}} | Not started | |

## Baseline Snapshot

| Metric | Baseline |
| --- | --- |
| AI commits per week | |
| Average review feedback volume | |
| Recurring quality issues | |
| Known project constraints | |

## Risks and Mitigations

| Risk | Probability | Impact | Mitigation |
| --- | --- | --- | --- |
| Team too busy for feedback | Medium | High | Keep updates short and async |
| Guidance conflict with local standards | Medium | Medium | Log override with rationale |
| No measurable signal by week 4 | Low | High | Add explicit weekly metrics |
