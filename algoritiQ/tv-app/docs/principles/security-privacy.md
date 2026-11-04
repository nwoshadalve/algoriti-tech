# 03 — Security & privacy

TV role: **read-only display + audio playback**. Treat the LAN as untrusted for authorization — the tablet validates every request.

## Secrets

- MUST NOT commit keystores, `key.properties`, `.env`, pairing tokens. Keep them in `.gitignore`.
- MUST NOT log session tokens, PINs, or announcement URLs with embedded credentials.
- Store session token, device id, and API base URL in **EncryptedSharedPreferences** or equivalent Keystore-backed storage.

## Pairing

- Pair with an **expiring PIN** shown on TV; staff confirms on tablet — "same Wi-Fi" is not trust ([app security](../../../app/docs/principles/security-privacy.md)).
- Pairing scoped to **`clinicId + chamberId + deviceId`**; session nonce prevents replay of old sessions.
- TV tokens are **read-only**; no queue commands from the TV app.

## Data minimization

- On-screen: **serial + queue type label only** — no names, phones, diagnoses.
- Optional **spoken** name may exist in tablet-prepared audio when the clinic enables it; the screen stays serial-only ([queue-product-decisions](../../../docs/features/queue-product-decisions.md)).
- MUST NOT cache patient-identifying fields from API responses if the contract ever exposes them to TV role — render only what the role allows.

## Network

- HTTPS to tablet host in production.
- `networkSecurityConfig` limits cleartext if ever allowed on LAN — document in ADR before enabling.
- Validate and bound all parsed JSON at the data layer.

## Android hardening

- Minimal permissions: `INTERNET`, `ACCESS_NETWORK_STATE`; no Bluetooth (printer is tablet-only).
- `android:exported="false"` for components except the leanback launcher activity.
- `allowBackup="false"` or backup rules excluding secrets.
- Release: R8/minify on; never ship debug-signed builds to clinics.

## Dependencies

- Prefer maintained AndroidX/Google libraries; review permissions each dependency adds.
