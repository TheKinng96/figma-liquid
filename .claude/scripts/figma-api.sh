#!/bin/bash

# Figma API Helper Functions
# Utility functions for interacting with Figma API

# Get Figma access token from .env
get_figma_token() {
  if [ -f .env ]; then
    grep "FIGMA_ACCESS_TOKEN=" .env | cut -d '=' -f2
  else
    echo ""
  fi
}

# Fetch Figma file data
# Usage: fetch_figma_file <file_key>
fetch_figma_file() {
  local file_key=$1
  local token=$(get_figma_token)

  if [ -z "$token" ]; then
    echo "Error: FIGMA_ACCESS_TOKEN not found in .env" >&2
    return 1
  fi

  curl -s -H "X-Figma-Token: $token" \
    "https://api.figma.com/v1/files/$file_key"
}

# Fetch specific node from Figma
# Usage: fetch_figma_node <file_key> <node_id>
fetch_figma_node() {
  local file_key=$1
  local node_id=$2
  local token=$(get_figma_token)

  if [ -z "$token" ]; then
    echo "Error: FIGMA_ACCESS_TOKEN not found in .env" >&2
    return 1
  fi

  curl -s -H "X-Figma-Token: $token" \
    "https://api.figma.com/v1/files/$file_key/nodes?ids=$node_id"
}

# Get image URLs for nodes
# Usage: fetch_figma_images <file_key> <node_ids> [format] [scale]
fetch_figma_images() {
  local file_key=$1
  local node_ids=$2
  local format=${3:-png}
  local scale=${4:-2}
  local token=$(get_figma_token)

  if [ -z "$token" ]; then
    echo "Error: FIGMA_ACCESS_TOKEN not found in .env" >&2
    return 1
  fi

  curl -s -H "X-Figma-Token: $token" \
    "https://api.figma.com/v1/images/$file_key?ids=$node_ids&format=$format&scale=$scale"
}

# Download image from Figma
# Usage: download_figma_image <image_url> <output_path>
download_figma_image() {
  local image_url=$1
  local output_path=$2

  curl -s -o "$output_path" "$image_url"
}

# Extract file key from Figma URL
# Usage: extract_file_key <figma_url>
extract_file_key() {
  local url=$1
  echo "$url" | sed -E 's|https://www\.figma\.com/(design|file)/([^/]+).*|\2|'
}

# Extract node ID from Figma URL
# Usage: extract_node_id <figma_url>
extract_node_id() {
  local url=$1
  # Node ID is after node-id= parameter
  echo "$url" | grep -o 'node-id=[^&]*' | cut -d '=' -f2 | sed 's/-/%3A/g'
}

# Export for use in other scripts
export -f get_figma_token
export -f fetch_figma_file
export -f fetch_figma_node
export -f fetch_figma_images
export -f download_figma_image
export -f extract_file_key
export -f extract_node_id
