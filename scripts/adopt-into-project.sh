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
CONFIG_FILE=""
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

STANDARDS_TOPICS=""
DEVIATION_POLICY="Do not deviate from these standards without explicit approval. If deviation is necessary, document it in the Project-Specific Overrides section below with rationale."

DEV_CMD_OVERRIDE=""
TEST_CMD_OVERRIDE=""
COVERAGE_CMD_OVERRIDE=""
LINT_CMD_OVERRIDE=""
TYPECHECK_CMD_OVERRIDE=""
BUILD_CMD_OVERRIDE=""

print_usage() {
    cat <<'EOF'
Usage:
  bash scripts/adopt-into-project.sh --project-dir <path> [options]

Required:
  --project-dir <path>          Target project directory

Options:
  --standards-path <path>       Location of agentic-best-practices (default: $AGENTIC_BEST_PRACTICES_HOME or ~/agentic-best-practices)
  --template-path <path>        Template file to render (default: adoption/template-agents.md in this repo)
  --config-file <path>          Optional adoption config file (KEY=VALUE lines)
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
  bash scripts/adopt-into-project.sh --project-dir . --config-file .agentic-best-practices/adoption.env
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
        PROJECT_NAME) PROJECT_NAME="$value" ;;
        AGENT_ROLE) AGENT_ROLE="$value" ;;
        PROJECT_DESCRIPTION) PROJECT_DESCRIPTION="$value" ;;
        PRIORITY_ONE) PRIORITY_ONE="$value" ;;
        PRIORITY_TWO) PRIORITY_TWO="$value" ;;
        PRIORITY_THREE) PRIORITY_THREE="$value" ;;
        STANDARDS_TOPICS) STANDARDS_TOPICS="$value" ;;
        DEVIATION_POLICY) DEVIATION_POLICY="$value" ;;
        DEV_CMD) DEV_CMD_OVERRIDE="$value" ;;
        TEST_CMD) TEST_CMD_OVERRIDE="$value" ;;
        COVERAGE_CMD) COVERAGE_CMD_OVERRIDE="$value" ;;
        LINT_CMD) LINT_CMD_OVERRIDE="$value" ;;
        TYPECHECK_CMD) TYPECHECK_CMD_OVERRIDE="$value" ;;
        BUILD_CMD) BUILD_CMD_OVERRIDE="$value" ;;
        "")
            ;;
        *)
            echo "Warning: unknown config key '$key' ignored ($config_path:$line_no)." >&2
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

command_for_script() {
    local package_manager="$1"
    local script_name="$2"

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

detect_project_stack() {
    local project_dir="$1"
    if [[ -f "$project_dir/package.json" ]]; then
        printf '%s\n' "node"
        return
    fi
    if [[ -f "$project_dir/pyproject.toml" || -f "$project_dir/requirements.txt" || -f "$project_dir/setup.py" || -f "$project_dir/Pipfile" ]]; then
        printf '%s\n' "python"
        return
    fi
    if [[ -f "$project_dir/go.mod" ]]; then
        printf '%s\n' "go"
        return
    fi
    if [[ -f "$project_dir/Cargo.toml" ]]; then
        printf '%s\n' "rust"
        return
    fi
    if [[ -f "$project_dir/pom.xml" || -f "$project_dir/build.gradle" || -f "$project_dir/build.gradle.kts" ]]; then
        printf '%s\n' "jvm"
        return
    fi
    printf '%s\n' "generic"
}

detect_language_for_stack() {
    local stack="$1"
    local project_dir="$2"
    case "$stack" in
    node)
        if [[ -f "$project_dir/tsconfig.json" || -f "$project_dir/tsconfig.base.json" ]]; then
            printf '%s\n' "TypeScript"
        else
            printf '%s\n' "JavaScript/TypeScript"
        fi
        ;;
    python) printf '%s\n' "Python" ;;
    go) printf '%s\n' "Go" ;;
    rust) printf '%s\n' "Rust" ;;
    jvm) printf '%s\n' "Java/Kotlin" ;;
    *) printf '%s\n' "TBD" ;;
    esac
}

runtime_for_stack() {
    local stack="$1"
    case "$stack" in
    node) printf '%s\n' "Node.js|20+" ;;
    python) printf '%s\n' "Python|3.11+" ;;
    go) printf '%s\n' "Go|1.22+" ;;
    rust) printf '%s\n' "Rust|stable" ;;
    jvm) printf '%s\n' "JVM|17+" ;;
    *) printf '%s\n' "TBD|TBD" ;;
    esac
}

