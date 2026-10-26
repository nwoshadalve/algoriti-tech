# 1. Flutter Application for Tablet

## Purpose

The tablet app is the main clinic operator application.

It starts and ends clinic sessions. It owns the local user flow for the counter. It coordinates printing, TV sync, and web dashboard access through the Backend API.

## Platform

- Flutter for tablet UI.
- Dart for application state and domain logic.
- SQLite for local persistence.
- Platform channels for Android-only services.

## Responsibilities

- Own clinic session state.
- Own queue state through the local domain layer.
- Read and write the local database.
- Call Android tablet services when native Android behavior is needed.
- Expose state to the Backend API.

## Boundaries

- It does not talk directly to the TV app.
- It does not talk directly to the React web app.
- It does not own Bluetooth socket code.
- It does not hardcode API clients.

## Long-Term Approach

Keep business rules outside UI widgets.

The tablet app should depend on interfaces for storage, printing, and API publishing. This keeps the system portable if the Backend API later moves to a dedicated device or server.
