#!/bin/bash

# Figma to Shopify Liquid - Implementation Mode
# Generate HTML/CSS/JS with Playwright validation

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
source "$SCRIPT_DIR/visual-validator.sh"

BRANCH_ARG=$1

echo -e "${PURPLE}⚡ Figma to Liquid - Implementation Mode${NC}\n"

# Function to handle branch switching
switch_to_branch() {
  local target_branch=$1
  local current_branch=$(get_current_branch)

  if [ "$current_branch" = "$target_branch" ]; then
    echo -e "${GREEN}✓ Already on branch: $target_branch${NC}"
    return 0
  fi

  # Check for uncommitted changes
  if ! is_working_directory_clean; then
    echo -e "${YELLOW}⚠️  Uncommitted changes detected:${NC}"
    get_changed_files
    echo ""
    echo "Options:"
    echo "  (s) Stash changes and switch"
    echo "  (c) Commit changes and switch"
    echo "  (n) Cancel and stay on current branch"
    echo ""
    read -p "Choose (s/c/n): " choice

    case $choice in
      s)
        git stash push -m "WIP: $current_branch before switching to $target_branch"
        echo -e "${GREEN}✓ Changes stashed${NC}"
        ;;
      c)
        git add .
        git commit -m "WIP: Auto-commit before switching to $target_branch"
        echo -e "${GREEN}✓ Changes committed${NC}"
        ;;
      n)
        echo "Cancelled"
        exit 0
        ;;
      *)
        echo "Invalid choice"
        exit 1
        ;;
    esac
  fi

  # Switch branch
  git checkout "$target_branch"
  echo -e "${GREEN}✓ Switched to branch: $target_branch${NC}\n"
}

# Determine which task to work on
if [ -z "$BRANCH_ARG" ]; then
  # Auto-detect mode
  echo -e "${BLUE}Mode: Auto-detect from current branch${NC}\n"

  if ! is_issue_branch; then
    echo -e "${RED}❌ Not on an issue branch${NC}"
    echo -e "${YELLOW}Available tasks:${NC}\n"
    list_tasks "pending"
    echo -e "\nUsage: /implement <branch-name>"
    exit 1
  fi

  TARGET_BRANCH=$(get_current_branch)
else
  # Explicit branch mode
  echo -e "${BLUE}Mode: Switch to specific task${NC}\n"

  # Search for task
  TASK_RESULT=$(search_task "$BRANCH_ARG")

  if [ -z "$TASK_RESULT" ]; then
    echo -e "${RED}❌ Task not found: $BRANCH_ARG${NC}"
    echo -e "\n${YELLOW}Available tasks:${NC}\n"
    list_tasks
    exit 1
  fi

  TARGET_BRANCH=$(echo "$TASK_RESULT" | jq -r '.branch')
  TASK_TITLE=$(echo "$TASK_RESULT" | jq -r '.title')

  echo -e "${GREEN}Found task: #$(echo "$TASK_RESULT" | jq -r '.issueNumber') - $TASK_TITLE${NC}"
  echo -e "${BLUE}Branch: $TARGET_BRANCH${NC}\n"

  read -p "Switch to this task? (Y/n): " confirm
  if [ "$confirm" = "n" ]; then
    echo "Cancelled"
    exit 0
  fi

  # Switch to branch
  switch_to_branch "$TARGET_BRANCH"
fi

# Load task info
TASK_FILE=$(get_task_file "$TARGET_BRANCH")
if [ ! -f "$TASK_FILE" ]; then
  echo -e "${RED}❌ Task file not found: $TASK_FILE${NC}"
  exit 1
fi

TASK_INFO=$(get_task_info "$TARGET_BRANCH")
TASK_TITLE=$(get_task_title "$TARGET_BRANCH")
TASK_SLUG=$(get_task_slug "$TARGET_BRANCH")
COMPLEXITY=$(get_task_complexity "$TARGET_BRANCH")
FIGMA_LINK=$(get_figma_link "$TARGET_BRANCH")
STATUS=$(get_task_status "$TARGET_BRANCH")

# Extract node ID from task index
NODE_ID=$(jq -r ".tasks[] | select(.branch == \"$TARGET_BRANCH\") | .nodeId // empty" .claude/tasks/index.json)

if [ -z "$NODE_ID" ]; then
  echo -e "${YELLOW}⚠️  No node ID found in task index${NC}"
  echo -e "${YELLOW}Attempting to extract from task file...${NC}"
  NODE_ID=$(grep -A 1 "## Figma Node ID" "$TASK_FILE" | tail -1 | tr -d '`' || echo "")
fi

if [ -z "$NODE_ID" ]; then
  echo -e "${RED}❌ Node ID not found. Cannot access Figma component via MCP.${NC}"
  echo -e "${YELLOW}Please ensure the task was created with /breakdown${NC}"
  exit 1
fi

echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Task: $TASK_TITLE${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
echo -e "Branch: $TARGET_BRANCH"
echo -e "Node ID: ${GREEN}$NODE_ID${NC}"
echo -e "Complexity: $COMPLEXITY/10"
echo -e "Status: $STATUS"
echo -e "Figma: $FIGMA_LINK"
echo ""

# Check Phase 1 completion
echo -e "${BLUE}Checking Phase 1 (Analysis)...${NC}"

PHASE1_COMPLETE=$(grep -A 20 "## Phase 1: Analysis" "$TASK_FILE" | grep -c "\[x\]" || echo "0")
PHASE1_TOTAL=$(grep -A 20 "## Phase 1: Analysis" "$TASK_FILE" | grep -c "\[ \]\|\[x\]" || echo "1")

if [ "$PHASE1_COMPLETE" -lt "$PHASE1_TOTAL" ]; then
  echo -e "${YELLOW}⚠️  Phase 1 incomplete: $PHASE1_COMPLETE/$PHASE1_TOTAL items checked${NC}"
  echo -e "${YELLOW}Recommendations:${NC}"
  echo -e "  - Complete Figma analysis with MCP"
  echo -e "  - Document all design specs"
  echo -e "  - List all required assets"
  echo ""
  read -p "Proceed to Phase 2 anyway? (y/N): " proceed
  if [ "$proceed" != "y" ]; then
    echo "Please complete Phase 1 first"
    exit 0
  fi
else
  echo -e "${GREEN}✓ Phase 1 complete${NC}\n"
fi

# Update task status
if [ "$STATUS" = "pending" ]; then
  update_task_status "$TARGET_BRANCH" "in_progress"
fi

update_task_phase "$TARGET_BRANCH" "html"

# Create output directories
mkdir -p html css js tests

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Phase 2: HTML Implementation${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo -e "${YELLOW}Claude will now:${NC}"
echo -e "  1. Analyze Figma component using MCP"
echo -e "  2. Generate semantic HTML structure"
echo -e "  3. Create BEM CSS styles"
echo -e "  4. Add JavaScript if needed"
echo -e "  5. Create Playwright tests"
echo -e "  6. Run visual validation"
echo -e "  7. Update task file with results"
echo ""

# Log to task file
log_to_task_file "$TASK_FILE" "Phase 2 started"

# Set up Playwright if not already configured
if [ ! -f playwright.config.js ]; then
  echo -e "${YELLOW}Setting up Playwright...${NC}"

  cat > playwright.config.js <<'EOF'
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:8000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
});
EOF

  echo -e "${GREEN}✓ Playwright configured${NC}\n"
fi

# Check if package.json exists
if [ ! -f package.json ]; then
  npm init -y > /dev/null 2>&1
fi

# Install Playwright if needed
if ! npm list @playwright/test > /dev/null 2>&1; then
  echo -e "${YELLOW}Installing Playwright...${NC}"
  npm install -D @playwright/test > /dev/null 2>&1
  echo -e "${GREEN}✓ Playwright installed${NC}\n"
fi

# Placeholder for Claude to implement
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Ready for Implementation${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo -e "${GREEN}Environment ready. Claude will now:${NC}"
echo -e "  1. Use MCP to fetch Figma component data for node: ${GREEN}$NODE_ID${NC}"
echo -e "  2. Generate HTML at: ${BLUE}html/$TASK_SLUG.html${NC}"
echo -e "  3. Generate CSS at: ${BLUE}css/$TASK_SLUG.css${NC}"
echo -e "  4. Generate tests at: ${BLUE}tests/$TASK_SLUG.spec.js${NC}"
echo -e "  5. Run Playwright tests"
echo -e "  6. Validate visual match ≥98%"
echo ""

echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${PURPLE}MCP INSTRUCTIONS FOR CLAUDE${NC}"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo -e "${BLUE}Use these MCP tools with node ID: ${GREEN}$NODE_ID${NC}\n"

echo -e "${YELLOW}1. Get Component Metadata:${NC}"
echo -e "   mcp__figma-dev-mode-mcp-server__get_metadata"
echo -e "   - nodeId: $NODE_ID"
echo -e "   - Returns: XML structure with layers, positions, sizes\n"

echo -e "${YELLOW}2. Get Component Code/Styles:${NC}"
echo -e "   mcp__figma-dev-mode-mcp-server__get_code"
echo -e "   - nodeId: $NODE_ID"
echo -e "   - Returns: Generated CSS and design specs\n"

echo -e "${YELLOW}3. Get Component Screenshot:${NC}"
echo -e "   mcp__figma-dev-mode-mcp-server__get_screenshot"
echo -e "   - nodeId: $NODE_ID"
echo -e "   - Returns: Visual reference for validation\n"

echo -e "${YELLOW}4. Get Variables (if needed):${NC}"
echo -e "   mcp__figma-dev-mode-mcp-server__get_variable_defs"
echo -e "   - nodeId: $NODE_ID"
echo -e "   - Returns: Design system variables\n"

echo -e "${GREEN}After implementation:${NC}"
echo -e "  - Run: ${BLUE}npm run test:validate${NC} (if configured)"
echo -e "  - Mark HTML complete: ${BLUE}mark_html_complete \"$TARGET_BRANCH\"${NC}"
echo -e "  - Update task file with progress\n"

echo -e "${YELLOW}Tests will run automatically when implementation is done.${NC}"
echo -e "${YELLOW}Task will be marked complete when all tests pass.${NC}\n"

# Export node ID for Claude to access
export FIGMA_NODE_ID="$NODE_ID"
export TASK_SLUG="$TASK_SLUG"
export TASK_BRANCH="$TARGET_BRANCH"

# Note: Actual implementation happens through Claude's MCP and code generation
# This script sets up the environment and provides structure
