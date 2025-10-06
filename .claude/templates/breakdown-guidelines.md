# Component Breakdown Guidelines

## Purpose
These guidelines ensure Figma components are split into manageable, testable chunks before implementation.

---

## Complexity Thresholds

### Maximum Limits
- **Element Count**: ≤8 direct child elements
- **Nesting Depth**: ≤4 levels deep
- **Complexity Score**: ≤7/10
- **File Size**: ≤100 lines of code

### Auto-Split Triggers
Component MUST be split if ANY of these are true:
- More than 8 direct child elements
- More than 4 levels of nesting
- Complexity score >7
- Multiple distinct interactive features (3+)
- Multiple data sources (product + collection + custom)
- Estimated implementation >100 lines

---

## Complexity Scoring Formula

```
Complexity = (Elements × 0.5) + (Depth × 1.5) + (Interactions × 2) + (Data Sources × 1.5)
```

### Scoring Guide
- **0-3**: Simple atom (button, icon, text)
- **4-7**: ✅ **Acceptable component** - Proceed with implementation
- **8-10**: ⚠️ Complex but manageable - Consider splitting
- **>10**: ❌ **MUST SPLIT** - Too complex for single component

### Examples

**Example 1: Simple Button**
- Elements: 1 (button) = 0.5
- Depth: 1 (no nesting) = 1.5
- Interactions: 1 (click) = 2
- Data sources: 0 (static) = 0
- **Total**: 4 ✅ **Acceptable**

**Example 2: Product Card**
- Elements: 4 (image, title, price, button) = 2
- Depth: 2 (card > content > elements) = 3
- Interactions: 1 (click) = 2
- Data sources: 1 (product) = 1.5
- **Total**: 8.5 ⚠️ **Consider splitting**

**Example 3: Full Product Page**
- Elements: 12 (gallery, info, variants, form, description, etc) = 6
- Depth: 4 (page > section > container > elements) = 6
- Interactions: 5 (gallery, variants, quantity, add to cart, reviews) = 10
- Data sources: 3 (product, recommendations, reviews) = 4.5
- **Total**: 26.5 ❌ **MUST SPLIT**

---

## DO's - Good Chunking Practices

### ✅ Split by Responsibility
Each component should have ONE clear purpose.

**Good**:
- `header-logo` - Just the logo
- `header-nav` - Just navigation menu
- `header-actions` - Just cart/search/account

**Bad**:
- `header` - Everything together (too complex)

### ✅ Split by Data Source
Separate components by what data they consume.

**Good**:
- `product-info` - Uses `{{ product }}` object
- `product-recommendations` - Uses `{{ recommendations }}` collection
- `product-reviews` - Uses custom metafields

**Bad**:
- `product-section` - Mixes all data sources

### ✅ Split by Behavior
Separate static content from interactive features.

**Good**:
- `product-details` - Static product info
- `product-variant-selector` - Interactive variant selection
- `add-to-cart-form` - Interactive form submission

**Bad**:
- `product-content` - Mix of static and interactive

### ✅ Create Reusable Snippets
If something appears multiple times, make it a snippet.

**Good**:
- `product-card` snippet used in:
  - Featured products section
  - Collection grid
  - Related products
  - Search results

**Bad**:
- Copy-paste product HTML in 4 different places

### ✅ Follow Atomic Design Principles
- **Atoms**: Button, icon, input, label
- **Molecules**: Search bar (input + button), product price (price + sale badge)
- **Organisms**: Header (logo + nav + actions), product card
- **Sections**: Hero, featured collection, footer

---

## DON'Ts - Bad Chunking Practices

### ❌ Don't Split Mid-Element
Never break up a single semantic element.

**Bad**:
```
card-image (just the image)
card-content (everything else)
```

**Good**:
```
product-card (image + content together as one card)
```

### ❌ Don't Create Cross-Dependencies
Components shouldn't require HTML from other components.

**Bad**:
```html
<!-- card-wrapper.liquid -->
<div class="card">
  {% render 'card-content' %} <!-- needs specific wrapper -->
</div>
```

**Good**:
```html
<!-- product-card.liquid -->
<div class="product-card">
  <!-- everything self-contained -->
</div>
```

### ❌ Don't Split by Viewport
Mobile and desktop are the same component (responsive CSS).

**Bad**:
- `nav-desktop.liquid`
- `nav-mobile.liquid`

**Good**:
- `header-nav.liquid` (with responsive CSS)

### ❌ Don't Create Utility Components
Components should have semantic meaning.

**Bad**:
- `flexbox-container`
- `grid-wrapper`
- `spacing-div`

**Good**:
- `product-grid`
- `collection-list`
- `featured-section`

### ❌ Don't Duplicate Code
Use snippets for repeated patterns.

**Bad**:
```liquid
<!-- sections/featured-products.liquid -->
<div class="product-card">...</div>

<!-- sections/collection-grid.liquid -->
<div class="product-card">...</div> <!-- duplicated! -->
```

**Good**:
```liquid
<!-- snippets/product-card.liquid -->
<div class="product-card">...</div>

<!-- sections/featured-products.liquid -->
{% render 'product-card', product: product %}

<!-- sections/collection-grid.liquid -->
{% render 'product-card', product: product %}
```

---

## Chunking Process

### Step 1: Analyze Figma Component
Use MCP to extract:
1. **Element count**: How many direct children?
2. **Nesting depth**: How many levels deep?
3. **Interactive features**: Clicks, hovers, forms?
4. **Data sources**: What Shopify objects are needed?
5. **Calculate complexity score**

