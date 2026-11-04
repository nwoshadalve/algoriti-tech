# Instructions for AI coding assistants

Before writing or changing any code in `algoritiQ/tv-app`:

1. Read [docs/README.md](docs/README.md) and the principle docs relevant to your task (`principles/`: architecture, connectivity-sync, errors, security, performance, testing, localization; `standards/`: UI, [code style](docs/standards/code-style.md), testing, git).
2. Follow them strictly. They are mandatory, not suggestions. Architecture docs in `../docs/architecture/` and OpenAPI take precedence.
3. Make the smallest change that solves the task. Don't add dependencies, change architecture, or touch unrelated files without asking.
4. Don't invent packages or APIs — check `gradle/libs.versions.toml` and existing code.
5. Bug fix → add a regression test. Before reporting done: `./gradlew check`, then verify on an **Android TV emulator** (see [dev-setup.md](docs/dev-setup.md)).
6. v1 announcements: tablet prepares audio; TV plays only ([queue-product-decisions.md](../docs/features/queue-product-decisions.md)). Do not add on-TV TTS unless product changes.
7. If a rule conflicts with the task, stop and ask the user.

Setup and commands: [docs/dev-setup.md](docs/dev-setup.md).
