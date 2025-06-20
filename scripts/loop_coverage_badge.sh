#!/bin/bash
set -e

# Configuration
COVERAGE_FILE="application/tmp/coverage/.last_run.json"
BADGE_DIR="docs/badges"
LINE_BADGE="$BADGE_DIR/coverage-line.svg"
BRANCH_BADGE="$BADGE_DIR/coverage-branch.svg"
SUMMARY_FILE="$BADGE_DIR/coverage-summary.txt"

# Extract coverage numbers
LINE_COVERAGE=$(grep '"line":' "$COVERAGE_FILE" | sed -E 's/.*"line": *([0-9.]+).*/\1/')
BRANCH_COVERAGE=$(grep '"branch":' "$COVERAGE_FILE" | sed -E 's/.*"branch": *([0-9.]+).*/\1/')

# Format with 1 decimal place
LINE_COVERAGE_FMT=$(printf "%.1f" "$LINE_COVERAGE")
BRANCH_COVERAGE_FMT=$(printf "%.1f" "$BRANCH_COVERAGE")

# Get integer parts
LINE_INT=${LINE_COVERAGE_FMT%.*}
BRANCH_INT=${BRANCH_COVERAGE_FMT%.*}

# Function to determine badge color
get_color() {
  local value=$1
  if [ "$value" -ge 90 ]; then echo "brightgreen"
  elif [ "$value" -ge 80 ]; then echo "green"
  elif [ "$value" -ge 70 ]; then echo "yellowgreen"
  elif [ "$value" -ge 60 ]; then echo "orange"
  else echo "red"
  fi
}

# Colors for badges
LINE_COLOR=$(get_color "$LINE_INT")
BRANCH_COLOR=$(get_color "$BRANCH_INT")

# Ensure output directory exists
mkdir -p "$BADGE_DIR"

# Download badges
curl -sSfL "https://img.shields.io/badge/line%20coverage-${LINE_COVERAGE_FMT}%25-${LINE_COLOR}.svg" -o "$LINE_BADGE"
curl -sSfL "https://img.shields.io/badge/branch%20coverage-${BRANCH_COVERAGE_FMT}%25-${BRANCH_COLOR}.svg" -o "$BRANCH_BADGE"

# Create summary message for GitHub Actions
echo "::notice ::Test Coverage - Line: ${LINE_COVERAGE_FMT}%, Branch: ${BRANCH_COVERAGE_FMT}%" > "$SUMMARY_FILE"

echo "✅ Line coverage badge saved to $LINE_BADGE"
echo "✅ Branch coverage badge saved to $BRANCH_BADGE"
echo "ℹ️  Coverage summary written to $SUMMARY_FILE"
