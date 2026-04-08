---
name: commit
description: >
  Automatically generate a good git commit message based on staged code changes.
  Use this skill when the user asks to create a commit, write a commit message,
  or mentions 'commit', 'git commit', or wants to save changes to git.
---

## Overview

This skill analyzes staged code changes (`git diff --staged`) and generates
a commit message following the Conventional Commits convention.

## Commit Message Format

```
<type>(<scope>): <short description>

[optional body — explain WHAT and WHY, not HOW]

[optional footer — breaking changes, closes issue]
```

**Common types:**

| Type | When to use |
|---|---|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Refactor without behavior change |
| `docs` | Documentation changes |
| `test` | Add or update tests |
| `chore` | Build, config, dependencies |
| `perf` | Performance improvement |

## Steps

1. Run `git diff --staged` to see staged changes
2. Analyze: which files changed, what the impact is, why the change was made
3. Pick the most appropriate `type`
4. Write a short description in English, max 72 characters, using imperative mood ("add", "fix", "update" — not "added", "fixed")
5. Add a body if the change needs further explanation
6. Run the commit

## Examples

### Simple change
```
feat(auth): add JWT refresh token support
```

### Change with body
```
fix(api): handle null response from payment gateway

Payment gateway occasionally returns null instead of an error object
when the service is unavailable. This caused an unhandled exception.
```

### Breaking change
```
feat(api)!: change response format for /users endpoint

BREAKING CHANGE: response now returns { data: [...] } instead of plain array
```

## Notes

- Always run `git diff --staged` before generating a commit message
- If no files are staged, ask the user which files they want to commit
- Never include changes from `.env` or credential files

## Bundled Resources

- This skill currently has no companion files under `references/` or `scripts/`.
- If companion files are added later, do not assume they are already loaded in context.
