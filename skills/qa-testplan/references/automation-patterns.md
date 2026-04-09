# Automation Test Patterns & Anti-Patterns

Reference guide for writing maintainable, reliable automation tests.

## Core Patterns

### Page Object Model (POM)

Encapsulate UI interactions in page objects. Tests should not contain selectors.

```typescript
// Good — Page Object
class LoginPage {
  get emailInput() { return cy.get('[data-testid="email-input"]') }
  get passwordInput() { return cy.get('[data-testid="password-input"]') }
  get submitButton() { return cy.get('[data-testid="login-submit"]') }

  login(email: string, password: string) {
    this.emailInput.type(email)
    this.passwordInput.type(password)
    this.submitButton.click()
  }
}

// Good — Test
it('should login with valid credentials', () => {
  const loginPage = new LoginPage()
  loginPage.login('user@example.com', 'password123')
  cy.url().should('include', '/dashboard')
})
```

### Selector Strategy (Priority Order)

1. `data-testid` — most stable, not affected by style changes
2. ARIA roles (`getByRole`) — accessible and semantic
3. ARIA labels (`getByLabelText`) — for form elements
4. Text content (`getByText`) — for buttons and links
5. CSS class — last resort, avoid coupling to styling

```typescript
// Best
cy.get('[data-testid="submit-button"]')

// Good (Playwright)
page.getByRole('button', { name: 'Submit' })

// Avoid
cy.get('.btn-primary.submit')  // breaks when styling changes
cy.get('div > form > button:nth-child(2)')  // fragile
```

### Test Data Management

```typescript
// Use fixtures for static data
cy.fixture('users/valid-user').then((user) => {
  loginPage.login(user.email, user.password)
})

// Use factories for dynamic data
const newUser = UserFactory.create({ role: 'admin' })

// Never hardcode production IDs in tests
// Bad
cy.visit('/users/12345')

// Good
cy.createUser().then((userId) => cy.visit(`/users/${userId}`))
```

### API Stubbing vs Real API

| Scenario | Use Real API | Use Stub |
| ---------- | ------------- | --------- |
| E2E happy path | Yes | No |
| Error states (500, 404) | No | Yes |
| Slow network behavior | No | Yes |
| CI pipeline | Prefer real | For flaky endpoints |
| Isolated component test | No | Yes |

---

## Anti-Patterns to Avoid

### Hard Sleeps

```typescript
// Bad — brittle, slow, and non-deterministic
cy.wait(3000)

// Good — wait for a condition
cy.get('[data-testid="success-toast"]').should('be.visible')
cy.intercept('POST', '/api/submit').as('submitRequest')
cy.wait('@submitRequest')
```

### Test Interdependence

```typescript
// Bad — test 2 depends on test 1 creating data
it('creates a user')  // test 1
it('edits the user')  // test 2 — fails if test 1 didn't run

// Good — each test sets up its own data
beforeEach(() => { cy.createUser().as('testUser') })
it('edits the user', function() { /* uses this.testUser */ })
```

### Asserting Implementation Details

```typescript
// Bad — tests internal state, not user-visible behavior
expect(component.state.isLoading).toBe(false)

// Good — test what the user sees
cy.get('[data-testid="loading-spinner"]').should('not.exist')
cy.get('[data-testid="user-list"]').should('be.visible')
```

### Over-Stubbing

```typescript
// Bad — stub everything, tests don't reflect reality
cy.intercept('GET', '/api/**', { fixture: 'mock-everything' })

// Good — only stub what must be controlled (errors, slow responses)
cy.intercept('GET', '/api/payments', { statusCode: 500 })
  .as('paymentError')
```

---

## CI/CD Integration Checklist

- [ ] Tests run in headless mode
- [ ] Test results output in JUnit XML format (for CI report)
- [ ] Screenshots and videos captured on failure
- [ ] Tests parallelized by spec file
- [ ] Retry on failure: max 2 retries (not more — masks real flakiness)
- [ ] Environment variables injected via CI secrets (never hardcoded)
- [ ] Separate CI stage: smoke → full regression (smoke fails fast)
- [ ] Failure notification to team Slack/email channel
