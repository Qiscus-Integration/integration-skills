---
name: self-assessment
description: Self-assessment of the user's AI agent ecosystem — 15 parameters (scale 1-10) + Aurora Charter Activation Progress (scale 1-5). Covers all active AI tools (Claude Code, Codex, Cursor, Copilot, Gemini, etc.).
user-invocable: true
---

# Self-Assessment — AI Agent Ecosystem

Perform a comprehensive assessment of the user's **entire AI agent ecosystem** — not just one tool. This covers all active AI agents: Claude Code, Codex (OpenAI), Cursor, GitHub Copilot, Gemini CLI, Continue.dev, Aider, and others. Assessment is holistic: evidence from any tool contributes to the same scoring parameters.

> **Output language:** All report content, labels, justifications, and recommendations MUST be written in **Bahasa Indonesia**. This instruction file is in English; the generated reports are in Indonesian.

## Step 0: Identify the User

Before starting, identify the user:

1. Look for **username** in memory files (`user_role.md`, `user_identity.md`) or via `git config --global user.name`
2. Look for **team role** in memory files (`user_role.md`)
3. **If either is missing** → ask the user directly using AskUserQuestion
4. Role matters for scoring context — a Software Architect's usage pattern differs from a Developer, QA, or PM

## Input

No arguments required. This skill automatically gathers data from multiple sources.

## Adaptive Learning

This skill may learn from previous assessments, but **only in a controlled way**.

Before assessment:
1. Read `ADAPTIVE_LEARNING.md` if it exists.
2. Use its contents to:
   - Add relevant candidate paths to the discovery list,
   - Remember repositories that have proven important,
   - Avoid false positives already clarified by the user,
   - Adjust the priority order for evidence gathering.

After assessment:
1. Update `ADAPTIVE_LEARNING.md` with validated findings only.
2. Only store operational learnings: important paths, key repos, confirmed active AI tools, identity aliases, and useful clarification patterns.
3. **Do not** change the scoring rubric, level definitions, or core assessment rules automatically.
4. **Do not** store sensitive strategic thinking or confidential information.
5. If a new learning is uncertain, store it under `Candidates`, not `Validated`.

## Core Principles

1. **Verify activity ownership** — Before assessing git commits or any activity, MUST verify it belongs to the user's account (`git config --global user.name` / `user.email`). Do not assess other people's activity.
2. **Assess the ecosystem, not a single tool** — Evidence from any tool (Claude, Codex, Cursor, etc.) contributes to the same parameter. Do not separate scores per tool.
3. **Deliberate on critical findings** — If a critical finding (positive or negative) is found, MUST ask the user ONE BY ONE using AskUserQuestion. Format: "Was [finding] intentional? If yes, explain why it was designed that way. If not, just say no." If the user answers "yes", STILL ask for the reason.
4. **Invalid critical findings are excluded** — If a critical finding proves to be a false positive during deliberation, it is NOT included in the assessment document.
5. **Use multi-agent** to speed up data collection from multiple sources.
6. **All report output in Bahasa Indonesia** — instructions are in English; reports are in Indonesian.
7. **Strategic thinking is not written in the document** — If a pattern of strategic thinking is found (e.g., career/position reasoning), DO NOT write it in the report. Only share it verbally with the user after analysis is complete.

## Check Previous Assessments

Check **silently** (do not announce to the user) whether a previous assessment exists at `~/.claude/skills/self-assessment/assessment-*.md`.
- **If found:** read the latest assessment and add a **Perbandingan dengan Assessment Sebelumnya** section at the end of the report (delta per parameter, Aurora Charter level change, highlights of improved/worsened/stagnant areas). Inform the user that a comparison will be included.
- **If not found:** proceed without mentioning it — mark as baseline in the final report only.

## Platform Detection

Run platform detection **before** collecting data. Adapt all commands and paths based on the detected platform.

### Step 1 — Determine the Actual Platform

```bash
# Step 1: try uname (available on Linux, macOS, Git Bash, WSL)
uname -s 2>/dev/null || echo "NO_UNAME"

# Step 2: if Linux → check whether this is WSL
cat /proc/version 2>/dev/null | grep -i microsoft
# If output contains "Microsoft" → this is WSL, not native Linux

# Step 3: if no uname → likely Windows PowerShell or CMD
# PowerShell: $env:OS   → output: Windows_NT
# CMD: echo %OS%
```

| `uname -s` output | Additional check | Platform |
|-------------------|-----------------|---------|
| `Darwin` | — | macOS |
| `Linux` | `/proc/version` does NOT contain "Microsoft" | Linux Native |
| `Linux` | `/proc/version` contains "Microsoft" | WSL (Windows Subsystem for Linux) |
| `MINGW64_NT-*` or `MSYS_NT-*` | — | Windows Git Bash |
| `NO_UNAME` | `$env:OS` = `Windows_NT` | Windows PowerShell |
| `NO_UNAME` | `%OS%` = `Windows_NT` | Windows CMD |

