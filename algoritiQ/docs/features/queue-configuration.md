# Queue configuration and sessions

Status: **accepted** for v1 queue configuration.  
Scope: admin configuration, chamber queue sessions, serial allocation boundaries, and role permissions.  
Related: [Queue product decisions](./queue-product-decisions.md), [Audit log](./audit-log.md), [Data and offline](../../app/docs/principles/data-offline.md).

---

## 1. Place in the product flow

Queue configuration is the **first step of the queue feature**. It happens after the clinic and its chambers exist and before a receptionist can issue tokens:

1. Admin creates or restores the clinic.
2. Admin configures the clinic's chambers.
3. System seeds the **clinic template** — three default queue types and ranges (§2).
4. Admin opens **Queue configuration**, selects a **chamber**, and reviews or edits that chamber's list. Changes apply to **that chamber only** (§4).
5. Admin or an assigned receptionist starts a queue session **for that chamber**.
6. Receptionist can issue patient tokens against **that chamber's** open session.

The setup must not require the admin to re-enter the standard queues. A new clinic starts with usable defaults.

---

## 2. Default queue types (clinic template)

On first use the tablet seeds a **clinic template** — three queue types every new clinic expects:

| Order | English name | Bengali name | Start | End |
| ---: | --- | --- | ---: | ---: |
| 1 | Regular | সাধারণ | 1001 | 1099 |
| 2 | Report | রিপোর্ট | 2001 | 2099 |
| 3 | Dressing | ড্রেসিং | 3001 | 3099 |

Each queue type has an independent counter in each open queue session. The default ranges provide 99 serials per type per session.

**Per chamber:** every chamber **starts by inheriting** this template (same three types and ranges on screen). The admin does not configure chambers in bulk. On the queue configuration page they **select one chamber** and add, edit, enable, disable, or reorder types for **that chamber only**. Saving must not change another chamber's list.

Admins may, for a given chamber:

- accept the inherited template without saving;
- edit a preset;
- enable or disable a queue type;
- change its display order;
- add another queue type.

Existing token history must retain the queue name and serial used when the token was issued. Renaming or disabling a queue type must not rewrite historical tokens.

---

## 3. Add or edit a queue type

Required admin inputs:

- English name;
- Bengali name;
- starting number;
- ending number.

System-managed values:

- stable queue type ID;
- display order;
- enabled/disabled state;
- creation and modification audit data;
- next serial for each queue session.

### Validation

The system must reject:

- a blank English or Bengali name;
- a duplicate queue name in the same configuration;
- start or end values that are zero or negative;
- a starting number greater than the ending number;
- overlapping enabled ranges in the **same chamber's** configuration;
- changing a queue type or range in a way that would affect an open session.

Changes apply to the **next** session. An open session keeps the immutable queue configuration snapshot with which it started.

If the configured range is smaller than the chamber's recent or expected daily volume, warn the admin but allow them to save it after confirmation.

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
- Each chamber begins with **`useClinicDefaults: true`**. Its configuration API returns the template types for display and for new sessions until that chamber has its own override.
- Other chambers are unaffected when an admin edits one chamber.

### Override (customize)

- The admin queue page saves with **`PATCH /queue/chambers/{chamberId}`** and a full `types` array for **that chamber only**.
- If the chamber still inherits, the server **copies the template into a chamber override** on the first save, sets **`useClinicDefaults: false`**, then applies the submitted types.
- Optional **`POST …/customize`** copies the template without other edits. **`POST …/clear-override`** exists for API completeness but is **not** exposed in the web admin UI.

### What must not happen

- The web admin UI **must not** save queue type add/edit/enable/disable through **`PATCH /queue/defaults`** while a chamber is selected. That endpoint updates the clinic template only (policy and, if present, template types for chambers that still inherit).
- A mutation in the UI **must not** push the same `types` list into every chamber's cache or database row.

### Sessions and serials

Queue sessions and counters always belong to one **work scope** (a chamber in the current v1 flow). Separate chambers may use the same numeric ranges without conflict: the authoritative identity is **session + queue type + serial**, not the serial alone.

### Queue-day boundary (still two-level)

