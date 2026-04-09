---
name: project-memory
description: >
  Create and manage a project memory system for AI Agents (Claude Code and OpenAI Codex CLI)
  so every new session and every local developer gets project context without re-reading the
  codebase. Generates .claude/CLAUDE.md, .codex/AGENTS.md, and a shared .project-memory/ folder —
  all committed to Git, no extra infrastructure needed. MCP Memory Server is optional and only
  recommended for specific use cases.
  Use this skill when the user wants to create CLAUDE.md, AGENTS.md, or project memory files;
  asks how to make Claude Code or Codex CLI remember context across sessions; wants shared AI
  context for a developer team; or mentions "save tokens", "ai agent memory", "project context",
  "memory.json", "handoff between developers", or "AGENTS.md". Supports solo devs up to large
  teams (7+) with conflict-free Git strategies and an optional Makefile setup for Git hooks.
---

# Project Memory System

This skill creates a **project memory system** stored in the Git repo so that:
- AI Agents (Claude Code, Codex CLI) immediately get context in every new session
- All local developers share the same context via `git pull` / `git push`
- Token usage is minimized — no need to re-read the entire codebase
- No extra infrastructure required — everything lives in the repo

---

## Core Philosophy: Keep It Simple

The most valuable part of this system is **human-readable markdown files** committed to Git.
They work immediately, require no server, survive `git pull`, and can be reviewed in PRs.

**MCP Memory Server is optional** — see the decision guide below before adding it.

---

## Agent Support Matrix

| AI Agent | Entry Point File | Config Location | Auto-loaded? |
|----------|-----------------|-----------------|--------------|
| Claude Code | `.claude/CLAUDE.md` | `.claude/mcp.json` (if using MCP) | ✅ Yes |
| OpenAI Codex CLI | `.codex/AGENTS.md` | `.codex/config.toml` (if using MCP) | ✅ Yes |
| Both (recommended) | Both files in their folders | Both configs, shared `.project-memory/` | ✅ Yes |

---

## Workflow

### Step 1 — Interview the Project

Ask the user (if not already in the conversation):

1. **Tech stack** — language, framework, database, queue, etc.
2. **Project type** — monolith / microservice / API only / fullstack
3. **Team size** — solo / small (2-3) / medium (4-6) / large (7+)
4. **AI agents in use** — Claude Code only / Codex CLI only / both
5. **Main folder structure** — entry points, architecture layers
6. **Key conventions** — naming, patterns, mandatory rules
7. **Active tasks** — any features currently being worked on?

If the user has already described their project, extract from there directly.

---

### Step 2 — Generate the Folder Structure

**Default setup (no MCP — recommended for most teams):**

```
project-root/
├── .claude/
│   └── CLAUDE.md                      ← Entry point for Claude Code (auto-read)
├── .codex/
│   └── AGENTS.md                      ← Entry point for Codex CLI (auto-read)
├── .gitattributes                     ← Merge strategy for memory files
├── Makefile                           ← `make setup` installs Git hooks
├── scripts/
│   └── hooks/
│       └── pre-commit                 ← Hook script (committed, installed by make setup)
└── .project-memory/
    ├── memory/                        ← Stable project context (rarely changes)
    │   ├── architecture.md
    │   ├── modules.md
    │   ├── conventions.md
    │   └── decisions.md
    └── tasks/
        ├── active/                    ← One file per developer/task (zero conflict)
        │   └── .gitkeep
        └── done.md                    ← Append-only completed task log
```

**With MCP Memory (optional — only add if needed):**

```
project-root/
├── .claude/
│   ├── CLAUDE.md
│   └── mcp.json                       ← Claude Code MCP config
├── .codex/
│   ├── AGENTS.md
│   └── config.toml                    ← Codex CLI MCP config
└── .project-memory/
    ├── memory/
    ├── tasks/
    └── mcp/
        └── memory.json                ← MCP knowledge graph (agent-managed)
```

> Generate the MCP config files only if the user explicitly wants MCP Memory.
> For most teams, the default setup without MCP is sufficient and easier to maintain.

---

### Step 3 — Generate All Files

Use the templates in `assets/templates/` and fill in project-specific info.

**Always generate (default setup):**

