#!/bin/bash
# Consolidate all task files from branches to main

set -e

echo "Consolidating task files from branches..."

# Get all issue branches sorted by issue number
branches=$(git branch | grep "issue-" | sed 's/^[* ]*//' | sort -t'-' -k2 -n)

count=0

# For each branch, extract the task file
for branch in $branches; do
  # Get issue number from branch name (issue-30-e -> 30)
  issue_num=$(echo "$branch" | grep -oE 'issue-[0-9]+' | grep -oE '[0-9]+')

  # Skip old issues (before the new breakdown at issue 30)
  if [ "$issue_num" -lt 30 ]; then
    continue
  fi

  # Calculate task number (issue 30 = task 1, issue 31 = task 2, etc.)
  task_num=$((issue_num - 29))

  # Extract the specific task file for this task number
  task_content=$(git show "$branch:.claude/tasks/task${task_num}.json" 2>/dev/null || true)

  if [ -n "$task_content" ]; then
    # Update the id field to match the task number (if needed)
    echo "$task_content" | jq --arg id "$task_num" '.id = $id' > ".claude/tasks/task${task_num}.json"
    count=$((count + 1))
    echo "  Task $task_num from $branch (task${task_num}.json)"
  fi
done

# Create new index
echo '{"tasks":[],"lastUpdated":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' > .claude/tasks/index.json

# Add all collected tasks to index in order
for task_file in $(ls .claude/tasks/task*.json | sort -V); do
  filename=$(basename "$task_file")
  jq --arg tf "$filename" '.tasks += [$tf]' .claude/tasks/index.json > .claude/tasks/index.json.tmp
  mv .claude/tasks/index.json.tmp .claude/tasks/index.json
done

total=$(jq '.tasks | length' .claude/tasks/index.json)
echo ""
echo "✓ Consolidated $total task files"
