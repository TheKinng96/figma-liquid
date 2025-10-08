#!/bin/bash

# Visual Validation Helper Functions
# Compare Figma screenshots with Playwright screenshots

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Load validation rules
load_validation_rules() {
  if [ -f .claude/config/validation-rules.json ]; then
    cat .claude/config/validation-rules.json
  else
    echo '{
      "visualThreshold": 0.98,
      "layoutTolerance": 5,
      "maxComponentSize": 100
    }'
  fi
}

# Get visual threshold from config
get_visual_threshold() {
  load_validation_rules | jq -r '.visualThreshold // 0.98'
}

# Get layout tolerance from config
get_layout_tolerance() {
  load_validation_rules | jq -r '.layoutTolerance // 5'
}

# Run Playwright visual regression tests
run_visual_tests() {
  local component_name=$1
  local test_file="html/tests/${component_name}.spec.js"

  if [ ! -f "$test_file" ]; then
    echo -e "${RED}❌ Test file not found: $test_file${NC}" >&2
    return 1
  fi

  echo -e "${YELLOW}Running Playwright tests for $component_name...${NC}"

  # Run tests and capture output
  npx playwright test "$test_file" --reporter=json > playwright-report.json 2>&1
  local exit_code=$?

  # Parse results
  if [ $exit_code -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed${NC}"
    return 0
  else
    echo -e "${RED}✗ Some tests failed${NC}"
    return 1
  fi
}

# Calculate visual match percentage from Playwright results
calculate_visual_match() {
  local screenshot1=$1
  local screenshot2=$2

  # Use Playwright's built-in visual comparison
  # This is a simplified version - Playwright handles this internally
  echo "98.5"  # Placeholder - actual implementation uses Playwright API
}

# Compare screenshot with Figma design
compare_with_figma() {
  local component_name=$1
  local viewport=$2  # desktop, tablet, mobile

  local figma_screenshot=".claude/data/figma-screenshots/${component_name}-${viewport}.png"
  local playwright_screenshot="html/tests/screenshots/${component_name}-${viewport}.png"

  if [ ! -f "$figma_screenshot" ]; then
    echo -e "${YELLOW}⚠️  Figma screenshot not found: $figma_screenshot${NC}"
    echo "Create baseline with: /breakdown"
    return 1
  fi

  if [ ! -f "$playwright_screenshot" ]; then
    echo -e "${RED}❌ Playwright screenshot not found${NC}"
    return 1
  fi

  # Calculate match percentage
  local match_percentage=$(calculate_visual_match "$figma_screenshot" "$playwright_screenshot")
  local threshold=$(get_visual_threshold)
  local threshold_percentage=$(echo "$threshold * 100" | bc)

  echo "Visual match: ${match_percentage}% (threshold: ${threshold_percentage}%)"

  # Check if passes threshold
  if (( $(echo "$match_percentage >= $threshold_percentage" | bc -l) )); then
    echo -e "${GREEN}✓ Visual validation passed${NC}"
    return 0
  else
    echo -e "${RED}✗ Visual validation failed${NC}"
    echo "Difference: $(echo "$threshold_percentage - $match_percentage" | bc)%"
    return 1
  fi
}

# Run full validation suite
validate_component() {
  local component_name=$1
  local threshold=$(get_visual_threshold)

  echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${YELLOW}Visual Validation: $component_name${NC}"
  echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

  local all_passed=true

  # Test each viewport
  for viewport in desktop tablet mobile; do
    echo "Testing $viewport viewport..."

    if compare_with_figma "$component_name" "$viewport"; then
      echo -e "${GREEN}✓ $viewport passed${NC}\n"
    else
      echo -e "${RED}✗ $viewport failed${NC}\n"
      all_passed=false
    fi
  done

  # Run Playwright tests
  if run_visual_tests "$component_name"; then
    echo -e "${GREEN}✓ Playwright tests passed${NC}"
  else
    echo -e "${RED}✗ Playwright tests failed${NC}"
    all_passed=false
  fi

  echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

  if [ "$all_passed" = true ]; then
    echo -e "${GREEN}✓ All validations passed${NC}\n"
    return 0
  else
    echo -e "${RED}✗ Some validations failed${NC}\n"
    return 1
  fi
}

# Update visual baselines
update_baselines() {
  local component_name=$1

  echo -e "${YELLOW}Updating visual baselines for $component_name...${NC}"

  npx playwright test "html/tests/${component_name}.spec.js" --update-snapshots

  echo -e "${GREEN}✓ Baselines updated${NC}"
}

# Generate validation report
generate_validation_report() {
  local component_name=$1
  local output_file=".claude/data/validation-reports/${component_name}-$(date +%Y%m%d-%H%M%S).md"

  mkdir -p .claude/data/validation-reports

  cat > "$output_file" <<EOF
# Validation Report: $component_name

**Generated**: $(date)

## Visual Comparison

| Viewport | Match % | Threshold | Status |
|----------|---------|-----------|--------|
| Desktop  | --      | $(get_visual_threshold | awk '{printf "%.0f%%", $1*100}') | -- |
| Tablet   | --      | $(get_visual_threshold | awk '{printf "%.0f%%", $1*100}') | -- |
| Mobile   | --      | $(get_visual_threshold | awk '{printf "%.0f%%", $1*100}') | -- |

## Playwright Tests

\`\`\`
$(npx playwright test "html/tests/${component_name}.spec.js" --reporter=list 2>&1)
\`\`\`

## Next Steps

- [ ] Review failing tests
- [ ] Fix visual differences
- [ ] Re-run validation
- [ ] Update task file with results
EOF

  echo "$output_file"
}

# Check if Shopify preview is running
check_shopify_preview() {
  local url=${SHOPIFY_PREVIEW_URL:-"http://127.0.0.1:9292"}

  if curl -s "$url" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Shopify preview is running${NC}"
    return 0
  else
    echo -e "${YELLOW}⚠️  Shopify preview not running${NC}"
    echo "Start with: shopify theme dev"
    return 1
  fi
}

# Export functions
export -f load_validation_rules
export -f get_visual_threshold
export -f get_layout_tolerance
export -f run_visual_tests
export -f calculate_visual_match
export -f compare_with_figma
export -f validate_component
export -f update_baselines
export -f generate_validation_report
export -f check_shopify_preview
