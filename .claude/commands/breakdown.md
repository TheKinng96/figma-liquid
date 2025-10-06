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
   - Use Figma MCP to analyze component structure:
     - `mcp__figma-dev-mode-mcp-server__get_metadata` - Get component hierarchy
     - `mcp__figma-dev-mode-mcp-server__get_code` - Get styles/CSS
     - `mcp__figma-dev-mode-mcp-server__get_screenshot` - Get visual reference
   - Calculate complexity score using formula:
     ```
     Complexity = (Elements × 0.5) + (Depth × 1.5) + (Interactions × 2) + (Data Sources × 1.5)
     ```
   - If complexity >7: Warn and suggest splitting
   - Create GitHub issue with:
     - Title: "Implement {Component Name}"
     - Labels: figma-conversion, priority, phase
     - Body: Figma link, complexity, task checklist
   - Create git branch: `issue-{N}-{slug}`
   - Create task file from `task-template.md`:
     - Fill in metadata (issue #, Figma link, complexity)
     - Add MCP analysis results
     - Set up Phase 1/2/3 checklists
   - Add task to `.claude/tasks/index.json`
   - Commit task file to branch

4. **Summary**
   - Display task statistics
   - Show next steps
   - Suggest running /implement

**After running, guide user to:**
- Review created tasks and GitHub issues
- Use `/implement` to start working on first task
- Or use `/implement <branch-name>` to work on specific task
