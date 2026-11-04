# 02 — Connectivity & sync

The TV stays useful when Wi-Fi flickers. Recovery is **snapshot-first**, not optimistic guessing.

## Connection model

1. On connect (or reconnect), obtain session credentials from stored pairing data.
2. Open **WebSocket** to `/ws/live` with bearer token or `?token=` per [OpenAPI](../../../docs/api/openapi.yaml).
3. Apply server **`snapshot`** frame before any incremental **`event`** frames.
4. Track monotonic **`eventSequence`**. If a gap is detected, **discard partial state** and fetch a fresh REST snapshot (when endpoint exists) or wait for a new WS `snapshot`.

## Disconnected behavior

- MUST show **Disconnected — last update at …** (Bengali copy in UI strings) — not a fake live board.
- Keep the last rendered snapshot visible but clearly stale (banner), matching [mock display-disconnected](../../mock/tv-app/screens/display-disconnected.html).
- On reconnect, refresh snapshot **before** playing announcements so an old call is not repeated.

## Retries

- Exponential backoff + jitter for WS and REST.
- Bounded timeouts on every network call.
- Ping/pong: reply to server `ping` with `{"type":"pong"}` per OpenAPI.

## TLS

- Production MUST validate TLS to the clinic tablet host (user-installed CA or system trust as provisioned).
- MUST NOT ship `trustAllCertificates` in release builds.
- Dev-only certificate overrides belong in debug build config only, documented in [dev-setup](../dev-setup.md).

## Emulator vs LAN

- Android emulator reaches the host PC at **`10.0.2.2`**, not `localhost`.
- Physical TV and tablet must share the same LAN subnet; router **AP isolation off** ([components_selection](../../../docs/components_selection.md)).
