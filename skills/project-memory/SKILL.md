---
name: project-memory
description: >
  Create and manage a project memory system for AI Agents so that every new session and every
  local developer can immediately get project context without re-reading the entire codebase.
  Supports both Claude Code (CLAUDE.md) and OpenAI Codex CLI (AGENTS.md) — and can generate
  both simultaneously for teams using mixed agents.
  Use this skill when: the user wants to create CLAUDE.md, AGENTS.md, or project memory files;
  the user asks how to make Claude Code or Codex CLI "remember" project context in a new session;
  the user wants shared AI context for a developer team; the user mentions "save tokens",
  "context window", "ai agent memory", "claude memory", "codex memory", "AGENTS.md",
  "project context", or "handoff between developers". Produces a complete memory folder structure
  with files ready to be committed to the repo and shared across the entire team.
---

# AI Project Memory System

This skill creates a **project memory system** stored in the repo so that:
- AI Agents (Claude Code, Codex CLI, etc.) immediately get context in every new session
- All local developers share the same context
- Token usage is minimized (no need to re-read the entire codebase)

---

## Agent Support Matrix

| AI Agent | Entry Point File | Config Location | Auto-loaded? |
|----------|-----------------|-----------------|--------------|
| Claude Code | `CLAUDE.md` | `.claude/` folder or project root | ✅ Yes |
| OpenAI Codex CLI | `AGENTS.md` | `.codex/` folder or project root | ✅ Yes |
| Both (recommended) | `CLAUDE.md` + `AGENTS.md` | Shared `memory/` & `tasks/` folders | ✅ Yes |

> When a team uses both agents, generate both entry point files pointing to the same shared
> `memory/` and `tasks/` folders — no duplication needed.

---

## Workflow

### Step 1 — Interview the Project

Ask the user (if not already covered in the conversation):

1. **Tech stack** — language, framework, database, queue, etc.
2. **Project type** — monolith / microservice / API only / fullstack
3. **Team size** — solo / small team / large team
4. **AI agents in use** — Claude Code only / Codex CLI only / both
5. **Main folder structure** — entry points, architecture layers in use
6. **Key conventions** — naming, patterns, rules that must be followed
7. **Active tasks** — any features currently being worked on?

If the user has already described their project in the conversation, extract from there directly.

---

### Step 2 — Determine Agent Target & Create Folder Structure

**For Claude Code only:**
```
project-root/
├── CLAUDE.md                  ← Auto-read by Claude Code (can also go in .claude/)
├── .claude/
│   └── memory/
│       ├── architecture.md
│       ├── modules.md
│       ├── conventions.md
│       └── decisions.md
└── .claude/tasks/
    ├── active.md
    └── done.md
```

**For Codex CLI only:**
```
project-root/
├── AGENTS.md                  ← Auto-read by Codex CLI (can also go in .codex/)
├── .codex/
│   └── memory/
│       ├── architecture.md
│       ├── modules.md
│       └── conventions.md
└── .codex/tasks/
    ├── active.md
    └── done.md
```

**For both agents (recommended shared layout):**
```
project-root/
├── CLAUDE.md                  ← Entry point for Claude Code
├── AGENTS.md                  ← Entry point for Codex CLI
└── .ai-memory/                ← Shared folder for both agents
    ├── memory/
    │   ├── architecture.md
    │   ├── modules.md
    │   ├── conventions.md
    │   └── decisions.md
    └── tasks/
        ├── active.md
        └── done.md
```

Both `CLAUDE.md` and `AGENTS.md` simply point to the same `.ai-memory/` folder.

---

### Step 3 — Generate Memory Files

Read the templates in `assets/templates/` and adapt them to the user's project info.

| Template | Purpose |
|----------|---------|
| `CLAUDE.md.template` | Entry point for Claude Code |
| `AGENTS.md.template` | Entry point for OpenAI Codex CLI |
| `modules.md.template` | Module/domain map with file paths |
| `active.md.template` | Task handoff between sessions/developers |

**Priority order for files to create:**
1. Entry point file(s) — `CLAUDE.md` and/or `AGENTS.md` — required, most important
2. `memory/modules.md` — strongly recommended for monoliths
3. `tasks/active.md` — important if there are tasks currently in progress
4. Other memory files as needed

---

### Step 4 — Add the Update Workflow

At the end of both entry point files, always include:

```markdown
## Instructions for AI Agent

After completing every task:
1. Update the "Recent Changes" section in this file
2. If there are architecture changes → update `memory/architecture.md`
3. If there are new modules → update `memory/modules.md`
4. If a task is unfinished → record progress in `tasks/active.md`
5. Commit all memory changes together with the code
```

---

### Step 5 — .gitignore Check

Make sure the memory folders are **NOT** in `.gitignore` — they must be committed so the
whole team can share them.

For sensitive local overrides, use:
- `.claude/local/` (Claude Code) → add to `.gitignore`
- `~/.codex/AGENTS.md` (Codex CLI global) → stored on each developer's machine, not in repo

---

## Key Differences: Claude Code vs Codex CLI

| Feature | Claude Code | Codex CLI |
|---------|-------------|-----------|
| Entry file | `CLAUDE.md` | `AGENTS.md` |
| Config folder | `.claude/` | `.codex/` |
| Global config | Not applicable | `~/.codex/AGENTS.md` |
| Override file | Not applicable | `AGENTS.override.md` |
| Max file size | No hard limit | 32 KiB default (configurable) |
| Nested loading | Single file | Walks directory tree from root to cwd |
| MCP support | ✅ Yes | ✅ Yes (via `config.toml`) |

### Codex CLI Directory Walking (important!)

Codex reads AGENTS.md files starting from the global `~/.codex/` scope, then walks down from the project root to the current working directory, loading each AGENTS.md it finds. This means you can have per-subdirectory overrides:

```
project-root/
├── AGENTS.md              ← Loaded for all work
└── services/
    └── payments/
        └── AGENTS.md      ← Loaded only when working inside payments/
```

Use this for monorepos or projects with modules that have their own strict rules.

---

## Principles for Good Memory Design

### Entry point files (CLAUDE.md / AGENTS.md) should:
- **Be concise but sufficient** — target 50–150 lines (Codex CLI: stay under 32 KiB total)
- **Contain pointers** to detail files, not the details themselves
- **Update "Recent Changes"** after every significant change
- **Avoid internal jargon** known only to one person

### modules.md should:
- Map every domain/feature to concrete file paths
- Record key rules per module (not every rule)
- Update whenever a new module is added or a major refactor happens

### active.md should:
- Clearly state who is working on it and which branch
- Have an actionable progress checklist
- Record "gotchas" or technical decisions made mid-task

---

## Token Savings Tips

| Strategy | Savings |
|----------|---------|
| Concise entry file with pointers to detail files | High |
| Module map with concrete file paths | High |
| Recent changes only (not full history) | Medium |
| Active task with progress checklist | Medium |
| Avoid duplicating info across files | Medium |
| Codex: use nested AGENTS.md for large monorepos | High |

---

## Further References

- `references/mcp-memory.md` — Set up MCP Memory Server for automatic memory (works for both agents)
- `references/multi-agent.md` — Patterns for teams with many parallel AI Agents
- `references/codex-config.md` — Codex CLI-specific config tips (`config.toml`, global AGENTS.md)
- `assets/templates/` — Ready-to-use templates for all memory files