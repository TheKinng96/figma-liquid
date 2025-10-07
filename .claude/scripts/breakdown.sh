#!/bin/bash

# Figma to Shopify Liquid - Breakdown Components
# Automatically analyze Figma design, create tasks, GitHub issues, and branches

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

# Check if project is initialized
if [ ! -f .claude/data/figma-project.json ]; then
  echo -e "${RED}❌ Project not initialized. Run /init-figma first.${NC}"
  exit 1
fi

# Check for Figma JSON file in logs folder
FIGMA_JSON="logs/figma-full-file.json"
if [ ! -f "$FIGMA_JSON" ]; then
  echo -e "${RED}❌ Figma JSON file not found: $FIGMA_JSON${NC}"
  echo -e "${YELLOW}Please export the Figma file using Figma API and place it in the logs/ directory${NC}"
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
FIGMA_URL=$(jq -r '.figmaUrl' .claude/data/figma-project.json)

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

# Extract components and frames from Figma JSON
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Extracting Components from Figma File${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# Extract top-level frames (main sections to implement)
FRAMES=$(jq -r '
.document.children[0].children[] |
select(.type == "FRAME") |
{nodeId: .id, name: .name, type: .type}
' "$FIGMA_JSON" | jq -s '.')

FRAME_COUNT=$(echo "$FRAMES" | jq 'length')
echo -e "${BLUE}Found $FRAME_COUNT frames/sections to implement${NC}\n"

# Show what we found
echo -e "${BLUE}Frames to implement:${NC}"
echo "$FRAMES" | jq -r '.[] | "  - \(.name) (node: \(.nodeId))"'
echo ""

# Ask user to confirm or filter
read -p "Process all frames? (y/N): " process_all

if [ "$process_all" != "y" ]; then
  echo -e "\n${YELLOW}Enter frame numbers to process (comma-separated, e.g., 1,3,5):${NC}"
  echo "$FRAMES" | jq -r 'to_entries | .[] | "\(.key + 1). \(.value.name)"'
  read -p "Frame numbers: " frame_numbers

  # Filter frames based on user selection
  SELECTED_FRAMES=$(echo "$FRAMES" | jq "[.[] | select(.nodeId as \$id | \"$frame_numbers\" | split(\",\") | map(tonumber - 1) | contains([(\$FRAMES | jq -r '.[] | .nodeId' | grep -n \$id | cut -d: -f1 | head -1 | xargs -I{} expr {} - 1)]))]")
  FRAMES="$SELECTED_FRAMES"
fi

# Process each frame
COMPONENT_NUM=1
echo "$FRAMES" | jq -c '.[]' | while IFS= read -r frame; do
  NODE_ID=$(echo "$frame" | jq -r '.nodeId')
  COMPONENT_NAME=$(echo "$frame" | jq -r '.name')

  echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}Processing: $COMPONENT_NAME${NC}"
  echo -e "${BLUE}Node ID: $NODE_ID${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

  # Create slug from component name
  SLUG=$(echo "$COMPONENT_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')

  # Calculate basic complexity (will be enhanced by Claude during implementation)
  # For now, use a simple heuristic based on name patterns
  COMPLEXITY=5
  if [[ "$COMPONENT_NAME" =~ (TOP|top) ]]; then
    COMPLEXITY=8  # Homepage is complex
  elif [[ "$COMPONENT_NAME" =~ (詳細|detail|Detail) ]]; then
    COMPLEXITY=7  # Product detail is complex
  elif [[ "$COMPONENT_NAME" =~ (SP_|PC_) ]]; then
    COMPLEXITY=6  # Responsive sections
  fi

  # Create Figma link with node ID
  FIGMA_LINK="$FIGMA_URL&node-id=${NODE_ID//:/-}"

  # Check complexity threshold
  MAX_COMPLEXITY=$(jq -r '.maxComplexityScore // 7' .claude/config/chunk-rules.json 2>/dev/null || echo "7")

  if [ "$COMPLEXITY" -gt "$MAX_COMPLEXITY" ]; then
    echo -e "${YELLOW}⚠️  Complexity: $COMPLEXITY/10 (threshold: $MAX_COMPLEXITY)${NC}"
    echo -e "${YELLOW}This component may need to be split${NC}"
  fi

  # Create GitHub issue
  ISSUE_BODY="**Figma Link**: $FIGMA_LINK

## Component Details
- Node ID: \`$NODE_ID\`
- Complexity: $COMPLEXITY/10
- Type: Section (auto-detected)

## Tasks
- [ ] Phase 1: Analyze Figma component using MCP
- [ ] Phase 2: Implement HTML/CSS/JS with Playwright validation
- [ ] Phase 3: Convert to Shopify Liquid
- [ ] Visual validation ≥98%
- [ ] All tests passing

## Files
- \`html/$SLUG.html\`
- \`css/$SLUG.css\`
- \`js/$SLUG.js\`
- \`theme/sections/$SLUG.liquid\`
- \`tests/$SLUG.spec.js\`

## MCP Access
This task will use Figma MCP to access node \`$NODE_ID\` for:
- Design metadata and structure
- CSS/styles generation
- Screenshots for validation

---
Generated by /breakdown"

  ISSUE_NUM=$(gh issue create \
    --title "Implement $COMPONENT_NAME" \
    --body "$ISSUE_BODY" \
    --label "figma-conversion,priority-medium,phase-core" \
    --json number -q '.number')

  echo -e "${GREEN}✓ Created issue #$ISSUE_NUM${NC}"

  # Create branch
  BRANCH="issue-$ISSUE_NUM-$SLUG"
  git checkout -b "$BRANCH" 2>/dev/null || git checkout "$BRANCH"

  # Create task file (markdown)
  TASK_FILE=$(create_task_file "$ISSUE_NUM" "$COMPONENT_NAME" "$SLUG" "$FIGMA_LINK" "$COMPLEXITY")

  # Add node ID to task file
  echo -e "\n## Figma Node ID\n\`$NODE_ID\`\n" >> "$TASK_FILE"

  echo -e "${GREEN}✓ Created task file: $TASK_FILE${NC}"

  # Create individual task JSON file
  TASK_JSON_FILE=".claude/tasks/task${COMPONENT_NUM}.json"
  cat > "$TASK_JSON_FILE" << EOF
{
  "id": "$ISSUE_NUM",
  "issueNumber": $ISSUE_NUM,
  "title": "$COMPONENT_NAME",
  "slug": "$SLUG",
  "branch": "$BRANCH",
  "nodeId": "$NODE_ID",
  "figmaLink": "$FIGMA_LINK",
  "complexity": $COMPLEXITY,
  "type": "section",
  "status": "pending",
  "phase": "analysis"
}
EOF

  echo -e "${GREEN}✓ Created JSON task file: $TASK_JSON_FILE${NC}"

  # Update task list in index.json
  TASK_FILES=$(ls .claude/tasks/task*.json 2>/dev/null | xargs -n1 basename | jq -R . | jq -s .)
  jq ".tasks = $TASK_FILES | .lastUpdated = \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"" \
    .claude/tasks/index.json > .claude/tasks/index.json.tmp && \
    mv .claude/tasks/index.json.tmp .claude/tasks/index.json

  # Commit task files
  git add "$TASK_FILE" "$TASK_JSON_FILE" .claude/tasks/index.json
  git commit -m "Task #$ISSUE_NUM: $COMPONENT_NAME - Initial breakdown

Node ID: $NODE_ID
Complexity: $COMPLEXITY/10
Figma: $FIGMA_LINK"

  echo -e "${GREEN}✓ Committed task files${NC}"

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
echo -e "  1. Review task list: ${BLUE}cat .claude/tasks/index.json | jq${NC}"
echo -e "  2. View specific task: ${BLUE}cat .claude/tasks/task1.json | jq${NC}"
echo -e "  3. Start implementation: ${BLUE}/implement${NC}"
echo -e "  4. Or switch to specific task: ${BLUE}/implement <branch-name>${NC}\n"

echo -e "${BLUE}All tasks have been created with Figma node IDs for MCP access${NC}"
echo -e "${BLUE}Task files are stored as individual JSON files in .claude/tasks/${NC}"
