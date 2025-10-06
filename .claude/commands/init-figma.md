---
description: Initialize Figma to Shopify Liquid conversion project
---

Execute the init-figma.sh script to validate Figma URL and check environment setup. The script will:

1. Prompt user to paste Figma browser URL
2. Validate URL format (must be figma.com/design or figma.com/file)
3. Extract file key from URL
4. Check if FIGMA_ACCESS_TOKEN exists in .env
5. Test API access to the Figma file
6. Save project configuration to .claude/data/figma-project.json

After running, guide the user to use /plan command next.
