# Skill: design-spec

Role: UI/UX Designer

Translates a PRD into a complete design specification for Figma — covering all screens, components, states, tokens, accessibility requirements, and developer handoff notes.

---

## Trigger Phrases

- "create a design spec"
- "design from PRD"
- "figma spec"
- "UI spec"
- "design specification"
- "design handoff"

---

## Workflow Position

```bash
[PM] generate-prd  →  prd.md
                          ↓
[Designer] design-spec reads prd.md  →  design-spec.md   ← THIS SKILL
                                               ↓
[QA] qa-testplan reads prd.md + design-spec.md
```

This is step 2 of 4 in the product workflow.

Input file: `docs/features/[slug]/prd.md` (required — skill stops if not found)

Output file: `docs/features/[slug]/design-spec.md`

---

## Inputs

Required at startup:

- `feature_slug` — used to locate `prd.md` and name the output file
- `design_system` — existing component library (e.g., Qiscus DS, Material, Ant Design)
- `platform` — `web`, `mobile-ios`, `mobile-android`, or `cross-platform`

Optional:

- `figma_project_url` — existing Figma project URL if available
- `output_format` — `notion`, `table`, or `markdown` (default: `markdown`)
- `mode` — `auto` or `interactive` (default: `interactive`)

---

## Execution Modes

- `interactive` — stops after each phase, waits for designer confirmation
- `auto` — runs all phases in sequence, surfaces design assumptions in the final output

---

## Output Phases

1. **PRD Parsing and Clarification** — extracts screens implied by the user journeys, asks 3–5 questions about design system, platform, and existing patterns
2. **Screen and Flow Inventory** — entry point, purpose, primary action, and exit points per screen; includes modals, drawers, and overlays
3. **Component Inventory** — DS reference, variants, screens used, and behavior per component; grouped by atomic level (Atoms → Molecules → Organisms → Templates); flags new components
4. **Interaction Flow Specification** — default, loading, empty, error, success, hover/focus/active states; transition type and animation duration per screen
5. **Design Token Specification** — color, typography, spacing, border radius, shadow, and motion tokens; references existing DS tokens first
6. **Accessibility Requirements** — WCAG 2.1 AA contrast ratios, keyboard navigation flow, ARIA roles and labels, touch target sizes (44×44px minimum), screen reader behavior
7. **Figma Structure Guideline** — recommended page layout, frame naming (`[Screen] / [State] / [Variant]`), layer naming, component organization, auto-layout guidelines, prototype flow connections
8. **Developer Handoff Notes** — behavior notes written for developers, animation specs (property, from, to, duration, easing), responsive breakpoints, data binding notes, API integration points
9. **Final Structured Output** — formatted as `notion`, `table`, or `markdown`
10. **Write Output File** — writes `docs/features/[slug]/design-spec.md`

---

## Bundled References

| File | When it is loaded |
| ------ | ------------------ |
| `references/design-system-checklist.md` | Load during Phase 3 (Component Inventory) to check coverage by category |
| `references/figma-naming-convention.md` | Load during Phase 7 (Figma Structure Guideline) for naming rules |

These files are not loaded automatically. Open them explicitly when needed.

---

## Maturity Rules

Must do:

- Read `prd.md` before starting any phase — never rely on the user pasting PRD content
- Reference existing design system components before proposing new ones
- Cover all states for every screen: loading, empty, error, success
- Write handoff notes in developer language (units, behavior, data binding — not aesthetic opinion)
- Make every design assumption explicit

Must not do:

- Prescribe visual aesthetics (colors, font choices) outside of the design system
- Skip accessibility specifications
- Invent screens not implied by the PRD
- Produce specs that require follow-up questions from developers

---

## Handoff to Next Role

After writing `design-spec.md`, confirm to the user:

```bash
Design spec saved to: docs/features/[slug]/design-spec.md
Next step: hand prd.md + design-spec.md to the QA Engineer and ask them to run $qa-testplan
```
