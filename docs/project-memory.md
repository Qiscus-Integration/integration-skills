# Skill: project-memory

Role: AI Workflow / Team Enablement

Creates a shared project memory system so Claude Code, Codex, and local developers can reuse the same project context across sessions.

---

## Trigger Phrases

- "create AGENTS.md"
- "create CLAUDE.md"
- "set up project memory"
- "shared AI context"
- "codex memory"
- "claude memory"
- "project handoff for AI"

---

## What It Produces

Depending on the target agent setup, this skill can create:

- `AGENTS.md`
- `CLAUDE.md`
- Shared memory folders such as `.ai-memory/`, `.claude/memory/`, or `.codex/memory/`
- Task handoff files such as `active.md` and `done.md`

---

## Agent Layouts

| Target | Entry files | Memory location |
| ----- | ----------- | --------------- |
| Claude Code only | `CLAUDE.md` | `.claude/memory/` and `.claude/tasks/` |
| Codex only | `AGENTS.md` | `.codex/memory/` and `.codex/tasks/` |
| Mixed team | `CLAUDE.md` + `AGENTS.md` | Shared `.ai-memory/` |

---

## Bundled Resources

| File | Purpose |
| ---- | ------- |
| `skills/project-memory/assets/templates/AGENTS.md.template` | Entry-point template for Codex |
| `skills/project-memory/assets/templates/CLAUDE.md.template` | Entry-point template for Claude Code |
| `skills/project-memory/assets/templates/modules.md.template` | Shared module map template |
| `skills/project-memory/assets/templates/active.md.template` | Active work handoff template |
| `skills/project-memory/references/codex-config.md` | Codex-specific config notes |
| `skills/project-memory/references/mcp-memory.md` | MCP memory server guidance |
| `skills/project-memory/references/multi-agent.md` | Multi-agent collaboration patterns |

These files are not auto-loaded. Open the relevant template or reference when needed.

---

## Recommended Flow

1. Identify the tech stack, project structure, and which AI agents the team uses.
2. Choose the target layout: Claude-only, Codex-only, or shared mixed-agent memory.
3. Generate the entry files and shared memory/task documents from the bundled templates.
4. Make sure the memory folder is committed to the repository and not ignored by `.gitignore`.

---

## Outcome

After setup, every new AI session can bootstrap faster without re-reading the whole codebase, and the whole team can share the same architecture notes, module map, and active task context.
