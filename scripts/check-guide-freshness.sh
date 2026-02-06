#!/usr/bin/env bash
set -euo pipefail

# Check guide freshness - report guides older than 6 months
# Usage: bash scripts/check-guide-freshness.sh

GUIDES_DIR="guides"
THRESHOLD_DAYS=180  # 6 months
NOW=$(date +%s)
STALE_COUNT=0
TOTAL_COUNT=0

echo "Checking guide freshness (threshold: ${THRESHOLD_DAYS} days)..."
echo ""

# Find all guide markdown files
while IFS= read -r guide; do
  TOTAL_COUNT=$((TOTAL_COUNT + 1))

  # Get last modified time of the file
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    MODIFIED=$(stat -f %m "$guide")
  else
    # Linux
    MODIFIED=$(stat -c %Y "$guide")
  fi

  # Calculate age in days
  AGE_SECONDS=$((NOW - MODIFIED))
  AGE_DAYS=$((AGE_SECONDS / 86400))

  # Check if stale
  if [ "$AGE_DAYS" -gt "$THRESHOLD_DAYS" ]; then
    STALE_COUNT=$((STALE_COUNT + 1))
    echo "⚠️  STALE ($AGE_DAYS days): $guide"
  fi
done < <(find "$GUIDES_DIR" -type f -name "*.md" | sort)

echo ""
echo "Summary:"
echo "  Total guides: $TOTAL_COUNT"
echo "  Stale guides (>$THRESHOLD_DAYS days): $STALE_COUNT"

if [ "$STALE_COUNT" -gt 0 ]; then
  STALE_PERCENT=$((STALE_COUNT * 100 / TOTAL_COUNT))
  echo "  Stale percentage: ${STALE_PERCENT}%"

  if [ "$STALE_PERCENT" -gt 25 ]; then
    echo ""
    echo "⚠️  Warning: More than 25% of guides are stale!"
    echo "   Consider increasing maintenance frequency."
  fi
fi

echo ""
echo "Fresh guides are those modified within the last $THRESHOLD_DAYS days."
