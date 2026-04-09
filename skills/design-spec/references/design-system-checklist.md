# Design System Component Coverage Checklist

Use this checklist when building component inventory for a new feature.
Check each category and mark whether existing DS components can cover the need, or a new component must be created.

## Navigation

- [ ] Top navigation bar / header
- [ ] Bottom navigation bar (mobile)
- [ ] Breadcrumb
- [ ] Sidebar / drawer
- [ ] Tab bar

## Forms & Inputs

- [ ] Text input (single line)
- [ ] Textarea (multi-line)
- [ ] Select / dropdown
- [ ] Multi-select
- [ ] Checkbox
- [ ] Radio button
- [ ] Toggle / switch
- [ ] Date picker
- [ ] File upload
- [ ] Search input with autocomplete

## Buttons & Actions

- [ ] Primary button
- [ ] Secondary button
- [ ] Tertiary / ghost button
- [ ] Icon button
- [ ] Floating action button (FAB)
- [ ] Link button

## Feedback & Status

- [ ] Loading spinner / skeleton
- [ ] Progress bar
- [ ] Toast / snackbar notification
- [ ] Alert / inline banner
- [ ] Empty state illustration + message
- [ ] Error state with retry action
- [ ] Success confirmation

## Data Display

- [ ] Table with sorting and pagination
- [ ] List item / row
- [ ] Card
- [ ] Badge / tag / chip
- [ ] Avatar
- [ ] Tooltip
- [ ] Popover

## Overlays

- [ ] Modal dialog
- [ ] Bottom sheet (mobile)
- [ ] Drawer / side panel
- [ ] Confirmation dialog
- [ ] Context menu

## Layout

- [ ] Page wrapper / container
- [ ] Grid system
- [ ] Divider / separator
- [ ] Spacer

---

## How to Use

For each component needed in the feature:

1. Check the list above.
2. If DS component exists → reference it by name and variant.
3. If DS component needs extension → document the new variant needed.
4. If no DS component exists → flag as "New Component" and define its spec.

Flag new components clearly in the component inventory with:

```bash
Status: NEW — must be added to design system
Owner: [designer name]
```
