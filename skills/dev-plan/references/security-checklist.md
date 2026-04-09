# Security Implementation Checklist

Apply this checklist to every feature implementation. Review before submitting a PR.

## Authentication & Authorization

- [ ] All endpoints require authentication (except explicitly public ones)
- [ ] Authorization checked at the service layer, not just the controller
- [ ] Resource ownership validated (user can only access their own resources unless admin)
- [ ] JWT tokens have appropriate expiry (access: 15min–1h, refresh: 7–30 days)
- [ ] Token refresh logic handles expired tokens gracefully
- [ ] Admin-only endpoints are explicitly gated, not just hidden

## Input Validation

- [ ] All user inputs validated before processing
- [ ] Validation happens server-side (never trust client-side only)
- [ ] String inputs have maximum length limits
- [ ] Numeric inputs have range validation
- [ ] File uploads: validate file type (MIME, not just extension), size limit enforced
- [ ] SQL queries use parameterized queries or ORM — never string concatenation
- [ ] HTML output is escaped to prevent XSS

## Data Protection

- [ ] Passwords hashed with bcrypt / argon2 (minimum 12 rounds)
- [ ] Sensitive fields (PII) encrypted at rest where required
- [ ] API responses never include passwords, tokens, or internal IDs that should not be exposed
- [ ] Logs do not contain passwords, tokens, or full credit card numbers
- [ ] Database backups encrypted

## API Security

- [ ] Rate limiting applied to authentication endpoints
- [ ] Rate limiting applied to resource-intensive endpoints
- [ ] CORS configured restrictively (not wildcard `*` in production)
- [ ] HTTPS enforced (HTTP → HTTPS redirect)
- [ ] Security headers set: `X-Content-Type-Options`, `X-Frame-Options`, `HSTS`
- [ ] API versioning in place to avoid breaking changes

## Error Handling

- [ ] Stack traces never exposed to client responses
- [ ] Error messages are user-friendly, not implementation-revealing
- [ ] 401 vs 403 used correctly (unauthenticated vs unauthorized)
- [ ] 500 errors logged with full context for debugging, but response is generic

## Frontend Security

- [ ] Sensitive data not stored in localStorage (use sessionStorage or memory)
- [ ] Auth tokens not accessible via JavaScript (HttpOnly cookies preferred)
- [ ] User-generated content rendered safely (no dangerouslySetInnerHTML without sanitization)
- [ ] External links use `rel="noopener noreferrer"`
- [ ] CSP (Content Security Policy) headers configured

## Dependency Security

- [ ] No known vulnerable dependencies (run `npm audit` / `bundle audit` / `pip-audit`)
- [ ] Dependencies pinned to exact versions in production
- [ ] No dev dependencies in production build

## OWASP Top 10 Quick Reference

| # | Risk | Check |
| --- | ------ | ------- |
| A01 | Broken Access Control | Authorization at service layer, resource ownership check |
| A02 | Cryptographic Failures | Passwords hashed, sensitive data encrypted, HTTPS enforced |
| A03 | Injection | Parameterized queries, input validation |
| A04 | Insecure Design | Threat modeling done before implementation |
| A05 | Security Misconfiguration | CORS, security headers, debug mode off in prod |
| A06 | Vulnerable Components | Dependency audit before release |
| A07 | Auth Failures | Token expiry, secure storage, rate limiting |
| A08 | Data Integrity | Signed serialized objects, dependency integrity checks |
| A09 | Logging Failures | Audit logs for auth events, no secrets in logs |
| A10 | SSRF | Validate and allowlist external URLs if feature fetches remote content |
