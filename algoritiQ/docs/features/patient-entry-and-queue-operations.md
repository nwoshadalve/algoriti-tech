# Patient entry and queue operations

Status: **accepted** for v1 receptionist workflow.  
Scope: one-page patient entry, token issue, queue operation, chamber-entry confirmation, printing, and reprinting.  
Related: [Queue configuration and sessions](./queue-configuration.md), [Queue product decisions](./queue-product-decisions.md), [Audit log](./audit-log.md), [Data and offline](../../app/docs/principles/data-offline.md).

---

## 1. One-page receptionist board

Patient entry and current-session queue operation live on one page. Do not use a multi-page wizard for the normal counter flow.

The page contains:

1. **Patient actions**
   - **New patient** — icon and text label;
   - **Existing patient** — icon and text label.
2. **Queue controls**
   - one control for each enabled queue type;
   - waiting count;
   - **Call next**;
   - **Recall** for that queue's latest called token.
3. **Current call/service panel**
   - currently called patient;
   - recall, patient entered, and missed actions according to state.
4. **Current-session queue**
   - fixed-height viewport with a fixed header;
   - internally scrolling rows;
   - responsive table in landscape and compact rows in portrait.

The patient-entry section opens inline on the board. After selection or registration, the receptionist chooses the queue type and creates the token without leaving the page.

Icons must have visible text where space permits and always have tooltips and accessibility labels.

---

## 2. Search before registration

Receptionists should not have to know whether a person is already stored.

### Existing patient

1. Search by clinic patient ID or normalized phone number.
2. Show all possible matches; phone numbers are not unique because families may share one.
3. Each result shows patient ID, Bengali name, and optional age information sufficient to disambiguate.
4. Receptionist selects the patient, selects a queue type, enters the optional visit fee, and creates the token.

### New patient

1. Search first.
2. If no result is correct, choose **Register new patient**.
3. Prefill the searched phone number.
4. Enter required details and any relevant optional details.
5. Save the patient and issue the first token in one user action.

If similar phone matches exist, the page must warn before creating another patient and require confirmation that this is a different person.

The permanent clinic patient ID is unique. A phone number is a searchable identifier but is **not** a unique database key: two or more family members may legitimately share it. A matching phone therefore produces a warning and a list of possible patients, not a hard registration block.

### Existing paper-file patient

“Existing patient” in the clinic and “existing AlgoritiQ patient” are different concepts. A person with an old paper file but no AlgoritiQ record is registered as a new local record with:

- **Has existing paper file**;
- optional legacy file number.

A generic “Is existing patient?” checkbox must not replace search.

---

## 3. Patient profile fields

Required:

- Bengali full name;
- phone number.

Optional:

- English name;
- exact date of birth, birth year, or approximate age;
- gender (`male`, `female`, `other`, `not_stated`);
- locality or short address;
- legacy paper-file number;
- short administrative note.

Do not collect diagnosis, clinical notes, national ID, or other unnecessary sensitive information in v1.

Age is not a permanent value. Prefer an exact date of birth when known. Otherwise store approximate age together with the date on which it was recorded so it can be interpreted correctly later.

Phone numbers are stored in a canonical normalized form and formatted for display.

---

## 4. Permanent clinic patient ID

Each patient receives a short, human-readable ID unique within the clinic:

```text
P-000001
P-000002
P-000003
```

Requirements:

- assigned transactionally by the tablet;
- permanent and never reused;
- independent of chamber, session, and queue type;
- searchable with or without the `P-` prefix and leading zeros;
- printed on every token;
- suitable for writing on the physical patient file.

Do not encode phone number, birth date, chamber, or other personal information in the ID.

Store and exchange the canonical ID using Latin digits. Bengali UI may localize the numeric part (`P-০০০০০১`) without creating a second identifier.

---

## 5. Visit and token inputs

These values belong to the visit/token, not the permanent patient profile:

- queue type;
- chamber/work scope (from the signed-in receptionist context);
- optional fee amount;
- session and issue time.

If more than one queue type is enabled, queue selection is required. If only one is enabled, preselect and display it.

Fee recording must not block patient creation or token issue.

Before issuing, check whether the patient already has an active token in the current session. If one exists:

- show the existing token;
- offer reprint;
- do not create another token for that patient in the same chamber session.

Only one active token is allowed per patient per chamber session, regardless of queue type.

---

## 6. Token issue and printing

### Confirmation before issue

Before allocating the serial or printing, show a token confirmation screen containing:

- selected patient ID and Bengali name;
- chamber;
- queue type in Bengali and English;
- optional fee;
- the expected next serial, clearly identified as a preview until confirmed.

Actions:

- **Back to edit** — returns to the inline form without creating a token or consuming a serial;
- **Confirm and print** — transactionally allocates the authoritative serial, persists the token, and starts the print attempt.

The authoritative serial shown after confirmation may change if another valid command allocated the previewed next serial first.

Token creation and printing are separate operations:

```text
save/select patient
→ allocate serial and persist token transactionally
→ display token immediately
→ create print attempt
→ send to printer
```

A printer failure must never roll back or delete the patient or token.

Print-attempt states:

```text
PENDING → SENT
        → FAILED
        → UNKNOWN
```

- `SENT` means bytes were sent successfully; Bluetooth cannot prove that paper physically emerged.
- `FAILED` means the attempt definitively failed before successful transmission.
- `UNKNOWN` means the connection failed after transmission may have started; the slip may have printed.

Do not automatically retry an `UNKNOWN` attempt. Ask the receptionist to inspect the printer first.

The printer processes one attempt at a time. While an attempt is `PRINTING`, all other Print and Reprint actions are disabled and show which token is printing. A bounded timeout must move a stuck attempt to `FAILED` or `UNKNOWN` and release the printer lock; printer failure must not permanently block token creation.

