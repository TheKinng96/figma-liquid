---
task_id: task-001
section_name: Hero Section
frame_name: PC_TOP
frame_width: 1440
node_id: "111:785"
node_count: 156
figma_link: https://www.figma.com/file/XXX/YYY?node-id=111:785
status: pending
created_at: 2025-01-09T10:00:00Z
---

# Task: Implement Hero Section

## CRITICAL INSTRUCTIONS
⚠️ **DO NOT GUESS OR USE PLACEHOLDERS** - Every measurement, color, and asset is available in Figma
⚠️ **ALWAYS USE FIGMA MCP** to get exact values before implementing
⚠️ **FRAME WIDTH IS ABSOLUTE** - This design is {frame_width}px wide

## 1. Figma MCP Access
Copy this exact link to access the component:
```
https://www.figma.com/file/XXX/YYY?node-id=111:785
```

## 2. Required Assets to Download
Before starting implementation, download these assets from Figma:

### Images
- [ ] `hero-background.jpg` - Background image (1440x600)
- [ ] `logo.svg` - Company logo (120x40)
- [ ] `icon-arrow.svg` - Arrow icon (24x24)

### Fonts
- [ ] Inter - Regular, Medium, Bold
- [ ] Noto Sans JP - Regular, Bold

## 3. Container Requirements
```
Frame Width: 1440px (absolute)
Section Width: [CHECK WITH FIGMA MCP]
If section width < frame width:
  - Add container with transparent background
  - Center the section within frame
```

## 4. Implementation Checklist

### Step 1: Verify Measurements with Figma MCP
```bash
# Get exact measurements - DO NOT SKIP THIS
figma get-node --id "111:785"
```
Record these values:
- [ ] Section width: ___px
- [ ] Section height: ___px
- [ ] Padding top: ___px
- [ ] Padding bottom: ___px
- [ ] Padding left: ___px
- [ ] Padding right: ___px

### Step 2: Verify Spacing
- [ ] Gap between elements: ___px
- [ ] Margin between sections: ___px
- [ ] Line height values: ___

### Step 3: Verify Colors
Get exact color values from Figma MCP:
- [ ] Background color: #______
- [ ] Text color primary: #______
- [ ] Text color secondary: #______
- [ ] Border color: #______

### Step 4: Typography Details
- [ ] Heading font size: ___px
- [ ] Body font size: ___px
- [ ] Font weights: ___
- [ ] Letter spacing: ___

## 5. Structure Guidelines

### HTML Structure
```html
<!-- Frame container (1440px) -->
<div class="frame-container">
  <!-- Section container (actual width from Figma) -->
  <section class="[section-name]">
    <!-- Content here -->
  </section>
</div>
```

### CSS Requirements
```css
.frame-container {
  width: 1440px; /* Absolute frame width */
  margin: 0 auto;
}

/* Section width MUST match Figma exactly */
.section {
  width: [GET FROM FIGMA MCP]px;
  /* If smaller than frame, center it */
  margin: 0 auto;
}
```

## 6. Validation Rules
Before marking complete, verify:
- [ ] All measurements match Figma exactly (use MCP to verify)
- [ ] All assets are downloaded and used (no placeholders)
- [ ] Frame width is exactly 1440px
- [ ] Section is properly centered if width < frame width
- [ ] All colors are exact hex values from Figma
- [ ] All gaps and spacing match Figma pixel-perfect

## 7. Common Mistakes to Avoid
❌ Using approximate values (e.g., "about 20px")
❌ Using placeholder images or colors
❌ Guessing spacing based on visual appearance
❌ Using rem/em instead of exact px from Figma
❌ Ignoring small details like borders or shadows

## 8. Dependencies
- Parent: [parent_task_id if applicable]
- Requires: [list any dependent sections]
- Assets folder: `/assets/task-001/`

## Notes
[Any special instructions or context about this section]
