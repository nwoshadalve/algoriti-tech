# Engineering principles (Android TV)

Mandatory for all code in `algoritiQ/tv-app` — written by humans **or AI**.
Keywords: **MUST** / **MUST NOT** = required. **SHOULD** = default; deviate only with a written reason in the PR.

Two kinds of docs:

- **Principles** — *what we protect and why*: design rules and strategy.
- **Standards** — *how we write code*: concrete conventions to follow.

## Principles ([principles/](./principles/))

| Doc | Covers |
| --- | --- |
| [Architecture](./principles/architecture.md) | Layers, folders, API boundaries |
| [Connectivity & sync](./principles/connectivity-sync.md) | Snapshot, WebSocket, reconnect, disconnected UI |
| [Errors & logging](./principles/errors-logging.md) | Failures, logs, fail-safe behavior |
| [Security & privacy](./principles/security-privacy.md) | Pairing, TLS, tokens, data minimization |
| [Performance & reliability](./principles/performance-reliability.md) | Kiosk display, LAN latency, API levels |
| [Testing](./principles/testing.md) | Regression strategy and critical paths |
| [Localization](./principles/localization.md) | Bengali-only TV UI, fonts, digits |

## Standards ([standards/](./standards/))

| Doc | Covers |
| --- | --- |
| [UI](./standards/ui.md) | Compose for TV, layout, safe area, Bengali |
| [Code style](./standards/code-style.md) | Kotlin style, naming, size limits |
| [Testing](./standards/testing.md) | Unit and integration tests |
| [Git & delivery](./standards/git-delivery.md) | Commits, PRs, dependencies, versioning |

## Features ([features/](./features/))

| Doc | Covers |
| --- | --- |
| [Pairing](./features/pairing.md) | PIN on TV, staff confirms on tablet |
| [Setup audio](./features/setup-audio.md) | Volume, test clip, health reporting |
| [Display states](./features/display-states.md) | Idle, live, disconnected waiting-room UI |
| [Announcements & audio](./features/announcements-audio.md) | Download and play tablet-prepared clips |

Queue display and announcements — accepted product decisions: [queue-product-decisions.md](../../docs/features/queue-product-decisions.md). UI reference mock: [mock/tv-app](../../mock/tv-app/README.md).

Guides: [Dev setup](./dev-setup.md).

Source of truth for *what* the system is: [../../docs/architecture/](../../docs/architecture/). API contract: [../../docs/api/openapi.yaml](../../docs/api/openapi.yaml).

Implementation home for this component: linked from [02-kotlin-android-tv-application.md](../../docs/architecture/02-kotlin-android-tv-application.md).

## Precedence

1. Architecture docs (`algoritiQ/docs/architecture/`) and OpenAPI + accepted `docs/features/*`
2. Principles (this folder)
3. Standards
4. Personal / tool preference

If rules conflict or a task needs to break one: **stop and ask**, don't improvise.

## Rules for AI assistants

1. Read this folder (at least the docs relevant to the task) before writing code.
2. Make the smallest change that solves the task. No drive-by refactors, no unrelated files.
3. MUST NOT add a dependency, change architecture, or rename public APIs without asking.
4. MUST NOT invent packages, APIs or file paths — check Gradle catalogs and the code first.
5. Don't edit generated files or `build/`.
6. Never commit secrets, keystores, `local.properties`.
7. Bug fix → add a regression test. Verify before claiming done (below).

## Definition of done

- [ ] `./gradlew ktlintCheck detekt` (when configured) and `./gradlew check` pass
- [ ] `./gradlew :app:assembleDebug` succeeds
- [ ] No hardcoded patient-identifying data on screen or in logs
- [ ] User-visible strings in Bengali per [Localization](./principles/localization.md); bundled Bengali font
- [ ] No business logic in Composables beyond presentation mapping; boundaries respected ([Architecture](./principles/architecture.md))
- [ ] UI checked on **Android TV emulator** (API 30 minimum) and documented in PR if layout changed
- [ ] Docs updated if behavior or setup changed
