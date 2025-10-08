#!/bin/bash

# Figma Utility Functions
# Helper functions for analyzing Figma components

# Check if a component needs a container wrapper
# Returns: "true" if needs container, "false" otherwise
needs_container() {
  local node_id=$1
  local figma_json=${2:-"logs/figma-full-file.json"}

  # Get node data
  local node_data=$(jq --arg nodeid "$node_id" '
    .. | objects | select(.id == $nodeid)
  ' "$figma_json" | jq -s '.[0]')

  # Check if node has layoutMode (auto-layout)
  local has_layout=$(echo "$node_data" | jq -r '.layoutMode // "NONE"')

  # Check if children are positioned at frame edges (no explicit container)
  local frame_width=$(echo "$node_data" | jq -r '.absoluteBoundingBox.width // 0')
  local children_width=$(echo "$node_data" | jq -r '
    [.children[]? | .absoluteBoundingBox.width] | max // 0
  ')

  # If no auto-layout AND children width >= frame width, likely needs container
  if [ "$has_layout" = "NONE" ] && [ "$(echo "$children_width >= $frame_width - 20" | bc -l)" -eq 1 ]; then
    echo "true"
  else
    echo "false"
  fi
}

# Get container specifications for a component
get_container_spec() {
  local node_id=$1
  local figma_json=${2:-"logs/figma-full-file.json"}

  local node_data=$(jq --arg nodeid "$node_id" '
    .. | objects | select(.id == $nodeid)
  ' "$figma_json" | jq -s '.[0]')

  # Extract dimensions
  local width=$(echo "$node_data" | jq -r '.absoluteBoundingBox.width // 0')
  local height=$(echo "$node_data" | jq -r '.absoluteBoundingBox.height // 0')

  # Check for padding (if has layoutMode)
  local padding_left=$(echo "$node_data" | jq -r '.paddingLeft // 0')
  local padding_right=$(echo "$node_data" | jq -r '.paddingRight // 0')
  local padding_top=$(echo "$node_data" | jq -r '.paddingTop // 0')
  local padding_bottom=$(echo "$node_data" | jq -r '.paddingBottom // 0')

  # Return JSON spec
  cat <<EOF
{
  "width": $width,
  "height": $height,
  "padding": {
    "top": $padding_top,
    "right": $padding_right,
    "bottom": $padding_bottom,
    "left": $padding_left
  },
  "needsContainer": $(needs_container "$node_id" "$figma_json")
}
EOF
}

# Get all sections from a parent component, sorted by Y position
get_sections_sorted() {
  local parent_node_id=$1
  local figma_json=${2:-"logs/figma-full-file.json"}

  jq --arg nodeid "$parent_node_id" '
    .. | objects | select(.id == $nodeid) |
    [.children[]? |
      select(.type == "FRAME" or .type == "GROUP" or .type == "SECTION") |
      {
        nodeId: .id,
        name: .name,
        type: .type,
        y: (.absoluteBoundingBox.y // 0),
        x: (.absoluteBoundingBox.x // 0),
        width: (.absoluteBoundingBox.width // 0),
        height: (.absoluteBoundingBox.height // 0)
      }
    ] | sort_by(.y)
  ' "$figma_json"
}

# Extract component metadata for HTML generation
get_component_metadata() {
  local node_id=$1
  local figma_json=${2:-"logs/figma-full-file.json"}

  jq --arg nodeid "$node_id" '
    def extract_colors:
      if .fills then
        [.fills[] |
          select(.type == "SOLID") |
          {
            r: (.color.r * 255 | floor),
            g: (.color.g * 255 | floor),
            b: (.color.b * 255 | floor),
            a: .color.a,
            hex: "#" + (
              [(.color.r * 255 | floor),
               (.color.g * 255 | floor),
               (.color.b * 255 | floor)] |
              map(tostring |
                  if length == 1 then "0" + . else . end) |
              join("")
            )
          }
        ]
      else [] end;

    def extract_text_styles:
      if .style then
        {
          fontFamily: .style.fontFamily,
          fontSize: .style.fontSize,
          fontWeight: .style.fontWeight,
          lineHeight: .style.lineHeightPx,
          letterSpacing: .style.letterSpacing,
          textAlign: .style.textAlignHorizontal
        }
      else null end;

    .. | objects | select(.id == $nodeid) |
    {
      id: .id,
      name: .name,
      type: .type,
      width: .absoluteBoundingBox.width,
      height: .absoluteBoundingBox.height,
      x: .absoluteBoundingBox.x,
      y: .absoluteBoundingBox.y,
      layoutMode: .layoutMode,
      paddingLeft: .paddingLeft,
      paddingRight: .paddingRight,
      paddingTop: .paddingTop,
      paddingBottom: .paddingBottom,
      itemSpacing: .itemSpacing,
      counterAxisAlignItems: .counterAxisAlignItems,
      primaryAxisAlignItems: .primaryAxisAlignItems,
      fills: extract_colors,
      textStyle: extract_text_styles,
      children: [.children[]? | {id: .id, name: .name, type: .type}]
    }
  ' "$figma_json"
}

# Export functions
export -f needs_container
export -f get_container_spec
export -f get_sections_sorted
export -f get_component_metadata
