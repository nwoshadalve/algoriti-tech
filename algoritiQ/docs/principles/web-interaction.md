# Web interaction principles

Pointer and affordance rules for `algoritiQ/web`.

## Cursor

- Any **clickable** control MUST show `cursor: pointer` on hover (and when idle), so users can tell it is interactive.
- This includes: `<button>`, links (`<a href>`), icon buttons, language/theme toggles, pill segments, text links styled as buttons, and custom controls with `role="button"`.
- **Disabled** controls MUST use `cursor: not-allowed` (or stay non-interactive without pointer), not `pointer`.
- Non-clickable surfaces (cards, labels without `for`, static text) MUST NOT use `cursor: pointer`.

## Implementation

- Global defaults live in `web/src/index.css` (`@layer base`) so new screens inherit the rule automatically.
- When adding a custom clickable element (e.g. `div` + `onClick`), either use a semantic `<button>` / `<a>` or add `className="cursor-pointer"` and keyboard support — prefer semantic elements.

## Do not

- Rely on hover color alone without pointer on desktop/laptop.
- Set `cursor: default` on interactive components unless the control is truly read-only.

Standards detail: [../standards/web-ui.md](../standards/web-ui.md#pointer-and-cursor).

## After a successful save (partial UI updates)

React screens MUST feel stable: a small edit updates only what changed, not the whole page.

- When one control or section is saved (modal, toggle, row action), MUST update **only the state** that changed — from the API response or the value just submitted.
- MUST NOT flip a page-level `loading` flag or replace the route with a preloader after a **successful** mutation. The list, header, and surrounding copy stay mounted.
- A **first visit** to a screen and an explicit **Retry** after load failure MAY show a full-page loader. Routine saves MUST NOT reuse that path.
- Refetching an entire screen after every save is an anti-pattern. If extra fields must be reconciled, fetch in the background **without** clearing visible content, or patch local state from the save response.
- Example: changing automatic session stop updates the stop-time summary (and effective time for the active chamber) and closes the modal — it does not reload queue types or chamber lists.
- The callback that sets page-level `loading` MUST NOT depend on filters, tabs, or selected ids (e.g. selected chamber). Put those in a **separate** fetch with section-only loading (or none). Otherwise changing a selection recreates the callback, re-runs the mount `useEffect`, and flashes the full-page preloader.
- Overlapping fetches MUST ignore stale responses (sequence counter or abort) when a newer request or a save has superseded them.
- **Server state (TanStack Query):** Read-mostly API data (e.g. queue defaults, chamber lists, per-chamber queue snapshots) MUST go through **TanStack Query** (`useQuery` / `useMutation`) with stable keys in `features/<name>/…QueryKeys.ts`. Revisiting a route or switching a filter MUST show cached data immediately while a background refetch runs when the entry is stale — not a full-page preloader.
- **After local saves:** Mutations MUST patch the query cache from the API response (`setQueryData`) or invalidate only the affected keys. Do not refetch the whole screen on every save.
- **Live channel:** When the tablet publishes a named WebSocket event (e.g. `queue.configuration.changed`), invalidate the matching query keys and let TanStack Query refetch in the background; show a short toast when **remote** clinic-wide changes arrive. Local saves still patch from the response without a full-page reload.

## Feedback: toasts

- The **result of an action** (saved, created, changed, signed in, failed) MUST be shown in a **toast**, not in a banner inside the form. One place to look, the same on every screen.
- A **field mistake** (empty, too short, does not match) MUST stay **on the field**, next to the input. When the server refuses a value (taken username, wrong current password) the field is marked **and** a toast says the same words.
- A save stopped by the form's own checks MUST also raise a toast ("Check the highlighted fields…"), because the mistake may be scrolled out of view.
- Toasts are **short** (one sentence), say what happened in the user's words, and never carry codes, stack traces, secrets or passwords.
- **At most 5** are on screen; a sixth pushes the oldest off. The same message raised again refreshes the one shown instead of stacking.
- Failures stay longer than successes, pause while the pointer or focus is on them, and can always be dismissed.
- A page that cannot show anything at all (its list failed to load) keeps its message **in the page**, with a retry button; a toast alone would vanish and leave an empty screen.

## Popups

- Forms that create or change a record (add user, edit user, change password) and confirmations of risky actions (disable a user) MUST open in a **popup** (`Modal`), not push the page around or hide in an inline panel.
- A popup has a **fixed header** (title, close button), a **scrolling body** and a **fixed footer** holding the buttons. The primary action is on the right on wide screens and on top on phones.
- A popup keeps focus inside, returns it to what opened it, closes with Escape, the close button and a press on the dark area, and holds the page still behind it.
- While something is being saved the popup **cannot be closed**, so the result is never lost. It closes by itself on success and stays open, with the mistake shown, on failure.
- A popup MUST NOT open another popup. If a flow needs two steps, use steps inside one popup.
- **Destructive actions** (disable, remove) ask first, in a small popup that names the person or thing and says what will happen and that it can be undone, if it can.

## Lists and tables

- Anything that can grow (users, patients, appointments) MUST be **searched, filtered, sorted and paged by the server**. The browser never downloads a whole table to work on it.
- A list loads one page at a time and loads the next **as the person scrolls** near the end. A visible *Load more* button covers browsers without scroll observation, and a *Try again* button covers a failed page.
- A new search, filter or sort starts again from the first page. Answers to an older query are dropped, so a slow reply can never overwrite a newer one.
- Typing in a search box waits for a short pause (about 300 ms) before asking, so a word is one request, not one per letter.
- Show how many matched and how many are shown ("Showing 20 of 45"), an empty state that says nothing matched with a way to clear the filters, and keep the page position when one row changes.
- The server answers a page as `{ items, total, nextCursor }`; the cursor is opaque to the client.
- On phones a table becomes a list of labelled cards. The data and the controls stay the same; no horizontal scrolling.

## Icons and tooltips

- **Actions on a row or beside a value** (edit, disable, enable, delete, upload a photo, undo) MUST be **icon buttons** with a **tooltip**, not text buttons. A table full of "Edit | Disable" words is noisy; a column of familiar icons is calm.
- The **main action of a page or popup** (Add user, Save, Create account, Confirm) stays a **labelled button**: it is the one thing the person came to do and must never be guessed. A leading `+` is fine; arrows are not (see [UI standards](../standards/web-ui.md)).
- Every icon means **one thing across the app**: pencil = edit, circle-with-slash = disable, check-circle = enable, trash = delete, camera = photo, undo = discard changes, plus = add, X = close. Do not reuse an icon for another meaning.
- An icon-only control MUST have an **accessible name** (`aria-label`) that says what it does and, in a list, to whom: "Edit: Dr. Rahim". The tooltip repeats the short action ("Edit"); it is a visual help and is hidden from screen readers so nothing is read twice.
- A tooltip is **one short phrase**, never a sentence of instructions or the only place a fact appears. It shows after a short pause on hover, **at once on keyboard focus**, and hides on Escape, leaving, clicking or scrolling.
- A **disabled** icon button says **why** in its tooltip ("A doctor needs at least one chamber"). Never leave a person to guess why something is greyed out.
- Where there is **no hover** (phones), icon buttons in a card show their **label next to the icon**; touch users must not be left to decode icons.
- Touch targets stay at least 44 × 44 px on phones, whatever the icon size.
- Icons are drawn in one set (`core/ui/icons.tsx`: 20 px, 1.8 stroke, round caps, `currentColor`) and never carry the only meaning; colour (red for destructive) accompanies the icon, it does not replace it.

## Who sees what in lists of people

- An admin managing users MUST NOT see **their own account** in the list. The server leaves it out (and from the total), so it cannot be edited, disabled or demoted from there by mistake; their own details live in **Settings**.
