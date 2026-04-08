# Backend Reference

## Runtime stack

- Ruby 3.1.3
- Rails 7.0.x
- Puma
- PostgreSQL
- Redis
- Sidekiq and sidekiq-scheduler

## Key gems and patterns

- `pundit` for authorization
- `avo` for admin UI
- `jbuilder` for JSON views
- `view_component` for reusable UI building blocks
- `strong_migrations` for migration safety
- `noticed` for notifications
- `omniauth` and JWT-related authentication helpers

## Common app folders

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

## Test stack

- RSpec
- FactoryBot
- Capybara
- WebMock

## Working style

- Prefer repository conventions over greenfield architecture.
- Keep business logic out of views.
- Check policies, jobs, migrations, and specs whenever backend behavior changes.
- Review performance whenever query paths change.
- Look for N+1 queries and missing eager loading on list or nested data flows.
- Keep request-time work small and move slow side effects to jobs when appropriate.
