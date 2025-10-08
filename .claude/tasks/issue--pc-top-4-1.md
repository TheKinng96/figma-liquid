# Task #: Frame 1567_Frame 1497

**GitHub Issue**: #
**Branch**: `issue--pc-top-4-1`
**Figma Link**: https://www.figma.com/design/5NQAM48PSavkdGzGHtipcD/%E3%80%90%E5%AE%8C%E4%BA%86%E3%80%91%E5%90%89%E5%B7%9D%E5%95%86%E4%BA%8B%E6%A0%AA%E5%BC%8F%E4%BC%9A%E7%A4%BE--Copy-?node-id=111-48{FIGMA_LINK}p=f{FIGMA_LINK}t=k4T5zU6D7Nbj7TcW-0{FIGMA_LINK}node-id=111-171
**Complexity**: 5/10
**Created**: 2025-10-08T06:29:12Z

---

## Phase 1: Analysis ✓ Complete when all items checked

### Component Metadata (auto-filled from Figma MCP)
- [ ] Figma structure analyzed
- [ ] Element count: {COUNT} (recommended: ≤8)
- [ ] Nesting depth: {DEPTH} (recommended: ≤4)
- [ ] Complexity score: 5 (recommended: ≤7)

⚠️ **If complexity >7, consider splitting into smaller components**

### Design Specifications (auto-filled from Figma MCP)
- [ ] Layout type identified: {LAYOUT_TYPE}
- [ ] Colors extracted to CSS variables
- [ ] Fonts/sizes documented
- [ ] Spacing/dimensions documented
- [ ] Responsive breakpoints identified

### Assets
- [ ] All images listed with dimensions
- [ ] All icons identified
- [ ] Figma screenshot saved for visual comparison

💡 **Tip: Run `/breakdown` to auto-fill Phase 1 items**

---

## Phase 2: HTML Implementation ✓ Complete when all tests pass

### Development Checklist
- [ ] Semantic HTML structure created
- [ ] BEM CSS classes applied (`.pc-top-4-1__element--modifier`)
- [ ] All styles in `css/pc-top-4-1.css`
- [ ] JavaScript in `js/pc-top-4-1.js` (if interactive)
- [ ] No hard-coded colors (use CSS variables)
- [ ] No magic numbers (use spacing variables)

### Automated Tests (Playwright)
Test file: `tests/pc-top-4-1.spec.js`

- [ ] Component renders without errors
- [ ] Desktop viewport (1920x1080): Visual match __% (target: ≥98%)
- [ ] Tablet viewport (768x1024): Visual match __% (target: ≥98%)
- [ ] Mobile viewport (375x667): Visual match __% (target: ≥98%)
- [ ] Layout accuracy: ±__px (tolerance: ±5px)
- [ ] All images load correctly
- [ ] All interactive elements functional

### Accessibility Tests
- [ ] Semantic HTML (header/nav/main/section/article)
- [ ] ARIA labels where needed
- [ ] Keyboard navigation works
- [ ] Focus states visible
- [ ] Color contrast ratios pass WCAG AA

### Browser Tests
- [ ] Chrome/Edge: Pass
- [ ] Safari: Pass
- [ ] Firefox: Pass

⚠️ **Warning: Proceeding to Liquid conversion with failing tests may require rework**

💡 **Tip: Run all tests before converting to Liquid to avoid debugging Liquid syntax**

---

## Phase 3: Liquid Conversion ✓ Complete when Shopify preview matches HTML

### Conversion Checklist
- [ ] HTML copied to `theme/{sections|snippets}/pc-top-4-1.liquid`
- [ ] Static content → Liquid variables
- [ ] Hard-coded images → Shopify assets/CDN
- [ ] Inline styles → `{% stylesheet %}` block
- [ ] Inline scripts → `{% javascript %}` block
- [ ] Section schema added (if section)

### Shopify Integration
- [ ] Shopify objects identified: {LIST_OBJECTS}
- [ ] Theme settings connected: {LIST_SETTINGS}
- [ ] Liquid syntax validated (no errors)
- [ ] Preview on `shopify theme dev` works

### Final Validation
- [ ] Shopify preview matches HTML version
- [ ] All Liquid variables render correctly
- [ ] Section settings work (if applicable)
- [ ] No console errors
- [ ] Performance acceptable (Lighthouse score >80)

⚠️ **Warning: Creating PR with failing validation will require fixes in review**

💡 **Recommended: Test on actual Shopify store before PR**

---

## Implementation Log

_Timestamps are added automatically during development_

