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
- Sign in with the **username or the email** of the account (the same `username` field of `POST /auth/login`; a value with `@` is looked up as an email, and usernames never contain `@`). Both give the same `invalid_credentials` answer, and the same throttling, when wrong.
- Wrong guesses slow down per username *and* per client address (5 free tries, then **20 s**, doubling each time up to **24 h**).
- Sign-ins, failures, resets and registrations go into the hash-chained audit trail. Passwords, tokens and the activation key are never written to it.

## Where the token lives

| Client | Token | Why |
| --- | --- | --- |
| Tablet app | In memory, or secure storage when **Remember me** is checked | Closing the app asks for the password again unless remembered (30 days). Checked again when the app returns to the front, so a reset elsewhere signs it out. |
| Website | `sessionStorage` of the tab | Gone when the tab closes. The tablet serves the site with a strict Content-Security-Policy (own origin only), which is the main defence against injected scripts. |

An `HttpOnly` cookie would protect the token even from injected scripts, but it needs CSRF protection and does not suit the TV and other native clients that use bearer tokens. Revisit when the dashboard has more screens that show user-supplied text.

## Remember this browser

The sign-in form has **Remember this browser** (off by default).

| | Not remembered | Remembered |
| --- | --- | --- |
| Session on the tablet | 12 hours | 30 days (`remember: true` on `POST /auth/login`) |
| Token in the browser | `sessionStorage` (gone when the tab closes) | `localStorage` (survives restarts) |

Either way the tablet ends the session at once when the password is changed or reset or the account is disabled, and **Sign out** removes it from both places and revokes it on the tablet. The website then asks for the password again. Only tick it on your own device: a token in `localStorage` is readable by script on the page, which is why the tablet serves the site with a strict Content-Security-Policy (own origin only) and why a remembered session still expires.

## Sign in with a PIN

A faster way back in on a browser you use often.

- **Setting it** (Settings → *Quick sign-in PIN*, `POST /me/pin`): needs the account password, then **6 digits** (not one digit repeated, not a straight run like 123456 or 654321). The tablet returns a random secret, the **device token**, once. The browser keeps it in `localStorage` (never the PIN); the tablet keeps only a hash of it and an Argon2id hash of the PIN.
- **Signing in** (`POST /auth/pin/login`): the PIN is checked **together with** the device token. A PIN alone, or a token alone, opens nothing, and the PIN is useless on any other browser. The login page offers the PIN first on a browser that has one, with *Use password instead*. The session is a normal 12-hour one for the tab.
- **Lockout:** wrong PINs are slowed down per client and per address like passwords, and **3 wrong in a row remove that client's PIN**: the tablet answers `pin_locked`, the client forgets its token, and only the password works there until a new PIN is set (no “Use PIN” until then).
- **Sign-in screen:** the person chooses PIN or password; that choice is remembered on the client. After three wrong PINs the PIN option is removed until a new PIN is set.
- **Revoking:** each browser appears in the list in Settings (name, last used) and can be removed; the owner can do this from any signed-in browser. **Changing or resetting the password removes every PIN**, a disabled account's PINs stop working, and at most 5 browsers keep a PIN (the oldest is dropped).
- **Audit:** `auth.pin_set`, `auth.pin_login`, `auth.pin_failed`, `auth.pin_locked`, `auth.pin_removed`, `auth.pin_set_refused`; never the PIN or the token.
- **Why it is acceptable:** a 6-digit PIN has a million values, but it protects nothing without the 256-bit device token that never leaves the browser, and an attacker with the token gets five tries. Treat the browser holding the token like a saved password: only set a PIN on your own device.

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

## Changing the password while signed in

`POST /api/v1/me/password` with the current and the new password (Settings on the website). Wrong current passwords count towards the same slow-down as sign-in (per account), the new password follows the usual rules and must differ from the current one, and every other sign-in of the account ends while the caller's stays. Audited as `auth.password_changed` / `auth.password_change_refused`, never with a password.

## Screens

- **Tablet** (`features/access/presentation/`): after the admin guide the tablet shows the sign-in screen (`SignInGate`); *Forgot password?* opens the three-step reset (`ResetPasswordCard`, with a "Step 2 of 3" bar); the app's top bar has a sign-out button. Landscape uses two columns.
- **Admin on the tablet:** the tablet only has the receptionist screen for now. An admin who signs in sees `AdminTabletNotice` (the web address with QR code, and a note that admin sign-in on the tablet may come later). **OK** signs the admin out and the sign-in screen comes back. Closing the app does the same (`AppLifecycleState.detached`, because the engine outlives the screen), so an admin can never reach the receptionist screen. Receptionists go straight to the app.
- **Website** (`algoritiQ/web`): `/login`, `/forgot-password` (three steps, `src/features/auth/reset/`) and `/home` after the setup steps; see [web app](./web-app.md).

## Code

`lib/features/access/application/access_service.dart` (`login`, `resetPassword`, `authenticate`), `tablet_session.dart` (the tablet's own sign-in), `lib/api/local_api_server.dart` (routes) · web `src/features/auth/`.
Tests: `test/features/access/password_reset_test.dart`, `sign_in_test.dart`, `test/api/local_api_server_test.dart`; web `src/features/auth/auth.test.tsx`.

## Not yet

PIN sign-in for receptionists on the tablet app, more roles and users (the admin creates them from the website), **forgot password for other users** (they request a code, an admin generates a one-time code for them), changing a password from the tablet app, idle sign-out timer, `HttpOnly` cookie option.
