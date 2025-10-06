#!/bin/bash

# Liquid Validation Helper Functions
# Validate Shopify Liquid syntax and structure

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if Liquid file has valid syntax
validate_liquid_syntax() {
  local file=$1

  if [ ! -f "$file" ]; then
    echo -e "${RED}❌ File not found: $file${NC}" >&2
    return 1
  fi

  # Basic syntax checks
  local errors=0

  # Check for unclosed tags
  local liquid_tags=$(grep -o '{%[^%]*%}' "$file" | grep -oP '(?<={%\s)(if|for|case|capture|form|stylesheet|javascript|schema)' | sort)
  local end_tags=$(grep -o '{%[^%]*%}' "$file" | grep -oP '(?<={%\s)end(if|for|case|capture|form|stylesheet|javascript|schema)' | sed 's/end//' | sort)

  if [ "$liquid_tags" != "$end_tags" ]; then
    echo -e "${RED}✗ Unclosed Liquid tags detected${NC}"
    errors=$((errors + 1))
  fi

  # Check for common syntax errors
  if grep -q '{{[^}]*{' "$file"; then
    echo -e "${RED}✗ Malformed object tag detected${NC}"
    errors=$((errors + 1))
  fi

  if grep -q '{%[^%]*{' "$file"; then
    echo -e "${RED}✗ Malformed tag detected${NC}"
    errors=$((errors + 1))
  fi

  # Check for required Shopify objects
  if grep -q '{{ product\.' "$file" && ! grep -q 'product' <<< "$file"; then
    echo -e "${YELLOW}⚠️  Uses product object - ensure it's passed or available${NC}"
  fi

  if [ $errors -eq 0 ]; then
    echo -e "${GREEN}✓ Liquid syntax valid${NC}"
    return 0
  else
    echo -e "${RED}✗ Found $errors syntax errors${NC}"
    return 1
  fi
}

# Validate section schema JSON
validate_section_schema() {
  local file=$1

  # Extract schema block
  local schema=$(sed -n '/{% schema %}/,/{% endschema %}/p' "$file" | sed '1d;$d')

  if [ -z "$schema" ]; then
    echo -e "${YELLOW}⚠️  No schema found (okay for snippets)${NC}"
    return 0
  fi

  # Validate JSON
  if echo "$schema" | jq . >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Schema JSON is valid${NC}"

    # Check for required fields
    if echo "$schema" | jq -e '.name' >/dev/null 2>&1; then
      echo -e "${GREEN}✓ Schema has 'name' field${NC}"
    else
      echo -e "${RED}✗ Schema missing 'name' field${NC}"
      return 1
    fi

    # Check if has presets
    if echo "$schema" | jq -e '.presets' >/dev/null 2>&1; then
      echo -e "${GREEN}✓ Schema has presets${NC}"
    else
      echo -e "${YELLOW}⚠️  Schema has no presets${NC}"
    fi

    return 0
  else
    echo -e "${RED}✗ Schema JSON is invalid${NC}"
    return 1
  fi
}

# Check for BEM naming in CSS
validate_bem_naming() {
  local file=$1

  # Extract stylesheet block
  local styles=$(sed -n '/{% stylesheet %}/,/{% endstylesheet %}/p' "$file")

  if [ -z "$styles" ]; then
    echo -e "${YELLOW}⚠️  No stylesheet block found${NC}"
    return 0
  fi

  # Check for BEM patterns (block__element--modifier)
  if echo "$styles" | grep -qP '\.[\w-]+__[\w-]+'; then
    echo -e "${GREEN}✓ BEM naming detected (elements)${NC}"
  fi

  if echo "$styles" | grep -qP '\.[\w-]+--[\w-]+'; then
    echo -e "${GREEN}✓ BEM naming detected (modifiers)${NC}"
  fi

  # Warn about non-BEM classes
  local non_bem=$(echo "$styles" | grep -oP '\.[a-z][a-z0-9-]*(?=[^_])' | grep -v '__' | grep -v '--' | head -5)
  if [ -n "$non_bem" ]; then
    echo -e "${YELLOW}⚠️  Found non-BEM classes (may be intentional)${NC}"
  fi

  return 0
}

