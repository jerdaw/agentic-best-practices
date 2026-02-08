#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ADOPT_SCRIPT="$REPO_ROOT/scripts/adopt-into-project.sh"
VALIDATE_SCRIPT="$REPO_ROOT/scripts/validate-adoption.sh"
PREPARE_PILOT_SCRIPT="$REPO_ROOT/scripts/prepare-pilot-project.sh"
READINESS_SCRIPT="$REPO_ROOT/scripts/check-pilot-readiness.sh"
SUMMARY_SCRIPT="$REPO_ROOT/scripts/summarize-pilot-findings.sh"

if [[ ! -f "$ADOPT_SCRIPT" || ! -f "$VALIDATE_SCRIPT" || ! -f "$PREPARE_PILOT_SCRIPT" || ! -f "$READINESS_SCRIPT" || ! -f "$SUMMARY_SCRIPT" ]]; then
    echo "Error: required scripts not found." >&2
    exit 1
fi

WORK_DIR="$(mktemp -d /tmp/abp-adoption-smoke-XXXXXX)"
trap 'rm -rf "$WORK_DIR"' EXIT

NEW_PROJECT="$WORK_DIR/new-project"
mkdir -p "$NEW_PROJECT"
cat >"$NEW_PROJECT/package.json" <<'EOF'
{
  "name": "new-project",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "echo dev",
    "test": "echo test",
    "test:coverage": "echo test:coverage",
    "lint": "echo lint",
    "typecheck": "echo typecheck",
    "build": "echo build"
  }
}
EOF

# Scenario 1: new project bootstrap should produce strict-valid adoption files.
bash "$ADOPT_SCRIPT" \
    --project-dir "$NEW_PROJECT" \
    --standards-path "$REPO_ROOT" \
    --project-description "adoption smoke test project" \
    --claude-mode auto \
    >/dev/null

bash "$VALIDATE_SCRIPT" \
    --project-dir "$NEW_PROJECT" \
    --expect-standards-path "$REPO_ROOT" \
    --strict \
    >/dev/null

# Scenario 2: strict validation should fail before merge, then pass after merge.
MERGE_PROJECT="$WORK_DIR/merge-project"
mkdir -p "$MERGE_PROJECT"
cat >"$MERGE_PROJECT/AGENTS.md" <<'EOF'
# AGENTS.md

## Agent Role

You are a maintainer.

## Tech Stack

| Layer | Technology | Version |
| --- | --- | --- |
| Language | TypeScript | 5.x |

## Key Commands

```bash
npm test
npm run lint
```

## Boundaries

| Level | Action | Why |
| --- | --- | --- |
| **Always** | Run lint | Quality gate |
| **Never** | Commit secrets | Security |
EOF

if bash "$VALIDATE_SCRIPT" \
    --project-dir "$MERGE_PROJECT" \
    --expect-standards-path "$REPO_ROOT" \
    --strict \
    >/dev/null 2>&1; then
    echo "Error: expected strict validation to fail before Standards Reference merge." >&2
    exit 1
fi

bash "$ADOPT_SCRIPT" \
    --project-dir "$MERGE_PROJECT" \
    --standards-path "$REPO_ROOT" \
    --existing-mode merge \
    --claude-mode auto \
    >/dev/null

if ! grep -Fq "BEGIN MANAGED: STANDARDS_REFERENCE" "$MERGE_PROJECT/AGENTS.md"; then
    echo "Error: expected managed Standards Reference markers after merge." >&2
    exit 1
fi

bash "$VALIDATE_SCRIPT" \
    --project-dir "$MERGE_PROJECT" \
    --expect-standards-path "$REPO_ROOT" \
    --strict \
    >/dev/null

bash "$ADOPT_SCRIPT" \
    --project-dir "$MERGE_PROJECT" \
    --standards-path "$REPO_ROOT" \
    --existing-mode merge \
    --claude-mode auto \
    >/dev/null

