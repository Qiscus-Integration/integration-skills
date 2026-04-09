---
name: dev-execute
description: >
  Generate a complete developer implementation plan from PRD, design spec, and QA test plan outputs. Creates task breakdown, technical decisions, implementation checklist, and code scaffolding guidance. Use this skill when a developer needs to translate product requirements and design specs into an actionable technical plan: implementation tasks, API integration guide, database migration plan, and definition of done. Trigger when the user says "create an implementation plan", "developer task breakdown", "technical plan from PRD", "how to implement this feature", "dev task", or passes PRD/design spec/test plan for developer execution.
---

# Dev Execute

Translate PRD, Design Spec, and QA Test Plan into a complete, actionable implementation plan for developers.

## Use This Skill When

- Breaking a PRD into developer tasks and technical subtasks
- Planning API integration from the PRD API contract
- Defining database migrations from the PRD data model
- Creating a technical implementation checklist before coding starts
- Reviewing technical feasibility of PRD requirements
- Preparing definition of done for each user story

## Do Not Use This Skill When

- No PRD or user stories are available — run `generate-prd` first
- The task is only about writing test cases (use `qa-testplan`)
- The task is only about UI/UX design decisions (use `design-spec`)

## File I/O Convention

This skill is **step 4 of 4** in the product workflow:

```
[PM] generate-prd  →  prd.md
                         ↓
[Designer] design-spec reads prd.md  →  design-spec.md
                                           ↓
[QA] qa-testplan reads prd.md + design-spec.md  →  qa-testplan.md
                                                       ↓
[Dev] dev-execute reads all 3 files  →  dev-plan.md  ← YOU ARE HERE
```

Input files (all under `docs/features/[feature-slug]/`):
- `prd.md` — product requirements, user stories, data model, API contract (required)
- `design-spec.md` — screen inventory, component list, interaction flows, handoff notes (required)
- `qa-testplan.md` — test cases, Gherkin scenarios, automation spec, DoD criteria (required)

Output file: `docs/features/[feature-slug]/dev-plan.md`

## Inputs

### Step 0: Setup (REQUIRED — complete every step here before starting Phase 1)

**Step 0a — Read the stack conventions**

Read `references/tech-stack-conventions.md` now. This file defines the valid stack profiles and the conventions that must be applied.

**Step 0b — Ask for the feature slug and read the input files**

1. Ask for `feature_slug` if it is not already known.
2. Read the following three files with the Read tool:
   - `docs/features/[feature-slug]/prd.md`
   - `docs/features/[feature-slug]/design-spec.md`
   - `docs/features/[feature-slug]/qa-testplan.md`
3. If `prd.md` does not exist, **stop completely**:
   ```
   Cannot continue. prd.md was not found at docs/features/[feature-slug]/prd.md
   Ask the PM to run $generate-prd first.
   ```
4. If `design-spec.md` does not exist, **warn and continue**:
   ```
   design-spec.md was not found. Continuing without a design spec.
   The component tree and frontend plan will be inferred from the PRD only.
   Ask the UI/UX Designer to run $design-spec for a more complete plan.
   ```
5. If `qa-testplan.md` does not exist, **warn and continue**:
   ```
   qa-testplan.md was not found. Continuing without a QA test plan.
   The Definition of Done will be based on the PRD acceptance criteria only.
   Ask the QA Engineer to run $qa-testplan for a more complete plan.
   ```

**Step 0c — Choose the stack profile (REQUIRED, cannot be skipped)**

Ask the developer:

```
Choose the stack profile for this feature:

Backend:
  [1] rails-monolith   ← default for most features
  [2] microservice-go  ← only if this feature is deployed as a separate service

Frontend (if this feature has a UI):
  [3] fe-vue     (Vue.js SPA)
  [4] fe-nuxt    (Nuxt SSR/SSG)
  [5] fe-react   (React SPA)
  [6] fe-next    (Next.js SSR/SSG)
  [7] fe-svelte  (Svelte / SvelteKit)
  [8] there is no frontend for this feature

If the project uses TWO different frontend apps (for example: Nuxt for the public
+ site and Vue for the dashboard), select both and name the scope of each app.

Example answers:
  Single frontend : "1, 4"
  Two frontends   : "1, 4 (public-app) + 3 (dashboard-app)"
  Backend only    : "1, 8"
```

