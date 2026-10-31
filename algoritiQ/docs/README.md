# AlgoritiQ engineering docs

Documentation for the **AlgoritiQ** monorepo: architecture, delivery, and **web dashboard** engineering rules.

## Architecture (system design)

Source of truth for *what* each component is and how they connect:

- [Architecture index](./architecture/README.md)
- [React web application](./architecture/04-react-web-application.md)
- [Backend API](./architecture/05-backend-api.md)

The Flutter tablet app has its own principles under [`app/docs/`](../app/docs/README.md).

## Web dashboard (`algoritiQ/web`)

Mandatory for humans and AI working on the React SPA:

| Kind | Folder | Purpose |
| --- | --- | --- |
| **Principles** | [principles/](./principles/) | What we protect: architecture, offline, security, testing strategy |
| **Standards** | [standards/](./standards/) | How we write UI, TypeScript, and regression tests |

Start with [principles/README.md](./principles/README.md) and [standards/README.md](./standards/README.md).

## Precedence

1. `docs/architecture/` — component boundaries and deployment
2. `docs/principles/` — web design rules
3. `docs/standards/` — concrete conventions
4. `web/AGENTS.md` — AI entry point for the SPA repo root

If rules conflict or a task needs to break one, **stop and ask** — do not improvise.

## Product features (planning)

Normative **accepted decisions** for upcoming work:

- [Queue configuration and sessions](./features/queue-configuration.md)
- [Patient entry and queue operations](./features/patient-entry-and-queue-operations.md)
- [Queue: patient entry, analytics, announcements](./features/queue-product-decisions.md)
- [Admin audit log](./features/audit-log.md) — living event catalogue; update as features are finalized

## Other folders

| Folder | Contents |
| --- | --- |
| [features/](./features/) | Product decisions for cross-cutting features (queue, etc.) |
| [dev-setup/](./dev-setup/README.md) | Flutter tablet + web dashboard local setup |
| [prod-build-deploy/](./prod-build-deploy/README.md) | Release builds |
| [discussions/](./discussions/) | R&D notes (non-normative) |
