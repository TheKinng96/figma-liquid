#!/bin/bash

# Task Management Helper Functions
# CRUD operations for tasks in index.json

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TASKS_DIR=".claude/tasks"
INDEX_FILE="$TASKS_DIR/index.json"

# Initialize tasks directory and index
init_tasks() {
  mkdir -p "$TASKS_DIR"

  if [ ! -f "$INDEX_FILE" ]; then
    echo '{"tasks":[]}' > "$INDEX_FILE"
    echo -e "${GREEN}✓ Task index created${NC}"
  fi
}

# Add new task to index
add_task() {
  local id=$1
  local issue_number=$2
  local title=$3
  local slug=$4
  local branch=$5
  local figma_link=$6
  local complexity=${7:-0}

  init_tasks

  local task_data=$(cat <<EOF
{
  "id": "$id",
  "issueNumber": $issue_number,
  "title": "$title",
  "slug": "$slug",
  "branch": "$branch",
  "file": "issue-${issue_number}-${slug}.md",
  "figmaLink": "$figma_link",
  "complexity": $complexity,
  "status": "pending",
  "phase": "analysis",
  "created": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "htmlComplete": false,
  "liquidComplete": false,
  "testsPass": false
}
EOF
)

  # Add task to array
  jq ".tasks += [$task_data]" "$INDEX_FILE" > "$INDEX_FILE.tmp" && mv "$INDEX_FILE.tmp" "$INDEX_FILE"

  echo -e "${GREEN}✓ Task added: $title${NC}"
}

