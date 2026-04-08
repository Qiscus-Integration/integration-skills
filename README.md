# Integration Skills

A collection of skills for **Claude Code** and **Codex (OpenAI CLI)** — installable without `git`.

## Installation

### Option 1 — Single `curl` command (Recommended)

No `git` required. Paste this in your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/Qiscus-Integration/integration-skills/main/install.sh | bash
```

The script will interactively ask:

1. Which AI tool to install for (Claude Code / Codex / Both)
2. Scope: Global (all projects) or Project (current project only)
3. Which skills to install

It installs the full skill folder, including optional companion files such as `agents/`, `references/`, and `scripts/`.

### Option 2 — Download ZIP via Browser

No terminal required:

1. Open the repository page on GitHub
2. Click **Code** → **Download ZIP**
3. Extract the downloaded ZIP
4. Copy the skill folder(s) you want to the appropriate directory:

**Claude Code:**

```text
~/.claude/skills/commit/       ← global (all projects)
.claude/skills/commit/         ← project scope (inside your project folder)
```

**Codex:**

```text
~/.codex/skills/commit/        ← global
.codex/skills/commit/          ← project scope
```

### Option 3 — For Developers (with git)

```bash
git clone https://github.com/Qiscus-Integration/integration-skills.git
cp -r integration-skills/skills/commit ~/.claude/skills/
```

## Uninstall

Remove installed skills with the interactive uninstaller:

```bash
curl -fsSL https://raw.githubusercontent.com/Qiscus-Integration/integration-skills/main/uninstall.sh | bash
```

The script will ask:

1. Which AI tool to remove skills from
2. Scope: Global or Project
3. Which installed skills to remove
4. Final confirmation before deleting the selected skill folders

---

## Usage

### Claude Code

After installation, invoke a skill with `/skill-name`:

```text
/commit
/review-pr
```

### Codex

Skills are automatically available when Codex starts. You can also invoke explicitly:

```text
$commit
$review-pr
```

---

## Contributing

See [docs/creating-skills.md](docs/creating-skills.md) for a guide on creating new skills.

---

## Need Help?

See [docs/install-without-git.md](docs/install-without-git.md) for a detailed installation guide without `git`.
