# Queue configuration and sessions

Status: **accepted** for v1 queue configuration.  
Scope: admin configuration, chamber queue sessions, serial allocation boundaries, and role permissions.  
Related: [Queue product decisions](./queue-product-decisions.md), [Patient entry and queue operations](./patient-entry-and-queue-operations.md), [Audit log](./audit-log.md), [Data and offline](../../app/docs/principles/data-offline.md).

**Code map**

| Layer | Location |
| --- | --- |
| Tablet persistence and rules | `app/lib/features/queue/` (`QueueService`, `DriftQueueRepository`, `queue_validation.dart`) |
| HTTP `/api/v1/queue/*` | `app/lib/api/local_api_server.dart` → `_queueApi` |
| HTTP `/api/v1/queue-desk/*` | same file → `_queueBoardApi` (live desk; shares session start with configuration service) |
| Web admin configuration UI | `web/src/features/queue/` — route **`/config/queue`** |
| Web queue desk UI | `web/src/features/board/`, `web/src/features/home/QueueDeskPage.tsx` — route **`/queue-desk`** |
| OpenAPI | [openapi.yaml](../api/openapi.yaml) — paths are relative to `/api/v1` |

---

## 1. Place in the product flow

Queue configuration is the **first step of the queue feature**. It happens after the clinic and its chambers exist and before staff can issue tokens:

1. Admin creates or restores the clinic.
2. Admin configures chambers (license, setup, or **`/license`** in the web app).
3. The tablet seeds the **clinic template** — three default queue types and ranges (§2).
4. Admin opens **Queue configuration** (`/config/queue`), selects a **chamber**, and reviews or edits that chamber's list. Changes apply to **that chamber only** (§4).
5. Admin or receptionist opens the **queue desk** (`/queue-desk`), selects work scope (chamber), and **starts a session** for that chamber when none is open (§5).
6. Receptionist issues patient tokens against that chamber's open session ([patient entry doc](./patient-entry-and-queue-operations.md)).

The setup must not require the admin to re-enter the standard queues. A new clinic starts with usable defaults.

Admins configure queues in the **web dashboard** served by the tablet. The Flutter tablet shell has no separate queue-configuration screen.

---

## 2. Default queue types (clinic template)

On first use the tablet seeds a **clinic template** — three queue types every new clinic expects:

| Order | English name | Bengali name | Start | End |
| ---: | --- | --- | ---: | ---: |
| 1 | Regular | সাধারণ | 1001 | 1099 |
| 2 | Report | রিপোর্ট | 2001 | 2099 |
| 3 | Dressing | ড্রেসিং | 3001 | 3099 |

Seeding lives in `DriftQueueRepository` (`clinic` owner key). Each queue type has an independent counter in each open queue session. The default ranges provide **99 serials per type per session** (`end − start + 1`).

**Per chamber:** every chamber **starts by inheriting** this template (same three types and ranges on screen). The admin does not configure chambers in bulk. On the queue configuration page they **select one chamber** and add, edit, or enable/disable types for **that chamber only**. Saving must not change another chamber's list.

Admins may, for a given chamber:

- accept the inherited template without saving;
- edit a preset (names and/or range);
- enable or disable a queue type (toggle persists the full `types` array);
- add another queue type (appended with the next `displayOrder`).

The web UI does not provide reorder controls. `displayOrder` is stored and returned by the API; new types get `max(displayOrder) + 1`.

Existing token history must retain the queue name and serial used when the token was issued. Renaming or disabling a queue type must not rewrite historical tokens.

**Note:** Bluetooth **test slips** (`connectivity` feature) use a separate fixed label `নিয়মিত` for Regular on the dummy slip only. Issued tokens and configuration use the configured Bengali name (default **সাধারণ**).

---

## 3. Add or edit a queue type

Required admin inputs (web modal):

- English name;
- Bengali name;
- starting number;
- ending number.

System-managed values:

- stable queue type ID (new rows use `new_<uuid>` until saved);
- `displayOrder`;
- `enabled`;
- creation and modification audit data;
- per-session `nextNumber` / `issuedCount` (§5).

