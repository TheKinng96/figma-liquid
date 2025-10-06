#!/bin/bash

# Playwright Helper Functions
# Utility functions for Playwright testing

# Create a component test
# Usage: create_component_test <component_name> <selector>
create_component_test() {
  local component_name=$1
  local selector=$2
  local test_file="tests/${component_name}.spec.js"

  cat > "$test_file" <<EOF
import { test, expect } from '@playwright/test';

test.describe('${component_name} Component', () => {
  test.beforeEach(async ({ page }) => {
    // Navigate to the page containing this component
    await page.goto('/');
  });

  test('should render correctly on desktop', async ({ page }) => {
    await page.setViewportSize({ width: 1920, height: 1080 });

    const component = page.locator('${selector}');
    await expect(component).toBeVisible();

    // Visual regression test
    await expect(component).toHaveScreenshot('${component_name}-desktop.png', {
      maxDiffPixels: 100
    });
  });

  test('should render correctly on tablet', async ({ page }) => {
    await page.setViewportSize({ width: 768, height: 1024 });

    const component = page.locator('${selector}');
    await expect(component).toBeVisible();

    // Visual regression test
    await expect(component).toHaveScreenshot('${component_name}-tablet.png', {
      maxDiffPixels: 100
    });
  });

  test('should render correctly on mobile', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 667 });

    const component = page.locator('${selector}');
    await expect(component).toBeVisible();

    // Visual regression test
    await expect(component).toHaveScreenshot('${component_name}-mobile.png', {
      maxDiffPixels: 100
    });
  });

  test('should be accessible', async ({ page }) => {
    const component = page.locator('${selector}');

    // Check for ARIA labels
    // Add specific accessibility tests here
  });
});
EOF

  echo "$test_file"
}

# Run specific component test
# Usage: run_component_test <component_name>
run_component_test() {
  local component_name=$1
  local test_file="tests/${component_name}.spec.js"

  if [ ! -f "$test_file" ]; then
    echo "Error: Test file $test_file not found" >&2
    return 1
  fi

  npx playwright test "$test_file"
}

# Run all tests
run_all_tests() {
  npx playwright test
}

# Update visual baselines
# Usage: update_test_snapshots <component_name>
update_test_snapshots() {
  local component_name=$1
  local test_file="tests/${component_name}.spec.js"

  npx playwright test "$test_file" --update-snapshots
}

# Check if Playwright is installed
check_playwright_installed() {
  if ! command -v npx &> /dev/null; then
    echo "Error: npx not found. Install Node.js first." >&2
    return 1
  fi

  if [ ! -f "playwright.config.js" ]; then
    echo "Warning: playwright.config.js not found" >&2
    return 1
  fi

  return 0
}

# Export for use in other scripts
export -f create_component_test
export -f run_component_test
export -f run_all_tests
export -f update_test_snapshots
export -f check_playwright_installed
