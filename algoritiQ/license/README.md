# AlgoritiQ licensing — how to generate a license

Offline, device-bound activation keys. The customer's app shows a **device code**; you (or an AI agent) turn it into an **activation key** with one Python command; the customer types it in. No internet needed on the clinic side.

```text
customer app ── device code ──▶ you / agent ── license_tool.py issue ──▶ activation key ──▶ customer app
```

## Quick start (any machine)

You need three things: this repo, Python 3.9+, and the **signing key** (`key-1.json`).

```bash
cd algoritiQ/license
pip install -r requirements.txt            # installs "cryptography"

# Point the tool at the signing key (pick one):
export ALGORITIQ_LICENSE_KEY="$(cat /path/to/key-1.json)"    # PowerShell: $env:ALGORITIQ_LICENSE_KEY = Get-Content key-1.json -Raw
#   or pass  --key /path/to/key-1.json  to each command

python license_tool.py issue \
  --type doctor --chambers 2 \
  --device ABCDE-12344 \
  --customer "Dr Example" \
  --expires 2027-10-27
```

Output: the **activation key** (the long `XXXXX-XXXXX-...` text). Send it to the customer.

## Choose the license type

| Customer buys | Command flags | Meaning |
| --- | --- | --- |
| A doctor (works in several chambers) | `--type doctor --chambers N` | 1 doctor, up to N chambers |
| A chamber/clinic (several doctors) | `--type chamber --doctors N` | 1 chamber, up to N doctors |

Expiry: `--expires YYYY-MM-DD` (last valid day) **or** `--perpetual`. After expiry the app allows 14 days of grace, then asks for a renewed key. Prefer yearly licenses — offline keys can't be revoked.

## Step by step

1. Customer installs the app → the **activation screen** shows a device code like `Q00N4-5ZQG8` (tap the copy button to send it).
2. You run the `issue` command above with that code as `--device`.
3. Send the activation key back (WhatsApp is fine). The customer pastes it and taps **Activate**.
4. Add the **ledger row** to your records (the tool also appends it to `license/ledger.csv`).

**Renewal / new device:** run `issue` again (new key for the same or new device code). A new device always needs a new key.

## For an AI agent

If you are an AI agent asked to issue a license, do exactly this:

1. Make sure the signing key is available **without printing it**: file path for `--key`, or the `ALGORITIQ_LICENSE_KEY` environment variable.
2. `pip install -r requirements.txt` (once).
3. Run, with values from the request (device code, type, count, expiry, customer):

   ```bash
   python license_tool.py issue --type <doctor|chamber> --device <CODE> \
     [--chambers N | --doctors N] (--expires YYYY-MM-DD | --perpetual) \
     --customer "<name>" --json
   ```

4. Reply with `activationKey` and `expires`, plus `licenseId` and `ledgerRow` for the owner's records.
5. Never print, log, commit or paste the signing key. If the device code is rejected, ask the customer to re-send it (typos are detected).
6. Sanity check a key: `python license_tool.py inspect <activation-key>` (add `--key`/env var to verify the signature).

## No PC? Use GitHub

GitHub **Actions → Issue AlgoritiQ license → Run workflow** (browser or the GitHub mobile app). Fill in type, device code, count, expiry, customer. The key appears in the run **summary**. One-time setup: repo **Settings → Secrets and variables → Actions → New repository secret** `ALGORITIQ_LICENSE_KEY` = full contents of `key-1.json`. Keep the repo **private**.

## The signing key

| | |
| --- | --- |
| File | `keys/key-1.json` — **secret**, gitignored |
| Create (once) | `python license_tool.py keygen --key-id 1` |
| Back up | Password manager. **If lost, you can't issue licenses for that key.** |
| Public half | Embedded in the app: `app/lib/features/licensing/data/license_public_keys.dart` |
| Leaked? | `keygen --key-id 2`, add its public key to the app, stop using key 1. Existing licenses keep working while the app still trusts key 1. |

## Commands

| Command | Purpose |
| --- | --- |
| `keygen [--key-id N] [--dir keys]` | Create a signing key pair (refuses to overwrite). |
| `issue ...` | Issue an activation key. Extras: `--ledger FILE`, `--no-ledger`, `--json`. |
| `inspect <key> [--key FILE]` | Show a key's contents and (with a signing key) check its signature. |

Errors print `Error: ...` and exit with code 1 (e.g. mistyped device code, wrong limits for the type, missing signing key).

## Security notes

- A leaked activation key only works on the device it was issued for.
- Anyone with the signing key can issue licenses — treat it like a password.
- No client-side check is uncrackable; this deters casual copying and ties installs to devices you approved.

## Tests

```bash
python -m unittest discover -s tests -v
```

`tests/fixtures/python_license_vector.json` is a shared test vector: these tests pin the exact key this script produces, and the app's Dart tests (`app/test/features/licensing/python_issuer_compat_test.dart`) verify the same key. If you change the key format, update **both** sides.
