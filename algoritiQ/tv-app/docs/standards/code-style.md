# 02 — Code style (Kotlin)

Follow [Kotlin coding conventions](https://kotlinlang.org/docs/coding-conventions.html). Use ktlint/detekt when configured in Gradle.

## Copyright header

New source files in this project SHOULD include:

```kotlin
/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
```

## Naming

| Thing | Style | Example |
| --- | --- | --- |
| Files | `PascalCase.kt` matching primary type | `PairingViewModel.kt` |
| Packages | lowercase | `tech.algoriti.algoritiq_tv.features.pairing` |
| Types | `UpperCamelCase` | `LiveSessionRepository` |
| Functions, vars | `lowerCamelCase` | `applySnapshot` |
| Composables | `PascalCase` | `DisplayLiveScreen` |

Suffixes: `*Screen` (route), `*ViewModel`, `*Repository`, `*Dto`, `*Mapper`.

## Size & shape

- Function ≤ 40 lines when practical; file ≤ 300 lines before split.
- Early returns; max nesting depth 3.
- One public type per file (small private helpers allowed).

## Coroutines

- ViewModels use `viewModelScope`; repositories use injected scope or `withContext(Dispatchers.IO)`.
- MUST NOT use `GlobalScope`.
- Expose UI state as `StateFlow`; collect in Composables with lifecycle awareness.

## Serialization

- DTOs in `data` layer only; map to domain before use in application layer.

## Comments

- Explain **why** (sequence gaps, dedupe rules), not what the next line does.
