---
name: generate-prd
description: Generate a structured product requirements document (PRD), expand it into user journeys, flows, edge cases, data models, API contracts, and implementation-ready user stories. Use when the user asks for a PRD, feature breakdown, system flow, product spec, user story set, or Notion-ready planning output for a new or revised feature.
---

# Generate PRD

Create a complete product specification from a feature idea and drive it toward implementation-ready planning artifacts.

## Use This Skill When

- Turning a feature idea into a PRD
- Expanding a product request into detailed flows and edge cases
- Converting requirements into API contracts or data models
- Breaking a feature into epics and user stories
- Preparing a product spec for Notion, table, or JSON output

## Do Not Use This Skill When

- The user only wants a short brainstorm or lightweight feature summary
- The user needs code changes instead of planning artifacts
- The task is purely UX writing, marketing copy, or interface polish

## Inputs

Collect or infer these inputs before starting:

- `feature_name`
- `business_context`
- `target_users`
- `goals`
- `output_format`: `notion`, `table`, or `json`
- `mode`: `auto` or `interactive`

If the user does not provide all of them, infer what is safe and ask focused clarification questions for the missing parts.

## Execution Modes

### Interactive mode

- Execute one phase at a time.
- Stop after each phase.
- Wait for user confirmation or correction before moving forward.

### Auto mode

- Execute all phases in sequence without stopping between phases.
- Make reasonable assumptions when details are missing.
- Surface assumptions clearly in the final output.

## Working Memory

Carry forward prior outputs instead of regenerating them from scratch:

- `clarified_requirements`
- `user_journey`
- `flow_details`
- `edge_cases`
- `data_model`
- `api_contract`
- `user_stories`

Update only the affected sections when a user asks for revision.

## Output Standards

- Keep requirements inside the scope of the stated feature and goals.
- Prefer concrete, implementation-relevant detail over vague product language.
- Separate assumptions from confirmed requirements.
- Keep entities, flows, and APIs internally consistent.
- Ensure every important user journey has matching edge cases and user stories.

## Workflow

### Phase 1: Clarification

Goal:
- Identify ambiguity, missing scope, and hidden assumptions.

Instructions:
- Ask between 3 and 7 focused questions.
- Ask questions even if the feature seems mostly clear.
- Prioritize business rules, actors, constraints, success metrics, dependencies, and out-of-scope boundaries.

Output:
- Questions only.

Interactive stop:
- Wait for user answers before proceeding.

### Phase 2: Clarified Requirements

Goal:
- Consolidate the feature into a clean requirement baseline.

Output:
- Feature summary
- Primary users
- Business goal
- Assumptions
- Explicit scope
- Out of scope
- Open questions, if any still remain

Interactive stop:
- Ask whether the requirement summary should be refined.

### Phase 3: User Journey

Goal:
- Describe the main user journey from trigger to successful outcome.

Output:
- Step-by-step journey
- Primary actor for each step
- Expected system response per step

Rules:
- Start with the happy path first.
- Keep the journey at a business and system behavior level, not low-level implementation detail.

Interactive stop:
- Ask whether the journey should be refined before continuing.

### Phase 4: Flow Expansion

Goal:
- Expand each journey step into implementation-relevant flow detail.

Output for each step:
- Trigger
- Preconditions
- Main actions
- System processing
- Data created or updated
- Success result
- Postconditions

Rules:
- Preserve prior expanded steps.
- Do not repeat already completed step details unless the user requests revision.
- In interactive mode, continue step by step.

Interactive stop:
- Ask whether to continue to the next step or revise the current one.

### Phase 5: Edge Cases

Input:
- `user_journey`
- `flow_details`

Output:
- Edge cases grouped by journey step

Each step must cover:
- Invalid input
- System failure
- Timeout or retry behavior
- Concurrency issues when applicable
- Permission or authorization issues

Format:
```text
Step X
- Case:
- Cause:
- System Behavior:
- User Feedback:
```

Interactive stop:
- Ask whether the edge cases should be refined.

### Phase 6: Data Model

Input:
- `flow_details`
- `edge_cases`

Output:
- Entity list

Each entity must include:
- Entity name
- Description
- Fields with type and required/optional status
- Relationships

Rules:
- Avoid redundant fields.
- Normalize where sensible.
- Include lifecycle or audit fields when needed.
- Keep the model consistent with the journey and API behavior.

