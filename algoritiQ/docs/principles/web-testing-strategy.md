# Web testing strategy

## Goals

- Prevent regressions in **auth shell**, **routing**, **responsive layout**, and **API error handling**.
- Keep tests fast enough to run on every change (`npm test`).

## Pyramid

| Level | Tool | When |
| --- | --- | --- |
| Unit | Vitest | Pure functions, mappers, reducers, API client helpers |
| Component | Vitest + Testing Library | Layout, a11y labels, role-based nav visibility |
| E2E | Playwright (future) | Full flows on tablet browser or LAN — add when API mock/stable |

## Critical paths (MUST have regression tests before release)

1. App shell renders at mobile, tablet, and desktop breakpoints (smoke).
2. Unauthenticated users are redirected to login (when auth is wired).
3. API unreachable → connection banner / error state (no infinite spinner).
4. Bengali + English string keys present for user-visible copy (when i18n is wired).

## Bug fixes

- **MUST** add a regression test that would fail without the fix, unless the bug is purely visual and covered by a snapshot test with justification in the PR.

## What we do not unit test

- Third-party libraries.
- Generated OpenAPI clients (test our thin wrapper instead).
- Pixel-perfect design — use semantic queries and roles.

How to write tests: [../standards/web-regression-tests.md](../standards/web-regression-tests.md).
