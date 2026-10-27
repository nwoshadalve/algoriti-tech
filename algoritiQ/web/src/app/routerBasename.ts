/**
 * The path the app is served under, for the router.
 *
 * Vite's `base` stays relative (`./`) so asset files resolve wherever the app
 * is hosted, but a router `basename` must be an absolute path: `./` made it
 * `/./`, matched no page, and the production build showed a blank screen.
 * Resolve the base against the page's own address instead (`/` when the tablet
 * serves the app at its root).
 */
export function routerBasename(baseUrl: string, documentBaseUri: string): string {
  const path = new URL(baseUrl, documentBaseUri).pathname
  return path.length > 1 ? path.replace(/\/$/, '') : '/'
}
