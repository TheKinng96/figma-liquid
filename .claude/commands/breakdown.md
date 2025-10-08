---
description: Auto-analyze Figma design and create implementation tasks with smart splitting
---

Execute the breakdown.sh script to automatically extract, analyze, and break down Figma components into implementable tasks.

**What this does:**

1. **Check Prerequisites**
   - Verify project initialized with /init-figma
   - Check GitHub CLI authentication
   - Verify Figma API access token

2. **Auto-Fetch Figma Design**
   - Download full Figma file structure via API to `logs/figma-full-file.json`
   - Extract all top-level frames/components from all pages
   - Display list of available components with IDs
   - Allow selection of specific components or all

3. **Smart Component Analysis & Recursive Splitting**

   **For each selected component:**

   a. **Count nodes** from Figma API data structure

   b. **Check size thresholds:**
      - ✅ **< 300 nodes**: Safe for MCP - create task
      - ⚠️ **300-500 nodes**: Warning but workable - create task
      - ❌ **> 500 nodes**: Too large for MCP - auto-split

   c. **Recursive Auto-Splitting (>500 nodes):**
      - Extract direct child frames sorted by Y position (top to bottom)
      - **Recursively** check each child's size
      - If child also >500 nodes, **split that child too**
      - Continues until all leaf components are <500 nodes
      - Max depth: 5 levels to prevent infinite recursion
      - **Only creates tasks for safe-sized components**
      - Parent containers are skipped (no task created)

   **Why This Matters:**
   - MCP tools have ~25,000 token output limit
   - Components >500 nodes typically exceed this limit
   - Recursive splitting ensures **all** tasks are implementable
   - No manual re-breakdown needed during implementation!

4. **For Each Safe Component (Task Creation):**
   - **Generate slug** from component name
   - **Calculate complexity** (1-10) based on node count:
     - <50 nodes: 3/10
     - <150 nodes: 5/10
     - <300 nodes: 7/10
     - ≥300 nodes: 9/10
   - **Determine type**: page, layout, or section
   - **Build Figma link** with node ID
   - **Create GitHub issue** with:
     - Title: "Implement {Component}" or "Implement {Parent} - Section N: {Component}"
     - Node ID and node count in body
     - MCP access code snippet
     - Task checklist (Phase 1/2/3)
     - Labels: figma-conversion, auto-split (if applicable), priority, phase
   - **Create git branch**: `issue-{N}-{slug}`
   - **Create task JSON file**: `.claude/tasks/task{N}.json`
     - Includes: nodeId, nodeCount, parentComponent, sectionNumber, isAutoSplit
     - Status: pending, Phase: analysis
   - **Update index**: `.claude/tasks/index.json`
   - **Commit** to branch

5. **Validation Summary**
   - Display breakdown by size category:
     - ✅ Safe components (<300 nodes)
     - ⚠️ Warning components (300-500 nodes)
     - ❌ Oversized components (>500 nodes, auto-split)
   - Show task statistics
   - List next steps

**Example Auto-Split Flow:**

```
PC_TOP (786 nodes) ❌ Too large
├── Auto-split into 7 children:
│   ├── ヘッダーE (56 nodes) ✅ Safe → Task #1
│   ├── Frame 1689 (16 nodes) ✅ Safe → Task #2
│   ├── sec02_bnr_pc (6 nodes) ✅ Safe → Task #3
│   ├── Frame 1567 (615 nodes) ❌ Still too large!
│   │   ├── Auto-split Frame 1567 into 8 children:
│   │   │   ├── Frame 1497 (107 nodes) ✅ Safe → Task #4
│   │   │   ├── Frame 1566 (58 nodes) ✅ Safe → Task #5
│   │   │   └── ... (Tasks #6-#11)
│   ├── Frame 1569 (33 nodes) ✅ Safe → Task #12
│   ├── Frame 1523 (2 nodes) ✅ Safe → Task #13
│   └── Frame 1493 (57 nodes) ✅ Safe → Task #14

Result: PC_TOP split into 14 implementable tasks
```

**Task Structure:**

Individual JSON files for better visibility:

`.claude/tasks/task1.json`:
```json
{
  "id": "1",
  "issueNumber": 29,
  "title": "ヘッダーE",
  "slug": "pc-top-1",
  "branch": "issue-29-pc-top-1",
  "nodeId": "111:785",
  "figmaLink": "https://figma.com/...",
  "complexity": 5,
  "nodeCount": 56,
  "type": "layout",
  "parentComponent": "PC_TOP",
  "sectionNumber": 1,
  "isAutoSplit": "true",
  "status": "pending",
  "phase": "analysis"
}
```

`.claude/tasks/index.json`:
```json
{
  "tasks": ["task1.json", "task2.json", ...],
  "version": "2.0",
  "lastUpdated": "2025-10-08T12:00:00Z"
}
```

**After running:**

1. Review all tasks:
   ```bash
   cat .claude/tasks/index.json | jq
   ```

2. View specific task:
   ```bash
   cat .claude/tasks/task1.json | jq
   ```

3. View all tasks at once:
   ```bash
   cat .claude/tasks/task*.json | jq -s
   ```

4. Start implementation:
   ```bash
   /implement
   ```

5. Or work on specific task:
   ```bash
   /implement issue-29-pc-top-1
   ```

**Key Benefits:**

- ✅ **Zero manual intervention**: Fully automated extraction and splitting
- ✅ **MCP-safe**: All tasks guaranteed under token limits
- ✅ **Recursive**: Handles deeply nested complex components
- ✅ **Order preserved**: Children sorted by Y position (top to bottom)
- ✅ **Seamless implementation**: `/implement` works without re-breakdown
- ✅ **Clear tracking**: Each task includes node count and parent info
- ✅ **GitHub integration**: Issues auto-created with all context

**Files Created:**

- `logs/figma-full-file.json` - Full Figma file structure
- `.claude/data/top-level-frames.txt` - Extracted components list
- `.claude/tasks/task1.json`, `task2.json`, etc. - Individual task files
- `.claude/tasks/index.json` - Task index
- Git branches for each task

**Next Steps:**

The `/implement` command will automatically:
1. Read task JSON to get nodeId
2. Use MCP to fetch component code
3. Generate HTML/CSS/JS
4. Run Playwright tests
5. Convert to Liquid

No manual breakdown or node ID lookup needed!
