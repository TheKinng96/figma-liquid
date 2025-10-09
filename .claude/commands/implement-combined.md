---
description: Auto-combine multiple sections into a single HTML file with smart detection
---

**Automatically implement a complete combined HTML page by processing chunks sequentially.**

## Workflow

Process chunks **one at a time** in order:

**For each chunk:**
1. Download ALL assets for the chunk
2. Fetch code for ALL sections in the chunk
3. Append all code to the combined HTML/CSS/JS files
4. Mark chunk as complete
5. Move to next chunk (repeat steps 1-4)

## Your Task

### Step 1: Initialize Files (Once)

Create the initial HTML/CSS/JS file structure:

**HTML** (`html/index.html`):
```html
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{parent-slug}</title>
  <link rel="stylesheet" href="css/style.css">
</head>
<body>
  <main class="{parent-slug}">
```

**CSS** (`html/css/style.css`):
```css
/* Combined CSS for {parent-slug} */

.{parent-slug} {
  width: 100%;
  margin: 0;
  padding: 0;
}

```

**JS** (`html/js/script.js`):
```javascript
/* Combined JavaScript for {parent-slug} */
(function() {
  'use strict';

```

### Step 2: Process Each Chunk Sequentially

1. **Find the next pending chunk:**
   - Look for tasks with `status != "completed"`
   - Group by `parentComponent` (e.g., "pc_top_1", "pc_top_2")
   - Get the first pending chunk

2. **For the current chunk, process ALL sections:**

   **A. Download ALL assets for this chunk first:**

   For each section in the chunk:
   - Create assets folder: `html/assets/{parentComponent}_{sectionNumber}/`
     - Example: `PC_TOP_1`, `PC_TOP_2`, `ドロワー_1`, etc.
   - Use `mcp__figma-dev-mode-mcp-server__get_screenshot`
     - Parameters: `nodeId: "{nodeId}"`, `clientLanguages: "html,css,javascript"`, `clientFrameworks: "unknown"`
   - Save image to: `html/assets/{parentComponent}_{sectionNumber}/screenshot.png`
   - Download ALL asset files from MCP response and save to the same folder
     - Extract asset URLs from the code (e.g., `http://localhost:3845/assets/xxx.svg`)
     - Download each asset using `curl -s {url} -o html/assets/{parentComponent}_{sectionNumber}/{filename}`
     - Update HTML to reference local paths: `assets/{parentComponent}_{sectionNumber}/{filename}`

   Report progress:
   ```
   Chunk: PC_TOP (5 sections)

   Downloading assets...
     Section 1/5: ヘッダーE (111:785) → html/assets/PC_TOP_1/ ✓
     Section 2/5: Group 4 (4:426) → html/assets/PC_TOP_2/ ✓
     ...
   ```

   **B. Fetch code for ALL sections in this chunk:**

   For each section in the chunk (in order):
   - Use `mcp__figma-dev-mode-mcp-server__get_code`
     - Parameters: `nodeId: "{nodeId}"`, `clientLanguages: "html,css,javascript"`, `clientFrameworks: "unknown"`
   - Extract HTML, CSS, and JavaScript from response

   Report progress:
   ```
   Fetching code from Figma...
     Section 1/5: ヘッダーE (111:785) ✓
     Section 2/5: Group 4 (4:426) ✓
     ...
   ```

   **C. Append ALL code to combined files:**

   For each section, append to **HTML file**:
   ```html
     <!-- Section {N}: {title} -->
     <!-- Node ID: {nodeId} | Chunk: {chunk-name} -->
     <section class="{parent-slug}__section" data-section="{N}" data-node-id="{nodeId}" data-chunk="{chunk-name}">
       {actual HTML from Figma MCP}
     </section>

   ```

   Append to **CSS file**:
   ```css
   /* =============================================
      Section {N}: {title}
      Node ID: {nodeId} | Chunk: {chunk-name}
      ============================================= */

   {actual CSS from Figma MCP}

   ```

   Append to **JS file**:
   ```javascript
   // Section {N}: {title} (Node: {nodeId} | Chunk: {chunk-name})
   {actual JS from Figma MCP}

   ```

   **D. Update task statuses for this chunk:**
   - Mark all tasks in this chunk as `status: "completed"` and `phase: "implementation"`
   - Update `updated` timestamp

   **E. Report chunk completion:**
   ```
   ✓ Chunk pc_top_1 complete (5 sections appended to index.html)
   ```

3. **Move to next chunk and repeat** steps 2A-2E

### Step 3: Finalize Files (After All Chunks)

After all chunks are processed, close the files:

**HTML** - append:
```html
  </main>
  <script src="js/script.js"></script>
</body>
</html>
```

