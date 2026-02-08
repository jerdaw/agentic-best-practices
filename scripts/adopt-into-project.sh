#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DEFAULT_TEMPLATE="$REPO_ROOT/adoption/template-agents.md"
MERGE_SCRIPT="$REPO_ROOT/scripts/merge-standards-reference.sh"
PIN_SCRIPT="$REPO_ROOT/scripts/pin-standards-version.sh"

PROJECT_DIR=""
STANDARDS_PATH="${AGENTIC_BEST_PRACTICES_HOME:-$HOME/agentic-best-practices}"
TEMPLATE_PATH="$DEFAULT_TEMPLATE"
FORCE=0
CLAUDE_MODE="auto" # auto | symlink | copy | skip
EXISTING_MODE="fail" # fail | overwrite | merge
ADOPTION_MODE="latest" # latest | pinned
PINNED_REF=""
PINNED_DIR=".agentic-best-practices/pinned"

PROJECT_NAME=""
AGENT_ROLE="project-focused software engineer"
PROJECT_DESCRIPTION="this project"
PRIORITY_ONE="Correctness over speed"
PRIORITY_TWO="Security over convenience"
PRIORITY_THREE="Readability over cleverness"

print_usage() {
    cat <<'EOF'
Usage:
  bash scripts/adopt-into-project.sh --project-dir <path> [options]

Required:
  --project-dir <path>          Target project directory

Options:
  --standards-path <path>       Location of agentic-best-practices (default: $AGENTIC_BEST_PRACTICES_HOME or ~/agentic-best-practices)
  --template-path <path>        Template file to render (default: adoption/template-agents.md in this repo)
  --project-name <name>         Project name override (default: basename of --project-dir)
  --agent-role <text>           Agent role text
  --project-description <text>  Short project description
  --priority-one <text>         First priority
  --priority-two <text>         Second priority
  --priority-three <text>       Third priority
  --adoption-mode <mode>        latest | pinned (default: latest)
  --pinned-ref <git-ref>        Git ref to pin when --adoption-mode pinned
  --pinned-dir <path>           Project-relative pinned snapshots dir (default: .agentic-best-practices/pinned)
  --existing-mode <mode>        fail | overwrite | merge (default: fail)
  --claude-mode <mode>          auto | symlink | copy | skip (default: auto)
  --force                       Overwrite/sync existing AGENTS.md/CLAUDE.md where needed (backs up previous files)
  --help                        Show help

Examples:
  bash scripts/adopt-into-project.sh --project-dir ~/work/my-api --standards-path ~/agentic-best-practices
  bash scripts/adopt-into-project.sh --project-dir . --adoption-mode pinned --pinned-ref v1.0.0
  bash scripts/adopt-into-project.sh --project-dir . --existing-mode merge --claude-mode skip
  bash scripts/adopt-into-project.sh --project-dir . --force --claude-mode copy
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

replace_literal() {
    local file="$1"
    local search="$2"
    local replace="$3"
    local temp_file

    temp_file="$(mktemp)"
    SEARCH_LITERAL="$search" REPLACE_LITERAL="$replace" perl -0777 -pe 's/\Q$ENV{SEARCH_LITERAL}\E/$ENV{REPLACE_LITERAL}/g' "$file" >"$temp_file"
    mv "$temp_file" "$file"
}

detect_package_manager() {
    local project_dir="$1"
    if [[ -f "$project_dir/pnpm-lock.yaml" ]]; then
        printf '%s\n' "pnpm"
        return
    fi
    if [[ -f "$project_dir/yarn.lock" ]]; then
        printf '%s\n' "yarn"
        return
    fi
    if [[ -f "$project_dir/bun.lock" || -f "$project_dir/bun.lockb" ]]; then
        printf '%s\n' "bun"
        return
    fi
    printf '%s\n' "npm"
}

has_package_script() {
    local project_dir="$1"
    local script_name="$2"
    local package_json="$project_dir/package.json"
    [[ -f "$package_json" ]] || return 1
    grep -Eq "\"$script_name\"[[:space:]]*:" "$package_json"
}

command_for_script() {
    local package_manager="$1"
    local script_name="$2"
    local project_dir="$3"

    if ! has_package_script "$project_dir" "$script_name"; then
        printf '%s\n' "TODO: set command for $script_name"
        return
    fi

    case "$package_manager" in
    yarn)
        printf '%s\n' "yarn $script_name"
        ;;
    bun)
        printf '%s\n' "bun run $script_name"
        ;;
    *)
        printf '%s\n' "$package_manager run $script_name"
        ;;
    esac
}

