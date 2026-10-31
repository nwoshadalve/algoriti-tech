# Industry standards we align with

This project intentionally follows widely adopted practices so new contributors and AI tools can rely on familiar patterns.

## Accessibility — WCAG 2.2 (Level AA target)

- Text contrast ≥ 4.5:1 (normal text), ≥ 3:1 (large text / UI components).
- Keyboard operability for all interactive controls; visible focus rings.
- Name, role, value for custom widgets (`aria-*`, semantic HTML first).
- Do not convey state by color alone.
- Reference: [W3C WCAG 2.2](https://www.w3.org/TR/WCAG22/)

## Web platform — Progressive Web Apps

- Installable optional; **offline-capable shell** required for clinic use.
- Web App Manifest + service worker per [MDN PWA guide](https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps).

## Security — OWASP ASVS / API Top 10 (frontend slice)

- No secrets in client bundles; minimize sensitive data in browser storage.
- CSRF: follow API cookie/session documentation.
- Reference: [OWASP ASVS](https://owasp.org/www-project-application-security-verification-standard/)

## TypeScript

- `strict` mode enabled; no `any` without a one-line comment explaining why.
- Prefer `unknown` over `any` at API boundaries; narrow with type guards or schema validation when OpenAPI types exist.

## React

- Function components + hooks; no class components.
- Effects only for synchronization (subscriptions, DOM bridges) — not for deriving state that belongs in render or event handlers.
- Reference: [React docs](https://react.dev/)

## CSS — Tailwind-first

- Utility classes for layout, spacing, typography, and responsive breakpoints.
- Component-specific `.css` only when Tailwind cannot express the design (complex animations, third-party overrides).
- Reference: [Tailwind CSS](https://tailwindcss.com/docs)

## Testing — Testing Library principles

- Query by role/label, not by class or test id, unless necessary.
- Assert user-visible outcomes, not implementation details.
- Reference: [Testing Library guiding principles](https://testing-library.com/docs/guiding-principles)

## API contracts

- Backend OpenAPI is the source of truth for request/response shapes.
- Clients generated or hand-written MUST stay in sync with the spec in the monorepo when it lands.

## Git & review

- Small, focused PRs; conventional commit style encouraged.
- Definition of done for web: `npm run lint`, `npm test`, `npm run build` pass.
