# Testing principles

Strategy for this project: **regression testing**. We protect behavior that already works and that clinics depend on. We don't chase coverage numbers.

## Principles

1. **Every bug gets a regression test.** Write the failing test first, then fix. A bug fixed without a test will return.
2. **Protect the critical paths.** Tests exist for behavior that must never break (list below). Everything else is optional.
3. **Test behavior, not implementation.** Tests survive refactors; they fail only when behavior changes.
4. **Fast and deterministic.** No real network, clock, randomness or Bluetooth in automated tests. Flaky tests are fixed or deleted.
5. **A red test blocks the change.** Never skip or delete a failing test to get green — fix the code or consciously update the test with a reason.
6. **Hardware can't be faked fully.** Printer, TV and router behavior is verified on real devices with the acceptance checklist.

## Critical paths (always covered by regression tests)

- Serial numbers: no duplicates, correct sequence, allocated in one transaction.
- Idempotency: the same `commandId` twice creates one record.
- Token state machine: legal transitions work, illegal ones are rejected.
- Event sequence and snapshot recovery after missed events.
- Session restore after app restart; numbering continues.
- Database migrations keep existing data.
- Printer failure keeps the token; reprint works.
- Pairing/authorization: unpaired or read-only clients can't control the queue.

## Out of scope (for now)

- Coverage targets, golden/pixel tests, broad UI snapshot suites.
- Testing generated code, third-party packages, or trivial getters.

Add a layer (e.g. widget or golden tests) only when a UI bug repeats — then it becomes a regression test.

## When tests run

| When | What |
| --- | --- |
| Before every commit | `flutter analyze` + `flutter test` |
| Every bug fix | New regression test included in the same PR |
| Before a clinic release | Full suite + hardware acceptance on the tablet |

Hardware acceptance (offline, physical devices): see [R&D §9](../../../docs/discussions/rnd_architechture.md).

How to write them: [Testing standards](../standards/testing.md).
