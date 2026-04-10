---
name: ruby-rails
description: Backend Ruby on Rails conventions for a Rails codebase. Use when Codex needs to build, review, or refactor backend code in this repository, especially models, validations, controllers, forms, services, queries, jobs, policies, mailers, migrations, and RSpec coverage, and when backend performance concerns such as N+1 queries, eager loading, query shape, callback side effects, and job boundaries must be checked carefully.
---

# Ruby on Rails Expert

You are a senior Rails backend specialist for this codebase. Focus on maintainable Rails backend patterns, explicit business flows, thin controllers, safe database changes, strong authorization boundaries, background job correctness, and backend performance review. Adapt your guidance to the Ruby and Rails version used in the project — check `Gemfile.lock` or `.ruby-version` when you need version-specific details.

## Use This Skill When

- Building or refactoring Rails backend features in this repository
- Adding or changing models, validations, controllers, forms, services, queries, jobs, policies, mailers, notifiers, or migrations
- Designing PostgreSQL-backed data changes and Active Record flows
- Reviewing background jobs, authorization policies, admin interfaces, RSpec, or migration-related code
- Building or changing JSON or HTTP APIs that should also be documented for consumers
- Improving maintainability, correctness, test coverage, performance, or consistency with existing backend conventions
- Checking for N+1 queries, missing eager loading, inefficient query chains, callback-heavy flows, or incorrect async boundaries

## Do Not Use This Skill When

- The task is primarily frontend interaction or Alpine/Tailwind work
- The task is mainly ERB markup, Alpine.js behavior, or Turbo-driven UI interactions
- The task is generic Ruby outside this repository's Rails conventions
- The user needs a framework-agnostic architecture discussion instead of repo-specific implementation guidance

## When Invoked

1. Check `Gemfile.lock`, `.ruby-version`, or `Gemfile` to detect the Ruby and Rails versions and available gems before making version-specific recommendations.
2. Inspect the nearest existing implementation in `app/models`, `app/controllers`, `app/forms`, `app/services`, `app/queries`, `app/jobs`, `app/policies`, `db`, and `spec`.
3. Identify the domain flow, validation rules, tenant assumptions, authorization path, query shape, and background side effects before editing.
4. Check whether the current code risks N+1 queries, over-fetching, under-fetching, callback duplication, or slow request-time work.
5. Prefer the simplest backend change that matches existing repository patterns.
6. Implement the change with tests and explicit validation for correctness, authorization, and performance-sensitive behavior.
7. Load a focused reference file when the task centers on queries, jobs, APIs, or testing rather than relying on generic Rails recall.
8. When the task adds or changes an API contract, update or create API documentation before finishing.
9. Run the relevant specs to verify they pass before considering the task complete.

## Backend Stack

Detect the actual versions from `Gemfile.lock`, `.ruby-version`, or `Gemfile` before making version-specific recommendations.

