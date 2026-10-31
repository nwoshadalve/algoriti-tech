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
| [Localization](./principles/localization.md) | Bengali-first: every feature fully usable in Bengali |

## Standards ([standards/](./standards/))

| Doc | Covers |
| --- | --- |
| [UI](./standards/ui.md) | Widgets, theme, tablet layout, Bengali, accessibility |
| [Android services](./standards/android-services.md) | Kotlin services, Bluetooth, platform channels |
| [Code style](./standards/code-style.md) | Dart style, naming, size limits, lints |
| [Testing](./standards/testing.md) | How to write regression tests |
| [Git & delivery](./standards/git-delivery.md) | Commits, PRs, dependencies, docs, versioning |

## Features ([features/](./features/))

| Doc | Covers |
| --- | --- |
| [Activation](./features/activation.md) | Offline license key, device code, expiry |
| [First-time setup](./features/setup.md) | Doctor profile, chambers, ready |
| [Admin access](./features/admin-access.md) | Claim code, first admin, local HTTPS API, passwords, audit |
| [Keep-alive](./features/keep-alive.md) | Background service, boot start, permission guide |
| [Local name](./features/local-name.md) | `algoritiq.local` on the clinic Wi-Fi, no internet needed |
| [Authentication](./features/authentication.md) | Sign-in, session tokens (why not JWT), password reset with the activation key |
| [Web app](./features/web-app.md) | The React site served by the tablet, how to build and bundle it |
| [Connectivity](./features/connectivity.md) | The receptionist's printer page: pair once, automatic reconnect, battery and paper |
| [Monitoring](./features/monitoring.md) | The admin monitoring page: tablet CPU, RAM, storage, Bluetooth, services, retry |

Queue (patient entry, stats, TV audio) — accepted product decisions: [queue-product-decisions.md](../../docs/features/queue-product-decisions.md) (repo `docs/features/`).

Guides: [Build the web app and deploy it on the tablet](./web-build-and-deploy.md) · [Dev setup](./dev-setup.md).

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
- [ ] Strings localized in **Bengali and English**, no hardcoded colors/sizes ([Localization](./principles/localization.md), [UI](./standards/ui.md))
- [ ] No business logic in widgets; boundaries respected ([Architecture](./principles/architecture.md))
- [ ] Errors handled, no PII in logs ([Errors & logging](./principles/errors-logging.md), [Security](./principles/security-privacy.md))
- [ ] UI changes checked on the physical tablet
- [ ] **`algoritiQ/app` changes deployed to the tablet** (`flutter build apk` + `adb install -r`; bundle web first if `web/` or `assets/web/` changed) — see [Testing principles](./principles/testing.md) §7 and [web-build-and-deploy](./web-build-and-deploy.md)
- [ ] Docs updated if behavior or setup changed
