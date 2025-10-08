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

  # Check component size by counting children nodes
  CHILDREN_COUNT=$(jq --arg nodeid "$NODE_ID" '
    def count_children:
      if .children then
        1 + ([.children[] | count_children] | add // 0)
      else
        1
      end;
    .. | objects | select(.id == $nodeid) | count_children
  ' "$FIGMA_JSON" 2>/dev/null || echo "0")

  # Recursive function to split component if too large
  split_if_needed() {
    local node_id=$1
    local comp_name=$2
    local parent_slug=$3
    local parent_name=${4:-""}
    local depth=${5:-0}

    local indent=""
    for ((i=0; i<depth; i++)); do indent="  $indent"; done

    # Count nodes
    local node_count=$(jq --arg nodeid "$node_id" '
      def count_children:
        if .children then 1 + ([.children[] | count_children] | add // 0)
        else 1 end;
      .. | objects | select(.id == $nodeid) | count_children
    ' "$FIGMA_JSON" 2>/dev/null || echo "0")

    # Check if component is too large
    if [ "$node_count" -gt 500 ]; then
      echo -e "${indent}${RED}❌ $comp_name: $node_count nodes (exceeds 500 limit)${NC}"
      echo -e "${indent}${YELLOW}Auto-splitting into child components...${NC}"

      # Extract child frames sorted by Y position
      local children=$(jq --arg nodeid "$node_id" '
        .. | objects | select(.id == $nodeid) |
        .children[]? |
        select(.type == "FRAME" or .type == "GROUP" or .type == "SECTION") |
        {nodeId: .id, name: .name, type: .type, y: (.absoluteBoundingBox.y // 0)}
      ' "$FIGMA_JSON" | jq -s 'sort_by(.y)')

      local child_count=$(echo "$children" | jq 'length')

      if [ "$child_count" -eq 0 ]; then
        echo -e "${indent}${RED}No child frames found to split${NC}"
        echo -e "${indent}${YELLOW}Component too large but cannot be auto-split - SKIPPING${NC}"
        return 1
      fi

      echo -e "${indent}${GREEN}Found $child_count child sections${NC}"
      echo "$children" | jq -r --arg indent "$indent" '.[] | "\($indent)  - \(.name) (node: \(.nodeId))"'

      # Process each child
      local child_num=1
      echo "$children" | jq -c '.[]' | while read -r child; do
        local child_node_id=$(echo "$child" | jq -r '.nodeId')
        local child_name=$(echo "$child" | jq -r '.name')
        local child_slug="${parent_slug}-${child_num}"
        local child_title="${comp_name}_${child_name}"

        # Recursively check if child is also too large
        if ! split_if_needed "$child_node_id" "$child_name" "$child_slug" "$comp_name" $((depth + 1)); then
          # Child was too large and couldn't be split - create task anyway with warning
          create_task_for_component "$child_node_id" "$child_title" "$child_slug" "$comp_name" "$child_num" "$child_count" "true"
        else
          # Child is safe size - create task
          create_task_for_component "$child_node_id" "$child_title" "$child_slug" "$comp_name" "$child_num" "$child_count" "false"
        fi

        child_num=$((child_num + 1))
      done

      return 1  # Indicate parent was split
    else
      echo -e "${indent}${GREEN}✓ $comp_name: $node_count nodes (safe)${NC}"
      return 0  # Indicate component is safe
    fi
  }

  # Helper to create task for a component
  create_task_for_component() {
    local node_id=$1
    local title=$2
    local slug=$3
    local parent_name=${4:-""}
    local section_num=${5:-""}
    local section_total=${6:-""}
    local is_oversized=${7:-"false"}

    local figma_link="$FIGMA_URL&node-id=${node_id//:/-}"

    # Count nodes
    local node_count=$(jq --arg nodeid "$node_id" '
      def count_children:
        if .children then 1 + ([.children[] | count_children] | add // 0)
        else 1 end;
      .. | objects | select(.id == $nodeid) | count_children
    ' "$FIGMA_JSON" 2>/dev/null || echo "0")

    local complexity=5
    if [ "$is_oversized" = "true" ]; then
      complexity=8
    fi

    # Build issue body
    local issue_body="**Figma Link**: $figma_link
**Node Count**: $node_count nodes"

    if [ -n "$parent_name" ] && [ -n "$section_num" ]; then
      issue_body="$issue_body
**Parent Component**: $parent_name
**Section**: $section_num of $section_total"
    fi

    if [ "$is_oversized" = "true" ]; then
      issue_body="$issue_body

⚠️ **Warning**: This component has $node_count nodes and may exceed MCP token limits."
    fi

    issue_body="$issue_body

## Component Details
- Node ID: \`$node_id\`
- Complexity: $complexity/10
- Type: Section

## Tasks
- [ ] Phase 1: Analyze Figma component using MCP
- [ ] Phase 2: Implement HTML/CSS/JS with Playwright validation
- [ ] Phase 3: Convert to Shopify Liquid
- [ ] Visual validation ≥98%
- [ ] All tests passing

## Files
- \`html/$slug.html\`
- \`html/css/$slug.css\`
- \`html/js/$slug.js\`
- \`theme/sections/$slug.liquid\`
- \`tests/$slug.spec.js\`

## MCP Access
This task will use Figma MCP to access node \`$node_id\`

---
Generated by /breakdown (auto-split)"

    local labels="figma-conversion,priority-medium,phase-core,auto-split"
    if [ "$is_oversized" = "true" ]; then
      labels="$labels,needs-splitting"
    fi

    local issue_url=$(gh issue create \
      --title "Implement $title" \
      --body "$issue_body" \
      --label "$labels")

    local issue_num=$(echo "$issue_url" | grep -oE '[0-9]+$')
    echo -e "${GREEN}✓ Created issue #$issue_num: $title${NC}"

    local branch="issue-$issue_num-$slug"
    git checkout -b "$branch" 2>/dev/null || git checkout "$branch"

    local task_file=$(create_task_file "$issue_num" "$title" "$slug" "$figma_link" "$complexity")
    echo -e "\n## Figma Node ID\n\`$node_id\`\n" >> "$task_file"

    local task_json=".claude/tasks/task${COMPONENT_NUM}.json"
    cat > "$task_json" << EOF
{
  "id": "$issue_num",
  "issueNumber": $issue_num,
  "title": "$title",
  "slug": "$slug",
  "branch": "$branch",
  "nodeId": "$node_id",
  "figmaLink": "$figma_link",
  "complexity": $complexity,
  "nodeCount": $node_count,
  "type": "section",
  "parentComponent": "$parent_name",
  "sectionNumber": $section_num,
  "isOversized": $is_oversized,
  "status": "pending",
  "phase": "analysis"
}
EOF

    TASK_FILES=$(ls .claude/tasks/task*.json 2>/dev/null | xargs -n1 basename | jq -R . | jq -s .)
    jq ".tasks = $TASK_FILES | .lastUpdated = \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"" \
      .claude/tasks/index.json > .claude/tasks/index.json.tmp && \
      mv .claude/tasks/index.json.tmp .claude/tasks/index.json

    git add "$task_file" "$task_json" .claude/tasks/index.json
    git commit -m "Task #$issue_num: $title - Auto-split section

Node ID: $node_id
Node Count: $node_count
Figma: $figma_link"

    echo -e "${GREEN}✓ Task $COMPONENT_NUM complete${NC}\n"
    COMPONENT_NUM=$((COMPONENT_NUM + 1))
  }

  # Check component size and auto-split if needed
  echo -e "${BLUE}Validating component size...${NC}"
  if ! split_if_needed "$NODE_ID" "$COMPONENT_NAME" "$SLUG" "" 0; then
    echo -e "${GREEN}✓ Component split into sub-components${NC}"
    continue  # Skip creating task for parent
  fi

  # Component is safe size - check other thresholds
  if [ "$CHILDREN_COUNT" -gt 300 ]; then
    echo -e "${YELLOW}⚠️  Large component: $CHILDREN_COUNT nodes${NC}"
    echo -e "${YELLOW}May need manual splitting if issues occur${NC}"
  fi

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
- \`html/css/$SLUG.css\`
- \`html/js/$SLUG.js\`
- \`theme/sections/$SLUG.liquid\`
- \`tests/$SLUG.spec.js\`

## MCP Access
This task will use Figma MCP to access node \`$NODE_ID\` for:
- Design metadata and structure
- CSS/styles generation
- Screenshots for validation

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

  # Create task file (markdown)
  TASK_FILE=$(create_task_file "$ISSUE_NUM" "$COMPONENT_NAME" "$SLUG" "$FIGMA_LINK" "$COMPLEXITY")

  # Add node ID to task file
  echo -e "\n## Figma Node ID\n\`$NODE_ID\`\n" >> "$TASK_FILE"

  echo -e "${GREEN}✓ Created task file: $TASK_FILE${NC}"

  # Create individual task JSON file (task1.json, task2.json, etc.)
  # This stores task metadata separately for better visibility and MCP access
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

  # Update index.json with list of task filenames (not the actual task data)
  # index.json stores only references to individual task files: ["task1.json", "task2.json", ...]
  # Actual task data is in the individual task*.json files
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

# Show component size summary
echo -e "${BLUE}Component Size Validation Summary:${NC}\n"

SAFE_TASKS=$(cat .claude/tasks/task*.json 2>/dev/null | jq -s '[.[] | select(.nodeCount <= 300)] | length')
WARNING_TASKS=$(cat .claude/tasks/task*.json 2>/dev/null | jq -s '[.[] | select(.nodeCount > 300 and .nodeCount <= 500)] | length')
OVERSIZED_TASKS=$(cat .claude/tasks/task*.json 2>/dev/null | jq -s '[.[] | select(.isOversized == "true")] | length')

echo -e "${GREEN}✅ Safe components (<300 nodes): $SAFE_TASKS${NC}"
if [ "$WARNING_TASKS" -gt 0 ]; then
  echo -e "${YELLOW}⚠️  Warning - Near limit (300-500 nodes): $WARNING_TASKS${NC}"
  cat .claude/tasks/task*.json 2>/dev/null | jq -s -r '.[] | select(.nodeCount > 300 and .nodeCount <= 500) | "  - \(.title): \(.nodeCount) nodes"'
fi
if [ "$OVERSIZED_TASKS" -gt 0 ]; then
  echo -e "${RED}❌ Oversized (>500 nodes, may fail): $OVERSIZED_TASKS${NC}"
  cat .claude/tasks/task*.json 2>/dev/null | jq -s -r '.[] | select(.isOversized == "true") | "  - \(.title): \(.nodeCount) nodes (needs manual review)"'
fi

echo ""

# Show task stats
get_task_stats

echo -e "\n${YELLOW}Next Steps:${NC}"
echo -e "  1. Review task index: ${BLUE}cat .claude/tasks/index.json | jq${NC}"
echo -e "  2. View specific task: ${BLUE}cat .claude/tasks/task1.json | jq${NC}"
echo -e "  3. View all tasks: ${BLUE}cat .claude/tasks/task*.json | jq -s${NC}"
echo -e "  4. Start implementation: ${BLUE}/implement${NC}"
echo -e "  5. Or switch to specific task: ${BLUE}/implement <branch-name>${NC}\n"

echo -e "${BLUE}✓ Tasks created as individual JSON files in .claude/tasks/${NC}"
echo -e "${BLUE}✓ Each task has a Figma node ID for MCP access${NC}"
echo -e "${BLUE}✓ index.json lists all task filenames (not the full task data)${NC}"
