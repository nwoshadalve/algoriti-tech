# Web UI standards

Admin and doctor dashboard: used on **Android tablets** (primary), phones, laptops, and desktops on the clinic LAN.

## Styling order

1. **Tailwind CSS** utility classes in JSX (`className`).
2. **Theme tokens** in `src/index.css` via `@theme` (colors, fonts, breakpoints) — not random hex in components.
3. **Component CSS** (`ComponentName.css` next to the component) only when Tailwind cannot do the job (multi-step keyframes, print styles, third-party widgets).

**MUST NOT** add global CSS files for one-off screen styles.

## Brand (align with tablet app)

| Token | Value | Usage |
| --- | --- | --- |
| `brand-navy` | `#0B1F3A` | Headers, primary chrome |
| `brand-coral` | `#FF5C39` | Accents |
| `brand-coral-action` | `#D23F1E` | Primary buttons (white text, WCAG AA) |
| `brand-mist` | `#F4F6F9` | Page background (light) |

- Font: **Plus Jakarta Sans** from `public/fonts/` (bundled, offline).
- Logo: use shared `BrandLogo` when added; do not hotlink external logo URLs.

## Responsive breakpoints

Use Tailwind defaults unless overridden in `@theme`:

| Prefix | Min width | Typical device |
| --- | --- | --- |
| (none) | 0 | Phone portrait |
| `sm` | 640px | Large phone / small tablet |
| `md` | 768px | Tablet portrait |
| `lg` | 1024px | Tablet landscape / laptop |
| `xl` | 1280px | Desktop |

**Layout rules**

- **Mobile**: single column; primary nav in a bottom bar or hamburger drawer.
- **Tablet (`md+`)**: persistent side nav for admin/doctor sections; content max-width with comfortable padding.
- **Desktop (`lg+`)**: optional secondary column (detail panel); do not stretch forms edge-to-edge.

Touch targets ≥ **44×44 px** on tablet; add gap between destructive and primary actions.

## Components

- Presentational components: no `fetch`, no business rules — props in, events out.
- Extract **named components**, not inline render functions > ~15 lines.
- File ≤ **300 lines**; split by responsibility.
- Every async view handles **loading / empty / error / data**.
- **Loading:** use `BrandLoader`, `PagePreloader`, or `LoadingButton` from `core/ui` — same three-dot indicator as the tablet app (`BrandLoader`). Do not use CSS spinners or `CircularProgressIndicator`-style loaders.

## Pointer and cursor

- Clickable controls MUST show **`cursor: pointer`** (see [Web interaction](../principles/web-interaction.md)).
- Enforced globally in `web/src/index.css`; do not override with `cursor-default` on buttons or links.
- Disabled buttons: `cursor-not-allowed` + `disabled` / `aria-disabled`.
- Prefer `<button type="button">` or `<a href>` over clickable `<div>`s.

## UX

