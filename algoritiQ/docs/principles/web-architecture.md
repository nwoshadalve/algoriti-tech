# Web architecture principles

## Role in the system

The React SPA is the **staff and doctor dashboard**. It runs in a browser on the **Android tablet** (primary) and may also run on clinic laptops on the LAN.

- It is a **pure API client** of the local Backend API ([04-react-web-application](../architecture/04-react-web-application.md)).
- It MUST NOT store the queue database, allocate serial numbers, or talk to the TV or Flutter UI directly.
- Business rules and persistence live on the tablet host; the web app renders state and sends commands.

## Layering (dependencies point inward)

```text
routes/pages  →  features  →  core
 (composition)    (UI+hooks)   (api, theme, i18n, utils)
```

| Layer | Responsibility |
| --- | --- |
| **routes / app shell** | Router, layout, auth gate, error boundaries |
| **features** | Admin vs doctor flows; feature-specific components and hooks |
| **core** | API client, WebSocket client, design tokens, shared UI, i18n, logging |

- **MUST NOT** import one feature's internals from another feature — share via `core` or explicit `features/<x>/public` exports.
- **MUST NOT** call `fetch` from leaf components — use typed clients/hooks in `core/api` or feature `data` modules.

## Folder layout (`web/src`)

```text
src/
  app/           # bootstrap, router, providers, shell layout
  core/          # api, theme, ui primitives, i18n, config
  features/      # <feature>/components, hooks, types
  test/          # shared test helpers
```

## API integration

- Use **relative** API base paths (e.g. `/api/v1`) so the same build works when served from the tablet host today and a dedicated backend later.
- After WebSocket disconnect, **MUST** recover from a fresh snapshot ([architecture README](../architecture/README.md)).
- Commands that can be retried MUST send **idempotency keys** when the OpenAPI contract requires them.

## Roles

- **Admin**: clinic configuration, accounts, session oversight (exact screens defined in product specs).
- **Doctor**: queue and patient-facing workflow views allowed by policy.

Role checks are enforced **server-side**; the UI only hides or disables routes for UX — never for security.

## Defaults (change only with team agreement + doc update)

| Concern | Choice |
| --- | --- |
| Framework | React 19 + TypeScript |
| Build | Vite |
| Routing | `react-router-dom` |
| Styling | Tailwind CSS v4 first; component CSS only when Tailwind is insufficient |
| Unit / component tests | Vitest + Testing Library |
| Offline shell | `vite-plugin-pwa` (Workbox) |
