# TV live WebSocket payload

The tablet Backend API exposes **`wss://<host>:8443/api/v1/ws/live?token=<bearer>`** on the same TLS identity as HTTPS (self-signed clinic certificate).

## Connect

After auth, the server sends:

1. `{ "type": "hello", "eventSequence", "serverTime" }`
2. `{ "type": "snapshot", "eventSequence", "payload": { "displays": [ … ] } }`

Each entry in **`displays`** matches one chamber (see `mock/tv-app/src/mock-session-data.json` + `tv-display.js`):

| Field | Purpose |
| --- | --- |
| `chamberId` | TV filters to its paired chamber when pairing ships |
| `sessionOpen` | Whether a queue session is open |
| `sessionId`, `businessDate` | When open |
| `doctor` | OpenAPI `Doctor` + `photoUrl` (`/api/v1/doctor/photo`) |
| `chamber` | Name, location, phone |
| `queueTypes` | Enabled types (id, bilingual names) |
| `called` | `{ tokenId, queueTypeId, serial }` or null |
| `waiting` | Map of queue type id → ascending waiting serials |

On-screen rules: **serials and queue type labels only** ([queue-product-decisions.md](./queue-product-decisions.md)).

## Events

| `name` | When |
| --- | --- |
| `queue.updated` | Issue, enter, skip, cancel, session start — payload includes `chamberId` and fresh `display` |
| `token.called` | Call or recall — `callId`, `serial`, optional future `announcementUrl`, plus `display` |

All use `{ "type": "event", "eventSequence", "name", "payload" }`. Reply to `{ "type": "ping" }` with `{ "type": "pong" }`.

Implementation: `app/lib/features/tv_live/`, `app/lib/api/live_event_bus.dart`.
