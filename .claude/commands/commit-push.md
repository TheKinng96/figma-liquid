---
allowed-tools:
  - Bash(git status:*)
  - Bash(git diff:*)
  - Bash(git log:*)
  - Bash(git add:*)
  - Bash(git commit:*)
  - Bash(git push:*)
argument-hint: "[optional: custom commit message]"
description: Auto-generate commit message from changes, commit and push
---

Automatically generate a commit message and push changes with these steps:

1. Run `git status` to see all untracked and modified files
2. Run `git diff --cached` and `git diff` to see the actual code changes
3. Run `git log -5 --oneline` to understand the recent commit message style

4. Analyze all the changes and generate a SHORT, concise commit message that:
   - Summarizes the nature of changes (add/update/fix/refactor/etc)
   - Is 1 line, max 72 characters
   - Follows conventional commit style if the repo uses it
   - Examples:
     * "Add user authentication system"
     * "Fix database connection pooling issue"
     * "Update tailwind config and home page"
     * "Refactor candidate pipeline components"

5. Show the generated commit message to the user and ask for confirmation

6. If approved, stage all changes with `git add -A`

7. Create commit using this format:
```
[Your generated message]

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

8. Push to remote with `git push`

9. Confirm success with the commit message used

NOTE: If user provides $ARGUMENTS, use that as the commit message instead of generating one.
