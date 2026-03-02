#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PROJECT_DIR=""
STANDARDS_PATH="${AGENTIC_BEST_PRACTICES_HOME:-$HOME/agentic-best-practices}"
CONFIG_FILE=""
STANDARDS_TOPICS=""
DEVIATION_POLICY="Do not deviate from these standards without explicit approval. If deviation is necessary, document it in the Project-Specific Overrides section with rationale."

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
  --config-file <path>          Optional adoption config file (KEY=VALUE lines)
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

trim_whitespace() {
    local value="$1"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    printf '%s\n' "$value"
}

strip_wrapping_quotes() {
    local value="$1"
    if [[ "$value" == \"*\" && "$value" == *\" ]]; then
        value="${value:1:-1}"
    elif [[ "$value" == \'*\' && "$value" == *\' ]]; then
        value="${value:1:-1}"
    fi
    printf '%s\n' "$value"
}

load_adoption_config() {
    local config_path="$1"
    local line
    local key
    local value
    local line_no=0

    if [[ ! -f "$config_path" ]]; then
        echo "Error: config file not found: $config_path" >&2
        exit 1
    fi

    while IFS= read -r line || [[ -n "$line" ]]; do
        line_no=$((line_no + 1))
        line="$(trim_whitespace "$line")"
        [[ -z "$line" || "$line" == \#* ]] && continue

        if [[ "$line" != *=* ]]; then
            echo "Error: invalid config entry at $config_path:$line_no (expected KEY=VALUE)." >&2
            exit 1
        fi

        key="$(trim_whitespace "${line%%=*}")"
        value="$(trim_whitespace "${line#*=}")"
        value="$(strip_wrapping_quotes "$value")"

        case "$key" in
        STANDARDS_TOPICS) STANDARDS_TOPICS="$value" ;;
        DEVIATION_POLICY) DEVIATION_POLICY="$value" ;;
        "")
            ;;
        *)
            ;;
        esac
    done <"$config_path"
}

resolve_guide_doc_path() {
    local standards_path="$1"
    local guide_value="$2"
    local guide_path

    guide_path="$(expand_home_path "$guide_value")"
    if [[ "$guide_path" == *"{{STANDARDS_PATH}}"* ]]; then
        guide_path="${guide_path//\{\{STANDARDS_PATH\}\}/$standards_path}"
    elif [[ "$guide_path" == /* ]]; then
        :
    else
        guide_path="$standards_path/${guide_path#./}"
    fi
    printf '%s\n' "$guide_path"
}

build_standards_rows() {
    local standards_path="$1"
    local topics_config="$2"
    local default_topics
    local topics_source
    local rows=""
    local entry
    local topic
    local guide_value
    local guide_path

    default_topics="Error handling|guides/error-handling/error-handling.md;Logging|guides/logging-practices/logging-practices.md;API design|guides/api-design/api-design.md;Documentation|guides/documentation-guidelines/documentation-guidelines.md;Code style|guides/coding-guidelines/coding-guidelines.md;Comments|guides/commenting-guidelines/commenting-guidelines.md"
    topics_source="$topics_config"
    if [[ -z "$topics_source" ]]; then
        topics_source="$default_topics"
    fi

    IFS=';' read -r -a topics_array <<<"$topics_source"
    for entry in "${topics_array[@]}"; do
        entry="$(trim_whitespace "$entry")"
        [[ -z "$entry" ]] && continue
        if [[ "$entry" != *"|"* ]]; then
            echo "Error: invalid STANDARDS_TOPICS entry '$entry' (expected 'Topic|path')." >&2
            exit 1
        fi

        topic="$(trim_whitespace "${entry%%|*}")"
        guide_value="$(trim_whitespace "${entry#*|}")"
        guide_path="$(resolve_guide_doc_path "$standards_path" "$guide_value")"

        if [[ -z "$topic" || -z "$guide_path" ]]; then
            echo "Error: invalid STANDARDS_TOPICS entry '$entry' (topic/path cannot be empty)." >&2
            exit 1
        fi

        rows+=$'| '"$topic"$' | `'"$guide_path"$'` |\n'
    done

    if [[ -z "$rows" ]]; then
        echo "Error: standards topics list is empty after parsing." >&2
        exit 1
    fi

    printf '%s' "${rows%$'\n'}"
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
    --config-file)
        CONFIG_FILE="${2:-}"
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

if [[ -n "$CONFIG_FILE" ]]; then
    CONFIG_FILE="$(expand_home_path "$CONFIG_FILE")"
    load_adoption_config "$CONFIG_FILE"
fi

AGENTS_PATH="$PROJECT_DIR/AGENTS.md"
if [[ ! -f "$AGENTS_PATH" ]]; then
    echo "Error: AGENTS.md not found in project. Use adopt-into-project.sh for first-time setup." >&2
    exit 1
fi

standards_rows="$(build_standards_rows "$STANDARDS_PATH_FOR_DOC" "$STANDARDS_TOPICS")"
block_file="$(mktemp)"
cat >"$block_file" <<EOF
$MANAGED_BEGIN
## Standards Reference

This project follows organizational standards defined in \`$STANDARDS_PATH_FOR_DOC/\`.

**Before implementing**, consult the relevant guide:

| Topic | Guide |
| --- | --- |
$standards_rows

For other topics, check \`$STANDARDS_PATH_FOR_DOC/README.md\` for the full guide index (all guides are in \`$STANDARDS_PATH_FOR_DOC/guides/\`).

**Deviation policy**: $DEVIATION_POLICY
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
if [[ -n "$CONFIG_FILE" ]]; then
    echo "  Config:    $CONFIG_FILE"
fi
echo ""
echo "Next step: bash \"$REPO_ROOT/scripts/validate-adoption.sh\" --project-dir \"$PROJECT_DIR\" --expect-standards-path \"$STANDARDS_PATH_FOR_DOC\""
