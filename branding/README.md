# Algoriti Tech — Brand assets

Vector logos for **Algoriti Tech** (company) and **AlgoritiQ** (product). All artwork is hand-authored SVG; no raster exports are required for web or print at typical sizes.

## Color palette

| Role | Hex | Usage |
|------|-----|--------|
| **Ink** | `#0F172A` | Primary text, wordmarks, dark UI |
| **Slate** | `#475569` | Secondary text (“Tech” suffix, captions) |
| **Deep** | `#0E4F6E` | Company mark, headers, trust surfaces |
| **Flow** | `#14B8A6` | Product accent, links, active states |
| **Glow** | `#5EEAD4` | Highlights on gradients, subtle emphasis |
| **Mist** | `#F1F5F9` | Light backgrounds behind marks |

Gradients in the marks blend **Deep → Flow** (company) and **Deep → Flow → Glow** (product) so both brands feel related while AlgoritiQ reads slightly more energetic.

## Typography direction

Wordmarks use **system UI stacks** in the SVG (`Segoe UI`, `system-ui`, sans-serif) so files stay portable. For app and web UI, prefer:

- **Headings / wordmark:** [Inter](https://rsms.me/inter/) or Segoe UI — semibold for “Algoriti”, regular or medium for “Tech”.
- **Product name:** Same family; emphasize the **Q** with the Flow accent (see product wordmark).

Replace `<text>` with outlined paths only if you need a locked custom font in print pipelines.

## Files

| File | Description |
|------|-------------|
| `algoriti-tech-logo.svg` | Company symbol (graph / algorithm motif) |
| `algoriti-tech-wordmark.svg` | Symbol + “Algoriti Tech” |
| `algoriti-tech-favicon.svg` | 32×32 simplified company mark |
| `algoritiq-logo.svg` | Product symbol (Q + queue motif) |
| `algoritiq-wordmark.svg` | Symbol + “AlgoritiQ” |
| `algoritiq-favicon.svg` | 32×32 simplified product mark |

## Usage

- **Clear space:** Keep at least the height of the symbol as padding on all sides.
- **Minimum size:** Symbol ≥ 24 px; wordmarks ≥ 120 px wide on screen.
- **On dark backgrounds:** Use white (`#FFFFFF`) for wordmark text and set symbol fills to `#FFFFFF` / `#5EEAD4` or place the mark on a Mist rounded panel.
- **Co-branding:** Place Algoriti Tech (company) first; AlgoritiQ (product) second, e.g. “AlgoritiQ by Algoriti Tech” with the product wordmark at larger size.
- **Do not** stretch, rotate, change palette hues, or add effects that reduce legibility on clinic displays.

## License

© Algoriti Tech. Assets in this folder are for Algoriti Tech and AlgoritiQ projects unless otherwise noted.
