#!/usr/bin/env bash
# validate-navigation.sh - Check for navigation drift in best-practices repo
# Run from repo root: npm run validate (or: bash ./scripts/validate-navigation.sh)

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

inc_error() {
    ERRORS=$((ERRORS + 1))
}

inc_warning() {
    WARNINGS=$((WARNINGS + 1))
}

echo "Validating navigation structure..."
echo ""

# --- 1. Check that all guide directories have a matching file in AGENTS.md ---
echo "=== Checking Guide Index completeness ==="

# Find all markdown files in guides/ and adoption/
# Using -print0 to handle spaces in filenames correctly
while IFS= read -r -d '' guide_file; do
    # Check if it's in AGENTS.md
    if ! grep -Fq "($guide_file)" AGENTS.md 2>/dev/null; then
        echo -e "${RED}ERROR${NC}: Guide '$guide_file' not in AGENTS.md Guide Index"
        inc_error
    fi
done < <(find guides adoption -name "*.md" -print0 2>/dev/null)

# --- 1b. Check that all guide files are present in README.md ---
echo ""
echo "=== Checking README guide index completeness ==="

while IFS= read -r -d '' guide_file; do
    if ! grep -Fq "($guide_file)" README.md 2>/dev/null; then
        echo -e "${RED}ERROR${NC}: Guide '$guide_file' not linked in README.md"
        inc_error
    fi
done < <(find guides adoption -name "*.md" -print0 2>/dev/null)

# --- 2. Check that AGENTS.md links point to existing files ---
echo ""
echo "=== Checking AGENTS.md links ==="

while IFS= read -r link; do
    # Extract path from markdown link
    path=$(echo "$link" | sed -n 's/.*(\([^)]*\.md\)).*/\1/p')
    if [[ -n "$path" && ! -f "$path" ]]; then
        echo -e "${RED}ERROR${NC}: AGENTS.md links to non-existent file: $path"
        inc_error
    fi
done < <(grep -oE '\[[^]]+\]\([^)]+\.md\)' AGENTS.md 2>/dev/null || true)

# --- 2b. Check that README.md links point to existing files ---
echo ""
echo "=== Checking README.md links ==="

while IFS= read -r link; do
    path=$(echo "$link" | sed -n 's/.*(\([^)]*\.md\)).*/\1/p')
    if [[ -z "$path" ]]; then
        continue
    fi
    if [[ "$path" =~ ^https?:// ]]; then
        continue
    fi
    if [[ ! -f "$path" ]]; then
        echo -e "${RED}ERROR${NC}: README.md links to non-existent file: $path"
        inc_error
    fi
done < <(grep -oE '\[[^]]+\]\([^)]+\.md\)' README.md 2>/dev/null || true)

# --- 3. Check Contents tables match actual H2 sections ---
echo ""
echo "=== Checking Contents tables match H2 sections ==="

while IFS= read -r -d '' guide; do
    [[ -f "$guide" ]] || continue
    
    # Skip if no Contents section
    if ! grep -q "^## Contents" "$guide" 2>/dev/null; then
        echo -e "${YELLOW}WARN${NC}: $guide has no Contents table"
        inc_warning
        continue
    fi
    
    # Get H2 sections from file (excluding Contents itself)
    actual_sections=$(grep -E "^## " "$guide" | grep -v "^## Contents" | sed 's/^## //' | sort)
    
    # Get sections listed in Contents table (skip fenced code blocks)
    # Look for lines like "| [Section Name](#anchor) |"
    contents_sections=$(awk '
        /^```/ { in_code = !in_code; next }
        !in_code && /^\| \[.*\]\(#/ { print }
    ' "$guide" | \
        grep -oE '\[[^]]+\]\(#[^)]+\)' | \
        sed 's/\[\([^]]*\)\].*/\1/' | \
        head -20 | sort)
    
    # Simple check: warn if counts differ significantly
    actual_count=$(echo "$actual_sections" | grep -c . || echo 0)
    contents_count=$(echo "$contents_sections" | grep -c . || echo 0)
    
    # Note: Contents tables intentionally contain only KEY sections, not all H2s
    # Only warn if Contents has MORE entries than actual H2s (stale)
    if [[ $contents_count -gt $actual_count ]]; then
        echo -e "${YELLOW}WARN${NC}: $guide Contents may have stale entries (H2s: $actual_count, Contents: $contents_count)"
        inc_warning
    fi
done < <(find guides adoption -name "*.md" -print0 2>/dev/null)

# --- 4. Check for broken internal anchor links ---
echo ""
echo "=== Checking internal anchor links ==="

while IFS= read -r -d '' guide; do
    [[ -f "$guide" ]] || continue

    # Build a list of valid heading anchors (GitHub-style slugification, with duplicate suffixes)
    valid_anchors=$(
        awk '
            function slugify(s,   t) {
                t = tolower(s)
                gsub(/[^a-z0-9 -]/, "", t)
                gsub(/ /, "-", t)
                gsub(/^-+/, "", t)
                gsub(/-+$/, "", t)
                return t
            }

            /^##+[[:space:]]+/ {
                line = $0
                sub(/^##+[[:space:]]+/, "", line)
                slug = slugify(line)
                if (slug == "") next
                counts[slug]++
                if (counts[slug] == 1) {
                    print slug
                } else {
                    print slug "-" (counts[slug] - 1)
                }
            }
        ' "$guide"
    )

    # Extract internal anchors from markdown links, skipping fenced code blocks
    anchors_used=$(
        awk '
            /^```/ { in_code = !in_code; next }
            !in_code {
                while (match($0, /\(#[a-z0-9-]+\)/)) {
                    a = substr($0, RSTART + 2, RLENGTH - 3)  # drop "(#" and ")"
                    print a
                    $0 = substr($0, RSTART + RLENGTH)
                }
            }
        ' "$guide" | head -200
    )

    while IFS= read -r anchor_id; do
        [[ -n "$anchor_id" ]] || continue
        if ! grep -Fxq "$anchor_id" <<<"$valid_anchors"; then
            echo -e "${YELLOW}WARN${NC}: $guide may have broken anchor: #$anchor_id"
            inc_warning
        fi
    done <<<"$anchors_used"
done < <(find guides adoption -name "*.md" -print0 2>/dev/null)

# --- Summary ---
echo ""
echo "=== Summary ==="
if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
    echo -e "${GREEN}✓ All checks passed${NC}"
    exit 0
elif [[ $ERRORS -eq 0 ]]; then
    echo -e "${YELLOW}⚠ $WARNINGS warning(s), 0 errors${NC}"
    exit 0
else
    echo -e "${RED}✗ $ERRORS error(s), $WARNINGS warning(s)${NC}"
    exit 1
fi