**JS** - append:
```javascript

  // Auto-initialize all sections on DOM ready
  document.addEventListener('DOMContentLoaded', function() {
    console.log('Initializing {parent-slug}...');
    // Add any global initialization here
  });

})();
```

**Create Playwright test** (`tests/{parent-slug}.spec.js`):
```javascript
const { test, expect } = require('@playwright/test');

test.describe('{parent-slug}', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('file://' + process.cwd() + '/html/index.html');
  });

  test('should load all sections', async ({ page }) => {
    const sections = await page.locator('[data-section]').count();
    expect(sections).toBe({total_sections});
  });

  test('should have correct title', async ({ page }) => {
    await expect(page).toHaveTitle('{parent-slug}');
  });

  test('should initialize JavaScript', async ({ page }) => {
    const logs = [];
    page.on('console', msg => logs.push(msg.text()));
    await page.waitForLoadState('networkidle');
    expect(logs.some(log => log.includes('{parent-slug}'))).toBe(true);
  });
});
```

### Step 4: Report Final Completion

Show summary:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Combined Implementation Complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Chunks Processed: 3 (pc_top_1, pc_top_2, pc_top_3)
Total Sections: 15

Files Created:
✓ HTML: html/index.html
✓ CSS: html/css/style.css
✓ JS: html/js/script.js
✓ Tests: tests/{parent-slug}.spec.js

Next Steps:
  1. Test: npx playwright test tests/{parent-slug}.spec.js
  2. Review and refine styling if needed
  3. Convert to Liquid: /to-liquid
```

## Important Notes

- **Process ONE CHUNK at a time** - complete all assets + code for chunk before moving to next
- **NO placeholders** - append actual Figma code directly for each chunk
- **Append mode** - each chunk appends to the same index.html file
- Use node IDs from task JSON files to call MCP tools
- Preserve section order based on `sectionNumber`
- Wrap MCP-generated HTML in `<section>` tags with data attributes
- Handle errors gracefully - if MCP fails for a section, note it and continue
- Create assets folder for each section before downloading
- Mark entire chunk as complete only after all sections are processed

## Success Criteria

✅ Process chunks sequentially (chunk 1 → chunk 2 → chunk 3...)
✅ For each chunk: download all assets, then fetch all code, then append
✅ Move to next chunk only when current chunk is 100% complete
✅ All sections implemented with actual Figma code
✅ Combined HTML/CSS/JS files created in append mode
✅ Playwright test suite generated
✅ All task statuses updated to completed
✅ User can test the page with `npx playwright test`

## Example Flow

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Processing: PC_TOP
Found 3 chunks to process
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 Chunk 1/3: PC_TOP (5 sections)

Downloading assets...
  Section 1/5: ヘッダーE (111:785) → html/assets/PC_TOP_1/ ✓
  Section 2/5: Group 4 (4:426) → html/assets/PC_TOP_2/ ✓
  Section 3/5: Frame 1689 (111:148) → html/assets/PC_TOP_3/ ✓
  Section 4/5: Frame 574 (4:69) → html/assets/PC_TOP_4/ ✓
  Section 5/5: sec02_bnr_pc (111:164) → html/assets/PC_TOP_5/ ✓

Fetching code from Figma...
  Section 1/5: ヘッダーE (111:785) ✓
  Section 2/5: Group 4 (4:426) ✓
  Section 3/5: Frame 1689 (111:148) ✓
  Section 4/5: Frame 574 (4:69) ✓
  Section 5/5: sec02_bnr_pc (111:164) ✓

Appending to HTML/CSS/JS files...
✓ All 5 sections appended to index.html

✅ Chunk pc_top_1 complete!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 Chunk 2/3: pc_top_2 (4 sections)

Downloading assets...
  Section 1/4: dammy02 (4:429) → html/assets/dammy02/screenshot.png ✓
  Section 2/4: H2E (4:564) → html/assets/h2e/screenshot.png ✓
  ...

Fetching code from Figma...
  Section 1/4: dammy02 (4:429) ✓
  Section 2/4: H2E (4:564) ✓
  ...

Appending to HTML/CSS/JS files...
✓ All 4 sections appended to index.html

✅ Chunk pc_top_2 complete!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 Chunk 3/3: pc_top_3 (6 sections)

Downloading assets...
  ...

Fetching code from Figma...
  ...

Appending to HTML/CSS/JS files...
✓ All 6 sections appended to index.html

✅ Chunk pc_top_3 complete!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
All Chunks Complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Processed: 3 chunks, 15 total sections

Files Created:
✓ HTML: html/index.html
✓ CSS: html/css/style.css
✓ JS: html/js/script.js
✓ Tests: tests/PC_TOP.spec.js

Next Steps:
  1. Test: npx playwright test tests/PC_TOP.spec.js
  2. Review and refine styling
  3. Convert to Liquid: /to-liquid
```
