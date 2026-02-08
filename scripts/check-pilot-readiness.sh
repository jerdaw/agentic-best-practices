#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VALIDATE_SCRIPT="$REPO_ROOT/scripts/validate-adoption.sh"

PROJECT_DIR="."
PILOT_DIR=".agentic-best-practices/pilot"
MIN_WEEKLY_CHECKINS=1
REQUIRE_RETROSPECTIVE=0
STRICT=0

ERRORS=0
WARNINGS=0
weekly_count=0
retrospective_count=0

print_usage() {
    cat <<'EOF'
Usage:
  bash scripts/check-pilot-readiness.sh [options]

Options:
  --project-dir <path>          Target project directory (default: .)
  --pilot-dir <path>            Project-relative pilot artifact directory (default: .agentic-best-practices/pilot)
  --min-weekly-checkins <n>     Minimum weekly check-in files required (default: 1)
  --require-retrospective       Require a completed retrospective file (retrospective*.md excluding template)
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
    --min-weekly-checkins)
        MIN_WEEKLY_CHECKINS="${2:-}"
        shift 2
        ;;
    --require-retrospective)
        REQUIRE_RETROSPECTIVE=1
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

AGENTS_PATH="$PROJECT_DIR/AGENTS.md"
CLAUDE_PATH="$PROJECT_DIR/CLAUDE.md"

if [[ ! -f "$AGENTS_PATH" ]]; then
    err "AGENTS.md missing at $AGENTS_PATH"
fi

if [[ ! -e "$CLAUDE_PATH" && ! -L "$CLAUDE_PATH" ]]; then
    warn "CLAUDE.md missing at $CLAUDE_PATH"
fi

if [[ -f "$VALIDATE_SCRIPT" ]]; then
    validate_output="$(mktemp)"
    validate_cmd=(bash "$VALIDATE_SCRIPT" --project-dir "$PROJECT_DIR")
    if [[ "$STRICT" -eq 1 ]]; then
        validate_cmd+=(--strict)
    fi
    if ! "${validate_cmd[@]}" >"$validate_output" 2>&1; then
        err "Adoption validation failed. Run validate-adoption.sh and fix reported issues."
        cat "$validate_output" >&2
    fi
    rm -f "$validate_output"
else
    warn "validate-adoption.sh not found at $VALIDATE_SCRIPT"
fi

if [[ ! -d "$PILOT_DIR_ABS" ]]; then
    err "Pilot directory missing at $PILOT_DIR_ABS"
else
    for required_file in kickoff.md weekly-checkin-template.md retrospective-template.md README.md; do
        if [[ ! -f "$PILOT_DIR_ABS/$required_file" ]]; then
            err "Missing pilot artifact file: $PILOT_DIR_ABS/$required_file"
        fi
    done

    if [[ -f "$PILOT_DIR_ABS/kickoff.md" ]] && grep -Fq "{{" "$PILOT_DIR_ABS/kickoff.md"; then
        err "kickoff.md still contains unresolved template tokens"
    fi

    weekly_count="$(find "$PILOT_DIR_ABS" -maxdepth 1 -type f -name 'weekly-*.md' ! -name 'weekly-checkin-template.md' | wc -l | tr -d ' ')"
    if ((weekly_count < MIN_WEEKLY_CHECKINS)); then
        if [[ "$STRICT" -eq 1 ]]; then
            err "Weekly check-ins below target. Required: $MIN_WEEKLY_CHECKINS, found: $weekly_count"
        else
            warn "Weekly check-ins below target. Required: $MIN_WEEKLY_CHECKINS, found: $weekly_count"
        fi
    fi

    retrospective_count="$(find "$PILOT_DIR_ABS" -maxdepth 1 -type f -name 'retrospective*.md' ! -name 'retrospective-template.md' | wc -l | tr -d ' ')"
    if [[ "$REQUIRE_RETROSPECTIVE" -eq 1 && "$retrospective_count" -eq 0 ]]; then
        err "Completed retrospective file not found (expected retrospective*.md excluding template)"
    fi
fi

echo ""
echo "Pilot readiness summary:"
echo "  Project:              $PROJECT_DIR"
echo "  Pilot directory:      $PILOT_DIR_ABS"
if [[ -d "$PILOT_DIR_ABS" ]]; then
    echo "  Weekly check-ins:     $weekly_count"
    echo "  Retrospectives found: $retrospective_count"
fi
echo "  Errors:               $ERRORS"
echo "  Warnings:             $WARNINGS"

if [[ "$ERRORS" -gt 0 ]]; then
    exit 1
fi

if [[ "$STRICT" -eq 1 && "$WARNINGS" -gt 0 ]]; then
    exit 1
fi

echo "Pilot readiness check passed."
