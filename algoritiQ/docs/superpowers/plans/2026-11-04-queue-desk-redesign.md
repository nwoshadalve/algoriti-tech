# Queue Desk Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** One-screen queue desk (landscape + portrait) whose patient table is searched, filtered, sorted and paged by the database, with a live wait column and no overflow when a patient is being called.

**Architecture:** A new `searchSessionTokens` query in `QueueBoardService`/`DriftQueueBoardRepository` returns a page of tokens plus per-status counts. A per-chamber Riverpod notifier owns the table state. A pure `QueueDeskView` lays out compact Now calling, queues and the table for the pane size; `QueueDeskPanel` stays the wiring (providers, dialogs, actions).

**Tech Stack:** Flutter, Riverpod (`flutter_riverpod`), drift 2.35 (SQLite), flutter_test, ARB l10n (bn + en).

**Spec:** `docs/superpowers/specs/2026-11-04-queue-desk-redesign-design.md`

## Global Constraints

- Project root `algoritiQ/app`; follow `app/AGENTS.md` and `app/docs` (mandatory).
- Copyright header on every new hand-written `.dart` file (copy from any existing file).
- File ≤ 300 lines, function ≤ 40 lines, `build()` ≤ ~80 lines; widgets are classes, not helper methods.
- No hardcoded colours/sizes: `Spacing`, `Radii`, theme scheme, `BrandColors.positive`. Touch targets ≥ 48 dp.
- Every user-visible string in **both** `lib/l10n/app_en.arb` and `app_bn.arb`, then `flutter gen-l10n`. No example text in fields. No arrow icons on buttons.
- Results of actions through the toaster (`toastControllerProvider`), never `SnackBar`.
- No `dart format .` on the project: format **only the files you touched** (`dart format <paths>`).
- Web API (`lib/api/local_api_server.dart`) behaviour must not change: `loadBoard` keeps returning tokens by default.
- Run on the tablet with `ANDROID_SERIAL=AJ5EJK6609C03364` (another emulator may be attached). Never `adb uninstall` / `pm clear` (back up first per `app/AGENTS.md` §6).
- Do not commit unless the user asks.
- Known unrelated failures: 24 `sign_in_test.dart` tests and `app_database_migration_test.dart` fail before this work; do not "fix" them.

## Review Focus

- A called patient with a very long Bengali name and 6 queues in portrait: nothing overflows, Now calling stays ≤ ~120 dp.
- Searching with `%`, `_` or a quote character: treated as plain text, no SQL error, no wildcard matching.
- Search/filter/sort changed while a slower earlier answer is still pending: the older answer never replaces the newer.
- Pages after a reload: no duplicate or missing rows when tokens change status between page loads (tie-break on id).
- Session closed / not started: table shows an empty state, counts are zero, no error.
- Clock skew (token `issuedAt` in the future): wait shows `00:00`, never negative.

---

### Task 1: Token query model and database query

**Files:**
- Create: `lib/features/queue_board/domain/token_query.dart`
- Modify: `lib/features/queue_board/data/drift_queue_board_repository.dart`
- Test: `test/features/queue_board/token_query_repository_test.dart` (uses `test/support/queue_desk_kit.dart`)

**Interfaces:**
- Produces (`token_query.dart`):
  - `enum TokenSort { issued, id, name, serial, queue, wait, status }`
  - `final class TokenQuery { const TokenQuery({String search = '', TokenStatus? status, String? queueTypeId, bool notPrintedOnly = false, TokenSort sort = TokenSort.issued, bool ascending = false, int limit = 30, int offset = 0}); TokenQuery copyWith({...}); bool get hasFilters; }` — `copyWith` for every field (`status`/`queueTypeId` clearable via `clearStatus`/`clearQueue` flags); `hasFilters` is true for non-empty search, status, queue or `notPrintedOnly`.
  - `final class TokenRows { const TokenRows({required List<QueueTokenRow> rows, required int total, required Map<TokenStatus, int> counts}); }` (data-layer result, in the repository file)
