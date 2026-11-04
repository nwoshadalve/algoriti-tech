# AlgoritiQ TV UI mock

Static HTML previews of the **Android TV waiting-room display** described in:

- [Kotlin Android TV application](../../docs/architecture/02-kotlin-android-tv-application.md)
- [Queue product decisions](../../docs/features/queue-product-decisions.md) — public display shows **serial + queue type only**
- [R&D architecture](../../docs/discussions/rnd_architechture.md) — pairing, snapshot/events, disconnected state, audio from tablet

**App UI lives in `screens/*.html` only.** Preview controls (theme, viewport, safe area) live in `index.html` and are not part of the TV design.

## Run locally

```bash
cd algoritiQ/mock/tv-app
npm install
npm run dev
```

Open **`http://localhost:5174/index.html`** — pick a screen in the sidebar; it loads in the TV frame (1366×768 by default).

You can also open a single screen directly, e.g. `/screens/display-live.html`, for full-screen review on a real TV browser.

### Sync from tablet SQLite

```bash
npm run sync:tablet
```

Reads `tablet-backups/.../app_flutter/algoritiq.sqlite` by default and writes `src/mock-session-data.json` (doctor, chamber, queue types). Current backup: **ডা. মো. জাহিদুল হক খান**, chamber **আল-খিদমাহ্ মেডিকেল সার্ভিসেস (প্রাঃ), চাঁদপুর**.

Doctor JPEG: `npm run sync:tablet` also tries `adb` when a device is connected. If missing, copy from the tablet (`doctor_photos/*.jpg` under app storage) to `public/assets/doctor-photo.jpg`. Until then the footer shows a placeholder monogram.

## Layout

| Path | Role |
|------|------|
| `index.html` + `src/preview.js` | Preview shell (controls + TV bezel) |
| `src/shell.css` | Preview chrome only |
| `src/tokens.css`, `src/tv.css` | Shared design system for TV screens |
| `src/screen-frame.js`, `src/tv-l10n.js` | Bengali strings + preview safe-area / text scale |
| `src/tv-display.js`, `src/display-*.js` | Queue demo + identity binding from `mock-session-data.json` |
| `src/mock-session-data.json` | Doctor + chamber fields (matches SQLite / OpenAPI `Doctor` + `Chambers`) |
| `public/assets/doctor-photo.svg` | Stand-in for `doctors.photoPath` / `GET /doctor/photo` |
| `screens/*.html` | One file per TV flow state |

## Device size

Target panel from [components_selection.md](../../docs/components_selection.md) (SINGER 32″ HD):

| Viewport | Size |
|----------|------|
| HD (default) | **1366 × 768** |
| 720p alt | **1280 × 720** |

Enable **TV safe-area padding** in the preview to mimic overscan margins (`device-metrics.json`).

## Screens

| Screen | Purpose |
|--------|---------|
| `pairing` | One-time PIN shown on TV; staff confirms on tablet |
| `setup-audio` | Volume + test announcement (tablet sends audio; TV plays) |
| `display-idle` | Connected session, no token called yet |
| `display-live` | **Primary waiting-room view** — large called serial, waiting lists by type |
| `display-disconnected` | Stale snapshot + “Disconnected — last update at …” |

On **`display-live`** and **`display-idle`**, the bottom **mock bar** simulates `token.called` events. It is for design review only and is not part of the shipped TV app.

**Layout (display screens):** top — session + connection; **main** — left **ঘোষণা** (called serial), right **অপেক্ষমাণ** (max **5** serials per queue type, then “আর N জন”); **bottom** — doctor photo + profile + chamber (from snapshot). Light theme, **Bengali only**, no logo or language toggle on the TV UI.

## Privacy / content rules (from docs)

- On-screen queue: **serials and queue type labels only** — no patient name or phone.
- Optional **spoken** name may come from tablet-prepared audio when the clinic enables it; the mock does not play real clips.
- Doctor/chamber heading matches API intent (`Doctor.name` with title for TV).

Add a new mock: create `screens/your-screen.html`, register it in `src/screens-list.js`.
