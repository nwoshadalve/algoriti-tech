# 05 — Errors & logging

## Errors

- Expected failures are **values**: `Result<T>` or sealed `Failure` in domain/data (`NetworkUnavailable`, `PairingExpired`, `AudioPlaybackFailed`).
- MUST NOT swallow errors: no empty `catch`. Log at the boundary that handles recovery.
- User messages in **Bengali**, actionable (retry, check Wi-Fi, re-pair). Never show stack traces.

## Fail-safe behavior

- WS disconnect → show disconnected state; tablet queue continues unaffected.
- Announcement failure → large serial still visible; log safe failure code; do not block display updates.
- Snapshot apply failure → keep stale UI with banner; retry with backoff.

## Logging

- Use **Timber** behind a small wrapper. **No `Log`/`println` in features.**
- Log correlation ids (`deviceId`, `eventSequence`, `callId`) — **never PII** and **never tokens**.
- Release: `info`+ only; debug tree in debug builds only.

## Crash reporting

- v1 offline: local logcat export only. No mandatory cloud crash SDK.