| Template | Output file | Notes |
|----------|-------------|-------|
| `CLAUDE.md.template` | `.claude/CLAUDE.md` | Entry point for Claude Code |
| `AGENTS.md.template` | `.codex/AGENTS.md` | Entry point for Codex CLI |
| `gitattributes.template` | `.gitattributes` | Anti-conflict merge strategy |
| `Makefile.template` | `Makefile` | `make setup` installs Git hooks |
| `pre-commit.template` | `scripts/hooks/pre-commit` | Hook script committed to repo |
| `modules.md.template` | `.project-memory/memory/modules.md` | Module/domain map |
| `active-task.md.template` | `.project-memory/tasks/active/[name]-[task].md` | Per-developer task |
| `done.md.template` | `.project-memory/tasks/done.md` | Append-only task log |

**Only generate if user wants MCP Memory:**

| Template | Output file | Notes |
|----------|-------------|-------|
| `mcp.json.template` | `.claude/mcp.json` | Claude Code MCP config |
| `codex-config.toml.template` | `.codex/config.toml` | Codex CLI MCP config |

**Priority order:**
1. `.claude/CLAUDE.md` and/or `.codex/AGENTS.md` — required, most important
2. `.gitattributes` — critical for teams with 4+ developers
3. `Makefile` + `scripts/hooks/pre-commit` — recommended for teams with 4+ developers
4. `.project-memory/memory/modules.md` — strongly recommended for monoliths
5. MCP config files — only if user explicitly needs MCP Memory

---

### Step 4 — Explain the Daily Workflow

Always explain this to the user so the team understands how to use the system:

```
Morning — start of day:
  git pull
  → .claude/CLAUDE.md / .codex/AGENTS.md updated with latest team context
  → .project-memory/ has latest task status and architecture notes from team

During work:
  Developer creates/updates .project-memory/tasks/active/[name]-[task].md
  Agent reads memory files automatically at session start

End of task:
  Append one-line summary to .project-memory/tasks/done.md
  Delete the active task file
  git add .project-memory/ && git commit && git push
```

---

### Step 5 — Add First-time Setup Instruction

Add this to both `.claude/CLAUDE.md` and `.codex/AGENTS.md`:

```markdown
## First-time Setup

After cloning the repo, run:
```bash
make setup
```
This installs the pre-commit hook that reminds you to update AI memory when committing code.
```

---

### Step 6 — Verify .gitignore

Make sure `.project-memory/`, `.claude/`, and `.codex/` are NOT in `.gitignore`.
These must be committed so the whole team shares the same setup.

For local-only overrides, use `.project-memory/local/` and add it to `.gitignore`.

---

## Should You Use MCP Memory?

Ask these questions before adding MCP Memory:

| Question | If YES | If NO |
|----------|--------|-------|
| Is your project context too large for a single CLAUDE.md? | Consider MCP | Skip MCP |
| Do you need semantic query across hundreds of entities? | Consider MCP | Skip MCP |
| Do you have someone to maintain a server? | Self-hosted MCP | Skip MCP |
| Is your team okay with non-human-readable memory files? | File-based MCP | Skip MCP |
| Are merge conflicts on memory.json acceptable? | File-based MCP | Skip MCP |

**For most teams (including large ones): skip MCP. The markdown files are enough.**

See `references/mcp-memory.md` for full MCP setup guide if needed.

---

## Key Design Decisions

### Why one file per active task?

With 7+ developers committing simultaneously, a single `active.md` causes frequent merge
conflicts. One file per task means each developer only touches their own file — zero conflicts.

### Why `merge=union` on done.md?

`done.md` is append-only. When two developers push simultaneously, Git's union merge
automatically combines both versions without conflict or data loss.

### Why entry point files in `.claude/` and `.codex/`?

Keeps all agent-specific files in their respective config folders. Claude Code reads
`.claude/CLAUDE.md` automatically; Codex CLI reads `.codex/AGENTS.md` automatically.
Separation makes it clear which files belong to which agent.

### Why commit the pre-commit hook script (not the hook itself)?

`.git/hooks/` is never committed to Git. By committing `scripts/hooks/pre-commit` and
using `make setup` to install it, the hook is version-controlled and shared — but each
developer installs it once on their own machine.

---

## Scaling Guidance

| Team Size | Recommended Setup |
|-----------|------------------|
| 1–3 developers | Default setup, single `active.md` is fine |
| 4–6 developers | Split `active/` per developer, add `.gitattributes` + Makefile |
| 7+ developers | Full default setup as above |
| Any size needing semantic memory | Add MCP Memory on top of default setup |

---

## Further References

- `references/mcp-memory.md` — When MCP Memory is worth it, full setup guide
- `references/codex-config.md` — Codex CLI-specific config (nested AGENTS.md, monorepos)
- `references/multi-agent.md` — Patterns for teams with many parallel AI Agents
- `assets/templates/` — All ready-to-use templates