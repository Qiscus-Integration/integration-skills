# Stack: Frontend Vue.js

Profile ID: `fe-vue`
Use for: Vue.js SPA with the Composition API and Pinia.

---

## File Structure

```bash
src/
  views/
    [FeatureName]View.vue        ← route-level component
  components/
    [Feature]/
      [ComponentName].vue
  composables/
    use[FeatureName].ts          ← Composition API reusable logic
  stores/
    [feature].ts                 ← Pinia store
  services/
    [feature]Api.ts              ← API caller functions
  types/
    [feature].ts
```

---

## State Management

- **Local state**: `ref` / `reactive` for state that does not need to be shared
- **Shared state**: Pinia store — one store per domain/feature
- Do not use Vuex — use Pinia

---

## HTTP Client

- Axios via a shared `apiClient` instance (not direct `axios.get` calls)
- Configure the base URL, auth interceptors, and error handling in one place

```typescript
// services/[feature]Api.ts
export const featureApi = {
  getList: () => apiClient.get('/api/v1/[resource]'),
  create: (data: CreateInput) => apiClient.post('/api/v1/[resource]', data),
}
```

---

## Router

- Vue Router with **named routes** — do not hardcode path strings inside components
- Use route guards to protect pages that require authentication

---

## Testing

- **Vitest** for unit tests
- **Vue Test Utils** for component tests
- Test composables separately from components
