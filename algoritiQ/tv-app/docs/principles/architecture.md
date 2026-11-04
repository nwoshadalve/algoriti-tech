# 01 — Architecture

Kotlin Android TV app = **read-only waiting-room client**. Queue authority lives on the tablet Backend API; the TV never owns queue data or allocates serials.

## Layers (dependencies point inward)

```text
presentation  →  application  →  domain  ←  data
 (Compose TV)     (ViewModels)     (pure Kotlin)  (OkHttp, WS, DataStore)
```

- **domain**: entities, value objects, repository *interfaces*, use-cases. Pure Kotlin — MUST NOT import Android, Compose, OkHttp, or Retrofit.
- **application**: ViewModels and coordinators; orchestrates use-cases; exposes immutable UI state as `StateFlow` / sealed UI models.
- **data**: implements domain interfaces (REST, WebSocket, secure storage). Maps DTOs ↔ domain models.
- **presentation**: Composables only. Collect state, dispatch intents. No I/O, no business rules.

## Folder layout

```text
app/src/main/java/tech/algoriti/algoritiq_tv/
  AlgoritiqTvApplication.kt
  MainActivity.kt
  core/                 # theme, di, network, logging, navigation shell
  features/<feature>/
    presentation/  application/  domain/  data/
```

Features MUST NOT import another feature's internals — depend on its `domain` interface or shared `core` abstractions.

## Boundaries (from architecture docs)

- MUST NOT talk to the Flutter tablet app directly; only via the **Backend API** (HTTPS + `/ws/live`).
- MUST NOT share UI code with the React web app.
- MUST NOT run TTS or synthesize announcement text on the TV in v1 ([queue-product-decisions](../../../docs/features/queue-product-decisions.md)).
- MUST NOT display patient name or phone on the waiting-room screen — serial and queue type only.
- Business rules live in `domain`, never in Composables or network interceptors.

## Defaults (change only via ADR in `docs/decisions/`)

| Concern | Choice |
| --- | --- |
| UI | Jetpack **Compose for TV** |
| DI | **Hilt** |
| HTTP | **OkHttp** + **Retrofit** + **kotlinx.serialization** |
| Live updates | OkHttp **WebSocket** (`/ws/live` per OpenAPI) |
| Images | **Coil 3** |
| Announcement playback | **Media3 ExoPlayer** |
| Secrets / pairing | **DataStore** + **EncryptedSharedPreferences** |
| Navigation | Navigation Compose |

## Rules

- No global mutable singletons for app state — inject via Hilt.
- Constructor injection; depend on abstractions (`LiveSessionRepository`, `AnnouncementPlayer`).
- Inject `Clock` for time-dependent logic in domain; avoid `Instant.now()` inside pure domain tests.
- One reason to change per class. Prefer composition over inheritance.