After the developer answers, do the following before proceeding:

1. **Single frontend**: record `backend_profile` and `frontend_profile`. Read the selected stack file.

2. **Composite frontend (two apps)**: record `backend_profile` and two entries:
   ```
   frontend_profiles:
     - scope: public-app    → fe-nuxt
     - scope: dashboard-app → fe-vue
   ```
   Read **both** frontend stack files. In every phase output, prefix each section with its scope label.

3. If the developer answers with a stack that is not in the list, ask for clarification before continuing.

4. **Do not mix conventions** across stacks. File paths, naming, response formats, and state management must follow the selected stack profile file.

**Step 0d — Confirm before starting**

Tampilkan ringkasan setup:

```
Setup confirmation:
  Feature slug : [feature-slug]
  Backend      : [rails-monolith / microservice-go]
  Frontend     : [nama profile] ATAU:
                 [public-app]    → fe-nuxt
                 [dashboard-app] → fe-vue
  Input files  : prd.md ✓ / design-spec.md [✓/⚠] / qa-testplan.md [✓/⚠]
  Output       : docs/features/[feature-slug]/dev-plan.md

Type "continue" to start Phase 1, or correct anything that is wrong.
```

### Additional inputs collected during the phases:

- `existing_codebase` — modules/services that already exist and are relevant to this feature
- `output_format` — `notion`, `table`, atau `markdown`
- `mode` — `auto` atau `interactive`

Ask for them when needed in the relevant phase, not all at the beginning.

## Execution Modes

### Interactive mode

- Execute one phase at a time.
- Stop after each phase and wait for developer/tech lead confirmation before continuing.

### Auto mode

- Execute all phases in sequence.
- Make reasonable technical assumptions based on stated tech stack.
- Surface assumptions clearly in the final output.

## Working Memory

Carry forward prior outputs:

- `technical_feasibility`
- `architecture_decisions`
- `task_breakdown`
- `api_implementation_plan`
- `database_migration_plan`
- `frontend_implementation_plan`
- `definition_of_done`
- `implementation_checklist`

Update only affected sections on revision.

## Output Standards

- Tasks must be sized for 0.5–3 days of work. Larger tasks must be broken down further.
- Every task must have clear inputs (what is needed before starting) and outputs (what is produced when done).
- Architecture decisions must state the reason and trade-offs considered.
- API implementation must align exactly with the PRD API contract.
- Database migrations must be reversible (up + down).

## Workflow

### Phase 1: PRD & Spec Parsing

Goal:
- Extract all developer-relevant information from PRD, design spec, and QA test plan.
- Identify technical risks and missing information before planning.

Instructions:
- Extract API contracts, data models, user stories, and acceptance criteria.
- Identify integration points with existing systems.
- Flag ambiguous or technically risky requirements.
- Ask 3–5 focused questions about tech stack, existing patterns, constraints, and non-functional requirements.

Output:
- Extracted technical requirements list
- Technical risk flags
- Clarification questions

Interactive stop:
- Wait for developer/tech lead answers before proceeding.

### Phase 2: Technical Feasibility Review

Goal:
- Assess whether the PRD requirements are technically feasible as specified.

Output per requirement:
- Feasibility status: Feasible / Needs Modification / Not Feasible
- Reason
- Recommended modification (if applicable)
- Estimated complexity: Simple / Moderate / Complex

Format:
```text
Requirement: [User story or API endpoint]
Status: Feasible / Needs Modification / Not Feasible
Reason: [technical reason]
Complexity: Simple / Moderate / Complex
Recommendation: [if modification needed]
```

