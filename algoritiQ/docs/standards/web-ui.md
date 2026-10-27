# Web UI standards

Admin and doctor dashboard: used on **Android tablets** (primary), phones, laptops, and desktops on the clinic LAN.

## Styling order

1. **Tailwind CSS** utility classes in JSX (`className`).
2. **Theme tokens** in `src/index.css` via `@theme` (colors, fonts, breakpoints) — not random hex in components.
3. **Component CSS** (`ComponentName.css` next to the component) only when Tailwind cannot do the job (multi-step keyframes, print styles, third-party widgets).

**MUST NOT** add global CSS files for one-off screen styles.

## Brand (align with tablet app)

| Token | Value | Usage |
| --- | --- | --- |
| `brand-navy` | `#0B1F3A` | Headers, primary chrome |
| `brand-coral` | `#FF5C39` | Accents |
| `brand-coral-action` | `#D23F1E` | Primary buttons (white text, WCAG AA) |
| `brand-mist` | `#F4F6F9` | Page background (light) |

- Font: **Plus Jakarta Sans** from `public/fonts/` (bundled, offline).
- Logo: use shared `BrandLogo` when added; do not hotlink external logo URLs.

## Responsive breakpoints

Use Tailwind defaults unless overridden in `@theme`:

| Prefix | Min width | Typical device |
| --- | --- | --- |
| (none) | 0 | Phone portrait |
| `sm` | 640px | Large phone / small tablet |
| `md` | 768px | Tablet portrait |
| `lg` | 1024px | Tablet landscape / laptop |
| `xl` | 1280px | Desktop |

**Layout rules**

- **Mobile**: single column; primary nav in a bottom bar or hamburger drawer.
- **Tablet (`md+`)**: persistent side nav for admin/doctor sections; content max-width with comfortable padding.
- **Desktop (`lg+`)**: optional secondary column (detail panel); do not stretch forms edge-to-edge.

Touch targets ≥ **44×44 px** on tablet; add gap between destructive and primary actions.

## Components

- Presentational components: no `fetch`, no business rules — props in, events out.
- Extract **named components**, not inline render functions > ~15 lines.
- File ≤ **300 lines**; split by responsibility.
- Every async view handles **loading / empty / error / data**.
- **Loading:** use `BrandLoader`, `PagePreloader`, or `LoadingButton` from `core/ui` — same three-dot indicator as the tablet app (`BrandLoader`). Do not use CSS spinners or `CircularProgressIndicator`-style loaders.

## Pointer and cursor

- Clickable controls MUST show **`cursor: pointer`** (see [Web interaction](../principles/web-interaction.md)).
- Enforced globally in `web/src/index.css`; do not override with `cursor-default` on buttons or links.
- Disabled buttons: `cursor-not-allowed` + `disabled` / `aria-disabled`.
- Prefer `<button type="button">` or `<a href>` over clickable `<div>`s.

## UX

- Show **connection health** (API + live channel) in the shell.
- Serial numbers: large, high contrast, tabular figures (`font-variant-numeric: tabular-nums`).
- Destructive actions need confirmation modal.
- Plain text button labels — no decorative arrow icons on primary actions.

## Localization (Bengali + English)

- All user-visible strings via i18n files (`core/i18n`) — no literals in components except dev-only.
- Support Bengali digits where product requires; dates/numbers via `Intl` APIs.
- Test both locales in component tests when strings affect layout (truncation).

## Accessibility

- Prefer `<button>`, `<nav>`, `<main>`, `<header>` over generic `<div>` clicks.
- `aria-current="page"` on active nav links.
- Focus visible: use `focus-visible:ring-2` utilities — never remove focus outlines without a replacement.

## Dark mode

- **SHOULD** support `prefers-color-scheme` with navy-based dark palette matching the tablet app; verify contrast in both modes before shipping UI changes.
