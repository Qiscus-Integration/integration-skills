# MCP Memory Server — File-based Setup

This guide covers setting up a **file-based MCP Memory Server** where the memory file
lives inside the Git repo and is shared across the entire team via `git pull/push`.

---

## How It Works

```bash
.project-memory/mcp/memory.json   ← Single shared file, committed to repo
        ↑                            ↑
  Claude Code               Codex CLI
  (reads/writes via MCP)    (reads/writes via MCP)
        ↑                            ↑
  Developer 1               Developer 2 ... Developer N
  (git pull → latest)       (git pull → latest)
```

Every developer gets the latest shared memory with `git pull`.
Every session update gets shared with the team via `git push`.

---

## Recommended Folder Structure

```bash
project-root/
├── CLAUDE.md                          ← Entry point for Claude Code
├── AGENTS.md                          ← Entry point for Codex CLI
├── .mcp.json                          ← Claude Code MCP config (committed)
├── .codex/
│   └── config.toml                    ← Codex CLI MCP config (committed)
└── .project-memory/
    ├── memory/                        ← Stable context (rarely changes)
    │   ├── architecture.md
    │   ├── modules.md
    │   ├── conventions.md
    │   └── decisions.md
    ├── tasks/
    │   ├── active/                    ← One file per developer/task (zero conflict)
    │   │   ├── alice-order-refactor.md
    │   │   └── bob-payment-service.md
    │   └── done.md                    ← Append-only log
    └── mcp/
        └── memory.json                ← MCP memory file (managed by agents)
```

**Why split active tasks into separate files?**
With 7+ developers committing simultaneously, a single `active.md` causes frequent merge
conflicts. One file per task means each developer only touches their own file — zero conflicts.

---

## Setup: Claude Code

Create `.mcp.json` at the project root and commit it:

```json
{
  "mcpServers": {
    "memory": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"],
      "env": {
        "MEMORY_FILE_PATH": ".project-memory/mcp/memory.json"
      }
    }
  }
}
```

All developers automatically get this config after `git pull`.

---

## Setup: Codex CLI

Create `.codex/config.toml` at the project root and commit it:

```toml
[mcp_servers.memory]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-memory"]

[mcp_servers.memory.env]
MEMORY_FILE_PATH = ".project-memory/mcp/memory.json"
```

> **Note:** Codex CLI is STDIO-only — it cannot connect to remote HTTP MCP servers directly.
> The file-based approach works perfectly because the server runs locally on each machine,
> pointing to the same file path (which is kept in sync via Git).

---

## Setup: .gitattributes (Critical for Large Teams)

Add to `.gitattributes` at the project root:

```bash
# Append-only files — Git auto-merges without conflict
.project-memory/tasks/done.md merge=union
CLAUDE.md merge=union
AGENTS.md merge=union

# MCP memory file — last-write-wins if conflict occurs
# Agents will reconcile on next session
.project-memory/mcp/memory.json merge=ours
```

`merge=union` — Git automatically combines both versions (ideal for append-only files).
`merge=ours` — On conflict, keep local version; agents reconcile stale entries next session.

---

## Instructions to Add in CLAUDE.md / AGENTS.md

Add this section to both entry point files so agents know what to do:

```markdown
## MCP Memory

This project uses a file-based MCP Memory Server.
Memory file: `.project-memory/mcp/memory.json` (committed to repo).

After every task, the agent MUST:
1. Save architecture decisions and key findings via `memory_add_observations`
2. Create or update `.project-memory/tasks/active/[your-name]-[task-slug].md`
3. If task is done → append a summary to `.project-memory/tasks/done.md`, delete the active file
4. Commit all `.project-memory/` changes together with the code

Active task file naming: `[developer-name]-[task-slug].md`
Examples: `alice-order-refactor.md`, `bob-payment-v2.md`
```

---

## Daily Developer Workflow

```bash
Morning — start of day:
  git pull
  → CLAUDE.md / AGENTS.md updated automatically
  → .project-memory/mcp/memory.json has latest knowledge from team

During work:
  Agent reads/writes to memory.json automatically
  Developer creates/updates .project-memory/tasks/active/[name]-[task].md

End of task:
  Move task summary to .project-memory/tasks/done.md (append)
  Delete the active file
  git add .project-memory/ && git commit && git push
```

---

## Common Problems & Solutions

| Problem | Solution |
| --------- | ---------- |
| `memory.json` conflict when 2 devs push at same time | `merge=ours` in `.gitattributes` — agent reconciles next session |
| Developer forgets to commit memory after work | Add pre-commit hook reminder (see below) |
| `memory.json` grows too large over time | Monthly cleanup: agent summarizes and prunes old entries |
| New developer confused about structure | CLAUDE.md / AGENTS.md contains the full guide |

---

## Optional: Pre-commit Hook Reminder

Save to `.git/hooks/pre-commit` (or distribute via Husky/Lefthook):

```bash
#!/bin/sh
SRC_CHANGED=$(git diff --cached --name-only | grep -c "^app/\|^src/\|^resources/")
MEM_CHANGED=$(git diff --cached --name-only | grep -c "^\.project-memory/")

if [ "$SRC_CHANGED" -gt 2 ] && [ "$MEM_CHANGED" -eq 0 ]; then
  echo "⚠️  You changed source files but haven't updated .project-memory/"
  echo "   Consider updating your active task file or memory."
  echo "   Press Enter to continue or Ctrl+C to cancel."
  read
fi
```

---

## When File-based Memory Is Not Enough

File-based memory works well for teams up to ~10 developers. Consider moving to a hosted
MCP Memory Server when:

- `memory.json` conflicts happen more than once a week despite `merge=ours`
- Team size grows beyond 10+ developers
- You need real-time memory sharing without waiting for git push/pull

See `references/mcp-memory-hosted.md` for hosted setup options.

---

## Git Hook Setup via Makefile

Because `.git/hooks/` is never committed to the repo, Git hooks must be installed on each
developer's machine. The recommended approach is a **Makefile + committed hook script**:

### File Structure

```bash
project-root/
├── Makefile                        ← Committed — developers run `make setup`
└── scripts/
    └── hooks/
        └── pre-commit              ← Committed — the actual hook script
```

### How It Works

1. Hook script lives in `scripts/hooks/pre-commit` — committed to repo, visible to everyone
2. `make setup` copies it to `.git/hooks/pre-commit` and makes it executable
3. Each developer runs `make setup` once after `git clone`
4. AI agent can instruct the developer to run `make setup` as part of onboarding

### Onboarding Instruction in CLAUDE.md / AGENTS.md

Add this to the entry point files so the AI agent knows to remind new developers:

```markdown
## First-time Setup

After cloning the repo, run:
```bash
make setup
```

This installs the pre-commit hook that reminds you to update AI memory when committing code.

```bash

### The Hook Behavior

When a developer commits more than 2 source files without touching `.project-memory/`:

```

⚠️  AI Memory Reminder
   You changed 5 source files but haven't updated .project-memory/

   Consider:

- Updating your active task: .project-memory/tasks/active/[your-name]-[task].md
- Saving decisions to MCP memory via your AI agent

   Press Enter to commit anyway, or Ctrl+C to cancel and update memory first.

```bash

The hook never blocks commits — it only reminds. Developers can always press Enter to proceed,
or use `git commit --no-verify` to skip it entirely.
