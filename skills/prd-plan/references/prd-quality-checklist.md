# PRD Quality Checklist

Use this reference when reviewing or refining a generated PRD before final output.

## Scope Control

- Does the PRD stay inside the user-requested feature boundary?
- Are out-of-scope items explicitly listed?
- Are assumptions clearly separated from confirmed requirements?
- Does the document avoid introducing new modules, actors, or workflows without justification?

## Requirement Quality

- Is the business goal stated in one or two clear sentences?
- Are primary users identified concretely, not generically?
- Does each major requirement describe observable system behavior?
- Are validation rules, permissions, and state transitions explicit where relevant?

## Journey and Flow Coverage

- Does the happy path cover the full journey from trigger to successful outcome?
- Does each journey step have matching flow detail?
- Are preconditions and postconditions recorded for important steps?
- Are system actions and user-visible outcomes both described?

## Edge Cases

- Does each critical journey step include negative or failure scenarios?
- Are timeout, retry, duplicate action, and concurrency cases covered where applicable?
- Are authorization and permission failures documented?
- Is user-facing error behavior defined, not just backend failure notes?

## Data Model and API Consistency

- Does every important entity map back to a real flow or requirement?
- Are redundant fields or overlapping entities removed?
- Do API endpoints align with the described journey and business actions?
- Do request and response schemas reflect the data model consistently?
- Are documented error cases traceable to real edge cases?

## User Story Readiness

- Can each story be completed independently in a small delivery window?
- Does each story have acceptance criteria that can be tested?
- Are edge cases represented in acceptance criteria or separate stories?
- Are priorities consistent with the stated business goal and risk?

## Handoff Readiness

- Can Design use this PRD without guessing missing interactions?
- Can QA derive test cases from the user stories and edge cases?
- Can Engineering infer entities, flows, and APIs without major ambiguity?
- Is there any unresolved question that should be called out before handoff?
