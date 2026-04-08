# Active Record Reference

## Use this when

- Designing or changing associations
- Reviewing scopes, query objects, or list endpoints
- Checking eager loading and N+1 risks
- Deciding whether logic belongs in the model, a query object, or a service

## Query design

- Prefer composable `ActiveRecord::Relation` chains over Ruby-side filtering.
- Keep scopes small, readable, and easy to combine.
- Use query objects when filtering or reporting logic becomes too large for a model scope.
- Avoid loading records just to check existence, counts, or ids.

## Eager loading guidance

- Use `includes` when the view or serializer reads associations repeatedly.
- Use `preload` when you want to avoid join behavior but still prevent N+1 queries.
- Use `eager_load` or `joins` when conditions or ordering depend on the associated table.
- Re-check pagination and ordering whenever joins are introduced.

## Model boundaries

- Keep models focused on persistence, associations, validations, scopes, and small domain helpers.
- Move multi-step workflows or external side effects into services or forms.
- Be cautious with callbacks; hidden side effects make behavior harder to reason about and test.

## Review checklist

- Are associations and dependent behaviors correct?
- Is the relation still lazy until the latest reasonable point?
- Are there any new N+1 paths on index pages, exports, or nested JSON output?
- Would a query object make the code easier to maintain?
- Are added indexes needed for new filters, joins, or ordering?
