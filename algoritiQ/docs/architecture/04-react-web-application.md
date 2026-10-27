# 4. React Web Application

## Purpose

The React web app is the browser client for **admin** and **doctor** workflows.

It runs in a browser on the **Android tablet** (primary host surface) and on clinic laptops on the LAN. It uses the Backend API for all data and actions.

## Platform

- React + TypeScript.
- Tailwind CSS (utility-first styling).
- Static web build with offline-capable shell (service worker).
- Served by the local Backend API host in v1.
- Engineering rules: [../principles/](../principles/) and [../standards/](../standards/); project root `web/README.md`.

## Responsibilities

- Render browser UI.
- Authenticate or pair with the Backend API.
- Read snapshots from the API.
- Receive live updates from the API.
- Send user actions to the API.

## Boundaries

- It does not store the queue database.
- It does not allocate serial numbers locally.
- It does not connect to the TV app.
- It does not require Internet or external CDNs.

## Long-Term Approach

Keep the web app as a pure API client.

The build should use relative API paths. This allows the same app to work from the tablet host now and from a dedicated backend later.
