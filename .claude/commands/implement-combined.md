---
description: Auto-combine multiple sections into a single HTML file with smart detection
---

Execute the implement-combined.sh script to automatically create a single HTML file combining multiple sections.

**What this does:**

## Overview
Automatically detects the next component to implement and combines all its sections into a single HTML file. No user input required unless you want to specify a specific component.

## Auto-Detection Flow

### Without Arguments (Recommended)
```bash
/implement-combined
```

**Auto-detection logic:**
1. Scans all tasks in `.claude/tasks/index.json`
2. Finds first **pending** or **in_progress** parent component
3. Groups all sections by parent component
4. Skips completed components
5. Automatically starts implementation

**Example:**
```
Auto-detecting next component to implement...
✓ Selected: pc-top

Found 7 sections to combine
  Processing section 1... Node: 111:785 - ヘッダーE
  Processing section 2... Node: 111:850 - Frame 1689
  ...
```

### With Argument (Manual Selection)
```bash
/implement-combined pc-top
```

Processes the specified parent component directly.

## Process

### 1. Find Related Sections
- Reads all task JSON files from `.claude/tasks/`
- Filters by parent component or slug pattern
- Sorts by section number (preserves top-to-bottom order)
- Handles auto-split tasks automatically

### 2. Analyze Each Section
For each section:
- Extracts Figma node ID from task JSON
- Gets frame width from `logs/figma-full-file.json`
- **Auto-detects container** (width < 1400px = needs container)
- Updates task status to `in_progress`

### 3. Generate Combined Files

Creates scaffolding with placeholders for each section:

**HTML** (`html/pc-top.html`):
```html
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <title>pc-top</title>
  <link rel="stylesheet" href="css/pc-top.css">
</head>
<body>
  <main class="pc-top">

    <!-- Section 1: ヘッダーE -->
    <!-- Node ID: 111:785 -->
    <section class="pc-top__section" data-section="1" data-node-id="111:785">
      <div class="pc-top__container" style="max-width: 1200px;">
        <!-- TODO: Implement ヘッダーE -->
        <div class="section-placeholder">
          <p>Section 1: ヘッダーE</p>
          <p>Node ID: 111:785</p>
        </div>
      </div>
    </section>

    <!-- Section 2: Frame 1689 (full width) -->
    <section class="pc-top__section" data-section="2" data-node-id="111:850">
      <div class="section-placeholder" style="max-width: 1440px;">
        <p>Section 2: Frame 1689</p>
        <p>Node ID: 111:850</p>
      </div>
    </section>

    <!-- Additional sections... -->

  </main>
  <script src="js/pc-top.js"></script>
</body>
</html>
```

**CSS** (`html/css/pc-top.css`):
```css
/* Combined CSS for pc-top */

.pc-top {
  width: 100%;
  margin: 0;
  padding: 0;
}

/* =============================================
   Section 1: ヘッダーE
   Node ID: 111:785
   Parent: PC_TOP
   ============================================= */

.pc-top__section[data-section="1"] {
  width: 100%;
  margin: 0 auto;
  max-width: 1200px;
}

.pc-top__section[data-section="1"] .pc-top__container {
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 16px;
  box-sizing: border-box;
}

/* Placeholder styling (remove when implemented) */
.pc-top__section[data-section="1"] .section-placeholder {
  padding: 40px;
  background: #f0f0f0;
  border: 2px dashed #ccc;
  text-align: center;
  color: #666;
}
```

**JavaScript** (`html/js/pc-top.js`):
```javascript
/* Combined JavaScript for pc-top */
(function() {
  'use strict';

  // Section 1: ヘッダーE (Node: 111:785)
  function initSection1() {
    const section = document.querySelector('[data-section="1"]');
    if (!section) {
      console.warn('Section 1 not found');
      return;
    }

    // TODO: Add section-specific initialization
    console.log('Section 1 initialized:', section);
  }

  // Auto-initialize all sections on DOM ready
  document.addEventListener('DOMContentLoaded', function() {
    console.log('Initializing pc-top...');

    const sections = document.querySelectorAll('[data-section]');
    console.log('Found ' + sections.length + ' sections');

    sections.forEach(function(section) {
      const sectionNum = section.getAttribute('data-section');
      const initFn = window['initSection' + sectionNum];

      if (typeof initFn === 'function') {
        initFn();
      }
    });

    console.log('pc-top initialized');
  });

})();
```

