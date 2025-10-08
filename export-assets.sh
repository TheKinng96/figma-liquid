#!/bin/bash

# Export Figma assets script
# Load token from .env file
if [ -f .env ]; then
  TOKEN=$(cat .env | grep FIGMA_ACCESS_TOKEN | cut -d'=' -f2)
else
  echo "Error: .env file not found. Please create .env with FIGMA_ACCESS_TOKEN=your_token"
  exit 1
fi

FILE_KEY="5NQAM48PSavkdGzGHtipcD"

mkdir -p assets/logo assets/icons

echo "Exporting logo..."
LOGO_URL=$(curl -s -H "X-Figma-Token: ${TOKEN}" \
  "https://api.figma.com/v1/images/${FILE_KEY}?ids=111:810&format=png&scale=2" \
  | jq -r '.images["111:810"]')

echo "Logo URL: $LOGO_URL"

if [ "$LOGO_URL" != "null" ] && [ -n "$LOGO_URL" ]; then
  curl -s "$LOGO_URL" -o assets/logo/logo.png
  echo "✓ Logo saved to assets/logo/logo.png"
else
  echo "✗ Failed to get logo URL"
fi

echo ""
echo "Exporting person icon..."
PERSON_URL=$(curl -s -H "X-Figma-Token: ${TOKEN}" \
  "https://api.figma.com/v1/images/${FILE_KEY}?ids=111:792&format=svg" \
  | jq -r '.images["111:792"]')

echo "Person icon URL: $PERSON_URL"

if [ "$PERSON_URL" != "null" ] && [ -n "$PERSON_URL" ]; then
  curl -s "$PERSON_URL" -o assets/icons/person.svg
  echo "✓ Person icon saved to assets/icons/person.svg"
else
  echo "✗ Failed to get person icon URL"
fi

echo ""
echo "Exporting heart/favorite icon..."
HEART_URL=$(curl -s -H "X-Figma-Token: ${TOKEN}" \
  "https://api.figma.com/v1/images/${FILE_KEY}?ids=111:809&format=svg" \
  | jq -r '.images["111:809"]')

echo "Heart icon URL: $HEART_URL"

if [ "$HEART_URL" != "null" ] && [ -n "$HEART_URL" ]; then
  curl -s "$HEART_URL" -o assets/icons/heart.svg
  echo "✓ Heart icon saved to assets/icons/heart.svg"
else
  echo "✗ Failed to get heart icon URL"
fi

echo ""
echo "Exporting shopping cart icon..."
CART_URL=$(curl -s -H "X-Figma-Token: ${TOKEN}" \
  "https://api.figma.com/v1/images/${FILE_KEY}?ids=111:801&format=svg" \
  | jq -r '.images["111:801"]')

echo "Cart icon URL: $CART_URL"

if [ "$CART_URL" != "null" ] && [ -n "$CART_URL" ]; then
  curl -s "$CART_URL" -o assets/icons/cart.svg
  echo "✓ Cart icon saved to assets/icons/cart.svg"
else
  echo "✗ Failed to get cart icon URL"
fi

echo ""
echo "Exporting arrow icon..."
ARROW_URL=$(curl -s -H "X-Figma-Token: ${TOKEN}" \
  "https://api.figma.com/v1/images/${FILE_KEY}?ids=111:796&format=svg" \
  | jq -r '.images["111:796"]')

echo "Arrow icon URL: $ARROW_URL"

if [ "$ARROW_URL" != "null" ] && [ -n "$ARROW_URL" ]; then
  curl -s "$ARROW_URL" -o assets/icons/arrow.svg
  echo "✓ Arrow icon saved to assets/icons/arrow.svg"
else
  echo "✗ Failed to get arrow icon URL"
fi

echo ""
echo "All assets exported!"
ls -lh assets/logo/ assets/icons/
