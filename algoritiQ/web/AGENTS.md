# Instructions for AI coding assistants

Before writing or changing code in `algoritiQ/web`:

1. Read [../docs/README.md](../docs/README.md) and the web docs relevant to your task:
   - [principles/](../docs/principles/) — architecture, offline PWA, security, testing strategy, [interaction](../docs/principles/web-interaction.md)
   - [standards/](../docs/standards/) — UI (Tailwind-first), [web code](../docs/standards/web-code.md) (**copyright header + commenting rules**), regression tests
2. Follow them strictly. Architecture in [../docs/architecture/](../docs/architecture/) takes precedence.
3. **Tailwind first** — add component CSS only when utilities are not enough.
4. Make the smallest change that solves the task. Do not add dependencies or change architecture without asking.
5. Bug fix → add a regression test. Before reporting done: `npm run lint`, `npm run test:run`, `npm run build`.

Setup: [README.md](./README.md).