detect_language() {
    local project_dir="$1"
    if [[ -f "$project_dir/tsconfig.json" || -f "$project_dir/tsconfig.base.json" ]]; then
        printf '%s\n' "TypeScript"
        return
    fi
    if [[ -f "$project_dir/package.json" ]]; then
        printf '%s\n' "JavaScript/TypeScript"
        return
    fi
    printf '%s\n' "TBD"
}

render_template() {
    local template_path="$1"
    local rendered_path="$2"
    local standards_path="$3"
    local project_name="$4"
    local package_manager="$5"
    local project_dir="$6"

    local dev_cmd
    local test_cmd
    local coverage_cmd
    local lint_cmd
    local typecheck_cmd
    local build_cmd
    local language
    local runtime

    dev_cmd="$(command_for_script "$package_manager" "dev" "$project_dir")"
    test_cmd="$(command_for_script "$package_manager" "test" "$project_dir")"
    coverage_cmd="$(command_for_script "$package_manager" "test:coverage" "$project_dir")"
    lint_cmd="$(command_for_script "$package_manager" "lint" "$project_dir")"
    typecheck_cmd="$(command_for_script "$package_manager" "typecheck" "$project_dir")"
    build_cmd="$(command_for_script "$package_manager" "build" "$project_dir")"
    language="$(detect_language "$project_dir")"

    if [[ -f "$project_dir/package.json" ]]; then
        runtime="Node.js"
    else
        runtime="TBD"
    fi

    {
        sed -n '1p' "$template_path"
        echo
        sed -n '/^## Agent Role/,$p' "$template_path"
    } >"$rendered_path"

    replace_literal "$rendered_path" "[Project Name]" "$project_name"
    replace_literal "$rendered_path" "[specific role, e.g., \"security-conscious backend developer\"]" "$AGENT_ROLE"
    replace_literal "$rendered_path" "[brief project description]" "$PROJECT_DESCRIPTION"
    replace_literal "$rendered_path" "[First priority, e.g., \"Security over convenience\"]" "$PRIORITY_ONE"
    replace_literal "$rendered_path" "[Second priority, e.g., \"Correctness over speed\"]" "$PRIORITY_TWO"
    replace_literal "$rendered_path" "[Third priority, e.g., \"Readability over cleverness\"]" "$PRIORITY_THREE"

    replace_literal "$rendered_path" "[e.g., TypeScript]" "$language"
    replace_literal "$rendered_path" "[e.g., 5.x]" "TBD"
    replace_literal "$rendered_path" "[e.g., Express]" "TBD"
    replace_literal "$rendered_path" "[e.g., 4.x]" "TBD"
    replace_literal "$rendered_path" "[e.g., Node.js]" "$runtime"
    replace_literal "$rendered_path" "[e.g., 20+]" "TBD"
    replace_literal "$rendered_path" "[e.g., PostgreSQL]" "TBD"
    replace_literal "$rendered_path" "[e.g., 15]" "TBD"
    replace_literal "$rendered_path" "[e.g., Jest]" "TBD"
    replace_literal "$rendered_path" "[e.g., 29.x]" "TBD"

    replace_literal "$rendered_path" "[npm run dev]" "$dev_cmd"
    replace_literal "$rendered_path" "[npm test]" "$test_cmd"
    replace_literal "$rendered_path" "[npm run test:coverage]" "$coverage_cmd"
    replace_literal "$rendered_path" "[npm run lint]" "$lint_cmd"
    replace_literal "$rendered_path" "[npm run typecheck]" "$typecheck_cmd"
    replace_literal "$rendered_path" "[npm run build]" "$build_cmd"

    replace_literal "$rendered_path" "[Start dev server with hot reload]" "Start development environment"
    replace_literal "$rendered_path" "[Run all tests]" "Run the default test suite"
    replace_literal "$rendered_path" "[Run tests with coverage report]" "Run tests with coverage"
    replace_literal "$rendered_path" "[Run linter]" "Run lint checks"
    replace_literal "$rendered_path" "[Run type checker]" "Run type checks"
    replace_literal "$rendered_path" "[Production build]" "Build production artifacts"

    replace_literal "$rendered_path" "[Add your own]" "None"
    replace_literal "$rendered_path" "[Rationale]" "N/A"
    replace_literal "$rendered_path" "[Topic]" "Topic"
    replace_literal "$rendered_path" "[What best-practices says]" "Describe the standard"
    replace_literal "$rendered_path" "[What this project does instead]" "Describe the override"
    replace_literal "$rendered_path" "[Why the deviation is necessary]" "Explain rationale"
    replace_literal "$rendered_path" "[Date]" "YYYY-MM-DD"

    replace_literal "$rendered_path" "[src/index.ts]" "TBD"
    replace_literal "$rendered_path" "[src/config/]" "TBD"
    replace_literal "$rendered_path" "[src/routes/]" "TBD"
    replace_literal "$rendered_path" "[src/services/]" "TBD"
    replace_literal "$rendered_path" "[src/types/]" "TBD"

    replace_literal "$rendered_path" "{{STANDARDS_PATH}}" "$standards_path"
    replace_literal "$rendered_path" "~/agentic-best-practices" "$standards_path"
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

write_claude_file() {
    local agents_path="$1"
    local claude_path="$2"
    local claude_mode="$3"

    if [[ "$claude_mode" == "copy" ]]; then
        cp "$agents_path" "$claude_path"
    elif [[ "$claude_mode" == "symlink" ]]; then
        ln -s AGENTS.md "$claude_path"
    else
        if ln -s AGENTS.md "$claude_path" 2>/dev/null; then
            :
        else
            cp "$agents_path" "$claude_path"
        fi
    fi
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
    --template-path)
        TEMPLATE_PATH="${2:-}"
        shift 2
        ;;
    --project-name)
        PROJECT_NAME="${2:-}"
        shift 2
        ;;
    --agent-role)
        AGENT_ROLE="${2:-}"
        shift 2
        ;;
    --project-description)
        PROJECT_DESCRIPTION="${2:-}"
        shift 2
        ;;
    --priority-one)
        PRIORITY_ONE="${2:-}"
        shift 2
        ;;
    --priority-two)
        PRIORITY_TWO="${2:-}"
        shift 2
        ;;
    --priority-three)
        PRIORITY_THREE="${2:-}"
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
    echo "Error: project directory does not exist: $PROJECT_DIR" >&2
    exit 1
