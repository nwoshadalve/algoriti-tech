# Engineering principles

Mandatory for all code in `algoritiQ/app` — written by humans **or AI**.
Keywords: **MUST** / **MUST NOT** = required. **SHOULD** = default; deviate only with a written reason in the PR.

Two kinds of docs:

- **Principles** — *what we protect and why*: design rules and strategy.
- **Standards** — *how we write code*: concrete conventions to follow.

## Principles ([principles/](./principles/))

| Doc | Covers |
| --- | --- |
| [Architecture](./principles/architecture.md) | Layers, folders, boundaries |
| [Data & offline](./principles/data-offline.md) | SQLite, transactions, idempotency, events |
| [Errors & logging](./principles/errors-logging.md) | Failures, logs, fail-safe behavior |
| [Security & privacy](./principles/security-privacy.md) | Secrets, pairing, TLS, data minimization |
| [Performance & reliability](./principles/performance-reliability.md) | Frame budget, long shifts, API levels |
| [Testing](./principles/testing.md) | Regression-test strategy and critical paths |

## Standards ([standards/](./standards/))

| Doc | Covers |
| --- | --- |
| [UI](./standards/ui.md) | Widgets, theme, tablet layout, Bengali, accessibility |
| [Android services](./standards/android-services.md) | Kotlin services, Bluetooth, platform channels |
| [Code style](./standards/code-style.md) | Dart style, naming, size limits, lints |
| [Testing](./standards/testing.md) | How to write regression tests |
| [Git & delivery](./standards/git-delivery.md) | Commits, PRs, dependencies, docs, versioning |

Source of truth for *what* the system is: [../../../docs/architecture/](../../docs/architecture/).

## Precedence

1. Architecture docs (`algoritiQ/docs/architecture/`)
2. Principles
3. Standards
4. Personal / tool preference

If rules conflict or a task needs to break one: **stop and ask**, don't improvise.

## Rules for AI assistants

1. Read this folder (at least the docs relevant to the task) before writing code.
2. Make the smallest change that solves the task. No drive-by refactors, no unrelated files.
3. MUST NOT add a dependency, change architecture, or rename public APIs without asking.
4. MUST NOT invent packages, APIs or file paths — check `pubspec.yaml` and the code first.
5. Don't edit generated files (`*.g.dart`, `*.freezed.dart`) or `build/`.
6. Never commit secrets, keystores, `.env`, `key.properties`.
7. Bug fix → add a regression test. Verify before claiming done (below).

## Definition of done

- [ ] `dart format .` clean
- [ ] `flutter analyze` — zero issues
- [ ] `flutter test` passes; bug fixes and critical-path changes have regression tests ([principles](./principles/testing.md))
- [ ] Strings localized, no hardcoded colors/sizes ([UI](./standards/ui.md))
- [ ] No business logic in widgets; boundaries respected ([Architecture](./principles/architecture.md))
- [ ] Errors handled, no PII in logs ([Errors & logging](./principles/errors-logging.md), [Security](./principles/security-privacy.md))
- [ ] UI changes checked on the physical tablet
- [ ] Docs updated if behavior or setup changed
