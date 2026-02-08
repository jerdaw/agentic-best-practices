#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="."
PILOT_DIR=".agentic-best-practices/pilot"
OUTPUT_PATH=""
MIN_WEEKLY_CHECKINS=1
REQUIRE_RETROSPECTIVE=0
STRICT=0
PRINT_ONLY=0

ERRORS=0
WARNINGS=0

print_usage() {
    cat <<'EOF'
Usage:
  bash scripts/summarize-pilot-findings.sh [options]

Options:
  --project-dir <path>          Target project directory (default: .)
  --pilot-dir <path>            Project-relative pilot artifact directory (default: .agentic-best-practices/pilot)
  --output <path>               Output markdown file (default: <pilot-dir>/pilot-summary.md)
  --min-weekly-checkins <n>     Minimum weekly check-in files expected (default: 1)
  --require-retrospective       Require at least one completed retrospective file
  --print-only                  Print summary to stdout without writing a file
  --strict                      Fail if warnings are present
  --help                        Show help
EOF
}

err() {
    ERRORS=$((ERRORS + 1))
    echo "ERROR: $1" >&2
}

warn() {
    WARNINGS=$((WARNINGS + 1))
    echo "WARN: $1"
}

expand_home_path() {
    local path="$1"
    if [[ "$path" == "~/"* ]]; then
        printf '%s\n' "$HOME/${path#~/}"
    else
        printf '%s\n' "$path"
    fi
}

normalize_path() {
    local path="$1"
    if [[ "$path" != "/" ]]; then
        path="${path%/}"
    fi
    printf '%s\n' "$path"
}

