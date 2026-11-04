# Chamber patient ID prefix

Status: **accepted** for clinic patient registration at the reception desk.  
Scope: how permanent clinic patient IDs are formed per chamber, how prefixes are assigned and changed, and how existing IDs are preserved.  
Related: [Patient entry and queue operations](./patient-entry-and-queue-operations.md), [OpenAPI](../api/openapi.yaml).

---

## 1. Purpose

Each chamber owns a **patient ID prefix** and a **sequence counter**. New patients registered while working in that chamber receive a permanent ID formed by concatenating the prefix and the next sequence value (no separator, no zero-padding of the sequence).

Example: prefix `776` → first patients `7761`, `7762`, …, then `776100`, `7761001`, and so on.

The prefix is assigned automatically when a chamber is created and is stored on the chamber record. Admins can view and change it on **Config → Chambers** (`/config/chamber`).

---

## 2. Assignment rules

### On chamber create

1. Generate a random **three-digit** numeric prefix in the range `100`–`999`.
2. The prefix must not already be in use by another chamber in the same clinic.
3. Set `patientIdNextSequence` to `1`.
4. Persist both on the chamber row.

### On patient register

1. Registration is always scoped to a **chamber** (`chamberId` on `POST /patients`).
2. In one database transaction:
   - read the chamber’s current prefix and next sequence;
   - form `clinicPatientId = prefix + sequence` (string concatenation);
   - insert the patient with that canonical ID;
   - increment the chamber’s next sequence by `1`.
3. The patient’s prefix and sequence are **copied onto the patient row** at creation time and never change, even if the chamber prefix is edited later.

### On prefix update (admin)

1. Admins may set a new prefix on **PATCH /chambers/{id}** (digits only, length **3–6**).
2. The new prefix must not match another chamber’s prefix (case not applicable; digits only).
3. If the prefix **changes**, reset that chamber’s `patientIdNextSequence` to `1`. The next registered patient gets `{newPrefix}1`, `{newPrefix}2`, …
4. Patients already registered keep their stored `clinicPatientId` (e.g. `7761013` remains valid for that person).

---

## 3. Uniqueness and search

- `patients.clinic_patient_id` is **unique clinic-wide** (canonical Latin digits).
- Chamber prefixes are **unique clinic-wide** so two chambers cannot issue colliding IDs under the same numbering rules.
- Search accepts:
  - legacy `P-000042` / `P-42` forms for patients created before this feature;
  - the full numeric **clinic patient ID** for chamber-scoped IDs (e.g. `7761013`).

Do not encode phone, birth date, or queue serial in the patient ID.

---

## 4. API and UI

| Surface | Behaviour |
|--------|-----------|
| `GET /chambers` | Returns `patientIdPrefix` and `patientIdNextSequence` per chamber. |
| `POST /chambers` | Server assigns prefix; client must not send one. |
| `PATCH /chambers/{id}` | Optional `patientIdPrefix`; validated as above. |
| `POST /patients` | **Required** `chamberId`; allocates ID from that chamber. |
| Web `/config/chamber` | Table column + edit field for prefix; shows next ID preview from prefix + next sequence. |

---

## 5. Legacy patients

Patients created under the older clinic-wide `P-000001` scheme keep that display ID. New registrations use the chamber prefix scheme only. Both formats may coexist in search and on tokens.

---

## 6. Audit

Changing a chamber prefix emits `chamber.updated` with the chamber id (existing audit action). Patient creation continues to use `patient.created`.
