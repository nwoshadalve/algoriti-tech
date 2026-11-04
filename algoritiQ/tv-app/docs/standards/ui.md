# 01 — UI (Compose for TV)

Reference layout: [mock/tv-app](../../../mock/tv-app/README.md). Target viewports **1366×768** (primary) and **1280×720**.

## Theme

- Light theme for waiting-room readability (match mock).
- No clinic logo or language switch on TV in v1.
- Typography: Noto Sans Bengali for all user-visible text.

## Focus & navigation

- D-pad / remote only — every interactive control MUST be focusable with visible focus indicator.
- Use Compose for TV focus APIs; avoid touch-only patterns.
- Setup screens (pairing, audio) are rare; display screens are mostly read-only.

## Layout rules

- **Safe area / overscan**: pad content (~5% margin) so serials are not clipped on cheap panels.
- **display-live**: left **ঘোষণা** (large called serial + type); right **অপেক্ষমাণ** — max **5** serials per queue type, then **"আর N জন"**.
- **Footer**: doctor photo + name with title + chamber name from snapshot API.
- **Top bar**: session / connection status.

## Privacy

- Queue lists and call panel: **serials and type labels only**.
- MUST NOT show patient name or phone anywhere on TV UI.

## Accessibility

- Content descriptions in Bengali for focusable controls.
- Sufficient contrast for distance viewing (waiting room).
