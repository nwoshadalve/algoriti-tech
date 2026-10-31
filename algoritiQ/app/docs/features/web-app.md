# The web app on the tablet

The React app in `algoritiQ/web` is built, copied into the tablet app, and served by the tablet's own server. Open `https://algoritiq.local:8443` (see [local name](./local-name.md)) from any device on the clinic Wi-Fi.

## What is served where

| Path | What |
| --- | --- |
| `/api/v1/...` | The backend API ([admin access](./admin-access.md), [authentication](./authentication.md)) |
| `/`, `/register`, `/login`, `/forgot-password`, `/home` | The web app's pages (all answered with `index.html`, so a reload or a typed link works) |
| `/assets/...`, icons, fonts | Files of the build; a missing file is a plain `404`, never the app |

Only `GET` and `HEAD` outside `/api/`. Hashed files under `/assets/` are cached for a year; everything else is checked again on each visit, so a new build shows at once.

Every page comes with browser protections: a Content-Security-Policy (scripts, styles, images, fonts and requests only from the tablet itself, no plugins, no framing), `X-Frame-Options: DENY`, `nosniff` and `Referrer-Policy: no-referrer`.

## Flow for the admin

1. After activation and setup, the tablet shows the **admin guide** (address, QR code, claim code).
2. On a laptop or phone the admin opens the address, enters the claim code, and registers.
3. The tablet leaves the guide by itself and shows its **sign-in** screen; the website shows **Sign in** (with *Forgot password?*). After signing in the website shows the dashboard (below).

## The dashboard

Desktop (width 1024 px and up): a fixed full-height sidebar on the left, a fixed top bar and the page beside it. Phones and tablets: a top bar (menu button, logo, connection dot) and the sidebar as a drawer.

At the bottom of the sidebar is the signed-in person: a round picture (or the first letter of their first name), their name and their role. Clicking it opens **Settings** and **Sign out**. There is no sign-out button in the navigation.

The **theme** and **language** switches are in the fixed top bar on desktop and tablet (the bar also shows the connection status on desktop). On phones (under 768 px) they sit in the drawer just above the user.

**Sign-in options.** The login page has **Remember this browser** (a 30-day session kept across restarts) and, on a browser where a PIN was set, a **PIN** box that signs in by itself at the sixth digit, with *Use password instead*. See [authentication](./authentication.md).

**Settings** (`/settings`): the profile photo, personal information, password and **quick sign-in PIN**.

