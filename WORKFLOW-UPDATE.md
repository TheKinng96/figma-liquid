# Improved Figma to Liquid Workflow

## Overview

The workflow has been updated to automatically extract components from Figma and use node IDs for MCP access throughout the implementation process.

## What Changed

### 1. Automated Component Discovery
**Before:** Manual input of Figma component links one by one
**Now:** Automatic extraction from `figma-full-file.json`

- Parses JSON to find all top-level frames/sections
- Extracts node IDs automatically
- Shows interactive selection menu

### 2. Node ID Storage
**New:** Each task now stores its Figma node ID for MCP access

```json
{
  "id": "1",
  "issueNumber": 1,
  "title": "PC_TOP",
  "nodeId": "111:58",  // ← NEW
  "figmaLink": "https://figma.com/...",
  "complexity": 8,
  "status": "pending"
}
```

### 3. MCP Integration
**New:** Implementation script provides node ID to Claude for MCP access

The `/implement` command now:
1. Extracts node ID from task index
2. Exports it as environment variable
3. Displays MCP tool instructions with the node ID
4. Claude uses MCP to access component directly

## Components Found in Current Figma File

18 frames/sections detected:

### Main Pages
- **PC_TOP** (111:58) - Desktop homepage [Complexity: 8/10]
- **SP_TOP** (111:856) - Mobile homepage [Complexity: 8/10]
- **PC_商品詳細** (111:2244) - Desktop product detail [Complexity: 7/10]
- **SP_商品詳細** (111:1875) - Mobile product detail [Complexity: 7/10]
- **PC_コレクションテンプレート（ブランド）** (111:2524) - Desktop collection [Complexity: 6/10]
- **SP_コレクションテンプレート（ブランド）** (111:1339) - Mobile collection [Complexity: 6/10]

### Components
- **ドロワー** (111:2116) - Drawer/menu [Complexity: 6/10]
- **設定** (111:3155) - Settings [Complexity: 5/10]
- Plus 10 additional frames

## New Workflow Steps

### Step 1: Run `/breakdown`

```bash
/breakdown
```

This will:
1. Check for `figma-full-file.json`
2. Extract all components with node IDs
3. Show interactive selection
4. Create GitHub issues and branches
5. Generate tasks with node IDs

### Step 2: Run `/implement`

```bash
/implement
# or
/implement issue-1-pc-top
```

This will:
1. Switch to task branch
2. Load node ID from task index
3. Display MCP instructions with node ID
4. Claude uses these MCP tools:
   - `get_metadata` - Structure/hierarchy
   - `get_code` - CSS/styles
   - `get_screenshot` - Visual reference
   - `get_variable_defs` - Design tokens

### Step 3: Implementation

Claude automatically:
1. Calls MCP with node ID
2. Generates HTML/CSS/JS
3. Creates Playwright tests
4. Runs validation
5. Updates task status

## Files Modified

1. **`.claude/scripts/breakdown.sh`**
   - Auto-extracts components from JSON
   - Stores node IDs in task index
   - Creates detailed GitHub issues

2. **`.claude/scripts/implement.sh`**
   - Loads node ID from task index
   - Exports environment variables
   - Displays MCP instructions

3. **`.claude/scripts/task-helpers.sh`**
   - Fixed macOS compatibility issue
   - Supports node ID storage

4. **`.claude/commands/breakdown.md`**
   - Updated documentation
   - Added workflow examples

## Testing

Extraction test successful:
```bash
$ bash test-extraction.sh
Found 18 frames/sections

- PC_TOP (node: 111:58)
- sec01_bnr_sp (node: 111:842)
- SP_TOP (node: 111:856)
- PC_商品詳細 (node: 111:2244)
...
```

## Next Steps

To use the new workflow:

1. **Run breakdown** to create all tasks:
   ```bash
   /breakdown
   ```

2. **Select components** to implement (or choose "all")

3. **Start implementation** on first task:
   ```bash
   /implement
   ```

4. Claude will automatically use MCP with the node ID to access the component

## Benefits

✅ **Fully automated** - No manual link copying
✅ **MCP-ready** - Node IDs stored for direct access
✅ **Scalable** - Process all 18 components at once
✅ **Consistent** - Same workflow for every component
✅ **Traceable** - Node IDs tracked in task index

## Example Task Flow

```bash
# 1. Create all tasks automatically
/breakdown
> Found 18 frames
> Process all? (y/N): y
> ✓ Created 18 tasks with node IDs

# 2. Implement first task
/implement
> Task: PC_TOP
> Node ID: 111:58
> [Claude uses MCP to access 111:58]
> ✓ Generated HTML/CSS/JS
> ✓ Tests pass

# 3. Move to next task
/implement issue-2-sp-top
> Task: SP_TOP
> Node ID: 111:856
> [Claude uses MCP to access 111:856]
...
```

## Architecture

```
figma-full-file.json
    ↓
breakdown.sh extracts components
    ↓
.claude/tasks/index.json (with nodeId)
    ↓
implement.sh loads nodeId
    ↓
Claude uses MCP with nodeId
    ↓
Generated code + tests
```
