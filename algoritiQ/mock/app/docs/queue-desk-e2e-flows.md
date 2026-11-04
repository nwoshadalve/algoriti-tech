# Queue desk mock — E2E flows (manual)

Use **`/screens/board.html`** (Queue desk) with dummy data persisted in `localStorage` (`algoritiq-mock-queue-desk-v2`). **Reset demo** restores seed data.

## Session

| Step | Action | Expected |
|------|--------|----------|
| 1 | Set `sessionOpen` via **Reset demo** (seed = open) or toggle in dev | Patient actions enabled when open |
| 2 | **Start session** when closed | Session opens; audit `session.start` |

## New patient → token

| Step | Action | Expected |
|------|--------|----------|
| 1 | **New patient** | Register modal |
| 2 | Enter Bengali name + phone; optional paper file | — |
| 3 | Duplicate phone (e.g. `01711111111`) | Warning; **Confirm & save** |
| 4 | Check **Save and continue to issue token** | After save → existing-patient modal with patient selected |
| 5 | Choose queue, **Review & print** → **Confirm & print** | Token in table; print slip modal; audit `token.issued` |

## Existing patient → token

| Step | Action | Expected |
|------|--------|----------|
| 1 | **Existing patient** → search `P-2` or phone | Match list |
| 2 | Select row, queue, fee, confirm issue | New WAITING token |
| 3 | Issue again for same patient | **Active token** modal; reprint only |

## Queue operations

| Step | Action | Expected |
|------|--------|----------|
| 1 | Resolve **1004** (Entered / Missed / Cancel) | Call enabled |
| 2 | **Call** on Regular | Oldest WAITING → CALLED; announcement banner |
| 3 | **Recall** | Audit `token.recall`; announcement |
| 4 | **Call** while CALLED unresolved | **Resolve current call** modal |

## Print

| Step | Action | Expected |
|------|--------|----------|
| 1 | Toolbar **Print sim → Fail** | Issue/reprint → slip shows FAILED; token stays valid |
| 2 | **Unknown** | No auto-retry; staff checks printer |
| 3 | **Reprint** with reason | REPRINT on slip; printer lock disables other prints |

## Token row **⋯**

| Action | Expected |
|--------|----------|
| Wrong queue type | Cancel `WRONG_QUEUE_TYPE`; issue confirm in correct queue |
| Cancel token | Reason required; CANCELLED |
| Edit patient | Profile update; IDs/serials unchanged |

## Audit

**Audit** button shows recent mock audit entries (issue, call, print, cancel, patient).
