# 04 — Performance & reliability

The TV runs for a full clinic day on modest hardware (often **≥1.5 GB RAM**, Android 11+ on clinic panels).

## Display performance

- Target smooth D-pad focus transitions; avoid recomposing the full board on every WS tick — diff by queue state.
- Doctor photo: load via Coil with size limits and disk cache keyed by `photoVersion`.
- No heavy work on the main thread; decode and network on IO dispatchers.

## Latency

- Call → on-screen update target: **< 500 ms** on normal chamber Wi-Fi (same as tablet principle).
- Announcement download may take longer; queue display MUST update even if audio fails.

## Kiosk behavior

- During an active paired session, use **`FLAG_KEEP_SCREEN_ON`** on the display activity so Google TV ambient mode does not hide the queue.
- MUST NOT hold a permanent partial wake lock when the app is not showing the clinic display.

## Long-running stability

- Soak test **≥ 8 hours** before rollout: memory stable, WS reconnects, no announcement double-play after reconnect.
- Cancel coroutines and close WebSocket when the activity is destroyed; no leaked OkHttp clients.

## Android version compatibility

- **`minSdk 24`**, **`targetSdk` / `compileSdk 35`** (see [dev-setup](../dev-setup.md)).
- Guard APIs above 24 with `Build.VERSION.SDK_INT` or AndroidX compat.
- Test on **API 30 TV AVD** (clinic parity) and **API 34 TV AVD** (current Google TV).

## Release builds

- Test **release** builds on emulator before clinic sideload — R8 can strip required serialization types if misconfigured.
