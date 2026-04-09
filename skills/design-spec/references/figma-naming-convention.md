# Figma Naming Convention Guide

Consistent naming in Figma prevents confusion during handoff and collaboration.
Apply these conventions to all frames, layers, and components.

## Page Structure

```bash
Cover              ← Project overview, feature name, version, last updated date
[Feature] / Flows  ← User journey flows and screen connections
[Feature] / Specs  ← Detailed component and interaction specs
[Feature] / Components ← Local component library for this feature
Archive            ← Deprecated frames (do not delete, just move here)
```

## Frame Naming

Pattern: `[ScreenName] / [State] / [Variant]`

Examples:

- `Dashboard / Default / Desktop`
- `Dashboard / Loading / Desktop`
- `Dashboard / Empty / Mobile`
- `Login / Error / Mobile`
- `Checkout / Success / Desktop`

States: `Default`, `Loading`, `Empty`, `Error`, `Success`, `Disabled`
Variants: `Desktop` (1440px), `Tablet` (768px), `Mobile` (375px)

## Layer Naming

Pattern: `[Component] / [Element] / [State]`

Examples:

- `Button / Label / Default`
- `Input / Field / Focus`
- `Card / Header / Hover`
- `Nav / Item / Active`

Rules:

- No generic names: avoid `Frame 1`, `Rectangle 2`, `Group 3`
- Use Title Case for component names
- Use lowercase for states and elements
- Group related layers with a descriptive group name

## Component Naming (Local Library)

Pattern: `[Category] / [Name] / [Variant]`

Examples:

- `Button / Primary / Large`
- `Button / Secondary / Small`
- `Form / Input / Default`
- `Form / Input / Error`
- `Feedback / Toast / Success`

## Auto Layout Guidelines

- Always use Auto Layout for components that may change content size.
- Set horizontal padding and vertical padding explicitly (avoid "0 + hug").
- Name auto layout containers with their semantic role, not layout direction.

## Prototype Flow Naming

- Name each flow by the user journey it demonstrates.
- Example: `Flow: New User Registration`, `Flow: Checkout Happy Path`

## Version Notes

- Add version number to the Cover page.
- Use comments in Figma for revision notes, not renamed frames.
- When replacing a frame, move the old one to Archive — never delete.
