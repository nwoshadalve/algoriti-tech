/** Client-safe configuration (VITE_* only). */

const apiPath = import.meta.env.VITE_API_BASE_PATH ?? '/api/v1'

/**
 * API root for `fetch`. Production uses a relative path (SPA and API share the
 * tablet host). Local `npm run dev` defaults to the tablet at
 * `https://algoritiq.local:8443` so calls do not go to `localhost:5173`.
 *
 * Override with `VITE_API_ORIGIN` (set to empty to use `/api/v1` + Vite proxy).
 */
export function resolveApiBase(): string {
  const configured = import.meta.env.VITE_API_ORIGIN as string | undefined
  const origin =
    configured !== undefined
      ? configured.trim() || null
      : import.meta.env.DEV
        ? 'https://algoritiq.local:8443'
        : null

  if (!origin) return apiPath
  const base = origin.replace(/\/$/, '')
  return `${base}${apiPath.startsWith('/') ? apiPath : `/${apiPath}`}`
}

export const config = {
  apiBasePath: resolveApiBase(),
  appName: 'AlgoritiQ',
} as const
