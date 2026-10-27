# Instructions for AI coding assistants

Before writing or changing any code in `algoritiQ/app`:

1. Read [docs/README.md](docs/README.md) and the principle docs relevant to your task (`principles/`: architecture, data, errors, security, performance, testing, localization (Bengali-first); `standards/`: UI, Android services, code style, testing, git).
2. Follow them strictly. They are mandatory, not suggestions. Architecture docs in `../docs/architecture/` take precedence.
3. Make the smallest change that solves the task. Don't add dependencies, change architecture, or touch unrelated files without asking.
4. Don't invent packages or APIs — check `pubspec.yaml` and existing code.
5. Bug fix → add a regression test. Before reporting done: `dart format .`, `flutter analyze` (zero issues), `flutter test`, then **verify on the physical tablet** (install + `adb` checks — see [dev-setup.md](docs/dev-setup.md) § AI / agent shells). Say what you could not verify.
6. Before any tablet operation that can wipe app data (`adb uninstall`, `pm clear`, etc.), **back up** SQLite + `FlutterSharedPreferences.xml` ([data-offline.md](docs/principles/data-offline.md), [dev-setup.md](docs/dev-setup.md) § Tablet data backup). Prefer `adb install -r` or prefs-only resets when that is enough.
7. If a rule conflicts with the task, stop and ask the user.

Setup and commands: [docs/dev-setup.md](docs/dev-setup.md) (including **AI / agent shells** if `flutter`/`adb` are missing in the terminal).
