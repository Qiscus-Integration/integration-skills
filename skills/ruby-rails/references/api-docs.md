# Backend Reference

## Runtime stack

Detect actual versions from `Gemfile.lock` and `.ruby-version` before making version-specific recommendations.

- Ruby (version from `.ruby-version` or `Gemfile`)
- Rails (version from `Gemfile.lock`)
- Puma (or the project's app server)
- PostgreSQL
- Redis (if present)
- Sidekiq or other background job processor (if present)

## Key gems and patterns

Check `Gemfile` to confirm which gems are actually used in the project. Common patterns include:

- Authorization: `pundit`, `cancancan`, or similar
- Admin UI: `avo`, `activeadmin`, `rails_admin` (if present)
- JSON rendering: `jbuilder`, `active_model_serializers`, `blueprinter`, or plain `render json:`
- UI components: `view_component` (if present)
- Migration safety: `strong_migrations` (if present)
- Notifications: `noticed` (if present)
- Authentication: `devise`, `omniauth`, JWT-based, or custom

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
- Write tests for every new feature or behavior change — no code without spec coverage.
