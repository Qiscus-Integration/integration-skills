# Bug Severity & Priority Classification Guide

Use this guide consistently across all QA test execution and bug reporting.

## Severity vs Priority

- **Severity** = impact on the system (technical measure)
- **Priority** = urgency to fix (business measure)

A bug can be high severity but low priority (e.g., crash in an unused admin panel),
or low severity but high priority (e.g., wrong logo on login page before a launch).

---

## Severity Levels

### S1 — Critical

- System crash, data loss, or complete feature failure with no workaround
- Security vulnerability (auth bypass, data exposure)
- Payment failure or data corruption

Examples:

- User cannot log in
- Data is permanently deleted incorrectly
- API returns 500 on all requests to a critical endpoint

### S2 — High

- Major feature broken, degraded significantly, but system still running
- No workaround available or workaround is too complex for end users

Examples:

- File upload fails for files > 5MB but should support up to 50MB
- Notification emails not sent
- Wrong data returned in report

### S3 — Medium

- Feature partially broken, workaround exists
- Minor data issue that does not cause data loss

Examples:

- Date format displays incorrectly in one locale
- Pagination skips page 3 in some conditions
- Form submits but shows wrong success message

### S4 — Low

- Cosmetic issue, typo, minor UI misalignment
- Non-blocking inconvenience

Examples:

- Button label has typo
- Icon slightly misaligned on mobile
- Tooltip text grammatically incorrect

---

## Priority Levels

### P1 — Must Fix Before Release

- Blocks release
- Blocks other test cases
- Customer-facing critical path affected

### P2 — Should Fix Before Release

- Significant user impact
- Can be waived with PM + PO written approval

### P3 — Fix in Next Sprint

- Noticeable but non-blocking
- Logged and scheduled

### P4 — Fix When Possible

- Minor cosmetic or edge case
- Can be deferred to backlog

---

## Bug Report Template

```bash
Title: [Short, descriptive title]
Severity: S1 / S2 / S3 / S4
Priority: P1 / P2 / P3 / P4
Feature: [Feature name]
Environment: [Staging / Production / specific build]
Browser/Device: [if applicable]

Steps to Reproduce:
1. [step]
2. [step]

Expected Result: [what should happen]
Actual Result: [what actually happened]
Frequency: Always / Intermittent / Rare

Attachments: [screenshot, video, log]
Related Test Case: [TC-XXX]
```
