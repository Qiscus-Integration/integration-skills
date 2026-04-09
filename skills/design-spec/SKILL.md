---
name: design-spec
description: >
  Generate a complete UI/UX design specification from a PRD output. Use this skill when a designer needs to translate product requirements into design artifacts: component inventory, interaction flows, design tokens, Figma structure guidelines, accessibility requirements, and responsive behavior. Trigger when the user says "create a design spec", "design from PRD", "design specification", "figma spec", "UI spec", or passes a PRD document for design handoff.
---

# Design Spec

Translate a Product Requirements Document (PRD) into a complete, implementation-ready design specification for UI/UX designers working in Figma.

## Use This Skill When

- Converting a PRD into design specifications
- Creating component inventory from user stories
- Defining interaction flows and states for each screen
- Preparing Figma structure and design token guidelines
- Producing design handoff documentation for developers

## Do Not Use This Skill When

- No PRD or requirement input is provided — run `generate-prd` first
- The task is about writing code or API design
- The request is only about brand identity or marketing visuals

## File I/O Convention

This skill is **step 2 of 4** in the product workflow:

```
[PM] generate-prd  →  prd.md
                         ↓
[Designer] design-spec reads prd.md  →  design-spec.md  ← YOU ARE HERE
                                           ↓
[QA] qa-testplan reads prd.md + design-spec.md  →  qa-testplan.md
                                                       ↓
[Dev] dev-execute reads all 3 files  →  dev-plan.md
```

Input file:  `docs/features/[feature-slug]/prd.md`
Output file: `docs/features/[feature-slug]/design-spec.md`

## Inputs

### Step 0: Read PRD File (REQUIRED — do this before anything else)

Before starting any phase:
1. Ask the user for `feature_slug` if not already provided.
2. Read the file `docs/features/[feature-slug]/prd.md` using the Read tool.
3. If the file does not exist, stop and say:
   ```
   PRD file not found at docs/features/[feature-slug]/prd.md
   Please ask the PM to run $generate-prd first and share the feature slug.
   ```
4. Extract all relevant information from the PRD before proceeding to Phase 1.

### Additional inputs to collect or infer:

- `design_system` — existing design system/component library name (e.g., Qiscus DS, Material, Ant Design) — ask if unknown
- `platform` — `web`, `mobile-ios`, `mobile-android`, `cross-platform`
- `figma_project_url` — existing Figma project URL if available
- `output_format` — `notion`, `table`, or `markdown`
- `mode` — `auto` or `interactive`

If inputs are missing, infer what is safe and ask focused questions for critical gaps.

## Execution Modes

### Interactive mode

- Execute one phase at a time.
- Stop after each phase and wait for designer confirmation before continuing.

### Auto mode

- Execute all phases in sequence.
- Make reasonable design assumptions.
- Surface assumptions clearly in the final output.

## Working Memory

Carry forward prior outputs:

- `screen_inventory`
- `component_inventory`
- `interaction_flows`
- `design_tokens`
- `accessibility_requirements`
- `figma_structure`
- `handoff_notes`

Update only affected sections on revision.

## Output Standards

- Focus on behavioral and visual specification, not aesthetic opinion.
- Every screen must have: states, transitions, and empty/error/loading variants.
- Components must reference the design system where possible.
- Separate assumptions from confirmed design decisions.
- All specs must be actionable by a developer without additional design context.

## Workflow

### Phase 1: PRD Parsing & Clarification

Goal:
- Extract design-relevant information from the PRD.
- Identify gaps that need designer decision before spec can proceed.

Instructions:
- Parse user journeys and user stories from PRD input.
- List all screens implied by the flows.
- Ask 3–5 focused questions about design system, platform, existing patterns, or constraints.

Output:
- Extracted screen list
- Clarification questions

Interactive stop:
- Wait for designer answers before proceeding.

### Phase 2: Screen & Flow Inventory

Goal:
- Produce a complete inventory of screens and their navigation relationships.

Output per screen:
- Screen name
- Entry point (what triggers navigation to this screen)
- Primary purpose
- Key user action on this screen
- Exit points (where user can go next)

Format:
```text
Screen: [Name]
- Entry: [trigger]
- Purpose: [one line]
- Primary Action: [CTA or main interaction]
- Exit Points: [list of next screens]
```

Rules:
- Cover all screens including empty states, error states, and loading states.
- Include modals, drawers, and overlays as sub-screens.

Interactive stop:
- Confirm screen inventory before detailing each screen.

### Phase 3: Component Inventory

Goal:
- Identify all UI components needed across all screens.

Output per component:
- Component name
- Design system reference (existing or new)
- Variants needed (size, state, theme)
- Screens where used
- Interaction behavior (clickable, input, static)

Rules:
- Prefer existing design system components over new ones.
- Flag new components that need to be created.
- Group by atomic level: Atoms → Molecules → Organisms → Templates.

Format:
```text
Component: [Name]
- DS Reference: [existing / new]
- Variants: [list]
- Used In: [screen list]
- Behavior: [description]
```

Interactive stop:
- Ask whether to revise component list or proceed.

