---
name: skill-name
description: >
  Brief description of what this skill does and WHEN it should be triggered
  automatically. This field is read first when the AI decides whether this
  skill is relevant — make the trigger context explicit.
  Example: "Use this skill when the user asks to create a commit message,
  or mentions 'commit', 'git commit', or 'save to git'."
---

## Overview

Brief explanation of what this skill does and the outcome it should produce.

## Workflow

Adapt these steps to the task. Keep them concrete and execution-oriented.

1. First step
2. Second step
3. Third step

## Output

Describe the expected artifact, format, or side effects from this skill.
- Example: create a Markdown doc at `docs/features/[slug]/prd.md`
- Example: update an existing config file and summarize follow-up checks

## Usage Examples

### Example 1

**Input:**
```
[example user input]
```

**Expected output:**
```
[expected output]
```

## Notes

- Add important notes here
- Limitations or things to be aware of
- Mention any important assumptions or decision rules

## Companion Files

Use this section when the skill depends on bundled references, templates, or helper scripts.

| Path | Purpose |
|------|---------|
| `references/example-reference.md` | Optional reference material to open when the task needs deeper rules or examples |
| `assets/templates/example-output.md.template` | Reusable output template that should be adapted to the user's request |
| `agents/openai.yaml` | Optional metadata for Codex UI |

## Bundled Resources

- `references/` contains documentation loaded on demand. Do not assume these files are already in context.
- `assets/templates/` contains reusable output skeletons. Open and adapt them instead of rewriting the same structure each time.
- `scripts/` is optional for helper automation. If a script is required, mention when to run it and what it produces.
- Any required external guidance must either be repeated here or explicitly opened by the agent before use.
