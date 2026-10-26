# algoritiq_app

AlgoritiQ counter tablet app (Flutter, Android). Offline-first clinic queue host: owns session and queue state, SQLite, printing via Android services, and the local Backend API.

> **Developers and AI assistants: read [docs/principles/](docs/principles/README.md) before writing any code.**
> Rules there are mandatory. If a task conflicts with them, stop and ask.

## Docs

| Topic | Link |
| --- | --- |
| **Engineering principles (start here)** | [docs/principles/](docs/principles/README.md) |
| Dev setup (Windows, physical tablet) | [docs/dev-setup.md](docs/dev-setup.md) |
| System architecture | [../docs/architecture/](../docs/architecture/README.md) |
| Prod build & deploy | [../docs/prod-build-deploy/](../docs/prod-build-deploy/README.md) |

## Principles at a glance

| Area | Doc |
| --- | --- |
| Layers, folders, boundaries | [01 Architecture](docs/principles/01-architecture.md) |
| Widgets, theme, tablet layout, Bengali, a11y | [02 UI standards](docs/principles/02-ui-standards.md) |
| Kotlin services, Bluetooth, platform channels | [03 Android services](docs/principles/03-android-services.md) |
| Dart style, naming, lints | [04 Code style](docs/principles/04-code-style.md) |
| SQLite, transactions, idempotency | [05 Data & offline](docs/principles/05-data-offline.md) |
| Failures, logging | [06 Errors & logging](docs/principles/06-errors-logging.md) |
| Secrets, pairing, privacy | [07 Security & privacy](docs/principles/07-security-privacy.md) |
| Tests and coverage | [08 Testing](docs/principles/08-testing.md) |
| Performance, long shifts, API levels | [09 Performance & reliability](docs/principles/09-performance-reliability.md) |
| Git, PRs, deps, versioning | [10 Git & delivery](docs/principles/10-git-delivery.md) |

## Quick start

```powershell
cd algoritiQ\app
flutter pub get
flutter run        # tablet connected via USB
```

Before committing: `dart format .` → `flutter analyze` → `flutter test`.
