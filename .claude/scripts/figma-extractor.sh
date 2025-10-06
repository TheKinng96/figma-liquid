#!/bin/bash

# Figma Asset & Measurement Extractor
# Downloads all assets and extracts pixel-perfect measurements

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Extract Figma file key and node ID from URL
extract_figma_info() {
  local url=$1

  # Extract file key
  FILE_KEY=$(echo "$url" | grep -oP 'figma\.com/design/\K[^/]+')

  # Extract node ID
  NODE_ID=$(echo "$url" | grep -oP 'node-id=\K[^&]+' | sed 's/-/:/')

  if [ -z "$FILE_KEY" ] || [ -z "$NODE_ID" ]; then
    echo -e "${RED}❌ Could not extract Figma file key or node ID from URL${NC}"
    return 1
  fi

  echo "$FILE_KEY|$NODE_ID"
}

# Download Figma component data
download_figma_data() {
  local file_key=$1
  local node_id=$2
  local output_file=$3

  if [ ! -f .env ]; then
    echo -e "${RED}❌ .env file not found${NC}"
    return 1
  fi

  TOKEN=$(cat .env | grep FIGMA_ACCESS_TOKEN | cut -d'=' -f2)

  echo -e "${BLUE}Downloading Figma component data...${NC}"
  curl -s -H "X-Figma-Token: $TOKEN" \
    "https://api.figma.com/v1/files/${file_key}/nodes?ids=${node_id}" \
    > "$output_file"

  # Check if successful
  if ! jq empty "$output_file" 2>/dev/null; then
    echo -e "${RED}❌ Failed to download Figma data${NC}"
    cat "$output_file"
    return 1
  fi

  echo -e "${GREEN}✓ Component data downloaded${NC}"
}

