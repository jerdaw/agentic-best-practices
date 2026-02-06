# Maintenance Cadence Decision

**Date**: 2026-02-06
**Status**: Recommended
**Decision**: Quarterly maintenance with event-driven updates

## Context

The agentic-best-practices repository requires ongoing maintenance to remain accurate and relevant. Per the planning documentation (`docs/planning/v1-success-criteria.md`), we evaluated four maintenance cadence options:

1. Monthly reviews (high overhead)
2. Quarterly reviews (balanced)
3. Annual reviews (may become stale)
4. Hybrid (event-driven + scheduled)

## Decision

**Option 4 (Hybrid)** is recommended as the maintenance cadence:

### Scheduled Maintenance: Quarterly

Every 3 months, perform a structured review:

| Activity | Responsibility | Estimated Time |
| --- | --- | --- |
| Run `scripts/check-guide-freshness.sh` | Maintainer | 5 min |
| Review CI link checker results | Maintainer | 15 min |
| Update health dashboard | Maintainer | 15 min |
| Triage community feedback | Maintainer | 30 min |
| Update 2-3 stale guides | Maintainer | 2-3 hours |

**Total time investment**: ~3-4 hours per quarter

### Event-Driven Updates: As Needed

Immediate updates when:

- Breaking changes in referenced tools (e.g., Claude API changes)
- Community reports critical errors (via issue templates)
- Security vulnerabilities discovered
- New best practices emerge from pilot projects

## Rationale

| Factor | Why Hybrid Works |
| --- | --- |
| **Freshness** | Quarterly reviews prevent guides from becoming outdated |
| **Responsiveness** | Event-driven updates address critical issues immediately |
| **Sustainability** | Predictable quarterly schedule prevents maintainer burnout |
| **Quality** | Regular cadence ensures dashboard and metrics stay current |
| **Community** | Fast response to feedback builds trust |

## Monitoring

Track maintenance effectiveness via the health dashboard (`docs/process/health-dashboard.md`):

- Percentage of guides updated in last 6 months
- Average age of guides
- Number of stale guides (>6 months)
- Community feedback response time

If >25% of guides become stale between quarterly reviews, consider increasing frequency to bimonthly.

## Exceptions

Some guides may need more frequent updates:

- **AI-Assisted Development** guides - AI tools evolve rapidly (monthly checks recommended)
- **Tool Configuration** - Updates when tool versions change
- **API Design** - Updates when referenced APIs/standards change

## Implementation

1. Create calendar reminders for quarterly reviews (Feb, May, Aug, Nov)
2. Set up GitHub issue templates for community feedback (✅ Complete)
3. Enable CI link checking on weekly schedule (✅ Complete)
4. Document freshness check script (✅ Complete)
5. Update CLAUDE.md with maintenance expectations

## Review

This decision should be reviewed after:

- 2 quarters of implementation (Aug 2026)
- Significant community growth
- Pilot project feedback indicates different needs

## See Also

- [Health Dashboard](health-dashboard.md) - Current repository metrics
- [Planning Documentation Guide](../../guides/planning-documentation/planning-documentation.md) - Documentation standards
- `scripts/check-guide-freshness.sh` - Automated freshness checking