# Check for required Shopify objects usage
check_shopify_objects() {
  local file=$1

  echo -e "\nShopify Objects Used:"

  # Check for common objects
  if grep -q '{{ product\.' "$file"; then
    echo -e "  ${GREEN}✓${NC} product"
  fi

  if grep -q '{{ collection\.' "$file"; then
    echo -e "  ${GREEN}✓${NC} collection"
  fi

  if grep -q '{{ cart\.' "$file"; then
    echo -e "  ${GREEN}✓${NC} cart"
  fi

  if grep -q '{{ customer\.' "$file"; then
    echo -e "  ${GREEN}✓${NC} customer"
  fi

  if grep -q '{{ shop\.' "$file"; then
    echo -e "  ${GREEN}✓${NC} shop"
  fi

  if grep -q 'section.settings' "$file"; then
    echo -e "  ${GREEN}✓${NC} section.settings"
  fi
}

# Validate filters usage
check_liquid_filters() {
  local file=$1

  # Check for money filter on prices
  if grep -q 'price' "$file" && ! grep -q '| money' "$file"; then
    echo -e "${YELLOW}⚠️  Found 'price' without | money filter${NC}"
  fi

  # Check for img_url filter on images
  if grep -q '\.image' "$file" && ! grep -q '| img_url' "$file"; then
    echo -e "${YELLOW}⚠️  Found image without | img_url filter${NC}"
  fi

  # Check for escape filter on user input
  if grep -q '\.title\|\.description' "$file" && ! grep -q '| escape' "$file"; then
    echo -e "${YELLOW}⚠️  Consider using | escape filter for user content${NC}"
  fi
}

# Run full Liquid validation
validate_liquid_file() {
  local file=$1

  echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${YELLOW}Validating Liquid File: $file${NC}"
  echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

  local all_passed=true

  # Syntax validation
  if ! validate_liquid_syntax "$file"; then
    all_passed=false
  fi

  # Schema validation (if section)
  if [[ "$file" =~ theme/sections ]]; then
    if ! validate_section_schema "$file"; then
      all_passed=false
    fi
  fi

  # BEM naming
  validate_bem_naming "$file"

  # Shopify objects
  check_shopify_objects "$file"

  # Filters
  check_liquid_filters "$file"

  echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

  if [ "$all_passed" = true ]; then
    echo -e "${GREEN}✓ Liquid validation passed${NC}\n"
    return 0
  else
    echo -e "${RED}✗ Liquid validation failed${NC}\n"
    return 1
  fi
}

# Validate all Liquid files in theme
validate_all_liquid_files() {
  local errors=0

  echo -e "${YELLOW}Validating all Liquid files...${NC}\n"

  # Validate sections
  for file in theme/sections/*.liquid 2>/dev/null; do
    if [ -f "$file" ]; then
      if ! validate_liquid_file "$file"; then
        errors=$((errors + 1))
      fi
    fi
  done

  # Validate snippets
  for file in theme/snippets/*.liquid 2>/dev/null; do
    if [ -f "$file" ]; then
      if ! validate_liquid_file "$file"; then
        errors=$((errors + 1))
      fi
    fi
  done

  if [ $errors -eq 0 ]; then
    echo -e "${GREEN}✓ All Liquid files valid${NC}"
    return 0
  else
    echo -e "${RED}✗ Found errors in $errors files${NC}"
    return 1
  fi
}

# Check if component has proper structure
validate_component_structure() {
  local component=$1
  local html_file="html/${component}.html"
  local css_file="css/${component}.css"
  local liquid_section="theme/sections/${component}.liquid"
  local liquid_snippet="theme/snippets/${component}.liquid"

  echo -e "\nComponent Structure Check:"

  if [ -f "$html_file" ]; then
    echo -e "  ${GREEN}✓${NC} HTML file exists"
  else
    echo -e "  ${RED}✗${NC} HTML file missing"
  fi

  if [ -f "$css_file" ]; then
    echo -e "  ${GREEN}✓${NC} CSS file exists"
  else
    echo -e "  ${RED}✗${NC} CSS file missing"
  fi

  if [ -f "$liquid_section" ]; then
    echo -e "  ${GREEN}✓${NC} Liquid section exists"
  elif [ -f "$liquid_snippet" ]; then
    echo -e "  ${GREEN}✓${NC} Liquid snippet exists"
  else
    echo -e "  ${YELLOW}⚠️${NC} Liquid file not found"
  fi
}

# Export functions
export -f validate_liquid_syntax
export -f validate_section_schema
export -f validate_bem_naming
export -f check_shopify_objects
export -f check_liquid_filters
export -f validate_liquid_file
export -f validate_all_liquid_files
export -f validate_component_structure
