# 10 — Git & delivery

## Branches & commits

- Branch from `main`: `feature/<topic>`, `fix/<topic>`, `docs/<topic>`, `chore/<topic>`.
- [Conventional Commits](https://www.conventionalcommits.org): `feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`. Imperative subject ≤ 72 chars; body explains *why*.
- Small, single-purpose commits and PRs. Don't mix refactors with behavior changes.
- MUST NOT commit: `build/`, `.dart_tool/`, `local.properties`, keystores, `key.properties`, `.env`, IDE files, screenshots with PII.
- Never rewrite shared history or force-push `main`.

## Pull requests

- Describe what/why, how it was tested, and screenshots for UI changes (from the tablet).
- Checklist: the Definition of Done in the [principles README](../README.md).
- Review for: layering ([Architecture](../principles/architecture.md)), security ([Security & privacy](../principles/security-privacy.md)), tests ([Testing](./testing.md)).

## Dependencies

- Add via PR with justification (why, alternatives, license, size). Update `pubspec.lock`.
- Remove unused dependencies promptly.

## Decisions & docs

- Architectural choice or deviation → short ADR in `docs/decisions/NNN-title.md` (context, decision, consequences).
- Behavior or setup change → update the relevant doc in the same PR.
- Keep docs short, precise, to the point.

## Versioning & release

- `version: x.y.z+build` in `pubspec.yaml`. Bump **+build** every clinic release; bump **x.y.z** for user-visible changes.
- Release builds only from a clean, tagged commit, signed with the release key ([prod build & deploy](../../../docs/prod-build-deploy/README.md)).
- Never ship debug builds to clinics.

## CI (when added)

Pipeline order: `format check → analyze → test → build apk/aab`. A red pipeline blocks merge.

## Working with AI assistants

- Give the assistant the task, the relevant principle docs, and the acceptance criteria.
- Review AI diffs like any other: layering, tests, no stray files, no invented APIs.
- The assistant rules in the [principles README](../README.md) apply to every tool and model.