Rules:
- Do not mark something "Not Feasible" without a recommended alternative.
- Surface performance concerns for any operation on large datasets.
- Flag any requirement that conflicts with existing system constraints.

Interactive stop:
- Confirm feasibility assessment with tech lead before planning tasks.

### Phase 3: Architecture Decisions

Goal:
- Document the technical decisions needed to implement this feature.

Output per decision:
- Decision ID (ADR-[feature]-[number])
- Decision title
- Context (why a decision is needed)
- Options considered
- Decision made
- Rationale
- Trade-offs accepted
- Consequences

Format:
```text
ADR-001: [Title]
Context: [why this decision is needed]
Options:
  A. [option description]
  B. [option description]
Decision: [chosen option]
Rationale: [why]
Trade-offs: [what we give up]
Consequences: [what changes as a result]
```

Rules:
- Document only decisions that are non-obvious or where multiple valid options exist.
- Every ADR must include at least two options considered.
- Link ADRs to the relevant user stories or API endpoints they affect.

Interactive stop:
- Review architecture decisions with tech lead before task breakdown.

### Phase 4: Task Breakdown

Goal:
- Break down all feature work into implementable developer tasks.

Output per task:
- Task ID (TASK-[feature]-[number])
- Title
- Type: Backend / Frontend / Database / DevOps / Integration
- Description
- Inputs (what must exist before this task starts)
- Outputs (what this task produces)
- Dependencies (other task IDs that must complete first)
- Acceptance criteria (how to know the task is done)
- Estimated size: XS (< 2h) / S (half day) / M (1 day) / L (2–3 days)
- Related user story ID

Format:
```text
TASK-001: [Title]
Type: Backend
Size: M
Story: US-[id]
Dependencies: none

Description:
  [what needs to be built]

Inputs:
  - [what must exist before starting]

Outputs:
  - [what will exist when done]

Acceptance Criteria:
  - [ ] [specific, verifiable criterion]
  - [ ] [specific, verifiable criterion]
```

Rules:
- Tasks of size L or larger must be broken into smaller subtasks.
- Every task must have at least two acceptance criteria.
- Group tasks into layers: Database → Backend → Frontend → Integration → Testing.
- Flag tasks that can be parallelized vs those that must be sequential.

Interactive stop:
- Ask whether to revise task list before implementation planning.

### Phase 5: Database Migration Plan

Goal:
- Produce a complete database migration plan from the PRD data model.

Output:
- Migration file list (ordered by dependency)
- Per migration:
  - Migration name and sequence number
  - Tables/columns created, altered, or dropped
  - Indexes added
  - Foreign key constraints
  - Seed data (if any)
  - Rollback (down migration) plan
  - Estimated migration time for production data volume

Format:
```text
Migration: [sequence]_[description]
Direction: up / down

Up:
  CREATE TABLE [name] (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    [field] [type] [constraints],
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
  );
  CREATE INDEX [name] ON [table]([column]);

Down:
  DROP TABLE IF EXISTS [name];

Estimated Runtime: [duration] on [X] million rows
Risk: Low / Medium / High (with reason)
```

Rules:
- Every migration must have an up and a down.
- Migrations on large tables must be zero-downtime (additive only, no destructive ALTER in production).
- Flag any migration that requires data backfill — plan it as a separate background job.

Interactive stop:
- Ask whether to revise migration plan before API planning.

### Phase 6: API Implementation Plan

Goal:
- Provide a technical implementation guide for each API endpoint from the PRD contract.

Output per endpoint:
- Endpoint and method
- Controller/handler location (file path convention)
- Service layer responsibilities
- Data validation rules
- Authorization check (who can call this)
- Database queries (conceptual, not raw SQL)
- Response transformation / serialization
- Error handling (exception types and HTTP codes)
- Caching strategy (if applicable)

