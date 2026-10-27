# 07 — Security & privacy

## Secrets

- MUST NOT commit keystores, `key.properties`, `.env`, passwords, tokens, API keys. Keep them in `.gitignore`.
- MUST NOT put secrets in source, logs, crash output or assets.
- Store runtime secrets (pairing/session tokens) in Android Keystore-backed storage (`flutter_secure_storage`).
- Release keystore: offline/secure backup only ([prod build](../../../docs/prod-build-deploy/README.md)).

## Data at rest

- All app data lives in Android **device-protected storage** so the local API can start after a restart before the PIN is entered ([keep-alive](../features/keep-alive.md)). It is encrypted, but with a device-bound key, not the user's PIN: protection against a stolen tablet relies on Android's file-based encryption and app sandbox, plus our own login, not on the screen lock.
- Keystore keys used by `flutter_secure_storage` MUST NOT require an unlocked device or user authentication, or the API cannot start before the first unlock.

## Pairing & access control

- Pair devices with an **expiring PIN/QR challenge** — "same Wi-Fi" is not trust.
- Tokens: random, high-entropy (`Random.secure()`), expiring, revocable (lost device).
- Roles: **TV = read-only**, doctor/laptop = control. Authorize and validate **every request on the tablet**, never trust the client.
- Pairing scoped to `clinicId + chamberId + deviceId`; session nonce prevents replay of old sessions.
- Auto-lock administrative screens; keep the public queue view visible.

## Network

- Local API over HTTPS where the architecture requires it; no "trust all certificates", no disabling hostname checks.
- Cleartext only if the architecture explicitly allows it on the controlled LAN, with `networkSecurityConfig` limiting scope.
- Validate and bound all input at the API boundary (size, type, range). Reject unknown commands.
- Rate-limit pairing attempts.

## Data minimization

- Collect the minimum. **No clinical notes in v1.**
- TV, receipts and public views show serial number only — no names, phones, diagnoses.
- Encrypt backups. Audit every sensitive action ([Data & offline](./data-offline.md)).
- Adding patient-identifying data later requires a privacy/security review first.

## Android hardening

- Minimal permissions; `android:exported="false"` by default; `allowBackup="false"` (or explicit backup rules excluding the DB/secrets).
- Release: R8/minify on, debug features off, **never ship debug-signed builds**.
- Don't log intents/extras containing tokens. Validate any incoming intent or deep link.

## Dependencies & supply chain

- Prefer few, maintained packages; review license and permissions each adds.
- Run `flutter pub outdated` periodically; patch known-vulnerable packages promptly.
