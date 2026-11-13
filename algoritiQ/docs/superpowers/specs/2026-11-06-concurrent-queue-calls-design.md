# Concurrent queue calls, board tiles and empty states — design

Date: 2026-11-06. Status: approved in chat by the product owner.

## Goal

A receptionist can have one called token in each queue at the same time (three
queues → up to three calls). Announcements never overlap: they are spoken one
after another. The waiting-room board shows every active call. Two board
problems are fixed in the same change: no doctor photo means no picture box, and
the "no token has been called yet" message must not show while people wait.

## Rule change

`docs/features/patient-entry-and-queue-operations.md` said only one token may be
`CALLED` per chamber. New rule: **one `CALLED` token per queue type** in a
session.

- Call next on a queue is refused (`unresolvedCalledToken`) only when **that
  queue** already has a `CALLED` token. Other queues are unaffected.
- Recall, Entered, Missed and Cancel act on the token they are pressed for.
- `canCallNext` = that queue has no `CALLED` token and someone waits.
  `canRecall` = that queue has a `CALLED` token.

## Data and API

- `BoardSnapshot.calledTokens` (list, ordered by queue display order) replaces
  `calledToken`. The HTTP desk API returns `calledTokens` and keeps
  `calledToken` (the most recently called) so an older web bundle keeps working.
- Live TV display payload gets `calledList`:
  `[{tokenId, queueTypeId, serial}]` in queue display order. `called` stays and
  is the most recently called token, for TV builds that do not know `calledList`.

## Announcements

- TV app: its announcement player plays calls through a first-in first-out
  queue; the next clip starts when the previous one finished. A clip that fails
  is skipped.
- The tablet no longer casts its screen to a TV (the cast display and its
  `CastBoardController` were removed, November 2026); the TV app is the only
  waiting-room display.

## Screens

- Board (TV app): "now calling" card shows one tile per called token with
  the queue name; the newest call/recall is highlighted and pulses. With none
  called and people waiting: label "অপেক্ষা করুন", text "শীঘ্রই ডাকা হবে". With
  nobody waiting and none called: "এখন কেউ অপেক্ষায় নেই".
- No doctor photo: the picture box and its initials are removed; details use the
  full card width.
- Tablet desk and web desk: the current-call area lists every active call, each
  with Recall, Entered, Missed and Cancel; the blocking notice names the queue.

## Testing

Service tests for the per-queue rule and recall; snapshot/payload tests for
`calledList`; controller test for announcement ordering; board widget tests for
tiles, empty states and photo-less layout; web tests for the multi-call panel;
live check on the tablet with the display simulator; final check on the real
TV. The web desk is bundled in the tablet app, so it ships by rebuilding and
installing the APK.
