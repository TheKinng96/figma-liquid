# Figma to Shopify Liquid

Automated workflow for converting Figma designs to Shopify Liquid themes using Claude AI with MCP (Model Context Protocol) and Playwright testing.

## Overview

This project provides a complete, automated pipeline for converting Figma designs into production-ready Shopify Liquid themes:

- **Figma MCP Integration**: Direct component analysis, screenshot comparison, style extraction
- **Test-Driven Development**: Playwright validation ensures visual accuracy ≥98%
- **HTML-First Approach**: Validate HTML before Liquid conversion
- **Branch-Per-Task Workflow**: Git branch for each component with full task tracking
- **Dual Task State**: Local task files + GitHub issues for team visibility

## Quick Start

### 1. Initialize Project

```bash
/init-figma
```

Paste your Figma design URL. Script validates access and saves project config.

### 2. Break Down Components

```bash
/breakdown
```

Paste Figma component links (one per line). For each component:
- Analyzes with MCP (metadata, styles, screenshots)
- Calculates complexity score
- Creates GitHub issue
- Creates git branch
- Generates task file

### 3. Implement Components

```bash
# Auto-detect from current branch
/implement

# Or switch to specific task
/implement issue-5-product-card
/implement product-card
/implement 5
```

Claude generates:
- Semantic HTML with BEM naming
- Responsive CSS (mobile-first)
- Vanilla JavaScript (if needed)
- Playwright tests (desktop/tablet/mobile)
- Visual validation against Figma

### 4. Convert to Liquid

```bash
/to-liquid
```

Converts working HTML to Shopify Liquid:
- Static → Dynamic content (Liquid variables)
- CSS → `{% stylesheet %}` block
- JS → `{% javascript %}` block
- Adds section schema
- Validates syntax
- Tests in Shopify preview

## Commands

### `/init-figma`
Initialize Figma project with API validation.

### `/breakdown`
Analyze Figma → Create tasks → GitHub issues + branches.

**Features:**
- MCP component analysis
- Complexity scoring (auto-warn if >7)
- Automatic chunking suggestions
- GitHub issue creation
- Branch creation per task
- Task file generation

### `/implement [branch-name]`
Generate HTML/CSS/JS with Playwright validation.

**No argument**: Auto-detect from current branch
**With argument**: Search and switch to specific task

