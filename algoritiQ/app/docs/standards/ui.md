# 02 — UI standards

Counter tablet UI: used all day by non-technical staff, under time pressure, in Bengali.

## Widgets

- Widgets are dumb: MUST NOT contain business logic or call DB / channels / HTTP.
- Extract **widget classes**, not helper methods that return `Widget`.
- `build()` ≤ ~80 lines; file ≤ 300 lines. Split by responsibility.
- `const` constructors wherever possible. Stable `Key`s in dynamic lists. Use `ListView.builder` for lists.
- Don't do work in `build()` (no parsing, sorting, I/O). Rebuild narrowly (`ref.watch(x.select(...))`).
- Dispose every controller, `FocusNode`, subscription.

## Design system

- Material 3. All colors, text styles, spacing, radii come from `core/theme` tokens.
- MUST NOT hardcode colors, font sizes, paddings, or magic numbers in widgets.
- Spacing on a 4/8 dp grid. One `ThemeData` (light first; dark optional).
- Reuse shared components in `core/widgets` before creating new ones.
- Logo: always use `BrandLogo` (`.wordmark` / `.symbol`); it switches navy/white variants by theme. Never hardcode logo files or colors. Brand colors live in `core/theme/brand_colors.dart`; brand font (Plus Jakarta Sans, OFL) is bundled in `assets/fonts`.
- Native splash wordmark PNGs are generated from `BrandLogo`: after changing the logo, run `flutter test tool/generate_splash_logo_test.dart`.
- Support **light and dark** themes (`ThemeMode.system`); verify every screen in both.

## Layout (tablet-first, any Android)

- Responsive: `LayoutBuilder`/`MediaQuery` + breakpoints; support landscape and portrait. No fixed-pixel screens.
- App MUST still work on phones and small screens (minSdk 21 devices) — never assume the Honor Pad X7 size.
- Touch targets ≥ 48×48 dp, with spacing between destructive and primary actions.
- Respect safe areas / system bars; no overflow at text scale 1.0–2.0.

## UX for the counter

- Core flow (create + print token) in **≤ 2 taps**; primary action large and obvious.
- Serial numbers large, high contrast, readable from a distance.
- Always show system health: session open, printer, TV, laptop connection.
- Destructive actions (cancel, skip, end session) need confirmation or undo.
- Every async screen handles **loading / empty / error / data** — no blank screens or infinite spinners.
- Show printer failure as `FAILED` with a **Reprint** action; never block queue actions on it.
- Public/queue views show the **serial number only** — no patient names/phones.

## Localization (Bengali + English)

- All user-visible strings via ARB (`l10n/app_bn.arb`, `app_en.arb`) — no string literals in widgets.
- Bundle **Noto Sans Bengali**; verify conjuncts and line height aren't clipped.
- Format numbers/dates via `intl`; support Bengali digits where product requires.
- Error messages are human, localized, actionable — never raw exception text.

## Accessibility

- `Semantics` labels on icon-only buttons and custom widgets.
- Contrast ≥ 4.5:1 (text), ≥ 3:1 (large text/icons). Don't convey state by color alone.
- Logical focus order; keyboard/external-input friendly.

## Navigation & performance

- Declarative routes in one place (`go_router`); no scattered `Navigator.push(MaterialPageRoute(...))`.
- Heavy work (receipt bitmap rendering, large parsing) off the UI isolate (`compute`/`Isolate.run`).
- Keep animations short and purposeful; none in the critical token flow.
