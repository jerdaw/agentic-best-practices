#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ADOPT_SCRIPT="$REPO_ROOT/scripts/adopt-into-project.sh"
VALIDATE_SCRIPT="$REPO_ROOT/scripts/validate-adoption.sh"

KICKOFF_TEMPLATE="$REPO_ROOT/docs/templates/pilot-kickoff-template.md"
WEEKLY_TEMPLATE="$REPO_ROOT/docs/templates/pilot-weekly-checkin-template.md"
RETRO_TEMPLATE="$REPO_ROOT/docs/templates/pilot-retrospective-template.md"

PROJECT_DIR=""
STANDARDS_PATH="${AGENTIC_BEST_PRACTICES_HOME:-$HOME/agentic-best-practices}"
ADOPTION_MODE="latest" # latest | pinned
PINNED_REF=""
PINNED_DIR=".agentic-best-practices/pinned"
EXISTING_MODE="merge" # fail | overwrite | merge
CLAUDE_MODE="auto" # auto | symlink | copy | skip
FORCE=0

PILOT_DIR=".agentic-best-practices/pilot"
PROJECT_NAME=""
PILOT_OWNER="TBD"
START_DATE="$(date +%Y-%m-%d)"
OVERWRITE=0

print_usage() {
    cat <<'USAGE'
Usage:
  bash scripts/prepare-pilot-project.sh --project-dir <path> [options]

Required:
  --project-dir <path>          Target project directory

Adoption options:
  --standards-path <path>       Location of agentic-best-practices (default: $AGENTIC_BEST_PRACTICES_HOME or ~/agentic-best-practices)
  --adoption-mode <mode>        latest | pinned (default: latest)
  --pinned-ref <git-ref>        Required when --adoption-mode pinned
  --pinned-dir <path>           Project-relative pinned snapshots dir (default: .agentic-best-practices/pinned)
  --existing-mode <mode>        fail | overwrite | merge (default: merge)
  --claude-mode <mode>          auto | symlink | copy | skip (default: auto)
  --force                       Forwarded to adopt script for overwrite/sync behavior

Pilot artifact options:
  --pilot-dir <path>            Project-relative pilot artifact directory (default: .agentic-best-practices/pilot)
  --project-name <name>         Project name used in generated pilot files (default: basename of --project-dir)
  --pilot-owner <text>          Pilot owner for generated templates (default: TBD)
  --start-date <YYYY-MM-DD>     Pilot start date in generated templates (default: today)
  --overwrite                   Overwrite existing pilot artifact files
  --help                        Show help

Examples:
  bash scripts/prepare-pilot-project.sh --project-dir ~/work/service-a --standards-path ~/agentic-best-practices
  bash scripts/prepare-pilot-project.sh --project-dir . --adoption-mode pinned --pinned-ref v1.0.0 --pilot-owner "Platform Team"
USAGE
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

replace_literal() {
    local file="$1"
    local search="$2"
    local replace="$3"
    local temp_file

    temp_file="$(mktemp)"
    SEARCH_LITERAL="$search" REPLACE_LITERAL="$replace" perl -0777 -pe 's/\Q$ENV{SEARCH_LITERAL}\E/$ENV{REPLACE_LITERAL}/g' "$file" >"$temp_file"
    mv "$temp_file" "$file"
}

write_template_file() {
    local src="$1"
    local dest="$2"
    local standards_path="$3"

    if [[ -f "$dest" && "$OVERWRITE" -ne 1 ]]; then
        echo "Skipping existing pilot artifact: $dest"
        return
    fi

    cp "$src" "$dest"
    replace_literal "$dest" "{{PROJECT_NAME}}" "$PROJECT_NAME"
    replace_literal "$dest" "{{PROJECT_DIR}}" "$PROJECT_DIR_ABS"
    replace_literal "$dest" "{{PILOT_OWNER}}" "$PILOT_OWNER"
    replace_literal "$dest" "{{START_DATE}}" "$START_DATE"
    replace_literal "$dest" "{{ADOPTION_MODE}}" "$ADOPTION_MODE"
    replace_literal "$dest" "{{STANDARDS_PATH}}" "$standards_path"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
    --project-dir)
        PROJECT_DIR="${2:-}"
        shift 2
        ;;
    --standards-path)
        STANDARDS_PATH="${2:-}"
        shift 2
        ;;
    --adoption-mode)
        ADOPTION_MODE="${2:-}"
        shift 2
        ;;
    --pinned-ref)
        PINNED_REF="${2:-}"
        shift 2
        ;;
    --pinned-dir)
        PINNED_DIR="${2:-}"
        shift 2
        ;;
    --existing-mode)
        EXISTING_MODE="${2:-}"
        shift 2
        ;;
    --claude-mode)
        CLAUDE_MODE="${2:-}"
        shift 2
        ;;
    --force)
        FORCE=1
        shift
        ;;
    --pilot-dir)
        PILOT_DIR="${2:-}"
        shift 2
        ;;
    --project-name)
        PROJECT_NAME="${2:-}"
        shift 2
        ;;
    --pilot-owner)
        PILOT_OWNER="${2:-}"
        shift 2
        ;;
    --start-date)
        START_DATE="${2:-}"
        shift 2
        ;;
    --overwrite)
        OVERWRITE=1
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