Interactive stop:
- Ask whether to revise the data model or proceed.

### Phase 7: API Contract

Input:
- `data_model`
- `flow_details`

Output:
- Endpoint list grouped by feature capability

Each endpoint must include:
- Endpoint
- Method
- Purpose
- Request schema
- Response schema
- Error cases
- HTTP status codes

Field types should use consistent primitives such as:
- `string`
- `integer`
- `boolean`
- `timestamp`
- `uuid`
- `enum`

Rules:
- Follow REST conventions unless the feature clearly requires another pattern.
- Do not invent endpoints outside the approved scope.
- Map error cases back to journey failures and edge cases.

Interactive stop:
- Ask whether the API contract should be revised.

### Phase 8: Review

Input:
- All prior outputs

Task:
- Perform a structured consistency review.

Review must check:
- Missing validation rules
- Incomplete journey coverage
- Inconsistent API vs data model
- Missing error handling
- Ambiguous requirements
- Over-scoped functionality

Output format:
```text
- Issue:
- Impact:
- Fix:
```

Interactive stop:
- Ask whether to apply fixes and continue.
- If yes, update all affected outputs before moving on.

### Phase 9: User Story Transformation

Input:
- `user_journey`
- `flow_details`
- `edge_cases`

Output:
- Epics with user stories grouped by journey stage or capability

Each story must include:
- Title
- Description
  - As a ...
  - I want ...
  - So that ...
- Acceptance Criteria in Gherkin
- Preconditions
- Postconditions
- Priority
- Story Points

Rules:
- Keep each story completable in roughly 1 to 3 days.
- Avoid combining multiple unrelated actions into one story.
- Cover critical edge cases in either a dedicated story or acceptance criteria.

Interactive stop:
- Ask whether to revise the stories before formatting.

### Phase 10: Final Structured Output

Input:
- `user_stories`
- all approved prior outputs

Output:
- Format according to `output_format`

If `output_format = json`:
- Return structured JSON.

If `output_format = table`:
- Return a clean tabular breakdown.

If `output_format = notion`:
- Prepare structured content for Notion-ready formatting.
- Load `references/notion-templated.md` if a Notion template structure is required.

Final check:
- All phases are complete.
- Scope has not drifted.
- Requirements, stories, data model, and API contract are consistent.

### Phase 11: Write Output File

Goal:
- Persist the PRD to disk so the next role (UI/UX Designer) can consume it.

Instructions:
- Ask the user for `feature_slug` (e.g., `user-authentication`, `payment-checkout`) if not already known.
- Write the complete PRD output to: `docs/features/[feature-slug]/prd.md`
- Create the directory if it does not exist.

Output file structure:
```
docs/features/[feature-slug]/
└── prd.md   ← written by this skill
```

Confirm to the user:
```
PRD saved to: docs/features/[feature-slug]/prd.md
Next step: hand this file to the UI/UX Designer and ask them to run $design-spec
```

## Maturity Rules

### Must Do

- Ask clarification questions before locking the scope.
- Keep scope tied to the stated feature and business goals.
- Make assumptions explicit.
- Ensure each output builds on the previous one.
- Keep the final result implementation-ready, not just presentation-friendly.

### Must Not Do

- Invent major features outside the original request.
- Skip edge cases just because the happy path looks complete.
- Produce inconsistent entities, flows, and APIs.
- Jump straight to user stories without clarifying the requirement first.

## Deliverable Checklist

Before finishing, verify that the PRD includes:

- Clarified requirements
- User journey
- Detailed flow expansion
- Edge cases
- Data model
- API contract
- Review findings and applied fixes
- User stories
- Final structured output in the requested format

## File I/O Convention

This skill is **step 1 of 4** in the product workflow:

```
[PM] generate-prd  →  prd.md
                         ↓
[Designer] design-spec reads prd.md  →  design-spec.md
                                           ↓
[QA] qa-testplan reads prd.md + design-spec.md  →  qa-testplan.md
                                                       ↓
[Dev] dev-execute reads all 3 files  →  dev-plan.md
```

Output file: `docs/features/[feature-slug]/prd.md`

## Bundled Resources

- `references/notion-templated.md` contains the Notion-ready PRD template structure.
- `scripts/helper.py` provides a compact PRD generation checklist.
- Do not assume these companion files are already loaded in context.
- Open the relevant companion file explicitly before relying on it.
