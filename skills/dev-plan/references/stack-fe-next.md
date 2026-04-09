# Stack: Frontend Next.js

Profile ID: `fe-next`
Use for: Next.js SSR/SSG with the App Router (React Server Components).

---

## File Structure

```bash
src/
  app/
    [feature]/
      page.tsx                   ← Server Component by default
      loading.tsx                ← Loading UI (Suspense boundary)
      error.tsx                  ← Error boundary
      layout.tsx                 ← layout wrapper when needed
      [id]/
        page.tsx
  components/
    [feature]/
      [ComponentName].tsx        ← add `'use client'` only when needed
  lib/
    [feature]Api.ts              ← fetch functions (used by Server Components)
  types/
    [feature].ts
```

---

## Server Component vs Client Component

- **Default: Server Component** — no directive required
- Add `'use client'` **only** if the component needs:
  - Event handlers (`onClick`, `onChange`, etc.)
  - React hooks (`useState`, `useEffect`, etc.)
  - Browser APIs (`window`, `localStorage`, etc.)

Rule of thumb: push `'use client'` as low as possible in the component tree.

---

## Data Fetching

In a **Server Component** — fetch directly without an extra library:

```typescript
// app/[feature]/page.tsx
async function FeaturePage() {
  const data = await fetch('/api/v1/[resource]', {
    cache: 'no-store',          // for real-time data
    // next: { revalidate: 60 } // for data that may be cached for 60 seconds
  }).then(r => r.json())

  return <FeatureList data={data} />
}
```

In a **Client Component** — use React Query:

```typescript
'use client'
const { data, isLoading } = useQuery({
  queryKey: ['[resource]'],
  queryFn: () => fetch('/api/v1/[resource]').then(r => r.json()),
})
```

---

## Route Handlers (app/api/)

Use **only** for:

- BFF pattern (aggregation across multiple backends)
- Auth callbacks (OAuth, webhooks)
- Hiding secrets/API keys from the client

Do not create Route Handlers just to proxy a backend call — call the backend directly from the Server Component.

---

## State Management

- Server state: React Query for Client Components, direct fetch for Server Components
- Client state: Zustand for shared client state
- Do not store server data in a global store unless it is truly necessary

---

## Testing

- **Jest** + **React Testing Library** for component tests
- **Playwright** for E2E tests
- Server Components can be tested with `@testing-library/react` and async rendering
