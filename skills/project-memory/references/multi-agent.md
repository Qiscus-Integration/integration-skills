# Patterns for Teams with Multiple AI Agents

A guide for teams where multiple developers are running AI Agents in parallel on their local machines.

## Core Problems

When several AI Agents work in parallel on different branches:

1. Memory conflicts — two agents update the same file simultaneously
2. Stale context — an agent reads info that is already outdated
3. Duplicated work — two agents tackle the same task

## Recommended Patterns

### Pattern 1: Branch-based Memory (Simplest)

Each developer/branch maintains its own memory that gets merged on PR:

```bash
main branch:
  .claude/CLAUDE.md          ← Shared, stable context
  .claude/memory/            ← Shared, stable context

feature/order-v2 branch:
  .claude/tasks/active.md    ← Only updated on this branch
```

**Rule:** When merging a PR, update `done.md` and remove the task from `active.md`.

---

### Pattern 2: Developer-scoped Active Tasks

Split `active.md` per developer to avoid conflicts:

```bas
.claude/tasks/
├── active-alice.md      ← Owned by @alice
├── active-bob.md        ← Owned by @bob
└── done.md              ← Shared, updated when tasks complete
```

Add to `CLAUDE.md`:

```markdown
## Active Tasks
See each developer's task file:
- @alice: `.claude/tasks/active-alice.md`
- @bob: `.claude/tasks/active-bob.md`
```

---

### Pattern 3: Conflict-free with Timestamps

For `done.md` that gets edited frequently by multiple people, use an append-only format:

```markdown
<!-- done.md — never edit old lines, only append at the bottom -->

[2025-04-08 10:30] @alice — Done: Refactored OrderService, extracted ShippingService. PR #142.
[2025-04-09 14:00] @bob — Done: Added CSV export feature. PR #143.
```

Append-only format minimizes merge conflicts.

---

## Git Workflow Recommendations

### .gitattributes for Memory Files

Add to `.gitattributes` to make merge conflicts easier to resolve:

```bash
.claude/tasks/done.md merge=union
.claude/CLAUDE.md merge=union
```

`merge=union` automatically combines both versions without a conflict (ideal for append-only files).

### Pre-commit Hook (Optional)

Remind developers to update memory before committing:

```bash
#!/bin/sh
# .git/hooks/pre-commit

# Check if src/ changed but .claude/ did not
SRC_CHANGED=$(git diff --cached --name-only | grep -c "^app/\|^src/\|^resources/")
MEMORY_CHANGED=$(git diff --cached --name-only | grep -c "^\.claude/")

if [ "$SRC_CHANGED" -gt 3 ] && [ "$MEMORY_CHANGED" -eq 0 ]; then
  echo "⚠️  Reminder: You changed many source files but haven't updated .claude/ memory."
  echo "   Consider updating CLAUDE.md or .claude/tasks/active.md"
  echo "   (press Enter to continue, or Ctrl+C to cancel)"
  read
fi
```

---

## Recommendation by Team Size

| Team Size | Recommendation |
| ----------- | ---------------- |
| 1–2 developers | Pattern 1 (branch-based) — simple enough |
| 3–5 developers | Pattern 2 (developer-scoped tasks) |
| 5+ developers | Pattern 3 + MCP Memory Server |