fi

STANDARDS_PATH="$(expand_home_path "$STANDARDS_PATH")"

if [[ ! -d "$STANDARDS_PATH" ]]; then
    echo "Error: standards path does not exist: $STANDARDS_PATH" >&2
    exit 1
fi

if [[ -z "$PROJECT_NAME" ]]; then
    PROJECT_NAME="$(basename "$PROJECT_DIR")"
fi

case "$CLAUDE_MODE" in
auto | symlink | copy | skip) ;;
*)
    echo "Error: --claude-mode must be one of: auto, symlink, copy, skip" >&2
    exit 1
    ;;
esac

case "$EXISTING_MODE" in
fail | overwrite | merge) ;;
*)
    echo "Error: --existing-mode must be one of: fail, overwrite, merge" >&2
    exit 1
    ;;
esac

case "$ADOPTION_MODE" in
latest | pinned) ;;
*)
    echo "Error: --adoption-mode must be one of: latest, pinned" >&2
    exit 1
    ;;
esac

if [[ "$FORCE" -eq 1 && "$EXISTING_MODE" == "fail" ]]; then
    EXISTING_MODE="overwrite"
fi

AGENTS_PATH="$PROJECT_DIR/AGENTS.md"
CLAUDE_PATH="$PROJECT_DIR/CLAUDE.md"
if [[ -e "$AGENTS_PATH" && "$EXISTING_MODE" == "fail" ]]; then
    echo "Error: AGENTS.md already exists. Use --existing-mode merge, --existing-mode overwrite, or --force." >&2
    exit 1
fi

EFFECTIVE_STANDARDS_PATH="$STANDARDS_PATH"
if [[ "$ADOPTION_MODE" == "pinned" ]]; then
    if [[ -z "$PINNED_REF" ]]; then
        echo "Error: --pinned-ref is required when --adoption-mode pinned." >&2
        exit 1
    fi
    if [[ ! -f "$PIN_SCRIPT" ]]; then
        echo "Error: pin script not found: $PIN_SCRIPT" >&2
        exit 1
    fi
    EFFECTIVE_STANDARDS_PATH="$(bash "$PIN_SCRIPT" \
        --project-dir "$PROJECT_DIR" \
        --standards-path "$STANDARDS_PATH" \
        --pinned-ref "$PINNED_REF" \
        --pinned-dir "$PINNED_DIR" \
        --print-relative-only)"
