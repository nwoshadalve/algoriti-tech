# algoritiq_app

AlgoritiQ counter tablet app (Flutter, Android). Offline-first clinic queue host: owns session and queue state, SQLite, printing via Android services, and the local Backend API.

> **Developers and AI assistants: read [docs/README.md](docs/README.md) before writing any code.**
> Rules there are mandatory. If a task conflicts with them, stop and ask.

## Docs

| Topic | Link |
| --- | --- |
| **Engineering principles (start here)** | [docs/README.md](docs/README.md) |
| Dev setup (Windows, physical tablet) | [docs/dev-setup.md](docs/dev-setup.md) |
| System architecture | [../docs/architecture/](../docs/architecture/README.md) |
| Prod build & deploy | [../docs/prod-build-deploy/](../docs/prod-build-deploy/README.md) |

## Principles at a glance

**Principles** (what we protect) — [docs/principles/](docs/principles/)

| Area | Doc |
| --- | --- |
| Layers, folders, boundaries | [Architecture](docs/principles/architecture.md) |
| SQLite, transactions, idempotency | [Data & offline](docs/principles/data-offline.md) |
| Failures, logging | [Errors & logging](docs/principles/errors-logging.md) |
| Secrets, pairing, privacy | [Security & privacy](docs/principles/security-privacy.md) |
| Long shifts, API levels | [Performance & reliability](docs/principles/performance-reliability.md) |
| Regression-test strategy | [Testing](docs/principles/testing.md) |

**Standards** (how we write code) — [docs/standards/](docs/standards/)

| Area | Doc |
| --- | --- |
| Widgets, theme, tablet layout, Bengali, a11y | [UI](docs/standards/ui.md) |
| Kotlin services, Bluetooth, platform channels | [Android services](docs/standards/android-services.md) |
| Dart style, naming, lints | [Code style](docs/standards/code-style.md) |
| Writing regression tests | [Testing](docs/standards/testing.md) |
| Git, PRs, deps, versioning | [Git & delivery](docs/standards/git-delivery.md) |

## Quick start

```powershell
cd algoritiQ\app
flutter pub get
flutter run        # tablet connected via USB
```

Before committing: `dart format .` → `flutter analyze` → `flutter test`.