standards_count="$(grep -Ec '^##[[:space:]]+Standards Reference[[:space:]]*$' "$MERGE_PROJECT/AGENTS.md" || true)"
if [[ "$standards_count" -ne 1 ]]; then
    echo "Error: expected exactly one Standards Reference section after idempotent merge (found: $standards_count)." >&2
    exit 1
fi

# Scenario 3: existing project overwrite mode should back up and pass strict validation.
OVERWRITE_PROJECT="$WORK_DIR/overwrite-project"
mkdir -p "$OVERWRITE_PROJECT"
cat >"$OVERWRITE_PROJECT/package.json" <<'EOF'
{
  "name": "overwrite-project",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "echo dev",
    "test": "echo test",
    "test:coverage": "echo test:coverage",
    "lint": "echo lint",
    "typecheck": "echo typecheck",
    "build": "echo build"
  }
}
EOF

cat >"$OVERWRITE_PROJECT/AGENTS.md" <<'EOF'
# AGENTS.md

## Agent Role

You are a maintainer.
EOF

if bash "$ADOPT_SCRIPT" --project-dir "$OVERWRITE_PROJECT" --standards-path "$REPO_ROOT" >/dev/null 2>&1; then
    echo "Error: expected bootstrap to fail when AGENTS.md exists and --force is not set." >&2
    exit 1
fi

bash "$ADOPT_SCRIPT" \
    --project-dir "$OVERWRITE_PROJECT" \
    --standards-path "$REPO_ROOT" \
    --existing-mode overwrite \
    --project-description "existing project smoke test" \
    --claude-mode copy \
    >/dev/null

if ! ls "$OVERWRITE_PROJECT"/AGENTS.md.bak.* >/dev/null 2>&1; then
    echo "Error: expected AGENTS.md backup file after overwrite." >&2
    exit 1
fi

bash "$VALIDATE_SCRIPT" \
    --project-dir "$OVERWRITE_PROJECT" \
    --expect-standards-path "$REPO_ROOT" \
    --strict \
    >/dev/null

# Scenario 4: pinned mode should create project-local snapshot with metadata and strict-valid output.
PINNED_PROJECT="$WORK_DIR/pinned-project"
PINNED_REF_SHA="$(git -C "$REPO_ROOT" rev-parse HEAD)"
mkdir -p "$PINNED_PROJECT"
cat >"$PINNED_PROJECT/package.json" <<'EOF'
{
  "name": "pinned-project",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "echo dev",
    "test": "echo test",
    "test:coverage": "echo test:coverage",
    "lint": "echo lint",
    "typecheck": "echo typecheck",
    "build": "echo build"
  }
}
EOF

bash "$ADOPT_SCRIPT" \
    --project-dir "$PINNED_PROJECT" \
    --standards-path "$REPO_ROOT" \
    --adoption-mode pinned \
    --pinned-ref "$PINNED_REF_SHA" \
    --claude-mode auto \
    >/dev/null

bash "$VALIDATE_SCRIPT" \
    --project-dir "$PINNED_PROJECT" \
    --strict \
    >/dev/null

PINNED_STANDARDS_PATH="$(sed -n 's/^This project follows organizational standards defined in `\([^`]*\)\/\?`\./\1/p' "$PINNED_PROJECT/AGENTS.md" | head -n 1)"
if [[ -z "$PINNED_STANDARDS_PATH" ]]; then
    echo "Error: expected pinned standards path in AGENTS.md." >&2
    exit 1
fi

PINNED_METADATA_PATH="$PINNED_PROJECT/$PINNED_STANDARDS_PATH/.abp-pin.json"
if [[ ! -f "$PINNED_METADATA_PATH" ]]; then
    echo "Error: expected pinned metadata file at $PINNED_METADATA_PATH." >&2
    exit 1
fi

if ! grep -Fq "\"resolved_sha\": \"$PINNED_REF_SHA\"" "$PINNED_METADATA_PATH"; then
    echo "Error: pinned metadata resolved_sha does not match expected commit." >&2
    exit 1
fi