### Phase 4: Interaction Flow Specification

Goal:
- Detail the interaction behavior for each screen and component.

Output per screen:
- Default state
- Loading state
- Empty state
- Error state
- Success state
- Hover / Focus / Active states (for interactive elements)
- Transition type (e.g., slide, fade, modal pop)
- Animation duration (ms)

Rules:
- Use standard durations: micro (100ms), short (200ms), medium (300ms), long (500ms).
- Every destructive action must have a confirmation step.
- Every form must specify validation timing (on blur, on submit, real-time).

Interactive stop:
- Ask whether interaction specs need revision.

### Phase 5: Design Token Specification

Goal:
- Define or reference design tokens relevant to this feature.

Output:
- Color tokens (primary, secondary, semantic: error, warning, success, info)
- Typography tokens (font family, size scale, weight, line height)
- Spacing tokens (base unit, scale)
- Border radius tokens
- Shadow/elevation tokens
- Motion tokens (easing curves, durations)

Rules:
- Reference existing design system tokens first.
- Only define new tokens when no existing token fits.
- Use semantic naming, not value-based naming (e.g., `color-danger` not `color-red-500`).

Interactive stop:
- Ask whether to revise tokens or proceed.

### Phase 6: Accessibility Requirements

Goal:
- Define accessibility specifications that must be met.

Output:
- Color contrast requirements (WCAG AA minimum)
- Keyboard navigation flow per screen
- ARIA roles and labels for interactive elements
- Touch target minimum sizes (mobile: 44×44px)
- Screen reader behavior for dynamic content
- Focus order specification

Rules:
- WCAG 2.1 AA is the minimum standard.
- Every interactive element must have a visible focus indicator.
- Error messages must be announced to screen readers.

Interactive stop:
- Ask whether accessibility spec needs adjustment.

### Phase 7: Figma Structure Guideline

Goal:
- Provide a recommended Figma file structure for this feature.

Output:
- Recommended page structure in Figma
- Frame naming convention
- Layer naming convention
- Component organization within local library
- Auto-layout and constraint guidelines
- Prototype flow connections to build

Format:
```text
Figma Structure:
Pages:
  - Cover
  - [Feature Name] / Flows
  - [Feature Name] / Components
  - [Feature Name] / Specs

Frame Naming: [Screen Name] / [State] / [Variant]
Layer Naming: [Component] / [Element] / [State]
```

Interactive stop:
- Ask whether Figma structure needs adjustment.

### Phase 8: Design Handoff Notes

Goal:
- Produce developer-facing handoff notes to accompany the Figma file.

Output:
- Behavior notes per screen (what code must handle, not just visual appearance)
- Animation spec (property, from value, to value, duration, easing)
- Responsive breakpoints and layout behavior
- Data binding notes (which fields are dynamic, which are static)
- API integration points visible in the UI
- Known design decisions and their rationale

Rules:
- Write for developers, not designers.
- Be specific about units (px, rem, %, not "a bit smaller").
- Flag every interaction that requires backend data.

Interactive stop:
- Ask whether handoff notes are complete before finalizing.

### Phase 9: Final Structured Output

Input:
- All prior phase outputs

Output:
- Format according to `output_format`

If `output_format = notion`:
- Prepare structured Notion-ready content with section headers and tables.

If `output_format = table`:
- Return tabular breakdown of screens, components, and tokens.

If `output_format = markdown`:
- Return clean markdown document suitable for Confluence or GitHub wiki.

Final check:
- All screens covered
- All components inventoried
- All states specified
- Figma structure provided
- Handoff notes complete

### Phase 10: Write Output File

Goal:
- Persist the design spec to disk so the next role (QA) can consume it.

Instructions:
- Write the complete design spec output to: `docs/features/[feature-slug]/design-spec.md`
- The file must contain all phase outputs in a single readable document.
- Do not truncate — include the full screen inventory, component inventory, interaction flows, design tokens, accessibility requirements, Figma structure, and handoff notes.

Confirm to the user:
```
Design spec saved to: docs/features/[feature-slug]/design-spec.md
Next step: hand prd.md + design-spec.md to the QA Engineer and ask them to run $qa-testplan
```

## Maturity Rules

### Must Do

- Reference existing design system components before proposing new ones.
- Cover all states for every screen (loading, empty, error, success).
- Write handoff notes in developer language.
- Make every design assumption explicit.

### Must Not Do

- Prescribe visual aesthetics (colors, font choices) outside of the design system.
- Skip accessibility specifications.
- Produce specs that require follow-up questions from developers.
- Invent screens not implied by the PRD.

## Deliverable Checklist

Before finishing, verify:

- [ ] Screen inventory complete
- [ ] Component inventory with DS references
- [ ] Interaction flows with all states
- [ ] Design token references
- [ ] Accessibility requirements
- [ ] Figma structure guideline
- [ ] Developer handoff notes
- [ ] Final structured output in requested format

## Bundled Resources

- `references/design-system-checklist.md` — checklist for design system component coverage.
- `references/figma-naming-convention.md` — Figma naming convention guide.
- Do not assume these files are loaded. Open them explicitly when needed.
