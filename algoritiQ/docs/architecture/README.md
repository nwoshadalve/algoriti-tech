# AlgoritiQ Architecture

AlgoritiQ is an offline-first clinic queue system.

The tablet is the main host. It owns queue data, printing, local API, and clinic session state. The TV and web dashboard are clients.

```text
Bluetooth Printer
       ▲
       │
Flutter Tablet App ── Android Tablet Services
       │
       ▼
Backend API
   │        │
   ▼        ▼
React Web App   Kotlin Android TV App
```

## Components

| Order | Component | Document |
| --- | --- | --- |
| 1 | Flutter application for tablet | [01-flutter-tablet-application.md](./01-flutter-tablet-application.md) |
| 2 | Kotlin Android application for Android TV | [02-kotlin-android-tv-application.md](./02-kotlin-android-tv-application.md) |
| 3 | Android services for tablet | [03-android-tablet-services.md](./03-android-tablet-services.md) |
| 4 | React web application (`web/`) | [04-react-web-application.md](./04-react-web-application.md) · [principles](../principles/) · [standards](../standards/) |
| 5 | Backend API | [05-backend-api.md](./05-backend-api.md) |

## High-Level Direction

- The system must work without Internet.
- The tablet is the source of truth for v1.
- The Backend API is local-first and runs with the tablet.
- Clients talk only through the Backend API.
- The API contract must stay independent from the tablet UI.
- This allows a future dedicated backend without rewriting TV or web clients.
- SQLite is enough for v1 local persistence.
- OpenAPI should define the API before parallel client development.
- WebSocket events should be used for live updates.
- Clients must recover from a fresh snapshot after reconnect.

## Scope

This folder describes architecture only.

It does not describe screen behavior, printer commands, permission UX, or feature workflows.
