# Testing standards

How to write regression tests. Strategy and scope: [Testing principles](../principles/testing.md).

## Tools

| Scope | Tool |
| --- | --- |
| Dart logic (domain, controllers, repositories) | `flutter_test` / `dart test` |
| Screens (only when a UI bug needs a regression test) | `flutter_test` widget tests |
| Core flows on the real tablet | `integration_test` |
| Kotlin service logic | JUnit + fake transport |

## Layout & naming

- `test/` mirrors `lib/`: `lib/features/queue/domain/token.dart` → `test/features/queue/domain/token_test.dart`.
- Test name: `should <behavior> when <condition>`.
- Regression test for a bug: add the issue id in the name or a comment, e.g. `// regression: #42 duplicate serial on retry`.
- Group with `group()` per class or behavior.

## Writing a test

- **Arrange – Act – Assert**, one behavior per test.
- Prefer **fakes** (in-memory repository, fake printer gateway) over mocks. `mocktail` is allowed where a fake is overkill.
- Use an in-memory drift database for repository tests; run migrations in migration tests.
- Inject `Clock` and ID generator; never depend on real time or random values.
- No `sleep`/`Future.delayed` waits — use `fakeAsync` or pump frames.
- Each test is independent: no shared mutable state or ordering.
- Assert on outcomes (state, returned values, emitted events), not on private calls.

## Do / Don't

| Do | Don't |
| --- | --- |
| Reproduce the bug in a test first | Fix the bug and add a test "later" |
| Keep test data minimal and readable | Copy huge fixtures |
| Use builders/helpers in `test/support/` | Repeat setup in every test |
| Fix or delete a flaky test | Retry-loop until it passes |
| Change a test only when behavior intentionally changed | Edit expectations to make it green |

## Android (Kotlin)

- Put Bluetooth behind a `Transport` interface; test print queue, retries and error codes with a fake.
- Real Bluetooth/printing is checked on the tablet, not in unit tests.
- Unit tests in `android/app/src/test/`; device tests in `android/app/src/androidTest/`.

## Commands

```powershell
flutter analyze
flutter test                          # all
flutter test test/path/file_test.dart # one file
flutter test integration_test         # on connected tablet
```

A task is not done until `flutter analyze` and `flutter test` pass.