### Step 2 — Resolve Home Directory & Key Paths

| Platform | Home Directory | AI Config Root | Downloads |
|----------|---------------|---------------|-----------|
| macOS | `$HOME` → `/Users/<username>` | `~/` | `~/Downloads/` |
| Linux Native | `$HOME` → `/home/<username>` | `~/` | `~/Downloads/` (may not exist on servers) |
| WSL | `$HOME` → `/home/<username>` (Linux home) | `~/` | `~/Downloads/` OR `/mnt/c/Users/<username>/Downloads/` |
| Windows Git Bash | `$HOME` → `/c/Users/<username>` | `~/` | `~/Downloads/` |
| Windows PowerShell | `$env:USERPROFILE` → `C:\Users\<username>` | `$env:USERPROFILE\` | `$env:USERPROFILE\Downloads\` |

**For WSL:** AI tools installed on the Windows side will be under `/mnt/c/Users/<username>/`. Always check both sides for each tool.

### Step 3 — Cross-Platform Command Reference

| Operation | macOS (BSD) | Linux / WSL / Git Bash (GNU) | Windows PowerShell |
|-----------|-------------|-----------------------------|--------------------|
| File timestamp | `stat -f '%m %N' <file>` | `stat --format='%Y %n' <file>` | `(Get-Item '<file>').LastWriteTime` |
| Find + timestamp | `find <dir> -name '*.jsonl' -exec stat -f '%m %N' {} \;` | `find <dir> -name '*.jsonl' -printf '%T+ %p\n'` | `Get-ChildItem -Recurse -Filter '*.jsonl' \| Select-Object LastWriteTime,FullName` |
| List dirs | `ls -d ~/*/` | `ls -d ~/*/` | `Get-ChildItem $HOME -Directory` |
| File size | `du -sh <file>` | `du -sh <file>` | `(Get-Item '<file>').Length / 1MB` |
| Line count | `wc -l <file>` | `wc -l <file>` | `(Get-Content '<file>').Count` |
| List subdirs | `find ~ -maxdepth 1 -type d` | `find ~ -maxdepth 1 -type d` | `Get-ChildItem $HOME -Directory -Depth 0` |

### Step 4 — Git Repo Discovery per Platform

| Platform | Search root | Discovery command |
|----------|------------|-------------------|
| macOS | `~/` | `find ~ -maxdepth 2 -name '.git' -type d 2>/dev/null` |
| Linux / WSL | `~/` | `find ~ -maxdepth 2 -name '.git' -type d 2>/dev/null` |
| WSL (Windows repos) | `/mnt/c/Users/<username>/` | `find /mnt/c/Users/$(whoami) -maxdepth 3 -name '.git' -type d 2>/dev/null` |
| Git Bash | `/c/Users/<username>/` | `find /c/$(whoami) -maxdepth 3 -name '.git' -type d 2>/dev/null` |
| Windows PowerShell | `$HOME` | `Get-ChildItem $HOME -Recurse -Depth 2 -Filter '.git' -Force -Directory` |

**WSL note:** If the user works in Windows with repos under `C:\` but uses WSL as the shell, check BOTH locations: `~/` (Linux home) and `/mnt/c/Users/<username>/` (Windows home).

### Step 5 — AI Tool Path Resolution per Platform

Tools installed on the Windows side (when running WSL) will be under `/mnt/c/Users/<username>/`. Use Read or ls to check which paths actually exist before collecting data.

| Platform | Path prefix for AI tools |
|----------|--------------------------|
| macOS / Linux Native | `~/.<toolname>/` |
| WSL | `~/.<toolname>/` (if installed in WSL) OR `/mnt/c/Users/<username>/.<toolname>/` (if installed in Windows) |
| Windows Git Bash | `~/.<toolname>/` = `/c/Users/<username>/.<toolname>/` |
| Windows PowerShell | `$env:USERPROFILE\.<toolname>\` or `$env:APPDATA\<toolname>\` (varies per tool) |

## AI Portfolio Discovery

**Mandatory step before data collection.** Detect all AI agents installed or used by the user. Use the path table below for each tool. If a path does not exist, the tool is considered inactive. List all active tools as the **AI Portfolio** in the report.

### AI Agent Path Reference

| AI Agent | Category | Config Path (Unix/macOS/WSL) | Config Path (Windows) | Key Files |
|----------|----------|-----------------------------|-----------------------|-----------|
| **Claude Code** | Agentic CLI | `~/.claude/` | `%USERPROFILE%\.claude\` | `settings.json`, `skills/`, `projects/`, `scripts/` |
| **Codex (OpenAI)** | Agentic CLI | `~/.codex/` | `%USERPROFILE%\.codex\` | `config.toml`, `AGENTS.md`, `rules/`, `plugins/` |
| **Gemini CLI** | Agentic CLI | `~/.gemini/` | `%USERPROFILE%\.gemini\` | `settings.json`, `GEMINI.md` |
| **Aider** | Agentic CLI | `~/.aider/` | `%USERPROFILE%\.aider\` | `.aider.conf.yml`, `.aider.model.settings.yml` |
| **Amazon Q CLI** | Agentic CLI | `~/.aws/amazonq/` | `%USERPROFILE%\.aws\amazonq\` | `profiles/`, telemetry |
| **Cursor** | IDE | `~/.cursor/` or `~/.config/Cursor/` | `%APPDATA%\Cursor\` | `settings.json`, `.cursorrules` in repos |
| **GitHub Copilot** | IDE Extension | `~/.config/github-copilot/` | `%LOCALAPPDATA%\github-copilot\` | `hosts.json`, `apps.json` |
| **Continue.dev** | IDE Extension | `~/.continue/` | `%USERPROFILE%\.continue\` | `config.json`, `config.ts` |
| **Codeium / Windsurf** | IDE / Extension | `~/.codeium/` or `~/.windsurf/` | `%USERPROFILE%\.codeium\` | `config/`, `auth/` |
| **Tabnine** | IDE Extension | `~/.tabnine/` | `%USERPROFILE%\.tabnine\` | `tabnine_config.json` |
| **Supermaven** | IDE Extension | `~/.supermaven/` | `%USERPROFILE%\.supermaven\` | config files |
| **Zed AI** | IDE | `~/.config/zed/` | — | `settings.json` (check `assistant` key) |
| **JetBrains AI** | IDE | `~/.config/JetBrains/` | `%APPDATA%\JetBrains\` | `ai-assistant.xml` in IDE config dirs |

**Quick parallel check:** Use Read or ls to check candidate paths in parallel. Do not read config files yet — just verify whether the directory or key file exists.

**Project-level config to check across repos:**
- `.cursorrules` — Cursor rule file
- `.github/copilot-instructions.md` — GitHub Copilot instructions
- `CLAUDE.md` — Claude Code project instructions
- `AGENTS.md` — Codex / generic agent instructions
- `GEMINI.md` — Gemini CLI instructions
- `.aider.conf.yml` — Aider config per project
- `.continue/config.json` — Continue.dev per project

### How to Report the AI Portfolio

In the report, display a table like this (in Indonesian):

```
| Tool | Status | Bukti |
|------|--------|-------|
| Claude Code | Aktif | ~/.claude/ (settings.json, 5 skills, hooks) |
| Codex | Aktif | ~/.codex/ (config.toml, 89 sessions, 30+ rules) |
| Cursor | Tidak ditemukan | — |
| GitHub Copilot | Aktif | ~/.config/github-copilot/hosts.json |
| Gemini CLI | Tidak ditemukan | — |
```

## Data Sources

Collect data from the following sources in parallel. All data is combined into a single score — do not separate per tool.

### 0. Home Root Sweep

MUST inventory all directories one level below the user's home before concluding scope of assessment. Goal: detect org repos, reusable public repos, experiment folders (`learn/`), and documentation/skill repos.

Use additional candidates from `ADAPTIVE_LEARNING.md` as initial priorities if available.

### 1. Git History

Search for AI co-authored commits across all git repos. **Verify author = user's account.**

Co-author patterns to search for:
- `Co-Authored-By: Claude` — Claude Code
- `Co-Authored-By: GitHub Copilot` — GitHub Copilot
- `Co-Authored-By: cursor` — Cursor AI
- `Generated with [Claude Code]` in commit body
- `Co-authored-by: assistant` — Codex / generic agent

Search locations:
- **Windows:** subdirectories under root drive (`/c/*/`)
- **macOS/Linux:** subdirectories under home (`~/*/`) or common paths (`/opt/`, `/var/www/`)
- Start from all direct child directories of the user's home, descend only into relevant candidates
- Do not recurse more than 1 level during initial discovery

**Important exception:** Public repositories clearly built for reusable AI workflows, skill distribution, installers, templates, or knowledge sharing may still be included as evidence for collaboration, customization, or feature usage parameters.

**Repository filter:** Only assess repositories affiliated with the user's organization. Check remote URL via `git remote -v` — only include repos whose remote URL contains the org identity.

**Determining first AI agent use date:** Use the earliest timestamp from session/config files across all detected tools. Priority: `.jsonl` session files, config creation date. Commands per platform:
- Linux/WSL/Git Bash: `find ~/.claude/projects/ -name '*.jsonl' -printf '%T+ %p\n' 2>/dev/null | sort | head -1`
- macOS: `find ~/.claude/projects/ -name '*.jsonl' -exec stat -f '%m %N' {} \; 2>/dev/null | sort -n | head -1`
- PowerShell: `Get-ChildItem "$HOME\.claude\projects" -Recurse -Filter '*.jsonl' | Sort-Object LastWriteTime | Select-Object -First 1`

### 2. Configuration & Customization per Tool

For each active tool in the AI Portfolio, collect:
- Settings/config file (depth of customization)
- Custom instructions (CLAUDE.md, AGENTS.md, GEMINI.md, .cursorrules, etc.)
- Rules / pre-approved commands (proxy for workflow automation maturity)
- Hooks / event handlers (Claude: PreToolUse/PostToolUse; Codex: rules)
- Guard scripts / security configurations

### 3. Skills & Plugins per Tool

| Tool | Skills/Plugins Location | What to Look For |
|------|------------------------|-----------------|
| Claude Code | `~/.claude/skills/` | Custom skills, skill count |
| Codex | `~/.codex/skills/` + `~/.codex/plugins/` | Skills (exclude `.system/`), active plugins |
| Continue.dev | `~/.continue/config.json` | Custom slash commands, context providers |
| Cursor | `.cursorrules` in repos | Rule complexity |
| Gemini CLI | `~/.gemini/` | Extensions / tools |

### 4. Memory System

Count and analyze **quantity + quality** of memory across all tools:
- Claude Code: `~/.claude/projects/*/memory/`
- Codex: `~/.codex/memories/`
- Continue.dev: memory section in config

Check: (a) duplication across projects/tools, (b) stale memory (references files/functions that no longer exist), (c) consolidation (index/reference files). Report ratio of quality memory vs total.

### 5. Conversation Sessions

| Tool | Session Location | How to Count |
|------|----------------|-------------|
| Claude Code | `~/.claude/projects/` | Count `.jsonl` files per project |
| Codex | `~/.codex/session_index.jsonl` | `wc -l` (Unix) or `Get-Content \| Count` (PowerShell) |
| Codex log intensity | `~/.codex/logs_2.sqlite` | File size as proxy (`du -sh` or PowerShell `Length`) |
| Cursor | `~/.cursor/` | Session/history files if present |

### 6. External Integrations (MCP, Extensions, Plugins)

- **MCP Servers (Claude):** `~/.claude/mcp.json` and system-reminder
- **VS Code Extensions:** check if Copilot/Continue/Codeium is installed via `~/.vscode/extensions/`
- **JetBrains Plugins:** `~/.config/JetBrains/*/plugins/` for AI plugins
- **Cursor Extensions:** AI extensions in Cursor settings

### 7. Project-Level AI Config

For each org repository found, assess the depth of AI integration:
- Presence of `CLAUDE.md` / `AGENTS.md` / `.cursorrules` / `GEMINI.md`
- Quality: are instructions specific or generic?
- Is there a `SYSTEM_MAP.md` to help AI navigate?

### 8. Hook & Automation Scripts

- **Claude Code:** `~/.claude/scripts/` — hook scripts
- **Codex:** `~/.codex/rules/default.rules` — pre-approved commands
- **Git hooks** in AI-assisted repos
- **CI/CD:** any pipelines leveraging AI?

**Edge cases:**
- Newly installed tool with no data → assess that parameter from other available tools
- If all sources are empty for a parameter → score = 1, note in report
- If platform is unrecognized → ask the user, note in report

## How to Combine Evidence Across Tools into Scores

Evidence from any tool contributes to the same parameter:

| Evidence from any tool | Contributes to parameter |
|------------------------|--------------------------|
| CLAUDE.md / AGENTS.md / .cursorrules / GEMINI.md | Prompt Engineering (#1), Customization (#8), Knowledge Architecture (#15) |
| Claude hooks / Codex rules / Copilot instructions | Workflow Integration (#3), Security Awareness (#4) |
| Claude memory / Codex memory / Continue context | Context Efficiency (#5), Knowledge Architecture (#15) |
| Skills (Claude) + plugins (Codex) + slash commands (Continue) | Feature Usage (#2), Customization (#8) |
| Co-authored commits (any tool) | Output Quality (#7), Collaboration (#10) |
| Workshop / public repo / team adoption | Collaboration (#10), Knowledge Sharing (#10) |
| Eval scripts / review checklists / test suites for AI output | Output Evaluation (#11) |
| Phoenix/Arize / Langfuse / custom dashboards / session logs | Observability (#12) |
| Subagent design / multi-agent configs / orchestration patterns | Multi-Agent Architecture (#13), Feature Usage (#2) |
| Model selection config / cost tracking / budget docs | Model & Cost Strategy (#14) |
| SYSTEM_MAP.md / RTK proxy / auto-generated context maps | Knowledge Architecture (#15), Context Efficiency (#5) |

If a feature exists in one tool but not another, note it as an **"asymmetry"** and score based on the combined ecosystem coverage, not per tool.

## Role-Based Scoring Guide

AI usage patterns differ by role. Adjust scoring expectations accordingly:

| Role | Expected usage pattern | Co-authored commits? |
|------|----------------------|----------------------|
| **Developer** | Code generation, bug fix, refactoring, testing | Yes, many |
| **Software Architect** | Analysis, workflow automation, tooling, oversight, skill design | Not required — 0 commits is not a weakness |
| **QA** | Test generation, bug reproduction, automation scripts | Possibly a few |
| **PM/PO** | Documentation, analysis, reporting, integrations | Not expected |

**Important:** If the user has 0 co-authored commits, do not automatically treat this as a weakness. Score based on usage patterns relevant to their role.

## Assessment 1: AI Agent Usage Parameters (Scale 1-10)

Scale:
- 1-2 = Not visible / Very weak — no deliberate AI strategy, purely reactive usage
- 3-4 = Basic / Just starting — single tool, ad-hoc usage, minimal configuration
- 5-6 = Adequate / Average — consistent usage in 1-2 tools, proactive patterns starting to emerge
- 7-8 = Good / Above average — systematic approach, cross-tool integration, measurable productivity impact
- 9-10 = Excellent / Expert — strategic, largely automated, enabling others, ecosystem thinking

### 15 Parameters with Concrete Criteria:

1. **Prompt Engineering** — Quality of instructions to AI agents (clarity, specificity, context, constraints) across all tools.
   - 1-2: No custom instructions in any tool, generic prompts only
   - 3-4: Some feedback/instructions in one tool, still mostly trial-and-error
   - 5-6: Structured custom instructions in 1-2 tools (CLAUDE.md, AGENTS.md, or .cursorrules), covering common scenarios
   - 7-8: Comprehensive instructions across multiple tools, covering edge cases, with hierarchy/priority and conflict resolution rules
   - 9-10: Consistent cross-tool instruction system with layered hierarchy, 200+ lines per main tool, conflict resolution, system-level thinking, teaching others

2. **AI Feature Usage** — Breadth of features used across the entire tool ecosystem.
   - 1-2: Only basic chat or inline suggestions in 1 tool
   - 3-4: Using file tools (Read, Edit, Bash) or code completion in 1-2 tools
   - 5-6: + memory/context system, custom skills/commands in at least 1 tool, 2 tools active
   - 7-8: + hooks/automation, MCP/plugin integration, multi-agent, 3+ tools actively used, deliberate tool selection per task type
   - 9-10: + scheduled triggers, custom scripts, subagents, public skill repo, complete cross-tool ecosystem with routing strategy

3. **Workflow Integration** — How deeply AI is integrated into daily workflows across all tools.
   - 1-2: AI used ad-hoc, no automation, no contextual instructions, tools are siloed
   - 3-4: Some skills/commands for routine tasks in 1 tool, manual invocation only
   - 5-6: Basic hooks or rules in 1-2 tools, daily workflow starting to integrate, automation for repetitive tasks
   - 7-8: PreToolUse + PostToolUse (Claude) or rules (Codex), multiple workflow skills, guard scripts, 2+ tools embedded in daily workflow
   - 9-10: + CI/CD integration, scheduled automation, event-driven triggers, full workflow coverage across tools with fallback strategies

4. **Security Awareness** — Security consciousness when using AI across all tools.
   - 1-2: No credential protection, .env exposed, no AI-specific security configuration
   - 3-4: Aware of risks but no enforcement mechanisms in any tool
   - 5-6: Basic credential masking in at least 1 tool, secrets not committed to AI context
   - 7-8: Guard hooks / command filtering / approval gates, automated credential masking, VPN checks, AI output reviewed for sensitive data
   - 9-10: Threat model-aware, cross-tool audit trail, automated credential rotation, AI hallucination risk mitigated, data governance policy for AI usage

5. **Context / Token Efficiency** — Efficiency of context window usage across all tools.
   - 1-2: No memory in any tool, every session starts from zero, no context management
   - 3-4: Some memory files in 1 tool, still much re-explanation per session
   - 5-6: Active memory system in 1 tool, some consolidated feedback, SYSTEM_MAP.md present in key repos
   - 7-8: Consolidated memory/feedback index, SYSTEM_MAP.md across repos, active context loading strategy in 2+ tools
   - 9-10: Explicit context budgeting per task, prompt compression techniques, optimized cross-tool loading, minimal redundancy across sessions

6. **Speed to Learn** — Speed of adoption and depth of mastery of advanced AI agent features.
   - 1-2: Still at basic features after 3+ months, not exploring new capabilities
   - 3-4: Starting to explore advanced features after 2-3 months, learning from community/docs
   - 5-6: Advanced features adopted within 1-2 months, onboarding 2+ tools, building mental model of ecosystem
   - 7-8: Advanced customization within < 1 month per tool, onboarding new tools within < 2 weeks, contributing back patterns
   - 9-10: Advanced customization within < 2 weeks per new tool, ahead of official documentation, teaching others systematically

7. **Output Quality** — Quality of outputs produced with AI agent assistance.
   - 1-2: Output frequently needs major revision, AI is a liability not an asset
   - 3-4: Output adequate but requires many corrections, inconsistent quality
   - 5-6: Consistent output quality, minor corrections, can select the right tool per task type
   - 7-8: Production-ready output, structured skill/config design, automation works reliably, 2+ tools used at their optimal range
   - 9-10: Exceptional output, near-zero defects on critical paths, AI configs adopted by others, measurable quality metrics maintained

8. **Customization & Configuration** — Depth of AI agent setup customization overall.
   - 1-2: Default settings in all tools, no customization, using AI as a black box
   - 3-4: Basic settings adjusted in 1 tool, maybe a CLAUDE.md with basic instructions
   - 5-6: Custom skills/rules/instructions in 1-2 tools, memory system started
   - 7-8: Customization ecosystem across 3+ tools: skills + hooks/rules + organized memory + workflow principles
   - 9-10: Complete cross-tool ecosystem (skills, hooks, memory, workflow principles, public repos, plugins) with documented rationale

9. **Problem Decomposition** — Ability to break down complex problems using AI agents effectively.
   - 1-2: Problems handed to any tool all at once without structure, hoping for the best
   - 3-4: Basic decomposition into a few steps in 1 tool, linear execution
   - 5-6: Multi-step workflows with structured skills/commands, some conditional logic
   - 7-8: Structured workflows 5+ steps, priority hierarchy, troubleshooting paths, deliberate tool selection per sub-task
   - 9-10: Complex workflows with branching logic, conflict resolution, error recovery, dynamic tool routing, multi-agent orchestration patterns

10. **Collaboration & Knowledge Sharing** — Effectiveness of human-AI collaboration and spreading knowledge to the team.
    - 1-2: Solo use only, no sharing, AI configs not documented or shared
    - 3-4: Occasionally sharing tips or prompts with colleagues
    - 5-6: Some skills/docs shared with team, at least 1 tool integrated into team projects, onboarding material started
    - 7-8: Public skills/configs, workshop/training delivered, reusable documentation, team actively adopting
    - 9-10: Entire team adopted thanks to user's enablement, AI configs become org standard, active ecosystem sharing across tools and projects

11. **AI Output Evaluation & Quality Control** — Systematic approach to verifying, critiquing, and improving AI-generated outputs.
    - 1-2: Accepts AI output as-is without review, no awareness of hallucination risk
    - 3-4: Manual spot-checks on important outputs, relies on intuition only
    - 5-6: Consistent review patterns per output type, cross-referencing AI output with authoritative sources for critical decisions
    - 7-8: Structured eval checklists per domain (code review, doc review), hallucination detection patterns, feedback loops back into prompt refinement
    - 9-10: Automated eval pipelines (e.g., LLM-as-judge, test suites for AI output), A/B testing prompts for quality, continuous quality metrics tracked over time

12. **Observability & AI Usage Analytics** — Monitoring and understanding AI agent performance, cost, and usage patterns.
    - 1-2: No monitoring, no visibility into AI usage beyond what the tool UI shows
    - 3-4: Occasionally checks usage dashboards in individual tools, no cross-tool view
    - 5-6: Tracks session counts and basic usage metrics, aware of cost per tool
    - 7-8: Cross-tool observability: logs AI interactions, tracks cost/token usage, uses observability tools (Phoenix/Arize, Langfuse, custom dashboards) for at least 1 workflow
    - 9-10: Full observability stack across tools, anomaly detection, cost anomaly alerts, usage-based optimization, LLM trace analysis to improve prompts and configs

13. **Multi-Agent Architecture Design** — Ability to design and orchestrate systems where multiple AI agents collaborate with clear roles, handoffs, and error handling.
    - 1-2: Uses only single agent, single task at a time, no concept of agent composition
    - 3-4: Aware of multi-agent patterns, uses basic parallelism (e.g., spawning subagents for independent tasks)
    - 5-6: Designs basic multi-agent flows: parallel data gathering + sequential synthesis, task delegation with defined scope
    - 7-8: Complex orchestration with agent specialization, explicit handoff contracts, error recovery paths, human-in-the-loop checkpoints
    - 9-10: Production multi-agent systems with monitoring, dynamic agent routing based on task type, fallback strategies, reusable orchestration patterns adopted by others

14. **Model & Cost Strategy** — Deliberate approach to selecting the right AI model/tool for the right task, balancing cost and quality.
    - 1-2: Always uses the same model regardless of task, no cost awareness
    - 3-4: Aware of cost differences between models but no systematic strategy
    - 5-6: Deliberate model selection per task category (e.g., small model for simple completions, large model for architecture decisions)
    - 7-8: Explicit cost budgeting per project, model routing strategy documented, tracks spending across tools, uses cheaper models for high-volume routine tasks
    - 9-10: Optimized cost/quality ratio across entire ecosystem, cost-aware prompt engineering (e.g., cache-friendly prompts), budget governance policy, measurable cost reduction without quality loss

15. **Knowledge Architecture for AI** — How well the user structures their codebase, documentation, and context to maximize AI comprehension and minimize token waste.
    - 1-2: No consideration for AI readability in structure, documentation, or naming
    - 3-4: Basic CLAUDE.md or AGENTS.md in some repos, code structure is unmodified for AI use
    - 5-6: SYSTEM_MAP.md in key repos, structured project docs, organized context loading, consistent naming conventions
    - 7-8: Comprehensive AI-optimized documentation across all org repos, context loading strategy per tool, RTK or equivalent navigation proxy in use
    - 9-10: Full knowledge architecture: layered context (global → project → session), automated map generation, org-wide documentation standards designed for AI consumption, self-updating SYSTEM_MAP.md

## Assessment 2: Aurora Charter Activation Progress

A separate assessment rating the user's AI activation level based on the Aurora Charter:

| Level | Label | Description |
|-------|-------|-------------|
| 1 | Aware | Knows AI tools exist but not using them regularly |
| 2 | Experimenting | Uses AI occasionally for specific tasks (editing PPT, coding help) |
| 3 | Adopting | Routinely uses AI tools for daily tasks |
| 4 | Optimized | Consistently uses AI for measurably better output. Builder: has already built AI tools/workflows |
| 5 | Mastery | Reduced workload 50%+, shares knowledge, makes the entire team productive. Builder: production-ready AI systems used by others |

Provide the level conclusion with detailed justification, covering evidence from all active tools.

> **Note:** The table above is extracted from the `AI Proficiency Scale` image (original source: `scale.png`). The image file is not required to run this skill.

## Output

Generate **two file formats** for each assessment:

### Output Path Resolution per Platform

| Platform | Skills Path | Downloads Path |
|----------|------------|---------------|
| macOS | `~/.claude/skills/self-assessment/` | `~/Downloads/ai-self-assessment/` |
| Linux Native | `~/.claude/skills/self-assessment/` | `~/Downloads/ai-self-assessment/` (create if missing) |
| WSL | `~/.claude/skills/self-assessment/` | `~/Downloads/ai-self-assessment/` OR `/mnt/c/Users/<username>/Downloads/ai-self-assessment/` |
| Windows Git Bash | `~/.claude/skills/self-assessment/` | `~/Downloads/ai-self-assessment/` |
| Windows PowerShell | `$env:USERPROFILE\.claude\skills\self-assessment\` | `$env:USERPROFILE\Downloads\ai-self-assessment\` |

Create the Downloads directory if missing:
- Linux/macOS/WSL/Git Bash: `mkdir -p ~/Downloads/ai-self-assessment/`
- PowerShell: `New-Item -ItemType Directory -Force "$env:USERPROFILE\Downloads\ai-self-assessment"`

### Format 1: Markdown (`.md`) — Full Report, per date
- Primary location: `~/.claude/skills/self-assessment/assessment-[YYYY-MM-DD].md`
- Secondary location: `~/Downloads/ai-self-assessment/assessment-[YYYY-MM-DD].md` (adjust per platform)
- New file per assessment, never overwritten.
- **All content in Bahasa Indonesia.**

### Format 2: HTML (`.html`) — Summary Card, single file
- Primary location: `~/.claude/skills/self-assessment/assessment-summary.html`
- Secondary location: `~/Downloads/ai-self-assessment/assessment-summary.html` (adjust per platform)
- **Always overwritten** on each assessment — only one HTML file reflecting current state.
- Contains: AI Portfolio table, 15-parameter score table with progress bars, Aurora Charter level, delta vs previous assessment, top 3 recommendations.
- Clean design with colors (green = up, yellow = stagnant, red = down), badge per active AI tool, Aurora Charter badge.
- Inline CSS only — no external dependencies.
- Must be openable directly in a browser without a server.
- **All text content in Bahasa Indonesia.**

### Markdown Report Structure:

```
# Self-Assessment AI Agent Ecosystem — [Nama User]
**Tanggal:** [tanggal]
**Periode:** [tanggal pertama pakai AI] s/d [tanggal assessment]
**AI Tools Aktif:** [daftar tool yang terdeteksi]

