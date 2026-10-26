# 2. Kotlin Android Application for Android TV

## Purpose

The Android TV app is the waiting-room display client.

It shows live queue information from the Backend API. It is read-only.

## Platform

- Kotlin.
- Native Android TV application.
- TV-first layout and lifecycle.

## Responsibilities

- Connect to the Backend API.
- Receive live updates.
- Recover state from the latest snapshot.
- Keep the display active during clinic hours.
- Store only connection and pairing data.

## Boundaries

- It does not own queue data.
- It does not allocate serial numbers.
- It does not call the tablet app directly.
- It does not share UI code with the React web app.

## Long-Term Approach

Use the API contract as the only shared layer.

The TV app should remain replaceable. If the API host moves from tablet to another backend, the TV app should only need a new endpoint and pairing flow.