# Update task status
update_task_status() {
  local branch=$1
  local status=$2

  if [ ! -f "$INDEX_FILE" ]; then
    echo -e "${RED}❌ Task index not found${NC}" >&2
    return 1
  fi

  jq "(.tasks[] | select(.branch == \"$branch\") | .status) = \"$status\" |
      (.tasks[] | select(.branch == \"$branch\") | .updated) = \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"" \
      "$INDEX_FILE" > "$INDEX_FILE.tmp" && mv "$INDEX_FILE.tmp" "$INDEX_FILE"

  echo -e "${GREEN}✓ Task status updated: $status${NC}"
}

# Update task phase
update_task_phase() {
  local branch=$1
  local phase=$2  # analysis, html, liquid

  jq "(.tasks[] | select(.branch == \"$branch\") | .phase) = \"$phase\" |
      (.tasks[] | select(.branch == \"$branch\") | .updated) = \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"" \
      "$INDEX_FILE" > "$INDEX_FILE.tmp" && mv "$INDEX_FILE.tmp" "$INDEX_FILE"

  echo -e "${GREEN}✓ Task phase updated: $phase${NC}"
}

# Mark HTML complete
mark_html_complete() {
  local branch=$1

  jq "(.tasks[] | select(.branch == \"$branch\") | .htmlComplete) = true |
      (.tasks[] | select(.branch == \"$branch\") | .phase) = \"html\" |
      (.tasks[] | select(.branch == \"$branch\") | .updated) = \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"" \
      "$INDEX_FILE" > "$INDEX_FILE.tmp" && mv "$INDEX_FILE.tmp" "$INDEX_FILE"

  echo -e "${GREEN}✓ HTML marked complete${NC}"
}

# Mark Liquid complete
mark_liquid_complete() {
  local branch=$1

  jq "(.tasks[] | select(.branch == \"$branch\") | .liquidComplete) = true |
      (.tasks[] | select(.branch == \"$branch\") | .phase) = \"liquid\" |
      (.tasks[] | select(.branch == \"$branch\") | .status) = \"completed\" |
      (.tasks[] | select(.branch == \"$branch\") | .updated) = \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"" \
      "$INDEX_FILE" > "$INDEX_FILE.tmp" && mv "$INDEX_FILE.tmp" "$INDEX_FILE"

  echo -e "${GREEN}✓ Liquid marked complete${NC}"
}

# Update tests status
update_tests_status() {
  local branch=$1
  local passed=$2  # true/false

  jq "(.tasks[] | select(.branch == \"$branch\") | .testsPass) = $passed |
      (.tasks[] | select(.branch == \"$branch\") | .updated) = \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"" \
      "$INDEX_FILE" > "$INDEX_FILE.tmp" && mv "$INDEX_FILE.tmp" "$INDEX_FILE"

  echo -e "${GREEN}✓ Tests status updated: $passed${NC}"
}

# Get task by branch
get_task_by_branch() {
  local branch=$1

  if [ ! -f "$INDEX_FILE" ]; then
    return 1
  fi

  jq -r ".tasks[] | select(.branch == \"$branch\")" "$INDEX_FILE"
}

# Get all tasks
get_all_tasks() {
  if [ ! -f "$INDEX_FILE" ]; then
    echo '{"tasks":[]}'
    return
  fi

  cat "$INDEX_FILE"
}

# Count tasks by status
count_tasks_by_status() {
  local status=$1

  if [ ! -f "$INDEX_FILE" ]; then
    echo "0"
    return
  fi

  jq "[.tasks[] | select(.status == \"$status\")] | length" "$INDEX_FILE"
}

# Get task statistics
get_task_stats() {
  if [ ! -f "$INDEX_FILE" ]; then
    echo "No tasks found"
    return
  fi

  local total=$(jq '.tasks | length' "$INDEX_FILE")
  local pending=$(count_tasks_by_status "pending")
  local in_progress=$(count_tasks_by_status "in_progress")
  local completed=$(count_tasks_by_status "completed")

  echo -e "${BLUE}Task Statistics:${NC}"
  echo -e "  Total: $total"
  echo -e "  Pending: $pending"
  echo -e "  In Progress: $in_progress"
  echo -e "  Completed: $completed"

  if [ "$total" -gt 0 ]; then
    local progress=$(echo "scale=0; $completed * 100 / $total" | bc)
    echo -e "  Progress: ${progress}%"
  fi
}

# Display task summary
show_task() {
  local branch=$1
  local task=$(get_task_by_branch "$branch")

  if [ -z "$task" ]; then
    echo -e "${RED}❌ Task not found for branch: $branch${NC}"
    return 1
  fi

  local title=$(echo "$task" | jq -r '.title')
  local status=$(echo "$task" | jq -r '.status')
  local phase=$(echo "$task" | jq -r '.phase')
  local complexity=$(echo "$task" | jq -r '.complexity')
  local html_complete=$(echo "$task" | jq -r '.htmlComplete')
  local liquid_complete=$(echo "$task" | jq -r '.liquidComplete')
  local tests_pass=$(echo "$task" | jq -r '.testsPass')

  echo -e "\n${BLUE}Task: $title${NC}"
  echo -e "  Branch: $branch"
  echo -e "  Status: $status"
  echo -e "  Phase: $phase"
  echo -e "  Complexity: $complexity/10"
  echo -e "  HTML Complete: $html_complete"
  echo -e "  Liquid Complete: $liquid_complete"
  echo -e "  Tests Pass: $tests_pass"
  echo ""
}

# List tasks with formatting
list_tasks() {
  local status_filter=${1:-"all"}

  if [ ! -f "$INDEX_FILE" ]; then
    echo "No tasks found"
    return
  fi

  echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}Tasks${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

  if [ "$status_filter" = "all" ]; then
    jq -r '.tasks[] | "\(.id). [\(.status)] \(.title) (branch: \(.branch))"' "$INDEX_FILE"
  else
    jq -r ".tasks[] | select(.status == \"$status_filter\") | \"\(.id). [\(.status)] \(.title) (branch: \(.branch))\"" "$INDEX_FILE"
  fi

  echo ""
}

# Delete task
delete_task() {
  local branch=$1

  if [ ! -f "$INDEX_FILE" ]; then
    echo -e "${RED}❌ Task index not found${NC}" >&2
    return 1
  fi

  jq ".tasks |= map(select(.branch != \"$branch\"))" "$INDEX_FILE" > "$INDEX_FILE.tmp" && mv "$INDEX_FILE.tmp" "$INDEX_FILE"

  echo -e "${GREEN}✓ Task deleted${NC}"
}

# Create task file from template
create_task_file() {
  local issue_number=$1
  local component_name=$2
  local slug=$3
  local figma_link=$4
  local complexity=$5

  local template_file=".claude/templates/task-template.md"
  local output_file="$TASKS_DIR/issue-${issue_number}-${slug}.md"

  if [ ! -f "$template_file" ]; then
    echo -e "${RED}❌ Template not found: $template_file${NC}" >&2
    return 1
  fi

  # Copy template and replace placeholders
  sed -e "s/{ISSUE_NUMBER}/$issue_number/g" \
      -e "s/{COMPONENT_NAME}/$component_name/g" \
      -e "s/{SLUG}/$slug/g" \
      -e "s|{FIGMA_LINK}|$figma_link|g" \
      -e "s/{COMPLEXITY}/$complexity/g" \
      -e "s/{TIMESTAMP}/$(date -u +%Y-%m-%dT%H:%M:%SZ)/g" \
      "$template_file" > "$output_file"

  echo "$output_file"
}

# Update task file with timestamp entry
log_to_task_file() {
  local task_file=$1
  local message=$2

  if [ ! -f "$task_file" ]; then
    echo -e "${RED}❌ Task file not found: $task_file${NC}" >&2
    return 1
  fi

  # Find implementation log section and add entry
  local timestamp=$(date -u +%Y-%m-%dT%H:%M:%S)
  sed -i.bak "/^```$/a\\
$timestamp - $message" "$task_file"

  rm "${task_file}.bak"
}

# Export functions
export -f init_tasks
export -f add_task
export -f update_task_status
export -f update_task_phase
export -f mark_html_complete
export -f mark_liquid_complete
export -f update_tests_status
export -f get_task_by_branch
export -f get_all_tasks
export -f count_tasks_by_status
export -f get_task_stats
export -f show_task
export -f list_tasks
export -f delete_task
export -f create_task_file
export -f log_to_task_file
