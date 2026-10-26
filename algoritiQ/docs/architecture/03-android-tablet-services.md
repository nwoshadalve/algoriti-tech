# 3. Android Services for Tablet

## Purpose

Android services handle long-running native work on the tablet.

They protect the clinic session from Android lifecycle limits.

## Platform

- Kotlin Android services.
- Foreground services where Android requires them.
- Flutter platform channels for communication with the tablet app.

## Responsibilities

- Keep printer communication alive during a clinic session.
- Manage Bluetooth printer connectivity.
- Run native lifecycle support for the local API host when needed.
- Report service health back to the Flutter app.

## Boundaries

- Services do not own clinic workflows.
- Services do not create queue numbers.
- Services do not render UI.
- Services do not expose public APIs to clients.

## Long-Term Approach

Keep native services small and operational.

The Flutter app should own product rules. Android services should own OS integration, device communication, and process reliability.
