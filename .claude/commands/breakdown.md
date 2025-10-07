---
description: Automatically analyze Figma file and create tasks with node IDs for MCP access
---

Execute the breakdown.sh script to automatically extract components from Figma and create implementation tasks.

**What this does:**

1. **Check Prerequisites**
   - Verify project initialized with /init-figma
   - Check for `figma-full-file.json` in root directory
   - Check GitHub CLI authentication
   - Verify access to repository

2. **Auto-Extract Components**
   - Parse `figma-full-file.json` to find all top-level frames/sections
   - Extract node IDs and component names automatically
   - Display list of found components with node IDs
   - Allow user to select which components to process

3. **For Each Selected Component:**
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
   - Create task file with:
     - All metadata (issue #, Figma link, complexity)
     - **Node ID for MCP access**
     - Phase 1/2/3 checklists
   - Update `.claude/tasks/index.json` with node ID
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
Each task in `.claude/tasks/index.json` includes:
```json
{
  "id": "1",
  "issueNumber": 1,
  "title": "PC_TOP",
  "slug": "pc-top",
  "branch": "issue-1-pc-top",
  "nodeId": "111:58",
  "figmaLink": "https://figma.com/...",
  "complexity": 8,
  "status": "pending",
  "phase": "analysis"
}
```

**After running:**
1. Review tasks: `cat .claude/tasks/index.json | jq`
2. Start implementation: `/implement`
3. Or work on specific task: `/implement <branch-name>`

**Note:** The `/implement` command will automatically use the stored node ID to access the component via Figma MCP tools.
