Execute the implement-combined.sh script to create a single HTML file combining multiple sections.

**What this does:**

## Overview
Instead of creating separate HTML files for each section (pc-top-1.html, pc-top-2.html, etc.), this command combines all sections from a parent component into a single HTML file (pc-top.html).

## Process

### 1. Detect Parent Component
- Auto-detects from current branch (e.g., `issue-14-pc-top-1` → parent: `pc-top`)
- Or specify manually: `/implement-combined pc-top`

### 2. Find All Related Sections
- Searches for all task branches matching the parent pattern
- Example: `issue-X-pc-top-1`, `issue-Y-pc-top-2`, etc.
- Sorts sections by number (top to bottom order preserved)

### 3. Analyze Each Section
For each section:
- Extracts Figma node ID from task JSON
- Gets component metadata using Figma utilities
- **Detects if container is needed**:
  - ✅ **Has container**: Section has explicit wrapper/container frame
  - ❌ **No container**: Components placed directly on frame
  - If no container, uses frame width as max-width

### 4. Generate Combined Files

**HTML Structure** (`html/pc-top.html`):
```html
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>pc-top</title>
  <link rel="stylesheet" href="css/pc-top.css">
</head>
<body>
  <main class="pc-top">

    <!-- Section 1: pc-top-1 -->
    <section class="pc-top__section" data-section="1">
      <div class="pc-top__container" style="max-width: 1200px;">
        <!-- Section content -->
      </div>
    </section>

    <!-- Section 2: pc-top-2 (no container) -->
    <section class="pc-top__section" data-section="2" style="max-width: 1440px;">
      <!-- Section content (full width) -->
    </section>

    <!-- Additional sections... -->

  </main>
  <script src="js/pc-top.js"></script>
</body>
</html>
```

**CSS Structure** (`html/css/pc-top.css`):
```css
/* Combined CSS for pc-top */

/* =============================================
   Section 1: pc-top-1
   Node ID: 111:58
   ============================================= */

.pc-top__section[data-section="1"] {
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
}

.pc-top__container {
  width: 100%;
  margin: 0 auto;
  padding: 0 16px;
  box-sizing: border-box;
}

/* =============================================
   Section 2: pc-top-2
   Node ID: 111:148
   ============================================= */

.pc-top__section[data-section="2"] {
  width: 100%;
  max-width: 1440px;
  margin: 0 auto;
}

/* Add section-specific styles here */
```

**JavaScript Structure** (`html/js/pc-top.js`):
```javascript
/* Combined JavaScript for pc-top */
(function() {
  'use strict';

  // Section 1: pc-top-1
  function initSection1() {
    const section = document.querySelector('[data-section="1"]');
    if (!section) {
      console.warn('Section 1 not found');
      return;
    }
    // Section-specific initialization
    console.log('Section 1 initialized');
  }

  // Section 2: pc-top-2
  function initSection2() {
    const section = document.querySelector('[data-section="2"]');
    // ...
  }

  // Initialize all sections
  document.addEventListener('DOMContentLoaded', function() {
    const sections = document.querySelectorAll('[data-section]');
    sections.forEach((section, index) => {
      const sectionNum = index + 1;
      const initFn = window['initSection' + sectionNum];
      if (initFn) initFn();
    });
  });

})();
```

## Container Detection

**Automatic container detection** checks:
1. **Has layoutMode**: If Figma frame has auto-layout, container is detected automatically
2. **Children at edges**: If children width ≥ frame width, assumes no container
3. **Frame width**: Uses frame's absoluteBoundingBox.width as max-width

**Results:**
- ✅ **With container**: Adds `<div class="parent__container">` wrapper with padding
- ❌ **Without container**: Section spans full frame width, no wrapper div

## Usage

```bash
# Auto-detect from current branch
/implement-combined

# Specify parent component
/implement-combined pc-top

# Process and implement
cd /path/to/project
bash .claude/scripts/implement-combined.sh pc-top
```

## After Generation

1. **Implement each section**:
   - Replace placeholders with actual component HTML
   - Use Figma MCP to get component details for each node ID
   - Add section-specific styles to CSS
   - Add section-specific JS if needed

2. **Test the combined page**:
   ```bash
   npx playwright test tests/pc-top.spec.js
   ```

3. **Commit**:
   ```bash
   git add html/pc-top.html html/css/pc-top.css html/js/pc-top.js
   git commit -m "Combined implementation: pc-top"
   ```

## Benefits

✅ **Single page**: All sections in one HTML file
✅ **Top-to-bottom order**: Sections sorted by Y position
✅ **Auto-container detection**: Handles containerless components
✅ **Organized CSS/JS**: Clear section separation with comments
✅ **Easy testing**: Test entire page or individual sections
✅ **Shopify-ready**: Easy conversion to Liquid template

## Example

For `PC_TOP` with 7 auto-split sections:
```
pc-top.html
├── Section 1: ヘッダーE (with container, max-width: 1200px)
├── Section 2: Frame 1689 (no container, max-width: 1440px)
├── Section 3: sec02_bnr_pc (with container, max-width: 1200px)
├── Section 4-1 to 4-8: Frame 1567 subsections
├── Section 5: Frame 1569
├── Section 6: Frame 1523
└── Section 7: Frame 1493
```

All in one file, ready for implementation!
