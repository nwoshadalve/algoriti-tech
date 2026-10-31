# 06 — Errors & logging

## Errors

- Expected failures are **values**: return `Result<T>` / `sealed Failure` from domain and data layers (`PrinterOffline`, `DuplicateCommand`, `StorageFull`).
- Exceptions are for bugs and truly exceptional states.
- MUST NOT swallow errors: no empty `catch`, no `catch (e) {}`. Catch **specific** types; add context when rethrowing.
- Presentation maps a failure → **localized, actionable** message. Never show stack traces or raw exception text.
- Always provide a recovery path in UI (retry, reprint, reconnect).
- **Ask before anything that cannot be undone or that uses a shared resource** (print, send, delete, end a session): a confirmation in the reusable popup (`AppDialog`, [UI standards](../standards/ui.md)) with a clear verb on the button, never a bare "OK". Dismissing the popup, or Cancel, does nothing.
- Tell the person the **result** of what they did, in the toaster (`core/toast`, [UI standards](../standards/ui.md)): success when it worked, a human, actionable error when it did not. Silence after a tap is a defect. Toasts are never the only record of a failure that needs action.

## Global handlers (set once in `main.dart`)

- `FlutterError.onError`, `PlatformDispatcher.instance.onError`, and a guarded zone → log + show a safe error screen. App MUST NOT white-screen.

## Fail-safe behavior

- Printer failure → token stays created, print status `FAILED`, explicit reprint. Never blocks the queue.
- TV/laptop disconnect → tablet continues; clients recover via snapshot.
- Announcement/audio failure → show visually; never delay a queue command.
- Retries: bounded count, exponential backoff + jitter, then surface the failure. One deliberate exception: the **printer link** keeps reconnecting forever with waits capped at 60 s, because the counter must heal by itself when the printer is switched on again; the failure stays visible on the Connectivity page the whole time ([Connectivity](../features/connectivity.md)).

## Logging

- Use the `core/logging` wrapper (levels: `trace`, `debug`, `info`, `warn`, `error`). **No `print`.**
- Log events with context ids (`sessionId`, `commandId`) — **never PII** (patient names, phones) and **never secrets/tokens**.
- Release builds log `info`+ only. Keep a small rotating local log file that staff can export for support.
- One log per event at the boundary that handles it — don't log-and-rethrow at every layer.

## Crash reporting

- v1 is offline: local logs only. Any remote reporting is optional, opt-in, and must not affect operation or leak PII.

## Android side

- Kotlin services map exceptions to typed error codes across the channel ([Android services](../standards/android-services.md)). Never let an uncaught exception kill a foreground service.
