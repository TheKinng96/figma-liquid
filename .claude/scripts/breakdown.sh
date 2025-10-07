#!/bin/bash

# Figma to Shopify Liquid - Breakdown Components
# Analyze Figma design, create tasks, GitHub issues, and branches

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Load helper functions
source "$(dirname "$0")/task-helpers.sh"

echo -e "${PURPLE}⚡ Figma to Liquid - Component Breakdown${NC}\n"

# Load Figma token
if [ -f .env ]; then
  FIGMA_TOKEN=$(cat .env | grep FIGMA_ACCESS_TOKEN | cut -d'=' -f2)
else
  echo -e "${RED}❌ .env file not found${NC}"
  exit 1
fi

# Function to extract node ID from URL
extract_node_id() {
  local url=$1
  echo "$url" | grep -oP 'node-id=\K[^&]+' | sed 's/-/:/'
}

# Function to get node metadata from Figma API
get_node_metadata() {
  local file_key=$1
  local node_id=$2

  curl -s -H "X-Figma-Token: $FIGMA_TOKEN" \
    "https://api.figma.com/v1/files/${file_key}/nodes?ids=${node_id}"
}

# Function to analyze frame complexity
analyze_frame_complexity() {
  local file_key=$1
  local node_id=$2
  local output_file=$3

  echo -e "${YELLOW}Analyzing frame structure...${NC}"

  # Get node data
  local node_data=$(get_node_metadata "$file_key" "$node_id")
  echo "$node_data" > "$output_file"

  # Count children recursively
  local children_count=$(echo "$node_data" | jq '[.. | objects | select(has("children")) | .children[]] | length')

  # Calculate nesting depth
  local nesting_depth=$(echo "$node_data" | jq '[.. | objects | select(has("children"))] | length')

  echo "$children_count|$nesting_depth"
}

