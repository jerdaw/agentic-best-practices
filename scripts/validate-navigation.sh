#!/usr/bin/env bash
# validate-navigation.sh - Check for navigation drift in best-practices repo
# Run from repo root: ./scripts/validate-navigation.sh

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

echo "Validating navigation structure..."
echo ""

# --- 1. Check that all guide directories have a matching file in AGENTS.md ---
echo "=== Checking Guide Index completeness ==="

for dir in guides/*/; do
    # Skip if guides directory doesn't exist
    [[ -d "guides" ]] || continue
    [[ "$dir" == "guides/*/" ]] && continue

    dir_name=$(basename "$dir")
    guide_file="${dir}${dir_name}.md"

    if [[ -f "$guide_file" ]]; then
        # Check if it's in AGENTS.md or CLAUDE.md
        if ! grep -q "($guide_file)" AGENTS.md 2>/dev/null && ! grep -q "($guide_file)" CLAUDE.md 2>/dev/null; then
            echo -e "${RED}ERROR${NC}: Guide '$guide_file' not in AGENTS.md/CLAUDE.md Guide Index"
            ((ERRORS++))
        fi
    fi
done

# --- 2. Check that AGENTS.md/CLAUDE.md links point to existing files ---
echo ""
echo "=== Checking AGENTS.md/CLAUDE.md links ==="

for doc in AGENTS.md CLAUDE.md; do
    [[ -f "$doc" ]] || continue
    while IFS= read -r link; do
        # Extract path from markdown link
        path=$(echo "$link" | sed -n 's/.*(\([^)]*\.md\)).*/\1/p')
        if [[ -n "$path" && ! -f "$path" ]]; then
            echo -e "${RED}ERROR${NC}: $doc links to non-existent file: $path"
            ((ERRORS++))
        fi
    done < <(grep -oE '\[[^]]+\]\([^)]+\.md\)' "$doc" 2>/dev/null || true)
done

# --- 3. Check Contents tables match actual H2 sections ---
echo ""
echo "=== Checking Contents tables match H2 sections ==="

for guide in guides/*/*.md; do
    [[ -f "$guide" ]] || continue
    
    # Skip if no Contents section
    if ! grep -q "^## Contents" "$guide" 2>/dev/null; then
        echo -e "${YELLOW}WARN${NC}: $guide has no Contents table"
        ((WARNINGS++))
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
        ((WARNINGS++))
    fi
done

# --- 4. Check for broken internal anchor links ---
echo ""
echo "=== Checking internal anchor links ==="

for guide in guides/*/*.md; do
    [[ -f "$guide" ]] || continue
    
    # Find anchor links within the same file
    while IFS= read -r anchor; do
        # Extract anchor from (#anchor-name)
        anchor_id=$(echo "$anchor" | sed 's/.*#\([^)]*\).*/\1/')
        
        # Convert anchor to expected header text (rough heuristic)
        # Anchors are lowercase, hyphenated versions of headers
        # We just check if any H2/H3 could plausibly match
        header_pattern=$(echo "$anchor_id" | tr '-' '.' | sed 's/\./.*/g')
        
        if ! grep -qiE "^##+ .*$header_pattern" "$guide" 2>/dev/null; then
            # Could be a false positive, so just warn
            echo -e "${YELLOW}WARN${NC}: $guide may have broken anchor: #$anchor_id"
            ((WARNINGS++))
        fi
    done < <(grep -oE '\(#[a-z0-9-]+\)' "$guide" 2>/dev/null | head -50 || true)
done || true

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
