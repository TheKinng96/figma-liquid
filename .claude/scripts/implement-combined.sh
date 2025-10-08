#!/bin/bash

# Combined Implementation Script
# Implements multiple sections into a single HTML file

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Load utilities
source "$(dirname "$0")/figma-utils.sh"

echo -e "${PURPLE}⚡ Figma to Liquid - Combined Implementation${NC}\n"

# Get parent component name from argument or detect from branch
PARENT_SLUG=$1

if [ -z "$PARENT_SLUG" ]; then
  # Try to detect from branch name (e.g., issue-X-pc-top-1 -> pc-top)
  CURRENT_BRANCH=$(git branch --show-current)
  if [[ "$CURRENT_BRANCH" =~ issue-[0-9]+-(.+)-[0-9]+ ]]; then
    PARENT_SLUG="${BASH_REMATCH[1]}"
  else
    echo -e "${RED}❌ Cannot detect parent component${NC}"
    echo -e "${YELLOW}Usage: $0 <parent-slug>${NC}"
    echo -e "${YELLOW}Example: $0 pc-top${NC}"
    exit 1
  fi
fi

echo -e "${BLUE}Parent Component:${NC} $PARENT_SLUG\n"

# Find all task branches for this parent
TASK_BRANCHES=$(git branch | grep "issue-.*-${PARENT_SLUG}-[0-9]" | sed 's/^[* ]*//' | sort)

if [ -z "$TASK_BRANCHES" ]; then
  echo -e "${RED}❌ No task branches found for $PARENT_SLUG${NC}"
  exit 1
fi

BRANCH_COUNT=$(echo "$TASK_BRANCHES" | wc -l | tr -d ' ')
echo -e "${GREEN}Found $BRANCH_COUNT sections to combine${NC}\n"

# Output files
COMBINED_HTML="html/${PARENT_SLUG}.html"
COMBINED_CSS="html/css/${PARENT_SLUG}.css"
COMBINED_JS="html/js/${PARENT_SLUG}.js"

# Initialize combined files
cat > "$COMBINED_HTML" << 'EOF'
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PARENT_TITLE</title>
  <link rel="stylesheet" href="css/PARENT_SLUG.css">
</head>
<body>
  <main class="PARENT_SLUG">
EOF

# Replace placeholders
sed -i '' "s/PARENT_TITLE/${PARENT_SLUG}/g" "$COMBINED_HTML"
sed -i '' "s/PARENT_SLUG/${PARENT_SLUG}/g" "$COMBINED_HTML"

# Initialize CSS and JS
echo "/* Combined CSS for $PARENT_SLUG */" > "$COMBINED_CSS"
echo "" >> "$COMBINED_CSS"

echo "/* Combined JavaScript for $PARENT_SLUG */" > "$COMBINED_JS"
echo "(function() {" >> "$COMBINED_JS"
echo "  'use strict';" >> "$COMBINED_JS"
echo "" >> "$COMBINED_JS"

