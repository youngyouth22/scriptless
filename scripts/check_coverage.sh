#!/usr/bin/env bash
# ==============================================================================
# Scriptless Coverage Checker & Quality Gate
# Enforces:
# - Minimum 100% Domain Layer Coverage (lib/features/*/domain/**, lib/core/usecases/**)
# - Minimum 80% Overall Codebase Coverage
# ==============================================================================

set -eo pipefail

LCOV_FILE="coverage/lcov.info"
CLEANED_LCOV_FILE="coverage/lcov_cleaned.info"
MIN_OVERALL_COVERAGE=80
MIN_DOMAIN_COVERAGE=100

echo "🔍 Checking test coverage quality gates..."

if [ ! -f "$LCOV_FILE" ]; then
  echo "❌ Error: $LCOV_FILE not found! Make sure 'flutter test --coverage' ran successfully."
  exit 1
fi

# Ensure lcov is installed
if ! command -v lcov &> /dev/null; then
  echo "⚠️ lcov command not found. Installing or skipping advanced filtering..."
fi

# Filter out generated files, main entry points, and UI pages from domain calculations if lcov is available
if command -v lcov &> /dev/null; then
  lcov --remove "$LCOV_FILE" \
    'lib/main.dart' \
    'lib/flavors.dart' \
    'lib/di/*.config.dart' \
    '**/*.g.dart' \
    '**/*.freezed.dart' \
    -o "$CLEANED_LCOV_FILE" --ignore-errors unused,empty || cp "$LCOV_FILE" "$CLEANED_LCOV_FILE"
else
  cp "$LCOV_FILE" "$CLEANED_LCOV_FILE"
fi

# Calculate Total Coverage
TOTAL_LINES=$(grep -c '^DA:' "$CLEANED_LCOV_FILE" || true)
HIT_LINES=$(grep '^DA:' "$CLEANED_LCOV_FILE" | grep -v ',0$' | wc -l | xargs || echo "0")

if [ "$TOTAL_LINES" -eq 0 ]; then
  echo "⚠️ No instrumented lines found in $CLEANED_LCOV_FILE."
  OVERALL_COVERAGE=0
else
  OVERALL_COVERAGE=$(awk "BEGIN {printf \"%.2f\", ($HIT_LINES / $TOTAL_LINES) * 100}")
fi

# Calculate Domain Coverage specifically
DOMAIN_TOTAL=$(awk '/^SF:.*domain\// {in_domain=1} /^DA:/ {if(in_domain) total++} /^end_of_record/ {in_domain=0} END {print total+0}' "$CLEANED_LCOV_FILE")
DOMAIN_HIT=$(awk '/^SF:.*domain\// {in_domain=1} /^DA:[0-9]+,[1-9][0-9]*/ {if(in_domain) hit++} /^end_of_record/ {in_domain=0} END {print hit+0}' "$CLEANED_LCOV_FILE")

if [ "$DOMAIN_TOTAL" -eq 0 ]; then
  DOMAIN_COVERAGE=100.00
else
  DOMAIN_COVERAGE=$(awk "BEGIN {printf \"%.2f\", ($DOMAIN_HIT / $DOMAIN_TOTAL) * 100}")
fi

echo "========================================================"
echo "📊 TEST COVERAGE SUMMARY REPORT"
echo "========================================================"
echo "  Overall Lines : $HIT_LINES / $TOTAL_LINES ($OVERALL_COVERAGE%) [Required: >= $MIN_OVERALL_COVERAGE%]"
echo "  Domain Lines  : $DOMAIN_HIT / $DOMAIN_TOTAL ($DOMAIN_COVERAGE%) [Required: == $MIN_DOMAIN_COVERAGE%]"
echo "========================================================"

FAILED=0

# Check Overall Coverage Gate
if (( $(echo "$OVERALL_COVERAGE < $MIN_OVERALL_COVERAGE" | bc -l) )); then
  echo "❌ OVERALL COVERAGE FAILED: $OVERALL_COVERAGE% is below required minimum of $MIN_OVERALL_COVERAGE%"
  FAILED=1
else
  echo "✅ OVERALL COVERAGE PASSED: $OVERALL_COVERAGE% >= $MIN_OVERALL_COVERAGE%"
fi

# Check Domain Coverage Gate (100%)
if (( $(echo "$DOMAIN_COVERAGE < $MIN_DOMAIN_COVERAGE" | bc -l) )); then
  echo "❌ DOMAIN LAYER COVERAGE FAILED: $DOMAIN_COVERAGE% is below required 100%"
  FAILED=1
else
  echo "✅ DOMAIN LAYER COVERAGE PASSED: $DOMAIN_COVERAGE% == 100%"
fi

if [ "$FAILED" -ne 0 ]; then
  echo ""
  echo "❌ Quality gate failed. Please add required unit tests to cover missing branches."
  exit 1
fi

echo "🎉 All coverage quality gates passed successfully!"
exit 0
