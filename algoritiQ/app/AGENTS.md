# Instructions for AI coding assistants

Before writing or changing any code in `algoritiQ/app`:

1. Read [docs/principles/README.md](docs/principles/README.md) and the principle docs relevant to your task (architecture, UI, Android services, code style, data, errors, security, testing, performance, git).
2. Follow them strictly. They are mandatory, not suggestions. Architecture docs in `../docs/architecture/` take precedence.
3. Make the smallest change that solves the task. Don't add dependencies, change architecture, or touch unrelated files without asking.
4. Don't invent packages or APIs — check `pubspec.yaml` and existing code.
5. Before reporting done: `dart format .`, `flutter analyze` (zero issues), `flutter test`. Say what you could not verify.
6. If a rule conflicts with the task, stop and ask the user.

Setup and commands: [docs/dev-setup.md](docs/dev-setup.md).
