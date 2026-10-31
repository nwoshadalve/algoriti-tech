# Admin audit log

Status: **living product document** — update this event catalogue as each feature is finalized.  
Scope: admin visibility into who changed configuration or performed an operational action.  
Related: [Queue configuration and sessions](./queue-configuration.md), [Patient entry and queue operations](./patient-entry-and-queue-operations.md), [Security and privacy](../../app/docs/principles/security-privacy.md).

---

## 1. Purpose

The audit page lets an administrator answer:

- who performed an action;
- what action was performed;
- when and from which client/device;
- which clinic, chamber, session, or record was affected;
- whether the action succeeded;
- what changed, without exposing secrets or unnecessary patient data.

The audit log is for accountability, troubleshooting, and recovery evidence. It is not an editable activity feed and is not a substitute for application logs.

---

## 2. Access and integrity

- Only authenticated **admins** may view the audit page.
- Receptionist actions are recorded but receptionists cannot browse the audit log.
- Audit entries are append-only: no user can edit or delete an individual entry.
- Use the existing hash-chained audit approach so tampering is detectable.
- Audit writes belong to the same authoritative tablet/SQLite boundary as the action.
- A business action must not report success until its required state and audit entry are persisted.
- Audit history is included in normal backup and restore.

### Retention

Audit retention is admin-configurable:

- **1 year** by default;
- supported choices: 1, 2, 3, or 5 years, or keep forever;
- a retention change applies prospectively and is itself audited;
- users cannot manually delete individual entries;
- scheduled cleanup removes entries only after they are older than the selected retention period;
- cleanup records a tamper-evident checkpoint containing the removed date range, entry count, and final removed hash so the retained chain remains verifiable.

Audit records present when a backup is created remain protected by that backup's own retention policy. CSV/PDF export is deferred from v1.

---

## 3. Audit page

Default view:

- newest entries first;
- server-side pagination;
- local date and time with the stored time zone;
- human-readable action text;
- actor name and role;
- chamber/work scope;
- outcome;
- expandable details.

Filters:

- date/time range;
- actor;
- role;
- action category;
- action;
- chamber/work scope;
- outcome (`success`, `refused`, `failed`);
- target ID or session ID where appropriate.

The details view may show safe before/after values for configuration changes. It must not show password hashes, activation keys, bearer tokens, PINs, device secrets, TLS private keys, claim codes, or full backup secrets.

Search and filtering must run against indexed server-side fields; the browser must not load the full audit history.

---

## 4. Audit entry model

Each entry should contain:

```text
id
occurredAt
action
category
outcome

actorAccountId          nullable for system events
actorDisplayNameSnapshot
actorRoleSnapshot
actorType               admin | receptionist | system

clinicId
chamberId               when applicable
sessionId               when applicable
targetType
targetId

reason                  required for designated sensitive actions
safeMetadata            allow-listed structured values only
before                  safe changed fields only
after                   safe changed fields only

commandId               for idempotency/correlation
sourceClient            tablet | web | system
sourceDeviceId          non-secret identifier when available
previousHash
entryHash
```

Snapshot the actor's display name and role so old entries remain understandable after an account is renamed or disabled.

Do not copy patient names, phone numbers, Bengali names, fees, or other PII into generic audit metadata. Where a patient-related event is eventually required, reference its record ID and show sensitive detail only through the separately authorized domain view.

---

## 5. Queue configuration and session events

This is the first finalized event catalogue. Extend later sections as other product flows are agreed.

### Configuration

| Event | Actor | Required safe details |
| --- | --- | --- |
| `queue.defaults.created` | system | seeded queue type IDs and ranges |
| `queue.policy.updated` | admin | clinic/chamber scope; before/after boundary, time zone, auto-start |
| `queue.type.created` | admin | queue type ID, English/Bengali names, range, order |
| `queue.type.updated` | admin | queue type ID and safe before/after fields |
| `queue.type.enabled` | admin | queue type ID |
| `queue.type.disabled` | admin | queue type ID |
| `queue.type.reordered` | admin | ordered queue type IDs |
| `queue.chamber_override.created` | admin | chamber ID and overridden fields |
| `queue.chamber_override.updated` | admin | chamber ID and safe before/after fields |
| `queue.chamber_override.cleared` | admin | chamber ID; returns to clinic defaults |
| `audit.retention.updated` | admin | before/after retention period |
| `audit.retention.purged` | system | cutoff, removed entry count, final removed hash/checkpoint |