```
2025-10-08T06:29:12Z - Phase 1 started
2025-10-08T06:29:12Z - Figma analysis complete
2025-10-08T06:29:12Z - Phase 1 complete ✓

2025-10-08T06:29:12Z - Phase 2 started
2025-10-08T06:29:12Z - HTML structure created
2025-10-08T06:29:12Z - CSS implemented (BEM naming)
2025-10-08T06:29:12Z - JavaScript added (if needed)
2025-10-08T06:29:12Z - Playwright tests created
2025-10-08T06:29:12Z - Running visual validation...
2025-10-08T06:29:12Z - Test results: Desktop: _%, Tablet: _%, Mobile: _%
2025-10-08T06:29:12Z - Phase 2 complete ✓

2025-10-08T06:29:12Z - Phase 3 started
2025-10-08T06:29:12Z - HTML converted to Liquid
2025-10-08T06:29:12Z - Section schema added
2025-10-08T06:29:12Z - Shopify preview validated
2025-10-08T06:29:12Z - Phase 3 complete ✓

2025-10-08T06:29:12Z - **TASK COMPLETE - Ready for PR**
```

---

## Test Results

### Visual Comparison
| Viewport | Resolution  | Match % | Diff Pixels | Status |
|----------|-------------|---------|-------------|--------|
| Desktop  | 1920x1080   | __%     | ___px       | ___    |
| Tablet   | 768x1024    | __%     | ___px       | ___    |
| Mobile   | 375x667     | __%     | ___px       | ___    |

**Pass Criteria**: ≥98% match, <500px difference

### Playwright Test Output
```
pc-top-4-1.spec.js

Test Suite Results:
○ renders on desktop
○ renders on tablet
○ renders on mobile
○ visual regression desktop
○ visual regression tablet
○ visual regression mobile
○ interactive features work
○ accessibility checks pass

Total: _/_ tests passed
```

---

## Files Created

### Phase 2: HTML Implementation
- `html/pc-top-4-1.html`
- `css/pc-top-4-1.css`
- `js/pc-top-4-1.js` (if interactive)
- `tests/pc-top-4-1.spec.js`
- `tests/screenshots/pc-top-4-1-desktop.png`
- `tests/screenshots/pc-top-4-1-tablet.png`
- `tests/screenshots/pc-top-4-1-mobile.png`

### Phase 3: Liquid Conversion
- `theme/sections/pc-top-4-1.liquid` (if section) OR
- `theme/snippets/pc-top-4-1.liquid` (if snippet/component)

---

## Design Specifications

### Layout Details
- **Type**: {flexbox/grid/block}
- **Direction**: {row/column}
- **Alignment**: {flex-start/center/space-between}
- **Gap/Spacing**: {VALUES}

### Typography
```css
/* Fonts used in this component */
--font-primary: {FONT_FAMILY};
--font-weight-normal: {WEIGHT};
--font-weight-bold: {WEIGHT};
--font-size-base: {SIZE};
--line-height: {VALUE};
```

### Colors
```css
/* Colors extracted from Figma */
--{slug}-bg: {HEX};
--{slug}-text: {HEX};
--{slug}-accent: {HEX};
--{slug}-border: {HEX};
```

### Spacing
```css
/* Spacing values */
--{slug}-padding: {VALUE};
--{slug}-margin: {VALUE};
--{slug}-gap: {VALUE};
```

### Responsive Behavior
- **Mobile (<768px)**: {DESCRIPTION}
- **Tablet (768-1024px)**: {DESCRIPTION}
- **Desktop (>1024px)**: {DESCRIPTION}

---

## Shopify Objects & Variables

### Data Source
- [ ] Static content
- [ ] Product object: `{{ product }}`
- [ ] Collection object: `{{ collection }}`
- [ ] Shop object: `{{ shop }}`
- [ ] Custom metafields
- [ ] Theme settings

### Liquid Variables Used
```liquid
{LIST_ALL_VARIABLES_HERE}

Example:
{{ product.title }}
{{ product.featured_image | img_url: 'large' }}
{{ section.settings.heading }}
```

### Section Schema (if applicable)
```json
{
  "name": "Frame 1567_Frame 1497",
  "settings": [
    {
      "type": "text",
      "id": "heading",
      "label": "Heading",
      "default": "Default Heading"
    }
  ],
  "presets": [
    {
      "name": "Frame 1567_Frame 1497"
    }
  ]
}
```

---

## Completion Criteria

**Task is complete when ALL of the following are true:**

- ✅ All Phase 1 analysis items checked
- ✅ All Phase 2 implementation items checked
- ✅ All Phase 3 Liquid conversion items checked
- ✅ Playwright test suite: 100% passing
- ✅ Visual validation: All viewports ≥98% match
- ✅ Shopify preview: Matches HTML exactly
- ✅ Zero console errors in browser and Shopify dev
- ✅ Task file committed to branch
- ✅ GitHub issue updated with summary

**Only when all criteria met: Create PR and close task**

---

## Notes & Decisions

### Architectural Decisions
_Document any deviations from Figma or important implementation choices_

### Blockers & Issues
_Track any problems encountered during development_

### Recommendations
_Suggestions for future improvements or optimizations_

## Figma Node ID
`111:171`

