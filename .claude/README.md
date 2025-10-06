# Figma to Shopify Liquid - Claude Agent

An automated workflow for converting Figma designs to Shopify Liquid themes using Claude with MCP (Model Context Protocol) and Playwright testing.

## Overview

This agent helps you:
1. **Initialize** Figma projects with API validation
2. **Plan** component structure using MCP to analyze Figma designs
3. **Create Tasks** in GitHub Projects for organized development
4. **Implement** components with automated Playwright validation

## Prerequisites

- **Figma Access Token**: Generate at https://www.figma.com/developers/api#access-tokens
- **GitHub CLI**: Install with `brew install gh`
- **Node.js & npm**: For Playwright testing
- **Shopify CLI**: For theme development
- **Figma MCP Server**: Configured in Claude settings

## Setup

1. **Add Figma token to `.env`**:
   ```bash
   FIGMA_ACCESS_TOKEN=your_token_here
   ```

2. **Authenticate GitHub CLI**:
   ```bash
   gh auth login
   ```

3. **Install Playwright** (will be done automatically in /implement):
   ```bash
   npm init -y
   npm install -D @playwright/test
   npx playwright install
   ```

## Workflow

### 1. Initialize Project: `/init-figma`

Validates your Figma setup and project access.

**What it does**:
- Prompts for Figma URL
- Validates URL format
- Checks FIGMA_ACCESS_TOKEN in `.env`
- Tests API access to the file
- Saves project configuration

**Usage**:
```
/init-figma
```

Then paste your Figma design URL when prompted.

---

### 2. Plan Components: `/plan`

Creates a planning document and analyzes Figma components using MCP.

**What it does**:
- Creates planning template from `templates/component-planning.md`
- Sets up planning session
- Guides you to copy component links from Figma

**Usage**:
```
/plan
```

Then for each component:
1. In Figma: Right-click component → Copy link
2. Paste link in chat
3. Claude uses MCP to analyze component
4. Claude fills in component details in planning doc

**MCP Integration**:
- `get_metadata`: Component structure and hierarchy
- `get_code`: CSS styling information
- `get_screenshot`: Visual reference image

---

### 3. Create Tasks: `/tasks`

Generates GitHub issues and project board from planning.

**What it does**:
- Creates GitHub labels for organization
- Prompts for GitHub Project setup
- Prepares task creation workflow

**Usage**:
```
/tasks
```

Claude will then:
- Read planning document
- Create GitHub issue for each component
- Add labels (priority, phase, type)
- Link to GitHub Project
- Save tasks to `.claude/data/tasks.json`

**Labels Created**:
- `figma-conversion` - Component conversion work
- `liquid-template` - Liquid template tasks
- `styling` - CSS work
- `testing` - Playwright tests
- `priority-{high|medium|low}` - Priority levels
- `phase-{foundation|core|content|interactive|polish}` - Implementation phases

---

### 4. Implement: `/implement`

Starts the implementation workflow with Playwright validation.

**What it does**:
- Creates Shopify theme structure
- Sets up Playwright testing
- Enters implementation mode

**Usage**:
```
/implement
```

Claude will then for each task:

1. **Select Task**: Choose next task based on dependencies and priority
2. **Get Figma Data**: Use MCP to fetch component details
3. **Generate HTML**: Convert Figma to semantic HTML
4. **Convert to Liquid**: Add Shopify objects and variables
5. **Create Styles**: Generate BEM CSS from Figma styles
6. **Add JavaScript**: If interactive features needed
7. **Create Test**: Generate Playwright test file
8. **Run Test**: Validate with Playwright
9. **Visual Compare**: Match against Figma screenshot
10. **Mark Complete**: Update GitHub issue and move to next

**Implementation Loop**:
```
Task Selection → Figma MCP → HTML → Liquid → CSS → JS → Test → Validate → Complete
                                                                    ↓ (if fails)
                                                                  Fix → Test
```

---

## Directory Structure

```
.claude/
├── commands/              # Executable shell scripts
│   ├── init-figma.sh     # Project initialization
│   ├── plan.sh           # Planning workflow
│   ├── tasks.sh          # GitHub task creation
│   └── implement.sh      # Implementation mode
├── slash-commands/        # Slash command configs
│   ├── init-figma.json
│   ├── plan.json
│   ├── tasks.json
│   └── implement.json
├── scripts/              # Utility functions
│   ├── figma-api.sh     # Figma API helpers
│   ├── github-helpers.sh # GitHub CLI helpers
│   └── playwright-helpers.sh # Playwright utilities
├── templates/            # Document templates
│   └── component-planning.md
├── data/                 # Generated data (gitignored)
│   ├── figma-project.json
│   ├── planning/
│   ├── tasks.json
│   └── implementation-state.json
└── README.md            # This file
```

