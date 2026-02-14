# E2E Testing

Guidelines for writing effective end-to-end tests that verify critical user journeys without creating a brittle, slow test suite.

> **Scope**: Covers E2E/UI testing strategy, selector patterns, async handling, and flaky test prevention.
> For unit and integration testing, see [Testing Strategy](../testing-strategy/testing-strategy.md).

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [When to Write E2E Tests](#when-to-write-e2e-tests) |
| [Test Structure](#test-structure) |
| [Selector Strategy](#selector-strategy) |
| [Handling Asynchrony](#handling-asynchrony) |
| [Common Patterns](#common-patterns) |
| [Flaky Test Prevention](#flaky-test-prevention) |
| [Anti-Patterns](#anti-patterns) |
| [Red Flags](#red-flags) |

---

## Quick Reference

| Category | Guidance | Rationale |
| --- | --- | --- |
| **Always** | Test critical user journeys only | E2E tests are expensive — be selective |
| **Always** | Use explicit waits, never `sleep()` | Deterministic timing prevents flakes |
| **Always** | Isolate tests — no shared state | Order-independent execution |
| **Prefer** | `getByTestId` or semantic selectors | Survives refactoring and styling changes |
| **Prefer** | Page Object Model pattern | Encapsulates selectors, improves readability |
| **Prefer** | Auth state reuse across tests | Avoids redundant login flows |
| **Never** | Write E2E for logic unit tests can cover | Wrong pyramid level |
| **Never** | Depend on test execution order | Creates hidden coupling |
| **Never** | Hard-code timing delays | Non-deterministic, environment-dependent |

---

## Core Principles

| Principle | Guideline | Rationale |
| --- | --- | --- |
| **Selective coverage** | E2E should be ~5-10% of total test suite | Balances confidence against maintenance cost |
| **User-visible behavior** | Test what users see and do, not internal state | Aligns tests with business value |
| **Stable selectors** | Use test IDs and semantic queries over CSS | Refactoring should not break tests |
| **Deterministic** | Same inputs → same results, every time | Flaky tests erode team confidence |
| **Independent** | Each test runs in isolation | No cascading failures |

---

## When to Write E2E Tests

| Write E2E | Use Unit/Integration Instead |
| --- | --- |
| Critical user flows (login, checkout, signup) | Individual function behavior |
| Multi-step workflows spanning pages | Single-component interactions |
| Cross-browser/device verification needs | API contract validation |
| Regression for UI bugs that lower-level tests can't catch | Business logic calculations |
| Payment or financial flows | CRUD operations on a single model |

### Decision Framework

```text
Is this a critical user journey?
  ├─ YES → Does it span multiple pages or components?
  │         ├─ YES → Write E2E test ✓
  │         └─ NO  → Integration test is likely sufficient
  └─ NO  → Unit or integration test
```

---

## Test Structure

### Page Object Model

Encapsulate page interactions into reusable objects. Tests read like user stories.

```javascript
// Good: Page Object encapsulates selectors and actions
class LoginPage {
    constructor(page) {
        this.page = page;
        this.emailInput = page.getByTestId('email-input');
        this.passwordInput = page.getByTestId('password-input');
        this.submitButton = page.getByRole('button', { name: 'Sign in' });
        this.errorMessage = page.getByTestId('login-error');
    }

    async login(email, password) {
        await this.emailInput.fill(email);
        await this.passwordInput.fill(password);
        await this.submitButton.click();
    }
}

// Test reads like a user story
test('user can log in with valid credentials', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await page.goto('/login');

    await loginPage.login('user@example.com', 'validPassword123');

    await expect(page).toHaveURL('/dashboard');
});
```

```javascript
// Bad: Selectors scattered throughout test
test('login works', async ({ page }) => {
    await page.goto('/login');
    await page.locator('.login-form input.email').fill('user@example.com');
    await page.locator('.login-form input[type="password"]').fill('pass');
    await page.locator('.login-form .btn-primary').click(); // Fragile CSS selector
    // No page object — selectors are not reusable
});
```

### Test Isolation

Every test must start from a clean, known state:

| Technique | When |
| --- | --- |
| Database seeding/reset | Before each test or suite |
| API-driven setup | Create test data via API, not UI |
| Storage state files | Reuse authenticated sessions |
| Cleanup hooks | `afterEach` removes created data |

---

## Selector Strategy

Use selectors in this priority order:

| Priority | Selector Type | Example | Reliability |
| --- | --- | --- | --- |
| **1 (Best)** | Test ID | `getByTestId('submit-btn')` | Highest — explicit, refactor-proof |
| **2** | Semantic role | `getByRole('button', { name: 'Submit' })` | High — accessible, meaningful |
| **3** | Text content | `getByText('Sign in')` | Medium — breaks on copy changes |
| **4** | Label | `getByLabel('Email address')` | Medium — tied to form labels |
| **5 (Avoid)** | CSS selector | `.btn-primary`, `div > span:nth-child(2)` | Low — breaks on styling changes |
| **6 (Never)** | XPath | `//div[@class="form"]/input[1]` | Lowest — extremely brittle |

### Adding Test IDs

```html
<!-- Good: Explicit test ID, no impact on styling or behavior -->
<button data-testid="checkout-submit" class="btn btn-primary">
    Complete Purchase
</button>
```

> Test IDs should describe the element's purpose, not its appearance. Use `data-testid="checkout-submit"` not `data-testid="blue-button"`.

---

## Handling Asynchrony

### Explicit Waits

```javascript
// Good: Wait for specific condition
await page.waitForSelector('[data-testid="results-list"]');
await expect(page.getByTestId('result-count')).toHaveText('10 results');

// Good: Wait for network response
await Promise.all([
    page.waitForResponse(resp =>
        resp.url().includes('/api/search') && resp.status() === 200
    ),
    page.getByTestId('search-btn').click(),
]);
```

```javascript
// Bad: Arbitrary sleep — non-deterministic, slow
await page.click('#search');
await page.waitForTimeout(3000); // Will still fail if server takes 3.1 seconds
```

### Web-First Assertions

Use auto-retrying assertions when available:

| Framework | Pattern | Benefit |
| --- | --- | --- |
| Playwright | `await expect(locator).toHaveText('...')` | Auto-retries until timeout |
| Cypress | `cy.get(...).should('have.text', '...')` | Built-in retry |
| Selenium | Custom wait utilities needed | Manual polling required |

---

## Common Patterns

### Authentication Flow Reuse

```javascript
// Good: Authenticate once, reuse state across tests
// auth.setup.js — runs before all tests
test('authenticate', async ({ page }) => {
    await page.goto('/login');
    await page.getByTestId('email-input').fill('test@example.com');
    await page.getByTestId('password-input').fill('testpass');
    await page.getByRole('button', { name: 'Sign in' }).click();
    await page.waitForURL('/dashboard');

    // Save authentication state
    await page.context().storageState({ path: 'auth-state.json' });
});

// Subsequent tests reuse the saved state — no login per test
test.use({ storageState: 'auth-state.json' });
```

### Form Submission

```javascript
test('submit contact form', async ({ page }) => {
    await page.goto('/contact');

    // Fill form fields
    await page.getByLabel('Name').fill('Jane Doe');
    await page.getByLabel('Email').fill('jane@example.com');
    await page.getByLabel('Message').fill('Test inquiry');

    // Submit and verify
    await page.getByRole('button', { name: 'Send Message' }).click();
    await expect(page.getByTestId('success-message'))
        .toHaveText('Message sent successfully');
});
```

### Navigation and Routing

```javascript
test('breadcrumb navigation', async ({ page }) => {
    await page.goto('/products/category/item-123');

    // Verify breadcrumb structure
    const breadcrumbs = page.getByTestId('breadcrumbs');
    await expect(breadcrumbs.getByText('Products')).toBeVisible();
    await expect(breadcrumbs.getByText('Category')).toBeVisible();

    // Navigate via breadcrumb
    await breadcrumbs.getByText('Products').click();
    await expect(page).toHaveURL('/products');
});
```

---

## Flaky Test Prevention

| Symptom | Likely Cause | Fix |
| --- | --- | --- |
| Passes locally, fails in CI | Timing/resource differences | Add explicit waits, increase timeouts |
| Fails intermittently | Race condition | Use `waitFor` patterns, not `sleep` |
| Fails after unrelated changes | Fragile selector | Switch to `getByTestId` |
| Slow (> 30s per test) | Too many page navigations | Reuse auth state, minimize navigation |
| Fails on first run only | Missing test data setup | Add proper seeding in `beforeAll` |
| Different behavior across browsers | Browser-specific rendering | Use platform-aware fixtures |

### Dealing with Animations

```javascript
// Option 1: Disable animations in test environment
test.use({
    // Playwright: disable CSS animations
    contextOptions: { reducedMotion: 'reduce' },
});

// Option 2: Wait for animation to complete
await page.getByTestId('modal').waitFor({ state: 'visible' });
await page.waitForFunction(
    () => !document.querySelector('[data-testid="modal"]')
        .getAnimations().some(a => a.playState === 'running')
);
```

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| --- | --- | --- |
| **Ice cream cone** | More E2E than unit tests | Invert — use E2E only for critical flows |
| **Testing implementation** | E2E checks internal state or DOM structure | Test user-visible behavior |
| **Fragile selectors** | Tests break on CSS/styling changes | Use `getByTestId` or semantic queries |
| **Sleep-driven waits** | Non-deterministic, slow | Use explicit waits and auto-retry assertions |
| **Shared test state** | Test order matters, cascading failures | Isolate each test completely |
| **Testing everything E2E** | Slow suite, high maintenance cost | Push down to unit/integration level |
| **No cleanup** | Leftover data pollutes other tests | Use `afterEach`/`afterAll` hooks |
| **Screenshot-only assertions** | Fragile, environment-dependent | Assert on DOM state, use screenshots as backup |

---

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| E2E suite takes > 10 minutes | Prune — you have too many E2E tests | Slow suites get ignored |
| Using `sleep()` or `waitForTimeout()` | Replace with explicit waits | Non-deterministic timing causes flakes |
| Test depends on other tests running first | Isolate — add proper setup | Hidden coupling creates cascading failures |
| Writing E2E for single-function logic | Delete and write a unit test | Wrong pyramid level |
| E2E test checks CSS classes or DOM structure | Assert on user-visible text/behavior | Implementation detail testing |
| More than 20 E2E tests for a small app | Review and consolidate | Diminishing returns on coverage |

---

## See Also

- [Testing Strategy](../testing-strategy/testing-strategy.md) – Test pyramid, unit and integration patterns
- [Testing AI-Generated Code](../testing-ai-code/testing-ai-code.md) – Verifying AI output
- [Debugging with AI](../debugging-with-ai/debugging-with-ai.md) – When E2E tests reveal bugs
