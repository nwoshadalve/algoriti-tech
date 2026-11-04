# 06 — Localization

Waiting-room display is **Bengali-only** in v1 (no language toggle on TV), matching [mock/tv-app](../../../mock/tv-app/README.md).

## Principles

- **Bundled Bengali font** (Noto Sans Bengali) — never rely on TV OEM fonts for conjuncts.
- **Bengali digits** for public serial display where product requires consistency with tablet/web.
- API and domain use **integers** for serials; presentation formats for display.
- Logs and analytics stay English/codes — localization is for on-screen users only.

## Rules

- MUST NOT hardcode user-visible strings in Kotlin — use `strings.xml` (Bengali default `values-bn` or single `values` with Bengali copy).
- MUST NOT truncate Bengali by raw `length` — use proper ellipsis or layout wrap.
- Layouts MUST tolerate longer Bengali labels without clipping (overscan safe area in [UI standards](../standards/ui.md)).

## English

- No English UI in v1 TV app. If bilingual TV is requested later, treat as a product change + ADR.
