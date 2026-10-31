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

## Toasts and popups in tests

- `renderAppAt` and `renderWithRouter` already wrap `ToastProvider`. Assert a toast **inside its region**: `within(screen.getByLabelText('Notifications')).findByText('…')`.
- When a refusal marks a field **and** raises a toast, the same words appear twice; assert both (`getAllByText(...)` has length 2, or one in the region and one under the field).
- Open a popup with the button that opens it, then query **inside** it: `const dialog = await screen.findByRole('dialog', { name: '…' })`, then `within(dialog)`. A popup's footer button and the page's button can share a name.
- Test that a popup stays open on failure, closes on success, and does not close while busy.
- For infinite scroll, stub `IntersectionObserver` and call the captured callback; test the *Load more* fallback with it set to `undefined`.
- Toaster timing tests use `vi.useFakeTimers({ shouldAdvanceTime: true })`.

## Icon buttons and tooltips in tests

- Find an icon button by its **accessible name** (`getByRole('button', { name: 'Edit: Desk Staff' })`), which includes who it is for.
- The tooltip is `aria-hidden`: query it with `findByRole('tooltip', { hidden: true })` after `user.hover(...)` (it waits for the hover pause) or `user.tab()` (shown at once).
- For a **disabled** icon button hover its wrapper (`button.parentElement`), since a disabled button receives no pointer events, and assert the reason text.
- Tooltip timing tests use `vi.useFakeTimers({ shouldAdvanceTime: true })`, like toasts.
