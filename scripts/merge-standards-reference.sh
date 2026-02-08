#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PROJECT_DIR=""
STANDARDS_PATH="${AGENTIC_BEST_PRACTICES_HOME:-$HOME/agentic-best-practices}"

MANAGED_BEGIN="<!-- BEGIN MANAGED: STANDARDS_REFERENCE -->"
MANAGED_END="<!-- END MANAGED: STANDARDS_REFERENCE -->"

print_usage() {
    cat <<'EOF'
Usage:
  bash scripts/merge-standards-reference.sh --project-dir <path> [options]

Required:
  --project-dir <path>          Target project directory with an existing AGENTS.md

Options:
  --standards-path <path>       Location of agentic-best-practices (default: $AGENTIC_BEST_PRACTICES_HOME or ~/agentic-best-practices)
  --help                        Show help

Behavior:
  - Removes existing Standards Reference section (managed or unmanaged)
  - Inserts a managed Standards Reference block near the top of AGENTS.md
  - Creates a timestamped backup of AGENTS.md before writing changes
EOF
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

backup_if_exists() {
    local target="$1"
    if [[ -e "$target" || -L "$target" ]]; then
        local timestamp
        timestamp="$(date +%Y%m%d%H%M%S)"
        local backup="${target}.bak.${timestamp}"
        mv "$target" "$backup"
        printf '%s\n' "$backup"
    fi
}

strip_existing_standards_sections() {
    local input_file="$1"
    local output_file="$2"
    local begin_marker="$3"
    local end_marker="$4"

    awk -v begin_marker="$begin_marker" -v end_marker="$end_marker" '
        BEGIN {
            in_managed = 0
            in_unmanaged = 0
        }
        {
            if ($0 == begin_marker) {
                in_managed = 1
                next
            }
            if (in_managed) {
                if ($0 == end_marker) {
                    in_managed = 0
                }
                next
            }
            if (!in_unmanaged && $0 ~ /^##[[:space:]]+Standards Reference[[:space:]]*$/) {
                in_unmanaged = 1
                next
            }
            if (in_unmanaged && $0 ~ /^##[[:space:]]+/) {
                in_unmanaged = 0
            }
            if (in_unmanaged) {
                next
            }
            print
        }
    ' "$input_file" >"$output_file"
}

insert_managed_block() {
    local input_file="$1"
    local output_file="$2"
    local block_file="$3"

    awk -v block_file="$block_file" '
        function print_block(    line) {
            while ((getline line < block_file) > 0) {
                print line
            }
            close(block_file)
        }
        BEGIN {
            inserted = 0
        }
        {
            if (!inserted && $0 ~ /^##[[:space:]]+/) {
                if (NR > 1) {
                    print ""
                }
                print_block()
                print ""
                inserted = 1
            }
            print
        }
        END {
            if (!inserted) {
                if (NR > 0) {
                    print ""
                }
                print_block()
            }
        }
    ' "$input_file" >"$output_file"
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

PROJECT_DIR_ABS="$(cd "$PROJECT_DIR" && pwd)"
STANDARDS_PATH_FOR_DOC="$(expand_home_path "$STANDARDS_PATH")"
STANDARDS_PATH_FOR_DOC="$(normalize_path "$STANDARDS_PATH_FOR_DOC")"

if [[ "$STANDARDS_PATH_FOR_DOC" == /* ]]; then
    STANDARDS_PATH_RESOLVED="$STANDARDS_PATH_FOR_DOC"
else
    STANDARDS_PATH_RESOLVED="$PROJECT_DIR_ABS/$STANDARDS_PATH_FOR_DOC"
fi
STANDARDS_PATH_RESOLVED="$(normalize_path "$STANDARDS_PATH_RESOLVED")"

if [[ ! -d "$STANDARDS_PATH_RESOLVED" ]]; then
    echo "Error: standards path does not exist: $STANDARDS_PATH_RESOLVED" >&2
    exit 1
fi

AGENTS_PATH="$PROJECT_DIR/AGENTS.md"
if [[ ! -f "$AGENTS_PATH" ]]; then
    echo "Error: AGENTS.md not found in project. Use adopt-into-project.sh for first-time setup." >&2
    exit 1
fi

block_file="$(mktemp)"
cat >"$block_file" <<EOF
$MANAGED_BEGIN
## Standards Reference

This project follows organizational standards defined in \`$STANDARDS_PATH_FOR_DOC/\`.

**Before implementing**, consult the relevant guide:

| Topic | Guide |
| --- | --- |
| Error handling | \`$STANDARDS_PATH_FOR_DOC/guides/error-handling/error-handling.md\` |
| Logging | \`$STANDARDS_PATH_FOR_DOC/guides/logging-practices/logging-practices.md\` |
| API design | \`$STANDARDS_PATH_FOR_DOC/guides/api-design/api-design.md\` |
| Documentation | \`$STANDARDS_PATH_FOR_DOC/guides/documentation-guidelines/documentation-guidelines.md\` |
| Code style | \`$STANDARDS_PATH_FOR_DOC/guides/coding-guidelines/coding-guidelines.md\` |
| Comments | \`$STANDARDS_PATH_FOR_DOC/guides/commenting-guidelines/commenting-guidelines.md\` |

For other topics, check \`$STANDARDS_PATH_FOR_DOC/README.md\` for the full guide index (all guides are in \`$STANDARDS_PATH_FOR_DOC/guides/\`).

**Deviation policy**: Do not deviate from these standards without explicit approval. If deviation is necessary, document it in the Project-Specific Overrides section with rationale.
$MANAGED_END
EOF

tmp_stripped="$(mktemp)"
tmp_merged="$(mktemp)"

strip_existing_standards_sections "$AGENTS_PATH" "$tmp_stripped" "$MANAGED_BEGIN" "$MANAGED_END"
insert_managed_block "$tmp_stripped" "$tmp_merged" "$block_file"

if cmp -s "$AGENTS_PATH" "$tmp_merged"; then
    rm -f "$block_file" "$tmp_stripped" "$tmp_merged"
    echo "No changes needed. Standards Reference already up to date."
    exit 0
fi

backup_path="$(backup_if_exists "$AGENTS_PATH")"
mv "$tmp_merged" "$AGENTS_PATH"
rm -f "$block_file" "$tmp_stripped"

echo "Merged Standards Reference into AGENTS.md."
echo "  Project:   $PROJECT_DIR"
echo "  AGENTS.md: $AGENTS_PATH"
echo "  Backup:    $backup_path"
echo "  Standards: $STANDARDS_PATH_FOR_DOC"
echo ""
echo "Next step: bash \"$REPO_ROOT/scripts/validate-adoption.sh\" --project-dir \"$PROJECT_DIR\" --expect-standards-path \"$STANDARDS_PATH_FOR_DOC\""
