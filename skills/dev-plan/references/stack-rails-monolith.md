# Stack: Rails Monolith

Profile ID: `rails-monolith`
Use for: a single Rails application that serves all features. Default for most features.

---

## Architecture

- Rails API-only or full-stack Rails
- PostgreSQL as the primary database
- Redis for caching and the Sidekiq queue
- Sidekiq for background job processing
- RSpec + FactoryBot for testing

---

## File Structure

```bash
app/
  controllers/
    api/
      v1/
        [resource]_controller.rb     ← thin: parse params, call service, render
  services/
    [feature_name]/
      [action]_service.rb            ← business logic, one public method (`.call`)
  models/
    [model].rb                       ← validations, associations, scopes only
  serializers/
    [model]_serializer.rb            ← response shaping (Blueprint / AMS)
  policies/
    [model]_policy.rb                ← Pundit: who is allowed to do what
  jobs/
    [action]_job.rb                  ← Sidekiq jobs
  mailers/
    [feature]_mailer.rb
spec/
  requests/
    api/v1/
      [resource]_spec.rb             ← request specs (not controller specs)
  services/
    [feature_name]/
      [action]_service_spec.rb
  models/
    [model]_spec.rb
  factories/
    [model].rb                       ← FactoryBot, not fixtures
```

---

## Service Layer Rules

- **Controller**: parse params → `authorize` (Pundit) → call service → render. No other logic.
- **Service**: one public method `.call`. Return a result object or raise a typed exception.
- **Model**: no business logic. Only validations, associations, and named scopes.
- **Serializer**: response shaping only. Do not trigger additional queries inside it.
- **Policy**: every controller action that touches a resource must call `authorize`.

---

## API Response Envelope

```json
{
  "data": { ... },
  "meta": { "page": 1, "per_page": 25, "total": 100 },
  "errors": []
}
```

## Error Response Format

```json
{
  "errors": [
    { "code": "validation_failed", "field": "email", "message": "is invalid" },
    { "code": "not_found", "field": null, "message": "Record not found" }
  ]
}
```

---

## HTTP Status Codes

| Code | When |
| ------ | ------ |
| 200 | GET, PUT, PATCH succeed |
| 201 | POST succeeds (resource created) |
| 204 | DELETE succeeds (no body) |
| 400 | Bad request / validation error |
| 401 | Unauthenticated |
| 403 | Unauthorized (logged in but does not have permission) |
| 404 | Resource not found |
| 409 | Conflict (duplicate, state conflict) |
| 422 | Unprocessable entity |
| 500 | Server error — do not expose details to the client |

---

## Database (PostgreSQL)

- Primary key: `uuid` with `gen_random_uuid()`
- Always include: `created_at`, `updated_at`
- Migration filename: `[timestamp]_[verb]_[subject].rb`
  - Example: `20240101120000_add_status_to_orders.rb`
- Index naming:
  - Single: `idx_[table]_[column]`
  - Composite: `idx_[table]_[col1]_[col2]`
  - Unique: `udx_[table]_[column]`

### Zero-Downtime Migration

**Safe (does not lock the table):**

- Add a nullable column
- `ADD INDEX CONCURRENTLY`
- Add a new table
- Drop an index

**Requires a maintenance window or special handling:**

- Add a `NOT NULL` column without a default
- Rename a column
- Change a column type
- Add a constraint to existing data
- Large-scale data backfill → run it as a separate background job

---

## Background Jobs (Sidekiq)

- Use for: sending email, push notifications, heavy data processing, calling third-party APIs
- Naming: `[Action]Job` — example: `SendWelcomeEmailJob`, `ProcessPaymentJob`
- Always **idempotent** — safe to retry
- Always log: start, success, failure with context (`user_id`, `resource_id`, `job_id`)

---

## Testing (RSpec)

- Use **request specs** for API endpoints (not controller specs)
- FactoryBot for test data — do not use fixtures
- Shared examples for repeated auth/permission patterns
- Coverage minimum: 80%, target 100% for services