# Extract asset nodes from component
extract_asset_nodes() {
  local data_file=$1
  local node_id=$2

  echo -e "\n${BLUE}Identifying assets to download...${NC}"

  # Find all image/vector nodes
  jq -r "
    .nodes.\"$node_id\".document |
    .. |
    objects |
    select(.type == \"RECTANGLE\" or .type == \"VECTOR\" or .type == \"BOOLEAN_OPERATION\" or .type == \"FRAME\") |
    select(.name | test(\"logo|icon|image|svg\"; \"i\")) |
    \"\(.id)|\(.name)|\(.type)\"
  " "$data_file" | sort -u
}

# Download individual asset
download_asset() {
  local file_key=$1
  local node_id=$2
  local asset_name=$3
  local format=$4  # png or svg
  local output_path=$5

  TOKEN=$(cat .env | grep FIGMA_ACCESS_TOKEN | cut -d'=' -f2)

  # Get export URL
  ASSET_URL=$(curl -s -H "X-Figma-Token: $TOKEN" \
    "https://api.figma.com/v1/images/${file_key}?ids=${node_id}&format=${format}&scale=2" \
    | jq -r ".images.\"${node_id}\"")

  if [ "$ASSET_URL" = "null" ] || [ -z "$ASSET_URL" ]; then
    echo -e "${YELLOW}  ⚠️  Could not export ${asset_name}${NC}"
    return 1
  fi

  # Download asset
  curl -s "$ASSET_URL" -o "$output_path"
  echo -e "${GREEN}  ✓ ${asset_name} → ${output_path}${NC}"
}

# Auto-detect and download all assets
auto_download_assets() {
  local data_file=$1
  local file_key=$2
  local node_id=$3
  local slug=$4

  mkdir -p assets/logo assets/icons assets/images figma-screenshots

  echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${YELLOW}Downloading Assets${NC}"
  echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

  # Download full component screenshot
  echo -e "${BLUE}1. Full component screenshot${NC}"
  download_asset "$file_key" "$node_id" "component-screenshot" "png" \
    "figma-screenshots/${slug}-original.png"

  # Find and download logo
  echo -e "\n${BLUE}2. Logo${NC}"
  LOGO_NODE=$(jq -r "
    .nodes.\"$node_id\".document |
    .. |
    objects |
    select(.name | test(\"logo\"; \"i\")) |
    .id
  " "$data_file" | head -1)

  if [ -n "$LOGO_NODE" ] && [ "$LOGO_NODE" != "null" ]; then
    download_asset "$file_key" "$LOGO_NODE" "logo" "png" "assets/logo/logo.png"
  fi

  # Find and download icons
  echo -e "\n${BLUE}3. Icons${NC}"
  ICON_NODES=$(jq -r "
    .nodes.\"$node_id\".document |
    .. |
    objects |
    select(.name | test(\"icon|favorite|cart|person|arrow|heart\"; \"i\")) |
    select(.type == \"BOOLEAN_OPERATION\" or .type == \"VECTOR\" or .type == \"FRAME\") |
    \"\(.id)|\(.name)\"
  " "$data_file" | sort -u)

  while IFS='|' read -r icon_id icon_name; do
    [ -z "$icon_id" ] && continue

    # Sanitize filename
    filename=$(echo "$icon_name" | tr '/' '-' | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
    download_asset "$file_key" "$icon_id" "$icon_name" "svg" \
      "assets/icons/${filename}.svg"
  done <<< "$ICON_NODES"
}

# Extract pixel-perfect measurements
extract_measurements() {
  local data_file=$1
  local node_id=$2
  local output_file=$3

  echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${YELLOW}Extracting Measurements${NC}"
  echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

  cat > "$output_file" << 'HEADER'
# Figma Design Measurements

## Container
HEADER

  # Get container dimensions
  jq -r "
    .nodes.\"$node_id\".document |
    \"- Width: \" + (.absoluteBoundingBox.width | tostring) + \"px\",
    \"- Height: \" + (.absoluteBoundingBox.height | tostring) + \"px\"
  " "$data_file" >> "$output_file"

  echo -e "" >> "$output_file"
  echo -e "## Layout Elements" >> "$output_file"
  echo -e "" >> "$output_file"

  # Get all direct children with measurements
  jq -r "
    .nodes.\"$node_id\".document.children[0].children[] |
    \"### \" + .name,
    \"- Size: \" + (.absoluteBoundingBox.width | tostring) + \"px × \" + (.absoluteBoundingBox.height | tostring) + \"px\",
    \"- Position: x=\" + (.absoluteBoundingBox.x | tostring) + \" y=\" + (.absoluteBoundingBox.y | tostring),
    \"\"
  " "$data_file" >> "$output_file"

  # Extract colors
  echo -e "## Colors" >> "$output_file"
  echo -e "" >> "$output_file"

  jq -r '
    .nodes."'"$node_id"'".document |
    .. |
    .fills? //empty |
    .[] |
    select(.type == "SOLID") |
    .color |
    "- rgb(" + ((.r * 255 | floor) | tostring) + ", " +
               ((.g * 255 | floor) | tostring) + ", " +
               ((.b * 255 | floor) | tostring) + ")"
  ' "$data_file" | sort -u >> "$output_file"

  echo -e "${GREEN}✓ Measurements saved to: $output_file${NC}"
}

# Main extraction function
extract_all() {
  local figma_url=$1
  local slug=$2

  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}Figma Asset & Measurement Extraction${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

  # Extract Figma info
  INFO=$(extract_figma_info "$figma_url")
  if [ $? -ne 0 ]; then
    return 1
  fi

  FILE_KEY=$(echo "$INFO" | cut -d'|' -f1)
  NODE_ID=$(echo "$INFO" | cut -d'|' -f2)

  echo -e "File Key: ${GREEN}$FILE_KEY${NC}"
  echo -e "Node ID: ${GREEN}$NODE_ID${NC}\n"

  # Download component data
  DATA_FILE="figma-data.json"
  download_figma_data "$FILE_KEY" "$NODE_ID" "$DATA_FILE"
  if [ $? -ne 0 ]; then
    return 1
  fi

  # Download assets
  auto_download_assets "$DATA_FILE" "$FILE_KEY" "$NODE_ID" "$slug"

  # Extract measurements
  MEASUREMENTS_FILE="FIGMA_MEASUREMENTS.md"
  extract_measurements "$DATA_FILE" "$NODE_ID" "$MEASUREMENTS_FILE"

  echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}Extraction Complete!${NC}"
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

  echo -e "Assets downloaded to: ${BLUE}assets/${NC}"
  echo -e "Screenshots saved to: ${BLUE}figma-screenshots/${NC}"
  echo -e "Measurements saved to: ${BLUE}$MEASUREMENTS_FILE${NC}"
  echo -e "Raw data saved to: ${BLUE}$DATA_FILE${NC}\n"
}

# Export functions
export -f extract_figma_info
export -f download_figma_data
export -f extract_asset_nodes
export -f download_asset
export -f auto_download_assets
export -f extract_measurements
export -f extract_all
