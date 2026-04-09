# Skill: dev-plan

Role: Developer / Tech Lead

Converts PRD, design spec, and QA test plan into a stack-specific, actionable implementation plan — task breakdown, architecture decisions, database migrations, API guide, frontend plan, and definition of done.

---

## Trigger Phrases

- "create an implementation plan"
- "break down dev tasks"
- "technical plan from PRD"
- "dev task"
- "how to implement this feature"

---

## Workflow Position

```bash
[PM] prd-plan  →  prd.md
                         ↓
[Designer] design-plan  →  design-spec.md
                                           ↓
[QA] qa-plan  →  qa-testplan.md
                                                       ↓
[Dev] dev-plan reads all 3 files  →  dev-plan.md   ← THIS SKILL
```

This is step 4 of 4 in the product workflow.

Input files (all under `docs/features/[slug]/`):

| File | Required | Behavior if missing |
| ------ | ---------- | ------------------- |
| `prd.md` | Yes | Skill stops — cannot proceed |
| `design-spec.md` | Recommended | Continues with warning; frontend plan inferred from PRD only |
| `qa-testplan.md` | Recommended | Continues with warning; DoD based on PRD acceptance criteria only |

Output file: `docs/features/[slug]/dev-plan.md`

---

## Stack Profiles

The skill asks for a backend profile and a frontend profile at startup (Step 0c).
All output — file paths, naming, API format, state management — follows the selected profiles exactly.

### Backend

| Profile ID | Stack | When to use |
| ----------- | ------- | ------------ |
| `rails-monolith` | Rails, PostgreSQL, Sidekiq, RSpec | Default for most features |
| `microservice-go` | Go, PostgreSQL, REST or gRPC | Only when feature is a separate deployed service |

### Frontend

| Profile ID | Stack | When to use |
| ----------- | ------- | ------------ |
| `fe-vue` | Vue.js SPA — Composition API, Pinia, Vitest | Vue SPA |
| `fe-nuxt` | Nuxt.js SSR/SSG — useFetch, Pinia | Vue-based SSR |
| `fe-react` | React SPA — Zustand / Redux Toolkit, React Query | React SPA |
| `fe-next` | Next.js App Router — Server Components, React Query | React-based SSR |
| `fe-svelte` | Svelte / SvelteKit — load functions, Form Actions | Svelte |
| _(none)_ | Backend-only feature | Skip frontend plan |

### Composite Frontend

Projects that use two separate frontend apps (e.g., Nuxt for public pages and Vue for the admin dashboard) can select both profiles with a scope label:

```bash
"1, 4 (public-app) + 3 (dashboard-app)"
```

Each app receives its own conventions throughout all output phases — they are never mixed.

---

## Execution Modes

- `interactive` — stops after each phase, waits for developer/tech lead confirmation
- `auto` — runs all phases in sequence, surfaces technical assumptions in the final output

---

## Output Phases

1. **Setup (Step 0)** — reads stack conventions index, reads all input files, prompts for stack profile selection, shows confirmation summary before proceeding
2. **Technical Feasibility Review** — per-requirement assessment: Feasible / Needs Modification / Not Feasible, with reason, complexity rating (Simple / Moderate / Complex), and recommended modification
3. **Architecture Decision Records** — ADR format: context, options considered, decision, rationale, trade-offs, and consequences; only for non-obvious decisions
4. **Task Breakdown** — per task: ID (`TASK-[feature]-[number]`), type (Backend / Frontend / Database / DevOps / Integration), size (XS / S / M / L), inputs, outputs, dependencies, acceptance criteria, related story ID
5. **Database Migration Plan** — ordered migration list with up and down scripts, index definitions, zero-downtime guidance, estimated runtime, and risk rating
6. **API Implementation Plan** — per endpoint: controller/handler location, service responsibilities, validation rules, authorization check, database operations, response transformation, error handling, caching strategy
7. **Frontend Implementation Plan** — per screen: component tree, state management (local vs global), API call locations, form handling, error and loading strategy, routing
8. **Definition of Done** — per-story DoD, feature-level DoD (E2E green, API contract match, security review, performance tested), release readiness checklist
9. **Implementation Checklist and Timeline** — phase-ordered task list, critical path, parallelizable workstreams, risk items flagged
10. **Final Structured Output** — formatted as `notion`, `table`, or `markdown`
11. **Write Output File** — writes `docs/features/[slug]/dev-plan.md` and prints a summary of all four workflow artifacts

---

## Task Sizing Guide

| Size | Duration | Notes |
| ------ | ---------- | ------- |
| XS | < 2 hours | Config change, small fix |
| S | ~half day | Isolated component or endpoint |
| M | ~1 day | Feature slice end-to-end |
| L | 2–3 days | Complex feature; break down further if possible |

Tasks sized L must be broken into subtasks before implementation starts.
Every task must have at least two acceptance criteria.

---

## Bundled References

| File | When it is loaded |
| ------ | ------------------ |
| `references/tech-stack-conventions.md` | Loaded at Step 0a — index of all profiles |
| `references/stack-rails-monolith.md` | Loaded at Step 0c if `rails-monolith` selected |
| `references/stack-microservice-go.md` | Loaded at Step 0c if `microservice-go` selected |
| `references/stack-fe-vue.md` | Loaded at Step 0c if `fe-vue` selected |
| `references/stack-fe-nuxt.md` | Loaded at Step 0c if `fe-nuxt` selected |
| `references/stack-fe-react.md` | Loaded at Step 0c if `fe-react` selected |
| `references/stack-fe-next.md` | Loaded at Step 0c if `fe-next` selected |
| `references/stack-fe-svelte.md` | Loaded at Step 0c if `fe-svelte` selected |
| `references/security-checklist.md` | Loaded during Phase 6 (API Implementation Plan) |

Only the files matching the selected stack profiles are loaded — not all files at once.

---

## Maturity Rules

Must do:

- Complete all four sub-steps of Step 0 before starting Phase 1
- Apply the selected stack's conventions consistently across all output phases
- Break all tasks to maximum 3-day (L) size
- Document architecture decisions with trade-offs
- Plan database migrations with rollback
- Cross-reference QA test cases when writing task acceptance criteria

Must not do:

- Mix conventions from different stack profiles in a single output
- Start Phase 1 without completing Step 0
- Create tasks without acceptance criteria
- Plan irreversible migrations without a rollback or maintenance window plan
- Skip authorization planning for any API endpoint

---

## Handoff / Workflow Complete

After writing `dev-plan.md`, print:

```bash
Dev plan saved to: docs/features/[slug]/dev-plan.md

Workflow complete. All 4 artifacts are available:
  docs/features/[slug]/prd.md
  docs/features/[slug]/design-spec.md
  docs/features/[slug]/qa-testplan.md
  docs/features/[slug]/dev-plan.md
```
