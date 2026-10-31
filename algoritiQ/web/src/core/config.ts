/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
/** Client-safe configuration (VITE_* only). */

const apiPath = import.meta.env.VITE_API_BASE_PATH ?? '/api/v1'

/**
 * API root for `fetch`. Production uses a relative path (SPA and API share the
 * tablet host). Local `npm run dev` defaults to `/api/v1` on the Vite dev server
 * (proxied to the tablet) so the browser stays same-origin and avoids CORS.
 *
 * Set `VITE_API_ORIGIN=https://algoritiq.local:8443` to call the tablet directly.
 */
export function resolveApiBase(): string {
  const configured = import.meta.env.VITE_API_ORIGIN as string | undefined
  const origin =
    configured !== undefined
      ? configured.trim() || null
      : import.meta.env.DEV
        ? null
        : null

  if (!origin) return apiPath
  const base = origin.replace(/\/$/, '')
  return `${base}${apiPath.startsWith('/') ? apiPath : `/${apiPath}`}`
}

export const config = {
  apiBasePath: resolveApiBase(),
  appName: 'AlgoritiQ',
} as const