### Validation

The tablet `QueueService` rejects saves when:

- English or Bengali name is blank;
- duplicate English (case-insensitive) or Bengali name among siblings;
- start or end is zero or negative;
- start is greater than end;
- **enabled** ranges overlap in the **same chamber's** configuration (disabled types are ignored for overlap);
- a change is blocked while a session is **open** for that chamber (see below).

The web form runs the same overlap and name rules **client-side** before PATCH; open-session refusals come from the server on save.

**Open session:** While a chamber has an open session (`OPEN` or `ROLLOVER_DUE`), the server **blocks** changes to `startNumber`, `endNumber`, or `enabled`, and blocks **removing** a type from the saved list. It **allows** edits to **English and Bengali names only** on existing types. Adding a brand-new type is blocked for the whole save while a session is open.

Changes to ranges and enabled state apply to the **next** session. An open session keeps the immutable queue configuration snapshot with which it started.

### Number localization

Ranges and serials are stored as canonical integers. Do not store a separate Bengali range:

```text
Stored value:      1001
English display:   1001
Bengali display:   ১০০১
```

The tablet, web app, TV, and printer localize digits for display. API and database values remain integers so sorting, searching, synchronization, and uniqueness remain reliable.

---

## 4. Chamber-wise queue types

Queue types are **owned per chamber**. A user change on one chamber **must not** update every chamber.

### Bootstrap (inherit)

- The clinic template (§2) is stored once under owner `clinic`.
- Each chamber begins with **`useClinicDefaults: true`**. `GET /queue/chambers/{chamberId}` returns the template types for display and for new sessions until that chamber has its own override.
- Other chambers are unaffected when an admin edits one chamber.

### Override (customize)

- The admin queue page saves with **`PATCH /queue/chambers/{chamberId}`** and a full `types` array for **that chamber only**.
- If the chamber still inherits, the server **copies the template into a chamber override** on the first save, sets **`useClinicDefaults: false`**, then applies the submitted types.
- **`POST /queue/chambers/{chamberId}/customize`** copies the template without other edits (API only; not exposed in the web UI).
- **`POST /queue/chambers/{chamberId}/clear-override`** restores inherit for types (API only; not exposed in the web UI). Policy overrides on the chamber are kept.

### What must not happen

- The web admin UI **does not** save queue type add/edit/enable/disable through **`PATCH /queue/defaults`** with a `types` body while configuring a chamber. That endpoint is for the **clinic template** (and clinic-wide policy fields when used).
- A mutation in the UI **must not** push the same `types` list into every chamber's cache or database row.

### Automatic stop time (per chamber)

The web UI labels this **automatic stop time**.

- Clinic default **`dayBoundary`** and **`timeZone`** come from `GET /queue/defaults` (defaults: **`03:00`**, **`Asia/Dhaka`**, `autoStart: true`).
- Per-chamber override is stored as **`dayBoundaryOverride`** on chamber settings.
- The policy modal saves with **`PATCH /queue/chambers/{chamberId}/policy`** and body `{ "dayBoundary": "HH:mm" }` only — not a full policy object.
- The modal can apply one time to **multiple selected chambers** (sequential PATCH per chamber).
- The configuration page footer shows the clinic **time zone**; the header summary shows the **effective** stop time for the selected chamber.

The web UI does not edit clinic `autoStart`, time zone, or rollover policy; those values stay at seeded defaults unless changed through the API.

### Sessions and serials

Queue sessions and counters always belong to one **work scope** (a chamber in the current v1 flow). Separate chambers may use the same numeric ranges without conflict: the authoritative identity is **session + queue type + serial**, not the serial alone.

---

## 5. Session controls

Only one open session may exist per chamber (`OPEN` or `ROLLOVER_DUE` counts as open for configuration locks).

