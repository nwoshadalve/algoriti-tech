# Localization — Bengali first

Counter staff work in **Bengali (বাংলা)**. Bengali is a first-class language, not a translation added later: every feature MUST be fully usable in Bengali, at the same quality as English. English is the second language, and the fallback only when a Bengali string is missing.

## Principles

- **Bengali-ready by default.** A feature is not done until its Bengali strings, layout and tests are done.
- **Bengali is the default locale** on the tablet. Staff can switch to English; the choice persists across restarts and works offline.
- **No hardcoded user-visible text.** Every string comes from ARB (`lib/l10n/app_bn.arb`, `app_en.arb`). Adding a key to one file without the other MUST fail review.
- **Never rely on string length.** Bengali is often longer and taller than English; layouts MUST wrap or scale, never clip or overflow.
- **Domain stays language-free.** `domain` and `data` carry codes and enums, never display text. Presentation maps them to localized strings ([Architecture](./architecture.md)).

## What must be localized

- All UI text, tooltips, `Semantics` labels, dialogs, snackbars and validation messages.
- Error and failure messages ([Errors & logging](./errors-logging.md)): human, actionable, in the active language.
- Printed output (tokens/receipts) when shown to patients — the printer path MUST handle Bengali glyphs, or render text as an image. Verify on the real printer.
- Dates, times, numbers and currency via `intl`, using the active locale. Bengali digits (০১২৩) where the product requires; serial numbers shown to the public MUST be consistent across tablet, TV and web.

## Rules

- MUST bundle a Bengali-capable font (Noto Sans Bengali); never depend on a device font. Verify conjuncts (যুক্তাক্ষর) and vowel marks aren't clipped — set line height deliberately.
- MUST NOT concatenate translated fragments; use ICU placeholders and plurals in ARB.
- MUST NOT truncate Bengali text by character count (it breaks grapheme clusters). Use `characters` or let the layout ellipsize.
- Sorting and search MUST work for Bengali input; don't assume ASCII or case folding.
- Logs and analytics stay in English/codes — localization is for the user only ([Errors & logging](./errors-logging.md)).
- Don't machine-translate and ship. Bengali copy needs review by a native speaker before release.

## Testing

- Widget tests for key screens run in **both** `bn` and `en`; assert no overflow and that the localized text renders.
- Include a long-string / large-text-scale case for every screen with dense layout.
- UI changes are checked in Bengali on the physical tablet ([Testing](./testing.md)).

How-to details (ARB workflow, fonts, formatting): [UI standards](../standards/ui.md).
