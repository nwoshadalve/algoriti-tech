# Queue — product decisions (planning)

Status: **accepted** for v1 queue design (patient entry, analytics, announcements).  
Scope: counter tablet (source of truth), TV client (display + playback), local API.  
Related: [Queue configuration and sessions](./queue-configuration.md), [Patient entry and queue operations](./patient-entry-and-queue-operations.md), [Audit log](./audit-log.md), [R&D architecture](../discussions/rnd_architechture.md), [Data & offline](../../app/docs/principles/data-offline.md), [Security & privacy](../../app/docs/principles/security-privacy.md).

---

## 1. Patient entry, identity, and token types

### Decisions

- **Three default token types**, each with its **own serial counter** per session / work scope (chamber or doctor): **Regular**, **Report**, **Dressing**. Bilingual names, default ranges, **per-chamber** add/edit/enable, session rollover, and role permissions are defined in [Queue configuration and sessions](./queue-configuration.md). A change on one chamber's queue list must not change another chamber's list.
- **New patient (first time in clinic record):** reception **must** enter **Bengali name** and **phone**; the accepted one-page fields and operational flow are defined in [Patient entry and queue operations](./patient-entry-and-queue-operations.md). Optional information must not block issuing a token.
- **Return patient:** do **not** repeat full registration. Reception finds the record, picks token type, issues today’s token.
- **Clinic patient number:** system-generated, **unique per clinic**, short and printable; shown on the token slip. **Not** the same as today’s queue serial.
- **Lookup:** reception searches by **phone** (normalized) and/or **clinic patient number**. Phone is **not** unique (shared family phones in Bangladesh); staff **confirm** the row (name, optional age) when multiple matches.
- **Public surfaces (TV screen, waiting-area display):** **serial (+ type label) only** — no name or phone.
- **Fee amount:** one optional BDT amount on the visit/token. V1 does not track paid/unpaid status, dues, waivers, refunds, or payment method. Fee entry must not block token creation.

### Step-by-step — new patient

1. Receptionist is signed in and has chosen **work scope** (chamber or doctor).
2. Search first by patient ID or phone; if no correct match exists, open **new patient** inline on the same board.
3. Enter **Bengali name** and **phone** (required).
4. Optionally enter the profile and visit fields defined in [Patient entry and queue operations](./patient-entry-and-queue-operations.md).
5. System creates **patient** row and assigns **clinic patient number**.
6. Choose token type: **Regular**, **Report**, or **Dressing**.
7. System allocates the next serial for that **type** in the open session, creates **token**, prints slip (serial, type, clinic patient number for staff; no sensitive data on TV).

### Step-by-step — return patient

1. Receptionist is signed in with work scope chosen.
2. Open **find patient**; search by **phone** or **clinic patient number**.
3. If several rows share a phone, select the correct **name** (and age if shown).
4. Choose token type: **Regular**, **Report**, or **Dressing**.
5. System issues **today’s token** (new serial for that type); **name and phone are not re-entered** unless staff updates the profile.

### Data notes (implementation)

- Store **phone normalized** (one canonical form, e.g. `8801…` or `01…`).
- Store **display name** for staff UI; add **`nameBn`** (Bengali Unicode) when name announcement is used (see §3).
- Only the **tablet** allocates serials, inside **one DB transaction** per issue ([data-offline](../../app/docs/principles/data-offline.md)).

---

## 2. History, scale, and analytics

### Decisions

- **SQLite on the tablet** remains the source of truth; **100k+ patients** and **millions of token rows** are acceptable with indexes and rollup tables.
- **Live queue** queries only **today’s session** (small); dashboards must **not** scan full history on every page open.
- **Analytics** (entered fee amounts, token counts, gender mix) use **pre-aggregated summary tables**, updated when tokens/fees are recorded and/or reconciled daily.
- **Gender percentage** is computed from the **patient** table (or cached snapshot), not by scanning all tokens on each load.
- **Fee reporting** sums the optional fee amount recorded on visits/tokens. It does not represent payment collection or outstanding dues.

