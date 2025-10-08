#!/bin/bash

# Figma to Shopify Liquid - Breakdown Components
# Auto-fetch design, analyze with MCP, recursively split large nodes

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

echo -e "${PURPLE}⚡ Figma to Liquid - Auto Breakdown${NC}\n"

# Load Figma token
if [ -f .env ]; then
  FIGMA_TOKEN=$(grep FIGMA_ACCESS_TOKEN .env | cut -d'=' -f2 | tr -d '"' | tr -d "'")
else
  echo -e "${RED}❌ .env file not found${NC}"
  exit 1
fi

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
  "auto-split:Auto-split from large component:#FF6B6B"
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

# Fetch full Figma file
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Fetching Figma Design${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

mkdir -p logs .claude/data

echo -e "${BLUE}Downloading file structure via API...${NC}"
curl -s -H "X-Figma-Token: $FIGMA_TOKEN" \
  "https://api.figma.com/v1/files/${FILE_KEY}" \
  > logs/figma-full-file.json

if [ ! -s logs/figma-full-file.json ]; then
  echo -e "${RED}❌ Failed to fetch Figma file${NC}"
  exit 1
fi

echo -e "${GREEN}✓ Figma file downloaded${NC}\n"

# Extract top-level pages and frames
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Extracting Components${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# Get all top-level frames from all pages
jq -r '.document.children[] |
  select(.type == "CANVAS") |
  .children[] |
  select(.type == "FRAME" or .type == "COMPONENT" or .type == "SECTION") |
  "\(.id)|\(.name)|\(.type)"' logs/figma-full-file.json > .claude/data/top-level-frames.txt

FRAME_COUNT=$(wc -l < .claude/data/top-level-frames.txt | tr -d ' ')
echo -e "${BLUE}Found ${FRAME_COUNT} top-level components${NC}\n"

if [ "$FRAME_COUNT" -eq 0 ]; then
  echo -e "${RED}❌ No components found in Figma file${NC}"
  exit 1
fi

# Display components and let user select
echo -e "${YELLOW}Available Components:${NC}\n"
COMPONENT_NUM=1
while IFS='|' read -r frame_id frame_name frame_type; do
  echo -e "${BLUE}${COMPONENT_NUM}.${NC} ${frame_name} (${frame_id})"
  COMPONENT_NUM=$((COMPONENT_NUM + 1))
done < .claude/data/top-level-frames.txt

echo ""
read -p "Enter component numbers to process (comma-separated, or 'all'): " selection

# Parse selection
if [ "$selection" = "all" ]; then
  SELECTED_INDICES=$(seq 1 $FRAME_COUNT)
else
  SELECTED_INDICES=$(echo "$selection" | tr ',' ' ')
fi

# Global counter for tasks
TASK_COUNTER=$(jq '.tasks | length' .claude/tasks/index.json 2>/dev/null || echo "0")
TASK_COUNTER=$((TASK_COUNTER + 1))

# Arrays to track components
declare -a SAFE_COMPONENTS=()
declare -a WARNING_COMPONENTS=()
declare -a OVERSIZED_COMPONENTS=()

# Function to count nodes using MCP metadata (via Claude)
count_nodes_mcp() {
  local node_id=$1

  # Create temp file for MCP request
  echo "$node_id" > /tmp/mcp_node_request.txt

  # Return a placeholder - Claude will call MCP directly
  echo "MCP_CHECK_NEEDED"
}

# Function to get child frames sorted by Y position
get_sorted_children() {
  local parent_id=$1

  # Use jq to extract children from the full file, sorted by Y position
  jq -r --arg pid "$parent_id" '
    .. | objects | select(.id == $pid) | .children[]? |
    select(.type == "FRAME" or .type == "SECTION" or .type == "GROUP") |
    "\(.id)|\(.name)|\(.absoluteBoundingBox.y // 0)"
  ' logs/figma-full-file.json | sort -t'|' -k3 -n | cut -d'|' -f1,2
}

# Function to create task for a component
create_component_task() {
  local component_id=$1
  local component_name=$2
  local parent_name=$3
  local section_num=$4
  local node_count=$5
  local is_split=$6

  # Generate slug
  local slug=$(echo "$component_name" | sed 's/[^a-zA-Z0-9]/-/g' | tr '[:upper:]' '[:lower:]' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')
  [ -z "$slug" ] && slug="component-$TASK_COUNTER"

  # If this is a split section, add parent name and number
  if [ "$is_split" = "true" ]; then
    local parent_slug=$(echo "$parent_name" | sed 's/[^a-zA-Z0-9]/-/g' | tr '[:upper:]' '[:lower:]' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')
    slug="${parent_slug}-${section_num}"
  fi

  # Calculate complexity based on node count
  local complexity=5
  if [ "$node_count" -lt 50 ]; then
    complexity=3
  elif [ "$node_count" -lt 150 ]; then
    complexity=5
  elif [ "$node_count" -lt 300 ]; then
    complexity=7
  else
    complexity=9
  fi

  # Determine component type
  local comp_type="section"
  if [[ "$component_name" =~ ^(PC_TOP|SP_TOP|.*TOP.*) ]]; then
    comp_type="page"
  elif [[ "$component_name" =~ ^(ヘッダー|フッター|header|footer) ]]; then
    comp_type="layout"
  fi

  # Build Figma link
  local figma_link="https://www.figma.com/design/${FILE_KEY}/${FILE_NAME}?node-id=${component_id}"

  # Create GitHub issue
  local issue_title="Implement $component_name"
  if [ "$is_split" = "true" ]; then
    issue_title="Implement $parent_name - Section $section_num: $component_name"
  fi

  local labels="figma-conversion,priority-medium,phase-core"
  if [ "$is_split" = "true" ]; then
    labels="${labels},auto-split"
  fi

  local issue_body="**Figma Link**: $figma_link
**Node ID**: \`$component_id\`
**Node Count**: $node_count nodes

## Component Details
- Name: $component_name
- Type: $comp_type
- Complexity: $complexity/10
- Parent: $parent_name
- Section: $section_num
- Auto-split: $is_split

## MCP Access
\`\`\`
mcp__figma-dev-mode-mcp-server__get_code({
  nodeId: \"$component_id\",
  clientLanguages: \"html,css,javascript\",
  clientFrameworks: \"unknown\"
})
\`\`\`

## Tasks
- [ ] Phase 1: Analyze Figma component via MCP
- [ ] Phase 2: Implement HTML/CSS/JS
- [ ] Phase 3: Convert to Liquid
- [ ] Visual validation ≥98%
- [ ] Playwright tests passing

## Files
- \`html/html/$slug.html\`
- \`html/css/$slug.css\`
- \`html/js/$slug.js\` (if needed)
- \`html/tests/$slug.spec.js\`
- \`theme/sections/$slug.liquid\`

---
Generated by /breakdown (auto-split: $is_split)"

  local issue_url=$(gh issue create \
    --title "$issue_title" \
    --body "$issue_body" \
    --label "$labels")

  local issue_num=$(echo "$issue_url" | grep -oE '[0-9]+$')

  echo -e "${GREEN}✓ Created issue #$issue_num${NC}: $component_name ($node_count nodes)"

  # Create branch
  local branch="issue-$issue_num-$slug"
  git checkout -b "$branch" 2>/dev/null || git checkout "$branch"

  # Create individual task JSON file
  local task_file=".claude/tasks/task${TASK_COUNTER}.json"
  cat > "$task_file" << EOF
{
  "id": "$TASK_COUNTER",
  "issueNumber": $issue_num,
  "title": "$component_name",
  "slug": "$slug",
  "branch": "$branch",
  "nodeId": "$component_id",
  "figmaLink": "$figma_link",
  "complexity": $complexity,
  "nodeCount": $node_count,
  "type": "$comp_type",
  "parentComponent": "$parent_name",
  "sectionNumber": $section_num,
  "isAutoSplit": $is_split,
  "status": "pending",
  "phase": "analysis"
}
EOF

  # Add to index
  jq --arg tf "task${TASK_COUNTER}.json" '.tasks += [$tf] | .lastUpdated = now | strftime("%Y-%m-%dT%H:%M:%SZ")' \
    .claude/tasks/index.json > .claude/tasks/index.json.tmp
  mv .claude/tasks/index.json.tmp .claude/tasks/index.json

  # Commit
  git add "$task_file" .claude/tasks/index.json
  git commit -m "Task #$issue_num: $component_name - Auto breakdown ($node_count nodes)"

  TASK_COUNTER=$((TASK_COUNTER + 1))
}

# Recursive function to process component (split if needed)
process_component() {
  local component_id=$1
  local component_name=$2
  local parent_name=$3
  local section_num=$4
  local depth=$5

  # Prevent infinite recursion
  if [ "$depth" -gt 5 ]; then
    echo -e "${RED}⚠️  Max depth reached for $component_name${NC}"
    return
  fi

  echo -e "\n${BLUE}Checking: $component_name${NC} (depth: $depth)"

  # This is where we need Claude to use MCP
  # For now, we'll estimate from the JSON file
  local node_count=$(jq -r --arg cid "$component_id" '
    [.. | objects | select(.id == $cid)] | .[0] |
    [.. | objects] | length
  ' logs/figma-full-file.json)

  # Fallback if jq fails
  if [ -z "$node_count" ] || [ "$node_count" = "null" ] || [ "$node_count" -eq 0 ]; then
    node_count=50  # Default safe value
  fi

  echo -e "${BLUE}  Node count: $node_count${NC}"

  # Check thresholds
  if [ "$node_count" -lt 300 ]; then
    # Safe - create task
    echo -e "${GREEN}  ✅ Safe size - creating task${NC}"
    SAFE_COMPONENTS+=("$component_name ($node_count nodes)")
    create_component_task "$component_id" "$component_name" "$parent_name" "$section_num" "$node_count" "false"

  elif [ "$node_count" -lt 500 ]; then
    # Warning but acceptable
    echo -e "${YELLOW}  ⚠️  Warning size - creating task${NC}"
    WARNING_COMPONENTS+=("$component_name ($node_count nodes)")
    create_component_task "$component_id" "$component_name" "$parent_name" "$section_num" "$node_count" "false"

  else
    # Too large - split recursively
    echo -e "${RED}  ❌ Oversized - splitting into children${NC}"
    OVERSIZED_COMPONENTS+=("$component_name ($node_count nodes)")

    # Get children sorted by Y position
    local children=$(get_sorted_children "$component_id")

    if [ -z "$children" ]; then
      echo -e "${YELLOW}  ⚠️  No children found - creating task anyway${NC}"
      create_component_task "$component_id" "$component_name" "$parent_name" "$section_num" "$node_count" "false"
      return
    fi

    local child_num=1
    while IFS='|' read -r child_id child_name; do
      # Recursively process each child
      process_component "$child_id" "$child_name" "$component_name" "$child_num" "$((depth + 1))"
      child_num=$((child_num + 1))
    done <<< "$children"
  fi
}

# Process selected components
echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Processing Components${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

COMPONENT_NUM=1
while IFS='|' read -r frame_id frame_name frame_type; do
  # Check if this component was selected
  if echo "$SELECTED_INDICES" | grep -wq "$COMPONENT_NUM"; then
    echo -e "\n${PURPLE}═══════════════════════════════════════${NC}"
    echo -e "${PURPLE}Processing: $frame_name${NC}"
    echo -e "${PURPLE}═══════════════════════════════════════${NC}"

    # Start recursive processing (depth 0)
    process_component "$frame_id" "$frame_name" "$frame_name" "0" 0
  fi
  COMPONENT_NUM=$((COMPONENT_NUM + 1))
done < .claude/data/top-level-frames.txt

# Return to main branch
git checkout main 2>/dev/null || git checkout master 2>/dev/null || true

# Display summary
echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Breakdown Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# Validation summary
echo -e "${BLUE}Component Size Validation:${NC}\n"

echo -e "${GREEN}✅ Safe Components (<300 nodes):${NC}"
if [ ${#SAFE_COMPONENTS[@]} -eq 0 ]; then
  echo -e "  None"
else
  for comp in "${SAFE_COMPONENTS[@]}"; do
    echo -e "  - $comp"
  done
fi

echo -e "\n${YELLOW}⚠️  Warning Components (300-500 nodes):${NC}"
if [ ${#WARNING_COMPONENTS[@]} -eq 0 ]; then
  echo -e "  None"
else
  for comp in "${WARNING_COMPONENTS[@]}"; do
    echo -e "  - $comp"
  done
fi

echo -e "\n${RED}❌ Oversized Components (>500 nodes, auto-split):${NC}"
if [ ${#OVERSIZED_COMPONENTS[@]} -eq 0 ]; then
  echo -e "  None - All components are implementable!"
else
  for comp in "${OVERSIZED_COMPONENTS[@]}"; do
    echo -e "  - $comp → Split into children"
  done
fi

# Task statistics
echo ""
get_task_stats

echo -e "\n${YELLOW}Next Steps:${NC}"
echo -e "  1. Review tasks: ${BLUE}cat .claude/tasks/index.json | jq${NC}"
echo -e "  2. View task details: ${BLUE}cat .claude/tasks/task1.json | jq${NC}"
echo -e "  3. Start implementation: ${BLUE}/implement${NC}"
echo -e "  4. Or work on specific task: ${BLUE}/implement <branch-name>${NC}\n"

echo -e "${GREEN}✨ All tasks are ready for seamless implementation!${NC}\n"
