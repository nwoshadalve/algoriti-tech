# Authentication

How people sign in to the tablet and to the website, and how a forgotten password is recovered. All of it works offline.

## Decision: server-side session tokens, not JWT

Sign-in returns a random token (256 bits). The tablet stores only its **SHA-256 hash**, the account and an expiry (12 hours). Every request sends the token as `Authorization: Bearer ...`; the tablet looks it up.

Why not JWT:

- **Revocation matters here.** Logout, a password reset or a disabled account must end sign-ins *now*, and the audit trail must say so. A JWT stays valid until it expires unless the server keeps a block list, which makes it a session anyway.
- **One server, no benefit.** JWT's strength is checking a signature without asking the issuer (many services, one login). Here the tablet is the only issuer and verifier.
- **Less to get wrong.** No signing key to protect and rotate on a tablet, no algorithm or claim pitfalls.

Stolen database: the stored hashes cannot be turned back into tokens. Stolen token: ends at logout, reset or after 12 hours.

## Passwords

- Argon2id with a per-password salt and a pepper held in the Android Keystore (`flutter_secure_storage`). At least 10 characters, at most 128, not containing the username.
- Wrong guesses slow down per username *and* per client address (5 free tries, then 30 s doubling to 15 min).
- Sign-ins, failures, resets and registrations go into the hash-chained audit trail. Passwords, tokens and the activation key are never written to it.

## Where the token lives

| Client | Token | Why |
| --- | --- | --- |
| Tablet app | In memory only | Closing the app or restarting the tablet asks for the password again. Checked again when the app returns to the front, so a reset elsewhere signs it out. |
| Website | `sessionStorage` of the tab | Gone when the tab closes. The tablet serves the site with a strict Content-Security-Policy (own origin only), which is the main defence against injected scripts. |

An `HttpOnly` cookie would protect the token even from injected scripts, but it needs CSRF protection and does not suit the TV and other native clients that use bearer tokens. Revisit when the dashboard has more screens that show user-supplied text.

## Forgotten password (admins)

Three steps, on the website and on the tablet:

1. **Username.** Nothing is sent to the tablet, so this step never says whether the account exists.
2. **Activation key.** `POST /api/v1/auth/password/reset/start` with the username and the **activation key** this tablet was activated with. Whoever holds that key (the clinic owner or the vendor) can recover an admin, with no internet and no email. If the key is right the tablet returns a **one-time reset ticket**; nothing changes yet.
3. **New password.** `POST /api/v1/auth/password/reset` with the ticket and the new password.

Rules:

- The key is compared with the one stored on the tablet; case, spaces and dashes do not matter. A wrong key and an unknown username give the same answer (`reset_refused`), so the website cannot be used to find out which accounts exist.
- The ticket is random (256 bits), kept in the tablet's memory only (hash, not the ticket), valid for **10 minutes**, usable **once**, and replaced by a newer ticket for the same account. A refused password keeps it, so another can be tried until it expires.
- Wrong keys and wrong tickets are slowed down per client and for the whole tablet (5 free tries, then waits that double).
- A successful reset ends every sign-in of the account, lifts any lockout on it, and is audited (`auth.reset_key_accepted`, `auth.password_reset`, `auth.reset_refused`). Keys, tickets and passwords are never written to the audit trail.

Later: other users (doctor, receptionist) will ask an admin for a one-time reset code instead of using the key; see "Not yet".

## Screens

- **Tablet** (`features/access/presentation/`): after the admin guide the tablet shows the sign-in screen (`SignInGate`); *Forgot password?* opens the three-step reset (`ResetPasswordCard`, with a "Step 2 of 3" bar); the app's top bar has a sign-out button. Landscape uses two columns.
- **Website** (`algoritiQ/web`): `/login`, `/forgot-password` (three steps, `src/features/auth/reset/`) and `/home` after the setup steps; see [web app](./web-app.md).

## Code

`lib/features/access/application/access_service.dart` (`login`, `resetPassword`, `authenticate`), `tablet_session.dart` (the tablet's own sign-in), `lib/api/local_api_server.dart` (routes) · web `src/features/auth/`.
Tests: `test/features/access/password_reset_test.dart`, `sign_in_test.dart`, `test/api/local_api_server_test.dart`; web `src/features/auth/auth.test.tsx`.

## Not yet

More roles and users (the admin creates them from the website), **forgot password for other users** (they request a code, an admin generates a one-time code for them), changing a password while signed in, idle sign-out timer, `HttpOnly` cookie option.
