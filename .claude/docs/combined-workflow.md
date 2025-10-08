# Combined HTML Implementation Workflow

## Quick Reference

### Problem Solved
Instead of creating separate HTML files for each component section:
- ❌ Old: `pc-top-1.html`, `pc-top-2.html`, `pc-top-3.html`, etc.
- ✅ New: **One file** `pc-top.html` with all sections combined

### Key Features

1. **Top-to-Bottom Order**
   - Sections automatically sorted by Y position from Figma
   - Ensures visual order is preserved
   - First section = top of page

2. **Auto-Container Detection**
   - Detects if Figma component has explicit container
   - If no container: uses frame width directly
   - Automatically applies proper CSS structure

3. **Single Combined HTML**
   - All sections in one file
   - Organized CSS with section comments
   - Modular JavaScript initialization

## Workflow

### Step 1: Run Breakdown (Auto-splits large components)

```bash
/breakdown
```

This creates tasks for each section, sorted top-to-bottom.

**Example:** `PC_TOP` (786 nodes) → 7 sections:
- `issue-14-pc-top-1` (ヘッダーE - 56 nodes)
- `issue-15-pc-top-2` (Frame 1689 - 16 nodes)
- `issue-16-pc-top-3` (sec02_bnr_pc - 6 nodes)
- ... etc.

### Step 2: Generate Combined HTML Structure

```bash
/implement-combined pc-top
```

**Creates:**
- `html/pc-top.html` - Combined HTML with section placeholders
- `html/css/pc-top.css` - CSS with section comments
- `html/js/pc-top.js` - JS with section initializers

**Output:**
```html
<!DOCTYPE html>
<html lang="ja">
<body>
  <main class="pc-top">
    <!-- Section 1: ヘッダーE -->
    <section class="pc-top__section" data-section="1">
      <div class="pc-top__container" style="max-width: 1200px;">
        <div id="section-1-placeholder"></div>
      </div>
    </section>

    <!-- Section 2: Frame 1689 (no container detected) -->
    <section class="pc-top__section" data-section="2" style="max-width: 1440px;">
      <div id="section-2-placeholder"></div>
    </section>

    <!-- ... more sections ... -->
  </main>
</body>
</html>
```

### Step 3: Implement Each Section

For each section, replace placeholder with actual content:

```bash
# Switch to section branch
git checkout issue-14-pc-top-1

# Get node ID from task
NODE_ID=$(cat .claude/tasks/task1.json | jq -r '.nodeId')

# Use Figma MCP to get component data
# (Requires Figma desktop app open)
```

**In Claude:**
```javascript
// Get component details
mcp__figma-dev-mode-mcp-server__get_code(nodeId: "111:785")
mcp__figma-dev-mode-mcp-server__get_screenshot(nodeId: "111:785")

// Or use Figma JSON (if desktop app not available)
jq '.. | objects | select(.id == "111:785")' logs/figma-full-file.json
```

**Implement in combined file:**
```html
<!-- Replace section 1 placeholder -->
<section class="pc-top__section" data-section="1">
  <div class="pc-top__container">
    <header class="pc-top__header">
      <nav class="pc-top__nav">
        <!-- Actual header content -->
      </nav>
    </header>
  </div>
</section>
```

### Step 4: Add Section Styles

In `html/css/pc-top.css`:

```css
/* =============================================
   Section 1: ヘッダーE
   Node ID: 111:785
   ============================================= */

.pc-top__section[data-section="1"] {
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
}

.pc-top__header {
  background-color: var(--header-bg);
  padding: 20px 0;
}

.pc-top__nav {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
```

### Step 5: Add Section JavaScript

In `html/js/pc-top.js`:

```javascript
// Section 1: ヘッダーE
function initSection1() {
  const section = document.querySelector('[data-section="1"]');
  if (!section) return;

  // Header-specific functionality
  const nav = section.querySelector('.pc-top__nav');
  const menuToggle = section.querySelector('.menu-toggle');

  menuToggle?.addEventListener('click', () => {
    nav.classList.toggle('active');
  });

  console.log('Header initialized');
}
```

### Step 6: Test Combined Page

```bash
# Create test file for combined page
npx playwright test tests/pc-top.spec.js
```

**Test file structure:**
```javascript
test('All sections render', async ({ page }) => {
  await page.goto(`file://${HTML_PATH}`);

  // Check all sections exist
  const sections = await page.locator('.pc-top__section').count();
  expect(sections).toBe(7);
});

