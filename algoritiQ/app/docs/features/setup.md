# First-time setup

Runs once after activation on a **doctor license**. Collects what the TV and queue need.
Chamber licenses skip it for now.

## Steps

```text
1 Profile  ──▶  2 Chambers  ──▶  3 Ready  ──▶  Home
```

- **Back** (button or system back) returns to the previous step. Nothing is lost.
- Progress is saved, so a restart resumes the same step.

## 1. Profile (the doctor)

| Field | Required |
| --- | --- |
| Name, with title | Yes |
| Designation | Yes |
| Specialty and areas of expertise | Yes |
| Degrees (at least one, in order) | Yes |
| Hospital or institution | No |
| Medical council registration number (BMDC) | No |
| Photo (gallery or camera) | No |

Shown on the TV. Photo is copied into the app's private storage (works offline).

## 2. Chambers

- Up to the license limit (`maxChambers`). At least **one** to continue.
- Each chamber: **name, address, phone** — all required. Chambers can be edited.
- Every chamber belongs to the doctor (`doctor_id`).

## 3. Ready

Summary of the doctor and chambers, then **Start**. That opens **Keep the tablet ready** ([keep-alive](./keep-alive.md)): background running, notifications, auto-start after power-on, and screen lock — so the local HTTPS API stays up with the screen locked and after a restart.

## Data

- SQLite via drift: `doctors`, `chambers`, `app_settings` (`setup.stage` = `profile`, `chambers`, `ready`, `done`).
- Ids are UUIDs. Schema v3; upgrades keep existing data ([Data & offline](../principles/data-offline.md)).

## Layout

- Portrait: one column.
- Landscape: compact grid that fits the tablet (893 × 533 dp) without scrolling.
- Light and dark, Bengali and English ([Localization](../principles/localization.md)).

## Not yet

Team and sign-in step, chamber-license setup, editing from settings.

## Code

`lib/features/clinic/` — `domain`, `data` (drift repository), `application` (actions), `presentation` (pages).
Tests: `test/features/clinic/`.