| Action | Route | Web UI |
| --- | --- | --- |
| Start session | `POST /queue/chambers/{chamberId}/session/start` or `POST /queue-desk/chambers/{chamberId}/session/start` | **Queue desk** (`queueDesk.ts`) |
| Close session | `POST /queue/chambers/{chamberId}/session/close` | API only (`queue.ts`) |
| Force close | `POST /queue/chambers/{chamberId}/session/force-close` with `{ reason }` | API only |
| Chamber config + session summary | `GET /queue/chambers/{chamberId}` includes optional `session` with per-type usage | Not shown on `/config/queue` |

Live token issue, call, enter, skip, cancel, and reprint use **`/queue-desk/*`** ([patient entry doc](./patient-entry-and-queue-operations.md)).

### Queue desk (web)

Route **`/queue-desk`**. Admins use **`AdminQueueBoardPage`**: chamber selector, **Start session** when closed, then patient entry and queue controls. Receptionists see the non-admin queue desk overview for their role.

### Session lifecycle (stored statuses)

```text
NOT_STARTED → OPEN → CLOSING → CLOSED
                  ↘ ROLLOVER_DUE
```

---

## 6. Range exhaustion

The server tracks **`issuedCount`**, **`nextNumber`**, and **`capacity`** per queue type in an open session and refuses issuance at exhaustion on the queue desk.

Do not roll over to the starting number inside the same session. Other queue types in the session remain available. Admins may configure a larger range for the **next** session when no open session blocks range edits.

---

## 7. Queue configuration page (web admin)

Admin-only route **`/config/queue`** (`QueueConfigurationPage`).

1. **Chamber selector** — choose which chamber to configure. All type add/edit/enable/disable actions save with **`PATCH /queue/chambers/{chamberId}`** and a full `types` array.
2. **Inherit vs customized** — **Uses clinic defaults** / **Customized for this chamber** from `settings.useClinicDefaults`.
3. **Queue types table** — English/Bengali names, localized range, enabled badge, edit and enable/disable actions.
4. **Automatic stop time** — summary in the page header; edit opens the policy modal (§4). Saves per chamber via **`PATCH …/policy`**.
5. **Sessions** — start and run on **queue desk** (§5), not on this page.

The page does **not** offer “use clinic defaults again” (`clear-override`).

Configuration changes publish live refresh hints so open `/config/queue` tabs update after saves elsewhere ([web interaction](../principles/web-interaction.md)).

Create, update, enable/disable, policy, and session API actions emit audit events defined in [Audit log](./audit-log.md).

---

## 8. Data and API

Conceptual records (SQLite on the tablet):

```text
ClinicQueueDefaults
  timeZone
  dayBoundary
  autoStart

QueueType
  ownerKey          # `clinic` = template, or chamberId = that chamber's override
  id
  englishName
  bengaliName
  startNumber
  endNumber
  displayOrder
  enabled

ChamberQueueSettings
  chamberId
  useClinicDefaults
  dayBoundaryOverride
  autoStartOverride

QueueSession
  id
  chamberId
  businessDate
  status
  openedAt / openedBy
  closeRequestedAt / closeRequestedBy
  closedAt / closedBy / closeReason
  queueConfigurationSnapshot

SessionQueueCounter
  sessionId
  queueTypeId
  nextNumber
  issuedCount
```

SQLite is authoritative, serial allocation is transactional and idempotent, and state is persisted before WebSocket events are emitted.

**API surface**

- **`/api/v1/queue/defaults`** — `GET` / `PATCH` clinic policy and template types.
- **`/api/v1/queue/chambers/{chamberId}`** — `GET` settings, effective policy, types, optional session; `PATCH` types.
- **`/api/v1/queue/chambers/{chamberId}/policy`** — `PATCH` `{ dayBoundary }`.
- **`/api/v1/queue/chambers/{chamberId}/customize`** | **`…/clear-override`** — `POST` (no web UI).
- **`/api/v1/queue/chambers/{chamberId}/session/*`** — start / close / force-close.
- **`/api/v1/queue-desk/chambers/{chamberId}`** — desk snapshot; **`…/session/start`**; issue, call, recall, etc.

Web client paths omit the `/api/v1` prefix (`core/api/client`). Full shapes: [OpenAPI](../api/openapi.yaml).