# Scenario 5: pilot preparation should scaffold pilot artifacts and remain idempotent.
PILOT_PROJECT="$WORK_DIR/pilot-project"
mkdir -p "$PILOT_PROJECT"
cat >"$PILOT_PROJECT/package.json" <<'EOF'
{
  "name": "pilot-project",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "echo dev",
    "test": "echo test",
    "test:coverage": "echo test:coverage",
    "lint": "echo lint",
    "typecheck": "echo typecheck",
    "build": "echo build"
  }
}
EOF

bash "$PREPARE_PILOT_SCRIPT" \
    --project-dir "$PILOT_PROJECT" \
    --standards-path "$REPO_ROOT" \
    --project-name "pilot-project" \
    --pilot-owner "pilot-owner" \
    >/dev/null

for pilot_file in \
    "$PILOT_PROJECT/.agentic-best-practices/pilot/kickoff.md" \
    "$PILOT_PROJECT/.agentic-best-practices/pilot/weekly-checkin-template.md" \
    "$PILOT_PROJECT/.agentic-best-practices/pilot/retrospective-template.md" \
    "$PILOT_PROJECT/.agentic-best-practices/pilot/README.md"; do
    if [[ ! -f "$pilot_file" ]]; then
        echo "Error: expected pilot artifact file at $pilot_file." >&2
        exit 1
    fi
done

bash "$PREPARE_PILOT_SCRIPT" \
    --project-dir "$PILOT_PROJECT" \
    --standards-path "$REPO_ROOT" \
    --project-name "pilot-project" \
    --pilot-owner "pilot-owner" \
    >/dev/null

bash "$READINESS_SCRIPT" \
    --project-dir "$PILOT_PROJECT" \
    --min-weekly-checkins 0 \
    --strict \
    >/dev/null

cat >"$PILOT_PROJECT/.agentic-best-practices/pilot/weekly-01.md" <<'EOF'
# Pilot Weekly Check-In

| Field | Value |
| --- | --- |
| Project | pilot-project |
| Week Number | Week 1 |
| Pilot Owner | pilot-owner |
| Reporting Period | 2026-02-01 to 2026-02-07 |
| Adoption Mode | latest |
| Standards Path | /tmp/standards |

## Delivery Signals

| Metric | Value | Notes |
| --- | --- | --- |
| AI-assisted commits this week | 4 | Stable |
| PRs merged with AI assistance | 2 | No blockers |
| Blockers encountered | 1 | Guide mismatch |
| Critical defects linked to guidance | 0 | None |
EOF

cat >"$PILOT_PROJECT/.agentic-best-practices/pilot/retrospective-01.md" <<'EOF'
# Pilot Retrospective Template

| Field | Value |
| --- | --- |
| Project | pilot-project |
| Pilot Owner | pilot-owner |
| Pilot Start Date | 2026-02-01 |
| Pilot End Date | 2026-02-08 |
| Adoption Mode | latest |
| Standards Path | /tmp/standards |

## Decision Record

| Decision | Rationale |
| --- | --- |
| Continue rollout / pause / iterate | Continue rollout |
| Preferred adoption mode (latest or pinned) | latest |
| Follow-up owners and deadlines | maintainer by 2026-02-15 |
EOF

bash "$SUMMARY_SCRIPT" \
    --project-dir "$PILOT_PROJECT" \
    --pilot-dir ".agentic-best-practices/pilot" \
    --require-retrospective \
    --strict \
    >/dev/null

if [[ ! -f "$PILOT_PROJECT/.agentic-best-practices/pilot/pilot-summary.md" ]]; then
    echo "Error: expected pilot summary output file." >&2
    exit 1
fi

if ! grep -Fq "Backlog Intake Checklist" "$PILOT_PROJECT/.agentic-best-practices/pilot/pilot-summary.md"; then
    echo "Error: expected backlog checklist section in pilot summary." >&2
    exit 1
fi

