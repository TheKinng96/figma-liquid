# Visual Validation Criteria

## Purpose
Define pass/fail criteria for visual comparison between Figma designs and implemented components.

---

## Pass Criteria

### Overall Visual Match
- **Minimum Match**: ≥98% similarity
- **Acceptable Pixel Difference**: <500px total
- **Layout Accuracy**: ±5px tolerance for element positioning

### Color Accuracy
- **Match Type**: Exact hex color match
- **Tolerance**: None (must use exact Figma colors)
- **CSS Variables**: Required for maintainability

### Typography
- **Font Family**: Exact match (or closest web-safe alternative)
- **Font Size**: ±1px tolerance
- **Font Weight**: Exact match
- **Line Height**: ±0.1 tolerance
- **Letter Spacing**: ±0.1px tolerance

### Spacing
- **Padding/Margin**: ±5px tolerance
- **Gap (Flexbox/Grid)**: ±5px tolerance
- **Border Radius**: ±2px tolerance

### Images
- **All Images Load**: Required
- **Aspect Ratio**: Exact match
- **Object-fit**: Matches Figma (cover/contain)
- **Alt Text**: Present and descriptive

### Layout Structure
- **Display Type**: Matches Figma (flex/grid/block)
- **Alignment**: Exact match
- **Direction**: Exact match (row/column)
- **Wrapping**: Matches Figma behavior

---

## Viewport Testing Requirements

### Desktop (1920×1080)
- **Pass Criteria**: ≥98% match
- **Max Pixel Diff**: <500px
- **Layout**: Centered or full-width as designed
- **No Horizontal Scroll**: Required

### Tablet (768×1024)
- **Pass Criteria**: ≥98% match
- **Max Pixel Diff**: <500px
- **Layout Adaptation**: Matches Figma tablet view
- **Touch Targets**: ≥44×44px

### Mobile (375×667)
- **Pass Criteria**: ≥98% match
- **Max Pixel Diff**: <500px
- **Layout Adaptation**: Matches Figma mobile view
- **Touch Targets**: ≥44×44px
- **No Horizontal Scroll**: Required
- **Font Size**: ≥16px for body text (prevent zoom on iOS)

### Between Breakpoints
- **No Broken Layouts**: Required
- **Smooth Transitions**: No sudden jumps
- **All Content Visible**: Nothing cut off

---

## Accessibility Requirements

### Semantic HTML
- [ ] Proper HTML5 elements used (`<header>`, `<nav>`, `<main>`, `<section>`, `<article>`, `<footer>`)
- [ ] No generic divs for semantic content
- [ ] Landmarks defined (role attributes if needed)

### Heading Hierarchy
- [ ] Logical h1 → h2 → h3 progression
- [ ] No skipped levels
- [ ] One h1 per page

### ARIA Labels
- [ ] All interactive elements have accessible names
- [ ] Images have alt text (empty alt="" for decorative)
- [ ] Form inputs have associated labels
- [ ] Buttons describe action

### Color Contrast (WCAG AA)
- [ ] Normal text: ≥4.5:1 contrast ratio
- [ ] Large text (18pt+): ≥3:1 contrast ratio
- [ ] UI elements: ≥3:1 contrast ratio
- [ ] Focus indicators: ≥3:1 contrast ratio

### Keyboard Navigation
- [ ] All interactive elements reachable via Tab
- [ ] Logical tab order
- [ ] Focus states visible
- [ ] No keyboard traps
- [ ] Skip links for long nav

### Screen Reader Support
- [ ] Content makes sense when read linearly
- [ ] ARIA landmarks used appropriately
- [ ] Dynamic content announces changes
- [ ] Images have meaningful alt text

---

## Performance Criteria

### Lighthouse Scores (Minimum)
- **Performance**: ≥80
- **Accessibility**: ≥90
- **Best Practices**: ≥90
- **SEO**: ≥90

### Core Web Vitals
- **LCP (Largest Contentful Paint)**: <2.5s
- **FID (First Input Delay)**: <100ms
- **CLS (Cumulative Layout Shift)**: <0.1

### Image Optimization
- [ ] Appropriate formats (WebP with fallback)
- [ ] Lazy loading for below-fold images
- [ ] Responsive images with srcset
- [ ] Compressed (no bloated file sizes)

### CSS
- [ ] No unused styles
- [ ] Minified in production
- [ ] Critical CSS inlined (if applicable)
- [ ] No render-blocking CSS

### JavaScript
- [ ] Minified in production
- [ ] No blocking scripts
- [ ] Deferred or async loading
- [ ] Minimal file size

---

## Browser Compatibility

### Required Browsers
- [ ] **Chrome/Edge** (Chromium): Latest 2 versions
- [ ] **Safari** (WebKit): Latest 2 versions
- [ ] **Firefox** (Gecko): Latest 2 versions

### Testing Scope
- [ ] Layout renders correctly
- [ ] Interactive features work
- [ ] No JavaScript errors
- [ ] Styling consistent
- [ ] Fonts load correctly

### Mobile Browsers
- [ ] Safari iOS: Latest version
- [ ] Chrome Android: Latest version

---

## Interactive Features Testing

