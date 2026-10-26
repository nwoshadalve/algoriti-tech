# Engineering principles

Mandatory for all code in `algoritiQ/app` — written by humans **or AI**.
Keywords: **MUST** / **MUST NOT** = required. **SHOULD** = default; deviate only with a written reason in the PR.

## Read before coding

| # | Doc | Covers |
| --- | --- | --- |
| 01 | [Architecture](./01-architecture.md) | Layers, folders, boundaries |
| 02 | [UI standards](./02-ui-standards.md) | Widgets, theme, tablet layout, Bengali, a11y |
| 03 | [Android services](./03-android-services.md) | Kotlin services, Bluetooth, platform channels |
| 04 | [Code style](./04-code-style.md) | Dart style, naming, size limits, lints |
| 05 | [Data & offline](./05-data-offline.md) | SQLite, transactions, idempotency, events |
| 06 | [Errors & logging](./06-errors-logging.md) | Failures, logs, fail-safe behavior |
| 07 | [Security & privacy](./07-security-privacy.md) | Secrets, pairing, TLS, data minimization |
| 08 | [Testing](./08-testing.md) | What to test, how, coverage |
| 09 | [Performance & reliability](./09-performance-reliability.md) | Frame budget, long shifts, API levels |
| 10 | [Git & delivery](./10-git-delivery.md) | Commits, PRs, deps, docs, versioning |

Source of truth for *what* the system is: [../../../docs/architecture/](../../../docs/architecture/).
These docs define *how* we write the code.

## Precedence

1. Architecture docs (`algoritiQ/docs/architecture/`)
2. These principles
3. Personal / tool preference

If rules conflict or a task needs to break one: **stop and ask**, don't improvise.

## Rules for AI assistants

1. Read this folder (at least the docs relevant to the task) before writing code.
2. Make the smallest change that solves the task. No drive-by refactors, no unrelated files.
3. MUST NOT add a dependency, change architecture, or rename public APIs without asking.
4. MUST NOT invent packages, APIs or file paths — check `pubspec.yaml` and the code first.
5. Don't edit generated files (`*.g.dart`, `*.freezed.dart`) or `build/`.
6. Never commit secrets, keystores, `.env`, `key.properties`.
7. Verify before claiming done (below). Report anything you could not verify.

## Definition of done

- [ ] `dart format .` clean
- [ ] `flutter analyze` — zero issues
- [ ] `flutter test` passes; new logic has tests ([08](./08-testing.md))
- [ ] Strings localized, no hardcoded colors/sizes ([02](./02-ui-standards.md))
- [ ] No business logic in widgets; boundaries respected ([01](./01-architecture.md))
- [ ] Errors handled, no PII in logs ([06](./06-errors-logging.md), [07](./07-security-privacy.md))
- [ ] UI changes checked on the physical tablet
- [ ] Docs updated if behavior or setup changed
