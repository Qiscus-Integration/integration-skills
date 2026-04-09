---
name: qa-testplan
description: >
  Generate a complete QA test plan from PRD and design spec outputs. Creates manual test cases, automation test specs, and regression coverage. Use this skill when a QA engineer needs to produce test documentation from product requirements: test cases in Gherkin format, automation test structure, edge case coverage, API test contracts, and test execution checklists. Trigger when the user says "create a test plan", "test cases from PRD", "QA spec", "automation test", "create test scenarios", or passes a PRD/design spec for QA planning.
---

# QA Test Plan

Translate a PRD and Design Spec into a complete, executable QA test plan covering manual tests, automation specs, and regression scenarios.

## Use This Skill When

- Creating test cases from user stories and acceptance criteria
- Building automation test structure from feature flows
- Defining API test contracts from PRD API spec
- Producing regression test coverage for an existing feature
- Preparing QA sign-off checklist before release

## Do Not Use This Skill When

- No PRD or user stories are available — run `generate-prd` first
- The request is about writing production code
- The task is only about performance or load testing (use a dedicated load testing skill)

## File I/O Convention

This skill is **step 3 of 4** in the product workflow:

```
[PM] generate-prd  →  prd.md
                         ↓
[Designer] design-spec reads prd.md  →  design-spec.md
                                           ↓
[QA] qa-testplan reads prd.md + design-spec.md  →  qa-testplan.md  ← YOU ARE HERE
                                                       ↓
[Dev] dev-execute reads all 3 files  →  dev-plan.md
```

Input files:
- `docs/features/[feature-slug]/prd.md` (required)
- `docs/features/[feature-slug]/design-spec.md` (required — provides screen inventory and interaction flows)

Output files:
- `docs/features/[feature-slug]/qa-testplan.md` (always)
- `docs/features/[feature-slug]/qa-testplan.csv` (when `output_format = csv` or `both`)

## Inputs

### Step 0: Read Input Files (REQUIRED — do this before anything else)

Before starting any phase:
1. Ask the user for `feature_slug` if not already provided.
2. Read `docs/features/[feature-slug]/prd.md` using the Read tool.
3. Read `docs/features/[feature-slug]/design-spec.md` using the Read tool.
4. If `prd.md` does not exist, stop and say:
   ```
   PRD file not found at docs/features/[feature-slug]/prd.md
   Please ask the PM to run $generate-prd first.
   ```
5. If `design-spec.md` does not exist, warn the user:
   ```
   Design spec not found at docs/features/[feature-slug]/design-spec.md
   Proceeding with PRD only — screen inventory and interaction states will be inferred.
   Ask the UI/UX Designer to run $design-spec for more complete test coverage.
   ```
6. Extract all testable requirements from both files before proceeding to Phase 1.

### Additional inputs to collect or infer:

- `test_framework` — automation framework to use (e.g., Cypress, Playwright, Jest, Appium, Postman/Newman)
- `test_scope` — `manual`, `automation`, or `both`
- `output_format` — `notion`, `table`, `markdown`, `csv`, or `both` (`both` = markdown + CSV)
- `mode` — `auto` or `interactive`

If inputs are missing, infer what is safe and ask focused questions for critical gaps.

## Execution Modes

### Interactive mode

- Execute one phase at a time.
- Stop after each phase and wait for QA confirmation before continuing.

### Auto mode

- Execute all phases in sequence.
- Make reasonable testing assumptions.
- Surface assumptions clearly in the final output.

## Working Memory

Carry forward prior outputs:

- `test_strategy`
- `test_scenarios`
- `manual_test_cases`
- `automation_test_specs`
- `api_test_cases`
- `regression_coverage`
- `test_execution_checklist`

Update only affected sections on revision.

## Output Standards

- Every user story must have at least one happy path test case.
- Every edge case from the PRD must have a corresponding negative test case.
- Test cases must be atomic — one expected result per test case.
- Automation specs must be framework-agnostic in structure, with framework-specific notes when needed.
- Acceptance criteria must be verifiable, not subjective.

## Workflow

### Phase 1: PRD & Design Spec Parsing

Goal:
- Extract testable requirements from PRD and design spec.
- Identify gaps in acceptance criteria before writing tests.

Instructions:
- Extract all user stories and acceptance criteria.
- List all screens and flows from design spec.
- Identify ambiguous acceptance criteria that need clarification.
- Ask 3–5 focused questions about test environment, critical flows, and known risks.

Output:
- Extracted testable requirements list
- Clarification questions

Interactive stop:
- Wait for QA / PM answers before proceeding.

### Phase 2: Test Strategy

Goal:
- Define the overall testing approach for this feature.

Output:
- Test types to be used (unit, integration, E2E, API, visual regression, accessibility)
- Risk-based test priority (High / Medium / Low)
- Test environment requirements
- Test data requirements
- Entry and exit criteria for QA sign-off
- Tools and frameworks

