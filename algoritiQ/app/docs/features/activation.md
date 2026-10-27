# Activation

Binds the app to **one tablet** with an offline license key. No internet needed.

## Flow

1. App shows the **device code** (e.g. `Q00N4-5ZQG8`). Tap copy.
2. Send it to the provider. They issue an **activation key** ([license/README.md](../../../license/README.md)).
3. Paste or type the key, then **Activate** (or the keyboard Done key).
4. Valid key → app opens. Invalid → a clear message, try again.

```text
device code ──▶ provider ──▶ activation key ──▶ app unlocked
```

## License

| Type | Covers |
| --- | --- |
| Doctor | 1 doctor, up to N chambers |
| Chamber | 1 chamber, up to N doctors |

- Valid until an expiry date, or perpetual.
- After expiry: **14 days grace** with a warning, then the activation screen returns.
- No revocation (offline), so prefer yearly licenses.

## Rules

- The key is signed; the app checks it **offline** with the public key in `license_public_keys.dart`.
- A key works only on the device it was issued for.
- Input is forgiving: case, spaces, dashes and line breaks are ignored.
- Checked **at app start only**, never in the middle of a clinic session.
- Stored in `SharedPreferences` (`license.token`).

## Errors (shown in the active language)

| Problem | Meaning |
| --- | --- |
| Not a key | Wrong format |
| Unknown key | This app version doesn't know the signing key |
| Not valid | Signature check failed |
| Different device | Issued for another tablet |
| Expired | Past expiry and grace; enter a renewed key |

## Code

`lib/features/licensing/` — `domain` (key + verifier), `data` (device id, storage), `application` (controller), `presentation` (activation page).
Tests: `test/features/licensing/`.
