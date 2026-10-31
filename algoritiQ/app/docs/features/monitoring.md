# Monitoring

The web app's **Monitoring** page (admins only) shows how the tablet and its services are doing, and why anything is down.

## What it shows

**At the very top**, four tiles: POS printer, TV app, WebSockets, Android services. Each has a state (Running, Warning, Failed, Unavailable, Retrying), a one-line reason when it is not fine, and, when it can be tried again, a **Retry** button with a refresh icon. While a retry runs the tile shows the three-dot loader and "Attempt 2 of 3".

**Tablet resources:** CPU, memory (RAM), storage, Bluetooth.

**Services:** the tablet API, the live channel (WebSockets, with the number of connected clients), the Android background service, the printer and the TV app, each with its uptime. The page also shows how long the tablet itself has been up.

## States and reasons

| State | Meaning |
| --- | --- |
| Running | Working |
| Warning | Working, but something needs attention (battery restriction, CPU or memory high, storage 85% full) |
| Failed | Down (service stopped, Bluetooth off, storage 95% full, no reading) |
| Unavailable | Nothing to connect to yet (printer, TV app) or no hardware (Bluetooth) |
| Retrying | A retry is running |

The tablet sends **reason codes** (`service_stopped`, `printer_not_set_up`, ...), never sentences; the web app words them in English and Bengali (`monitoringReasons.ts`). The list is in `docs/api/openapi.yaml`.

## Retry

`POST /api/v1/monitoring/services/{id}/retry` for `androidService`, `printer` or `tv`. The tablet makes up to three tries, two seconds apart, and the progress is part of every reading (`retry: {attempt, max}`), so every browser sees the same. The page reads every 5 seconds, every second while a retry runs.

- **Android services:** each try starts the background service again and checks it.
- **Printer and TV app:** not built yet, so each try honestly fails and the part stays *Unavailable* with its reason. This is the place to connect them.
- **WebSockets:** this is the browser's own live connection (the tablet cannot tell whether a browser could reach it). Retry reconnects at once instead of waiting for the next automatic try.
- The API itself cannot be retried from the page (409 `not_retryable`).

## What the numbers mean

- **CPU** is this app's share of the processor. Since Android 8 apps may not read the system-wide figure.
- **Memory and storage** are the tablet's (storage is the app's data partition).
- **Bluetooth** is on/off as Android reports it. Admins can tap **Turn on Bluetooth** on the monitoring page; Android shows its own dialog or settings on the **tablet screen** (`POST /api/v1/monitoring/bluetooth/enable`). It does not yet check a paired printer.

## Code

Tablet: `lib/features/monitoring/` (`MonitoringService`, domain models), `lib/platform/system_health_gateway.dart` with `SystemHealthChannel.kt`, routes in `lib/api/local_api_server.dart`.
Web: `web/src/features/monitoring/`, `web/src/core/api/monitoring.ts`.
Tests: `test/features/monitoring/`, `test/api/local_api_server_test.dart` (monitoring group); web `MonitoringPage.test.tsx`, `monitoringHelpers.test.ts`.

## Not yet

Real printer and TV connections (and their uptime), a paired-printer Bluetooth check, history and alerts, live push of readings instead of polling.