- Produces (repository): `Future<TokenRows> querySessionTokens({required String sessionId, required TokenQuery query, required int nowMs, required Map<String, int> queueOrder})` — `queueOrder` maps queueTypeId → display order.

- [ ] **Step 1: Write failing tests** in `token_query_repository_test.dart`, one `test` each, against a kit desk with an open session and patients added via `desk.addPatient` (add a `desk.boardRepo` getter to `QueueDeskKit` exposing the `DriftQueueBoardRepository`):
  - `search matches Bengali name part, English name any case, clinic id prefix, serial, phone prefix`
  - `search treats % _ and ' as plain text` (query `'%'` returns 0 rows of names without `%`; no exception)
  - `status filter and counts ignore each other`: counts hold every status regardless of the status filter, `total` honours it
  - `queue filter and notPrintedOnly` (printed via `setLatestPrintStatus`)
  - `sort by each of TokenSort values, ascending and descending` — assert the exact order of serials for: name (Bengali alphabetical by `bengaliName`), id, serial, queue (by `queueOrder`, then serial), wait (`COALESCE(firstCalledAt, enteredAt, nowMs) - issuedAt`), status (waiting, called, skipped, entered, cancelled), issued
  - `paging has no duplicates or gaps with 70 tokens and limit 30; offset past the end returns empty rows with the same total`
  - `ties on the sort key are broken by token id`
  - `a future issuedAt gives wait 0 when sorted` (clamp with `MAX(0, …)`)

- [ ] **Step 2: Run** `flutter test test/features/queue_board/token_query_repository_test.dart` — Expected: FAIL (`querySessionTokens` undefined).

- [ ] **Step 3: Implement** `TokenQuery`/`TokenSort` and `querySessionTokens` in the repository: one drift join `queueTokens ⟕ patients` filtered by `sessionId`; search with `contains`/`startsWith` (drift escapes `%`/`_`); `ORDER BY` built from `TokenSort` using `CaseWhenExpression` for queue and status, `CustomExpression<int>` only for the wait arithmetic with `nowMs` bound as a variable; final `ORDER BY` tail is `queueTokens.id` (same direction); `limit/offset`; counts via a second grouped query that applies search + queue filter + notPrinted but not status.

- [ ] **Step 4: Run** the same command — Expected: PASS.

### Task 2: Service method and board without tokens

**Files:**
- Modify: `lib/features/queue_board/application/queue_board_service.dart`, `lib/features/queue_board/domain/board_models.dart`
- Test: `test/features/queue_board/queue_board_service_test.dart`

**Interfaces:**
- Consumes: `TokenQuery`, `querySessionTokens` (Task 1).
- Produces: `final class TokenPage { const TokenPage({required List<BoardTokenView> items, required int total, required Map<TokenStatus, int> counts}); static const empty; }` (in `board_models.dart`); `Future<TokenPage> QueueBoardService.searchSessionTokens(Account admin, String chamberId, TokenQuery query)`; `loadBoard(Account, String chamberId, {bool includeTokens = true})`.

- [ ] **Step 1: Write failing tests**: `searchSessionTokens returns views with patient names and queue names`; `returns TokenPage.empty when no session is open`; `refuses a receptionist not assigned to the chamber` (`QueueBoardProblem.forbidden`); `loadBoard(includeTokens: false) returns no tokens but the same queue controls and called token`.
- [ ] **Step 2: Run** `flutter test test/features/queue_board/queue_board_service_test.dart` — Expected: FAIL.
- [ ] **Step 3: Implement** the service method (`_requireDeskUser`, open session lookup, `typesForChamber` → `queueOrder`, rows → `_tokenView`) and the `includeTokens` flag (skip the token loop in `_snapshotForSession`, keep `calledToken`, controls, `printerBusyTokenId`).
- [ ] **Step 4: Run** the same file plus `flutter test test/api/queue_board_api_test.dart` — Expected: PASS (web API unchanged).

