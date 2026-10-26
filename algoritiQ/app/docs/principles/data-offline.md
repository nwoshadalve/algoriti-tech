# 05 — Data & offline-first

The tablet's SQLite database is the single source of truth. The system MUST work with no Internet.

## Persistence

- SQLite via `drift`. Foreign keys **on**, WAL mode **on**.
- Schema changes = new numbered migration. MUST NOT edit a shipped migration. Every migration has an upgrade test from the previous version.
- Store timestamps as UTC epoch milliseconds; convert to local only in UI.
- Repositories return **domain models**, never DB rows. API DTOs are separate from DB tables and domain models.
- Parameterized queries only (drift does this). No SQL string concatenation.

## Consistency rules

- Allocate the next serial number inside **one DB transaction**. Only the tablet allocates serials.
- **Persist the event first, then notify clients.**
- Every write command carries a `commandId` (UUID). A retry with the same id returns the original result — never a duplicate record.
- Events carry `sessionId`, `chamberId`, and a monotonically increasing `eventSequence`.
- Token state changes go through the domain state machine; illegal transitions throw:

```text
WAITING -> CALLED -> IN_CONSULTATION -> COMPLETED
   |          |
   +-> CANCELLED
   +-> SKIPPED -> CALLED
```

- Append-only audit trail for: create, call, skip, cancel, reprint, session start/end, settings change.
- Restore the open session from SQLite on app restart and resume the same `eventSequence`.

## Backend API contract

- Define in **OpenAPI** before client work; versioned `/api/v1`; WebSocket `/ws` for events.
- Stable resources and commands; don't expose DB tables as the contract.
- `GET /snapshot` returns full state. Clients that miss a sequence discard state and re-fetch.
- Web build uses **relative** API paths so a dedicated backend can replace the tablet host later.

## Offline & time

- No network call in the critical path (token creation, print, call). No CDNs, remote fonts or remote assets — bundle everything.
- Every I/O has a timeout (default 10 s) and bounded retry with backoff + jitter.
- Inject `Clock`; never read system time in domain logic.

## Backup

- Backups are encrypted; restore is tested. Document what can be lost after the last backup.
- Online services (backup, updates, reporting) are optional and MUST NOT gate clinic operation.
