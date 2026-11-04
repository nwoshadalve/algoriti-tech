# Pairing

One-time binding of a physical TV to a **clinic + chamber** on the chamber LAN.

## Flow

1. TV app starts unpaired → **pairing** screen shows a short **PIN** (and optional QR when API supports it).
2. Staff on tablet opens device pairing, enters/confirms the PIN.
3. Tablet issues a **read-only session token** and chamber scope; TV stores token + base URL securely.
4. TV proceeds to [setup-audio](./setup-audio.md), then [display states](./display-states.md).

## Rules

- PIN MUST expire; rate-limit attempts on server.
- Stored identity: `clinicId`, `chamberId`, `deviceId`, API base URL, token.
- MUST NOT auto-accept wrong chamber — pairing is scoped ([security](../principles/security-privacy.md)).
- Re-pair clears old token before saving new credentials.

## Mock reference

[mock/tv-app/screens/pairing.html](../../../mock/tv-app/screens/pairing.html)

OpenAPI: follow tablet pairing endpoints when published; until then implement UI + local state stub only.