### Task 3: Live wait formatting and ticker

**Files:**
- Create: `lib/features/queue_board/presentation/queue_desk_live_wait.dart`
- Modify: `lib/features/queue_board/presentation/queue_desk_format.dart`
- Test: `test/features/queue_board/queue_desk_live_wait_test.dart`

**Interfaces:**
- Produces: `String queueDeskWaitClock(Duration wait, Locale locale)` (`mm:ss`, `h:mm:ss` from 1 h, negative → `00:00`, Bengali digits for `bn`); `final deskTickerProvider = StreamProvider.autoDispose<DateTime>(...)` (emits `DateTime.now()` every second); `class DeskLiveWait extends ConsumerWidget { const DeskLiveWait({super.key, required BoardTokenView token, TextStyle? style}); }` — shows `now - issuedAt` while WAITING/CALLED-unresolved? **No:** shows `(firstCalledAt ?? enteredAt ?? now) - issuedAt`, so it ticks only while the token has neither timestamp and is waiting.

- [ ] **Step 1: Write failing tests**: formatter table (`0s→00:00`, `59m59s→59:59`, `1h→1:00:00`, `-5s→00:00`, Bengali `১২:০৫`); widget test overriding `deskTickerProvider` with a `StreamController<DateTime>` asserting a waiting token's text advances `00:05 → 00:06` per emitted tick and a token with `firstCalledAt` stays frozen across ticks.
- [ ] **Step 2: Run** `flutter test test/features/queue_board/queue_desk_live_wait_test.dart` — Expected: FAIL.
- [ ] **Step 3: Implement** the formatter and widget; only waiting-without-call tokens watch the ticker (others render static text so ticks do not rebuild them).
- [ ] **Step 4: Run** — Expected: PASS.

### Task 4: Table controller

**Files:**
- Create: `lib/features/queue_board/application/queue_desk_table_controller.dart`
- Modify: `lib/features/queue_board/application/queue_board_providers.dart`
- Test: `test/features/queue_board/queue_desk_table_controller_test.dart` (ProviderContainer with a fake `QueueBoardService` subclass or the kit)

**Interfaces:**
- Consumes: `searchSessionTokens`, `TokenQuery`, `TokenPage`.
- Produces: `final class DeskTableState { TokenQuery query; List<BoardTokenView> items; int total; Map<TokenStatus,int> counts; bool loading; bool loadingMore; bool failed; bool get hasMore; }`; `final queueDeskTableProvider = NotifierProvider.autoDispose.family<QueueDeskTableController, DeskTableState, String>(...)` keyed by chamberId; methods `Future<void> load()`, `void setSearch(String)` (300 ms pause, then reset to offset 0), `void setStatus(TokenStatus?)`, `void setQueue(String?)`, `void toggleNotPrinted()`, `void sortBy(TokenSort)` (same key toggles direction; new key starts ascending), `void clearFilters()`, `Future<void> loadMore()`, `Future<void> reload()` (reloads `max(limit, items.length)` rows from offset 0 without setting `loading`).

- [ ] **Step 1: Write failing tests**: `setSearch waits 300 ms and sends one query`; `a slower older answer never replaces a newer one` (fake service with completers); `sortBy twice toggles direction, a new key resets to ascending`; `loadMore appends the next page and stops at total`; `reload keeps loaded rows visible (loading stays false) and refreshes counts`; `failure sets failed and keeps previous items`; `no open session yields empty items, zero counts`.
- [ ] **Step 2: Run** `flutter test test/features/queue_board/queue_desk_table_controller_test.dart` — Expected: FAIL.
- [ ] **Step 3: Implement** with a request sequence counter; account from `tabletSessionProvider`; the pause via a `Timer` (cancelled in `ref.onDispose`).
- [ ] **Step 4: Run** — Expected: PASS.

### Task 5: Patient table widgets (columns, sort, print icon, toolbar)

