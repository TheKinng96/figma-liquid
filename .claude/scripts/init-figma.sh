#!/bin/bash

# Figma to Shopify Liquid - Initialize Figma Project
# This command validates Figma URL and checks for required access tokens

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🎨 Figma to Shopify Liquid - Project Initialization${NC}\n"

# Prompt for Figma URL
echo -e "${YELLOW}Please paste the Figma URL:${NC}"
read -r FIGMA_URL

# Validate URL format
if [[ ! $FIGMA_URL =~ ^https://www\.figma\.com/(design|file)/ ]]; then
  echo -e "${RED}❌ Invalid Figma URL. Must be a figma.com/design or figma.com/file URL${NC}"
  exit 1
fi

echo -e "${GREEN}✓ Valid Figma URL format${NC}\n"

# Extract file key from URL
FILE_KEY=$(echo "$FIGMA_URL" | sed -E 's|https://www\.figma\.com/(design\|file)/([^/]+).*|\2|')
echo -e "File Key: ${GREEN}$FILE_KEY${NC}"

# Check for .env file
if [ ! -f .env ]; then
  echo -e "${RED}❌ .env file not found${NC}"
  echo -e "${YELLOW}Creating .env file...${NC}"
  touch .env
fi

# Check for FIGMA_ACCESS_TOKEN
if grep -q "FIGMA_ACCESS_TOKEN=" .env; then
  TOKEN=$(grep "FIGMA_ACCESS_TOKEN=" .env | cut -d '=' -f2)
  if [ -z "$TOKEN" ]; then
    echo -e "${RED}❌ FIGMA_ACCESS_TOKEN is empty in .env${NC}"
    echo -e "${YELLOW}Please add your Figma access token to .env:${NC}"
    echo -e "FIGMA_ACCESS_TOKEN=your_token_here"
    exit 1
  fi
  echo -e "${GREEN}✓ FIGMA_ACCESS_TOKEN found in .env${NC}\n"
else
  echo -e "${RED}❌ FIGMA_ACCESS_TOKEN not found in .env${NC}"
  echo -e "${YELLOW}Please add your Figma access token to .env:${NC}"
  echo -e "FIGMA_ACCESS_TOKEN=your_token_here"
  exit 1
fi

# Test Figma API access
echo -e "${YELLOW}Testing Figma API access...${NC}"
RESPONSE=$(curl -s -H "X-Figma-Token: $TOKEN" "https://api.figma.com/v1/files/$FILE_KEY" -w "\n%{http_code}")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
  echo -e "${GREEN}✓ Successfully connected to Figma API${NC}\n"

  # Extract and display file info
  FILE_NAME=$(echo "$BODY" | grep -o '"name":"[^"]*"' | head -1 | cut -d'"' -f4)
  echo -e "Project Name: ${GREEN}$FILE_NAME${NC}"

  # Save project config
  mkdir -p .claude/data
  cat > .claude/data/figma-project.json <<EOF
{
  "figmaUrl": "$FIGMA_URL",
  "fileKey": "$FILE_KEY",
  "fileName": "$FILE_NAME",
  "initialized": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

  echo -e "\n${GREEN}✓ Project configuration saved to .claude/data/figma-project.json${NC}"
  echo -e "\n${GREEN}🎉 Initialization complete! Next steps:${NC}"
  echo -e "  1. Run ${YELLOW}/plan${NC} to analyze and separate components"
  echo -e "  2. Run ${YELLOW}/tasks${NC} to create GitHub issues"
  echo -e "  3. Run ${YELLOW}/implement${NC} to start development"

elif [ "$HTTP_CODE" = "403" ]; then
  echo -e "${RED}❌ Access denied. Please check:${NC}"
  echo -e "  1. Your FIGMA_ACCESS_TOKEN is valid"
  echo -e "  2. You have access to this Figma file"
  exit 1
elif [ "$HTTP_CODE" = "404" ]; then
  echo -e "${RED}❌ Figma file not found. Please check the URL.${NC}"
  exit 1
else
  echo -e "${RED}❌ API request failed with code: $HTTP_CODE${NC}"
  exit 1
fi
