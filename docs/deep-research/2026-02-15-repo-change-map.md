# Repo Change Map (2026-02-15)

Targeted updates derived from synthesized, high-confidence findings.

## Planned File Updates

| File | Change | Why |
| --- | --- | --- |
| `guides/documentation-guidelines/documentation-guidelines.md` | Add decision matrix for where knowledge lives; add context profiles; tighten "what not to document" for sensitive operations | Existing guidance is strong but missing explicit placement matrix + sensitivity model |
| `guides/commenting-guidelines/commenting-guidelines.md` | Add mandatory comment cases and linkability rules (ADR/issue/test references) | Make "why" comments and traceability rules explicit and testable |
| `guides/agents-md/agents-md-guidelines.md` | Add documentation map and verification-gate guidance | Align with proven command/boundary patterns for agent reliability |
| `guides/doc-maintenance/doc-maintenance.md` | Add PR doc checklist + minimum doc CI gates | Strengthen anti-rot controls using existing repo workflows |
| `adoption/template-agents.md` | Add "Documentation Map" and docs update expectations in template | Push high-confidence baseline into adopter defaults |
| `.github/pull_request_template.md` | Add docs sync and sensitivity checklist | Enforce docs updates and safe documentation at PR time |
| `docs/README.md` | Index new deep-research evaluation artifacts | Keep docs navigation current |

## Validation Plan

| Check | Command |
| --- | --- |
| Markdown lint | `npm run lint:md` |
| Navigation consistency | `npm run validate` |
| Direct navigation check | `bash ./scripts/validate-navigation.sh` |

## Change Boundaries

| Boundary | Rule |
| --- | --- |
| Taxonomy | No new directories |
| Guide discoverability | No new guide files; only targeted updates to existing guides |
| Authorship metadata | No AI attribution additions |
| Unrelated edits | Ignore stashed script changes until explicitly requested |
