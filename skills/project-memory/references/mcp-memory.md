# MCP Memory Server

A more advanced alternative to file-based memory: using an **MCP (Model Context Protocol)
Memory Server** that stores a knowledge graph which Claude Code can query automatically.

## When to Use MCP Memory vs File-based Memory?

| Situation | Recommendation |
| ----------- | ---------------- |
| Small team, simple project | File-based (CLAUDE.md) — simpler to set up |
| Want automatic memory without manual updates | MCP Memory Server |
| Memory needs to persist without committing to repo | MCP Memory Server |
| Large project with lots of dynamic context | MCP Memory Server |

## Setting Up MCP Memory Server

### 1. Install via npx

```bash
npx @modelcontextprotocol/server-memory
```

### 2. Configure in Claude Code

Create or edit `.claude/mcp-config.json` at the project root:

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"],
      "env": {
        "MEMORY_FILE_PATH": ".claude/mcp-memory.json"
      }
    }
  }
}
```

> **Tip:** Set `MEMORY_FILE_PATH` to a path inside `.claude/` so it can be committed to the repo
> and shared across the whole team.

### 3. How It Works

The MCP Memory Server stores a **knowledge graph** containing:

- **Entities** — concepts, modules, files, developers
- **Relations** — connections between entities
- **Observations** — facts remembered about each entity

Claude Code can query this memory automatically using the `memory_*` tools provided by MCP.

### 4. Instruct Claude to Update Memory

Add this to `CLAUDE.md`:

```markdown
## MCP Memory

This project uses an MCP Memory Server.
After every task, save important context to memory using the `memory_add_observations` tool.
Examples of what to save:
- New architecture decisions
- Bugs found (even if not yet fixed)
- New modules created
- Changes to conventions
```

## Best of Both Worlds

For serious team projects, use **both**:

```bash
CLAUDE.md               ← Static context, committed to repo, human-readable
MCP Memory Server       ← Dynamic context, automatically updated by AI
```
