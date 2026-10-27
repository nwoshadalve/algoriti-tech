# Web code standards

TypeScript + React in `algoritiQ/web`.

## Tooling

| Tool | Purpose |
| --- | --- |
| TypeScript 7 (`strict`) | Types |
| Vite | Dev server and production bundle |
| oxlint | Lint (`npm run lint`) |
| Vitest | Unit and component tests |

## Naming

| Item | Convention |
| --- | --- |
| Components | `PascalCase.tsx` |
| Hooks | `useSomething.ts` |
| Utilities | `camelCase.ts` |
| Test files | `*.test.ts` / `*.test.tsx` beside source or under `__tests__` |
| CSS modules / side CSS | `ComponentName.css` |

## Imports

- Use path alias `@/` → `src/` (configured in `tsconfig` and Vite).
- Order: React → third-party → `@/` → relative.
- No default exports for shared utilities — named exports except `lazy()` route pages.

## React patterns

- One component per file for anything reused or > ~80 lines.
- Colocate feature types in `features/<name>/types.ts`.
- Side effects in `useEffect` with cleanup; abort `fetch` via `AbortController`.
- Prefer `useMemo`/`useCallback` only when profiling or stable child memoization requires it — not by default.

## API layer

```text
core/api/
  client.ts       # fetch wrapper, auth headers, error mapping
  types.ts        # shared DTO types until OpenAPI codegen lands
```

- Map HTTP errors to a small `AppError` type; UI shows localized messages.
- **MUST NOT** scatter `import.meta.env` outside `core/config.ts`.

## Environment variables

- Prefix with `VITE_` for client-exposed values.
- `.env.development` for local proxy targets; **never commit** `.env` with secrets.
- Document every variable in `web/README.md`.

## Size & review

- `build()`-equivalent: keep route components thin — delegate to feature components.
- No `// eslint-disable` without issue link; prefer fixing the cause.

## Definition of done

```powershell
cd algoritiQ\web
npm run lint
npm test
npm run build
```

Bug fixes include a regression test per [web-regression-tests.md](./web-regression-tests.md).
