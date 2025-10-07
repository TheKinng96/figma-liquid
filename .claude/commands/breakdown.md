---
description: Automatically analyze Figma file and create tasks with node IDs for MCP access
---

Execute the breakdown.sh script to automatically extract components from Figma and create implementation tasks.

**What this does:**

1. **Check Prerequisites**
   - Verify project initialized with /init-figma
   - Check for `figma-full-file.json` in `logs/` directory
   - Check GitHub CLI authentication
   - Verify access to repository

2. **Auto-Extract Components**
   - Parse `logs/figma-full-file.json` to find all top-level frames/sections
   - Extract node IDs and component names automatically
   - Display list of found components with node IDs
   - Allow user to select which components to process

3. **Validate Component Size (Critical!)**

   For each component, the script automatically:

   a. **Count child nodes** in the component tree
   b. **Check against thresholds**:
      - ✅ **< 300 nodes**: Safe, will work with MCP
      - ⚠️ **300-500 nodes**: Warning, may need splitting
      - ❌ **> 500 nodes**: Too large, will exceed MCP 25k token limit

   c. **If component is too large (>500 nodes)**:
      - Script displays error message
      - Shows node count
      - Offers to skip component
      - **User should either**:
        1. Skip and manually split in Figma
        2. Continue anyway (will fail during `/implement`)

   **Why This Matters:**
   - MCP tools (`get_metadata`, `get_code`) have 25,000 token limit
   - Components >500 nodes typically exceed this limit
   - If not caught here, `/implement` will fail with token error

   **How to Split Large Components:**

   If a component is too large, you have two options:

   **Option A: Split in Figma (Recommended)**
   1. Open Figma file
   2. Identify major sections in the large component (header, hero, product-grid, footer, etc.)
   3. Create separate top-level frames for each section
   4. Re-export Figma JSON
   5. Re-run `/breakdown`

   **Option B: Auto-Split via Script**
   1. Script detects large component
   2. Extracts direct children frames
   3. Creates separate tasks for each child
   4. Maintains correct order based on Y-position
   5. Example: `PC_TOP` (786 nodes) → `PC_TOP_Header` (120 nodes), `PC_TOP_Hero` (80 nodes), `PC_TOP_Products` (200 nodes), etc.

   **Order Preservation:**
   - Child components are sorted by vertical position (Y coordinate)
   - Ensures sections are implemented in visual order (top to bottom)
   - Task naming: `{parent}-section-{N}` or `{parent}-{child-name}`

4. **For Each Selected Component:**
   - Extract node ID (e.g., `111:58` for PC_TOP)
   - Create slug from component name
   - Calculate initial complexity score:
     - Homepage/TOP: 8/10
     - Product detail: 7/10
     - Responsive sections: 6/10
     - Other: 5/10
   - Build Figma link with node ID
   - Create GitHub issue with:
     - Title: "Implement {Component Name}"
     - Body: Figma link, node ID, complexity, task checklist
     - Labels: figma-conversion, priority-medium, phase-core
   - Create git branch: `issue-{N}-{slug}`
   - Create task files:
     - Markdown file with checklists (`.claude/tasks/{slug}.md`)
     - Individual JSON file (`.claude/tasks/task{N}.json`)
     - All metadata (issue #, Figma link, complexity, **node ID for MCP access**)
   - Update `.claude/tasks/index.json` to list all task files
   - Commit task files to branch

4. **Summary**
   - Display task statistics
   - Show created tasks with node IDs
   - Suggest next steps

**Components Found (Example):**
```
- PC_TOP (node: 111:58)
- SP_TOP (node: 111:856)
- PC_商品詳細 (node: 111:2244)
- SP_商品詳細 (node: 111:1875)
- ドロワー (node: 111:2116)
```

**Task Structure:**

Tasks are stored as individual JSON files for better visibility:
- `.claude/tasks/task1.json` - First task details
- `.claude/tasks/task2.json` - Second task details
- `.claude/tasks/index.json` - Lists all task files

Each task file (e.g., `task1.json`) contains:
```json
{
  "id": "2",
  "issueNumber": 2,
  "title": "PC_TOP",
  "slug": "pc-top",
  "branch": "issue-2-pc-top",
  "nodeId": "111:58",
  "figmaLink": "https://figma.com/...",
  "complexity": 8,
  "type": "section",
  "status": "pending",
  "phase": "analysis"
}
```

The `index.json` file lists all tasks:
```json
{
  "tasks": ["task1.json", "task2.json", "task3.json", ...],
  "version": "2.0",
  "lastUpdated": "2025-10-07T03:05:52Z",
  "description": "Task files are now individual JSON files for better visibility"
}
```

**After running:**
1. Review task list: `cat .claude/tasks/index.json | jq`
2. View specific task: `cat .claude/tasks/task1.json | jq`
3. View all tasks at once: `cat .claude/tasks/task*.json | jq -s`
4. Start implementation: `/implement`
5. Or work on specific task: `/implement <branch-name>`

**File Locations:**
- Figma JSON file: `logs/figma-full-file.json`
- Task files: `.claude/tasks/task1.json`, `task2.json`, etc.
- Task index: `.claude/tasks/index.json`

**Note:** The `/implement` command will automatically use the stored node ID to access the component via Figma MCP tools.
