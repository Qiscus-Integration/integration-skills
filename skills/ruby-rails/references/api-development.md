# API Development Reference

## Use this when

- Building or changing JSON endpoints
- Reviewing controller responses and parameter handling
- Working with JSON serialization (Jbuilder, ActiveModelSerializers, Blueprinter, or plain `render json:`)
- Checking authentication and authorization boundaries

## Controller guidance

- Keep controllers thin: parse input, authorize, delegate work, return a response.
- Keep strong parameters explicit and close to the endpoint.
- Return appropriate status codes for validation, auth, and not-found failures.
- Avoid mixing too much response-shaping logic directly into the controller action.

## Response design

- Match the repository's existing JSON shape before inventing a new contract.
- Use the project's existing serialization approach consistently (Jbuilder, serializers, or plain `render json:`).
- Keep success and error payloads predictable.
- Be careful when changing response structure because clients may depend on it.

## Security and boundaries

- Validate and authorize before exposing data.
- Avoid leaking internal-only fields by default.
- Review pagination, filtering, and search endpoints for over-fetching risks.

## Review checklist

- Does the endpoint follow existing repository conventions?
- Are status codes and error responses correct?
- Is authorization enforced in the right place?
- Are query and serialization paths efficient for collection endpoints?
