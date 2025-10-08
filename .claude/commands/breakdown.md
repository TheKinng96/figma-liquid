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

3. **Validate & Auto-Split Components (Critical!)**

   For each component, the script **automatically and recursively** validates size:

   a. **Count child nodes** in the component tree
   b. **Check against thresholds**:
      - ✅ **< 300 nodes**: Safe, will work with MCP
      - ⚠️ **300-500 nodes**: Warning, may need splitting
      - ❌ **> 500 nodes**: Too large, will exceed MCP 25k token limit

   c. **Automatic Recursive Splitting (>500 nodes)**:
      - Script **automatically** detects oversized components
      - Extracts direct child frames sorted by Y-position (top to bottom)
      - **Recursively validates** each child's size
      - If child is also >500 nodes, **splits that child too**
      - Continues until all components are under limit
      - Creates separate tasks for each safe-sized section
      - Skips parent component (only creates tasks for leaf sections)

   **Why This Matters:**
   - MCP tools (`get_metadata`, `get_code`) have 25,000 token limit
   - Components >500 nodes typically exceed this limit
   - Recursive splitting ensures **all** final tasks are implementable
   - No manual intervention needed!

   **Splitting Example:**

   ```
   PC_TOP (786 nodes) ❌ Too large
   ├── Auto-split into 7 children:
   │   ├── ヘッダーE (56 nodes) ✅ Safe → Create task
   │   ├── Frame 1689 (16 nodes) ✅ Safe → Create task
   │   ├── sec02_bnr_pc (6 nodes) ✅ Safe → Create task
   │   ├── Frame 1567 (615 nodes) ❌ Still too large!
   │   │   ├── Auto-split Frame 1567 into 8 children:
   │   │   │   ├── Frame 1497 (107 nodes) ✅ Safe → Create task
   │   │   │   ├── Frame 1566 (58 nodes) ✅ Safe → Create task
   │   │   │   ├── Frame 1501 (106 nodes) ✅ Safe → Create task
   │   │   │   ├── Frame 1503 (145 nodes) ✅ Safe → Create task
   │   │   │   ├── Frame 1509 (62 nodes) ✅ Safe → Create task
   │   │   │   ├── Frame 1512 (63 nodes) ✅ Safe → Create task
   │   │   │   ├── line_bnr (20 nodes) ✅ Safe → Create task
   │   │   │   └── Frame 1513 (53 nodes) ✅ Safe → Create task
   │   ├── Frame 1569 (33 nodes) ✅ Safe → Create task
   │   ├── Frame 1523 (2 nodes) ✅ Safe → Create task
   │   └── Frame 1493 (57 nodes) ✅ Safe → Create task
   │
   Result: PC_TOP split into 15 implementable tasks (56-145 nodes each)
   ```

   **Order Preservation:**
   - Child components sorted by Y coordinate (top to bottom)
   - Ensures sections implemented in visual order
   - Task naming: `{parent}-{N}` for numbered sections
   - All tasks tagged with `auto-split` label

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

4. **Summary & Validation Report**
   - Display component size validation summary:
     - ✅ Safe components (<300 nodes)
     - ⚠️ Warning components (300-500 nodes)
     - ❌ Oversized components (>500 nodes, if any slipped through)
   - Show task statistics
   - List all created tasks with node IDs and node counts
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
  "id": "14",
  "issueNumber": 14,
  "title": "PC_TOP_ヘッダーE",
  "slug": "pc-top-1",
  "branch": "issue-14-pc-top-1",
  "nodeId": "111:785",
  "figmaLink": "https://figma.com/...",
  "complexity": 5,
  "nodeCount": 56,
  "type": "section",
  "parentComponent": "PC_TOP",
  "sectionNumber": 1,
  "isOversized": "false",
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
