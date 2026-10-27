# Offline & PWA principles

Clinic networks may have no Internet. The dashboard MUST remain usable when only the tablet LAN is available.

## Asset policy

- **MUST NOT** load scripts, styles, fonts, or images from public CDNs in production builds.
- **MUST** bundle fonts and icons under `public/` (or `src/assets` when hashed by Vite).
- **MUST** ship a service worker that precaches the application shell and hashed build assets.

## Runtime behavior

- The SPA shell (HTML, JS, CSS, fonts) MUST load from cache after the first successful visit.
- **API data is not offline-first** in v1: queue state comes from the Backend API. When the API is unreachable, show a clear **connection lost** state with retry — never a blank screen.
- After reconnect, **MUST** apply a full snapshot before relying on incremental WebSocket events.

## Caching rules

- Do not cache API responses in the service worker unless an explicit product spec defines safe TTL and invalidation.
- Versioned filenames from Vite builds are safe to precache; `index.html` uses `network-first` or `stale-while-revalidate` per Workbox config in `vite.config.ts`.

## Development

- `npm run dev` does not require a service worker; use `npm run build && npm run preview` to verify PWA behavior.
- Test offline in Chrome DevTools → Application → Service Workers → Offline.

## Deployment

- Production build output is copied into the tablet host and served by the Backend API over **HTTPS** on the LAN.
- `base` in Vite MUST stay relative (`./`) so assets resolve when the app is not hosted at domain root.