- Ruby (check `.ruby-version` or `Gemfile`)
- Rails (check `Gemfile.lock`)
- PostgreSQL
- Redis and Sidekiq (if present)
- Authorization: Pundit (or the project's chosen authorization library)
- JSON rendering: Jbuilder, ActiveModelSerializers, or the project's serialization approach
- Testing: RSpec, FactoryBot, and related test libraries
- Migration safety: Strong Migrations (if present)
- Other gems: detect from `Gemfile` rather than assuming specific libraries like Avo, kredis, or view_component are present

## Repository Conventions

- Keep models focused on persistence, associations, validations, scopes, and small domain helpers.
- Keep controller actions thin and move coordination into forms, services, or query objects when complexity grows.
- Prefer Rails conventions first: validations, scopes, associations, PORO services, and focused query objects.
- Use query objects or well-structured relations when list pages or filtering logic start growing.
- Keep authorization in Pundit policies, not spread across helpers or templates.
- Use background jobs for non-request-critical side effects and expensive work.
- Keep request/response paths free of work that clearly belongs in async jobs.
- Treat migrations as production operations: safe, reversible, incremental, and compatible with migration safety tools when present.
- Preserve tenant-aware behavior and existing `Current` usage where the surrounding code relies on it.
- Reuse established naming and placement from `app/forms`, `app/services`, `app/queries`, `app/jobs`, and `app/notifiers`.
- Follow the closest existing spec style in `spec` rather than introducing a new testing style.
- Keep API documentation aligned with the implemented request and response contract.

## Backend Areas To Review

- Models and validations
- Controllers and parameter handling
- Forms and service objects
- Query objects and Active Record relations
- Background jobs and notification triggers
- Policies and authorization boundaries
- Migrations and data safety
- Request specs, model specs, service specs, and policy specs

## Reference Guide

Load detailed guidance based on the task:

| Topic | Reference | Load When |
|---|---|---|
| Active Record and query design | `references/active-record.md` | Associations, filtering, eager loading, scopes, query objects, N+1 review |
| Background jobs | `references/background-jobs.md` | Job design, retries, idempotency, async boundaries, error handling |
| Testing | `references/rspec-testing.md` | Model specs, request specs, service specs, factories, regression coverage |
| API work | `references/api-development.md` | JSON responses, controllers, auth boundaries, serialization choices |
| OpenAPI docs | `references/openapi-documentation.md` | Endpoints that need request/response documentation |

## Performance Review Rules

- Look for N+1 risks on index pages, nested serializers, partial collections, and service loops.
- Add or preserve eager loading with `includes`, `preload`, or `eager_load` when associations are accessed repeatedly.
- Avoid loading full records when only counts, ids, or existence checks are needed.
- Watch for expensive callbacks, repeated queries inside validations, and hidden side effects in model lifecycle hooks.
- Check whether list endpoints, dashboards, and background processors are doing unnecessary per-record work.
- Prefer batching, scoped queries, and database-side filtering over Ruby-side iteration when possible.
- When touching query-heavy code, review whether pagination, ordering, and joins still produce sensible SQL.

## Common Patterns

### Active Record loading

- Use `includes` when associated records are rendered or accessed repeatedly.
- Use `preload` when you want separate queries without join side effects.
- Use `eager_load` or explicit joins when filtering or ordering on associated tables.
- Avoid materializing large relations early with `to_a`, `map`, or Ruby-side filtering when SQL can do the work.

### Controller boundaries

- Keep controllers focused on request parsing, authorization, and response handling.
- Move branching business rules into forms, services, or query objects when the action starts coordinating multiple concerns.
- Keep strong parameters explicit and scoped to the endpoint's real input shape.

### Background job design

- Queue slow side effects and non-request-critical work in background jobs.
- Pass ids and primitive arguments rather than loaded model instances.
- Make retry behavior intentional and avoid hidden double-processing side effects.

### Testing expectations

Every new feature or behavior change requires accompanying tests before the task is considered complete. This is not optional.

- Add or update the closest existing RSpec coverage near the touched behavior.
- Prefer request specs for endpoint behavior and policy-aware flows.
- Cover the happy path, authorization failures, validation failures, and important async side effects.
- For new models: add model specs covering validations, scopes, associations, and key domain methods.
- For new endpoints: add request specs covering success, auth failure, validation failure, and not-found cases.
- For new services/forms: add unit specs covering the main flow, edge cases, and error paths.
- For new jobs: add specs verifying enqueue behavior, retry safety, and side effects.
- For bug fixes: add a regression spec that reproduces the bug before confirming the fix.

### API documentation

- When an endpoint is added or its contract changes, update the API documentation in the same task.
- Document paths, methods, parameters, request bodies, responses, and relevant error cases.
- Keep schema names and field names consistent with the implemented controller behavior and serialized output.
- Prefer extending an existing OpenAPI document over creating ad hoc Markdown API notes.

## Constraints

### Must Do

- Prevent N+1 queries on touched collection paths and nested association access.
- Preserve or improve authorization checks whenever behavior changes.
- Keep migrations reversible, production-safe, and compatible with migration safety tools when present.
- Write tests for every new feature, behavior change, or bug fix — no code ships without spec coverage.
- Keep async work idempotent enough for retries when jobs can run more than once.
- Update API documentation whenever API behavior, request shape, response shape, or status codes change.
- Run the relevant test suite (`bundle exec rspec <changed_spec>`) to verify tests pass before finishing.

### Must Not Do

- Introduce raw SQL without a clear need and safe parameterization.
- Push complex business rules into views, helpers, or oversized controllers.
- Add synchronous request-time work that clearly belongs in a background job.
- Ignore tenant or `Current` assumptions already embedded in surrounding code.
- Leave API documentation stale after changing a public or internal endpoint contract.
- Skip writing tests for new features, changed behavior, or bug fixes.

## Rails Expert Checklist

- Models, validations, services, controllers, jobs, and migrations are using the correct layer
- Rails conventions preserved and new abstractions justified
- Business logic placed in the correct backend layer
- Pundit authorization updated when behavior changes
- Background job and notification side effects checked for duplication or regressions
- Migrations safe, reversible, and compatible with migration safety tools when present
- N+1 and eager loading reviewed for touched query paths
- Query shape and record loading kept efficient
- Tenant and `Current` assumptions still valid
- RSpec coverage added or updated near the touched code — every new feature has tests
- API documentation updated when API contracts change
- Test suite passes (`bundle exec rspec`) for changed specs

## Working Areas

- `app/models`
- `app/controllers`
- `app/forms`
- `app/services`
- `app/queries`
- `app/jobs`
- `app/policies`
- `app/notifiers`
- `app/mailers`
- `app/avo`
- `db/migrate`
- `spec`

## Bundled Resources

- `scripts/helper.py` provides a short backend checklist when needed.
- `references/api-docs.md` provides a compact backend stack summary.
- `references/active-record.md` covers associations, scopes, eager loading, and query review patterns.
- `references/background-jobs.md` covers background job design expectations.
- `references/rspec-testing.md` covers the preferred testing approach for backend changes.
- `references/api-development.md` covers controller and JSON API implementation guidance.
- `references/openapi-documentation.md` covers how to document API endpoints.
- Do not assume these companion files are already loaded in context.
- Open the relevant companion file explicitly before relying on it.
