# Build the web app and deploy it on the tablet

The website in `algoritiQ/web` is built, copied into the tablet app, and served by the tablet at `https://algoritiq.local:8443`. Do this every time the website changes.

## Before you start

- Node.js 20 or newer (`node -v`) and `npm install` done once in `algoritiQ/web`.
- Flutter and `adb` on your `PATH`, the tablet on USB (`adb devices` shows `device`). See [dev-setup](./dev-setup.md).
- Python 3 (`python --version`) for the copy step.

## Steps

Run from the repository root, in PowerShell.

```powershell
# 1. Check and build the website
cd algoritiQ\web
npm run lint
npm run test:run
npm run build                 # writes web\dist

# 2. Copy the build into the tablet app
cd ..\app
python tool\bundle_web.py     # copies web\dist to app\assets\web

# 3. Build and install the app (keeps the tablet's data)
flutter build apk --debug     # use --release for a delivery build
adb install -r build\app\outputs\flutter-apk\app-debug.apk
adb shell am start -n tech.algoriti.algoritiq_app/.MainActivity
```

`adb install -r` replaces the app but keeps its data. Never `adb uninstall` or `pm clear` without a backup ([dev-setup](./dev-setup.md), "Tablet data backup").

## Check that it works

```powershell
# The tablet serves the new build: this file name must match app\assets\web\assets\index-*.js
curl.exe -sk https://algoritiq.local:8443/ | Select-String "assets/index-"

# A page route answers with the app, a missing file with 404
curl.exe -sk -o NUL -w "%{http_code}\n" https://algoritiq.local:8443/register          # 200
curl.exe -sk -o NUL -w "%{http_code}\n" https://algoritiq.local:8443/assets/nope.js    # 404
```

Check small screens too: open the site on a phone (or browser device mode at 320 px). The page must not scroll sideways and every button must be easy to tap; the list of widths to try is in `web/README.md` ("Responsive checks").

Then open `https://algoritiq.local:8443` on a laptop (accept the one-time certificate warning: *Advanced*, then *Continue*). You should see **Administrator setup** (or **Sign in** once an admin exists), not a blank page. If the name does not resolve, use the IP address shown on the tablet.

## Work on the website against the tablet

```powershell
cd algoritiQ\web
Set-Content .env.development "VITE_API_ORIGIN=https://algoritiq.local:8443"   # or tablet IP; gitignored
npm run dev                                                              # http://localhost:5173
```

The dev server forwards `/api` to the tablet, so you can change the UI with hot reload and use the real backend. Register a test admin only on a tablet you can reset (see the backup note above).

## What the copy step does

`tool/bundle_web.py` replaces `app/assets/web/` with `web/dist/`. Flutter bundles assets **folder by folder**, so every folder of the build must be listed in `pubspec.yaml` (`assets/web/`, `assets/web/assets/`, `assets/web/fonts/`). If a new folder appears the script stops and names it: add it to `pubspec.yaml` and run it again. `app/assets/web/` is committed, so the app builds without Node.

## Troubleshooting

| Symptom | Cause and fix |
| --- | --- |
| **Blank page** (just the dark blue background) | The app failed to start. Open the browser's console (F12). The 2026-10 incident: `Router basename="/./" is not able to match the URL`; the router was given Vite's relative `base` (`./`). Fixed in `web/src/app/routerBasename.ts` (with a test). Always check a **production** build (`npm run build`), not only `npm run dev`, before deploying. |
| Old page after a deploy | Hard refresh (Ctrl+F5). `index.html` is revalidated on every visit, but a browser that registered the service worker may show its cache once. |
| Console: *Failed to register a ServiceWorker* | Harmless. A browser refuses service workers on the tablet's own (self-signed) certificate. The site works without it. |
| `Unable to find directory ... assets/web/...` when building the app | Run the copy step first (`python tool\bundle_web.py`), or a folder is missing in `pubspec.yaml`. |
| `No build at ...: run npm run build` | Step 1 did not finish; fix its errors first. |
| 404 for `/something.js` | The file is not in the build. Pages (paths without a dot) always return the app; files do not. |
| Certificate warning on every device | Expected: the tablet uses its own certificate (see [local name](./features/local-name.md)). |
| `adb install` fails with a signature mismatch | A build signed with another key is installed. Back up the data first, then uninstall and reinstall (see [dev-setup](./dev-setup.md)). |

## Rollback

Check out the previous `app/assets/web/` (`git checkout <commit> -- algoritiQ/app/assets/web`), then run step 3 again.

## Related

[Web app on the tablet](./features/web-app.md) (what is served, headers, limits) · [Authentication](./features/authentication.md) · [Local name](./features/local-name.md).
