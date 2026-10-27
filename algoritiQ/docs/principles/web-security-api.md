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
