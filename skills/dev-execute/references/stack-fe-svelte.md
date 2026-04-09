# Stack: Frontend Svelte / SvelteKit

Profile ID: `fe-svelte`
Use for: Svelte SPA or SvelteKit with SSR/SSG.

---

## File Structure

```bash
src/
  routes/
    [feature]/
      +page.svelte               ← main page
      +page.server.ts            ← server-side load function
      +layout.svelte             ← layout wrapper when needed
      [id]/
        +page.svelte
        +page.server.ts
  lib/
    components/
      [Feature]/
        [ComponentName].svelte
    stores/
      [feature].ts               ← Svelte writable/derived store
    services/
      [feature]Api.ts
    types/
      [feature].ts
```

---

## Data Fetching

Use the **`load` function** in `+page.server.ts` for data that needs SSR:

```typescript
// routes/[feature]/+page.server.ts
import type { PageServerLoad } from './$types'

export const load: PageServerLoad = async ({ fetch, params }) => {
  const res = await fetch(`/api/v1/[resource]/${params.id}`)
  const data = await res.json()
  return { data }
}
```

For client-only fetches (after navigation), use `load` in `+page.ts` (without `.server`):

```typescript
// routes/[feature]/+page.ts
export const load = async ({ fetch }) => {
  const res = await fetch('/api/v1/[resource]')
  return { items: await res.json() }
}
```

---

## State Management

- **Svelte stores** (`writable`, `readable`, `derived`) for shared reactive state
- Use `writable` for state that can be changed externally
- Use `derived` for state computed from other stores
- Do not use stores for server data that can be fetched again through `load`

```typescript
// lib/stores/[feature].ts
import { writable } from 'svelte/store'

export const selectedItem = writable<Item | null>(null)
```

---

## Form Handling

- Use **Form Actions** (`+page.server.ts` with an `actions` export) for mutations
- Progressive enhancement: the form works without JavaScript, then is enhanced with `use:enhance`

```typescript
// routes/[feature]/+page.server.ts
export const actions = {
  create: async ({ request }) => {
    const data = await request.formData()
    // process data...
    return { success: true }
  }
}
```

```svelte
<!-- +page.svelte -->
<form method="POST" action="?/create" use:enhance>
  <input name="title" />
  <button type="submit">Save</button>
</form>
```

---

## Rendering Strategy

- **SSR** (default in SvelteKit): for public pages and pages that need SEO
- **CSR**: set `export const ssr = false` in `+page.ts` for auth-only pages
- **SSG**: set `export const prerender = true` for static content

---

## Testing

- **Vitest** for unit tests (stores, utilities, load functions)
- **Playwright** for E2E tests via `@sveltejs/kit/vite`
- **@testing-library/svelte** for component tests
