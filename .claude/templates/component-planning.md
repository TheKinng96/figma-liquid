# Figma to Liquid Component Planning Template

## Project Information
- **Figma File**: [File Name]
- **File Key**: [File Key]
- **Planning Date**: [Date]

---

## Page Structure Analysis

### 1. Layout Overview
- [ ] Header/Navigation
- [ ] Hero Section
- [ ] Content Sections (list all)
- [ ] Footer
- [ ] Mobile Layout Differences

### 2. Component Breakdown

#### Component: [Component Name]
**Figma Layer**: `[Layer Name/Path]`
**Component Type**: [Section/Snippet/Block]
**Liquid File**: `[sections/snippets]/[filename].liquid`

**Visual Description**:
- Layout: [flex/grid/block]
- Key Elements: [list all elements]
- Interactive Elements: [buttons, forms, sliders, etc.]

**Shopify Integration**:
- Data Source: [product/collection/custom/static]
- Dynamic Fields: [list fields that need Liquid variables]
- Settings Required: [list theme settings needed]

**CSS Requirements**:
- BEM Base Class: `.component-name`
- Responsive Breakpoints: [mobile/tablet/desktop specs]
- CSS Variables: [list custom properties needed]
- Animations/Transitions: [if any]

**Dependencies**:
- External Scripts: [if any]
- Other Components: [list component dependencies]
- Shopify Objects: [product, collection, cart, etc.]

**Complexity**: [Low/Medium/High]
**Estimated Time**: [hours]

---

### 3. Reusable Components (Snippets)

List components that appear multiple times:

1. **[Component Name]**
   - Usage Count: [number]
   - Variations: [list variations if any]
   - Props/Parameters: [list required parameters]

---

### 4. Theme Sections

List all sections that need to be created:

| Section Name | File Path | Dependencies | Priority |
|-------------|-----------|--------------|----------|
| Header | `sections/header.liquid` | - | High |
| Hero | `sections/hero.liquid` | - | High |
| Featured Products | `sections/featured-products.liquid` | product-card snippet | Medium |
| Footer | `sections/footer.liquid` | - | High |

---

### 5. Asset Requirements

**Images**:
- [ ] Logo (SVG preferred)
- [ ] Hero Images: [list sizes needed]
- [ ] Icons: [list all icons]
- [ ] Background Images: [if any]

**Fonts**:
- Primary Font: [font name, weights]
- Secondary Font: [font name, weights]
- Source: [Google Fonts/Custom/Shopify]

**Colors** (Extract from Figma):
```css
:root {
  --color-primary: #[hex];
  --color-secondary: #[hex];
  --color-text: #[hex];
  --color-background: #[hex];
  --color-accent: #[hex];
}
```

---

### 6. Interactive Features

List all interactive functionality:

1. **[Feature Name]**
   - Description: [what it does]
   - Implementation: [JavaScript/Shopify native/library]
   - Files: [list files needed]

---

### 7. Responsive Design

**Breakpoints**:
- Mobile: `< 768px`
- Tablet: `768px - 1024px`
- Desktop: `> 1024px`

**Layout Changes**:
- [List major layout shifts between breakpoints]

---

### 8. Performance Considerations

- [ ] Image optimization strategy
- [ ] Lazy loading requirements
- [ ] Critical CSS identification
- [ ] JavaScript bundling approach
- [ ] Font loading strategy

---

### 9. Accessibility Requirements

- [ ] ARIA labels needed
- [ ] Keyboard navigation
- [ ] Focus management
- [ ] Screen reader considerations
- [ ] Color contrast validation

---

### 10. Testing Requirements

**Visual Regression**:
- [ ] Desktop viewport: 1920x1080
- [ ] Tablet viewport: 768x1024
- [ ] Mobile viewport: 375x667

**Functional Testing**:
- [ ] [List all interactive features to test]

**Playwright Test Sections**:
- [ ] Header navigation
- [ ] Product interactions
- [ ] Cart functionality
- [ ] Form submissions
- [ ] [Add more as needed]

---

## Implementation Order

1. **Phase 1 - Foundation**
   - [ ] Setup theme structure
   - [ ] Create base layout
   - [ ] Setup CSS variables
   - [ ] Import fonts

2. **Phase 2 - Core Components**
   - [ ] Header/Navigation
   - [ ] Footer
   - [ ] Basic snippets

3. **Phase 3 - Content Sections**
   - [ ] Hero section
   - [ ] Product sections
   - [ ] Content sections

4. **Phase 4 - Interactive Features**
   - [ ] JavaScript functionality
   - [ ] Forms
   - [ ] Cart integration

5. **Phase 5 - Polish**
   - [ ] Responsive refinements
   - [ ] Performance optimization
   - [ ] Accessibility audit

---

## Notes & Considerations

[Add any additional notes, edge cases, or special considerations here]

---

## MCP Component Links

For each component, save the Figma component link here for MCP access:

- Header: `[Copy link from Figma]`
- Hero: `[Copy link from Figma]`
- Product Card: `[Copy link from Figma]`
- [Add more as needed]
