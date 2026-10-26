# Instructions for AI coding assistants

Before writing or changing any code in `algoritiQ/app`:

1. Read [docs/README.md](docs/README.md) and the principle docs relevant to your task (`principles/`: architecture, data, errors, security, performance, testing, localization (Bengali-first); `standards/`: UI, Android services, code style, testing, git).
2. Follow them strictly. They are mandatory, not suggestions. Architecture docs in `../docs/architecture/` take precedence.
3. Make the smallest change that solves the task. Don't add dependencies, change architecture, or touch unrelated files without asking.
4. Don't invent packages or APIs — check `pubspec.yaml` and existing code.
5. Bug fix → add a regression test. Before reporting done: `dart format .`, `flutter analyze` (zero issues), `flutter test`. Say what you could not verify.
6. If a rule conflicts with the task, stop and ask the user.

Setup and commands: [docs/dev-setup.md](docs/dev-setup.md).
