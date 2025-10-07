---
description: Generate HTML/CSS/JS with Playwright validation
---

Execute the implement.sh script to start HTML implementation workflow.

**Usage:**

```bash
# Auto-detect from current branch
/implement

# Switch to specific task
/implement issue-5-product-card
/implement product-card
/implement 5
```

**What this does:**

## Without Argument (Auto-detect)
1. Check if on issue branch
2. If not, show available tasks and exit
3. Load task information from current branch
4. Proceed to implementation

## With Argument (Branch Switch)
1. Search for task by:
   - Exact branch name: `issue-5-product-card`
   - Partial slug: `product-card`
   - Issue number: `5` or `#5`
   - Title keyword: `product`
2. Display found task and ask for confirmation
3. Check for uncommitted changes:
   - If changes exist, prompt: (s)tash, (c)ommit, or (n)cancel
   - Handle accordingly
4. Switch to target branch
5. Proceed to implementation

## Implementation Process

### 1. Check Phase 1 (Analysis)
- Read task file
- Count completed vs total items in Phase 1
- If incomplete: **Warn** and ask to proceed
- User can skip warning (not blocked)

### 2. Update Task Status
- Set status to `in_progress` (if was `pending`)
- Set phase to `html`
- Log to task file

### 3. Set Up Environment
- Create directories: `html/`, `html/css/`, `html/js/`, `tests/`
- Set up Playwright config if not exists
- Install Playwright if needed
- Initialize package.json if needed

### 4. Ready for Claude Implementation
Script provides structure. Claude will:

1. **Use Figma MCP** to get component data:
   ```javascript
   mcp__figma-dev-mode-mcp-server__get_metadata(figmaLink)
   mcp__figma-dev-mode-mcp-server__get_code(figmaLink)
   mcp__figma-dev-mode-mcp-server__get_screenshot(figmaLink)
   ```

   **⚠️ IMPORTANT**: If `get_metadata` or `get_code` response exceeds token limits (25000 tokens), this indicates the component was not properly broken down during `/breakdown`. The component is too large and should be split into smaller sub-components. Return to `/breakdown` and create separate tasks for each major section.

2. **Generate HTML** at `html/{slug}.html`:
   - Semantic HTML5 elements
   - BEM class naming
   - Accessibility (ARIA, alt text)
   - No inline styles
   - Link to CSS: `<link rel="stylesheet" href="css/{slug}.css">`
   - Link to JS: `<script src="js/{slug}.js"></script>`

3. **Generate CSS** at `html/css/{slug}.css`:
   - BEM naming: `.block__element--modifier`
   - CSS variables for colors/spacing
   - Mobile-first responsive
   - Breakpoints: 768px, 1024px

4. **Generate JS** (if needed) at `html/js/{slug}.js`:
   - Vanilla JavaScript
   - Progressive enhancement
   - Event delegation
   - No globals

5. **Create Playwright Test** at `tests/{slug}.spec.js`:
   - Desktop (1920×1080) visual test
   - Tablet (768×1024) visual test
   - Mobile (375×667) visual test
   - Accessibility checks
   - Interactive features tests

6. **Run Tests**:
   ```bash
   npx playwright test tests/{slug}.spec.js
   ```

7. **Visual Validation**:
   - Compare screenshots with Figma
   - Check match percentage ≥98%
   - Layout accuracy ±5px

8. **Update Task File**:
   - Mark Phase 2 items complete
   - Add test results table
   - Log timestamps

9. **Commit Progress**:
   ```bash
   git add html/ tests/ .claude/tasks/
   git commit -m "Task #{N}: HTML implementation complete"
   ```

## Success Criteria

Phase 2 complete when:
- ✅ All HTML/CSS/JS files created
- ✅ Playwright tests written
- ✅ All tests passing
- ✅ Visual match ≥98% on all viewports
- ✅ Accessibility checks pass
- ✅ Task file updated

## Next Steps

After Phase 2 complete:
- Run `/to-liquid` to convert HTML to Shopify Liquid
- Or continue refining HTML if tests not passing

## Notes

- Script sets up environment only
- Claude performs actual implementation using MCP and code generation
- Tests run automatically
- User prompted if Phase 1 incomplete (not blocked)
