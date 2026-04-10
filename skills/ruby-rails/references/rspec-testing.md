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

Every new feature or behavior change requires accompanying tests. This is not optional — no code ships without spec coverage.

- Cover the happy path and the most important failure paths.
- Include authorization or policy coverage when access rules can change.
- Add regression coverage for the exact bug being fixed.
- Verify important async side effects rather than assuming enqueueing is enough.

## New feature testing requirements

Match the spec type to what was added:

- **New model** → model spec covering validations, scopes, associations, and key domain methods.
- **New endpoint** → request spec covering success (200/201), auth failure (401/403), validation failure (422), and not-found (404).
- **New service or form** → unit spec covering the main flow, edge cases, and error paths.
- **New background job** → job spec verifying enqueue behavior, retry safety, and side effects.
- **Bug fix** → regression spec that reproduces the original bug before confirming the fix.
- **New policy** → policy spec covering allowed and denied cases for each action.

## Factory guidance

- Keep factories minimal and explicit.
- Prefer traits over huge default objects.
- Avoid creating unrelated records that make the spec harder to understand.

## Review checklist

- Does the spec prove the behavior that changed?
- Is the test level appropriate for the risk?
- Are edge cases and failure paths covered where they matter?
- Does the spec stay readable without excessive setup?
- Does every new public method or endpoint have at least one spec?
- Do the specs pass when run in isolation (`bundle exec rspec <spec_file>`)?