# Function to break down large frames into sections
breakdown_large_frame() {
  local file_key=$1
  local node_id=$2
  local frame_name=$3

  echo -e "${YELLOW}Breaking down large frame: $frame_name${NC}"

  # Get frame data
  local frame_data=$(get_node_metadata "$file_key" "$node_id")

  # Extract direct children (sections)
  echo "$frame_data" | jq -r ".nodes[\"$node_id\"].document.children[]? |
    select(.type == \"FRAME\" or .type == \"GROUP\" or .type == \"SECTION\") |
    {id: .id, name: .name, type: .type, bounds: .absoluteBoundingBox} |
    @json" | while read -r section; do

      local section_id=$(echo "$section" | jq -r '.id')
      local section_name=$(echo "$section" | jq -r '.name')
      local section_type=$(echo "$section" | jq -r '.type')

      echo "$section_id|$section_name|$section_type"
  done
}

# Function to check if node is too large for MCP
is_too_large_for_mcp() {
  local children_count=$1
  local nesting_depth=$2

  # MCP limit is ~25,000 tokens
  # Rough estimate: >100 children or >10 nesting levels = too large
  if [ "$children_count" -gt 100 ] || [ "$nesting_depth" -gt 10 ]; then
    return 0  # true
  else
    return 1  # false
  fi
}

# Check if project is initialized
if [ ! -f .claude/data/figma-project.json ]; then
  echo -e "${RED}❌ Project not initialized. Run /init-figma first.${NC}"
  exit 1
fi

# Check GitHub CLI
if ! command -v gh &> /dev/null; then
  echo -e "${RED}❌ GitHub CLI (gh) not installed.${NC}"
  echo -e "${YELLOW}Install with: brew install gh${NC}"
  exit 1
fi

if ! gh auth status &> /dev/null; then
  echo -e "${RED}❌ Not authenticated with GitHub.${NC}"
  echo -e "${YELLOW}Run: gh auth login${NC}"
  exit 1
fi

# Read project info
FILE_KEY=$(jq -r '.fileKey' .claude/data/figma-project.json)
FILE_NAME=$(jq -r '.fileName' .claude/data/figma-project.json)

echo -e "${BLUE}Project:${NC} $FILE_NAME"
echo -e "${BLUE}File Key:${NC} $FILE_KEY\n"

# Initialize tasks
init_tasks

# Create labels
echo -e "${YELLOW}Creating GitHub labels...${NC}"
LABELS=(
  "figma-conversion:Component conversion from Figma:#7B68EE"
  "liquid-template:Shopify Liquid template:#00D9FF"
  "styling:CSS and styling:#FF6B6B"
  "testing:Playwright testing:#4ECDC4"
  "priority-high:High priority:#FF0000"
  "priority-medium:Medium priority:#FFA500"
  "priority-low:Low priority:#808080"
  "phase-foundation:Foundation phase:#1E90FF"
  "phase-core:Core components:#32CD32"
  "phase-content:Content sections:#FFD700"
  "phase-interactive:Interactive features:#FF69B4"
  "phase-polish:Polish and optimization:#9370DB"
)

for label in "${LABELS[@]}"; do
  IFS=':' read -r name description color <<< "$label"
  gh label create "$name" --description "$description" --color "$color" --force 2>/dev/null || true
done

echo -e "${GREEN}✓ Labels created${NC}\n"

# Prompt for components
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Component Breakdown${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
echo -e "Paste Figma component links (one per line)"
echo -e "Right-click component in Figma → Copy link"
echo -e "Press Ctrl+D when done\n"

COMPONENT_NUM=1
while IFS= read -r figma_link; do
  [ -z "$figma_link" ] && continue

  echo -e "\n${BLUE}Analyzing component $COMPONENT_NUM...${NC}"

  # Extract node ID from URL
  NODE_ID=$(extract_node_id "$figma_link")
  echo -e "${BLUE}Node ID:${NC} $NODE_ID"

  # Analyze frame complexity using API
  ANALYSIS_FILE=".claude/data/analysis-$COMPONENT_NUM.json"
  mkdir -p .claude/data
  COMPLEXITY_DATA=$(analyze_frame_complexity "$FILE_KEY" "$NODE_ID" "$ANALYSIS_FILE")

  CHILDREN_COUNT=$(echo "$COMPLEXITY_DATA" | cut -d'|' -f1)
  NESTING_DEPTH=$(echo "$COMPLEXITY_DATA" | cut -d'|' -f2)

  echo -e "${BLUE}Children:${NC} $CHILDREN_COUNT"
  echo -e "${BLUE}Nesting depth:${NC} $NESTING_DEPTH"

  # Get component name from API
  COMPONENT_NAME=$(jq -r ".nodes[\"$NODE_ID\"].document.name // \"Component $COMPONENT_NUM\"" "$ANALYSIS_FILE")
  SLUG=$(echo "$COMPONENT_NAME" | sed 's/[^a-zA-Z0-9]/-/g' | tr '[:upper:]' '[:lower:]' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')
  [ -z "$SLUG" ] && SLUG="component-$COMPONENT_NUM"

  echo -e "${BLUE}Component:${NC} $COMPONENT_NAME"

  # Calculate complexity score (1-10)
  COMPLEXITY=$((CHILDREN_COUNT / 20 + NESTING_DEPTH / 2))
  [ "$COMPLEXITY" -gt 10 ] && COMPLEXITY=10
  [ "$COMPLEXITY" -lt 1 ] && COMPLEXITY=1

  # Check if frame is too large for MCP
  if is_too_large_for_mcp "$CHILDREN_COUNT" "$NESTING_DEPTH"; then
    echo -e "${YELLOW}⚠️  Frame too large for MCP (${CHILDREN_COUNT} children, ${NESTING_DEPTH} depth)${NC}"
    echo -e "${YELLOW}Breaking down into sections...${NC}\n"

    # Get sections
    breakdown_large_frame "$FILE_KEY" "$NODE_ID" "$COMPONENT_NAME" > ".claude/data/sections-$COMPONENT_NUM.txt"

    # Create task file with section breakdown
    SECTIONS_TODO=""
    SECTION_NUM=1
    while IFS='|' read -r section_id section_name section_type; do
      SECTIONS_TODO="${SECTIONS_TODO}\n- [ ] Section ${SECTION_NUM}: ${section_name} (${section_id})"
      echo -e "${GREEN}  ✓ Section ${SECTION_NUM}:${NC} ${section_name} (${section_id})"
      SECTION_NUM=$((SECTION_NUM + 1))
    done < ".claude/data/sections-$COMPONENT_NUM.txt"

    BREAKDOWN_NOTE="⚠️ **Large Frame Detected**

This frame has been broken down into $(($SECTION_NUM - 1)) sections.
Each section should be implemented separately using its node ID.

**Sections:**
${SECTIONS_TODO}

**Implementation Guide:**
1. Use \`mcp__figma-dev-mode-mcp-server__get_code\` with each section's node ID
2. Combine sections into final page
3. Ensure proper spacing between sections
"
  else
    BREAKDOWN_NOTE="**Frame Analysis:**
- Children: $CHILDREN_COUNT
- Nesting depth: $NESTING_DEPTH
- Node ID: $NODE_ID
- MCP Compatible: ✅ Yes

Use \`mcp__figma-dev-mode-mcp-server__get_code\` with node ID \`$NODE_ID\`
"
  fi

  # Check complexity threshold
  MAX_COMPLEXITY=$(jq -r '.maxComplexityScore // 7' .claude/config/chunk-rules.json 2>/dev/null || echo "7")

  if [ "$COMPLEXITY" -gt "$MAX_COMPLEXITY" ]; then
    echo -e "${YELLOW}⚠️  Complexity: $COMPLEXITY/10 (threshold: $MAX_COMPLEXITY)${NC}"
    echo -e "${YELLOW}Consider splitting this component${NC}"
    read -p "Proceed anyway? (y/N): " proceed
    [ "$proceed" != "y" ] && continue
  fi

  # Create GitHub issue
  ISSUE_BODY="**Figma Link**: $figma_link
**Node ID**: \`$NODE_ID\`

## Component Details
- Name: $COMPONENT_NAME
- Complexity: $COMPLEXITY/10
- Children: $CHILDREN_COUNT
- Nesting depth: $NESTING_DEPTH

$BREAKDOWN_NOTE

## Tasks
- [ ] Phase 1: Analyze Figma component
- [ ] Phase 2: Implement HTML/CSS/JS
- [ ] Phase 3: Convert to Liquid
- [ ] Visual validation ≥98%
- [ ] Playwright tests passing

## Files
- \`html/html/$SLUG.html\`
- \`html/css/$SLUG.css\`
- \`html/js/$SLUG.js\` (if needed)
- \`html/tests/$SLUG.spec.js\`
- \`theme/sections/$SLUG.liquid\`

---
Generated by /breakdown"

  ISSUE_URL=$(gh issue create \
    --title "Implement $COMPONENT_NAME" \
    --body "$ISSUE_BODY" \
    --label "figma-conversion,priority-medium,phase-core")

  ISSUE_NUM=$(echo "$ISSUE_URL" | grep -oE '[0-9]+$')

  echo -e "${GREEN}✓ Created issue #$ISSUE_NUM${NC}"

  # Create branch
  BRANCH="issue-$ISSUE_NUM-$SLUG"
  git checkout -b "$BRANCH" 2>/dev/null || git checkout "$BRANCH"

  # Create task file
  TASK_FILE=$(create_task_file "$ISSUE_NUM" "$COMPONENT_NAME" "$SLUG" "$figma_link" "$COMPLEXITY")

  # Add node ID and sections info to task file
  sed -i.bak "s|**Figma Link**:.*|**Figma Link**: $figma_link\n**Node ID**: \`$NODE_ID\`\n\n$BREAKDOWN_NOTE|" "$TASK_FILE"
  rm "${TASK_FILE}.bak"

  echo -e "${GREEN}✓ Created task file: $TASK_FILE${NC}"

  # Add task to index
  add_task "$COMPONENT_NUM" "$ISSUE_NUM" "$COMPONENT_NAME" "$SLUG" "$BRANCH" "$figma_link" "$COMPLEXITY"

  # Commit task file and analysis
  git add "$TASK_FILE" .claude/tasks/index.json "$ANALYSIS_FILE"
  [ -f ".claude/data/sections-$COMPONENT_NUM.txt" ] && git add ".claude/data/sections-$COMPONENT_NUM.txt"
  git commit -m "Task #$ISSUE_NUM: $COMPONENT_NAME - Initial breakdown"

  COMPONENT_NUM=$((COMPONENT_NUM + 1))
done

# Return to main/master branch
git checkout main 2>/dev/null || git checkout master 2>/dev/null || true

echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Breakdown Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# Show summary
get_task_stats

echo -e "\n${YELLOW}Next Steps:${NC}"
echo -e "  1. Review tasks: ${BLUE}list_tasks${NC}"
echo -e "  2. Start implementation: ${BLUE}/implement${NC}"
echo -e "  3. Or switch to specific task: ${BLUE}/implement <branch-name>${NC}\n"
