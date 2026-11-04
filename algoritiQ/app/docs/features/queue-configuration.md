# Queue configuration

Normative product spec: **[queue-configuration.md](../../../docs/features/queue-configuration.md)** in `algoritiQ/docs/features/`.

## Where it lives in the product

| Surface | Route / entry | Notes |
| --- | --- | --- |
| Web admin UI | `/config/queue` | Served by the tablet; see [web-app.md](./web-app.md) § Queue configuration |
| Web queue desk | `/queue-desk` | Start session, issue tokens, call queue — not configuration |
| Flutter tablet shell | — | No dedicated queue-config screen in v1; API and SQLite in `lib/features/queue/` |

## Tablet code

- **Domain and validation:** `lib/features/queue/domain/` (`queue_validation.dart`, `queue_models.dart`)
- **Persistence:** `lib/features/queue/data/drift_queue_repository.dart` (template seed §2 in shared doc)
- **Admin rules:** `lib/features/queue/application/queue_service.dart`
- **HTTP:** `lib/api/local_api_server.dart` — `_queueApi` (`/api/v1/queue/…`) and desk routes under `/api/v1/queue-desk/…`

## Web code

- **Configuration page:** `web/src/features/queue/`
- **Desk operations:** `web/src/features/board/`, `web/src/core/api/queueDesk.ts`

When the shared spec and code disagree, **fix the code or update the shared doc** — do not maintain a second copy of the rules here.
