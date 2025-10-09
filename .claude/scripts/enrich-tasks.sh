#!/bin/bash

# Enrich task JSON files with parent component and section number info
# This script reads the Figma hierarchy and adds parentComponent and sectionNumber fields

set -e

FIGMA_FILE="logs/figma-full-file.json"
TASKS_DIR=".claude/tasks"

if [ ! -f "$FIGMA_FILE" ]; then
  echo "❌ Figma file not found: $FIGMA_FILE"
  exit 1
fi

# Function to find parent component for a node ID
find_parent() {
  local node_id="$1"

  # Find which parent frame contains this node
  jq -r --arg nid "$node_id" '
    [
      .. | objects |
      select(.children? != null) |
      select(
        [.children[]? | objects | .id] | contains([$nid])
      ) |
      {name: .name, id: .id}
    ] | .[0] | .name // empty
  ' "$FIGMA_FILE"
}

# Function to find section number (child index) within parent
find_section_number() {
  local node_id="$1"
  local parent_name="$2"

  # Find the index of this child within the parent's children array
  jq -r --arg nid "$node_id" --arg pname "$parent_name" '
    [
      .. | objects |
      select(.name == $pname and .children? != null)
    ] | .[0] |
    [.children[]? | objects] |
    map(.id) |
    index($nid) // -1 | . + 1
  ' "$FIGMA_FILE"
}

# Process all task JSON files
for task_file in "$TASKS_DIR"/task*.json; do
  if [ ! -f "$task_file" ]; then
    continue
  fi

  echo "Processing: $(basename "$task_file")"

  # Get node ID from task
  node_id=$(jq -r '.nodeId // empty' "$task_file")

  if [ -z "$node_id" ]; then
    echo "  ⚠️  No nodeId, skipping"
    continue
  fi

  # Find parent component
  parent_name=$(find_parent "$node_id")

  if [ -z "$parent_name" ]; then
    echo "  ⚠️  No parent found for node $node_id"
    continue
  fi

  # Convert parent name to slug format
  parent_slug=$(echo "$parent_name" | sed 's/[^a-zA-Z0-9]/-/g' | tr '[:upper:]' '[:lower:]' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')

  # Find section number
  section_num=$(find_section_number "$node_id" "$parent_name")

  echo "  ✓ Parent: $parent_name ($parent_slug), Section: $section_num"

  # Add fields to task JSON
  jq --arg parent "$parent_slug" --arg parent_name "$parent_name" --argjson section "$section_num" \
    '. + {parentComponent: $parent, parentComponentName: $parent_name, sectionNumber: $section}' \
    "$task_file" > "${task_file}.tmp"

  mv "${task_file}.tmp" "$task_file"
done

echo ""
echo "✨ Task enrichment complete!"