resolve_path_from_project() {
    local path="$1"
    local project_dir_abs="$2"
    local expanded

    expanded="$(expand_home_path "$path")"
    if [[ "$expanded" == /* ]]; then
        normalize_path "$expanded"
    else
        normalize_path "$project_dir_abs/$expanded"
    fi
}

escape_table_value() {
    local value="${1:-}"
    value="${value//|/\\|}"
    value="${value//$'\r'/}"
    if [[ -z "${value// }" ]]; then
        printf '%s\n' "N/A"
    else
        printf '%s\n' "$value"
    fi
}

extract_table_value() {
    local file="$1"
    local key="$2"
    sed -n "s/^| ${key//\//\\/} | \\(.*\\) |$/\\1/p" "$file" | head -n 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
    --project-dir)
        PROJECT_DIR="${2:-}"
        shift 2
        ;;
    --pilot-dir)
        PILOT_DIR="${2:-}"
        shift 2
        ;;
    --output)
        OUTPUT_PATH="${2:-}"
        shift 2
        ;;
    --min-weekly-checkins)
        MIN_WEEKLY_CHECKINS="${2:-}"
        shift 2
        ;;
    --require-retrospective)
        REQUIRE_RETROSPECTIVE=1
        shift
        ;;
    --print-only)
        PRINT_ONLY=1
        shift
        ;;
    --strict)
        STRICT=1
        shift
        ;;
    --help)
        print_usage
        exit 0
        ;;
    *)
        echo "Unknown argument: $1" >&2
        print_usage >&2
        exit 1
        ;;
    esac
done

if [[ ! -d "$PROJECT_DIR" ]]; then
    echo "Error: project directory not found: $PROJECT_DIR" >&2
    exit 1
fi

if ! [[ "$MIN_WEEKLY_CHECKINS" =~ ^[0-9]+$ ]]; then
    echo "Error: --min-weekly-checkins must be a non-negative integer." >&2
    exit 1
fi

PROJECT_DIR_ABS="$(cd "$PROJECT_DIR" && pwd)"
PILOT_DIR_ABS="$(resolve_path_from_project "$PILOT_DIR" "$PROJECT_DIR_ABS")"

if [[ ! -d "$PILOT_DIR_ABS" ]]; then
    err "Pilot directory not found: $PILOT_DIR_ABS"
fi

if [[ -z "$OUTPUT_PATH" ]]; then
    OUTPUT_PATH="$PILOT_DIR_ABS/pilot-summary.md"
else
    OUTPUT_PATH="$(resolve_path_from_project "$OUTPUT_PATH" "$PROJECT_DIR_ABS")"
fi

weekly_rows=""
weekly_count=0
retrospective_count=0
latest_retrospective=""

if [[ -d "$PILOT_DIR_ABS" ]]; then
    mapfile -t weekly_files < <(find "$PILOT_DIR_ABS" -maxdepth 1 -type f -name 'weekly-*.md' ! -name 'weekly-checkin-template.md' | sort)
    weekly_count="${#weekly_files[@]}"
    if ((weekly_count < MIN_WEEKLY_CHECKINS)); then
        warn "Weekly check-ins below target. Required: $MIN_WEEKLY_CHECKINS, found: $weekly_count"
    fi

    for weekly_file in "${weekly_files[@]}"; do
        weekly_name="$(basename "$weekly_file")"
        reporting_period="$(escape_table_value "$(extract_table_value "$weekly_file" "Reporting Period")")"
        blockers="$(escape_table_value "$(extract_table_value "$weekly_file" "Blockers encountered")")"
        critical_defects="$(escape_table_value "$(extract_table_value "$weekly_file" "Critical defects linked to guidance")")"
        weekly_rows+=$'| `'"$weekly_name"$'` | '"$reporting_period"$' | '"$blockers"$' | '"$critical_defects"$' |\n'
    done

    mapfile -t retrospective_files < <(find "$PILOT_DIR_ABS" -maxdepth 1 -type f -name 'retrospective*.md' ! -name 'retrospective-template.md' | sort)
    retrospective_count="${#retrospective_files[@]}"
    if ((retrospective_count > 0)); then
        latest_retrospective="${retrospective_files[$((retrospective_count - 1))]}"
    elif [[ "$REQUIRE_RETROSPECTIVE" -eq 1 ]]; then
        err "No completed retrospective found (expected retrospective*.md excluding template)."
    else
        warn "No completed retrospective found yet."
    fi
fi

generated_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
project_name="$(basename "$PROJECT_DIR_ABS")"

summary_file="$(mktemp)"
{
    echo "# Pilot Findings Summary"
    echo ""
    echo "Generated by \`scripts/summarize-pilot-findings.sh\` on $generated_at."
    echo ""
    echo "| Field | Value |"
    echo "| --- | --- |"
    echo "| Project | $project_name |"
    echo "| Project Directory | $PROJECT_DIR_ABS |"
    echo "| Pilot Directory | $PILOT_DIR_ABS |"
    echo "| Weekly Check-ins Found | $weekly_count |"
    echo "| Retrospectives Found | $retrospective_count |"
    echo ""
    echo "## Weekly Snapshot"
    echo ""
    echo "| Weekly File | Reporting Period | Blockers Encountered | Critical Defects |"
    echo "| --- | --- | --- | --- |"
    if [[ -n "$weekly_rows" ]]; then
        printf '%s' "$weekly_rows"
    else
        echo "| N/A | N/A | N/A | N/A |"
    fi
    echo ""
    echo "## Retrospective Snapshot"
    echo ""
    echo "| Field | Value |"
    echo "| --- | --- |"
    if [[ -n "$latest_retrospective" ]]; then
        rollout_decision="$(escape_table_value "$(extract_table_value "$latest_retrospective" "Continue rollout / pause / iterate")")"
        preferred_mode="$(escape_table_value "$(extract_table_value "$latest_retrospective" "Preferred adoption mode (latest or pinned)")")"
        follow_up="$(escape_table_value "$(extract_table_value "$latest_retrospective" "Follow-up owners and deadlines")")"
        echo "| Latest retrospective | \`$(basename "$latest_retrospective")\` |"
        echo "| Rollout decision | $rollout_decision |"
        echo "| Preferred adoption mode | $preferred_mode |"
        echo "| Follow-up owners/deadlines | $follow_up |"
    else
        echo "| Latest retrospective | N/A |"
        echo "| Rollout decision | N/A |"
        echo "| Preferred adoption mode | N/A |"
        echo "| Follow-up owners/deadlines | N/A |"
    fi
    echo ""
    echo "## Backlog Intake Checklist"
    echo ""
    echo "| Item | Owner | Status |"
    echo "| --- | --- | --- |"
    echo "| Review weekly blockers and defects from all weekly files | Maintainer + pilot owner | Pending |"
    echo "| Convert confirmed gaps into feedback issues using \`docs/templates/feedback-template.md\` | Maintainer + contributors | Pending |"
    echo "| Map accepted issues into next release backlog and roadmap milestones | Maintainer | Pending |"
} >"$summary_file"

if [[ "$PRINT_ONLY" -eq 1 ]]; then
    cat "$summary_file"
else
    mkdir -p "$(dirname "$OUTPUT_PATH")"
    mv "$summary_file" "$OUTPUT_PATH"
    summary_file=""
    echo "Pilot summary written to: $OUTPUT_PATH"
fi

if [[ -n "$summary_file" && -f "$summary_file" ]]; then
    rm -f "$summary_file"
fi

echo "Summary checks:"
echo "  Errors:   $ERRORS"
echo "  Warnings: $WARNINGS"

if ((ERRORS > 0)); then
    exit 1
fi

if [[ "$STRICT" -eq 1 && "$WARNINGS" -gt 0 ]]; then
    exit 1
fi

echo "Pilot findings summary complete."