### Step 2: Identify Split Points
Look for natural boundaries:
- **Visual separation**: Distinct sections with spacing/borders
- **Functional separation**: Navigation vs content vs footer
- **Data separation**: Different Shopify objects
- **Reusability**: Appears multiple times in design

### Step 3: Name Chunks
Follow naming conventions:
- **Parent component**: `{page-type}-{section}` (e.g., `product-gallery`)
- **Child components**: `{parent}-{element}` (e.g., `gallery-thumbnail`)
- **Reusable snippets**: `{element}-card` (e.g., `product-card`)
- **Use kebab-case**: `header-nav`, not `HeaderNav` or `header_nav`

### Step 4: Map Dependencies
Document the order:
- What loads first? (header before content)
- What depends on what? (thumbnails need gallery)
- What's reusable? (product-card in 5 places)

### Step 5: Validate Complexity
Each chunk should score ≤7. If not, repeat process.

---

## Real-World Examples

### ✅ GOOD: E-commerce Homepage

```
homepage (too complex - split into sections)

├── header (section) - Complexity: 6 ✓
│     ├── logo (atom) - Complexity: 1 ✓
│     ├── main-nav (molecule) - Complexity: 5 ✓
│     └── header-actions (molecule) - Complexity: 4 ✓
│           ├── search-toggle (atom)
│           ├── account-link (atom)
│           └── cart-icon (atom)
│
├── hero-banner (section) - Complexity: 5 ✓
│
├── featured-collection (section) - Complexity: 6 ✓
│     └── product-card (snippet) - Complexity: 3 ✓ [REUSED]
│
├── promotional-banner (section) - Complexity: 3 ✓
│
└── footer (section) - Complexity: 7 ✓
      ├── footer-newsletter (molecule) - Complexity: 4 ✓
      ├── footer-nav (molecule) - Complexity: 5 ✓
      └── footer-social (molecule) - Complexity: 2 ✓
```

**Analysis**: All chunks ≤7 complexity ✅

---

### ❌ BAD: Monolithic Product Page

```
product-page (everything in one component)
  Complexity: 28 ❌ WAY TOO HIGH

  Contains:
  - Product gallery (5 images + zoom + thumbnails)
  - Product info (title, vendor, description, badges)
  - Variant selector (size, color, quantity)
  - Price display (regular, sale, unit pricing)
  - Add to cart form (button, quantity, stock status)
  - Product tabs (description, reviews, shipping)
  - Related products (4 product cards)
  - Recently viewed (4 product cards)
```

**Problems**:
- Cannot test individual features
- Cannot reuse product card
- Changes to one feature risk breaking others
- Impossible to maintain
- >500 lines of code

---

### ✅ GOOD: Product Page (Split Properly)

```
product-page (orchestrator - loads sections)

├── product-gallery (section) - Complexity: 6 ✓
│     ├── gallery-main (molecule)
│     └── gallery-thumbnails (molecule)
│
├── product-info (section) - Complexity: 7 ✓
│     ├── product-price (snippet) - Complexity: 3 ✓ [REUSED]
│     ├── product-badges (snippet) - Complexity: 2 ✓
│     └── product-meta (molecule)
│
├── product-form (section) - Complexity: 6 ✓
│     ├── variant-selector (molecule) - Complexity: 5 ✓
│     ├── quantity-selector (molecule) - Complexity: 3 ✓
│     └── add-to-cart (molecule) - Complexity: 4 ✓
│
├── product-tabs (section) - Complexity: 5 ✓
│     ├── tab-description (molecule)
│     ├── tab-reviews (molecule)
│     └── tab-shipping (molecule)
│
├── related-products (section) - Complexity: 4 ✓
│     └── product-card (snippet) - Complexity: 3 ✓ [REUSED]
│
└── recently-viewed (section) - Complexity: 4 ✓
      └── product-card (snippet) - Complexity: 3 ✓ [REUSED]
```

**Benefits**:
- All chunks testable independently
- Product card reused 3 times
- Easy to maintain and modify
- Can enable/disable sections via theme editor

---

## Component Type Guidelines

### Sections (`theme/sections/*.liquid`)
Use for:
- Full-width layout sections
- Independently manageable content
- Theme editor customizable blocks
- Top-level page structures

Examples: header, hero, featured-products, footer

### Snippets (`theme/snippets/*.liquid`)
Use for:
- Reusable components
- Repeated patterns
- Small, focused elements
- Shared across multiple sections

Examples: product-card, icon, breadcrumbs, loading-spinner

### Layouts (`theme/layout/*.liquid`)
Use for:
- Page templates
- Overall HTML structure
- Should NOT be split further

Example: theme.liquid (main layout)

---

## Checklist for /breakdown Command

When running `/breakdown`, verify:

- [ ] All components analyzed with MCP
- [ ] Complexity scores calculated
- [ ] No component >7 complexity
- [ ] Reusable patterns identified
- [ ] Dependencies mapped
- [ ] Naming conventions followed
- [ ] Task files created for each chunk
- [ ] GitHub issues created
- [ ] Git branches created

---

## When to Re-evaluate

Re-run breakdown if:
- Design changes significantly
- Component complexity increases
- Tests become difficult to write
- File exceeds 100 lines
- Multiple bugs in same component
- Team suggests splitting

---

## References

- Atomic Design: https://atomicdesign.bradfrost.com/
- Shopify Theme Architecture: https://shopify.dev/docs/themes/architecture
- BEM Naming: https://getbem.com/naming/