fi

operation="rendered-template"

if [[ -e "$AGENTS_PATH" ]]; then
    if [[ "$EXISTING_MODE" == "merge" ]]; then
        if [[ ! -f "$MERGE_SCRIPT" ]]; then
            echo "Error: merge script not found: $MERGE_SCRIPT" >&2
            exit 1
        fi
        bash "$MERGE_SCRIPT" --project-dir "$PROJECT_DIR" --standards-path "$EFFECTIVE_STANDARDS_PATH"
        operation="merged-standards-reference"
    else
        if [[ ! -f "$TEMPLATE_PATH" ]]; then
            echo "Error: template file not found: $TEMPLATE_PATH" >&2
            exit 1
        fi
        backup_if_exists "$AGENTS_PATH" >/dev/null || true
        tmp_rendered="$(mktemp)"
        package_manager="$(detect_package_manager "$PROJECT_DIR")"
        render_template "$TEMPLATE_PATH" "$tmp_rendered" "$EFFECTIVE_STANDARDS_PATH" "$PROJECT_NAME" "$package_manager" "$PROJECT_DIR"
        mv "$tmp_rendered" "$AGENTS_PATH"
        operation="overwrote-existing-agents"
    fi
else
    if [[ ! -f "$TEMPLATE_PATH" ]]; then
        echo "Error: template file not found: $TEMPLATE_PATH" >&2
        exit 1
    fi
    tmp_rendered="$(mktemp)"
    package_manager="$(detect_package_manager "$PROJECT_DIR")"
    render_template "$TEMPLATE_PATH" "$tmp_rendered" "$EFFECTIVE_STANDARDS_PATH" "$PROJECT_NAME" "$package_manager" "$PROJECT_DIR"
    mv "$tmp_rendered" "$AGENTS_PATH"
    operation="rendered-template"
fi

claude_status="skipped"
if [[ "$CLAUDE_MODE" != "skip" ]]; then
    if [[ -e "$CLAUDE_PATH" || -L "$CLAUDE_PATH" ]]; then
        if [[ "$FORCE" -eq 1 ]]; then
            backup_if_exists "$CLAUDE_PATH" >/dev/null || true
            write_claude_file "$AGENTS_PATH" "$CLAUDE_PATH" "$CLAUDE_MODE"
            claude_status="overwritten"
        else
            if [[ -L "$CLAUDE_PATH" && "$(readlink "$CLAUDE_PATH")" == "AGENTS.md" ]]; then
                claude_status="kept-existing-symlink"
            elif [[ -f "$CLAUDE_PATH" ]] && cmp -s "$AGENTS_PATH" "$CLAUDE_PATH"; then
                claude_status="kept-existing-copy"
            else
                claude_status="kept-existing-different"
                echo "Warning: CLAUDE.md exists and differs from AGENTS.md. Use --force to overwrite or --claude-mode skip to ignore." >&2
            fi
        fi
    else
        write_claude_file "$AGENTS_PATH" "$CLAUDE_PATH" "$CLAUDE_MODE"
        claude_status="created"
    fi
fi

echo "Adoption bootstrap complete ($operation)."
echo "  Project:   $PROJECT_DIR"
echo "  AGENTS.md: $AGENTS_PATH"
if [[ "$CLAUDE_MODE" == "skip" ]]; then
    echo "  CLAUDE.md: skipped"
else
    echo "  CLAUDE.md: $CLAUDE_PATH ($claude_status)"
fi
echo "  Mode:      $ADOPTION_MODE"
if [[ "$ADOPTION_MODE" == "pinned" ]]; then
    echo "  Pinned ref: $PINNED_REF"
fi
echo "  Standards source: $STANDARDS_PATH"
echo "  Standards path:   $EFFECTIVE_STANDARDS_PATH"
echo ""
echo "Next step: bash \"$REPO_ROOT/scripts/validate-adoption.sh\" --project-dir \"$PROJECT_DIR\" --expect-standards-path \"$EFFECTIVE_STANDARDS_PATH\""