## Generated Theme Structure

```
theme/
├── sections/            # Theme sections
├── snippets/           # Reusable components
├── layout/             # Layout files
│   └── theme.liquid
├── templates/          # Page templates
├── assets/             # CSS, JS, images
├── config/             # Theme settings
│   └── settings_schema.json
└── locales/           # Translations
```

## Testing Structure

```
tests/
├── header.spec.js
├── hero.spec.js
├── product-card.spec.js
└── visual/
    └── [component]-[viewport].png
```

## Key Features

### MCP Integration
- **Direct Figma Access**: Get component metadata without manual exports
- **Screenshot Comparison**: Visual validation against Figma
- **Style Extraction**: Automatic CSS generation from Figma styles

### Playwright Testing
- **Multi-viewport**: Desktop, tablet, mobile
- **Visual Regression**: Screenshot comparison
- **Automatic Validation**: Test before marking complete
- **Accessibility Checks**: ARIA and semantic HTML validation

### GitHub Integration
- **Project Boards**: Organized task tracking
- **Issue Creation**: Automatic from planning
- **Progress Updates**: Real-time status sync
- **Dependency Management**: Proper task ordering

### Shopify Best Practices
- **BEM CSS**: Proper naming conventions
- **Semantic HTML**: Accessible structure
- **Liquid Patterns**: Following Shopify standards
- **Section Schema**: Customizable theme settings

## Configuration Files

### `.claude/data/figma-project.json`
```json
{
  "figmaUrl": "https://figma.com/file/...",
  "fileKey": "ABC123",
  "fileName": "My Design",
  "initialized": "2025-10-06T10:00:00Z"
}
```

### `.claude/data/tasks.json`
```json
{
  "tasks": [
    {
      "id": "1",
      "title": "Implement Header Component",
      "component": "header",
      "status": "completed",
      "url": "https://github.com/user/repo/issues/1",
      "dependencies": []
    }
  ]
}
```

## Workflow Example

```bash
# 1. Initialize
/init-figma
# Paste: https://figma.com/file/ABC123/My-Design

# 2. Plan
/plan
# Copy component links from Figma and paste in chat

# 3. Create tasks
/tasks
# Claude creates GitHub issues

# 4. Implement
/implement
# Claude starts implementing each component with testing

# Watch the magic happen! ✨
```

## Environment Variables

```bash
# Required
FIGMA_ACCESS_TOKEN=figd_xxx

# Optional
SHOPIFY_PREVIEW_URL=http://127.0.0.1:9292
GITHUB_TOKEN=ghp_xxx  # Usually set by gh auth login
```

## Troubleshooting

### Figma Access Issues
- Verify token has correct permissions
- Check file is shared with token owner
- Ensure URL format is correct

### GitHub Issues
- Run `gh auth status` to check authentication
- Ensure you're in a GitHub repository
- Check network connectivity

### Playwright Failures
- Run `npx playwright install` to install browsers
- Check Shopify dev server is running
- Verify component selector is correct

### MCP Connection
- Ensure Figma MCP server is configured
- Check component links are valid
- Try copying link again from Figma

## Advanced Usage

### Custom Component Types
Edit `.claude/templates/component-planning.md` to add your own component patterns.

### Custom Test Templates
Edit `.claude/scripts/playwright-helpers.sh` to customize test generation.

### API Scripts
Use `.claude/scripts/figma-api.sh` functions in custom scripts:
```bash
source .claude/scripts/figma-api.sh
fetch_figma_file "ABC123"
```

## Best Practices

1. **Plan First**: Complete planning before creating tasks
2. **One Task at a Time**: Let Claude finish one before starting next
3. **Review Tests**: Check Playwright results before marking complete
4. **Update Planning**: Keep planning doc current as design evolves
5. **Component Links**: Keep MCP component links in planning doc

## Resources

- [Shopify Liquid Docs](SHOPIFY_LIQUID_DOCS.md)
- [Figma API Docs](https://www.figma.com/developers/api)
- [Playwright Docs](https://playwright.dev)
- [GitHub CLI Docs](https://cli.github.com)

## Support

For issues or questions:
- Check planning document for component details
- Review `.claude/data/` for state information
- Check Playwright reports in `playwright-report/`
- Review GitHub issues for task status
