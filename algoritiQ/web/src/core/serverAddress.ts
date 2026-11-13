/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
const STORAGE_KEY = 'algoritiq.serverAddress'
const DEFAULT_PORT = '8443'

/**
 * Turns what a person typed (an IP address or a name, with or without a port
 * or `https://`) into the tablet's origin, or `null` when it is not an address.
 * Always https: the dashboard is served over https and browsers block plain
 * http calls from it.
 */
export function parseServerAddress(input: string): string | null {
  const text = input.trim()
  if (!text) return null
  const withScheme = /^[a-z][a-z0-9+.-]*:\/\//i.test(text) ? text : `https://${text}`
  let url: URL
  try {
    url = new URL(withScheme)
  } catch {
    return null
  }
  if (url.protocol !== 'https:' && url.protocol !== 'http:') return null
  if (!url.hostname || url.username || url.password) return null
  const host = url.hostname
  const isIpv4 = /^\d{1,3}(\.\d{1,3}){3}$/.test(host)
  if (isIpv4 && host.split('.').some((part) => Number(part) > 255)) return null
  // A bare word is not an address: names need a dot (algoritiq.local).
  if (!isIpv4 && host !== 'localhost' && !host.includes('.')) return null
  return `https://${host}:${url.port || DEFAULT_PORT}`
}

/** The saved tablet origin, or `null` when this browser uses the page's own origin. */
export function readServerAddress(): string | null {
  try {
    return localStorage.getItem(STORAGE_KEY)
  } catch {
    return null
  }
}

export function saveServerAddress(origin: string): void {
  try {
    localStorage.setItem(STORAGE_KEY, origin)
  } catch {
    // Storage refused: nothing is remembered.
  }
}

export function clearServerAddress(): void {
  try {
    localStorage.removeItem(STORAGE_KEY)
  } catch {
    // Nothing more to do.
  }
}
