# RSpec Testing Reference

## Use this when

- Adding or updating backend tests
- Choosing the right spec type
- Writing regression coverage for bugs
- Verifying policies, services, jobs, and request flows

## Preferred testing shape

- Follow the nearest existing spec style before introducing a new pattern.
- Use request specs for endpoint behavior, response codes, authorization, and serialized output.
- Use model specs for validations, scopes, and small domain behavior.
- Use service or form specs for multi-step backend workflows.
- Use job specs when retry logic, enqueue behavior, or background side effects matter.

## Coverage expectations

- Cover the happy path and the most important failure paths.
- Include authorization or policy coverage when access rules can change.
- Add regression coverage for the exact bug being fixed.
- Verify important async side effects rather than assuming enqueueing is enough.

## Factory guidance

- Keep factories minimal and explicit.
- Prefer traits over huge default objects.
- Avoid creating unrelated records that make the spec harder to understand.

## Review checklist

- Does the spec prove the behavior that changed?
- Is the test level appropriate for the risk?
- Are edge cases and failure paths covered where they matter?
- Does the spec stay readable without excessive setup?