### Step-by-step — recording (operational)

1. Each **token** row stores type, session, timestamps, link to **patient**.
2. If a fee is captured, store the optional BDT amount on that visit/token.
3. In the **same transaction** (or end-of-day job), increment **`daily_stats`** for that scope: counts per type, fee totals, new patients if applicable.

### Step-by-step — viewing reports (admin)

1. Open analytics (tablet or web admin).
2. **Default charts** read **`daily_stats` / `monthly_stats`** only (bounded date range).
3. Show **daily / weekly / monthly / yearly** token totals (overall and by **Regular / Report / Dressing**).
4. Show **fee totals** for the same periods from rollup columns.
5. Show **male / female (or gender) mix** from patients or a cached stats row.
6. **Drill-down** to individual tokens uses **paginated**, **date-filtered** queries — not full export to the browser.

### Rollup grain (minimum)

| Table | Grain | Examples |
| --- | --- | --- |
| `daily_stats` | clinic + scope + **calendar date** | token counts by type, `fee_amount_bdt`, new patients |
| `monthly_stats` | clinic + scope + **year-month** | same aggregates for charts |

Indexes on **`tokens(created_at_ms)`**, **`patients(phone_normalized)`**, **unique `patients(clinic_patient_number)`**.

---

## 3. Announcements (tablet prepares audio, TV plays)

### Decisions

- **Tablet** builds announcement **text** and **audio** (TTS and/or bundled Bengali clips for fixed phrases and numbers).
- **TV app** does **not** run TTS or heavy models; it **downloads and plays** audio from the tablet API.
- **Order:** **serial number first**, then **patient name** (when enabled), then closing phrase (Bengali template).
- **Bengali speech** uses stored **`nameBn`** only — **not** live conversion from English at call time.
- **Registration:** if staff type English, app may **suggest** Bengali spelling; staff **confirm once** → save **`nameBn`**. Return visits reuse **`nameBn`**.
- **Clinic/chamber setting:** **Announce name** on/off (default **off** for alignment with serial-only public display until clinic opts in). **TV screen** stays **serial-only** even when audio includes name (unless product changes later).
- **Delivery:** on **call** (or recall), tablet stores a short audio artifact; **`token.called`** event includes **`announcementUrl`** (and ids for deduplication). TV **GET**s and plays; respect **event sequence** to avoid double-play on reconnect.
- **Failure:** TV still shows **serial** large; tablet logs audio failure; queue must not block on audio.

### Step-by-step — registration (when name in announcement is enabled)

1. Enter required **name** and **phone** (§1).
2. Enter or confirm **`nameBn`** (Bengali Unicode) — required for name in audio.
3. Save patient; issue tokens as usual.

### Step-by-step — call and announce

1. Staff **calls** token (Regular / Report / Dressing).
2. Tablet composes Bengali text, e.g. serial clause + optional **`nameBn`** + closing phrase.
3. Tablet synthesizes **offline** audio (recorded fragments + verified offline bn-BD TTS, or equivalent on tablet only).
4. Tablet saves clip; emits **`token.called`** with **`announcementUrl`** (+ `announcementId` / `callId`).
5. TV fetches audio, plays; display shows **serial (+ type)** per §1.
6. If **`nameBn`** is missing or announce-name is off, audio is **serial-only** template.

### Out of scope (v1)

- On-device **LLM** for announcement wording or English→Bengali at call time.
- TV-side synthesis or transliteration.

---

## Precedence vs existing privacy text

[Security & privacy](../../app/docs/principles/security-privacy.md) states public views show **serial only**. This doc adds: **optional spoken name** on TV speaker when the clinic enables it, using **`nameBn`**, while **on-screen public display** remains serial-only unless a future decision changes that.

When implementing queue APIs and schema, update **OpenAPI** and architecture notes to match this doc.
