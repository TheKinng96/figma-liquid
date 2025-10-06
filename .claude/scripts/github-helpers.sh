#!/bin/bash

# GitHub Helper Functions
# Utility functions for GitHub CLI operations

# Create a GitHub issue
# Usage: create_github_issue <title> <body> <labels>
create_github_issue() {
  local title=$1
  local body=$2
  local labels=$3

  gh issue create \
    --title "$title" \
    --body "$body" \
    --label "$labels"
}

# Update GitHub issue
# Usage: update_github_issue <issue_number> <comment>
update_github_issue() {
  local issue_number=$1
  local comment=$2

  gh issue comment "$issue_number" --body "$comment"
}

# Close GitHub issue
# Usage: close_github_issue <issue_number> <comment>
close_github_issue() {
  local issue_number=$1
  local comment=$2

  gh issue close "$issue_number" --comment "$comment"
}

# Add issue to project
# Usage: add_to_project <issue_number> <project_number>
add_to_project() {
  local issue_number=$1
  local project_number=$2

  gh issue edit "$issue_number" --add-project "$project_number"
}

# Get issue status
# Usage: get_issue_status <issue_number>
get_issue_status() {
  local issue_number=$1

  gh issue view "$issue_number" --json state -q .state
}

# List open issues with label
# Usage: list_issues_by_label <label>
list_issues_by_label() {
  local label=$1

  gh issue list --label "$label" --json number,title,state
}

# Export for use in other scripts
export -f create_github_issue
export -f update_github_issue
export -f close_github_issue
export -f add_to_project
export -f get_issue_status
export -f list_issues_by_label