if [[ -z "$PROJECT_DIR" ]]; then
    echo "Error: --project-dir is required." >&2
    print_usage >&2
    exit 1
fi

if [[ ! -d "$PROJECT_DIR" ]]; then
    echo "Error: project directory not found: $PROJECT_DIR" >&2
    exit 1
fi

if [[ "$ADOPTION_MODE" != "latest" && "$ADOPTION_MODE" != "pinned" ]]; then
    echo "Error: --adoption-mode must be latest or pinned." >&2
    exit 1
fi

if [[ "$ADOPTION_MODE" == "pinned" && -z "$PINNED_REF" ]]; then
    echo "Error: --pinned-ref is required when --adoption-mode pinned." >&2
    exit 1
fi

for required in "$ADOPT_SCRIPT" "$VALIDATE_SCRIPT" "$KICKOFF_TEMPLATE" "$WEEKLY_TEMPLATE" "$RETRO_TEMPLATE"; do
    if [[ ! -f "$required" ]]; then
        echo "Error: required file not found: $required" >&2
        exit 1
    fi
done

PROJECT_DIR_ABS="$(cd "$PROJECT_DIR" && pwd)"
STANDARDS_PATH="$(expand_home_path "$STANDARDS_PATH")"

if [[ -z "$PROJECT_NAME" ]]; then
    PROJECT_NAME="$(basename "$PROJECT_DIR_ABS")"
fi

if [[ ! "$START_DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    echo "Error: --start-date must be in YYYY-MM-DD format." >&2
    exit 1
fi

adopt_cmd=(
    bash "$ADOPT_SCRIPT"
    --project-dir "$PROJECT_DIR"
    --standards-path "$STANDARDS_PATH"
    --adoption-mode "$ADOPTION_MODE"
    --existing-mode "$EXISTING_MODE"
    --claude-mode "$CLAUDE_MODE"
)

if [[ "$ADOPTION_MODE" == "pinned" ]]; then
    adopt_cmd+=(--pinned-ref "$PINNED_REF" --pinned-dir "$PINNED_DIR")
fi

if [[ "$FORCE" -eq 1 ]]; then
    adopt_cmd+=(--force)
fi

"${adopt_cmd[@]}"

validate_cmd=(bash "$VALIDATE_SCRIPT" --project-dir "$PROJECT_DIR" --strict)
if [[ "$ADOPTION_MODE" == "latest" ]]; then
    validate_cmd+=(--expect-standards-path "$STANDARDS_PATH")
fi
"${validate_cmd[@]}"

EFFECTIVE_STANDARDS_PATH="$(sed -n 's/^This project follows organizational standards defined in `\([^`]*\)\/?`\./\1/p' "$PROJECT_DIR/AGENTS.md" | head -n 1)"
if [[ -z "$EFFECTIVE_STANDARDS_PATH" ]]; then
    EFFECTIVE_STANDARDS_PATH="$STANDARDS_PATH"
fi

PILOT_DIR_ABS="$(resolve_path_from_project "$PILOT_DIR" "$PROJECT_DIR_ABS")"
mkdir -p "$PILOT_DIR_ABS"

write_template_file "$KICKOFF_TEMPLATE" "$PILOT_DIR_ABS/kickoff.md" "$EFFECTIVE_STANDARDS_PATH"
write_template_file "$WEEKLY_TEMPLATE" "$PILOT_DIR_ABS/weekly-checkin-template.md" "$EFFECTIVE_STANDARDS_PATH"
write_template_file "$RETRO_TEMPLATE" "$PILOT_DIR_ABS/retrospective-template.md" "$EFFECTIVE_STANDARDS_PATH"

README_PATH="$PILOT_DIR_ABS/README.md"
if [[ ! -f "$README_PATH" || "$OVERWRITE" -eq 1 ]]; then
    cat >"$README_PATH" <<README
# Adoption Pilot Artifacts

Generated by agentic-best-practices \`scripts/prepare-pilot-project.sh\` on $START_DATE.

| File | Purpose |
| --- | --- |
| kickoff.md | Pilot setup checklist and baseline metadata |
| weekly-checkin-template.md | Weekly progress and friction tracking |
| retrospective-template.md | End-of-pilot outcomes and decisions |

| Context | Value |
| --- | --- |
| Project | $PROJECT_NAME |
| Project directory | $PROJECT_DIR_ABS |
| Adoption mode | $ADOPTION_MODE |
| Standards path in AGENTS | $EFFECTIVE_STANDARDS_PATH |
| Pilot owner | $PILOT_OWNER |

## Suggested Workflow

1. Fill \`kickoff.md\` before week 1 starts.
2. Duplicate \`weekly-checkin-template.md\` each week (for example, \`weekly-01.md\`).
3. File concrete issues using \`$EFFECTIVE_STANDARDS_PATH/docs/templates/feedback-template.md\` when guidance fails.
4. Complete \`retrospective-template.md\` at pilot end and link resulting change requests.
README
fi

echo ""
echo "Pilot preparation complete."
echo "  Project:           $PROJECT_DIR_ABS"
echo "  Adoption mode:     $ADOPTION_MODE"
echo "  Standards path:    $EFFECTIVE_STANDARDS_PATH"
echo "  Pilot artifacts:   $PILOT_DIR_ABS"
echo ""
echo "Next: fill kickoff.md and start weekly check-ins."
