# 5. Backend API

## Purpose

The Backend API is the system boundary for all clients.

In v1, it runs locally with the tablet. It exposes queue state, session state, pairing, and live updates.

## Platform

- Local API host inside the tablet app runtime.
- HTTPS for browser and device clients.
- WebSocket for live updates.
- SQLite-backed domain layer.

## Responsibilities

- Enforce the queue authority.
- Persist state through the tablet database.
- Serve the React web app build.
- Provide API endpoints for web and TV clients.
- Provide live events for connected clients.
- Return snapshots so clients can recover after reconnect.

## Boundaries

- It is not a cloud dependency for v1.
- It should not contain UI code.
- It should not depend on React or TV implementation details.
- It should not expose database tables as the API contract.

## Long-Term Approach

Define the API with OpenAPI before client work grows.

Use stable resources, commands, idempotency keys, snapshots, and event sequence numbers. This protects the system from duplicate actions and broken reconnects.

Keep the API contract portable. A future dedicated backend should be able to implement the same contract without changing the React or TV applications.
