# 04 — Git & delivery

Same branch and commit conventions as [app/docs/standards/git-delivery.md](../../../app/docs/standards/git-delivery.md).

## Versioning

- `versionName` / `versionCode` in `app/build.gradle.kts`.
- Bump **versionCode** every clinic sideload; bump **versionName** for user-visible changes.

## Dependencies

- Add via PR with justification; update version catalog `libs.versions.toml`.
- Remove unused dependencies promptly.

## ADRs

- Architectural choice → `docs/decisions/NNN-title.md` (context, decision, consequences).

## Release

- Signed release APK/AAB per [prod-build-deploy](../../../docs/prod-build-deploy/README.md) when TV release pipeline exists.
- Never ship debug builds to clinics.