Format:
```text
Feature: [Name]
Risk Level: [High / Medium / Low]
Test Priority: [Critical paths listed]

Test Types:
- Manual: [scope]
- Automation: [scope and framework]
- API: [scope]

Entry Criteria:
- [list]

Exit Criteria:
- [list]
```

Interactive stop:
- Confirm test strategy before writing test cases.

### Phase 3: Manual Test Cases

Goal:
- Write manual test cases for all user stories and critical flows.

Output per test case:
- Test Case ID (TC-[feature]-[number])
- Title
- Preconditions
- Test Steps (numbered)
- Expected Result
- Priority (P1 Critical / P2 High / P3 Medium / P4 Low)
- Test Type (Functional / UI / Accessibility / Boundary)
- Related User Story ID

Format:
```text
TC-001: [Title]
Priority: P1
Type: Functional
Story: US-[id]
Preconditions:
  - [list]
Steps:
  1. [action]
  2. [action]
Expected Result: [what should happen]
```

Rules:
- Happy path first, then negative cases, then edge cases.
- Each test case tests exactly one behavior.
- Steps must be reproducible by any QA without domain knowledge.
- Include boundary value cases for all numeric and date inputs.

Interactive stop:
- Ask whether to revise test cases or proceed.

### Phase 4: Gherkin / BDD Scenarios

Goal:
- Convert critical test cases into Gherkin format for BDD automation.

Output per scenario:
```gherkin
Feature: [Feature Name]

  Background:
    Given [shared precondition]

  Scenario: [Happy path title]
    Given [initial state]
    When [user action]
    Then [expected outcome]
    And [additional assertion]

  Scenario: [Negative case title]
    Given [initial state]
    When [invalid user action]
    Then [expected error behavior]
```

Rules:
- Use declarative style (what, not how).
- Avoid UI selectors in Gherkin (those belong in step definitions).
- Group related scenarios under the same Feature block.
- Use Scenario Outline for data-driven tests.

Interactive stop:
- Ask whether Gherkin scenarios need revision.

### Phase 5: Automation Test Spec

Goal:
- Define the automation test structure, file organization, and implementation guide for the chosen framework.

Output:
- File/folder structure for automation tests
- Test suite grouping by feature area
- Selector strategy (data-testid preferred, CSS fallback)
- Page Object Model (POM) or equivalent pattern recommendation
- Fixtures and test data management approach
- CI/CD integration notes

Format:
```text
Framework: [Cypress / Playwright / Jest / etc.]

Folder Structure:
  tests/
    [feature-name]/
      [feature-name].spec.ts    ← E2E test file
      [feature-name].fixtures.ts ← test data
    pages/
      [FeatureName]Page.ts      ← Page Object

Selector Strategy:
  Primary: data-testid="[component-name]"
  Fallback: CSS class (avoid implementation-coupled selectors)

Test Data:
  - Static fixtures for happy path
  - Factory functions for dynamic data
  - Separate test data per environment

CI/CD:
  - Run on: PR open, PR merge to main
  - Parallelization: [yes/no, spec]
  - Retry on failure: 2 times
```

Interactive stop:
- Ask whether automation structure needs adjustment.

### Phase 6: API Test Cases

Goal:
- Write API-level test cases from the PRD API contract.

Output per endpoint:
- Test Case ID (API-[feature]-[number])
- Endpoint and method
- Description
- Request headers
- Request body (valid and invalid variants)
- Expected status code
- Expected response schema
- Edge cases (empty payload, missing auth, rate limit)

Format:
```text
API-001: [Endpoint] — [Description]
Method: POST /api/v1/[resource]
Priority: P1

Request:
  Headers: Authorization: Bearer {token}
  Body: { "field": "value" }

Expected:
  Status: 201
  Response: { "id": "...", "status": "created" }

Negative Cases:
  - Missing required field → 400 Bad Request
  - Invalid auth token → 401 Unauthorized
  - Duplicate resource → 409 Conflict
```

Rules:
- Test authentication and authorization separately from business logic.
- Cover all HTTP error codes documented in the API contract.
- Include response time assertion (P95 < 500ms for critical endpoints).

Interactive stop:
- Ask whether API test cases need revision.

### Phase 7: Regression Coverage Map

Goal:
- Map new test cases to existing features to identify regression risk.

Output:
- List of existing features potentially affected by this change
- Regression test cases to run before release
- Smoke test set (minimal set to verify system is alive)
- Full regression set (complete verification)

Format:
```text
Affected Features:
  - [Feature A]: [reason it may be affected]
  - [Feature B]: [reason it may be affected]

Smoke Test Set (run first — ~15 min):
  - TC-001, TC-002, API-001

Regression Set (full — ~2 hrs):
  - [complete list]
```

Interactive stop:
- Ask whether regression map is accurate.

### Phase 8: Test Execution Checklist

