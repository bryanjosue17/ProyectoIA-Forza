# Project Rules for Playwright Tests

This project uses Playwright for E2E testing. Follow these rules strictly when generating or modifying tests:

## Core Principles
1. **Never use hardcoded waits** (`page.waitForTimeout()`). Always rely on auto-waiting or `waitForSelector` / `waitForResponse`.
2. **Use `test.step()`** for organizing test logic into logical blocks, making reports readable.
3. **Use the Page Object Model (POM)** for reusable components. Do not dump all logic into a single spec file.
4. **Use Locators** accurately (`getByRole`, `getByTestId`, `getByText`). Avoid relying on fragile CSS/XPath unless strictly necessary.

## Architecture & Authentication
- Frontend Colaborador runs on `localhost:30081`.
- Frontend RRHH runs on `localhost:30082`.
- Keycloak runs on `localhost:30080`.
- Both frontends require login via Keycloak PKCE flow.
- Always implement an AuthGuard bypass or login routine at the start of the tests.

## Snapshots
- Set `screenshot: 'only-on-failure'` in the Playwright config to avoid cluttering storage.
