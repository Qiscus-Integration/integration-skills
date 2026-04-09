# Stack: Frontend Nuxt.js

Profile ID: `fe-nuxt`
Use for: Nuxt.js SSR/SSG on top of Vue, for server-side rendering or static generation needs.

---

## File Structure

```bash
pages/
  [feature]/
    index.vue
    [id].vue
components/
  [Feature]/
    [ComponentName].vue
composables/
  use[FeatureName].ts
stores/
  [feature].ts                   ← Pinia store
server/
  api/
    [feature]/
      index.get.ts               ← Nuxt server routes (BFF layer when needed)
      index.post.ts
```

---

## Data Fetching

- Use `useFetch` or `useAsyncData` for **SSR-compatible** data fetching
- Do not mix `useFetch` with Axios on the same page
- For client-only fetches (dashboard, auth-gated flows), use `useFetch` with `{ server: false }`

```typescript
// inside the page
const { data, pending, error } = await useFetch('/api/v1/[resource]')
```

---

## Rendering Strategy

- **SSR**: for public pages (landing pages, product detail, blog) — better for SEO
- **CSR**: for dashboards and auth-protected pages — use `{ server: false }` or move the logic into `<ClientOnly>`
- **SSG**: for static content that rarely changes — use `nuxt generate`

---

## State Management

- Pinia for shared state
- Nuxt `useState` for state that must be shared between server and client rendering

---

## Server Routes (BFF)

Use `server/api/` only if:

- You need to hide API keys from the client
- You need aggregation across multiple backend endpoints
- Auth callbacks or webhook handlers

---

## Testing

- **Vitest** for unit tests of composables and utilities
- **@nuxt/test-utils** for component and page tests
