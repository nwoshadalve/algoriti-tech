# AlgoritiQ Web Dashboard

React + TypeScript single-page application for **admin** and **doctor** clinic workflows. Runs in the browser on the **Android tablet** (served by the local Backend API) and on clinic laptops on the LAN.

## Features (v1 foundation)

- **Two-step admin setup**: activation code (`/`) → account registration (`/register`), aligned with [`docs/api/openapi.yaml`](../docs/api/openapi.yaml) (`GET /setup/status`, `POST /setup/admin`). The activation code is stored in the session until registration completes.
- **Sign-in**: `/login`, **forgot password** (`/forgot-password`: username, then the tablet's activation key, then the new password) and a signed-in `/home`, aligned with `POST /auth/login`, `/auth/password/reset/start`, `/auth/password/reset`, `GET /me` in the OpenAPI file. The token lives in `sessionStorage`; see [authentication](../app/docs/features/authentication.md).
- Responsive layout, **mobile first, from 280 px**: the header wraps instead of overflowing, a "Step 2 of 3" strip replaces the step list below `lg`, cards and fields grow with the screen (touch targets 44 px or more), the page keeps clear of notches, and long names or Bengali text wrap instead of widening the page. Tablet (`sm`/`md`) centres one card; laptop (`lg+`) shows the steps beside it.
- **Light / dark / system** theme (top-right toggle); brand wordmark switches automatically.
- **Tailwind CSS v4** for styling (component CSS only when Tailwind is insufficient).
- **Offline-capable app shell** via service worker (`vite-plugin-pwa`) — icons and wordmarks from `branding/logo/algoritiq/web` in `public/`.
- API client uses relative paths (`/api/v1`) against the tablet host.
- **Loading UI:** `BrandLoader`, `PagePreloader`, `LoadingButton` in `src/core/ui/` (aligned with Flutter `BrandLoader`).

## Prerequisites

- **Node.js 20 LTS** (see [docs/dev-setup](../docs/dev-setup/README.md))
- Tablet Flutter app or API host when testing against real HTTPS (optional for UI work)

## Quick start

```powershell
cd algoritiQ\web
npm install
npm run dev
```

Open the URL Vite prints (default `http://localhost:5173`). In dev, API calls go to **`https://algoritiq.local:8443/api/v1`** by default (see `core/config.ts`). Set `VITE_API_ORIGIN=` in `.env.development` if you prefer the Vite proxy (`/api` → `VITE_API_PROXY`).

## Scripts

| Command | Purpose |
| --- | --- |
| `npm run dev` | Dev server with HMR |
| `npm run build` | Typecheck + production bundle to `dist/` |
| `npm run preview` | Serve `dist/` locally (test PWA / offline) |
| `npm run lint` | oxlint |
| `npm test` | Vitest watch mode |
| `npm run test:run` | Vitest single run (CI) |

## Environment variables

Copy [`.env.example`](./.env.example) to `.env.development` (gitignored):

| Variable | Default | Purpose |
| --- | --- | --- |
| `VITE_API_ORIGIN` | `https://algoritiq.local:8443` in dev | Full API host; empty uses relative path + proxy |
| `VITE_API_PROXY` | `https://algoritiq.local:8443` | Dev-server proxy target when using relative `/api` |
| `VITE_API_BASE_PATH` | `/api/v1` | API path suffix (`core/config.ts`) |

Never commit `.env` files with secrets.

## Project layout

```text
web/
  public/           # Static assets (fonts, favicon) — copied verbatim to dist
  src/
    app/            # Router, AppShell, providers
    core/           # config, API client, shared UI
    features/       # Route-level feature modules
    test/           # Test setup and render helpers
  dist/             # Production build output (consumed by tablet host)
```

## Engineering docs (mandatory for contributors & AI)

| Doc | Location |
| --- | --- |
| Principles (why) | [`../docs/principles/`](../docs/principles/) |
| Standards (how) | [`../docs/standards/`](../docs/standards/) |
| System architecture | [`../docs/architecture/04-react-web-application.md`](../docs/architecture/04-react-web-application.md) |
| AI entry point | [`AGENTS.md`](./AGENTS.md) |

## Responsive checks

Before shipping a UI change, look at 280, 320, 360, 414, 768 and 1280 px, in English and Bengali, light and dark (browser dev tools, device mode). At each width:

- no sideways scrolling (`document.documentElement.scrollWidth` equals the window width);
- buttons, fields and links are at least 40-44 px tall;
- long text (a long display name, Bengali sentences, the activation key) wraps inside its card.

A new page should use `SetupLayout` and the shared fields (`TextField`, `PasswordField`, `LoadingButton`), which already follow these rules.

## Styling rules

1. Use Tailwind utilities in JSX.
2. Extend design tokens in `src/index.css` (`@theme`).
3. Add `ComponentName.css` next to a component only when Tailwind cannot express the design.

Brand colors and font match the Flutter tablet app (`Plus Jakarta Sans` in `public/fonts/`).

## Offline / PWA

Production builds register a service worker that precaches JS, CSS, HTML, fonts, and icons.

Verify offline behavior:

```powershell
npm run build
npm run preview
```

Then use browser DevTools → Application → Service Workers → **Offline**, reload the page. The shell should load; API data still requires the tablet host.

## Integration with tablet release

1. `npm run build` produces `dist/`.
2. From `algoritiQ/app`, `python tool/bundle_web.py` copies `dist/` into the tablet app, which serves it at `/` (see [web app on the tablet](../app/docs/features/web-app.md)).
3. Clients open `https://<tablet-host>/` on the LAN — same origin as the API.

`vite.config.ts` uses `base: './'` so asset URLs work when not hosted at domain root.

## Definition of done

- [ ] `npm run lint`
- [ ] `npm run test:run`
- [ ] `npm run build`
- [ ] UI checked at mobile and tablet widths
- [ ] Docs updated if behavior or setup changed
