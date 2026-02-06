# Planning Archive

This directory contains historical planning documents, decision records, and retired documentation.

## Purpose

Per [Planning Documentation](../../../guides/planning-documentation/planning-documentation.md), this archive:

- Preserves context for future contributors
- Documents why decisions were made
- Tracks the evolution of the repository
- Provides historical reference without cluttering active docs

## Contents

Documents are archived here when:

- A planning phase completes (e.g., v1 preparation)
- A decision is finalized and implemented
- A proposal is rejected or superseded
- A roadmap becomes historical

## Active Planning

For current planning documents, see:

- `/docs/planning/` - Active roadmaps, proposals, and decision documents
- `/docs/process/` - Ongoing process documentation

## Archive Structure

Organize archived documents by:

- Year/quarter (e.g., `2026-Q1/`)
- Topic (e.g., `v1-launch/`, `guide-restructuring/`)
- Type (e.g., `decisions/`, `proposals/`, `roadmaps/`)

Use clear, descriptive filenames that include dates.

## Retrieval

If you need to reference archived decisions:

1. Check this directory for relevant historical context
2. Use git history to see the evolution of decisions
3. Link to archived docs in current documentation when providing historical context

## Examples

```
archive/
  2026-Q1/
    v1-success-criteria.md          # Completed v1 planning
    pilot-selection-process.md      # How pilots were chosen
  decisions/
    2026-02-maintenance-cadence.md  # Why quarterly maintenance
```