- Show **connection health** (API + live channel) in the shell.
- Serial numbers: large, high contrast, tabular figures (`font-variant-numeric: tabular-nums`).
- Destructive actions need a confirmation popup (see [Popups](#popups-modal)).
- Results of actions go in toasts (see [Toasts](#toasts)).
- Plain text button labels — no decorative arrow icons on primary actions.

## Localization (Bengali + English)

- All user-visible strings via i18n files (`core/i18n`) — no literals in components except dev-only.
- Support Bengali digits where product requires; dates/numbers via `Intl` APIs.
- Test both locales in component tests when strings affect layout (truncation).

## Accessibility

- Prefer `<button>`, `<nav>`, `<main>`, `<header>` over generic `<div>` clicks.
- `aria-current="page"` on active nav links.
- Focus visible: use `focus-visible:ring-2` utilities — never remove focus outlines without a replacement.

## Dark mode

- **SHOULD** support `prefers-color-scheme` with navy-based dark palette matching the tablet app; verify contrast in both modes before shipping UI changes.

## Toasts

Code: `src/core/toast/`. Principle: [Web interaction](../principles/web-interaction.md#feedback-toasts).

```tsx
const toast = useToast()
toast.success(t('settingsSaved'))
toast.error(t('errorGeneric'))
```

- `ToastProvider` is mounted above the router in `main.tsx` (and in `test/render.tsx`), so a toast raised just before navigation is still shown.
- Messages are **i18n keys** passed through `t()`, in both languages. Never pass raw API text or error codes.
- `MAX_TOASTS = 5`. Success lives 4.5 s, failure 8 s. Hover or focus pauses the countdown. These numbers live in `Toaster.tsx`; change them there only.
- Failures use `role="alert"`; the stack is an `aria-live="polite"` region labelled "Notifications".
- Placement: bottom right from `sm`, full width at the bottom on phones, above popups (`z-[80]`), light and dark styled with the brand tokens.
- Map API error codes to messages in one place per feature (`authErrors.ts`, `usersErrorMessages.ts`), then `toast.error(t(key))`. When the code belongs to a field, also set that field's error.
- Inline `NoticeBanner` is only for a page that failed to load.

## Popups (`Modal`)

Code: `src/core/ui/Modal.tsx`. Principle: [Web interaction](../principles/web-interaction.md#popups).

```tsx
{open ? (
  <Modal
    title={t('usersCreateTitle')}
    description={t('usersAddIntro')}
    size="lg"                 // sm | md | lg
    busy={saving}             // blocks closing while saving
    onClose={close}
    footer={
      <>
        <button type="button" className={secondaryButton} onClick={close}>{t('actionCancel')}</button>
        <LoadingButton type="submit" form="user-form" isLoading={saving}>{t('usersSave')}</LoadingButton>
      </>
    }
  >
    <form id="user-form" onSubmit={submit}>…</form>
  </Modal>
) : null}
```

- **Render it only while open.** Its fields start fresh each time, and focus restoring depends on mounting and unmounting.
- Put the submit button in the **footer** and tie it to the form with `form="id"`; the form itself sits in the scrolling body.
- Cancel is `secondaryButton` (`core/ui/buttonStyles.ts`); the primary action is a `LoadingButton`. On phones the footer stacks with the primary action first.
- From `sm` it is a centred card (max height `min(42rem, 100dvh − 3rem)`); on phones a sheet rising from the bottom (max height `100dvh − 0.75rem`). The body scrolls; header and footer never do.
- The popup is a portal on `document.body` at `z-[70]`; toasts (`z-[80]`) stay visible above it. Page scrolling is locked with `lockPageScroll()` (counted, so two popups cannot unlock each other).
- A popup **never opens another popup**.
- Needs no focus code from callers: it focuses the first field in the body, wraps Tab, closes on Escape / X / a press on the dark area, and gives focus back.

## Lists and tables

Code: `features/users/` is the model (`useUsersList`, `UsersTable`, `UsersToolbar`), with `core/ui/ScrollSentinel.tsx`, `SelectField.tsx` and `useDebouncedValue.ts`.

- One hook owns the query and the pages: the query is part of its key, a changed key starts again from page one, and a stale answer is ignored (the key is compared when it arrives).
- Sort by clicking a column heading (`aria-sort` on the `th`, toggling ascending and descending). Where the headings are hidden (phones) the same sort is offered as two menus.
- One `<table>` for every size: from `md` it is a table; below `md` the rows become labelled cards through utility classes (`max-md:`), so there is one markup to test and one to keep accessible.
- `ScrollSentinel` (an `IntersectionObserver` with a 240 px margin) asks for the next page; show *Load more* when `IntersectionObserver` is missing, *Try again* when a page failed.
- An edit replaces the row in place (`replace`), without fetching the list again; a create reloads from page one.
- The server contract: `GET /…?search=&role=&status=&sort=&dir=&limit=&cursor=` answering `{ items, total, nextCursor }`. Unknown values are a 400, `limit` is capped, ties are broken by id so a row never moves between pages.

## Pages that depend on the license

The menu and the routes follow what the tablet is licensed for (`GET /clinic`, `ClinicProvider`): the **Doctor** and **License** pages exist only for a doctor license. A route for a feature the clinic does not have redirects to the overview; never show a link that leads nowhere. Add the rule to `dashboardNav.ts` (`license: 'doctor'`) and guard the page itself.

## Icons and tooltips

Code: `core/ui/icons.tsx`, `core/ui/Tooltip.tsx`, `core/ui/IconButton.tsx`. Principle: [Web interaction](../principles/web-interaction.md#icons-and-tooltips).

```tsx
<IconButton
  label={t('usersEdit')}                         // tooltip, and the name unless ariaLabel is given
  ariaLabel={`${t('usersEdit')}: ${name}`}       // in a list: the action and who it is for
  icon={PencilIcon}
  labelOnSmall                                   // show the label next to the icon below md
  onClick={() => onEdit(user)}
/>
<IconButton label={t('chamberDelete')} icon={TrashIcon} tone="danger"
  disabled={onlyOne} disabledReason={t('chamberLastTip')} onClick={askToDelete} />
```

| Icon | Meaning | Component |
| --- | --- | --- |
| pencil | edit | `PencilIcon` |
| circle with a slash | disable | `BanIcon` |
| circle with a check | enable | `CheckCircleIcon` |
| trash | delete | `TrashIcon` |
| camera | upload or change a photo | `CameraIcon` |
| arrow turning back | discard changes | `UndoIcon` |
| plus | add (in front of the label of a primary button) | `PlusIcon` |
| X | close (popup, toast) | `CloseIcon` |

- Use `IconButton` for row and inline actions; use `Tooltip` directly to add a tooltip to any other icon-only control (theme switch, popup close, toast close).
- `Tooltip` renders into `document.body` (`z-[90]`, above popups and toasts), positioned from the control's box and kept inside the window, so a table or card with `overflow: hidden` cannot cut it off. Do not build tooltips with CSS `:hover` and absolute positioning.
- A tooltip wraps a control; for a **disabled** button put the pointer events on the wrapper (`Tooltip` does), because a disabled button gets none.
- Icon-only means the button has `aria-label`; `IconButton` makes that impossible to forget (`label` is required). New icons are drawn in `icons.tsx` with the shared `Icon` wrapper (24 × 24 viewBox, 1.8 stroke) and added to the table above.
- Tooltip texts are i18n keys in both languages, a few words, no full stops.
- **Primary actions are not icon-only**: page and popup actions (`Add user`, `Save changes`, `Delete chamber` in a confirmation) are labelled `LoadingButton`s, optionally with a leading `PlusIcon`.

## License and chambers

`/license` (admins, doctor license only) shows the license (type, doctors, issue and end dates, status) and the **chambers** it allows as a table with add, edit and delete (popups), up to `maxChambers`. It follows the same rules as the other pages: toasts for results, popups for forms and the delete confirmation, icon buttons with tooltips for row actions, cards on phones.

- **Add** is disabled when the license is full, with the reason in its tooltip; the tablet enforces the limit in the same transaction that adds the chamber, so two admins cannot both take the last place. If the tablet says the license is full anyway, the page looks again at the numbers.
- **Delete** asks first, names the chamber and says receptionists assigned to it lose it. The **last chamber cannot be deleted** (a doctor needs one); that button is disabled with the reason.
- All three fields (name, address, phone) are required, as on the tablet's setup screens.
