# 07 — Testing

## Strategy

- **Unit tests** for domain use-cases (snapshot apply, event sequence gap, announcement dedupe).
- **MockWebServer** for REST and WebSocket frame parsing.
- **Turbine** for Flow/StateFlow emissions in ViewModels.
- UI: focused Compose tests for critical Bengali strings and disconnected banner — not snapshot-heavy pixel tests.

## Critical paths (MUST have regression tests before release)

1. Pairing state machine (unpaired → paired → token stored).
2. Reconnect: snapshot before events; **no double-play** of same `announcementId` / `callId`.
3. Disconnected UI shows last update time when WS drops.
4. Display mapping: serial + type only in public queue models (no accidental PII fields).

## Before merge

- `./gradlew test` and `./gradlew :app:assembleDebug`.
- Manual smoke on **Android TV emulator** after UI changes.

See [standards/testing.md](../standards/testing.md) for how-to.
