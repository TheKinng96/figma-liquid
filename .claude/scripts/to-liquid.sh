#!/bin/bash

# Figma to Shopify Liquid - Convert HTML to Liquid
# Takes working HTML and converts to Shopify Liquid theme

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Load helper functions
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/branch-detector.sh"
source "$SCRIPT_DIR/task-helpers.sh"
source "$SCRIPT_DIR/liquid-validator.sh"
source "$SCRIPT_DIR/visual-validator.sh"

echo -e "${PURPLE}⚡ Figma to Liquid - HTML to Liquid Conversion${NC}\n"

# Check if on issue branch
if ! is_issue_branch; then
  echo -e "${RED}❌ Not on an issue branch${NC}"
  exit 1
fi

CURRENT_BRANCH=$(get_current_branch)
TASK_FILE=$(get_task_file "$CURRENT_BRANCH")
TASK_TITLE=$(get_task_title "$CURRENT_BRANCH")
TASK_SLUG=$(get_task_slug "$CURRENT_BRANCH")
ISSUE_NUM=$(get_issue_number "$CURRENT_BRANCH")

if [ ! -f "$TASK_FILE" ]; then
  echo -e "${RED}❌ Task file not found${NC}"
  exit 1
fi

echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Task: $TASK_TITLE${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# Check Phase 2 completion
echo -e "${BLUE}Checking Phase 2 (HTML Implementation)...${NC}"

# Check if HTML files exist
HTML_FILE="html/html/$TASK_SLUG.html"
CSS_FILE="html/css/$TASK_SLUG.css"

if [ ! -f "$HTML_FILE" ]; then
  echo -e "${RED}❌ HTML file not found: $HTML_FILE${NC}"
  echo -e "${YELLOW}Run /implement first${NC}"
  exit 1
fi

# Check test results
PHASE2_COMPLETE=$(grep -A 30 "## Phase 2: HTML Implementation" "$TASK_FILE" | grep -c "\[x\]" || echo "0")
PHASE2_TOTAL=$(grep -A 30 "## Phase 2: HTML Implementation" "$TASK_FILE" | grep -c "\[ \]\|\[x\]" || echo "1")

if [ "$PHASE2_COMPLETE" -lt "$PHASE2_TOTAL" ]; then
  echo -e "${YELLOW}⚠️  Phase 2 incomplete: $PHASE2_COMPLETE/$PHASE2_TOTAL items checked${NC}"
  echo ""
  echo -e "${YELLOW}This means tests may not be passing.${NC}"
  echo -e "${YELLOW}Converting to Liquid with failing tests may require rework.${NC}"
  echo ""
  read -p "Proceed to Liquid conversion anyway? (y/N): " proceed
  if [ "$proceed" != "y" ]; then
    echo "Please complete Phase 2 first"
    exit 0
  fi
else
  echo -e "${GREEN}✓ Phase 2 complete${NC}\n"
fi

# Update task phase
update_task_phase "$CURRENT_BRANCH" "liquid"
log_to_task_file "$TASK_FILE" "Phase 3 started - Liquid conversion"

# Create theme structure if not exists
mkdir -p theme/{sections,snippets,layout,templates,assets,config,locales}

if [ ! -f theme/layout/theme.liquid ]; then
  echo -e "${YELLOW}Creating basic theme layout...${NC}"
  cat > theme/layout/theme.liquid <<'EOF'
<!doctype html>
<html lang="{{ request.locale.iso_code }}">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>{{ page_title }}</title>
    {{ content_for_header }}
  </head>
  <body>
    {% sections 'header-group' %}
    <main role="main">
      {{ content_for_layout }}
    </main>
    {% sections 'footer-group' %}
  </body>
</html>
EOF
  echo -e "${GREEN}✓ Theme layout created${NC}\n"
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Phase 3: Liquid Conversion${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo -e "${YELLOW}Claude will now:${NC}"
echo -e "  1. Read HTML/CSS/JS files"
echo -e "  2. Convert static content to Liquid variables"
echo -e "  3. Move CSS to {% stylesheet %} block"
echo -e "  4. Move JS to {% javascript %} block"
echo -e "  5. Add section schema (if section)"
echo -e "  6. Validate Liquid syntax"
echo -e "  7. Test on Shopify preview"
echo -e "  8. Compare with HTML version"
echo ""

# Determine if section or snippet
echo -e "${YELLOW}Is this a Section or Snippet?${NC}"
echo "  (1) Section - Full-width, theme editor customizable"
echo "  (2) Snippet - Reusable component"
echo ""
read -p "Choose (1/2): " component_type

case $component_type in
  1)
    LIQUID_FILE="theme/sections/$TASK_SLUG.liquid"
    echo -e "${BLUE}Creating section: $LIQUID_FILE${NC}\n"
    ;;
  2)
    LIQUID_FILE="theme/snippets/$TASK_SLUG.liquid"
    echo -e "${BLUE}Creating snippet: $LIQUID_FILE${NC}\n"
    ;;
  *)
    echo -e "${RED}Invalid choice${NC}"
    exit 1
    ;;
esac

echo -e "${GREEN}Files ready for conversion:${NC}"
echo -e "  HTML: $HTML_FILE"
echo -e "  CSS: $CSS_FILE"
if [ -f "js/$TASK_SLUG.js" ]; then
  echo -e "  JS: js/$TASK_SLUG.js"
fi
echo -e "  Target: $LIQUID_FILE"
echo ""

echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Ready for Conversion${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo -e "${GREEN}Claude will now convert HTML to Liquid following:${NC}"
echo -e "  • liquid-conversion-guidelines.md"
echo -e "  • Shopify best practices"
echo -e "  • BEM naming conventions"
echo ""
echo -e "${YELLOW}After conversion:${NC}"
echo -e "  1. Liquid syntax will be validated"
echo -e "  2. Shopify dev server will start (if not running)"
echo -e "  3. Visual comparison: Shopify preview vs HTML"
echo -e "  4. Task marked complete if all checks pass"
echo ""

# Check if Shopify CLI is installed
if ! command -v shopify &> /dev/null; then
  echo -e "${YELLOW}⚠️  Shopify CLI not installed${NC}"
  echo -e "${YELLOW}Install with: brew tap shopify/shopify && brew install shopify-cli${NC}"
  echo -e "${YELLOW}Conversion will proceed, but Shopify preview testing will be skipped${NC}\n"
fi

# Note: Actual conversion happens through Claude
# This script provides structure and validation

echo -e "${BLUE}Environment ready for Liquid conversion.${NC}"
echo -e "${BLUE}Waiting for Claude to generate Liquid code...${NC}\n"