## Ringkasan Eksekutif

## AI Portfolio
[Tabel tool aktif + bukti + level penggunaan per tool]

## Data yang Dikumpulkan
[Per sumber data, sebutkan tool asal evidence]

## Penilaian 1: Parameter Penggunaan AI Agent (Skala 1-10)
[Tabel 15 parameter + justifikasi per parameter, sebutkan tool mana yang menjadi evidence]

## Penilaian 2: Aurora Charter Activation Progress (Skala 1-5)
[Level yang dicapai + justifikasi detail per level]

## Deliberasi & Klarifikasi
[Temuan kritis + jawaban pengguna]

## Kesimpulan & Rekomendasi
[Top 3 area improvement + tool yang disarankan dikembangkan]

## Skor Keseluruhan
[Rata-rata 15 parameter /10 + level Aurora Charter /5]
[Sertakan radar chart tekstual atau tabel kelompok: Core (1-10) vs Maturity (11-15)]

## Rekomendasi Re-assessment
[Interval yang disarankan berdasarkan level saat ini]
```

## Re-assessment Interval Recommendations

| Aurora Charter Level | Re-assessment Interval | Reason |
|---------------------|----------------------|--------|
| 1-2 (Aware/Experimenting) | 2 weeks | Early phase, rapid changes, progress tracking needed |
| 3 (Adopting) | 1 month | Already routine, monthly evaluation is sufficient |
| 4 (Optimized) | 1-2 months | Focus on gap toward Mastery |
| 5 (Mastery) | 3 months / quarterly | Maintenance and continuous improvement |

If this is the first assessment, mark it as **baseline** for comparison in the next assessment.

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|---------|
| Git co-authored commits = 0 | Author doesn't match, or role is not developer | Check `git config --global user.name/email`. If role is not developer, 0 commits is not a weakness — score per role. |
| `.jsonl` files not found | `~/.claude/projects/` doesn't exist or path differs | Check path per platform, expand `~` accordingly |
| Memory files detected as stale | File references functions/paths that no longer exist | Grep the referenced function/path — if absent from codebase, mark stale |
| Skills directory empty | User hasn't created custom skills | Score parameter from other tools' evidence, note limitation |
| Previous assessment not found | First time or file moved | Glob `assessment-*.md` — if empty, mark as baseline |
| Deliberation timeout | User doesn't respond to clarification | Skip the finding, note as "Unverified — pending user confirmation" |
| `stat --format` fails on macOS | macOS uses BSD stat, not GNU stat | Switch to `stat -f '%m %N'` |
| `find -printf` fails on macOS | BSD find does not support `-printf` | Switch to `-exec stat -f '%m %N' {} \;` |
| `uname` not found | Windows PowerShell / CMD without Git Bash | Use `$env:OS` (PowerShell) or `%OS%` (CMD) |
| AI tool path not found | Tool installed on different side (WSL vs Windows) | Check `/mnt/c/Users/<username>/` for tools installed on the Windows side |
| `mkdir -p` fails on PowerShell | PowerShell doesn't recognize `-p` flag | Switch to `New-Item -ItemType Directory -Force` |
| Path `/c/Users/...` not found | Git Bash drive letter is not C: | Check `echo $USERPROFILE` in Git Bash for actual drive |
| `du -sh` fails on PowerShell | PowerShell doesn't have `du` | Switch to `(Get-Item '<file>').Length / 1MB` |
| Platform detected as Linux but actually WSL | `/proc/version` not checked | Always check `cat /proc/version \| grep -i microsoft` after `uname -s` returns `Linux` |
| Tool detected but data is minimal | Tool newly installed, not yet actively used | Mark as "Installed, not yet adopted" in AI Portfolio |

## Verification

Before finalizing the assessment document:

1. **Cross-check score vs evidence** — every parameter scoring >= 7 MUST have concrete proof from at least 1 tool (file, config, or command output)
2. **Validate co-authored commits** — ensure author matches the user's account, not someone else
3. **Check memory duplication** — do not count duplicate memory as evidence of quality
4. **Verify AI Portfolio** — all tools claimed as active must have a verifiable path
5. **Score consistency** — related parameters should not differ by > 3 points without justification:
   - #1 Prompt Engineering ↔ #8 Customization
   - #2 Feature Usage ↔ #3 Workflow Integration
   - #5 Context Efficiency ↔ #15 Knowledge Architecture
   - #7 Output Quality ↔ #11 Output Evaluation
   - #9 Problem Decomposition ↔ #13 Multi-Agent Architecture
6. **Tool asymmetry check** — if score is high in one tool but very low in another of the same category, note as improvement area
7. **Maturity gap check** — if Core parameters (#1-10) average >= 7 but Maturity parameters (#11-15) average <= 4, explicitly flag this as the next growth frontier
8. **New parameters evidence** — for #11-15, accept proxy evidence: eval scripts, observability tool presence, model config, SYSTEM_MAP.md, cost notes — do not require production-grade systems to score above 5

## Post-Assessment

1. **Save files** to both locations (skills dir + Downloads), adjusted per platform
2. **Compare** with previous assessment — highlight delta per parameter
3. **Update adaptive learning log** — add to `ADAPTIVE_LEARNING.md`: newly discovered tools, validated important paths, clarified false positives
4. **Inform user** — display summary in Indonesian: active AI Portfolio, average score, Aurora Charter level, top 3 improvement areas
5. **Recommend** next re-assessment date based on interval table