- **Photo.** Choosing a picture opens a round crop window: drag or swipe to move the picture, pinch, scroll or use the slider to zoom, arrow keys to nudge (`+`/`-` zoom). The picture always covers the window, so no empty edge is saved. Save crops the chosen square, shrinks it to 256 px in the browser and uploads it. It is kept on the tablet and fetched with the token (the page's CSP allows `blob:` images). Remove deletes it.
- **Personal information.** First name, last name, email and phone. The username cannot be changed.
- **Quick sign-in PIN.** Lists the browsers that have a PIN (name, last used, *This browser*), with a trash icon to remove each. *Set PIN for this browser* / *Change PIN* opens a popup: password, then the 6-digit PIN twice. The browser keeps the tablet's secret for it (`src/features/auth/pinDevice.ts`); changing the password removes every PIN.
- **Password.** The Password block has a **Change password** button that opens the form in a popup (current password, new password, confirm). The popup closes on success; on a refusal it stays open with the field marked. The tablet slows down wrong current passwords, and ends the account's other sign-ins (this tab stays signed in). See `PATCH /me` and `/me/photo` in the [API](../../../docs/api/openapi.yaml).

## Users

`/users` (admins only) is a **table** of everyone who can sign in: name (with email), username, role, status, date added, and *Edit* / *Disable* (or *Enable*) per row.

- **Server side.** Search, the role and status filters, sort and paging are all done by the tablet (`GET /users?search&role&status&sort&dir&limit&cursor`, see the [API](../../../docs/api/openapi.yaml)). The browser only holds the pages it has scrolled through. Typing waits 300 ms; a new query starts again from page one.
- **Scrolling.** The next page loads as the end of the table comes near. *Load more* appears where the browser cannot watch scrolling, *Try again* when a page failed.
- **Sorting.** Click a column heading (again for the other direction). On phones the table turns into one card per person and the sort is offered as two menus.
- **Not yourself.** The signed-in admin does not appear in their own list (the tablet leaves the account out of the rows and the total). Their details are in Settings.
- **Icons, not words.** Each row has icon buttons with tooltips: pencil (edit), circle-with-slash (disable) or check-circle (enable). On phones, where there is no hover, each card shows the label next to the icon.
- **Add user** opens a popup: role (*Receptionist* or *Administrator*), name, email, username, password twice, and for a receptionist the chambers (or doctors, on a chamber license) they may work with. An administrator has no chambers. Created users can sign in at once.
- **Edit** opens the same popup with the details, without username, role or password. A person's role does not change.
- **Disable** asks first; it ends the person's sign-ins. **Enable** acts at once. Admins cannot disable themselves, and the last active admin cannot be disabled (the tablet refuses with `cannot_disable_self` / `last_admin`).
- Accounts are never deleted: disabling keeps the history of who did what.

## License page

`/license` (admins, doctor license only): the license (type, doctors, issued, valid until, status) and the **chambers** it allows, shown as a table with `x of N used` and a bar. Chambers are added, edited and deleted in popups, up to the number the license allows (`maxChambers`).

- **Add chamber** is disabled when the license is full, with the reason in its tooltip. The tablet checks the limit when it saves, so it holds even if two people add at once.
- **Edit** and **Delete** are icon buttons (pencil, trash) with tooltips. All of name, address and phone are required, as on the tablet's own setup screens.
- **Delete** asks first and says receptionists assigned to the chamber lose it. The **last chamber cannot be deleted**: its delete icon is disabled, with the reason in the tooltip.
- A chamber license (one chamber, several doctors) has no such page; its screens come later together with diagnostic licenses.

## Queue configuration

`/config/queue` (admins only): choose a **chamber**, then add, edit, enable, or disable **that chamber's** queue types. New clinics start with three inherited template types (Regular, Report, Dressing and their default ranges — see [queue-configuration.md](../../../docs/features/queue-configuration.md)). The first save for a chamber creates a **chamber override**; other chambers are not changed. The page shows **Uses clinic defaults** or **Customized for this chamber**. Saves call `PATCH /queue/chambers/{chamberId}` with a `types` body, not clinic-wide defaults. Automatic stop time can differ per chamber via the policy editor. The web UI does not offer “use clinic defaults again”.

## Doctor page

Only for a clinic licensed for **one doctor** (`GET /clinic` says `doctor`); the menu item and the `/doctor` route do not exist for a chamber license. An admin edits the doctor's name with title, degrees (one line, separated by commas, in the order to show), specialty, designation, workplace, registration number, and the photo (same crop popup as the profile photo; upload, change and remove are icon buttons with tooltips, and so is *discard changes*). The details are what the waiting-room screen shows. Diagnostic licenses will get their own pages later.

## Popups: `Modal`

`src/core/ui/Modal.tsx` is the one popup to use. It has a **fixed header** (title, optional description, close button), a **body that scrolls** by itself when it is taller than the space, and an optional **fixed footer** for the buttons (put a form's submit button there with the `form="id"` attribute). From 640 px up it is a centred card; on phones it is a sheet rising from the bottom. Light and dark themes follow the app.

```tsx
{open ? (
  <Modal title="..." description="..." onClose={close} busy={saving}
         footer={<><button>Cancel</button><LoadingButton form="f" type="submit">Save</LoadingButton></>}>
    <form id="f">...</form>
  </Modal>
) : null}
```

Render it only while open (its fields start fresh each time). Escape, the X button and a press on the dark area close it; `busy` blocks all three while something is saving. Focus moves to the first field, stays inside, and returns to the opener. Page scrolling behind it is locked. The photo crop window and the password form both use it.

## Messages: toasts

Whether a form action worked or failed is shown in a **toast** (`src/core/toast/`), not in a banner inside the form: saving the profile, changing the photo or password, signing in, the password reset, the setup steps and the user forms. A toast slides in at the bottom right (full width at the bottom on phones) in the light or dark theme, has a close button and a bar that counts its time down (4.5 s for success, 8 s for failure). Pointer over it or keyboard focus on it pauses the countdown.

- **At most 5** are shown (`MAX_TOASTS`); a sixth pushes the oldest off. Raising the same message again refreshes the one on screen instead of stacking a copy.
- Failures use `role="alert"`; the stack is an `aria-live="polite"` region.
- **Field mistakes stay on the field** (the red text under it). When the tablet refuses a value (wrong current password, email already used), the field is marked and the same words appear in a toast.
- Use it with `const toast = useToast(); toast.success(t('...'))` / `toast.error(...)`. `ToastProvider` sits above the router, so a toast raised just before a page change (for example "Password changed" on the way to sign-in) is still shown.
- A save stopped by the form's own checks (an empty name, passwords that differ) also raises a toast ("Check the highlighted fields..."), as well as marking the fields.
- A page that cannot load at all (for example the user list) still shows its message in the page, since there is nothing else to show.

## Update the web app on the tablet

Steps, checks and troubleshooting (including the blank-page incident) are in [Build the web app and deploy it on the tablet](../web-build-and-deploy.md). In short: `npm run build` in `algoritiQ/web`, `python tool/bundle_web.py` in `algoritiQ/app`, then build and install the app. `app/assets/web/` is committed, so the tablet app builds without Node.

## Limits

- The certificate is the tablet's own, so the browser warns once per device, and **a service worker cannot register** on it: the site's offline shell (PWA) works only once the browser trusts the certificate. The site itself needs the tablet anyway.
- No custom domain: `algoritiq.local:8443` (Android apps cannot use ports below 1024, so the port stays).

## Code

`lib/api/web_site.dart` (paths, types, caching, headers) · `lib/api/local_api_server.dart` (routing) · `tool/bundle_web.py` · web: `src/app/dashboard/` (shell, user menu), `src/core/toast/` (toaster), `src/features/settings/` (`PhotoCropper`, `cropMath`, `ChangePasswordCard`), `src/features/home/`.
Tests: `test/api/web_site_test.dart`.
