# Pilot Execution Playbook

Operational playbook for running external adoption pilots with consistent setup and feedback capture.

| Field | Value |
| --- | --- |
| Status | Active |
| Last Updated | 2026-02-08 |
| Owner | Maintainer + pilot project owner |
| Scope | 1-2 external pilot repositories |

## Contents

| Section |
| --- |
| [When to Use](#when-to-use) |
| [Pilot Workflow](#pilot-workflow) |
| [Readiness Check](#readiness-check) |
| [Findings Summary](#findings-summary) |
| [Cadence](#cadence) |
| [Exit Criteria](#exit-criteria) |
| [Escalation Paths](#escalation-paths) |

---

## When to Use

| Situation | Use this playbook? | Why |
| --- | --- | --- |
| Preparing first external pilot | Yes | Standardizes setup and baseline capture |
| Rolling out to many repos after pilot | Partially | Reuse checklist/cadence; simplify weekly details |
| Internal doc-only updates | No | Use normal change process |

---

## Pilot Workflow

| Step | Action | Output |
| --- | --- | --- |
| 1. Select repository | Apply `docs/planning/pilot-repo-selection.md` rubric | Chosen pilot repo + owner |
| 2. Prepare project | Run `scripts/prepare-pilot-project.sh` against target repo | Validated `AGENTS.md`/`CLAUDE.md` + pilot artifacts |
| 3. Run readiness check | Run `scripts/check-pilot-readiness.sh` | Early signal for missing setup artifacts |
| 4. Kickoff alignment | Fill `kickoff.md` and agree weekly cadence | Shared baseline + success criteria |
| 5. Run weekly check-ins | Duplicate `weekly-checkin-template.md` each week | Weekly outcomes and blockers |
| 6. Generate findings summary | Run `scripts/summarize-pilot-findings.sh` | Consolidated evidence and backlog intake checklist |
| 7. Log issues | File concrete gaps via `docs/templates/feedback-template.md` | Actionable backlog |
| 8. Close pilot | Fill retrospective template and summarize decisions | Go/no-go and follow-up plan |

### Prepare Project Command

```bash
bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/prepare-pilot-project.sh" \
  --project-dir /path/to/target-repo \
  --standards-path "$AGENTIC_BEST_PRACTICES_HOME" \
  --existing-mode merge \
  --pilot-owner "Team Name"
```

## Readiness Check

Run this after pilot setup and during weekly cadence to detect missing artifacts early.

```bash
bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/check-pilot-readiness.sh" \
  --project-dir /path/to/target-repo \
  --min-weekly-checkins 0 \
  --strict
```

| Option | When to use |
| --- | --- |
| `--min-weekly-checkins 0` | Immediately after kickoff setup (before week 1 artifacts exist). |
| `--min-weekly-checkins 4` | Mid/late pilot to enforce cadence completion. |
| `--require-retrospective` | End-of-pilot gate before final decision review. |

## Findings Summary

Run this during pilot cadence and before retrospective close-out.

```bash
bash "$AGENTIC_BEST_PRACTICES_HOME/scripts/summarize-pilot-findings.sh" \
  --project-dir /path/to/target-repo \
  --pilot-dir ".agentic-best-practices/pilot" \
  --require-retrospective
```

| Output | Use |
| --- | --- |
| `pilot-summary.md` | Weekly + retrospective evidence in one file for release planning. |
| Backlog intake checklist | Converts pilot observations into tracked implementation items. |

---

## Cadence

| Cadence Item | Frequency | Owner | Max Duration |
| --- | --- | --- | --- |
| Async weekly check-in | Weekly | Pilot owner | 15 minutes |
| Sync debrief | Every 2 weeks | Maintainer + pilot owner | 30 minutes |
| Mid-point review | Week 3-4 | Maintainer | 45 minutes |
| Final retrospective | Week 6-8 | Maintainer + stakeholders | 60 minutes |

---

## Exit Criteria

| Criterion | Pass Condition |
| --- | --- |
| Setup reliability | Pilot setup command succeeded and strict validation passed |
| Usage evidence | Weekly check-ins completed for pilot duration |
| Feedback quality | At least one actionable issue or explicit "no gaps" finding |
| Decision clarity | Retrospective includes rollout/iterate decision and owners |

---

## Escalation Paths

| Issue Type | Escalation Path | SLA |
| --- | --- | --- |
| Setup command failure | Open issue in this repo with logs and repro steps | 1 business day |
| Guide conflict/safety issue | File feedback issue with severity High | Same day |
| Process friction (meeting load, unclear ownership) | Maintainer + pilot owner sync | 2 business days |
