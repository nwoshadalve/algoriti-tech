# 08 — Testing

## Pyramid

| Level | Tool | Scope |
| --- | --- | --- |
| Unit | `flutter_test` / `dart test` | domain, controllers, repositories (in-memory DB) |
| Widget | `flutter_test` | screens: loading / empty / error / data states |
| Golden (key screens) | `matchesGoldenFile` | token screen, queue screen — optional |
| Integration | `integration_test` | core flows on the **physical tablet** |
| Kotlin | JUnit + fake transport | service logic; real Bluetooth on device |

Targets: **domain ≥ 90%**, overall ≥ 70% line coverage. Coverage is a floor, not the goal.

## Rules

- `test/` mirrors `lib/`. Name: `should <behavior> when <condition>`. Arrange–Act–Assert.
- Prefer **fakes** over mocks; `mocktail` allowed. Test behavior, not implementation.
- No real network, clock, randomness or Bluetooth in unit tests — inject `Clock`, ID generator, gateways.
- Deterministic: no `sleep`; use `fakeAsync` / pumped frames.
- Bug fix → write the failing regression test first.
- New logic without tests is not done.

## Must-have tests (system-critical)

- Serial allocation: 100 concurrent/rapid tokens → no duplicates, no gaps beyond rules.
- Idempotency: same `commandId` twice → one record, same result.
- Token state machine: every legal and illegal transition.
- Event sequence + snapshot recovery after missed/reordered events.
- DB migrations: upgrade from each prior version keeps data.
- Session restore after app restart resumes `eventSequence`.
- Printer failure leaves token intact; reprint works.

## Hardware acceptance (physical devices, offline)

Follow [R&D §9](../../../docs/discussions/rnd_architechture.md): Bengali receipt, printer reconnect, TV recovery, router power-cycle, unpaired client rejected, full-shift soak.

## Before every commit

```powershell
dart format .
flutter analyze
flutter test
```

Run UI changes on the tablet; screenshot via `adb exec-out screencap -p` for the PR when useful.
