# Algoriti Tech — Brand assets

Vector logos for **Algoriti** (company) and **AlgoritiQ** (product). All artwork is hand-authored SVG. Wordmarks use live text set in Plus Jakarta Sans Bold (fallback: Segoe UI / system sans-serif); convert to outlines before print or locked-font use.

## Concept

Both marks are built from chunky rounded bars in navy with one coral accent, so the company and product read as one family.

- **Algoriti (company):** bars indented step by step, like lines of code. The coral last bar is the step being executed. It stands for an algorithm.
- **AlgoritiQ (product):** three equal bars with the middle one coral and pushed forward. It stands for an ordered queue where the active item steps out of line.

Naming: **Algoriti** (capital A only) and **AlgoritiQ** (capital Q, set in coral in the wordmark).

## Color palette

| Role | Hex | Usage |
|------|-----|--------|
| **Navy** | `#0B1F3A` | Marks, wordmark text, dark backgrounds |
| **Coral** | `#FF5C39` | Accent bar, the Q, calls to action |
| **White** | `#FFFFFF` | Reversed marks, light backgrounds |

## Files

Each brand has its own folder under `logo/`: `logo/algoriti/` (company, file prefix `algoriti-tech-`) and `logo/algoritiq/` (product, prefix `algoritiq-`). The layout is identical in both.

| Path | Contents |
|------|----------|
| `svg/` | `*-logo.svg` (symbol), `*-wordmark.svg` (symbol + name), plus `-reversed` versions for dark backgrounds |
| `web/` | `favicon.ico` (16/32/48/64), `favicon.svg`, `favicon-16x16.png`, `-32x32.png`, `-48x48.png`, `apple-touch-icon.png` (180), `icon-192.png`, `icon-512.png`, `icon-maskable-512.png`, `site.webmanifest` |
| `android/res/` | Drop-in resource folders: `mipmap-{mdpi..xxxhdpi}/ic_launcher.png` and `ic_launcher_round.png`, adaptive icon in `mipmap-anydpi-v26/`, vector `drawable/ic_launcher_foreground.xml` and `ic_launcher_monochrome.xml` (Android 13 themed icons), `values/ic_launcher_background.xml` |
| `android/ic_launcher-playstore.png` | 512×512 Google Play store icon |

### Web usage

```html
<link rel="icon" href="/favicon.ico" sizes="48x48">
<link rel="icon" href="/favicon.svg" type="image/svg+xml">
<link rel="apple-touch-icon" href="/apple-touch-icon.png">
<link rel="manifest" href="/site.webmanifest">
<meta name="theme-color" content="#0B1F3A">
```

### Android usage

Copy the contents of `android/res/` into `app/src/main/res/` and set `android:icon="@mipmap/ic_launcher"` and `android:roundIcon="@mipmap/ic_launcher_round"` in `AndroidManifest.xml`. Upload `ic_launcher-playstore.png` in the Play Console.

## Usage

- **Clear space:** at least the height of one bar on all sides.
- **Minimum size:** symbol 16 px (favicon) / 24 px (logo); wordmarks 120 px wide.
- **Co-branding:** Algoriti first, AlgoritiQ second, e.g. "AlgoritiQ by Algoriti".
- **Do not** stretch, rotate, recolour outside the palette, or add effects.

## License

© Algoriti Tech. Assets in this folder are for Algoriti and AlgoritiQ projects unless otherwise noted.