# Scenario 6: config-driven adoption should render custom standards rows and policy.
CONFIG_PROJECT="$WORK_DIR/config-project"
mkdir -p "$CONFIG_PROJECT/.agentic-best-practices"
cat >"$CONFIG_PROJECT/package.json" <<'EOF'
{
  "name": "config-project",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "echo dev",
    "test": "echo test",
    "test:coverage": "echo test:coverage",
    "lint": "echo lint",
    "typecheck": "echo typecheck",
    "build": "echo build"
  }
}
EOF

cat >"$CONFIG_PROJECT/.agentic-best-practices/adoption.env" <<'EOF'
AGENT_ROLE=platform reliability engineer
PROJECT_DESCRIPTION=service with strict SLO targets
PRIORITY_ONE=Reliability over speed
PRIORITY_TWO=Security over convenience
PRIORITY_THREE=Readability over cleverness
STANDARDS_TOPICS=Resilience|guides/resilience-patterns/resilience-patterns.md;Observability|guides/observability-patterns/observability-patterns.md;Testing|guides/testing-strategy/testing-strategy.md
DEVIATION_POLICY=Only deviate with explicit maintainer approval and documented rollback path.
LINT_CMD=npm run lint -- --max-warnings=0
EOF

bash "$ADOPT_SCRIPT" \
    --project-dir "$CONFIG_PROJECT" \
    --standards-path "$REPO_ROOT" \
    --config-file "$CONFIG_PROJECT/.agentic-best-practices/adoption.env" \
    --claude-mode auto \
    >/dev/null

bash "$VALIDATE_SCRIPT" \
    --project-dir "$CONFIG_PROJECT" \
    --expect-standards-path "$REPO_ROOT" \
    --strict \
    >/dev/null

if ! grep -Fq "| Resilience | \`$REPO_ROOT/guides/resilience-patterns/resilience-patterns.md\` |" "$CONFIG_PROJECT/AGENTS.md"; then
    echo "Error: expected custom standards topic row in config-driven AGENTS.md." >&2
    exit 1
fi

if ! grep -Fq "**Deviation policy**: Only deviate with explicit maintainer approval and documented rollback path." "$CONFIG_PROJECT/AGENTS.md"; then
    echo "Error: expected custom deviation policy in config-driven AGENTS.md." >&2
    exit 1
fi

if ! grep -Fq "npm run lint -- --max-warnings=0" "$CONFIG_PROJECT/AGENTS.md"; then
    echo "Error: expected command override in config-driven AGENTS.md." >&2
    exit 1
fi

# Scenario 7: non-Node stack defaults should render usable commands and metadata.
RUST_PROJECT="$WORK_DIR/rust-project"
mkdir -p "$RUST_PROJECT/src"
cat >"$RUST_PROJECT/Cargo.toml" <<'EOF'
[package]
name = "rust-project"
version = "0.1.0"
edition = "2021"
EOF
cat >"$RUST_PROJECT/src/main.rs" <<'EOF'
fn main() {
    println!("hello");
}
EOF

bash "$ADOPT_SCRIPT" \
    --project-dir "$RUST_PROJECT" \
    --standards-path "$REPO_ROOT" \
    --claude-mode auto \
    >/dev/null

bash "$VALIDATE_SCRIPT" \
    --project-dir "$RUST_PROJECT" \
    --expect-standards-path "$REPO_ROOT" \
    --strict \
    >/dev/null

if ! grep -Fq "| Language | Rust | TBD |" "$RUST_PROJECT/AGENTS.md"; then
    echo "Error: expected Rust language detection in AGENTS.md." >&2
    exit 1
fi

if ! grep -Fq "cargo clippy --all-targets --all-features -- -D warnings" "$RUST_PROJECT/AGENTS.md"; then
    echo "Error: expected Rust lint command defaults in AGENTS.md." >&2
    exit 1
fi

if grep -Fq "TODO: set command for" "$RUST_PROJECT/AGENTS.md"; then
    echo "Error: non-Node defaults should avoid TODO command placeholders." >&2
    exit 1
fi

echo "Adoption smoke simulation passed."