**Files:**
- Create: `lib/features/queue_board/presentation/queue_desk_token_table.dart`, `queue_desk_table_toolbar.dart`
- Modify: `queue_desk_token_rows.dart` (column order), `queue_desk_token_status.dart`, ARB files (new strings: `deskSearchPatients`, `deskFilterAll`, `deskFilterNotPrinted`, `deskFilterAllQueues`, `deskNoMatch`, `deskClearFilters`, `deskPrintNeeded`, `deskPrintBusy`, `deskSortedBy`, `deskLoadingMore`, `deskLoadFailed`), delete the old `queue_desk_session_table.dart` usage (file replaced, not removed from history without asking: leave it as a thin re-export or ask the user first)
- Test: `test/features/queue_board/queue_desk_token_table_test.dart` (replaces `queue_desk_session_table_test.dart` assertions)

**Interfaces:**
- Consumes: `DeskTableState`, `DeskLiveWait`, `QueueTypeBoardControl`.
- Produces: `class QueueDeskTokenTable extends StatelessWidget { const QueueDeskTokenTable({super.key, required DeskTableState state, required String? printerBusyTokenId, required ValueChanged<TokenSort> onSort, required VoidCallback onLoadMore, required VoidCallback onRetry, required void Function(BoardTokenView) onPrint, onEditPatient, onCancel, onReprint})`; `class QueueDeskTableToolbar extends StatelessWidget { const QueueDeskTableToolbar({super.key, required DeskTableState state, required List<QueueTypeBoardControl> queues, required ValueChanged<String> onSearch, required ValueChanged<TokenStatus?> onStatus, required ValueChanged<String?> onQueue, required VoidCallback onToggleNotPrinted, required VoidCallback onClear}); }`.

- [ ] **Step 1: Write failing tests**: header order `Patient ID, Name, Serial, Queue, Wait, Status` then icon columns; tapping a heading calls `onSort` with the matching `TokenSort`, heading shows direction in `Semantics`; two-line Bengali name wraps without overflow at width 560; print icon only for `FAILED/UNKNOWN/null/PENDING` and a busy indicator for `PENDING`; ⋯ menu has Edit patient, Reprint, Cancel token (active only); `printerBusyTokenId != null` disables print icons; chips show counts and `onStatus` fires; search field calls `onSearch`; empty result shows `deskNoMatch` + Clear filters; reaching the list end calls `onLoadMore`; failed state shows retry; card layout below 560 dp (scaled).
- [ ] **Step 2: Run** `flutter test test/features/queue_board/queue_desk_token_table_test.dart` — Expected: FAIL.
- [ ] **Step 3: Implement** the widgets; the list is a `ListView.builder` with a `ScrollController` (near-end → `onLoadMore`); rows use fixed column widths for ID/Serial/Queue/Wait/Status/actions and flex for Name; add keys on rows by token id.
- [ ] **Step 4: Run** the new test plus `flutter gen-l10n` clean — Expected: PASS.

### Task 6: Compact Now calling and queue controls

**Files:**
- Create: `lib/features/queue_board/presentation/queue_desk_now_calling.dart`, `queue_desk_queue_controls.dart`
- Test: `test/features/queue_board/queue_desk_left_strip_test.dart`

**Interfaces:**
- Produces: `class DeskNowCalling extends StatelessWidget { const DeskNowCalling({super.key, required BoardTokenView? called, required bool compactRow, required VoidCallback onRecall, onEntered, onMissed, onCancel}); }` (`compactRow` true = single slim row for portrait); `class DeskQueueControls extends StatelessWidget { const DeskQueueControls({super.key, required List<QueueTypeBoardControl> controls, required bool horizontalTiles, required String? busyQueueId, required ValueChanged<String> onCall, onRecall}); }` — vertical slim rows (list scrolls only if it cannot fit) or compact tiles that wrap.

