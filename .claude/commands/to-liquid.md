---
description: Convert HTML to Shopify Liquid theme files
---

Execute the to-liquid.sh script to convert working HTML to Shopify Liquid.

**What this does:**

## Prerequisites Check

1. **Verify on Issue Branch**
   - Must be on valid issue branch
   - Load task information

2. **Check Phase 2 (HTML) Complete**
   - Verify HTML files exist
   - Check task file Phase 2 checklist
   - If incomplete: **Warn** and ask to proceed
   - User can skip warning (not blocked)

## Conversion Process

### 1. Set Up Theme Structure
Create Shopify theme directories if not exist:
```
theme/
├── sections/
├── snippets/
├── layout/
│   └── theme.liquid (basic layout)
├── templates/
├── assets/
├── config/
└── locales/
```

### 2. Determine Component Type
Prompt user:
- **(1) Section** - Full-width, theme editor customizable
- **(2) Snippet** - Reusable component

Target file:
- Section: `theme/sections/{slug}.liquid`
- Snippet: `theme/snippets/{slug}.liquid`

### 3. Convert HTML to Liquid
Claude will read files and convert:

**Source Files:**
- `html/{slug}.html`
- `css/{slug}.css`
- `js/{slug}.js` (if exists)

**Conversion Steps:**

1. **Static → Dynamic Content**
   ```liquid
   <!-- Before -->
   <h1>Product Title</h1>
   <img src="product.jpg">

   <!-- After -->
   <h1>{{ product.title }}</h1>
   <img src="{{ product.featured_image | img_url: 'large' }}">
   ```

2. **Move CSS to Stylesheet Block**
   ```liquid
   {% stylesheet %}
     .component {
       /* CSS here */
     }
   {% endstylesheet %}
   ```

3. **Move JS to JavaScript Block**
   ```liquid
   {% javascript %}
     // JavaScript here
   {% endjavascript %}
   ```

4. **Add Section Schema** (if section)
   ```liquid
   {% schema %}
   {
     "name": "Component Name",
     "settings": [
       {
         "type": "text",
         "id": "heading",
         "label": "Heading"
       }
     ],
     "presets": [
       {
         "name": "Component Name"
       }
     ]
   }
   {% endschema %}
   ```

5. **Use Shopify Objects**
   - `{{ product }}` - Product data
   - `{{ collection }}` - Collection data
   - `{{ section.settings }}` - Theme settings
   - `{{ shop }}` - Shop data
   - Proper filters: `| money`, `| img_url`, `| escape`

### 4. Validate Liquid
Run validation checks:
- Syntax validation (unclosed tags, malformed syntax)
- Schema JSON validation (if section)
- BEM naming in CSS
- Shopify objects usage
- Filter usage (money, img_url, escape)

### 5. Test in Shopify Preview
If Shopify CLI installed:
```bash
shopify theme dev
```

Access preview at: `http://127.0.0.1:9292`

### 6. Visual Comparison
- Compare Shopify preview with HTML version
- Ensure visual match
- Verify all Liquid variables render
- Check section settings work

### 7. Update Task File
- Mark Phase 3 items complete
- Document Shopify objects used
- Add Liquid conversion notes
- Log completion timestamp

### 8. Commit & Create PR
```bash
git add theme/ .claude/tasks/
git commit -m "Task #{N}: Liquid conversion complete"
```

Prompt: Create PR? (y/N)
```bash
gh pr create --fill
```

## Success Criteria

Phase 3 complete when:
- ✅ Liquid file created
- ✅ Static content → Liquid variables
- ✅ CSS in `{% stylesheet %}` block
- ✅ JS in `{% javascript %}` block
- ✅ Schema added (if section)
- ✅ Liquid syntax valid
- ✅ Shopify preview matches HTML
- ✅ No console errors
- ✅ All settings work

## Guidelines Used

Claude follows:
- `liquid-conversion-guidelines.md` - Conversion patterns
- `liquid-patterns/` - Reusable Liquid templates
- Shopify best practices
- BEM CSS naming

## Notes

- Script provides structure
- Claude performs actual conversion
- Validation runs automatically
- User prompted if Phase 2 incomplete (not blocked)
- Shopify preview optional (if CLI installed)
