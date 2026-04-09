---
name: project-memory
description: >
  Create and manage a project memory system for AI Agents (Claude Code and OpenAI Codex CLI)
  so every new session and every local developer gets project context without re-reading the
  codebase. Generates CLAUDE.md, AGENTS.md, file-based MCP Memory Server config, and a shared
  .project-memory/ folder — all committed to Git, no extra infrastructure needed.
  Use this skill when the user wants to create CLAUDE.md, AGENTS.md, MCP memory setup, or
  project memory files; asks how to make Claude Code or Codex CLI remember context across
  sessions; wants shared AI context for a developer team; or mentions "save tokens",
  "ai agent memory", "MCP memory", "project context", "memory.json", or "handoff between
  developers". Supports solo devs up to large teams (7+) with conflict-free Git strategies.
---

# AI Project Memory System

This skill creates a **project memory system** stored in the Git repo so that:
- AI Agents (Claude Code, Codex CLI) immediately get context in every new session
- All local developers share the same memory via `git pull` / `git push`
- Token usage is minimized — no need to re-read the entire codebase
- No extra infrastructure required — everything lives in the repo

---

## Agent Support Matrix

| AI Agent | Entry Point File | MCP Config | Auto-loaded? |
|----------|-----------------|------------|--------------|
| Claude Code | `CLAUDE.md` | `.mcp.json` | ✅ Yes |
| OpenAI Codex CLI | `AGENTS.md` | `.codex/config.toml` | ✅ Yes |
| Both (recommended) | `CLAUDE.md` + `AGENTS.md` | Both files, shared `.project-memory/` | ✅ Yes |

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

### Step 2 — Generate the Full Folder Structure

Create this structure at the project root:

```
project-root/
├── CLAUDE.md                          ← Entry point for Claude Code
├── AGENTS.md                          ← Entry point for Codex CLI
├── .mcp.json                          ← Claude Code MCP config (committed)
├── .gitattributes                     ← Merge strategy for memory files
├── Makefile                           ← `make setup` installs Git hooks
├── scripts/
│   └── hooks/
│       └── pre-commit                 ← Hook script (committed, copied by make setup)
├── .codex/
│   └── config.toml                    ← Codex CLI MCP config (committed)
└── .project-memory/
    ├── memory/                        ← Stable project context
    │   ├── architecture.md
    │   ├── modules.md
    │   ├── conventions.md
    │   └── decisions.md
    ├── tasks/
    │   ├── active/                    ← One file per developer/task (zero conflict)
    │   │   └── .gitkeep
    │   └── done.md                    ← Append-only completed task log
    └── mcp/
        └── memory.json                ← MCP knowledge graph (managed by agents)
```

> If only one agent is used, skip the entry file and config for the other.
> The `.project-memory/` folder is always shared regardless.

---

### Step 3 — Generate All Files

Use the templates in `assets/templates/` and fill in project-specific info.

| Template | Output file | Notes |
|----------|-------------|-------|
| `CLAUDE.md.template` | `CLAUDE.md` | Entry point for Claude Code |
| `AGENTS.md.template` | `AGENTS.md` | Entry point for Codex CLI |
| `mcp.json.template` | `.mcp.json` | Claude Code MCP config |
| `codex-config.toml.template` | `.codex/config.toml` | Codex CLI MCP config |
| `gitattributes.template` | `.gitattributes` | Anti-conflict merge strategy |
| `Makefile.template` | `Makefile` | `make setup` installs Git hooks |
| `pre-commit.template` | `scripts/hooks/pre-commit` | Hook script committed to repo |
| `modules.md.template` | `.project-memory/memory/modules.md` | Module/domain map |
| `active-task.md.template` | `.project-memory/tasks/active/[name]-[task].md` | Per-developer task |
| `done.md.template` | `.project-memory/tasks/done.md` | Append-only task log |

**Priority order:**
1. `CLAUDE.md` and/or `AGENTS.md` — required, most important
2. `.mcp.json` and/or `.codex/config.toml` — required for MCP memory
3. `.gitattributes` — critical for teams with 4+ developers
4. `Makefile` + `scripts/hooks/pre-commit` — recommended for teams with 4+ developers
5. `.project-memory/memory/modules.md` — strongly recommended for monoliths
6. Other memory files as needed

---

### Step 4 — Explain the Daily Workflow

Always explain this to the user so the team understands how to use the system:

```
Morning — start of day:
  git pull
  → CLAUDE.md / AGENTS.md updated with latest team context
  → .project-memory/mcp/memory.json has latest knowledge from all agents

During work:
  Agent reads/writes to memory.json automatically (via MCP tools)
  Developer creates/updates .project-memory/tasks/active/[name]-[task].md

End of task:
  Append summary to .project-memory/tasks/done.md
  Delete the active task file
  git add .project-memory/ && git commit && git push
```

---

### Step 5 — Add First-time Setup Instruction

Add this to both `CLAUDE.md` and `AGENTS.md` so the AI agent reminds new developers:

```markdown
## First-time Setup

After cloning the repo, run:

make setup
```
This installs the pre-commit hook that reminds you to update AI memory when committing code.

---

### Step 6 — Verify .gitignore

Make sure `.project-memory/` and `.mcp.json` and `.codex/config.toml` are NOT in `.gitignore`.
These files must be committed so the whole team shares the same setup.

If there are local-only overrides, use `.project-memory/local/` and add it to `.gitignore`.

---

## Key Design Decisions

### Why one file per active task?

With 7+ developers committing simultaneously, a single `active.md` causes frequent merge
conflicts. One file per task means each developer only touches their own file — zero conflicts.

### Why `merge=union` on done.md?

`done.md` is append-only. When two developers push simultaneously, Git's union merge
automatically combines both versions without conflict or data loss.

### Why `merge=ours` on memory.json?

`memory.json` is a structured JSON file managed by the MCP server. Standard Git merges
corrupt the JSON structure. With `merge=ours`, Git keeps the local version on conflict,
and the agent reconciles stale entries automatically in the next session.

### Why commit MCP config files?

Committing `.mcp.json` and `.codex/config.toml` means every developer — including new
team members — gets the correct MCP setup automatically after `git clone` or `git pull`.
No manual setup documentation needed.

---

## Codex CLI Note: STDIO-only Limitation

Codex CLI cannot connect to remote HTTP MCP servers — it only supports local STDIO transport.
The file-based approach works perfectly because:
- The MCP server runs locally on each developer's machine
- All developers point to the same `.project-memory/mcp/memory.json` path
- Git keeps that file in sync across the team

This is **not** a limitation for the file-based approach.

---

## Scaling Guidance

| Team Size | Recommended Setup |
|-----------|------------------|
| 1–3 developers | Single `active.md` is fine, skip `active/` folder |
| 4–6 developers | Split `active/` per developer, add `.gitattributes` |
| 7+ developers | Full setup as described above, add pre-commit hook |
| 10+ developers | Consider hosted MCP server — see `references/mcp-memory.md` |

---

## Further References

- `references/mcp-memory.md` — Full file-based MCP setup guide with conflict strategies
- `references/codex-config.md` — Codex CLI-specific config (nested AGENTS.md, monorepos)
- `references/multi-agent.md` — Patterns for teams with many parallel AI Agents
- `assets/templates/` — All ready-to-use templates