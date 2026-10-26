# 04 — Code style (Dart)

Follow [Effective Dart](https://dart.dev/effective-dart). Tooling enforces; don't argue with the linter.

## Tooling

- `dart format .` — no manual formatting.
- `flutter analyze` — **zero** issues. `analysis_options.yaml`: `flutter_lints` + `strict-casts`, `strict-inference`, `strict-raw-types`.
- Don't silence lints (`// ignore`) without a one-line reason.

## Naming

| Thing | Style | Example |
| --- | --- | --- |
| Files, packages | `snake_case` | `token_repository.dart` |
| Types | `UpperCamelCase` | `TokenRepository` |
| Members, vars | `lowerCamelCase` | `nextSerial` |
| Constants | `lowerCamelCase` | `maxRetries` |
| Private | `_leading` | `_cache` |

Suffixes: `*Page`/`*Screen` (route), `*View` (sub-UI), `*Controller`/`*Notifier` (state), `*Repository`, `*Gateway` (device/API), `*Dto` (wire model). Booleans read as questions: `isConnected`, `hasPaper`.

## Size & shape

- Function ≤ 40 lines; file ≤ 300; ≤ 4 params (use a parameter object beyond that).
- Early returns over deep nesting (max 3 levels).
- One public type per file (small private helpers allowed).

## Types & null safety

- No `dynamic`; no `as` casts without a check. No `!` unless proven non-null (comment why).
- Avoid `late` except for DI/init that is guaranteed.
- Models immutable (`final` fields, `copyWith`). Use Dart 3 `sealed` classes/records for states and results; exhaustive `switch`.
- Enums for closed sets; no stringly-typed state.

## Async

- Always `await` or mark `unawaited(...)` deliberately. No async constructors.
- Cancel/dispose timers, streams, controllers.
- Don't use `BuildContext` after an `await` without `mounted` check.

## Comments & docs

- Code explains *what*; comments explain *why* (constraints, trade-offs).
- `///` doc comments on public API of `domain` and `core`.
- No dead code, no commented-out code. `TODO(name): …` must link an issue.
- No `print`/`debugPrint` — use the logger ([Errors & logging](../principles/errors-logging.md)).

## Imports

- `package:` imports; relative only within the same feature folder. Keep sorted (`directives_ordering`).
- Respect layer rules ([Architecture](../principles/architecture.md)).

## Dependencies

- Add only with a reason (maintained, null-safe, permissive license, small). Ask first.
- Caret ranges in `pubspec.yaml`; commit `pubspec.lock`.
- Code generation (`build_runner`) allowed for drift/freezed/pigeon/riverpod; **never edit generated files**.
