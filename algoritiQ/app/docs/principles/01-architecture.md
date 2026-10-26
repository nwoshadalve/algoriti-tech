# 01 — Architecture

Flutter tablet app = clinic operator app and **source of truth** (offline-first). TV and web are clients of the Backend API; they never talk to the app directly.

## Layers (dependencies point inward)

```text
presentation  →  application  →  domain  ←  data
 (widgets)       (controllers)   (pure Dart)  (SQLite, API, channels)
```

- **domain**: entities, value objects, repository *interfaces*, use-cases, state machines. Pure Dart — MUST NOT import `flutter`, drift, or platform code.
- **application**: controllers/notifiers; orchestrates use-cases; exposes immutable UI state.
- **data**: implements domain interfaces (SQLite, API publisher, printer/platform channels). Maps rows/DTOs ↔ domain models.
- **presentation**: widgets only. Reads state, sends intents. No logic, no I/O.

## Folder layout

```text
lib/
  main.dart            # bootstrap only
  app/                 # App widget, router, DI root
  core/                # theme, l10n, errors, logging, clock, utils (no feature code)
  features/<feature>/
    presentation/  application/  domain/  data/
  platform/            # typed wrappers over platform channels
```

Features MUST NOT import another feature's internals — depend on its `domain` interface.

## Boundaries (from architecture docs)

- MUST NOT talk to the TV or React app directly; only via the Backend API.
- MUST NOT put Bluetooth socket code in Dart — it lives in Android services ([03](./03-android-services.md)).
- MUST NOT hardcode API clients in features; depend on interfaces for **storage, printing, API publishing** (host may move to a dedicated backend later).
- Only the tablet allocates serial numbers ([05](./05-data-offline.md)).
- Business rules live in `domain`, never in widgets or Android services.

## Defaults (change only via ADR in `docs/decisions/`)

| Concern | Choice |
| --- | --- |
| State / DI | `flutter_riverpod` |
| Navigation | `go_router` |
| Local DB | `drift` (SQLite) |
| Models | immutable classes, Dart 3 `sealed`/records; `freezed` optional |
| Native bridge | `pigeon` typed channels |

## Rules

- No global mutable state, no singletons — inject via providers.
- Constructor injection; depend on abstractions (`PrinterGateway`, `QueueRepository`).
- Inject `Clock` and ID generator; never call `DateTime.now()` / `Uuid()` inside domain.
- One reason to change per class. Prefer composition over inheritance.
