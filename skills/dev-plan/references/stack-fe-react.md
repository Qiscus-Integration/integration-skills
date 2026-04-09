# Stack: Frontend React

Profile ID: `fe-react`
Use for: React SPA with Zustand or Redux Toolkit and React Query.

---

## File Structure

```bash
src/
  features/
    [feature-name]/
      [FeatureName]Page.tsx      ← route entry / main page
      components/
        [ComponentName].tsx
        [ComponentName].test.tsx
      hooks/
        use[FeatureName].ts
      store/
        [feature]Slice.ts        ← Zustand store or Redux slice
      services/
        [feature]Api.ts
      types/
        index.ts
```

---

## State Management

- **Local state** (`useState`): UI state that does not need to be shared (modal open state, active tab)
- **Zustand**: simple to medium shared state — preferred because it has minimal boilerplate
- **Redux Toolkit**: only if the state is very complex with many interacting actions
- **Server state**: use **React Query** (`useQuery` / `useMutation`) — **do not** use `useEffect + useState` to fetch API data

```typescript
// services/[feature]Api.ts
export const featureApi = {
  getList: () => apiClient.get<Item[]>('/api/v1/[resource]'),
  create: (data: CreateInput) => apiClient.post<Item>('/api/v1/[resource]', data),
}

// inside the component
const { data, isLoading, error } = useQuery({
  queryKey: ['[resource]'],
  queryFn: featureApi.getList,
})

const mutation = useMutation({ mutationFn: featureApi.create })
```

---

## Router

- React Router v6 with **named/typed routes** where possible
- Use `loader` for route-level data fetching if you are using React Router v6.4+

---

## Testing

- **Jest** + **React Testing Library**
- Test behavior from the user's perspective — do not test implementation details (internal state, private methods)
- Use `msw` (Mock Service Worker) to mock APIs in tests — not direct function mocks