**Features:**
- Branch switching with uncommitted change handling
- Phase 1 completion check (warns, doesn't block)
- Environment setup (Playwright, directories)
- MCP-driven HTML/CSS generation
- Automated testing and validation

### `/to-liquid`
Convert HTML to Shopify Liquid theme.

**Features:**
- Phase 2 completion check (warns, doesn't block)
- Section vs Snippet choice
- Liquid conversion with best practices
- Syntax validation
- Shopify preview testing
- Visual comparison with HTML

## Workflow

```
/init-figma
    ↓
/breakdown (paste Figma links)
    ↓
  Creates: GitHub issues + branches + task files
    ↓
git checkout issue-1-header
    ↓
/implement
    ↓
  Phase 1: Figma analysis ✓
  Phase 2: HTML + tests → validation ≥98% ✓
    ↓
/to-liquid
    ↓
  Phase 3: HTML → Liquid → Shopify preview ✓
    ↓
  Create PR
```

## Project Structure

```
.claude/
├── commands/           # Slash command configs
│   ├── init-figma.md
│   ├── breakdown.md
│   ├── implement.md
│   └── to-liquid.md
├── scripts/           # Shell automation
│   ├── init-figma.sh
│   ├── breakdown.sh
│   ├── implement.sh
│   ├── to-liquid.sh
│   ├── branch-detector.sh
│   ├── visual-validator.sh
│   ├── liquid-validator.sh
│   └── task-helpers.sh
├── templates/         # Documentation templates
│   ├── task-template.md
│   ├── breakdown-guidelines.md
│   ├── implementation-guidelines.md
│   ├── liquid-conversion-guidelines.md
│   ├── validation-criteria.md
│   └── liquid-patterns/
│       ├── product-card.liquid
│       ├── collection-grid.liquid
│       ├── hero-section.liquid
│       ├── navigation-menu.liquid
│       └── form-component.liquid
├── config/           # Configuration
│   ├── validation-rules.json
│   └── chunk-rules.json
├── tasks/            # Task files (committed to branches)
│   ├── issue-1-header.md
│   ├── issue-2-hero.md
│   └── index.json
└── data/             # Runtime data (gitignored)
    └── figma-project.json

html/                 # HTML output
css/                  # CSS output
js/                   # JavaScript output
tests/                # Playwright tests
theme/                # Shopify theme
├── sections/
├── snippets/
├── layout/
├── assets/
├── config/
└── locales/
```

## Task File Format

Each task has a markdown file with TDD checklists:

### Phase 1: Analysis ✓
- [ ] Figma structure analyzed
- [ ] Element count: ___ (≤8)
- [ ] Complexity: ___ (≤7)
- [ ] Colors extracted
- [ ] Fonts documented
- [ ] Assets listed

### Phase 2: HTML Implementation ✓
- [ ] Semantic HTML created
- [ ] BEM CSS applied
- [ ] Playwright tests passing
- [ ] Desktop: __% match (≥98%)
- [ ] Tablet: __% match (≥98%)
- [ ] Mobile: __% match (≥98%)
- [ ] Accessibility checks pass

### Phase 3: Liquid Conversion ✓
- [ ] Liquid file created
- [ ] Variables replaced
- [ ] Schema added
- [ ] Shopify preview matches HTML
- [ ] No console errors

## Complexity Scoring

```
Complexity = (Elements × 0.5) + (Depth × 1.5) + (Interactions × 2) + (Data Sources × 1.5)
```

**Thresholds:**
- 0-3: Simple atom
- 4-7: ✅ Acceptable (proceed)
- 8-10: ⚠️ Complex (consider splitting)
- >10: ❌ Must split

**Auto-split triggers:**
- More than 8 elements
- More than 4 nesting levels
- Complexity >7

## Validation Criteria

### Visual Validation
- Match threshold: ≥98%
- Max pixel difference: <500px
- Layout accuracy: ±5px

### Testing Requirements
- Desktop: 1920×1080
- Tablet: 768×1024
- Mobile: 375×667
- Accessibility: WCAG AA
- Lighthouse score: >80

## Prerequisites

### Required
- **Figma Access Token**: [Generate here](https://www.figma.com/developers/api#access-tokens)
- **GitHub CLI**: `brew install gh`
- **Node.js**: For Playwright
- **Git**: Version control

### Optional
- **Shopify CLI**: `brew tap shopify/shopify && brew install shopify-cli`

## Setup

### 1. Add Figma Token

```bash
echo "FIGMA_ACCESS_TOKEN=your_token_here" > .env
```

### 2. Authenticate GitHub

```bash
gh auth login
```

### 3. Install Dependencies

```bash
npm install -D @playwright/test
npx playwright install
```

## Configuration

### `.claude/config/validation-rules.json`

```json
{
  "visualThreshold": 0.98,
  "layoutTolerance": 5,
  "viewports": {
    "desktop": { "width": 1920, "height": 1080 },
    "tablet": { "width": 768, "height": 1024 },
    "mobile": { "width": 375, "height": 667 }
  }
}
```

### `.claude/config/chunk-rules.json`

```json
{
  "maxElements": 8,
  "maxNestingDepth": 4,
  "maxComplexityScore": 7,
  "forceBreakdown": true
}
```

## Key Features

### ✅ Automated
- Figma → Task files: 95% auto-filled
- HTML generation: Semantic, BEM, responsive
- Liquid conversion: Shopify best practices
- Visual validation: Automated with Playwright

### ✅ Quality Gates
- Complexity >7: Warned to split
- Tests <98%: Prompted before proceeding
- Liquid errors: Blocked with syntax validation
- All phases: Checklist-driven

### ✅ Developer Control
- Branch switching: Prompts for uncommitted changes
- Skip validation: Allowed with warning
- Manual edits: Preserved
- Flexible workflow: Commands work independently

### ✅ Tracking
- Dual state: Local task files + GitHub issues
- Progress visible: Checklists, test results
- Audit trail: Git commits per phase
- Team visibility: GitHub PRs with task docs

## Best Practices

### Component Breakdown
- Keep complexity ≤7
- Split by responsibility (nav, logo, actions)
- Create reusable snippets (product-card)
- Follow atomic design (atoms → molecules → organisms)

### HTML Implementation
- Semantic HTML5 elements
- BEM naming: `.block__element--modifier`
- Mobile-first responsive
- Accessibility (ARIA, contrast, keyboard nav)

### Liquid Conversion
- Use Shopify objects (`{{ product }}`, `{{ collection }}`)
- Apply filters (`| money`, `| img_url`, `| escape`)
- Add section schemas for customization
- Follow Shopify theme architecture

## Troubleshooting

### Figma Access Issues
- Verify token permissions
- Check file sharing with token owner
- Ensure correct URL format

### GitHub Issues
- Run `gh auth status`
- Check repository access
- Verify network connectivity

### Playwright Failures
- Run `npx playwright install`
- Check Shopify dev server running
- Verify selectors in tests

### MCP Connection
- Ensure Figma MCP server configured
- Validate component links
- Try re-copying link from Figma

## Example Workflow

```bash
# 1. Initialize
/init-figma
# → Paste: https://figma.com/file/ABC123/Store-Design

# 2. Breakdown
/breakdown
# → Paste component links:
#    Header: https://figma.com/file/.../Header
#    Hero: https://figma.com/file/.../Hero
#    Product Card: https://figma.com/file/.../ProductCard
# → Creates issues #1, #2, #3
# → Creates branches: issue-1-header, issue-2-hero, issue-3-product-card

# 3. Implement first task
git checkout issue-1-header
/implement
# → Analyzes Figma with MCP
# → Generates HTML/CSS/JS
# → Runs Playwright tests
# → Visual validation: 98.5% match ✓

# 4. Convert to Liquid
/to-liquid
# → Converts HTML to Liquid
# → Tests in Shopify preview
# → Creates PR

# 5. Next task
/implement issue-2-hero
# → Auto-commits current work
# → Switches branch
# → Starts implementation
```

## Environment Variables

```bash
# Required
FIGMA_ACCESS_TOKEN=figd_xxx

# Optional
SHOPIFY_PREVIEW_URL=http://127.0.0.1:9292
BASE_URL=http://localhost:8000  # For Playwright tests
```

## Resources

- [Shopify Liquid Docs](SHOPIFY_LIQUID_DOCS.md)
- [Figma API](https://www.figma.com/developers/api)
- [Playwright](https://playwright.dev)
- [GitHub CLI](https://cli.github.com)
- [Shopify Theme Docs](https://shopify.dev/docs/themes)

## Contributing

This is a Claude Code workflow project. Improvements welcome via:
1. Fork repository
2. Create feature branch
3. Test workflow end-to-end
4. Submit PR with example task files

## License

MIT
