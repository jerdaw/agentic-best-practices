#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="."
EXPECT_STANDARDS_PATH=""
STRICT=0

print_usage() {
    cat <<'EOF'
Usage:
  bash scripts/validate-adoption.sh [options]

Options:
  --project-dir <path>            Target project directory (default: .)
  --expect-standards-path <path>  Expected standards repo path in AGENTS.md
  --strict                        Fail on warnings
  --help                          Show help
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

resolve_path_for_project() {
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

is_pinned_path() {
    local path="$1"
    if [[ "$path" == *"/.agentic-best-practices/pinned/"* || "$path" == .agentic-best-practices/pinned/* || "$path" == ./.agentic-best-practices/pinned/* ]]; then
        return 0
    fi
    return 1
}

looks_like_semver_tag() {
    local value="$1"
    if [[ "$value" =~ ^v?[0-9]+\.[0-9]+\.[0-9]+([-.][A-Za-z0-9]+)?$ ]]; then
        return 0
    fi
    if [[ "$value" =~ ^[0-9a-f]{7,40}$ ]]; then
        return 0
    fi
    return 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
    --project-dir)
        PROJECT_DIR="${2:-}"
        shift 2
        ;;
    --expect-standards-path)
        EXPECT_STANDARDS_PATH="${2:-}"
        shift 2
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
PROJECT_DIR_ABS="$(cd "$PROJECT_DIR" && pwd)"

AGENTS_PATH="$PROJECT_DIR/AGENTS.md"
CLAUDE_PATH="$PROJECT_DIR/CLAUDE.md"
ERRORS=0
WARNINGS=0

err() {
    ERRORS=$((ERRORS + 1))
    echo "ERROR: $1" >&2
}

warn() {
    WARNINGS=$((WARNINGS + 1))
    echo "WARN: $1"
}

if [[ ! -f "$AGENTS_PATH" ]]; then
    err "AGENTS.md not found at $AGENTS_PATH"
else
    if grep -Fq "SETUP INSTRUCTIONS (delete this block after setup):" "$AGENTS_PATH"; then
        err "Template setup instructions are still present in AGENTS.md"
    fi

    PLACEHOLDER_REGEX='\[(Project Name|specific role, e\.g\., "security-conscious backend developer"|brief project description|First priority, e\.g\., "Security over convenience"|Second priority, e\.g\., "Correctness over speed"|Third priority, e\.g\., "Readability over cleverness"|e\.g\., TypeScript|e\.g\., 5\.x|e\.g\., Express|e\.g\., 4\.x|e\.g\., Node\.js|e\.g\., 20\+|e\.g\., PostgreSQL|e\.g\., 15|e\.g\., Jest|e\.g\., 29\.x|npm run dev|npm test|npm run test:coverage|npm run lint|npm run typecheck|npm run build|Add your own|Rationale|Topic|What best-practices says|What this project does instead|Why the deviation is necessary|Date|src/index\.ts|src/config/|src/routes/|src/services/|src/types/)\]'
    placeholder_tmp="$(mktemp)"
    if grep -nE "$PLACEHOLDER_REGEX" "$AGENTS_PATH" >"$placeholder_tmp" 2>/dev/null; then
        err "Unresolved template placeholders found in AGENTS.md"
        cat "$placeholder_tmp" >&2
    fi
    if grep -nE '\{\{[A-Z_]+\}\}' "$AGENTS_PATH" >>"$placeholder_tmp" 2>/dev/null; then
        err "Unresolved token placeholders found in AGENTS.md"
        cat "$placeholder_tmp" >&2
    fi
    rm -f "$placeholder_tmp"

    standards_section_count="$(grep -Ec '^##[[:space:]]+Standards Reference[[:space:]]*$' "$AGENTS_PATH" || true)"
    if [[ "$standards_section_count" -eq 0 ]]; then
        err "Missing required section: ## Standards Reference"
    elif [[ "$standards_section_count" -gt 1 ]]; then
        warn "Multiple Standards Reference sections detected ($standards_section_count)"
    fi

    if ! grep -Fq "**Deviation policy**:" "$AGENTS_PATH"; then
        err "Deviation policy statement is missing from AGENTS.md"
    fi

    managed_begin_count="$(grep -Fc '<!-- BEGIN MANAGED: STANDARDS_REFERENCE -->' "$AGENTS_PATH" || true)"
    managed_end_count="$(grep -Fc '<!-- END MANAGED: STANDARDS_REFERENCE -->' "$AGENTS_PATH" || true)"
    if [[ "$managed_begin_count" -ne "$managed_end_count" ]]; then
        err "Managed standards markers are unbalanced"
    fi

    for required_header in "## Agent Role" "## Tech Stack" "## Key Commands" "## Boundaries"; do
        if ! grep -Fq "$required_header" "$AGENTS_PATH"; then
            warn "Missing recommended section: $required_header"
        fi
    done

    if grep -Fq "TODO: set command for" "$AGENTS_PATH"; then
        warn "Key Commands still contain TODO placeholders"
    fi

    standards_path="$(sed -n 's/^This project follows organizational standards defined in `\([^`]*\)\/\?`\./\1/p' "$AGENTS_PATH" | head -n 1)"
    if [[ -z "$standards_path" ]]; then
        err "Could not parse standards path from AGENTS.md Standards Reference"
    else
        expanded_standards_path="$(resolve_path_for_project "$standards_path" "$PROJECT_DIR_ABS")"
        if [[ ! -d "$expanded_standards_path" ]]; then
            err "Standards path does not exist: $expanded_standards_path"
        fi
        if [[ ! -f "$expanded_standards_path/README.md" ]]; then
            warn "Standards path does not contain README.md: $expanded_standards_path"
        fi

        if is_pinned_path "$standards_path"; then
            if [[ ! -f "$expanded_standards_path/.abp-pin.json" ]]; then
                err "Pinned standards path is missing .abp-pin.json metadata: $expanded_standards_path"
            else
                pinned_ref="$(sed -n 's/.*\"pinned_ref\": \"\([^\"]*\)\".*/\1/p' "$expanded_standards_path/.abp-pin.json" | head -n 1)"
                if [[ -z "$pinned_ref" ]]; then
                    warn "Pinned metadata exists but pinned_ref could not be parsed: $expanded_standards_path/.abp-pin.json"
                elif ! looks_like_semver_tag "$pinned_ref"; then
                    warn "Pinned metadata uses non-version/non-sha ref ('$pinned_ref'); prefer tags or commit SHA for reproducibility"
                fi
            fi
        fi

        if [[ -n "$EXPECT_STANDARDS_PATH" ]]; then
            expanded_expected="$(resolve_path_for_project "$EXPECT_STANDARDS_PATH" "$PROJECT_DIR_ABS")"
            if [[ "$expanded_expected" != "$expanded_standards_path" ]]; then
                err "Standards path mismatch. Expected '$expanded_expected' but AGENTS.md uses '$expanded_standards_path'"
            fi
        fi
    fi

    mapfile -t guide_refs < <(grep -oE '`[^`]+guides/[^`]+\.md`' "$AGENTS_PATH" | tr -d '`' | sort -u || true)
    if [[ "${#guide_refs[@]}" -eq 0 ]]; then
        err "No guide references found in AGENTS.md"
    else
        if [[ "${#guide_refs[@]}" -lt 3 ]]; then
            warn "Only ${#guide_refs[@]} guide references found; expected at least 3 references for effective guidance"
        fi
        for ref in "${guide_refs[@]}"; do
            expanded_ref="$(resolve_path_for_project "$ref" "$PROJECT_DIR_ABS")"
            if [[ ! -f "$expanded_ref" ]]; then
                err "Guide reference does not exist: $expanded_ref"
            fi
        done
    fi
fi

if [[ -e "$CLAUDE_PATH" || -L "$CLAUDE_PATH" ]]; then
    if [[ -L "$CLAUDE_PATH" ]]; then
        link_target="$(readlink "$CLAUDE_PATH")"
        if [[ "$link_target" != "AGENTS.md" ]]; then
            warn "CLAUDE.md symlink target is '$link_target' (expected AGENTS.md)"
        fi
    elif [[ -f "$CLAUDE_PATH" ]]; then
        if ! cmp -s "$AGENTS_PATH" "$CLAUDE_PATH"; then
            warn "CLAUDE.md exists but differs from AGENTS.md"
        fi
    fi
else
    warn "CLAUDE.md not found (recommended for Claude Code compatibility)"
fi

echo ""
echo "Adoption validation summary:"
echo "  Project:  $PROJECT_DIR"
echo "  Errors:   $ERRORS"
echo "  Warnings: $WARNINGS"

if [[ "$ERRORS" -gt 0 ]]; then
    exit 1
fi

if [[ "$STRICT" -eq 1 && "$WARNINGS" -gt 0 ]]; then
    exit 1
fi

echo "Validation passed."
