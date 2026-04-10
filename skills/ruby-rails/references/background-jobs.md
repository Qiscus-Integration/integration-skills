# Background Jobs Reference

## Use this when

- Adding or changing background jobs (Sidekiq, GoodJob, Solid Queue, or Active Job-based)
- Moving work out of the request cycle
- Reviewing retries, idempotency, and failure handling
- Coordinating mailers, notifiers, or expensive external calls

## Job design

- Pass ids or simple primitives, not rich in-memory objects.
- Re-load records inside the job and handle missing records intentionally.
- Keep each job focused on one responsibility.
- Make it safe enough for retries and duplicate execution where practical.

## Retry and failure handling

- Decide whether a failure should retry, warn, discard, or escalate.
- Avoid retrying forever when the error is permanent or the record is gone.
- Log failures with enough context to debug without exposing secrets.

## Async boundaries

- Use jobs for expensive notifications, integrations, fan-out work, and non-critical side effects.
- Do not move essential synchronous validation or authorization into the background.
- Be explicit about transaction boundaries if a job depends on just-created records.

## Review checklist

- Does this work belong in a job?
- Are arguments serializable and stable?
- Is retry behavior appropriate?
- Could the job run twice without corrupting data?
- Are downstream calls, emails, and notifications protected from noisy duplicates?
