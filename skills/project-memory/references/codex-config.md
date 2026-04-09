# Codex CLI Configuration Tips

Specific guidance for setting up project memory with OpenAI Codex CLI.

## File Size Limit

Codex CLI loads AGENTS.md files up to **32 KiB total** across all loaded files (global + project).
Increase the limit in `.codex/config.toml` if needed:

```toml
# .codex/config.toml
project_doc_max_bytes = 65536   # 64 KiB
```

Keep your main AGENTS.md concise and use pointer files (`See: .project-memory/memory/modules.md`)
for detailed content.

## Global vs Project Scope

Codex reads instruction files in this order (highest precedence first):

```bash
~/.codex/AGENTS.override.md    ← Temporary global override (not committed)
~/.codex/AGENTS.md             ← Your personal defaults (not committed)
        ↓
project-root/AGENTS.md         ← Project-wide rules (committed to repo)
        ↓
subdir/AGENTS.md               ← Subdirectory overrides (committed to repo)
```

Use `~/.codex/AGENTS.md` for personal preferences like:

```markdown
## My Personal Working Agreements
- Always use pnpm instead of npm
- Prefer TypeScript strict mode
- Ask before installing new dependencies
```

## Nested AGENTS.md for Monorepos

For monorepos or large projects with modules that have strict rules, use subdirectory files:

```bash
project-root/
├── AGENTS.md                      ← Global project rules
├── apps/
│   ├── api/
│   │   └── AGENTS.md              ← API-specific rules
│   └── frontend/
│       └── AGENTS.md              ← Frontend-specific rules
└── packages/
    └── payments/
        └── AGENTS.md              ← Payment module strict rules
```

Example subdirectory AGENTS.md:

```markdown
# Payments Service Rules

> These rules override the project-wide AGENTS.md for this subdirectory.

- Use `make test-payments` instead of `npm test`
- NEVER rotate API keys without notifying the security channel
- All Stripe calls must go through `PaymentsService`, never call Stripe SDK directly
```

## Custom Fallback Filenames

If you want to reuse existing documentation files as instruction sources:

```toml
# .codex/config.toml
project_doc_fallback_filenames = ["CONTRIBUTING.md", "DEVELOPMENT.md", ".agents.md"]
```

Codex will look for these filenames in each directory if AGENTS.md is not found.

## MCP Server Configuration

Add MCP servers in `.codex/config.toml`:

```toml
[mcp_servers.memory]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-memory"]

[mcp_servers.memory.env]
MEMORY_FILE_PATH = ".project-memory/mcp-memory.json"
```

Or use the CLI:

```bash
codex mcp add memory npx -y @modelcontextprotocol/server-memory
```

## Session Resume

Codex CLI stores session transcripts locally. Resume a previous session to avoid re-explaining context:

```bash
codex resume           # Pick from recent sessions
codex resume --last    # Jump straight to the last session
```

This is useful for long-running tasks — the agent keeps full context from the previous run.

## Verify Which Files Are Loaded

Check which AGENTS.md files Codex is actually loading in a session:

```bash
codex --cd your/subdir --ask-for-approval never "Show which instruction files are active."
```

Inspect session logs at:

```bash
~/.codex/log/codex-tui.log
```