- [ ] **Step 1: Write failing tests**: called token with a 60-character Bengali name renders in ≤ 120 dp height at width 360 and 800; empty state is one line; 1, 3 and 6 queues render with no overflow in 360×(remaining) and 800×200 tiles; Call disabled when `canCallNext` false; Call/Recall callbacks carry the queue id; no "Resolve serial" text.
- [ ] **Step 2: Run** `flutter test test/features/queue_board/queue_desk_left_strip_test.dart` — Expected: FAIL.
- [ ] **Step 3: Implement** with no fixed heights (intrinsic sizing; `Wrap` for tiles; `ListView(shrinkWrap)` capped by the available height for rows).
- [ ] **Step 4: Run** — Expected: PASS.

### Task 7: Desk view layout and panel wiring

**Files:**
- Create: `lib/features/queue_board/presentation/queue_desk_view.dart`
- Modify: `queue_desk_panel.dart` (use the view and `queueDeskTableProvider`; pass `includeTokens: false`; reload the table after every action), `queue_desk_panel_widgets.dart` (remove the replaced left-column and table-card widgets; keep `_SessionClosedCard` if still used)
- Test: `test/features/queue_board/queue_desk_view_test.dart`

**Interfaces:**
- Consumes: Tasks 3–6 widgets, `BoardSnapshot`, `DeskTableState`.
- Produces: `class QueueDeskView extends StatelessWidget { const QueueDeskView({super.key, required BoardSnapshot snapshot, required DeskTableState table, required QueueDeskCallbacks callbacks, String? busyQueueId}); }` with `final class QueueDeskCallbacks` grouping every callback (call, recall, entered, missed, cancelCalled, add, addExisting, search, status, queue, notPrinted, sort, loadMore, retry, print, edit, cancel, reprint, clearFilters). Landscape when `constraints.maxWidth >= 1000`.

- [ ] **Step 1: Write the layout matrix test** (`for` over sizes 1340×800, 800×1340, 893×533, 533×893, 360×740 × queues {1,3,6} × called {none, long Bengali name} × text scale {1.0, 1.3} × locale {en, bn} × theme {light, dark}): pumps `QueueDeskView` with fixture data, asserts `tester.takeException()` is null, that exactly one scrollable (the token list) exists, and that Now calling, every queue and the table header are on screen without scrolling.
- [ ] **Step 2: Run** `flutter test test/features/queue_board/queue_desk_view_test.dart` — Expected: FAIL.
- [ ] **Step 3: Implement** `QueueDeskView` (landscape: left strip 360 dp + table card; portrait: Now calling row, queue tiles, table card) and rewire `QueueDeskPanel` (it owns dialogs, `QueueDeskTokenActions`, session start; actions call `ref.read(queueDeskTableProvider(id).notifier).reload()` and `_refresh()` for the snapshot).
- [ ] **Step 4: Run** the matrix test and `flutter test test/features/queue_board test/core/widgets` — Expected: PASS.

### Task 8: Verify on the tablet, both orientations

**Files:** none (add `docs/features` note only if behaviour differs from the spec)

- [ ] **Step 1: Build and install**: `flutter build apk --debug`; `adb -s AJ5EJK6609C03364 install -r build/app/outputs/flutter-apk/app-debug.apk`; launch `tech.algoriti.algoritiq_app/.MainActivity`.
- [ ] **Step 2: Seed 45 patients** through the app (Add) or a one-off debug script in the scratchpad dir (not the repo); confirm paging by scrolling.
- [ ] **Step 3: Walk every scenario in landscape, then portrait, with a screenshot each**: add, add existing, call (Now calling filled, queues intact, no overflow bars), recall, entered, missed, cancel, search (name, ID, serial, phone), each status chip, queue filter, Not printed, every sortable heading both ways, live wait ticking, wait frozen after call, edit patient, print with printer off (icon red, token stays), session closed state.
- [ ] **Step 4: Run the whole suite** `flutter test`; Expected: only the known unrelated failures; `flutter analyze` on touched paths shows no new issues; `dart format` on touched paths only.
- [ ] **Step 5: Report** to the user what was verified and what was not (real printing needs the printer on).
