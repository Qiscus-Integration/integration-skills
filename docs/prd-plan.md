# Skill: prd-plan

Role: Product Manager

Turns a feature idea into a complete, implementation-ready Product Requirements Document.

---

## Trigger Phrases

- "create a PRD"
- "write a product spec"
- "break this feature down"
- "generate user stories"
- "feature breakdown"
- "system flow"

---

## Workflow Position

```bash
[PM] prd-plan  →  docs/features/[slug]/prd.md   ← THIS SKILL
                                 ↓
[Designer] design-plan reads prd.md
```

This is step 1 of 4 in the product workflow. It has no file inputs — it starts from a feature description provided by the user.

Output file: `docs/features/[slug]/prd.md`

---

## Execution Modes

- `interactive` — stops after each phase, waits for confirmation before continuing
- `auto` — runs all phases in sequence, surfaces assumptions in the final output

---

## Output Phases

1. **Clarification** — 3–7 focused questions about scope, business rules, actors, constraints, and out-of-scope boundaries
2. **Clarified Requirements** — feature summary, primary users, business goal, assumptions, scope, out of scope
3. **User Journey** — step-by-step happy path with system responses per step
4. **Flow Expansion** — trigger, preconditions, main actions, system processing, data created, success result, postconditions per step
5. **Edge Cases** — invalid input, system failure, timeout, concurrency, and permission cases per journey step
6. **Data Model** — entity list with fields, types, relationships, and lifecycle fields
7. **API Contract** — endpoint list with method, request schema, response schema, error cases, and HTTP status codes
8. **Consistency Review** — structured check for missing validation, incomplete journey coverage, inconsistent API vs data model, and ambiguous requirements
9. **User Story Transformation** — epics with stories in As a / I want / So that format, Gherkin acceptance criteria, priority, and story points
10. **Final Structured Output** — formatted as `notion`, `table`, or `markdown`
11. **Write Output File** — writes `docs/features/[slug]/prd.md` and confirms the path to the user

---

## Output Format Options

| Format | When to use |
| -------- | ------------ |
| `notion` | Paste into Notion — uses section headers and tables |
| `table` | Tabular breakdown for quick review |
| `markdown` | Confluence, GitHub wiki, or any Markdown renderer |
| `json` | Structured machine-readable planning output |

---

## Bundled References

| File | When it is loaded |
| ------ | ------------------ |
| `references/prd-quality-checklist.md` | Loaded during Phase 8 when a deeper quality review is needed |
| `assets/templates/notion-templated.md.template` | Loaded during Phase 10 when `output_format = notion` |
| `scripts/helper.py` | PRD generation checklist — load on demand |

These files are not loaded automatically. Open them explicitly when needed.

---

## Maturity Rules

Must do:

- Ask clarification questions before locking the scope
- Keep scope tied to the stated feature and business goals
- Make assumptions explicit and separate from confirmed requirements
- Ensure each output builds on the previous one
- Keep the final result implementation-ready, not just presentation-friendly

Must not do:

- Invent major features outside the original request
- Skip edge cases because the happy path looks complete
- Produce inconsistent entities, flows, and APIs
- Jump straight to user stories without clarifying requirements first

---

## Handoff to Next Role

After writing `prd.md`, confirm to the user:

```bash
PRD saved to: docs/features/[slug]/prd.md
Next step: hand this file to the UI/UX Designer and ask them to run $design-plan
```
