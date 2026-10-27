# Web regression test standards

Strategy: [principles/web-testing-strategy.md](../principles/web-testing-strategy.md).

## Stack

- **Vitest** — runner and assertions
- **@testing-library/react** — render and interact
- **@testing-library/jest-dom** — DOM matchers (`toBeVisible`, etc.)
- **jsdom** — browser environment

Setup: `src/test/setup.ts` (imported from `vite.config.ts`).

## Layout

```text
src/
  app/AppShell.test.tsx
  features/auth/LoginPage.test.tsx
  core/api/client.test.ts
  test/
    setup.ts
    render.tsx    # custom render with router + providers
```

Mirror production folder names; test file next to source or in `__tests__`.

## Naming

- `describe('ComponentName', () => { ... })`
- `it('should <behavior> when <condition>', () => { ... })`
- Regressions: `it('should not hide nav when viewport is md', () => { ... })` + comment `// regression: #123`

## Writing tests

- **Arrange – Act – Assert**; one behavior per test.
- Query priority: `getByRole` → `getByLabelText` → `getByText` → `getByTestId` (last resort).
- Use `userEvent` for clicks and typing.
- Mock API at the `fetch` boundary or inject a fake client — do not mock React internals.

## Responsive smoke tests

Use Testing Library + jsdom width is limited; for breakpoint-specific class behavior, assert on **document structure** (e.g. mobile nav button present) using `window.matchMedia` mock:

```ts
import { vi } from 'vitest'

vi.stubGlobal('matchMedia', (query: string) => ({
  matches: query.includes('min-width: 768px'),
  media: query,
  addEventListener: vi.fn(),
  removeEventListener: vi.fn(),
}))
```

Reset mocks in `afterEach`.

## Commands

```powershell
npm test              # watch in dev
npm run test:run      # CI single run
npm run test:coverage # optional coverage report
```

A task is not done until `npm run test:run` passes.