**Playwright Test** (`tests/pc-top.spec.js`):
```javascript
const { test, expect } = require('@playwright/test');

test.describe('pc-top', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('file://' + process.cwd() + '/html/pc-top.html');
  });

  test('should load all sections', async ({ page }) => {
    const sections = await page.locator('[data-section]').count();
    expect(sections).toBe(7);
  });

  test('should have correct title', async ({ page }) => {
    await expect(page).toHaveTitle('pc-top');
  });

  test('should initialize JavaScript', async ({ page }) => {
    const logs = [];
    page.on('console', msg => logs.push(msg.text()));

    await page.waitForLoadState('networkidle');

    expect(logs.some(log => log.includes('pc-top initialized'))).toBe(true);
  });
});
```

## Container Detection

**Simple heuristic:**
- Width < 1400px → Adds container wrapper with padding
- Width ≥ 1400px → Full width section, no wrapper

**You can manually adjust** the container logic in the generated HTML/CSS.

## Usage Examples

### Auto Mode (Recommended)
```bash
# Run breakdown first
/breakdown

# Then auto-implement (no input needed)
/implement-combined

# It will:
# 1. Find first pending component
# 2. Create scaffolding for all sections
# 3. Update task status to in_progress
# 4. Show next steps
```

### Manual Mode
```bash
# Implement specific component
/implement-combined pc-top

# Or implement mobile version
/implement-combined sp-top
```

### Continuous Flow
```bash
# Implement all components one by one
while true; do
  /implement-combined || break
  # Implement sections...
  # Test...
  # Commit...
done
```

## After Generation

### 1. Implement Each Section

Use the node IDs in HTML comments to fetch component details via MCP:

```javascript
// For Section 1 (Node ID: 111:785)
mcp__figma-dev-mode-mcp-server__get_code({
  nodeId: "111:785",
  clientLanguages: "html,css,javascript",
  clientFrameworks: "unknown"
})
```

Replace the placeholder `<div class="section-placeholder">` with actual component HTML.

### 2. Add Styles

Replace placeholder CSS with actual component styles.

### 3. Add JavaScript (if needed)

Implement section-specific logic in the `initSectionN()` functions.

### 4. Test

```bash
# Run tests
npx playwright test tests/pc-top.spec.js

# View in browser
open html/pc-top.html
```

### 5. Remove Placeholders

Once implemented, remove:
- `.section-placeholder` divs
- Placeholder CSS
- TODO comments

### 6. Convert to Liquid

```bash
/to-liquid pc-top
```

## Task Status Tracking

Each task JSON is automatically updated:

**Before:**
```json
{
  "status": "pending",
  "phase": "analysis"
}
```

**After `/implement-combined`:**
```json
{
  "status": "in_progress",
  "phase": "implementation",
  "updated": "2025-10-08T12:00:00Z"
}
```

## Benefits

✅ **Zero input**: Auto-detects next component to implement
✅ **Smart continuation**: Skips completed, finds pending
✅ **Single file**: All sections combined in one HTML
✅ **Order preserved**: Sections sorted by Y position
✅ **Node IDs included**: Easy MCP access via comments
✅ **Auto-container**: Smart width-based detection
✅ **Test ready**: Playwright tests auto-generated
✅ **Status tracking**: Tasks updated to in_progress

## Example Output

```
⚡ Figma to Liquid - Auto Combined Implementation

Auto-detecting next component to implement...
✓ Selected: pc-top

Parent Component: pc-top

Found 7 sections to combine

Creating combined files...
  Processing section 1...
    ✓ Node: 111:785 - ヘッダーE
  Processing section 2...
    ✓ Node: 111:850 - Frame 1689
  Processing section 3...
    ✓ Node: 111:852 - sec02_bnr_pc
  ...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Combined Implementation Scaffolding Complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Files Created:
  📄 html/pc-top.html
  🎨 html/css/pc-top.css
  ⚙️  html/js/pc-top.js
  🧪 tests/pc-top.spec.js

Sections Included: 7

Next Steps:
  1. Implement each section using Figma MCP:
     Use node IDs in HTML comments to get component details

  2. Replace placeholders with actual component HTML/CSS

  3. Test the combined page:
     npx playwright test tests/pc-top.spec.js

  4. Add visual regression tests

  5. When complete, convert to Liquid:
     /to-liquid pc-top

✨ Ready for implementation!

To continue with next component, run:
  /implement-combined
```

## Workflow Integration

Perfect for batch processing:

```bash
# 1. Breakdown all components
/breakdown
# Select: all

# 2. Implement first component
/implement-combined
# Auto-detects: pc-top

# 3. Fill in sections, test, commit

# 4. Implement next component
/implement-combined
# Auto-detects: sp-top

# Repeat until all components implemented!
```

No manual component selection needed - it just works! 🚀