Format:
```text
POST /api/v1/[resource]
Controller: [file path]
Service: [file path]

Authorization: [role/permission required]

Validation:
  - [field]: [rule] → [error message]

Service Logic:
  1. [step]
  2. [step]

DB Operations:
  - [description of query]

Response:
  201: [schema description]
  400: [validation error schema]
  401: Unauthorized

Caching: [none / cache key / TTL]
```

Rules:
- Authorization must be checked before any business logic.
- Validation must happen before any database operation.
- Log all state-changing operations with actor ID and timestamp.
- Never return raw database errors to the client.

Interactive stop:
- Ask whether API plan needs revision.

### Phase 7: Frontend Implementation Plan

Goal:
- Provide a technical implementation guide for the frontend based on design spec and PRD.

Output:
- Component tree for each screen
- State management plan (local state vs global store)
- API integration points (which components call which endpoints)
- Form handling plan (library, validation, submission)
- Error handling UI strategy
- Loading state strategy
- Routing plan (new routes and params)

Format:
```text
Screen: [Name]
Route: /[path]

Component Tree:
  [ScreenName]
  ├── [ComponentA]
  │   └── [SubComponent]
  └── [ComponentB]

State:
  Local: [list of local state vars]
  Global: [store slices / context used]

API Calls:
  - On mount: GET /api/v1/[resource]
  - On submit: POST /api/v1/[resource]

Forms:
  Library: [React Hook Form / Formik / etc.]
  Validation: [Zod / Yup / etc.]
  Trigger: on-submit / on-blur

Error Handling:
  API Error → [toast / inline error / redirect]
  Validation Error → inline field error

Loading:
  Skeleton: [yes/no, component name]
  Button: [disable + spinner on submit]
```

Interactive stop:
- Ask whether frontend plan needs revision.

### Phase 8: Definition of Done

Goal:
- Produce a clear, shared definition of done for this feature.

Output:
- Per-story DoD checklist
- Feature-level DoD checklist
- Release readiness checklist

Format:
```text
Per Story DoD:
  [ ] Code reviewed and approved by at least 1 reviewer
  [ ] Unit tests written and passing
  [ ] Integration tests passing
  [ ] No linting errors
  [ ] PR description includes test evidence (screenshot or log)
  [ ] Linked to user story ticket

Feature DoD:
  [ ] All stories meet per-story DoD
  [ ] E2E automation tests passing in CI
  [ ] API contract matches implementation (no undocumented deviations)
  [ ] Database migrations tested on staging
  [ ] Performance tested (P95 response time within target)
  [ ] Security review completed (auth, input validation, OWASP check)
  [ ] Feature flagged (if applicable) and tested in both states
  [ ] Product and design sign-off received

Release Readiness:
  [ ] QA sign-off received
  [ ] Staging deployment verified
  [ ] Rollback plan documented
  [ ] Monitoring/alerting configured for new endpoints
  [ ] On-call runbook updated
```

Interactive stop:
- Ask whether DoD is complete before final output.

### Phase 9: Implementation Checklist & Timeline

Goal:
- Produce an ordered implementation checklist with suggested sequencing.

Output:
- Phase-ordered task list (which tasks go in which sprint/phase)
- Critical path identified
- Parallelizable workstreams
- Risk items flagged
- Suggested daily standup tracking format

Format:
```text
Phase 1 — Foundation (Sprint N)
  [ ] TASK-001: [title] — Backend — M
  [ ] TASK-002: [title] — Database — S
  (can run in parallel: TASK-001 and TASK-002)

Phase 2 — Core Feature (Sprint N+1)
  [ ] TASK-003: [title] — Backend — L (depends: TASK-001)
  [ ] TASK-004: [title] — Frontend — M (depends: TASK-002)

Critical Path: TASK-001 → TASK-003 → TASK-005
Parallel Track: TASK-002 → TASK-004

Risk Items:
  - TASK-003: complex migration on large table — plan maintenance window
```

### Phase 10: Final Structured Output

Input:
- All prior phase outputs

Output:
- Format according to `output_format`