### Buttons
- [ ] Click/tap works
- [ ] Hover state appears (desktop)
- [ ] Active/pressed state appears
- [ ] Disabled state works
- [ ] Loading state (if applicable)
- [ ] Focus state visible

### Forms
- [ ] All inputs work
- [ ] Validation triggers correctly
- [ ] Error messages display
- [ ] Success state works
- [ ] Submit works (or prevented correctly)
- [ ] Keyboard accessible

### Dropdowns/Menus
- [ ] Opens on click/tap
- [ ] Closes on outside click
- [ ] Closes on Escape key
- [ ] Keyboard navigable (arrow keys)
- [ ] Focus managed correctly
- [ ] Touch-friendly on mobile

### Modals/Dialogs
- [ ] Opens correctly
- [ ] Closes on X button
- [ ] Closes on outside click (if designed)
- [ ] Closes on Escape key
- [ ] Focus trapped inside
- [ ] Returns focus on close
- [ ] Scrolling locked on body

### Carousels/Sliders
- [ ] Navigation works (arrows, dots)
- [ ] Touch swipe works (mobile)
- [ ] Keyboard accessible (arrow keys)
- [ ] Auto-play works (if designed)
- [ ] Pause on hover (if auto-play)
- [ ] ARIA labels present

---

## Comparison Tools

### Playwright Visual Regression
```javascript
await expect(component).toHaveScreenshot('component-name.png', {
  maxDiffPixels: 500,  // <500px difference
  threshold: 0.02      // 98% match
});
```

### Manual Comparison Checklist
1. **Overlay Figma Screenshot**: Use dev tools or design tools
2. **Compare Colors**: Use browser inspect to check hex values
3. **Measure Spacing**: Use browser rulers/guides
4. **Check Typography**: Inspect font properties
5. **Test Interactions**: Click/hover all interactive elements
6. **Responsive Check**: Test all breakpoints

---

## Failure Criteria

### Automatic Fail (Block Implementation)
- Visual match <95%
- Pixel difference >1000px
- Layout broken on any viewport
- Horizontal scroll on mobile
- Missing required images
- Contrast ratio fails WCAG AA
- Broken interactive features
- JavaScript errors in console
- Form submission broken

### Warning (Fix Recommended)
- Visual match 95-98%
- Pixel difference 500-1000px
- Layout slightly off (5-10px)
- Minor spacing issues
- Non-critical accessibility issues
- Performance score 70-80

---

## Validation Workflow

### Phase 2 (HTML Implementation)
1. **Create Component**: Generate HTML/CSS/JS
2. **Run Playwright Tests**: Desktop/tablet/mobile
3. **Visual Comparison**: Figma vs Implementation
4. **Accessibility Audit**: Run axe or Lighthouse
5. **Browser Testing**: Chrome/Safari/Firefox
6. **Performance Check**: Lighthouse score

### Phase 3 (Liquid Conversion)
1. **Convert to Liquid**: Replace static with dynamic
2. **Preview in Shopify**: Check rendering
3. **Visual Comparison**: Shopify vs HTML
4. **Test Settings**: Verify schema controls work
5. **Final Validation**: All tests pass

### Iteration Loop
```
Generate → Test → Compare → Pass? → Proceed
                      ↓ Fail
                    Fix → Test
```

---

## Reporting Format

### Test Results Table
| Viewport | Resolution | Match % | Diff (px) | Status |
|----------|-----------|---------|-----------|--------|
| Desktop  | 1920×1080 | 98.5%   | 234       | ✓ PASS |
| Tablet   | 768×1024  | 97.8%   | 312       | ✓ PASS |
| Mobile   | 375×667   | 99.1%   | 89        | ✓ PASS |

### Accessibility Report
```
✓ Semantic HTML
✓ Heading hierarchy
✓ ARIA labels
✓ Color contrast (4.8:1)
✓ Keyboard navigation
✓ Screen reader friendly
```

### Performance Report
```
Lighthouse Scores:
- Performance: 92
- Accessibility: 98
- Best Practices: 95
- SEO: 100

Core Web Vitals:
- LCP: 1.8s ✓
- FID: 45ms ✓
- CLS: 0.05 ✓
```

---

## Edge Cases to Test

### Content Variations
- [ ] Very long product titles (wrapping)
- [ ] Very long descriptions (truncation)
- [ ] Empty states (no products)
- [ ] Single item (grid layout)
- [ ] Maximum items (performance)

### Image Variations
- [ ] Missing images (broken src)
- [ ] Different aspect ratios
- [ ] Very large images (loading)
- [ ] Very small images (pixelation)

### User States
- [ ] Logged out
- [ ] Logged in
- [ ] Empty cart
- [ ] Full cart
- [ ] Wishlist items

### Responsive Edge Cases
- [ ] Exactly at breakpoint (768px, 1024px)
- [ ] Very small screens (320px)
- [ ] Very large screens (2560px)
- [ ] Portrait/landscape orientation

---

## References

- Playwright Visual Testing: https://playwright.dev/docs/test-snapshots
- WCAG Guidelines: https://www.w3.org/WAI/WCAG21/quickref/
- Lighthouse: https://developers.google.com/web/tools/lighthouse
- Core Web Vitals: https://web.dev/vitals/
- axe Accessibility: https://www.deque.com/axe/