### Reprint

Reprint:

- uses the existing token and serial;
- never creates another queue entry;
- creates a new print-attempt record;
- records actor, timestamp, attempt number, and reason;
- marks the slip **REPRINT**;
- requires confirmation.

The result panel and the token row expose **Reprint**. A failed print is shown as “Token created — not printed”; the token remains valid and in the queue.

Recommended slip content:

- clinic/chamber;
- large queue serial;
- Bengali and English queue-type names;
- clinic patient ID;
- issue date/time;
- `REPRINT` marker when applicable.

Do not print the phone number. Patient name is omitted by default for privacy.

### Wrong queue type after issue

A token's queue type and serial are immutable after confirmation. If the wrong queue type is discovered after issue:

1. mark the incorrect token `CANCELLED` with reason `WRONG_QUEUE_TYPE`;
2. never reuse its serial;
3. create a new token in the correct queue, allocating that queue's next serial;
4. show the replacement confirmation and print immediately after confirmation;
5. audit both the cancellation and replacement token.

Do not transfer or edit an issued token between queue types.

---

## 7. Queue controls

For each enabled queue type show:

- localized queue name;
- waiting count;
- next serial or latest called serial where useful;
- **Call next**;
- **Recall**.

Only one token may be actively `CALLED` in a chamber at a time, regardless of queue type. While a called token is unresolved:

- disable **Call next** for every queue type;
- explain which serial is awaiting entry;
- allow Recall only for the current token;
- release the call/announcement guard only when the token becomes `ENTERED`, `SKIPPED`, or `CANCELLED`.

Announcement playback is also serialized: do not start a second announcement while the current audio attempt is playing. A playback timeout or failure releases the audio transport lock without changing the token's `CALLED` state.

### Call next

`Call next`:

1. selects the oldest eligible `WAITING` token in that queue type;
2. changes it to `CALLED`;
3. records `firstCalledAt` on the first call;
4. emits the persisted queue event;
5. generates and publishes the TV announcement;
6. highlights the token in the board.

Disable the action when no eligible token is waiting.

### Recall

Recall repeats the latest call for that queue type:

- keeps the same token and serial;
- does not alter queue order;
- creates a new call/announcement attempt ID for deduplication;
- is audited.

Disable Recall when that queue type has no called token eligible for recall.

Calling automatically triggers the initial voice announcement. A separate initial “voice announcement” action is unnecessary.

---

## 8. Determining whether a patient entered the chamber

The queue system is responsible for moving a waiting patient into the doctor's chamber. It does not track whether consultation or medical service was completed.

Calling or printing a token does not prove that the patient entered. Chamber entry is an explicit state transition:

```text
WAITING → CALLED → ENTERED
WAITING → CANCELLED
CALLED  → CANCELLED
CALLED  → SKIPPED → CALLED
```

Receptionist-facing labels:

- `WAITING` → **Waiting**
- `CALLED` → **Called**
- `ENTERED` → **Entered**
- `SKIPPED` → **Missed**
- `CANCELLED` → **Cancelled**

A patient has authoritatively entered the doctor's chamber only when:

```text
token.status == ENTERED
and enteredAt is present
```

### Current-call actions

When `CALLED`:

- **Recall**;
- **Patient entered** → `ENTERED`;
- **Missed** → `SKIPPED`.

For v1, the assigned receptionist confirms chamber entry. An admin may correct status only through an explicit correction flow with confirmation and a mandatory reason.

If **Call next** is pressed while the relevant previous token is still `CALLED`, do not silently mark it entered. Show the unresolved token and require staff to mark **Patient entered**, **Missed**, or **Cancelled** before proceeding according to the queue policy.

`ENTERED` is the successful terminal state for the queue. The patient leaves the active queue but remains in current-session history. The system must not describe this as served, consultation completed, or treatment received.

Printing status is independent of queue status: a patient may enter the chamber even if their slip failed to print.

Store at least:

- `issuedAt`;
- `firstCalledAt`;
- `enteredAt`;
- `cancelledAt` when applicable.

Derived durations:

```text
waiting time = firstCalledAt - issuedAt
entry response time = enteredAt - firstCalledAt
total queue time = enteredAt - issuedAt
```

---

## 9. Current-session queue display

Landscape table columns:

1. serial number;
2. queue type;
3. patient ID;
4. Bengali patient name;
5. waiting time;
6. queue status;
7. print status when attention is required;
8. actions.

Serial is visually prominent. Phone number is searchable by authorized staff but is not displayed in the queue table.

Direct common actions may include **Edit patient** and **Reprint**. Less common actions belong in an overflow menu. Editing patient details must never edit patient ID, serial, session, or historical token identity.

The table has a fixed-height viewport with scrolling rows. In portrait, use compact multi-line rows rather than squeezing all columns or requiring horizontal scrolling.

The table shows the current open session by default. Historical sessions belong in a separate history/report view.

At session closure, every token that did not reach `ENTERED` must retain an explicit terminal outcome. Under an automatic or admin force-close policy, `WAITING`, `CALLED`, and `SKIPPED` tokens become `CANCELLED` with reason `SESSION_ROLLOVER` or `SESSION_FORCE_CLOSED`; they are never reported as entered.

---

## 10. Data and API rules

- SQLite on the tablet remains authoritative.
- Patient ID and token serial allocation occur transactionally.
- Every patient/token command carries a `commandId`; retry returns the original result.
- Persist patient, token, state transition, print/call attempt, and required audit evidence before publishing the corresponding event.
- Web/TV clients receive only the fields permitted for their role; TV never receives patient name or phone for display.
- Define patient, token, state-transition, print-attempt, call/recall, and snapshot contracts in OpenAPI before client implementation.
