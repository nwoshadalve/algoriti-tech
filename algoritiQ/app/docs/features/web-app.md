# The web app on the tablet

The React app in `algoritiQ/web` is built, copied into the tablet app, and served by the tablet's own server. Open `https://algoritiq.local:8443` (see [local name](./local-name.md)) from any device on the clinic Wi-Fi.

## What is served where

| Path | What |
| --- | --- |
| `/api/v1/...` | The backend API ([admin access](./admin-access.md), [authentication](./authentication.md)) |
| `/`, `/register`, `/login`, `/forgot-password`, `/home` | The web app's pages (all answered with `index.html`, so a reload or a typed link works) |
| `/assets/...`, icons, fonts | Files of the build; a missing file is a plain `404`, never the app |

Only `GET` and `HEAD` outside `/api/`. Hashed files under `/assets/` are cached for a year; everything else is checked again on each visit, so a new build shows at once.

Every page comes with browser protections: a Content-Security-Policy (scripts, styles, images, fonts and requests only from the tablet itself, no plugins, no framing), `X-Frame-Options: DENY`, `nosniff` and `Referrer-Policy: no-referrer`.

## Flow for the admin

1. After activation and setup, the tablet shows the **admin guide** (address, QR code, claim code).
2. On a laptop or phone the admin opens the address, enters the claim code, and registers.
3. The tablet leaves the guide by itself and shows its **sign-in** screen; the website shows **Sign in** (with *Forgot password?*). After signing in the website shows `/home` (a placeholder until the dashboard exists).

## Update the web app on the tablet

Steps, checks and troubleshooting (including the blank-page incident) are in [Build the web app and deploy it on the tablet](../web-build-and-deploy.md). In short: `npm run build` in `algoritiQ/web`, `python tool/bundle_web.py` in `algoritiQ/app`, then build and install the app. `app/assets/web/` is committed, so the tablet app builds without Node.

## Limits

- The certificate is the tablet's own, so the browser warns once per device, and **a service worker cannot register** on it: the site's offline shell (PWA) works only once the browser trusts the certificate. The site itself needs the tablet anyway.
- No custom domain: `algoritiq.local:8443` (Android apps cannot use ports below 1024, so the port stays).

## Code

`lib/api/web_site.dart` (paths, types, caching, headers) · `lib/api/local_api_server.dart` (routing) · `tool/bundle_web.py`.
Tests: `test/api/web_site_test.dart`.