test('Section 1 - Header', async ({ page }) => {
  const section1 = page.locator('[data-section="1"]');
  await expect(section1).toBeVisible();
  // Section-specific tests
});

test('Visual regression - Full page', async ({ page }) => {
  await page.setViewportSize({ width: 1920, height: 1080 });
  const screenshot = await page.screenshot({ fullPage: true });
  expect(screenshot).toMatchSnapshot('pc-top-full.png');
});
```

## Container Detection Logic

### With Container (Auto-layout or explicit wrapper)

**Figma structure:**
```
PC_TOP (frame)
└── Container (auto-layout frame)
    └── Content
```

**Generated HTML:**
```html
<section class="pc-top__section" data-section="1">
  <div class="pc-top__container" style="max-width: 1200px;">
    <!-- Content here -->
  </div>
</section>
```

**CSS:**
```css
.pc-top__container {
  width: 100%;
  margin: 0 auto;
  padding: 0 16px;  /* Standard padding */
  box-sizing: border-box;
}
```

### Without Container (Direct placement)

**Figma structure:**
```
PC_TOP (frame)
└── Content (placed directly, full width)
```

**Generated HTML:**
```html
<section class="pc-top__section" data-section="2" style="max-width: 1440px;">
  <!-- Content spans full width -->
</section>
```

**CSS:**
```css
.pc-top__section[data-section="2"] {
  width: 100%;
  max-width: 1440px;  /* Uses frame width */
  margin: 0 auto;
}
```

## Advanced Usage

### Custom Container Width

Override generated max-width:

```css
/* Force specific section to full width */
.pc-top__section[data-section="3"] {
  max-width: none !important;
}

/* Or set custom breakpoint */
.pc-top__section[data-section="4"] {
  max-width: 1920px;
}
```

### Section-Specific Breakpoints

```css
/* Section 1: Mobile-first responsive */
.pc-top__section[data-section="1"] {
  max-width: 100%;
}

@media (min-width: 768px) {
  .pc-top__section[data-section="1"] {
    max-width: 720px;
  }
}

@media (min-width: 1024px) {
  .pc-top__section[data-section="1"] {
    max-width: 1200px;
  }
}
```

### Lazy-Load Sections

```javascript
// Only initialize visible sections
const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      const section = entry.target;
      const sectionNum = section.dataset.section;
      const initFn = window['initSection' + sectionNum];
      if (initFn) {
        initFn();
        observer.unobserve(section);
      }
    }
  });
});

document.querySelectorAll('[data-section]').forEach(section => {
  observer.observe(section);
});
```

## Benefits

✅ **Single source of truth** - One HTML file for entire page
✅ **Preserved order** - Top-to-bottom from Figma
✅ **Auto-detection** - Handles container/no-container cases
✅ **Modular** - Each section clearly separated
✅ **Testable** - Test individual sections or full page
✅ **Maintainable** - Easy to update specific sections
✅ **Shopify-ready** - Simple conversion to Liquid

## Migration from Separate Files

If you already created separate HTML files:

```bash
# Combine existing files
cat html/pc-top-1.html html/pc-top-2.html > html/pc-top-combined.html

# Extract just the body content from each
for file in html/pc-top-*.html; do
  # Extract content between <body> and </body>
  sed -n '/<body>/,/<\/body>/p' "$file" | sed '1d;$d'
done > sections.html

# Wrap in combined structure
cat > html/pc-top.html << EOF
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PC TOP</title>
  <link rel="stylesheet" href="css/pc-top.css">
</head>
<body>
  <main class="pc-top">
$(cat sections.html)
  </main>
  <script src="js/pc-top.js"></script>
</body>
</html>
EOF
```

## Troubleshooting

**Q: Container not detected correctly?**
```bash
# Check component metadata
bash .claude/scripts/figma-utils.sh
source .claude/scripts/figma-utils.sh
get_container_spec "111:785" | jq

# Manually override
# Edit generated HTML to add/remove container div
```

**Q: Sections out of order?**
```bash
# Sections are sorted by Y position automatically
# Check Figma coordinates:
jq '.. | objects | select(.id == "111:785") | .absoluteBoundingBox.y' logs/figma-full-file.json

# Re-run breakdown if needed:
/breakdown
```

**Q: Want separate files for testing?**
```bash
# Extract section from combined file
sed -n '/data-section="1"/,/data-section="2"/p' html/pc-top.html > html/pc-top-1.html

# Or keep both approaches:
# - Combined: For production/Shopify
# - Separate: For isolated testing
```
