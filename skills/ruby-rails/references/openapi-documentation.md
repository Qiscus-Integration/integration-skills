# OpenAPI Documentation Reference

## Use this when

- Adding a new endpoint
- Changing request parameters or body shape
- Changing response payloads or status codes
- Needing to document an internal or public API contract

## Output location

- Store API documentation in `docs/openapi.yml`.
- Update the existing file when it already exists instead of creating duplicate API docs in other formats.

## What to document

- Path and HTTP method
- Summary or short description
- Path, query, and header parameters when applicable
- Request body schema for write operations
- Response schemas for success and important failure cases
- Relevant status codes such as `200`, `201`, `400`, `401`, `403`, `404`, `422`, and `500`

## Schema guidance

- Keep field names aligned with the actual JSON returned by the controller or Jbuilder templates.
- Reuse schema components when the same payload shape appears in multiple endpoints.
- Mark required fields clearly.
- Include enum values when the API accepts or returns a finite set of values.

## Good workflow

1. Implement or update the endpoint.
2. Verify the real request and response contract from controller code, serializers, Jbuilder, and request specs.
3. Update `docs/openapi.yml` to match the implemented behavior.
4. Make sure error responses and validation failures are documented when they matter to consumers.

## Review checklist

- Does the OpenAPI path match the real route?
- Do the request and response schemas match the implemented code?
- Are status codes accurate?
- Are auth or permission-related failures documented where needed?
- Would another developer be able to integrate from `docs/openapi.yml` without reading controller code first?
