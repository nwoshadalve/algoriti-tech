# Security & API client principles

## Transport

- Production MUST use **HTTPS** to the tablet host (self-signed or clinic CA as provisioned by the tablet app).
- MUST NOT disable TLS validation in production code. Dev-only overrides live in `.env.development` and MUST NOT ship in builds.

## Authentication & pairing

- Follow the Backend API contract for login, session tokens, and device pairing — do not invent cookie names or headers.
- **MUST NOT** store long-lived secrets in `localStorage` unless the API spec requires it; prefer httpOnly cookies when the API provides them.
- **MUST NOT** log tokens, passwords, or patient-identifying fields.

## Data minimization

- Public queue views show **serial numbers only** — no patient names or phone numbers on shared displays.
- Render only fields the API returns for the authenticated role; do not cache extra PII in IndexedDB without an approved design.

## Frontend hygiene (OWASP-aligned)

- Treat all API text as untrusted when rendering HTML — use React text nodes, not `dangerouslySetInnerHTML`, unless sanitized.
- Validate forms on the client for UX; **authorization and validation MUST be enforced on the server**.
- Keep dependencies updated; run `npm audit` before release branches.

## CORS and origins

- The app is same-origin with the API when served by the tablet host. Do not hardcode absolute LAN IPs in source — use relative URLs and environment config for dev proxies only.

## Remembered sign-in and PIN

- **Remember this browser** is opt-in, off by default, and says to use it only on one's own device. A remembered session is a **bearer token in `localStorage`**, so it MUST be bounded (30 days), revocable by the server at once (password change or reset, account disabled, sign-out), and protected by the strict Content-Security-Policy. Without it the token stays in `sessionStorage` and ends with the tab.
- Sign-out MUST remove the token from **both** storages and revoke it on the server.
- A **PIN** is a convenience, never a replacement for the password. It MUST be tied to **one browser** by a server-issued secret (the PIN means nothing without it), stored only as hashes on the server, limited to a few wrong tries in a row (then the PIN is removed), slowed down per browser and per address, and refused for weak values (one repeated digit, straight runs).
- Setting a PIN MUST need the **password**, so a borrowed, unlocked browser cannot add one. A password change or reset MUST remove every PIN.
- The PIN and the device secret MUST NOT be logged, put in URLs, or written to the audit trail.
- The browser MUST forget its PIN secret as soon as the server says it is gone (`pin_unavailable`, `pin_locked`), and never retry it silently.
