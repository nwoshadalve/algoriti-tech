# 09 — Performance & reliability

The app runs a full clinic shift (hours) on a mid-range tablet. Reliability beats cleverness.

## UI performance

- Target 60 fps; no jank in token creation or queue list. Measure in **profile mode** on the physical tablet (`flutter run --profile`), never debug.
- No heavy work in `build()`; use `const`, `select`, `ListView.builder`; keep widget trees shallow where it matters.
- Heavy CPU (receipt raster, large parsing) on a separate isolate.
- Bundle only needed assets; subset fonts; compress images.

## Startup & responsiveness

- Show first frame fast; defer non-essential init. Cold start target: usable < 3 s on the Honor Pad X7.
- Token create → printed target: **< 5 s**. Call → TV update target: **< 500 ms** on normal Wi-Fi.

## Long-running stability

- No leaks: dispose controllers/streams/sockets; cancel timers and coroutines.
- Soak test a full shift (≥ 8 h) before clinic rollout: memory stable, connections recover.
- Survive process death and app restart by restoring from SQLite ([Data & offline](./data-offline.md)).
- Keep the screen on during a session using `FLAG_KEEP_SCREEN_ON` (foreground), not a permanent wake lock ([Android services](../standards/android-services.md)).

## Connectivity

- Reconnect with exponential backoff + jitter; always re-sync from snapshot.
- Timeouts on every network/Bluetooth call; surface disconnected state with "last update at …".

## Android version compatibility

- `minSdk 21`, target current stable. Guard APIs with `Build.VERSION.SDK_INT`; use AndroidX/compat.
- Test on API 35 (Honor Pad X7) and, when available, one older device. Don't use APIs above `minSdk` unguarded.
- Check behavior changes per release (foreground service types, notification & Bluetooth permissions, background limits).

## Release builds

- Release behavior differs from debug — test **release** on the tablet before shipping.
- Prefer `--split-per-abi` APKs (arm64-v8a for the Honor Pad X7); keep APK size in check.
- Keep a small perf budget in PRs that touch hot paths (queue list, receipt render).
