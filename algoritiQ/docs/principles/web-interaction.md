# Web interaction principles

Pointer and affordance rules for `algoritiQ/web`.

## Cursor

- Any **clickable** control MUST show `cursor: pointer` on hover (and when idle), so users can tell it is interactive.
- This includes: `<button>`, links (`<a href>`), icon buttons, language/theme toggles, pill segments, text links styled as buttons, and custom controls with `role="button"`.
- **Disabled** controls MUST use `cursor: not-allowed` (or stay non-interactive without pointer), not `pointer`.
- Non-clickable surfaces (cards, labels without `for`, static text) MUST NOT use `cursor: pointer`.

## Implementation

- Global defaults live in `web/src/index.css` (`@layer base`) so new screens inherit the rule automatically.
- When adding a custom clickable element (e.g. `div` + `onClick`), either use a semantic `<button>` / `<a>` or add `className="cursor-pointer"` and keyboard support — prefer semantic elements.

## Do not

- Rely on hover color alone without pointer on desktop/laptop.
- Set `cursor: default` on interactive components unless the control is truly read-only.

Standards detail: [../standards/web-ui.md](../standards/web-ui.md#pointer-and-cursor).
