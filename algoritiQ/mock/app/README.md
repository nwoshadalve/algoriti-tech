# AlgoritiQ tablet UI mock

Static HTML previews of the Flutter `algoritiQ/app` screens. **App UI lives in `screens/*.html` only.** Preview controls (theme, orientation, viewport, text size) live in `index.html` and are not part of the design.

## Run locally

```bash
cd algoritiQ/mock/app
npm install
npm run dev
```

Open **`/index.html`** — pick a screen in the sidebar; it loads in the device iframe.

You can also open a single screen directly, e.g. `/screens/board.html`, to edit layout without the preview chrome (theme/orientation then use the preview shell).

## Layout

| Path | Role |
|------|------|
| `index.html` + `src/preview.js` | Preview shell (controls + device frame) |
| `src/shell.css` | Preview chrome only |
| `src/tokens.css`, `src/app.css` | Shared design system (used by screen HTML) |
| `src/screen-frame.js` | Applies preview options inside each iframe |
| `src/screens-list.js` | Screen picker entries |
| `screens/*.html` | One file per app screen (hard-coded copy/data) |

## Device size (measured)

Clinic tablet **AJ5EJK6609C03364** @ 240 dpi (`device-metrics.json`):

| Orientation | Usable size |
|-------------|-------------|
| Portrait | **800 × 1340** |
| Landscape | **1340 × 800** |

Preview defaults to these dimensions. **Navigation is a slide-out drawer** (☰ menu, max 288px / 85% width, scrim behind)—same as the tablet at 800×1340, not a permanent sidebar.

## Preview options (outside the design)

- **Theme** — light / dark (`data-theme` on the screen document)
- **Orientation** — portrait / landscape (CSS breakpoints + layout)
- **Viewport** — measured tablet or narrow 600×960
- **Text size** — 100% / 130% / 200% (simulates system font scale)
- **Safe area** — optional padding on `.app-root`

Dashboard screens also include in-app **বাংলা / EN** and **theme** controls (same as Flutter); those toggle inside the iframe for design review.

**Chamber name (matches Flutter):** On viewports **under 1024px** (portrait on the clinic tablet), the top bar shows a location pin and chamber name (`WorkScopeContextHeader` compact). At **1024px and up** (landscape), the top bar does not show the chamber—only the **Board** page body uses “Working at … Run the counter from here.” Connectivity and Settings never repeat the chamber in the page body.

## Screens

`activation`, `readiness`, `clinic-data`, `setup-profile`, `setup-chambers`, `setup-ready`, `sign-in`, `work-scope`, `admin-notice`, `board`, `connectivity`, `settings`

Add a new mock: create `screens/your-screen.html` (copy head + link CSS + `screen-frame.js`), then register it in `src/screens-list.js`.
