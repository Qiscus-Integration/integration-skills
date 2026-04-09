# Tech Stack Conventions — Index

This file is an **index**. Do not add technical conventions here.
All conventions live in the per-profile files below.

## Stack Profiles

| Profile ID | File | When to use |
| ----------- | ------ | ------------- |
| `rails-monolith` | [stack-rails-monolith.md](stack-rails-monolith.md) | Single Rails application. **Default for most features.** |
| `microservice-go` | [stack-microservice-go.md](stack-microservice-go.md) | Separate service with its own deployment lifecycle. Use only when it is explicitly scoped as a microservice. |
| `fe-vue` | [stack-fe-vue.md](stack-fe-vue.md) | Vue.js SPA (Composition API + Pinia) |
| `fe-nuxt` | [stack-fe-nuxt.md](stack-fe-nuxt.md) | Nuxt.js SSR/SSG |
| `fe-react` | [stack-fe-react.md](stack-fe-react.md) | React SPA (Zustand / Redux Toolkit + React Query) |
| `fe-next` | [stack-fe-next.md](stack-fe-next.md) | Next.js SSR/SSG (App Router) |
| `fe-svelte` | [stack-fe-svelte.md](stack-fe-svelte.md) | Svelte / SvelteKit |

## How to Use It (for `dev-execute`)

1. **Step 0a**: Read only this index file. Do not read every file at once.
2. **Step 0c**: After the developer chooses a profile, read **only** the selected profile file.
3. Apply the conventions from that file consistently in every phase output.
4. Do not mix conventions from different profile files **except in a Composite Profile** scenario (see below).

## Composite Profile (Multi-Frontend)

Some projects use more than one frontend app within a single feature.
That is valid and must be handled explicitly, **not by mixing conventions**.

### When it happens

- **Nuxt + Vue**: Nuxt for public/marketing pages (SSR), Vue SPA for the dashboard/admin
- **Next + React**: Next for the landing page (SSR), React SPA for the app dashboard
- Other similar patterns: two separate apps with different deployment lifecycles

### How to handle it

1. Treat each app as a **separate entity** with a clear scope label.
2. Ask the developer to name the scope for each app, for example:
   - `public-app` → Nuxt
   - `dashboard-app` → Vue
3. Read **both** selected stack files.
4. In every phase output, use the scope label as a prefix:
   - `[public-app]` follows `fe-nuxt` conventions
   - `[dashboard-app]` follows `fe-vue` conventions
5. The task breakdown, file structure, and implementation plan must stay **separated by app** — do not merge them.

### What is still not allowed

- Writing Vue file paths inside a Nuxt-labeled section (or the reverse)
- Assuming both apps share the same state management or routing
- Combining tasks from two different apps into one task without a clear boundary explanation

## Shared Conventions (apply to every stack)

### Environment Variables

- Do not hardcode secrets in source code
- Commit `.env.example` with placeholders — do not commit `.env`
- Naming: `SCREAMING_SNAKE_CASE` — example: `DATABASE_URL`, `REDIS_URL`, `APP_ENV`
- Production secrets via CI/CD secrets injection (GitHub Actions, Vault, AWS SSM)

### Feature Flags

- Convention: `FEATURE_[NAME]_ENABLED=true|false`
- Clean up the flag and dead code within 2 sprints after full rollout is confirmed

### Selector Strategy for Frontend Testing

1. `data-testid="[component]-[element]"` — primary (most stable)
2. ARIA role + accessible name — secondary
3. Text content — for buttons/links only
4. CSS class — **never**
