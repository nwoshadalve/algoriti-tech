# Queue desk: Calling and Patients tabs — design

Date: 2026-11-06. Status: layout chosen by the product owner in chat ("Two tabs: Calling and Patients"). Supersedes the layout in `2026-11-04-queue-desk-redesign-design.md` (the table, search, filters and backend there stay).

## Problem

Each queue appeared twice (Now calling and Queues). With two or three active calls the left strip grew past the ~380 dp the Honor Pad leaves, so queues were cut off, and the patient table showed only 3–4 rows.

## Layout

One row on top: two tabs, **Calling** (badge: active calls) and **Patients** (badge: session total), and the two Add buttons on the right. Below, the selected tab fills all remaining space. On a narrow pane (< 560 dp) the Add buttons move to their own line under the tabs.

**Calling tab** — one card per queue, all on screen at once (up to four queues without scrolling on the Honor Pad; beyond that the list scrolls inside itself):

- name, "N waiting", **Call** (always visible, disabled when the queue is busy or empty);
- when the queue is calling: serial, patient name, patient ID, and **Recall · Entered · Missed · Cancel** for that patient (nothing is hidden in a menu).
- Wide pane: a queue is one row. Narrow pane: name and Call on one line, the patient and actions below.
- **End session** is a small error-coloured button under the cards.

**Patients tab** — the existing toolbar (filters, sort) and table, using the full height. The title and Add buttons move to the tab row.

Landscape and portrait use the same tabs; only the card arrangement changes with width. The selected tab is kept while the desk is open; it opens on Calling.

## Out of scope

Table columns and backend, web desk (the web desk keeps its own layout), call rules from the concurrent-calls design.

## Testing

Layout matrix (Honor Pad landscape/portrait, large tablet, phone; 1/3/6 queues; nobody/one/all calling; English/Bengali; text ×1.3; dark/light) with no overflow and every queue's Call button on screen on tablets in the Calling tab; actions pass the right token; tabs switch and keep the badges; table still scrolls alone; checked on the tablet.
