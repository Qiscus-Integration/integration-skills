# Stack: Microservice Go

Profile ID: `microservice-go`
Use for: a separate service with its own deployment lifecycle. Only use this when the feature is explicitly scoped as a microservice, not by default.

---

## Architecture

- Standalone Go service with its own database schema
- REST or gRPC — **decide in the ADR**, do not mix them without a clear reason
- PostgreSQL (its own schema, not shared with the Rails monolith)
- Redis if caching is needed

---

## File Structure

```bash
cmd/
  [service-name]/
    main.go
internal/
  handler/
    [resource]_handler.go         ← HTTP/gRPC handler (thin)
  service/
    [resource]_service.go         ← business logic
    [resource]_service_test.go
  repository/
    [resource]_repository.go      ← DB queries (interface + implementation)
    [resource]_repository_test.go
  model/
    [resource].go                 ← structs, no business logic
  middleware/
    auth.go
    logging.go
pkg/
  [shared-package]/
migrations/
  [timestamp]_[description].sql
```

---

## Service Layer Rules

- **Handler**: parse request → validate → call service → write response. No business logic.
- **Service**: business logic. Depends on a repository **interface**, not an implementation.
- **Repository**: SQL queries only. Return domain models.
- No global state — inject dependencies via constructors.
- Return errors explicitly — **do not `panic`** in production code paths.
- Every function that can fail must return `error` as the last return value.

---

## API Response (REST)

Success:

```json
{ "data": { ... }, "error": null }
```

Error:

```json
{ "data": null, "error": { "code": "NOT_FOUND", "message": "resource not found" } }
```

---

## HTTP Status Codes

| Code | When |
| ------ | ------ |
| 200 | GET, PUT, PATCH succeed |
| 201 | POST succeeds |
| 204 | DELETE succeeds |
| 400 | Validation error / bad request |
| 401 | Unauthenticated |
| 403 | Unauthorized |
| 404 | Resource not found |
| 409 | Conflict |
| 500 | Server error |

---

## Database (PostgreSQL)

- Primary key: `uuid` with `gen_random_uuid()`
- Always include: `created_at`, `updated_at`
- Migration filename: `[timestamp]_[description].sql`
  - Example: `20240101120000_create_orders.sql`
- Index naming follows the same convention as Rails: `idx_[table]_[column]`

### Zero-Downtime Migration

Same rules as the Rails monolith — see the shared guidance:

- Safe: add a nullable column, create indexes concurrently, add a new table
- Requires maintenance: `NOT NULL` without a default, rename, type change

---

## Testing (Go)

- **Table-driven tests** for the service and repository layers
- Mock repositories through **interfaces**, not a global mock library
- Integration tests against a real PostgreSQL instance: use `testcontainers-go` or `docker-compose` in CI
- Test files stay in the same package: `[file]_test.go`
- Do not test private functions directly — test through the public interface
