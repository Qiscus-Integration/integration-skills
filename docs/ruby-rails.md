# Skill: ruby-rails

Backend conventions for Rails codebases — models, validations, controllers, forms, services, queries, jobs, policies, mailers, and migrations.

---

## Trigger

Automatically activates when working in a Rails project, especially on `.rb` files.
Also activates when the user asks to build, review, or refactor backend code in a Rails codebase.

---

## Scope

This skill applies to the Rails monolith stack. For Rails-specific conventions used by `$dev-execute`, see [dev-execute.md](dev-execute.md) and `skills/dev-execute/references/stack-rails-monolith.md`.

---

## What This Skill Covers

- **Models** — validations, associations, named scopes, callbacks (when appropriate)
- **Controllers** — thin controllers: parse params, authorize, call service, render response
- **Services** — single-responsibility service objects with one public method (`.call`)
- **Policies** — Pundit authorization: who can perform which actions on which resources
- **Jobs** — Sidekiq background jobs: idempotent, always retryable, always logged
- **Mailers** — ActionMailer conventions and preview setup
- **Queries** — query objects for complex database queries outside of scopes
- **Migrations** — naming, index conventions, zero-downtime rules
- **RSpec** — request specs, factory conventions, shared examples

---

## Key Conventions

### Controller

```ruby
# app/controllers/api/v1/orders_controller.rb
def create
  authorize Order
  result = Orders::CreateService.call(permitted_params, current_user)
  render json: OrderSerializer.new(result), status: :created
end
```

### Service

```ruby
# app/services/orders/create_service.rb
class Orders::CreateService
  def self.call(params, user)
    new(params, user).call
  end

  def call
    # business logic here
  end
end
```

### Model

```ruby
# app/models/order.rb
class Order < ApplicationRecord
  belongs_to :user
  has_many :line_items

  validates :status, presence: true, inclusion: { in: %w[pending confirmed shipped] }

  scope :pending, -> { where(status: "pending") }
end
```

### Policy

```ruby
# app/policies/order_policy.rb
class OrderPolicy < ApplicationPolicy
  def show?
    record.user == user || user.admin?
  end

  def create?
    user.present?
  end
end
```

### Migration

```ruby
# db/migrate/20240101120000_add_status_to_orders.rb
def change
  add_column :orders, :status, :string, null: false, default: "pending"
  add_index :orders, :status
end
```

---

## Zero-Downtime Migration Rules

Safe (no table lock):

- Add a nullable column
- `add_index ... algorithm: :concurrently`
- Add a new table
- Drop an index

Requires a maintenance window or special handling:

- Add a `NOT NULL` column without a default value
- Rename a column
- Change a column type
- Add a constraint that validates existing rows
- Large data backfill — run as a background job instead

---

## Testing Conventions

- Use **request specs** for API endpoints (`spec/requests/`) — not controller specs
- Use **FactoryBot** for test data — not fixtures
- Use **shared examples** for repeated auth and permission patterns
- Coverage minimum: 80%; target 100% for service objects
