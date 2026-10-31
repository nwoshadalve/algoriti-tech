# 03 — Android services (Kotlin)

Native services keep the clinic session alive and talk to hardware. Flutter owns product rules; services own **OS integration, device communication, process reliability**.

Location: `android/app/src/main/kotlin/tech/algoriti/algoritiq_app/` (channels and services live here, not under a separate `services/` package).

Each `.kt` file uses the copyright header from [Code style — Copyright header](./code-style.md). Document channel contracts with KDoc; explain Android-version branches and permission flows in comments, not in Flutter.

## Responsibilities

- Printer communication + Bluetooth connectivity (kept alive during a session).
- Lifecycle support for the local API host when needed.
- Report service health back to Flutter.

## Boundaries — services MUST NOT

- own clinic workflows or create queue/serial numbers;
- render UI;
- expose public APIs to clients;
- depend on Flutter UI classes. Keep them small and operational.

## Foreground services

- Run a foreground service only while a clinic session is open; stop it when the session ends.
- Declare `android:foregroundServiceType` + matching `FOREGROUND_SERVICE_*` permission (required Android 14+). Use a visible, informative notification; request `POST_NOTIFICATIONS` on Android 13+.
- Pick the type honestly (e.g. `connectedDevice` for Bluetooth). Avoid `dataSync` for long-running work (time-limited on Android 15); verify against current Android docs.
- MUST NOT hold a permanent wake lock. If unavoidable: `PARTIAL_WAKE_LOCK` with timeout, released in `finally`.
- `start`/`stop` MUST be idempotent. Survive process death by restoring from persisted session state, not memory.

## Bluetooth & printing

- Bluetooth Classic **SPP + raw ESC/POS**. MUST NOT depend on a proprietary vendor SDK.
- Receipts arrive as a **384-dot monochrome raster** rendered by Flutter; services only transmit bytes.
- Android 12+: runtime `BLUETOOTH_CONNECT` (and `BLUETOOTH_SCAN` with `neverForLocation` for discovery). Legacy `BLUETOOTH*` / location permissions limited with `maxSdkVersion="30"`.
- Check permission before every call; catch `SecurityException`. Flutter shows the permission UX; services never prompt.
- Print jobs: serial queue, per-job timeout, bounded retry with backoff, explicit result (`OK` / `FAILED(reason)`). A failed print never creates or loses a token; reprint is explicit.
- Always close sockets/streams (`use {}` / `finally`).
- Implemented in `PrinterChannel.kt`: one background thread owns the socket so commands never interleave; a reader thread detects a dropped link and tells Dart; connect tries the SPP service UUID, then channel 1. Reconnect policy lives in Dart, not here ([Connectivity](../features/connectivity.md)).

## Coroutines & threading

- Structured concurrency: one `CoroutineScope(SupervisorJob() + Dispatchers.Default)` per service, cancelled in `onDestroy`.
- MUST NOT use `GlobalScope`. Blocking I/O on `Dispatchers.IO`. Never block the main thread.
- Expose state as `StateFlow`/`Flow`; no shared mutable state without confinement.

## Platform channels (Flutter ↔ Kotlin)

- Use **Pigeon**-generated typed APIs; if `MethodChannel` is unavoidable, name it `tech.algoriti.algoritiq/<service>` and keep constants in one file.
- Flutter → native: commands (`connectPrinter`, `print`, `startSession`). Native → Flutter: `EventChannel` stream for health/status.
- Every call returns a typed result or error code — no raw exceptions across the bridge. Version the contract.
- Dart side wraps channels in `lib/platform/`; features use the domain interface (e.g. `PrinterGateway`), never the channel.

## Manifest & API levels

- App supports `minSdk 21`. Guard newer APIs with `Build.VERSION.SDK_INT` (or AndroidX compat); never crash on older versions.
- Request the minimum permissions. Components `android:exported="false"` unless required.
- Handle Doze/battery restrictions: document the user setting, don't silently rely on it.

## Logging & health

- Log with `Log.*` tags per service; no PII, no secrets. Report `connected | connecting | disconnected | error(code)` to Flutter.
- Unit-test logic behind a `Transport` interface (fake Bluetooth); test real hardware on the tablet ([Testing](./testing.md)).
