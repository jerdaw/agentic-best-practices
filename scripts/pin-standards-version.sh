#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR=""
STANDARDS_PATH="${AGENTIC_BEST_PRACTICES_HOME:-$HOME/agentic-best-practices}"
PINNED_REF=""
PINNED_DIR=".agentic-best-practices/pinned"
PRINT_RELATIVE_ONLY=0

print_usage() {
    cat <<'EOF'
Usage:
  bash scripts/pin-standards-version.sh --project-dir <path> --pinned-ref <git-ref> [options]

Required:
  --project-dir <path>      Target project directory
  --pinned-ref <git-ref>    Git ref to pin (tag, branch, or commit)

Options:
  --standards-path <path>   Source standards repository path (default: $AGENTIC_BEST_PRACTICES_HOME or ~/agentic-best-practices)
  --pinned-dir <path>       Project-relative directory for pinned snapshots (default: .agentic-best-practices/pinned)
  --print-relative-only     Print only the resulting project-relative pinned path
  --help                    Show help

Notes:
  - Uses `git archive` to create a read-only standards snapshot at the pinned ref.
  - Writes `.abp-pin.json` metadata in the snapshot directory.
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

sanitize_ref_name() {
    local ref="$1"
    local sanitized
    sanitized="$(printf '%s' "$ref" | tr '/:@ ' '----' | tr -cd '[:alnum:]._-' )"
    if [[ -z "$sanitized" ]]; then
        sanitized="ref"
    fi
    printf '%s\n' "$sanitized"
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
    --pinned-ref)
        PINNED_REF="${2:-}"
        shift 2
        ;;
    --pinned-dir)
        PINNED_DIR="${2:-}"
        shift 2
        ;;
    --print-relative-only)
        PRINT_RELATIVE_ONLY=1
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

if [[ -z "$PROJECT_DIR" || -z "$PINNED_REF" ]]; then
    echo "Error: --project-dir and --pinned-ref are required." >&2
    print_usage >&2
    exit 1
fi

if [[ ! -d "$PROJECT_DIR" ]]; then
    echo "Error: project directory not found: $PROJECT_DIR" >&2
    exit 1
fi

PROJECT_DIR_ABS="$(cd "$PROJECT_DIR" && pwd)"
STANDARDS_PATH="$(expand_home_path "$STANDARDS_PATH")"
STANDARDS_PATH="$(normalize_path "$STANDARDS_PATH")"

if [[ ! -d "$STANDARDS_PATH" ]]; then
    echo "Error: standards path not found: $STANDARDS_PATH" >&2
    exit 1
fi

if ! git -C "$STANDARDS_PATH" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Error: standards path is not a git repository: $STANDARDS_PATH" >&2
    exit 1
fi

if ! RESOLVED_SHA="$(git -C "$STANDARDS_PATH" rev-parse "${PINNED_REF}^{commit}" 2>/dev/null)"; then
    echo "Error: unable to resolve pinned ref '$PINNED_REF' in $STANDARDS_PATH" >&2
    exit 1
fi

SHORT_SHA="${RESOLVED_SHA:0:12}"
SANITIZED_REF="$(sanitize_ref_name "$PINNED_REF")"
SNAPSHOT_NAME="${SANITIZED_REF}-${SHORT_SHA}"
PINNED_PATH_REL="${PINNED_DIR%/}/${SNAPSHOT_NAME}"
PINNED_PATH_ABS="$PROJECT_DIR_ABS/$PINNED_PATH_REL"

mkdir -p "$PROJECT_DIR_ABS/${PINNED_DIR%/}"

if [[ -d "$PINNED_PATH_ABS" ]]; then
    metadata_file="$PINNED_PATH_ABS/.abp-pin.json"
    if [[ -f "$metadata_file" ]] && grep -Fq "\"resolved_sha\": \"$RESOLVED_SHA\"" "$metadata_file"; then
        if [[ "$PRINT_RELATIVE_ONLY" -eq 1 ]]; then
            printf '%s\n' "$PINNED_PATH_REL"
            exit 0
        fi
        echo "Pinned snapshot already up to date."
        echo "  Ref:      $PINNED_REF"
        echo "  SHA:      $RESOLVED_SHA"
        echo "  Path:     $PINNED_PATH_REL"
        exit 0
    fi
    rm -rf "$PINNED_PATH_ABS"
fi

mkdir -p "$PINNED_PATH_ABS"
git -C "$STANDARDS_PATH" archive --format=tar "$RESOLVED_SHA" | tar -xf - -C "$PINNED_PATH_ABS"

REMOTE_URL="$(git -C "$STANDARDS_PATH" config --get remote.origin.url || true)"
PINNED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

cat >"$PINNED_PATH_ABS/.abp-pin.json" <<EOF
{
  "source_repo_path": "$STANDARDS_PATH",
  "source_repo_remote": "$REMOTE_URL",
  "pinned_ref": "$PINNED_REF",
  "resolved_sha": "$RESOLVED_SHA",
  "snapshot_name": "$SNAPSHOT_NAME",
  "pinned_at_utc": "$PINNED_AT"
}
EOF

if [[ "$PRINT_RELATIVE_ONLY" -eq 1 ]]; then
    printf '%s\n' "$PINNED_PATH_REL"
    exit 0
fi

echo "Pinned standards snapshot created."
echo "  Ref:      $PINNED_REF"
echo "  SHA:      $RESOLVED_SHA"
echo "  Path:     $PINNED_PATH_REL"