# Process each section in order
SECTION_NUM=1
echo "$TASK_BRANCHES" | while read -r branch; do
  echo -e "${BLUE}Processing section $SECTION_NUM: $branch${NC}"

  # Get task JSON from this branch
  TASK_JSON=$(git show "${branch}:.claude/tasks/task${SECTION_NUM}.json" 2>/dev/null || echo "{}")

  if [ "$TASK_JSON" = "{}" ]; then
    echo -e "${YELLOW}  ⚠️  No task JSON found, searching...${NC}"
    # Try to find task JSON by branch name
    TASK_JSON=$(git show "${branch}:.claude/tasks/" | grep "\.json$" | head -1)
  fi

  NODE_ID=$(echo "$TASK_JSON" | jq -r '.nodeId // empty')
  SECTION_SLUG=$(echo "$TASK_JSON" | jq -r '.slug // empty')

  if [ -z "$NODE_ID" ]; then
    echo -e "${YELLOW}  ⚠️  Skipping - no node ID${NC}"
    SECTION_NUM=$((SECTION_NUM + 1))
    continue
  fi

  echo -e "  ${GREEN}Node ID: $NODE_ID${NC}"

  # Get component metadata
  METADATA=$(get_component_metadata "$NODE_ID")
  CONTAINER_SPEC=$(get_container_spec "$NODE_ID")

  NEEDS_CONTAINER=$(echo "$CONTAINER_SPEC" | jq -r '.needsContainer')
  FRAME_WIDTH=$(echo "$CONTAINER_SPEC" | jq -r '.width')

  # Generate section HTML
  echo "" >> "$COMBINED_HTML"
  echo "    <!-- Section $SECTION_NUM: $SECTION_SLUG -->" >> "$COMBINED_HTML"

  if [ "$NEEDS_CONTAINER" = "true" ]; then
    echo "    <section class=\"${PARENT_SLUG}__section\" data-section=\"$SECTION_NUM\">" >> "$COMBINED_HTML"
    echo "      <div class=\"${PARENT_SLUG}__container\" style=\"max-width: ${FRAME_WIDTH}px;\">" >> "$COMBINED_HTML"
    echo "        <!-- Section content will be implemented here -->" >> "$COMBINED_HTML"
    echo "        <div id=\"section-${SECTION_NUM}-placeholder\"></div>" >> "$COMBINED_HTML"
    echo "      </div>" >> "$COMBINED_HTML"
    echo "    </section>" >> "$COMBINED_HTML"
  else
    echo "    <section class=\"${PARENT_SLUG}__section\" data-section=\"$SECTION_NUM\" style=\"max-width: ${FRAME_WIDTH}px;\">" >> "$COMBINED_HTML"
    echo "      <!-- Section content will be implemented here -->" >> "$COMBINED_HTML"
    echo "      <div id=\"section-${SECTION_NUM}-placeholder\"></div>" >> "$COMBINED_HTML"
    echo "    </section>" >> "$COMBINED_HTML"
  fi

  # Add section comment to CSS
  echo "" >> "$COMBINED_CSS"
  echo "/* =============================================" >> "$COMBINED_CSS"
  echo "   Section $SECTION_NUM: $SECTION_SLUG" >> "$COMBINED_CSS"
  echo "   Node ID: $NODE_ID" >> "$COMBINED_CSS"
  echo "   ============================================= */" >> "$COMBINED_CSS"
  echo "" >> "$COMBINED_CSS"

  # Add base section styles
  cat >> "$COMBINED_CSS" << EOF
.${PARENT_SLUG}__section[data-section="$SECTION_NUM"] {
  width: 100%;
  max-width: ${FRAME_WIDTH}px;
  margin: 0 auto;
}

EOF

  if [ "$NEEDS_CONTAINER" = "true" ]; then
    cat >> "$COMBINED_CSS" << EOF
.${PARENT_SLUG}__container {
  width: 100%;
  margin: 0 auto;
  padding: 0 16px;
  box-sizing: border-box;
}

EOF
  fi

  # Add section initialization to JS
  cat >> "$COMBINED_JS" << EOF
  // Section $SECTION_NUM: $SECTION_SLUG
  function initSection${SECTION_NUM}() {
    const section = document.querySelector('[data-section="$SECTION_NUM"]');
    if (!section) {
      console.warn('Section $SECTION_NUM not found');
      return;
    }

    // Section-specific initialization
    console.log('Section $SECTION_NUM initialized');
  }

EOF

  SECTION_NUM=$((SECTION_NUM + 1))
done

# Close HTML
cat >> "$COMBINED_HTML" << 'EOF'
  </main>

  <script src="js/PARENT_SLUG.js"></script>
</body>
</html>
EOF

sed -i '' "s/PARENT_SLUG/${PARENT_SLUG}/g" "$COMBINED_HTML"

# Close JS
cat >> "$COMBINED_JS" << 'EOF'
  // Initialize all sections
  document.addEventListener('DOMContentLoaded', function() {
    const sections = document.querySelectorAll('[data-section]');
    sections.forEach((section, index) => {
      const sectionNum = index + 1;
      const initFn = window['initSection' + sectionNum];
      if (initFn) initFn();
    });
  });

})();
EOF

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Combined Implementation Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}Files Created:${NC}"
echo -e "  📄 $COMBINED_HTML"
echo -e "  🎨 $COMBINED_CSS"
echo -e "  ⚙️  $COMBINED_JS"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo -e "  1. Implement each section placeholder with actual content"
echo -e "  2. Add section-specific styles to CSS"
echo -e "  3. Add section-specific JS if needed"
echo -e "  4. Run tests: ${BLUE}npx playwright test tests/${PARENT_SLUG}.spec.js${NC}"
echo ""
