---
description: Analyze Figma design, create chunked tasks, GitHub issues, and branches
---

Execute the breakdown.sh script to start component breakdown workflow.

**What this does:**

1. **Check Prerequisites**
   - Verify project initialized with /init-figma
   - Check GitHub CLI authentication
   - Verify access to repository

2. **Component Input**
   - Prompt user to paste Figma component links
   - One component link per line
   - Right-click component in Figma → Copy link

3. **For Each Component:**
   - **Extract node ID** from Figma URL (e.g., `node-id=111-786` → `111:786`)
   - **Use Figma REST API** to analyze frame structure:
     - Get full node metadata with children count
     - Calculate nesting depth
     - Extract component name
     - Save analysis to `.claude/data/analysis-N.json`
   - **Check MCP compatibility:**
     - If children >100 OR nesting depth >10: **TOO LARGE FOR MCP**
     - Automatically break down into sections using direct children
     - Create todo list with section node IDs
     - Save sections to `.claude/data/sections-N.txt`
   - **Calculate complexity score:**
     ```
     Complexity = (Children / 20) + (Nesting Depth / 2)
     Clamped to 1-10
     ```
   - **If complexity >7:** Warn and suggest splitting
   - **Create GitHub issue** with:
     - Title: "Implement {Component Name}"
     - Node ID in issue body
     - Section breakdown (if large frame)
     - Implementation guide with node IDs
     - Labels: figma-conversion, priority, phase
   - **Create git branch:** `issue-{N}-{slug}`
   - **Create task file** with:
     - Node ID for MCP access
     - Section breakdown with node IDs
     - Implementation instructions
     - Phase 1/2/3 checklists
   - **Add to index:** `.claude/tasks/index.json`
   - **Commit:** Task file + analysis + sections list

4. **Summary**
   - Display task statistics
   - Show next steps
   - Suggest running /implement

**After running, guide user to:**
- Review created tasks and GitHub issues
- Use `/implement` to start working on first task
- Or use `/implement <branch-name>` to work on specific task
