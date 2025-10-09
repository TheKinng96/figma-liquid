#!/bin/bash
# Consolidate all task files from branches to main

set -e

cd /Users/gen/Code/figma-liquid

# Get all task branches
branches=$(git branch | grep "issue-" | sed 's/^[* ]*//')

# Create tasks array
echo '{"tasks":[],"lastUpdated":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' > .claude/tasks/index.json

# Copy task files from each branch
for branch in $branches; do
  echo "Processing $branch..."

  # Get task file from branch
  task_file=$(git show "$branch:.claude/tasks/index.json" 2>/dev/null | jq -r '.tasks[]' 2>/dev/null || echo "")

  if [ -n "$task_file" ]; then
    # Extract task content
    git show "$branch:.claude/tasks/$task_file" > ".claude/tasks/$task_file" 2>/dev/null || true

    # Add to index
    if [ -f ".claude/tasks/$task_file" ]; then
      jq --arg tf "$task_file" '.tasks += [$tf]' .claude/tasks/index.json > .claude/tasks/index.json.tmp
      mv .claude/tasks/index.json.tmp .claude/tasks/index.json
      echo "  Added $task_file"
    fi
  fi
done

# Sort tasks by ID
jq '.tasks |= (map(ltrimstr("task") | rtrimstr(".json") | tonumber) | sort | map("task" + tostring + ".json"))' \
  .claude/tasks/index.json > .claude/tasks/index.json.tmp
mv .claude/tasks/index.json.tmp .claude/tasks/index.json

echo ""
echo "Consolidated $(jq '.tasks | length' .claude/tasks/index.json) tasks"
