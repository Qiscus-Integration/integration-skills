# Skill: qa-testplan

Role: QA Engineer

Generates a complete, executable QA test plan from a PRD and design spec — covering manual test cases, Gherkin BDD scenarios, automation spec, API tests, regression coverage, and sign-off checklist.

---

## Trigger Phrases

- "create a test plan"
- "write test cases"
- "QA spec"
- "automation tests"
- "gherkin scenarios"
- "buat skenario test"

---

## Workflow Position

```bash
[PM] generate-prd  →  prd.md
                          ↓
[Designer] design-spec  →  design-spec.md
                                ↓
[QA] qa-testplan reads prd.md + design-spec.md  →  qa-testplan.md   ← THIS SKILL
                                                           ↓
[Dev] dev-execute reads all 3 files
```

This is step 3 of 4 in the product workflow.

Input files:

- `docs/features/[slug]/prd.md` — required; skill stops if not found
- `docs/features/[slug]/design-spec.md` — recommended; skill continues with a warning if not found, inferring screen states from the PRD

Output file: `docs/features/[slug]/qa-testplan.md`

---

## Inputs

Required at startup:

- `feature_slug` — used to locate input files and name the output file
- `test_framework` — automation framework (e.g., Cypress, Playwright, Jest, Appium, Postman/Newman)
- `test_scope` — `manual`, `automation`, or `both`

Optional:

- `output_format` — `notion`, `table`, or `markdown` (default: `markdown`)
- `mode` — `auto` or `interactive` (default: `interactive`)

---

## Execution Modes

- `interactive` — stops after each phase, waits for QA confirmation
- `auto` — runs all phases in sequence, surfaces testing assumptions in the final output

---

## Output Phases

1. **PRD and Design Spec Parsing** — extracts testable requirements, identifies ambiguous acceptance criteria, asks 3–5 questions about test environment, critical flows, and known risks
2. **Test Strategy** — test types (unit, integration, E2E, API, visual regression, accessibility), risk-based priority, environment requirements, test data requirements, entry and exit criteria, tools and frameworks
3. **Manual Test Cases** — per test case: ID (`TC-[feature]-[number]`), title, preconditions, numbered steps, expected result, priority (P1–P4), type, related story ID; ordered happy path → negative → edge cases
4. **Gherkin / BDD Scenarios** — declarative `Given / When / Then` format; `Scenario Outline` for data-driven tests; no UI selectors in Gherkin
5. **Automation Test Spec** — folder structure, test suite grouping, selector strategy (`data-testid` preferred), Page Object Model pattern, fixture and test data management, CI/CD integration notes
6. **API Test Cases** — per endpoint: ID, method, request headers and body (valid and invalid), expected status code, expected response schema, negative cases (missing auth, missing field, conflict)
7. **Regression Coverage Map** — affected existing features, smoke test set (~15 min), full regression set
8. **Test Execution and Sign-Off Checklist** — pre-execution steps, execution order (smoke → regression → exploratory), bug severity guide reference, sign-off criteria (0 P1 bugs, automation green)
9. **Final Structured Output** — formatted as `notion`, `table`, or `markdown`
10. **Write Output File** — writes `docs/features/[slug]/qa-testplan.md`

---

## Test Case ID Convention

| Type | Format | Example |
|------|--------|---------|
| Manual | `TC-[feature]-[number]` | `TC-checkout-001` |
| API | `API-[feature]-[number]` | `API-checkout-001` |

---

## Bundled References

| File | When it is loaded |
| ------ | ------------------ |
| `references/bug-severity-guide.md` | Load during Phase 8 for severity (S1–S4) and priority (P1–P4) classification; includes bug report template |
| `references/automation-patterns.md` | Load during Phase 5 for POM pattern, selector strategy, anti-patterns (hard sleeps, test interdependence), and CI/CD checklist |

These files are not loaded automatically. Open them explicitly when needed.

---

## Maturity Rules

Must do:

- Read both input files before starting any phase
- Cover every user story with at least one happy path test case
- Write atomic test cases — one expected result per test
- Use Gherkin for all automation-targeted scenarios
- Document test data requirements explicitly

Must not do:

- Write test cases that depend on other test cases' side effects
- Skip negative test cases or edge cases
- Mix UI steps with business logic assertions in Gherkin
- Produce test cases without a clear expected result

---

## Handoff to Next Role

After writing `qa-testplan.md`, confirm to the user:

```bash
QA test plan saved to: docs/features/[slug]/qa-testplan.md
Next step: hand prd.md + design-spec.md + qa-testplan.md to the Developer and ask them to run $dev-execute
```
