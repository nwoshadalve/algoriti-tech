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
WAITING -> CALLED -> ENTERED
WAITING -> CANCELLED
CALLED  -> CANCELLED
CALLED  -> SKIPPED -> CALLED
```

`ENTERED` is the successful terminal state for the queue: an authorized person confirmed that the patient entered the doctor's chamber. The queue system does not claim that consultation, treatment, or medical service was completed.

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

### Physical tablet — before destructive dev operations

A **full app restart** (reinstall, `adb uninstall`, `pm clear`, or anything that wipes the app sandbox) is sometimes necessary: native/Kotlin changes, a broken install, Gradle cache issues, or debugging platform channels. That is acceptable when the task needs it — but it **destroys** the local SQLite database, license prefs, setup, readiness, and admin accounts unless you copy them off the device first.

**MUST** take a backup **before** any operation that can wipe app data, including:

- `adb uninstall …`
- `adb shell pm clear …`
- Reinstall flows that require uninstall (signature mismatch, etc.)
- Manually deleting files under the app's private storage

**SHOULD** prefer less destructive options when they are enough:

- `adb install -r` (keep data) for APK updates
- Edit `shared_prefs/FlutterSharedPreferences.xml` only (app data is under `/data/user_de/0/<package>/`, not the default data folder — see [keep-alive](../features/keep-alive.md)) (e.g. reset `readiness.acknowledged`) instead of clearing the whole app
- `flutter run` / hot restart for Dart-only changes

**Backup bundle** (minimum):

| Asset | On-device path (via `run-as tech.algoriti.algoritiq_app`) |
| --- | --- |
| SQLite (Drift name `algoritiq`) | `databases/algoritiq.sqlite` plus `databases/algoritiq.sqlite-wal` and `databases/algoritiq.sqlite-shm` if present |
| License, language, readiness flags | `shared_prefs/FlutterSharedPreferences.xml` |

Stop the app (`adb shell am force-stop tech.algoriti.algoritiq_app`) before copying the database files so WAL files are consistent. Store backups **outside** the repo (e.g. `tablet-backups/<timestamp>/`); **MUST NOT** commit backups or activation keys to git.

**Restore:** push files back with `adb push` + `run-as … cp` into the same paths, then cold-start the app. If the app was uninstalled, reinstall first, then restore before opening the UI.

Commands and examples: [dev-setup.md](../dev-setup.md) § Tablet data backup & restore.
