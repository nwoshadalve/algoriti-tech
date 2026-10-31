/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
const STORAGE_KEY = 'algoritiq.pin'

/** What this browser keeps so the person can sign in with a PIN. The PIN itself is never kept. */
export type PinBrowser = {
  /** A secret from the tablet. The PIN works only together with it. */
  deviceToken: string
  /** Which entry of the person's list of PIN browsers this is. */
  deviceId: string
  username: string
  displayName: string
}

export function readPinBrowser(): PinBrowser | null {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    if (!raw) return null
    const value = JSON.parse(raw) as Partial<PinBrowser>
    if (
      typeof value.deviceToken === 'string' &&
      typeof value.deviceId === 'string' &&
      typeof value.username === 'string' &&
      typeof value.displayName === 'string'
    ) {
      return value as PinBrowser
    }
  } catch {
    // Unreadable: treated as none.
  }
  return null
}

export function savePinBrowser(browser: PinBrowser): void {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(browser))
  } catch {
    // Storage refused: the PIN simply will not be offered on this browser.
  }
}

export function clearPinBrowser(): void {
  try {
    localStorage.removeItem(STORAGE_KEY)
  } catch {
    // Nothing to remove.
  }
}

/** A short name for this browser, to recognise it in the list ("Chrome on Windows"). */
export function describeBrowser(): string {
  const agent = navigator.userAgent
  const browser = /Edg\//.test(agent)
    ? 'Edge'
    : /OPR\//.test(agent)
      ? 'Opera'
      : /Firefox\//.test(agent)
        ? 'Firefox'
        : /Chrome\//.test(agent)
          ? 'Chrome'
          : /Safari\//.test(agent)
            ? 'Safari'
            : 'Browser'
  const system = /Android/.test(agent)
    ? 'Android'
    : /iPhone|iPad/.test(agent)
      ? 'iOS'
      : /Windows/.test(agent)
        ? 'Windows'
        : /Mac OS/.test(agent)
          ? 'macOS'
          : /Linux/.test(agent)
            ? 'Linux'
            : ''
  return system ? `${browser} on ${system}` : browser
}