- **Clinic default** boundary and time zone (e.g. **03:00 Asia/Dhaka**).
- Optional **per-chamber** `dayBoundaryOverride` (and optional `autoStartOverride`) without copying type lists between chambers.

Store the time zone explicitly (`Asia/Dhaka` for the current deployment), not only a UTC offset.

---

## 5. Queue-day boundary (detail)

The admin configures when a new queue business day begins (see also §4):

- clinic default start time and time zone, for example **03:00 Asia/Dhaka**;
- optional per-chamber **day boundary** override (e.g. **00:00**) without changing that chamber's type list;
- whether the next session starts automatically when rollover is safe;
- how remaining non-entered tokens are handled at the boundary.

### Scheduled rollover

The boundary creates a **new session**. It never deletes or resets historical rows.

At the configured boundary:

- if no active tokens remain, close the current session and, when auto-start is enabled, open the next session with counters reset to their configured starts;
- apply the admin-configured active-token policy when non-entered tokens remain;
- if the tablet was off, reconcile the boundary at the next startup and create only the required current session.

Supported active-token policies:

1. **Wait until clear** (recommended default) — mark the session **rollover due**, keep it open, and prompt staff to mark each called patient entered, missed, or cancelled.
2. **Close at boundary** — change every remaining `WAITING`, `CALLED`, or `SKIPPED` token to `CANCELLED` with reason `SESSION_ROLLOVER`, close the session, and audit the affected counts before optionally starting the next session.

The selected policy must be visible on the configuration and current-session pages. The system must never silently discard a token and must never wrap an exhausted counter back to its start inside the same session.

---

## 6. Manual session controls

Only one open session may exist for a chamber.

### Receptionist

An assigned receptionist may:

- start a session for their selected chamber;
- request normal closure of that session;
- resolve active tokens as entered, missed, or cancelled before closure.

They cannot manage another chamber and cannot force-close a session with active tokens.

### Admin

An admin may:

- start or close a session for any chamber;
- force-close a session when operationally necessary.

Force-close requires a confirmation and a reason. Remaining active tokens become `CANCELLED`; they are not deleted. The action and reason are written to the audit log.

### Lifecycle

```text
NOT_STARTED → OPEN → CLOSING → CLOSED
                  ↘ ROLLOVER_DUE
```

- `OPEN`: tokens may be issued.
- `ROLLOVER_DUE`: the configured boundary passed while active tokens remained.
- `CLOSING`: token issuance is blocked while remaining work is resolved.
- `CLOSED`: immutable history; a new session may start.

---

## 7. Range exhaustion

The queue page must show usage for every queue type, for example **82 of 99 issued**.

- Warn staff before exhaustion (default threshold: 80%).
- At the ending number, block further issuance for that type with an actionable message.
- Do not roll over to the starting number.
- Other queue types in the session remain available.
- Admin may configure a larger range for the next session.

---

## 8. Queue configuration page (web admin)

Admin-only route **`/config/queue`**.

1. **Chamber selector** — choose which chamber to configure. All type add/edit/enable/disable actions save with **`PATCH /queue/chambers/{chamberId}`** only.
2. **Inherit vs customized** — show **Uses clinic defaults** while the chamber has no override; after the first save show **Customized for this chamber**. Other chambers keep their own inherit or override state.
3. **Queue types table** — names, ranges, enabled state, and actions for the **selected chamber** only.
4. **Automatic stop time** — per-chamber effective boundary (clinic default or override); edit via the policy modal without changing other chambers' type lists.
5. **Current session** (when built on this page or the board) — status, usage, start/close for the selected chamber.

The page **must not** treat the chamber dropdown as a filter on a single shared list stored at clinic scope. Clinic **`PATCH /queue/defaults`** with a `types` body is for the **template** and policy only, not for the primary “edit queue types” flow.

All create, update, enable/disable, start, close, rollover, and force-close actions must produce audit events defined in [Audit log](./audit-log.md).

---

## 9. Data and API direction

Conceptual records:

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

Implementation must preserve the existing rules: SQLite is authoritative, serial allocation is transactional and idempotent, and state is persisted before WebSocket events are emitted. API shapes live in [OpenAPI](../api/openapi.yaml) (`/queue/defaults`, `/queue/chambers/{chamberId}`, customize, clear-override).
