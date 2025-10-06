#!/bin/bash

# Branch Detection Helper Functions
# Detect current branch and load task information

# Get current git branch
get_current_branch() {
  git branch --show-current 2>/dev/null
}

# Extract issue number from branch name
# Example: issue-5-product-card → 5
get_issue_number() {
  local branch=${1:-$(get_current_branch)}
  echo "$branch" | grep -o 'issue-[0-9]*' | grep -o '[0-9]*'
}

# Get task file path from branch name
get_task_file() {
  local branch=${1:-$(get_current_branch)}
  local issue_num=$(get_issue_number "$branch")

  if [ -z "$issue_num" ]; then
    return 1
  fi

  # Find task file matching issue number
  find .claude/tasks -name "issue-${issue_num}-*.md" -print -quit
}

# Get task slug from branch name
# Example: issue-5-product-card → product-card
get_task_slug() {
  local branch=${1:-$(get_current_branch)}
  echo "$branch" | sed -E 's/^issue-[0-9]+-//'
}

# Check if current branch is an issue branch
is_issue_branch() {
  local branch=$(get_current_branch)
  [[ "$branch" =~ ^issue-[0-9]+-.*$ ]]
}

# Get task info from index.json
get_task_info() {
  local branch=${1:-$(get_current_branch)}

  if [ ! -f .claude/tasks/index.json ]; then
    echo "Error: Task index not found" >&2
    return 1
  fi

  jq -r ".tasks[] | select(.branch == \"$branch\")" .claude/tasks/index.json 2>/dev/null
}

# Get task status
get_task_status() {
  local branch=${1:-$(get_current_branch)}
  get_task_info "$branch" | jq -r '.status // empty'
}

# Get task title
get_task_title() {
  local branch=${1:-$(get_current_branch)}
  get_task_info "$branch" | jq -r '.title // empty'
}

# Get task complexity
get_task_complexity() {
  local branch=${1:-$(get_current_branch)}
  get_task_info "$branch" | jq -r '.complexity // empty'
}

# Get Figma link from task
get_figma_link() {
  local branch=${1:-$(get_current_branch)}
  get_task_info "$branch" | jq -r '.figmaLink // empty'
}

# Check if git working directory is clean
is_working_directory_clean() {
  git diff-index --quiet HEAD -- 2>/dev/null
}

# Get list of changed files
get_changed_files() {
  git status --porcelain | awk '{print $2}'
}

# Search for task by query (branch name, issue number, or title keyword)
search_task() {
  local query=$1

  if [ ! -f .claude/tasks/index.json ]; then
    echo "Error: Task index not found" >&2
    return 1
  fi

  # Try exact branch match first
  local result=$(jq -r ".tasks[] | select(.branch == \"$query\")" .claude/tasks/index.json 2>/dev/null)

  # Try issue number
  if [ -z "$result" ]; then
    local clean_query=$(echo "$query" | sed 's/^#//')
    result=$(jq -r ".tasks[] | select(.issueNumber == $clean_query)" .claude/tasks/index.json 2>/dev/null)
  fi

  # Try partial match on slug
  if [ -z "$result" ]; then
    result=$(jq -r ".tasks[] | select(.slug | contains(\"$query\"))" .claude/tasks/index.json 2>/dev/null)
  fi

  # Try partial match on title
  if [ -z "$result" ]; then
    result=$(jq -r ".tasks[] | select(.title | ascii_downcase | contains(\"${query,,}\"))" .claude/tasks/index.json 2>/dev/null)
  fi

  echo "$result"
}

# List all available tasks
list_all_tasks() {
  if [ ! -f .claude/tasks/index.json ]; then
    echo "No tasks found"
    return 1
  fi

  jq -r '.tasks[] | "\(.id). [\(.status)] \(.title) (branch: \(.branch))"' .claude/tasks/index.json
}

# List tasks by status
list_tasks_by_status() {
  local status=$1

  if [ ! -f .claude/tasks/index.json ]; then
    echo "No tasks found"
    return 1
  fi

  jq -r ".tasks[] | select(.status == \"$status\") | \"\(.id). \(.title) (branch: \(.branch))\"" .claude/tasks/index.json
}

# Get next available task (based on dependencies and status)
get_next_task() {
  if [ ! -f .claude/tasks/index.json ]; then
    return 1
  fi

  # Find first pending task with no incomplete dependencies
  jq -r '.tasks[] | select(.status == "pending") | .branch' .claude/tasks/index.json | head -n 1
}

# Validate branch exists in git
branch_exists() {
  local branch=$1
  git show-ref --verify --quiet "refs/heads/$branch"
}

# Export functions for use in other scripts
export -f get_current_branch
export -f get_issue_number
export -f get_task_file
export -f get_task_slug
export -f is_issue_branch
export -f get_task_info
export -f get_task_status
export -f get_task_title
export -f get_task_complexity
export -f get_figma_link
export -f is_working_directory_clean
export -f get_changed_files
export -f search_task
export -f list_all_tasks
export -f list_tasks_by_status
export -f get_next_task
export -f branch_exists
