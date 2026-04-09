# MCP Memory Server — When It's Worth It

Before reading this guide, consider whether MCP Memory is actually the right tool.
For most teams, plain markdown files in Git are sufficient and easier to maintain.

---

## Honest Assessment

### What MCP Memory does well

MCP Memory stores a **knowledge graph** of entities, relations, and observations that
agents can query semantically. Example:

```bash
Entity: "OrderService"
  Observation: "Handles status transitions"
  Observation: "Must use DB transaction when updating 2 warehouses"
  Relation: "depends_on" → "StockRepository"
```

An agent can ask: *"What do I know about OrderService?"* and get all observations at once,
without having to read entire files.

### What MCP Memory does NOT do well

- **Not human-readable** — `memory.json` is an internal JSON graph. Developers cannot
  review, edit, or resolve conflicts manually. It cannot be reviewed in a PR.
- **Conflict-prone in Git** — `merge=ours` means one developer loses their memory updates
  when two push simultaneously. With 7+ developers this happens often.
- **Not automatic** — Agents only write to MCP memory when explicitly instructed.
  If the instruction in CLAUDE.md is weak, memory silently goes unupdated.
- **Adds maintenance overhead** — Self-hosted servers need uptime, auth, and backups.

### The default setup is enough when

- The project context fits in a well-structured CLAUDE.md + modules.md
- Developers can maintain the `tasks/active/` folder themselves
- The team values human-readable, PR-reviewable memory over semantic query

### MCP Memory adds real value when

- The codebase has hundreds of modules with complex interdependencies
- You need to query relations between entities ("what depends on PaymentService?")
- The team has DevOps capacity to maintain a server
- Context regularly exceeds what CLAUDE.md can hold efficiently

---

## Option A — File-based MCP (memory in Git)

The MCP server runs locally on each developer's machine, all pointing to the same
`memory.json` file synced via Git.

**Pros:** No server, no infrastructure, works with Codex CLI (STDIO-only)
**Cons:** Conflict-prone, not human-readable, `merge=ours` causes data loss on conflict

### Claude Code config — `.claude/mcp.json`

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

### Codex CLI config — `.codex/config.toml`

```toml
[mcp_servers.memory]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-memory"]

[mcp_servers.memory.env]
MEMORY_FILE_PATH = ".project-memory/mcp/memory.json"
```

### .gitattributes addition

```bash
.project-memory/mcp/memory.json merge=ours
```

---

## Option B — Self-hosted MCP Server (recommended if using MCP)

A shared server that all developers connect to. No Git conflicts on memory.json
because the file never goes into the repo.

**Pros:** No conflict, real-time sharing, supports REST query
**Cons:** Requires server, Codex CLI needs a local proxy (STDIO-only limitation)

### Run the server (Docker)

```bash
docker run -d -p 8080:8080 \
  -v /data/project-memory:/data \
  --name mcp-memory \
  doobidoo/mcp-memory-service
```

### Claude Code config — connects via HTTP directly

```bash
claude mcp add --transport http memory http://your-internal-server:8080/mcp
```

### Codex CLI config — needs local proxy (STDIO-only limitation)

```bash
npm install -g mcp-proxy
```

```toml
# .codex/config.toml
[mcp_servers.memory]
command = "mcp-proxy"
args = ["http://your-internal-server:8080/mcp"]
```

---

## Instructions to Add in CLAUDE.md / AGENTS.md (if using MCP)

```markdown
## MCP Memory

This project uses MCP Memory Server for persistent knowledge storage.

After every task, the agent MUST:
1. Save key architecture decisions via `memory_add_observations`
2. Record new module relationships via `memory_create_relations`
3. Update `.project-memory/tasks/active/[your-name]-[task-slug].md`
4. If task done → append summary to `.project-memory/tasks/done.md`, delete active file
5. Commit all `.project-memory/` changes with the code
```

---

## Recommendation Summary

| Situation | Recommendation |
| ----------- | --------------- |
| Team up to 10 developers, normal monolith | Plain markdown files only — skip MCP |
| Large codebase, complex module relationships | Add MCP on top of markdown files |
| No DevOps capacity | File-based MCP (Option A) or skip entirely |
| Have DevOps capacity | Self-hosted MCP (Option B) |
| Using Codex CLI only | File-based MCP (Codex can't use remote HTTP servers) |
| Using Claude Code only | Either option works |
| Using both agents | File-based MCP (simplest for both) or self-hosted + proxy |

---

## Git Hook Setup via Makefile

Because `.git/hooks/` is never committed, Git hooks must be installed per machine.
The recommended approach: commit the script, install via `make setup`.

### File structure

```bash
project-root/
├── Makefile                        ← committed
└── scripts/
    └── hooks/
        └── pre-commit              ← committed (source of truth)
```

`make setup` copies `scripts/hooks/pre-commit` → `.git/hooks/pre-commit` and makes it executable.

Each developer runs `make setup` once after `git clone`. The AI agent reminds new developers
to do this via the First-time Setup section in `.claude/CLAUDE.md` / `.codex/AGENTS.md`.

### Hook behavior

When a developer commits more than 2 source files without touching `.project-memory/`:

```bash
⚠️  AI Memory Reminder
   You changed 5 source files but haven't updated .project-memory/

   Consider:
   - Updating your active task: .project-memory/tasks/active/[your-name]-[task].md
   - Saving decisions to MCP memory via your AI agent

   Press Enter to commit anyway, or Ctrl+C to cancel.
```

The hook never blocks commits — it only reminds. Use `git commit --no-verify` to skip.
