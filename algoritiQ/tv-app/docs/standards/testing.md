# 03 — Testing (how-to)

## Layout

```text
app/src/test/java/...     # unit tests (JVM)
app/src/androidTest/...   # instrumented (sparingly)
```

## Libraries

- JUnit 5 (or JUnit 4 if Gradle template uses 4 — align with project)
- MockWebServer (OkHttp)
- Turbine for Flow
- Coroutines test (`runTest`, `StandardTestDispatcher`)

## Patterns

- Domain tests: pure Kotlin, no Robolectric.
- ViewModel tests: fake repositories, turbine on `uiState`.
- Parse golden JSON files for WS `snapshot` / `event` frames when shapes stabilize in OpenAPI.

## Naming

- `shouldApplySnapshotBeforeEventsWhenReconnecting`
- One behavior per test method.

## CI (when added)

`./gradlew check` before merge — same order as [git-delivery](./git-delivery.md).
