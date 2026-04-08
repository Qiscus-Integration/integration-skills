# Installation Without Git

This guide is for users who don't have `git` or are not comfortable with the terminal.

---

## Method 1: Single Terminal Command (Recommended)

The easiest way. Open your terminal and paste:

```bash
curl -fsSL https://raw.githubusercontent.com/Qiscus-Integration/integration-skills/main/install.sh | bash
```

The script will guide you interactively — just answer the prompts.

It installs the full skill folder, including companion files such as `agents/`, `references/`, and `scripts/` when they exist.

### Requirements

- `curl` must be installed (comes pre-installed on Mac, Linux, and Windows WSL)

### How to Open a Terminal

- **Mac:** Press `Cmd + Space`, type "Terminal", press Enter
- **Windows (WSL):** Press `Win`, type "Ubuntu" or "WSL", press Enter
- **Linux:** Press `Ctrl + Alt + T`

---

## Method 2: Download ZIP via Browser (No Terminal)

For users who don't want to use the terminal at all.

### Steps

1. **Download the repository**

   Open your browser and go to:

   ```text
   https://github.com/Qiscus-Integration/integration-skills
   ```

   Click **Code** → **Download ZIP**

   The ZIP file will download to your Downloads folder.

2. **Extract the ZIP**

   - **Mac:** Double-click the ZIP file
   - **Windows:** Right-click → "Extract All"
   - **Linux:** Right-click → "Extract Here"

3. **Select the skill(s) you want**

   Inside the extracted folder, open the `skills/` directory.
   Pick the skill folder you want, e.g. `commit/`.

4. **Copy to the correct directory**

   Open your file manager (Finder on Mac, Explorer on Windows) and navigate to the target folder:

   #### For Claude Code

   | Scope                 | Location                                       |
   | --------------------- | ---------------------------------------------- |
   | Global (all projects) | `~/.claude/skills/`                            |
   | Single project        | `.claude/skills/` inside your project folder   |

   #### For Codex

   | Scope                 | Location                                       |
   | --------------------- | ---------------------------------------------- |
   | Global (all projects) | `~/.codex/skills/`                             |
   | Single project        | `.codex/skills/` inside your project folder    |

   > **Note:** `~` means your home directory:
   > - Mac/Linux: `/Users/yourname/` or `/home/yourname/`
   > - Windows WSL: `/home/yourname/`

   **How to show hidden folders:**
   - **Mac:** Press `Cmd + Shift + .` in Finder
   - **Windows:** Check "Hidden items" under the View tab in Explorer

5. **Restart the application**

   After copying, restart Claude Code or Codex for the skill to be recognized.

---

## Verifying the Installation

### Claude Code

Type `/commit` — if the skill is installed, it will appear in autocomplete.

### Codex

Type `$commit` — the skill will appear in the list.

---

## Troubleshooting

### Skill does not appear after installation

- Make sure the folder structure is correct:
  `~/.claude/skills/commit/SKILL.md`
  (not `~/.claude/skills/SKILL.md`)
- Restart the application
- Make sure the folder name matches the `name` field in `SKILL.md`

### The `.claude` folder is not visible

- This folder is hidden because it starts with a dot (`.`)
- Enable "Show hidden files" in your file manager

### `curl` not found

- **Mac:** `brew install curl`
- **Windows:** Use WSL or download from [https://curl.se/windows](https://curl.se/windows)

---

## Uninstalling Skills

If you want to remove installed skills later, run:

```bash
curl -fsSL https://raw.githubusercontent.com/Qiscus-Integration/integration-skills/main/uninstall.sh | bash
```

The uninstaller will let you choose:

- Claude Code, Codex, or both
- Global or project scope
- Which installed skill folders to remove
