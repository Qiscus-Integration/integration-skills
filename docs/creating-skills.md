# Creating a New Skill

Skills are instructions given to Claude Code or Codex to perform specific tasks consistently.

---

## Skill Structure

```text
skills/
└── skill-name/
    ├── SKILL.md                         # Required — main instructions
    ├── agents/
    │   └── openai.yaml                  # Optional — metadata for Codex UI
    ├── references/                      # Optional — load on demand
    │   └── example-reference.md
    ├── assets/
    │   └── templates/                   # Optional — reusable output skeletons
    │       └── example-output.md.template
    └── scripts/                         # Optional — helper automation
        └── helper.py
```

`skills/_template/` is the starter folder for new skills. It now includes example `references/`
and `assets/templates/` files so new skills can follow the same modular pattern used by richer
skills such as `project-memory`.

---

## Writing SKILL.md

Copy the template from `skills/_template/SKILL.md` and customize it:

```yaml
---
name: skill-name
description: >
  Explain what this skill does AND when it should be triggered.
  This field is critical — the AI reads it to decide whether this skill
  is relevant to the user's request.
---

## Overview
...
```

### Naming rules

- Lowercase letters only
- Use hyphens (`-`) as word separators
- Maximum 64 characters
- Use a verb that describes the action: `review-pr`, `generate-test`, `deploy-staging`
- The folder name must exactly match the `name` field in the frontmatter

### Tips for writing a good `description`

The `description` field determines when the skill is automatically activated.
Include:

- What the skill does
- Keywords or phrases users typically say when they need this skill

Poor example:

```yaml
description: "Skill for commit."
```

Good example:

```yaml
description: >
  Generate a good git commit message based on code changes.
  Trigger when the user mentions 'commit', 'git commit', 'save to git',
  or asks to create/write a commit message.
```

### Tips for writing the SKILL.md body

- Describe the steps the AI should follow
- Include the expected output format
- Add input/output examples
- Keep it concise — the body is loaded after the skill triggers, so avoid bloat
- Don't duplicate things the AI already knows (common conventions, basic syntax)
- If the skill depends on files in `references/`, `assets/templates/`, or `scripts/`, add a `## Bundled Resources` section that lists them and explains when to open them explicitly
- Do not assume companion files are automatically loaded, especially in Claude Code
- Prefer putting reusable output shapes in `assets/templates/` instead of embedding long templates directly in `SKILL.md`

---

## Writing agents/openai.yaml (Optional)

Only needed if you want the skill to appear with richer metadata in the Codex UI.
Claude Code ignores this file.

```yaml
interface:
  display_name: "Human-Readable Name"
  short_description: "25-64 character description"
  default_prompt: "Use $skill-name to [action]. [Optional instruction]."

policy:
  allow_implicit_invocation: true   # false = explicit $skill-name invocation only
```

---

## Checklist Before Submitting

Before opening a PR with a new skill:

- [ ] Folder name matches the `name` field in the frontmatter
- [ ] Both `name` and `description` are present in SKILL.md frontmatter
- [ ] `description` explains WHEN the skill triggers (not just what it does)
- [ ] Skill has been tested in Claude Code or Codex
- [ ] No sensitive files (`.env`, credentials) inside the skill folder
- [ ] Skill name uses lowercase + hyphens, max 64 characters

---

## Adding the Skill to README

After creating a skill, add it to the skills directory by browsing the `skills/` folder in the repository.

---

## Full Folder Structure (for richer skills)

For richer skills that need references, templates, or helper scripts:

```text
skills/
└── skill-name/
    ├── SKILL.md
    ├── agents/
    │   └── openai.yaml
    ├── references/              # Documentation loaded on demand
    │   └── api-docs.md
    ├── assets/
    │   └── templates/           # Output templates adapted per request
    │       └── report.md.template
    └── scripts/                 # Python/Bash scripts executed by the skill
        └── helper.py
```

> **Note:** Claude Code and Codex do not automatically load companion files just because they
> exist in the skill folder. Always document them in `SKILL.md` and open them explicitly when
> needed.
