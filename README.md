# Integration Skills

A curated collection of reusable agent skills for [Claude Code](https://claude.ai/code) and [Codex (OpenAI CLI)](https://platform.openai.com/docs/codex).
Skills extend AI assistants with structured, repeatable workflows — from writing commit messages to generating full product specifications.

---

## Available Skills

### Product Workflow

Four skills that form an end-to-end product delivery chain — each role hands off a file to the next.

```bash
[PM]       $prd-plan     →  docs/features/[slug]/prd.md
                                         ↓
[Designer] $design-plan  →  docs/features/[slug]/design-spec.md
                                         ↓
[QA]       $qa-plan      →  docs/features/[slug]/qa-testplan.md
                                         ↓
[Dev]      $dev-plan     →  docs/features/[slug]/dev-plan.md
```

| Skill | Role | What it produces | Docs |
| ----- | ---- | ---------------- | ---- |
| `prd-plan` | Product Manager | PRD with user journeys, data model, API contracts, and user stories | [docs/prd-plan.md](docs/prd-plan.md) |
| `design-plan` | UI/UX Designer | Screen inventory, component list, interaction states, Figma structure, and handoff notes | [docs/design-plan.md](docs/design-plan.md) |
| `qa-plan` | QA Engineer | Manual test cases, Gherkin scenarios, automation spec, API tests, and sign-off checklist | [docs/qa-plan.md](docs/qa-plan.md) |
| `dev-plan` | Developer | Task breakdown, architecture decisions, DB migrations, API plan, frontend plan, and definition of done | [docs/dev-plan.md](docs/dev-plan.md) |

### General Skills

| Skill | What it does | Docs |
| ----- | ------------ | ---- |
| `commit` | Generates a Conventional Commits message from staged changes | [docs/commit.md](docs/commit.md) |
| `project-memory` | Creates shared AI memory files such as `AGENTS.md`, `CLAUDE.md`, and repo-based context folders for team handoff | [docs/project-memory.md](docs/project-memory.md) |
| `ruby-rails` | Rails backend conventions for models, controllers, services, and specs | [docs/ruby-rails.md](docs/ruby-rails.md) |

---

## Installation

### Option 1 — Terminal (macOS / Linux / Windows WSL / Git Bash)

```bash
curl -fsSL https://raw.githubusercontent.com/Qiscus-Integration/integration-skills/main/install.sh | bash
```

### Option 2 — Windows PowerShell

```powershell
irm https://raw.githubusercontent.com/Qiscus-Integration/integration-skills/main/install.ps1 | iex
```

> **Security note:** For maximum security, clone the repo first and run the installer locally instead of piping from curl. See [SECURITY.md](SECURITY.md) for details.

The installer will ask:

1. Which AI tool to install for — Claude Code, Codex, or both
2. Scope — Global (all projects) or Project (current directory only)
3. Which skills to install

It copies the full skill folder, including all companion files (`agents/`, `references/`, `assets/templates/`, `scripts/`).

### Option 3 — Manual (no terminal required)

1. Download this repository as a ZIP from GitHub: **Code → Download ZIP**
2. Extract the ZIP and open the `skills/` folder
3. Copy the skill folder(s) you want to the target location:

| Tool | Scope | Location |
| ------ | ------- | ---------- |
| Claude Code | Global | `~/.claude/skills/[skill-name]/` |
| Claude Code | Project | `.claude/skills/[skill-name]/` |
| Codex | Global | `~/.codex/skills/[skill-name]/` |
| Codex | Project | `.codex/skills/[skill-name]/` |

> **Note:** `~/.claude/skills/` is a hidden directory. On macOS press `Cmd + Shift + .` in Finder to show hidden folders. On Windows, enable "Hidden items" in the Explorer View tab.

### Option 4 — Git clone

```bash
git clone https://github.com/Qiscus-Integration/integration-skills.git
cp -r integration-skills/skills/commit ~/.claude/skills/
```

---

## Usage

### Claude Code

Invoke a skill by typing its name as a slash command:

```bash
/commit
/prd-plan
```

### Codex

Skills are available automatically on startup. You can also invoke explicitly:

```bash
$commit
$prd-plan
```

---

## Uninstall

### macOS / Linux / Windows WSL / Git Bash

```bash
curl -fsSL https://raw.githubusercontent.com/Qiscus-Integration/integration-skills/main/uninstall.sh | bash
```

### Windows PowerShell

```powershell
irm https://raw.githubusercontent.com/Qiscus-Integration/integration-skills/main/uninstall.ps1 | iex
```

The uninstaller will ask which skills to remove, from which tool, and at which scope. It requires a confirmation before deleting anything.

---

## Contributing

See [docs/creating-skills.md](docs/creating-skills.md) for a full guide on writing and submitting new skills.

Quick checklist before opening a PR:

- [ ] Folder name matches the `name` field in `SKILL.md` frontmatter
- [ ] `description` in `SKILL.md` explains **when** the skill triggers, not just what it does
- [ ] Skill has been tested end-to-end in Claude Code or Codex
- [ ] No sensitive files (`.env`, credentials) inside the skill folder
- [ ] If the skill reads companion files, they are listed in a `## Bundled Resources` section
- [ ] If the skill has reusable output shapes, they live in `assets/templates/` instead of bloating `SKILL.md`

---

## Need Help?

- **Installation without git:** [docs/install-without-git.md](docs/install-without-git.md)
- **Writing a new skill:** [docs/creating-skills.md](docs/creating-skills.md)
- **Issues and feedback:** open an issue on GitHub
