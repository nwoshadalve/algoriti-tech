# Instructions for AI coding assistants

Before writing or changing code in `algoritiQ/web`:

1. Read [../docs/README.md](../docs/README.md) and the web docs relevant to your task:
   - [principles/](../docs/principles/) — architecture, offline PWA, security, testing strategy, [interaction](../docs/principles/web-interaction.md)
   - [standards/](../docs/standards/) — UI (Tailwind-first), [web code](../docs/standards/web-code.md) (**copyright header + commenting rules**), regression tests
2. Follow them strictly. Architecture in [../docs/architecture/](../docs/architecture/) takes precedence.
3. **Tailwind first** — add component CSS only when utilities are not enough.
4. **Server state:** use TanStack Query (`core/query`, feature `*QueryKeys.ts`) — no ad-hoc module caches for shared API data ([web-code](../docs/standards/web-code.md#tanstack-query-server-state)).
5. Make the smallest change that solves the task. Do not add dependencies or change architecture without asking.
6. Bug fix → add a regression test. Before reporting done: `npm run lint`, `npm run test:run`, `npm run build`.
7. **Tablet deploy:** The dashboard is bundled inside the Flutter app. Any change under `algoritiQ/web` is **not done** until you run [web-build-and-deploy](../app/docs/web-build-and-deploy.md) (`bundle_web.py`, `flutter build apk`, `adb install -r`) and smoke-test on the physical tablet — same rule as [app testing §7](../app/docs/principles/testing.md).

Setup: [README.md](./README.md). Tablet commands: [app dev-setup](../app/docs/dev-setup.md) § AI / agent shells.