Goal:
- Produce a pre-release QA sign-off checklist.

Output:
- Environment verification steps
- Test data setup steps
- Execution order (smoke → regression → exploratory)
- Bug severity classification guide
- Sign-off criteria
- Known limitations / deferred items

Format:
```text
Pre-Execution:
  [ ] Test environment deployed and accessible
  [ ] Test data seeded
  [ ] Feature flags enabled for this feature

Execution Order:
  1. Smoke tests (P1 only)
  2. Full manual test cases
  3. Automation suite
  4. API tests
  5. Exploratory testing (30 min)

Sign-Off Criteria:
  [ ] 0 P1 bugs open
  [ ] 0 P2 bugs open (or waived with PM approval)
  [ ] All P1 and P2 test cases passed
  [ ] Automation suite green
```

Interactive stop:
- Ask whether checklist is complete before finalizing.

### Phase 9: Final Structured Output

Input:
- All prior phase outputs

Output:
- Format according to `output_format`

If `output_format = notion`:
- Prepare structured Notion-ready content.

If `output_format = table`:
- Return tabular test case list with ID, title, priority, type, and status.

If `output_format = markdown`:
- Return clean markdown document for Confluence or GitHub wiki.

If `output_format = csv` or `output_format = both`:
- Open `references/csv-template.md` and follow all instructions there.
- Generate a CSV file with the exact column order defined in that reference.
- Column rules:
  - `No`: sequential integer starting at 1
  - `Key Feature in TRA/ SRS`: feature/module name from PRD
  - `Scenario`: short scenario label
  - `Description Scenario`: full description in Bahasa Indonesia
  - `PREREQUISITE`: login role + open page, in Bahasa Indonesia
  - `CASE TYPE`: `Positive` or `Negative`
  - `Test Case`: specific test action label
  - `Test Data`: role or input values used
  - `Step`: numbered steps, each on a new line within the quoted cell. **Always start with standard opening steps for the first test case of each new feature:**
    ```
    1. Login sebagai {Role}
    2. Buka {URL / Menu path}
    3. Verifikasi halaman {feature name} berhasil terbuka
    ```
    Then continue with the specific test interaction steps.
  - `EXPECTED RESULT`: what should happen after all steps complete
  - `ENV`: `Staging` (default for new features)
  - Columns 12–19 (execution fields): leave blank — filled by tester
  - Header row columns 21–24: `TOTAL TEST CASE,{COUNT},,TOTAL TEST CASE`
- Save CSV to `docs/features/[feature-slug]/qa-testplan.csv`
- If `output_format = both`, also write the markdown file.

Final check:
- All user stories covered
- All edge cases from PRD have negative test cases
- API contracts tested
- Regression impact assessed
- Sign-off checklist complete

### Phase 10: Write Output File

Goal:
- Persist the QA test plan to disk so the next role (Developer) can consume it.

Instructions:
- Always write: `docs/features/[feature-slug]/qa-testplan.md`
  - Must include all phases: test strategy, manual test cases, Gherkin scenarios, automation spec, API tests, regression map, and sign-off checklist.
  - Do not truncate any test cases.
- If `output_format = csv` or `output_format = both`:
  - Open `references/csv-template.md` first.
  - Generate and write: `docs/features/[feature-slug]/qa-testplan.csv`
  - Follow all column rules and step format rules from the reference.
  - Ensure every feature's first test case starts with the standard opening steps.

Confirm to the user:
```
QA test plan saved to: docs/features/[feature-slug]/qa-testplan.md
CSV export saved to:   docs/features/[feature-slug]/qa-testplan.csv  (if applicable)
Next step: hand prd.md + design-spec.md + qa-testplan.md to the Developer and ask them to run $dev-execute
```

## Maturity Rules

### Must Do

- Cover every user story with at least one happy path test case.
- Write atomic test cases (one expected result per test).
- Use Gherkin for all automation-targeted scenarios.
- Document test data requirements explicitly.

### Must Not Do

- Write test cases that depend on other test cases' side effects.
- Skip negative test cases or edge cases.
- Mix UI steps with business logic assertions in Gherkin.
- Produce test cases without clear expected results.

## Deliverable Checklist

Before finishing, verify:

- [ ] Test strategy defined
- [ ] Manual test cases written (happy path + negative + edge cases)
- [ ] Gherkin scenarios for automation targets
- [ ] Automation test structure specified
- [ ] API test cases written
- [ ] Regression coverage mapped
- [ ] Pre-release sign-off checklist produced
- [ ] Final structured output in requested format

## Bundled Resources

- `references/bug-severity-guide.md` — bug severity and priority classification guide.
- `references/automation-patterns.md` — common automation test patterns and anti-patterns.
- `references/csv-template.md` — CSV column structure, step format rules, and sample rows for CSV export.
- Do not assume these files are loaded. Open them explicitly when needed.
