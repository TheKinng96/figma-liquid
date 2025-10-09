---
command: breakdown
description: Intelligently break down Figma designs into manageable implementation tasks
---

# Breakdown Figma Design

## Overview
This command analyzes your Figma file and intelligently splits it into implementable sections, creating a task markdown file for each section.

## Prerequisites
- Figma API token configured
- Figma file ID in `.claude/config.json`
- Project initialized with `/init-figma`

## Execution Steps

### Step 1: Fetch Figma File Structure
```bash
# Get Figma file data
curl -s -H "X-Figma-Token: $FIGMA_TOKEN" \
    "https://api.figma.com/v1/files/$FIGMA_FILE_ID" \
    > .claude/data/figma-file.json
```

### Step 2: Analyze Frame Structure
Read `.claude/data/figma-file.json` and identify:
- Main design frames (width: 375/768/1440/1920px)
- Exclude component libraries and random frames
- Separate mobile/tablet/desktop designs

### Step 3: Intelligent Section Splitting

For each identified design frame:

1. **Analyze the frame hierarchy**
   - Count nodes in each child element
   - Identify logical groupings (header, hero, sections, footer)
   - Consider Y-position for top-to-bottom ordering

2. **Apply splitting rules:**
   ```
   IF section has 100-400 nodes → Create as single task
   IF section has < 50 nodes → Merge with adjacent section
   IF section has > 400 nodes → Split into sub-sections
   ```

3. **Smart naming based on:**
   - Position (first = header, last = footer)
   - Content analysis (hero, gallery, testimonials, etc.)
   - Figma layer names (cleaned up)
   - Default to "Section N" if unclear

### Step 4: Generate Task Files

For each section, create a markdown file using this structure:

#### File naming: `.claude/tasks/{device}/task-{number}-{section-name}.md`

Example structure:
```
.claude/tasks/
├── desktop/
│   ├── task-001-header.md
│   ├── task-002-hero.md
│   ├── task-003-features.md
│   └── task-004-footer.md
├── mobile/
│   ├── task-001-header.md
│   └── task-002-hero.md
└── index.json
```

### Step 5: Task Template

Each task file should follow this template:

```markdown
---
task_id: task-001
section_name: Header
frame_name: Desktop_Home
frame_width: 1440
node_id: "12:34"
node_count: 156
figma_link: https://www.figma.com/file/{file_id}?node-id=12:34
status: pending
created_at: 2025-01-09T10:00:00Z
---

# Task: Implement Header

## CRITICAL INSTRUCTIONS
⚠️ **DO NOT GUESS OR USE PLACEHOLDERS** - Every measurement, color, and asset is available in Figma
⚠️ **ALWAYS USE FIGMA MCP** to get exact values before implementing
⚠️ **FRAME WIDTH IS ABSOLUTE** - This design is 1440px wide

## 1. Figma MCP Access
Copy this exact link to access the component:
\```
https://www.figma.com/file/{file_id}?node-id=12:34
\```

## 2. Required Assets to Download
Before starting implementation, download these assets from Figma:

### Images
- [ ] `logo.svg` - Company logo
- [ ] `hero-bg.jpg` - Background image

### Fonts
- [ ] Inter - Regular, Medium, Bold

## 3. Container Requirements
\```
Frame Width: 1440px (absolute)
Section Width: [CHECK WITH FIGMA MCP]
If section width < frame width:
  - Add container with transparent background
  - Center the section within frame
\```

## 4. Implementation Checklist

### Step 1: Verify Measurements with Figma MCP
\```bash
# Get exact measurements - DO NOT SKIP THIS
figma get-node --id "12:34"
\```

Record these values:
- [ ] Section width: ___px
- [ ] Section height: ___px
- [ ] Padding: ___px
- [ ] Gap between elements: ___px

### Step 2: Get Exact Colors
- [ ] Background: #______
- [ ] Text primary: #______
- [ ] Borders: #______

## 5. Validation Rules
- [ ] All measurements match Figma exactly
- [ ] All assets downloaded (no placeholders)
- [ ] Frame width is exactly 1440px
- [ ] Colors are exact hex values from Figma
```

### Step 6: Create Index File

Generate `.claude/tasks/index.json`:
```json
{
  "version": "1.0",
  "created_at": "2025-01-09T10:00:00Z",
  "figma_file": "{file_id}",
  "devices": {
    "desktop": {
      "frame_width": 1440,
      "tasks": [
        {
          "id": "task-001",
          "file": "desktop/task-001-header.md",
          "section": "Header",
          "node_count": 156,
          "status": "pending"
        }
      ]
    },
    "mobile": {
      "frame_width": 375,
      "tasks": []
    }
  },
  "statistics": {
    "total_tasks": 8,
    "by_device": {
      "desktop": 4,
      "mobile": 4
    }
  }
}
```

## Smart Splitting Logic

### Identifying Main Frames
```javascript
// Pseudo-code for frame identification
frames.filter(frame => {
  const isStandardWidth = [375, 768, 1440, 1920].includes(frame.width);
  const isTallEnough = frame.height > 500;
  const notComponent = !frame.name.includes('component');
  return isStandardWidth && isTallEnough && notComponent;
});
```

### Section Splitting Algorithm
```javascript
// Group children into logical sections
function splitIntoSections(frame) {
  const sections = [];
  let currentSection = [];
  let currentNodeCount = 0;
  
  const MAX_NODES = 400;
  const MIN_NODES = 50;
  
  // Sort children by Y position (top to bottom)
  const sortedChildren = frame.children
    .sort((a, b) => a.y - b.y);
  
  for (const child of sortedChildren) {
    const childNodes = countNodes(child);
    
    if (currentNodeCount + childNodes > MAX_NODES && currentNodeCount > MIN_NODES) {
      // Save current section and start new
      sections.push(currentSection);
      currentSection = [child];
      currentNodeCount = childNodes;
    } else {
      // Add to current section
      currentSection.push(child);
      currentNodeCount += childNodes;
    }
  }
  
  // Handle last section
  if (currentSection.length > 0) {
    sections.push(currentSection);
  }
  
  return sections;
}
