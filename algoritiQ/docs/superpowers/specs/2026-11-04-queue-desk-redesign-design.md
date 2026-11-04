# Queue desk redesign — one screen, server-side session table

Status: **draft for review** · Scope: `algoritiQ/app` (Flutter tablet) · Related: [Patient entry and queue operations](../../features/patient-entry-and-queue-operations.md), [UI standards](../../../app/docs/standards/ui.md)

## 1. Goal

The receptionist sees and manages everything about today's session from one screen, in landscape and portrait, **without scrolling the page**. Only the patient list scrolls, inside its own pane.

## 2. Problems today

1. With a patient in **Now calling**, the left column (Now calling + warning line + queue tiles) is taller than the screen; the queue tiles have fixed heights and overflow.
2. The session table loads every token, cannot be searched, filtered or sorted, and truncates Queue and Wait.
3. Waiting time is computed once per refresh; it does not tick.

## 3. Layout

Breakpoint by **pane width**, not by device name. Landscape ≥ 1000 dp wide; below that, portrait/stacked.

### Landscape (side by side)

```text
┌ Left strip ~360 dp ──────┐ ┌ Patients (rest) ────────────────────────────┐
│ Now calling (compact)    │ │ Title · counts chips      [Add] [Add exist.]│
│ Queues (one slim row per │ │ [search] [queue ▾] [Not printed]            │
│ queue; list scrolls only │ │ ID | Name | Serial | Queue | Wait | Status … │
│ past ~6 queues)          │ │ rows (scroll inside, load more on demand)   │
└──────────────────────────┘ └─────────────────────────────────────────────┘
```

### Portrait (stacked)

1. Now calling — one slim row (serial, name, ID, queue; Recall / Entered / Missed / Cancel).
2. Queues — one compact tile per queue in a row (wraps to a second row beyond 4).
3. Patients — takes all remaining height; same header, search bar and table.

### Now calling card

Empty: one line "No patient is being called." Filled: big serial, patient name (wraps, 2 lines max), ID · queue, and the four actions. No fixed heights; it sizes to content and never exceeds ~120 dp.

### Queue row / tile

Name, "N waiting", **Call**, **Recall**. When a called patient is unresolved, Call buttons are disabled; the reason is shown by the Now calling card (no separate warning line).

## 4. Patients table

Column order: **Patient ID · Name · Serial · Queue · Wait · Status · print icon · ⋯ menu**.

- **Name** wraps to two lines, then ellipsis; full name on long press. Row height grows to fit.
- **Serial** in Bengali digits when the app is in Bengali.
- **Wait** is live: `mm:ss`, or `h:mm:ss` from one hour. Counts from issue time until the first call, then freezes (entered / missed / cancelled stay frozen). Ticks every second; only the wait cells rebuild.
- **Status**: Waiting / Called / Missed / Entered / Cancelled, as a labelled pill (never colour alone).
- **Print icon** only when a slip still needs printing: red printer (failed / unknown / not printed), busy indicator while printing. Disabled while another print runs. Reprinting a printed token is in ⋯.
- **⋯ menu**: Edit patient, Reprint, Cancel token (active tokens only).
- Below 560 dp (scaled by text size) each row becomes a card with the same fields.

### Header controls

- **Status chips with counts**: All · Waiting · Called · Missed · Entered · Cancelled. One selected at a time. Counts honour the search and queue filter, not the status filter.
- **Search** (300 ms pause): Bengali or English name (any part), patient ID, serial, phone prefix.
- **Queue filter**: all queues or one.
- **Not printed** toggle.
- **Sort**: tap a column heading to sort, tap again to reverse (`aria-sort`-style semantics via `Semantics`). Default: newest issued first. Sortable: ID, name, serial, queue (queue display order), wait, status (lifecycle order).
- Empty result: "No patients match" with **Clear filters**.

## 5. Backend (tablet service)

New in `QueueBoardService`:

```dart
Future<TokenPage> searchSessionTokens(Account, String chamberId, TokenQuery query)
```

- `TokenQuery`: `search`, `status?`, `queueTypeId?`, `notPrintedOnly`, `sort` (`id|name|serial|queue|wait|status`), `ascending`, `limit` (default 30), `offset`.
- `TokenPage`: `items`, `total` (after all filters), `counts` (per status, ignoring the status filter), `sessionId?`.
- Implemented in `DriftQueueBoardRepository` as one joined query (tokens ⟕ patients) with SQL `ORDER BY`, `LIMIT/OFFSET`, `LIKE`; sort keys for queue, status and wait use `CASE`/arithmetic expressions. Tie-break on token id so rows never move between pages.
- `loadBoard` gains `includeTokens` (default `true`, so the web API is unchanged); the desk passes `false`.
- No session → empty page.

## 6. State and refresh

- `QueueDeskTableController` (Riverpod notifier, per chamber): holds the query, loaded items, total, counts, loading / loading-more / error. Stale answers are ignored (sequence number). Changing search / filter / sort starts again from page one.
- Scrolling near the end loads the next page.
- After any desk action (issue, call, enter, missed, cancel, print, edit) it **reloads in place** (as many rows as are loaded, at least one page) without a full-screen loader; the list position is kept.
- A once-a-second ticker provider drives the live wait cells; injectable for tests.

## 7. Code structure (each file one job, ≤ 300 lines)

- `application/token_query.dart` — `TokenQuery`, `TokenPage`, enums.
- `application/queue_desk_table_controller.dart` — table state.
- `presentation/queue_desk_view.dart` — pure layout (snapshot + table state + callbacks), landscape/portrait.
- `queue_desk_now_calling.dart`, `queue_desk_queue_controls.dart`, `queue_desk_table_toolbar.dart`, `queue_desk_token_table.dart` (+ existing `queue_desk_token_rows.dart`, `queue_desk_token_status.dart`), `queue_desk_live_wait.dart`.
- `queue_desk_panel.dart` stays the stateful wiring (providers, dialogs, actions). The old left-column widgets in `queue_desk_panel_widgets.dart` are replaced.

## 8. Testing (a checkpoint after each)

1. **Service/DB**: search (Bengali, English, ID, serial, phone), each filter, every sort both directions, paging without duplicates or gaps, counts, empty session, 200 tokens.
2. **Live wait**: formats (`00:00`, `59:59`, `1:00:00`), ticking with a fake ticker, freezing after call, Bengali digits.
3. **Layout widget tests** — sizes 1340×800, 800×1340, 893×533, 533×893, 360×740; 1 / 3 / 6 queues; nothing / one called patient (long Bengali name); 100% and 130% text; English and Bengali; light and dark. Asserts no overflow and that the table area is the only scrolling region.
4. **Controller**: debounce, stale answers, load more, reload-in-place keeps position.
5. **On the tablet**, both orientations, 40+ patients: add, add existing, call, recall, entered, missed, cancel, search, filter, sort, scroll, edit, printer off.

## 9. Out of scope

Web dashboard, a real-time push from other devices (the desk refreshes after its own actions and on screen entry), printing changes beyond what exists.

## 10. Assumptions

- Wait runs from `issuedAt` to `firstCalledAt` (or `enteredAt`), then stops.
- Default sort is newest first; counts cover the whole session.
- The "Resolve serial … first" line is removed; the state shows in Now calling and on disabled Call buttons.