If `output_format = notion`:
- Prepare structured Notion-ready content with sections and tables.

If `output_format = table`:
- Return tabular task list with ID, type, size, dependencies, and status.

If `output_format = markdown`:
- Return clean markdown document for Confluence or GitHub wiki.

Final check:
- All user stories covered by tasks
- All API endpoints planned
- Database migrations planned
- Frontend implementation planned
- Definition of done defined
- Implementation checklist ordered

### Phase 11: Write Output File

Goal:
- Persist the developer implementation plan to disk.

Instructions:
- Write the complete dev plan to: `docs/features/[feature-slug]/dev-plan.md`
- The file must contain all phases: feasibility review, architecture decisions, task breakdown, database migrations, API plan, frontend plan, definition of done, and implementation checklist.
- Do not truncate any tasks or decisions.

Confirm to the user:
```
Dev plan saved to: docs/features/[feature-slug]/dev-plan.md

Workflow complete. All 4 artifacts are available:
  docs/features/[feature-slug]/prd.md
  docs/features/[feature-slug]/design-spec.md
  docs/features/[feature-slug]/qa-testplan.md
  docs/features/[feature-slug]/dev-plan.md
```

## Maturity Rules

### Must Do

- Always read all available input files before starting — never rely on the user pasting content.
- Break down all tasks to max 3-day size.
- Document architecture decisions with trade-offs.
- Plan database migrations with rollback.
- Validate API implementation against PRD contract.
- Define explicit acceptance criteria per task.
- Cross-reference QA test cases when writing acceptance criteria per task.

### Must Not Do

- Start Phase 1 before finishing Step 0 completely.
- Mix conventions from different stacks in a single output (for example, Rails structure inside a Go plan).
- Skip feasibility review.
- Buat task tanpa acceptance criteria.
- Plan a migration that cannot be rolled back without a maintenance window plan.
- Skip authorization planning for any API endpoint.
- Generalize the output. Every detail (file path, naming, response format) must follow the chosen stack.

## Deliverable Checklist

Before finishing, verify:

- [ ] Step 0 completed: stack profile selected and confirmed
- [ ] `tech-stack-conventions.md` read at the beginning
- [ ] Technical feasibility reviewed
- [ ] Architecture decisions documented
- [ ] Task breakdown complete (all user stories covered)
- [ ] Database migration plan complete (with rollback)
- [ ] API implementation guide complete (following the selected stack conventions)
- [ ] Frontend implementation plan complete (following the selected sub-stack)
- [ ] Definition of done defined
- [ ] Implementation checklist ordered with critical path
- [ ] `dev-plan.md` ditulis ke disk

## Bundled Resources

### Index (read in Step 0a)

- `references/tech-stack-conventions.md` — index of all stack profiles and shared conventions. **Read this first in Step 0a**, before the developer chooses a stack.

### Stack Profile Files (read in Step 0c after the developer chooses)

Backend:

- `references/stack-rails-monolith.md` — Rails monolith: file structure, service layer, API envelope, DB migration, Sidekiq, RSpec.
- `references/stack-microservice-go.md` — Go microservice: file structure, interface-based repository, REST/gRPC, table-driven tests.

Frontend:

- `references/stack-fe-vue.md` — Vue.js SPA: Composition API, Pinia, Axios, Vitest.
- `references/stack-fe-nuxt.md` — Nuxt.js SSR/SSG: useFetch, Pinia, server routes.
- `references/stack-fe-react.md` — React SPA: Zustand/Redux Toolkit, React Query, msw.
- `references/stack-fe-next.md` — Next.js App Router: Server Components, React Query, Route Handlers.
- `references/stack-fe-svelte.md` — SvelteKit: load functions, Form Actions, Svelte stores.

### Security

- `references/security-checklist.md` — OWASP checklist for backend and frontend. Open it during Phase 6 (API Implementation Plan).

**Do not assume these files are already in context. Open them explicitly when needed.**