framework_for_stack() {
    local stack="$1"
    case "$stack" in
    node) printf '%s\n' "Express/Next.js/TBD" ;;
    python) printf '%s\n' "Django/FastAPI/TBD" ;;
    go) printf '%s\n' "net/http/Fiber/TBD" ;;
    rust) printf '%s\n' "Axum/Actix/TBD" ;;
    jvm) printf '%s\n' "Spring Boot/TBD" ;;
    *) printf '%s\n' "TBD" ;;
    esac
}

testing_for_stack() {
    local stack="$1"
    case "$stack" in
    node) printf '%s\n' "Jest/Vitest/TBD" ;;
    python) printf '%s\n' "pytest" ;;
    go) printf '%s\n' "go test" ;;
    rust) printf '%s\n' "cargo test" ;;
    jvm) printf '%s\n' "JUnit/TestNG" ;;
    *) printf '%s\n' "TBD" ;;
    esac
}

choose_existing_path() {
    local project_dir="$1"
    local fallback="$2"
    shift 2
    local candidate

    for candidate in "$@"; do
        if [[ -e "$project_dir/$candidate" ]]; then
            printf '%s\n' "$candidate"
            return
        fi
    done
    printf '%s\n' "$fallback"
}

detect_go_entry_path() {
    local project_dir="$1"
    local candidate

    shopt -s nullglob
    for candidate in "$project_dir"/cmd/*/main.go; do
        printf '%s\n' "${candidate#$project_dir/}"
        shopt -u nullglob
        return
    done
    shopt -u nullglob

    if [[ -f "$project_dir/main.go" ]]; then
        printf '%s\n' "main.go"
        return
    fi

    printf '%s\n' "cmd/<service>/main.go"
}

java_build_tool() {
    local project_dir="$1"
    if [[ -f "$project_dir/gradlew" || -f "$project_dir/build.gradle" || -f "$project_dir/build.gradle.kts" ]]; then
        printf '%s\n' "gradle"
        return
    fi
    printf '%s\n' "maven"
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
    local stack
    local runtime_name
    local runtime_version
    local framework_name
    local testing_name
    local language_version
    local framework_version
    local testing_version
    local critical_entry
    local critical_config
    local critical_routes
    local critical_services
    local critical_types
    local python_prefix
    local java_tool
    local runtime_info
    local standards_rows

    stack="$(detect_project_stack "$project_dir")"
    language="$(detect_language_for_stack "$stack" "$project_dir")"
    runtime_info="$(runtime_for_stack "$stack")"
    runtime_name="${runtime_info%%|*}"
    runtime_version="${runtime_info#*|}"
    framework_name="$(framework_for_stack "$stack")"
    testing_name="$(testing_for_stack "$stack")"

    language_version="TBD"
    framework_version="TBD"
    testing_version="TBD"

    case "$stack" in
    node)
        dev_cmd="$(command_for_script "$package_manager" "dev")"
        test_cmd="$(command_for_script "$package_manager" "test")"
        coverage_cmd="$(command_for_script "$package_manager" "test:coverage")"
        lint_cmd="$(command_for_script "$package_manager" "lint")"
        typecheck_cmd="$(command_for_script "$package_manager" "typecheck")"
        build_cmd="$(command_for_script "$package_manager" "build")"
        critical_entry="$(choose_existing_path "$project_dir" "src/index.ts" "src/index.ts" "src/index.js" "index.ts" "index.js")"
        critical_config="$(choose_existing_path "$project_dir" "src/config/" "src/config" "config")"
        critical_routes="$(choose_existing_path "$project_dir" "src/routes/" "src/routes" "routes")"
        critical_services="$(choose_existing_path "$project_dir" "src/services/" "src/services" "services" "src/lib")"
        critical_types="$(choose_existing_path "$project_dir" "src/types/" "src/types" "types")"
        ;;
    python)
        if [[ -f "$project_dir/uv.lock" ]]; then
            python_prefix="uv run "
        elif [[ -f "$project_dir/poetry.lock" ]]; then
            python_prefix="poetry run "
        elif [[ -f "$project_dir/Pipfile.lock" || -f "$project_dir/Pipfile" ]]; then
            python_prefix="pipenv run "
        else
            python_prefix=""
        fi

        if [[ -f "$project_dir/manage.py" ]]; then
            dev_cmd="${python_prefix}python manage.py runserver"
        elif [[ -f "$project_dir/app.py" ]]; then
            dev_cmd="${python_prefix}python app.py"
        elif [[ -f "$project_dir/src/main.py" ]]; then
            dev_cmd="${python_prefix}python src/main.py"
        elif [[ -f "$project_dir/main.py" ]]; then
            dev_cmd="${python_prefix}python main.py"
        else
            dev_cmd="${python_prefix}python -m app"
        fi

        test_cmd="${python_prefix}pytest"
        coverage_cmd="${python_prefix}pytest --cov"
        lint_cmd="${python_prefix}ruff check ."
        typecheck_cmd="${python_prefix}mypy ."
        build_cmd="${python_prefix}python -m build"
        critical_entry="$(choose_existing_path "$project_dir" "src/main.py" "manage.py" "app.py" "src/main.py" "main.py")"
        critical_config="$(choose_existing_path "$project_dir" "config/" "app/config" "src/config" "config")"
        critical_routes="$(choose_existing_path "$project_dir" "app/routes/" "app/routes" "src/routes" "routes")"
        critical_services="$(choose_existing_path "$project_dir" "app/services/" "app/services" "src/services" "services")"
        critical_types="$(choose_existing_path "$project_dir" "app/schemas/" "app/schemas" "src/types" "types")"
        ;;
    go)
        dev_cmd="go run ."
        test_cmd="go test ./..."
        coverage_cmd="go test ./... -cover"
        lint_cmd="go vet ./..."
        typecheck_cmd="go test ./..."
        build_cmd="go build ./..."
        critical_entry="$(detect_go_entry_path "$project_dir")"
        critical_config="$(choose_existing_path "$project_dir" "internal/config/" "internal/config" "pkg/config" "config")"
        critical_routes="$(choose_existing_path "$project_dir" "internal/http/" "internal/http" "pkg/http" "api")"
        critical_services="$(choose_existing_path "$project_dir" "internal/service/" "internal/service" "pkg/service" "service")"
        critical_types="$(choose_existing_path "$project_dir" "internal/types/" "internal/types" "pkg/types" "api/types")"
        ;;
    rust)
        dev_cmd="cargo run"
        test_cmd="cargo test"
        coverage_cmd="cargo test"
        lint_cmd="cargo clippy --all-targets --all-features -- -D warnings"
        typecheck_cmd="cargo check"
        build_cmd="cargo build --release"
        critical_entry="$(choose_existing_path "$project_dir" "src/main.rs" "src/main.rs" "src/lib.rs")"
        critical_config="$(choose_existing_path "$project_dir" "config/" "src/config" "config")"
        critical_routes="$(choose_existing_path "$project_dir" "src/routes/" "src/routes" "src/http")"
        critical_services="$(choose_existing_path "$project_dir" "src/services/" "src/services" "src/domain")"
        critical_types="$(choose_existing_path "$project_dir" "src/types/" "src/types" "src/domain/types")"
        ;;
    jvm)
        java_tool="$(java_build_tool "$project_dir")"
        if [[ "$java_tool" == "gradle" ]]; then
            dev_cmd="./gradlew run"
            test_cmd="./gradlew test"
            coverage_cmd="./gradlew test"
            lint_cmd="./gradlew check"
            typecheck_cmd="./gradlew classes"
            build_cmd="./gradlew build"
        else
            if [[ -f "$project_dir/mvnw" ]]; then
                dev_cmd="./mvnw spring-boot:run"
                test_cmd="./mvnw test"
                coverage_cmd="./mvnw test"
                lint_cmd="./mvnw -q -DskipTests verify"
                typecheck_cmd="./mvnw -q -DskipTests compile"
                build_cmd="./mvnw -DskipTests package"
            else
                dev_cmd="mvn spring-boot:run"
                test_cmd="mvn test"
                coverage_cmd="mvn test"
                lint_cmd="mvn -q -DskipTests verify"
                typecheck_cmd="mvn -q -DskipTests compile"
                build_cmd="mvn -DskipTests package"
            fi
        fi
        critical_entry="$(choose_existing_path "$project_dir" "src/main/java/" "src/main/java" "src/main/kotlin")"
        critical_config="$(choose_existing_path "$project_dir" "src/main/resources/" "src/main/resources" "config")"
        critical_routes="$(choose_existing_path "$project_dir" "src/main/java/" "src/main/java" "src/main/kotlin")"
        critical_services="$(choose_existing_path "$project_dir" "src/main/java/" "src/main/java" "src/main/kotlin")"
        critical_types="$(choose_existing_path "$project_dir" "src/main/java/" "src/main/java" "src/main/kotlin")"
        ;;
    *)
        dev_cmd="make dev"
        test_cmd="make test"
        coverage_cmd="make test-coverage"
        lint_cmd="make lint"
        typecheck_cmd="make typecheck"
        build_cmd="make build"
        critical_entry="$(choose_existing_path "$project_dir" "src/" "src" "app")"
        critical_config="$(choose_existing_path "$project_dir" "config/" "config" "src/config")"
        critical_routes="$(choose_existing_path "$project_dir" "src/" "src/routes" "routes")"
        critical_services="$(choose_existing_path "$project_dir" "src/" "src/services" "services")"
        critical_types="$(choose_existing_path "$project_dir" "src/" "src/types" "types")"
        ;;
    esac

    if [[ -n "$DEV_CMD_OVERRIDE" ]]; then
        dev_cmd="$DEV_CMD_OVERRIDE"
    fi
    if [[ -n "$TEST_CMD_OVERRIDE" ]]; then
        test_cmd="$TEST_CMD_OVERRIDE"
    fi
    if [[ -n "$COVERAGE_CMD_OVERRIDE" ]]; then
        coverage_cmd="$COVERAGE_CMD_OVERRIDE"
    fi
    if [[ -n "$LINT_CMD_OVERRIDE" ]]; then
        lint_cmd="$LINT_CMD_OVERRIDE"
    fi
    if [[ -n "$TYPECHECK_CMD_OVERRIDE" ]]; then
        typecheck_cmd="$TYPECHECK_CMD_OVERRIDE"
    fi
    if [[ -n "$BUILD_CMD_OVERRIDE" ]]; then
        build_cmd="$BUILD_CMD_OVERRIDE"
    fi

    standards_rows="$(build_standards_rows "$standards_path" "$STANDARDS_TOPICS")"

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
    replace_literal "$rendered_path" "[e.g., 5.x]" "$language_version"
    replace_literal "$rendered_path" "[e.g., Express]" "$framework_name"
    replace_literal "$rendered_path" "[e.g., 4.x]" "$framework_version"
    replace_literal "$rendered_path" "[e.g., Node.js]" "$runtime_name"
    replace_literal "$rendered_path" "[e.g., 20+]" "$runtime_version"
    replace_literal "$rendered_path" "[e.g., PostgreSQL]" "TBD"
    replace_literal "$rendered_path" "[e.g., 15]" "TBD"
    replace_literal "$rendered_path" "[e.g., Jest]" "$testing_name"
    replace_literal "$rendered_path" "[e.g., 29.x]" "$testing_version"

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

    replace_literal "$rendered_path" "[src/index.ts]" "$critical_entry"
    replace_literal "$rendered_path" "[src/config/]" "$critical_config"
    replace_literal "$rendered_path" "[src/routes/]" "$critical_routes"
    replace_literal "$rendered_path" "[src/services/]" "$critical_services"
    replace_literal "$rendered_path" "[src/types/]" "$critical_types"

    replace_literal "$rendered_path" "{{STANDARDS_GUIDE_ROWS}}" "$standards_rows"
    replace_literal "$rendered_path" "{{DEVIATION_POLICY}}" "$DEVIATION_POLICY"
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

ARGS=("$@")
for ((i = 0; i < ${#ARGS[@]}; i++)); do
    if [[ "${ARGS[$i]}" == "--config-file" ]]; then
        if ((i + 1 >= ${#ARGS[@]})); then
            echo "Error: --config-file requires a value." >&2
            exit 1
        fi
        CONFIG_FILE="${ARGS[$((i + 1))]}"
        break
    fi
done

if [[ -n "$CONFIG_FILE" ]]; then
    CONFIG_FILE="$(expand_home_path "$CONFIG_FILE")"
    load_adoption_config "$CONFIG_FILE"
fi

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
    --config-file)
        CONFIG_FILE="${2:-}"
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
        merge_cmd=(
            bash "$MERGE_SCRIPT"
            --project-dir "$PROJECT_DIR"
            --standards-path "$EFFECTIVE_STANDARDS_PATH"
        )
        if [[ -n "$CONFIG_FILE" ]]; then
            merge_cmd+=(--config-file "$CONFIG_FILE")
        fi
        "${merge_cmd[@]}"
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
if [[ -n "$CONFIG_FILE" ]]; then
    echo "  Config file:      $CONFIG_FILE"
fi
echo ""
echo "Next step: bash \"$REPO_ROOT/scripts/validate-adoption.sh\" --project-dir \"$PROJECT_DIR\" --expect-standards-path \"$EFFECTIVE_STANDARDS_PATH\""