### Sessions

| Event | Actor | Required safe details |
| --- | --- | --- |
| `queue.session.started` | admin or assigned receptionist | chamber ID, session ID, business date, configuration snapshot ID |
| `queue.session.auto_started` | system | chamber ID, session ID, configured boundary |
| `queue.session.close_requested` | admin or assigned receptionist | chamber ID, session ID, active-token counts |
| `queue.session.rollover_due` | system | chamber ID, session ID, configured boundary, active-token counts |
| `queue.session.closed` | admin, assigned receptionist, or system | chamber ID, session ID, issue counts by queue type |
| `queue.session.force_closed` | admin | chamber ID, session ID, mandatory reason, cancelled-token count |
| `queue.session.start_refused` | system | chamber ID and safe reason code |
| `queue.session.close_refused` | system | chamber ID, session ID and safe reason code |

Automatic events use `actorType: system`; they must clearly state which configured policy caused the action.

---

## 6. Patient, token, chamber-entry, and printing events

Patient names, phone numbers, addresses, and other profile values must not be copied into generic audit metadata. Use the permanent patient ID and authorized record links.

### Patient records

| Event | Actor | Required safe details |
| --- | --- | --- |
| `patient.created` | receptionist or admin | patient ID; whether linked to a legacy paper file (not its sensitive contents) |
| `patient.updated` | receptionist or admin | patient ID; names of changed fields, not raw sensitive values |
| `patient.legacy_file_linked` | receptionist or admin | patient ID; non-sensitive legacy record reference when policy permits |
| `patient.possible_duplicate_confirmed` | receptionist or admin | new patient ID; matched record IDs; confirmation reason/code |

### Token and queue lifecycle

| Event | Actor | Required safe details |
| --- | --- | --- |
| `token.issued` | receptionist or admin | patient ID, token ID, session ID, queue type ID, serial |
| `token.duplicate_refused` | system | patient ID, existing token ID, session ID, reason code |
| `token.additional_issue_confirmed` | receptionist or admin | patient ID, existing token ID, new token ID, reason |
| `token.called` | receptionist or admin | token ID, serial, queue type ID, call ID |
| `token.recalled` | receptionist or admin | token ID, serial, call ID, announcement attempt ID |
| `token.entered` | assigned receptionist or admin | token ID; transition `CALLED` → `ENTERED`; chamber-entry time |
| `token.skipped` | receptionist or admin | token ID; safe reason code |
| `token.cancelled` | receptionist or admin | token ID; mandatory reason; replacement token ID when reason is `WRONG_QUEUE_TYPE` |
| `token.status_corrected` | admin | token ID; before/after status; mandatory reason |
| `token.transition_refused` | system | token ID; attempted transition; safe reason code |

Calling, printing, or issuing a later token must never create `token.entered`. Entry is recorded only after an authorized person explicitly confirms that the patient entered the doctor's chamber. The audit log must not claim that consultation or medical service was completed.

### Printing and announcements

| Event | Actor | Required safe details |
| --- | --- | --- |
| `token.print_sent` | system | token ID, print attempt ID, printer ID, attempt number |
| `token.print_failed` | system | token ID, print attempt ID, safe failure code |
| `token.print_unknown` | system | token ID, print attempt ID, safe failure code |
| `token.reprint_requested` | receptionist or admin | token ID, new print attempt ID, attempt number, reason |
| `announcement.created` | system | token ID, call ID, announcement attempt ID |
| `announcement.failed` | system | token ID, call ID, announcement attempt ID, safe failure code |

---

## 7. Initial action categories to expand

Future product discussions should add event catalogues for:

- authentication and account administration;
- clinic, doctor, chamber, and work-scope changes;
- printer and TV pairing or removal;
- backup creation, download, restore, and failure;
- licensing and activation;
- security-sensitive settings and device revocation.

Do not add a vague “updated record” event. Each auditable action needs a stable event name, allowed actors, required reason where applicable, and an explicit safe metadata allow-list.

---

## 8. Audit UX states

The admin page must handle:

- loading;
- no entries;
- filtered empty result;
- data;
- recoverable API error;
- entry details with unavailable/deleted referenced records.

An audit failure for a sensitive operation must be explicit. Force-close, account/security changes, backup restore, and destructive actions must fail closed if their required audit record cannot be persisted.
