# Admin access and the local API

How the first admin gets into the system. The tablet hosts the backend; the web app does the setup.

## Flow

```text
Activate ──▶ First-time setup ──▶ Keep the tablet ready ──▶ Admin guide ──▶ (web) register + sign in ──▶ Home
```

The HTTPS server starts as soon as the device is activated ([keep-alive](./keep-alive.md)). The **admin guide** (address, QR, claim code) appears only after setup and the readiness checklist are done.

1. After activation the tablet shows the **admin guide**: the web address (`algoritiq.local` when the tablet has [claimed its name](./local-name.md), else the IP; always the IP in the QR code), a **claim code**, and the server status.
2. On a laptop or phone on the same Wi-Fi, the admin opens the address and enters the claim code.
3. The admin registers (username + password) and signs in. The tablet moves on by itself.

## Claim code

- 8 characters (e.g. `7K4M-9XQ2`), shown only on the tablet screen.
- Expires after **15 minutes**, works **once**, locked after **5 wrong tries**. A new code appears automatically.
- Held in memory only: restarting the app shows a new code.
- Never returned by the API. Registration closes for good after the first admin (`409`).

## Local API (`/api/v1`)

HTTPS on port **8443**, self-signed certificate (the browser warns once; the tablet shows the fingerprint to compare). Contract: [openapi.yaml](../../../docs/api/openapi.yaml).

| Endpoint | Purpose |
| --- | --- |
| `GET /health` | Is the server up |
| `GET /setup/status` | Admin registered? Claim code needed? |
| `POST /setup/admin` | Register the first admin (claim code) |
| `POST /auth/login`, `POST /auth/logout`, `GET /me` | Sign in, out, who am I |

Rules: JSON only, bearer tokens (no cookies), 16 KB body limit, errors are `{error:{code,message}}`, nothing cached, no internals in errors.

## Passwords and tokens

- Passwords: at least **10** characters (max 128), not containing the username. Username `a-z 0-9 . _ -`, 3–32.
- Stored as **Argon2id** hashes with a random salt, mixed with a device secret kept in the Android Keystore. The password is never stored or logged.
- Sign-in tokens are random, last **12 hours**, and only their hash is stored. Logout revokes them.
- Guessing is slowed: after 5 failures a name (and a client address) waits 30 s, doubling up to 15 min (`429` + `Retry-After`).

## Audit trail

Append-only and **hash-chained**: each entry includes the previous entry's hash, so an edit or deletion is detectable. Recorded so far: admin registered, claim code refused, sign-in, failed sign-in, sign-out. No passwords or tokens, ever.

## Code

`lib/features/access/` (accounts, claim code, throttle, audit, guide screen) · `lib/api/` (HTTPS identity, server, host) · `docs/api/openapi.yaml`.
Tests: `test/features/access/`, `test/api/`.

## Not yet

Creating more users and roles (doctor, receptionist), password reset, serving the React build from the tablet, sign-in on the tablet itself.
