/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
const STORAGE_KEY = 'algoritiq.session'

type StoredSession = { token: string; expiresAt: string }

/**
 * Where the sign-in token lives depends on whether the person asked to be
 * remembered:
 *
 * - **Not remembered**: `sessionStorage`. It is gone when the tab closes, and a
 *   stolen laptop is not signed in tomorrow. The tablet also ends it after 12
 *   hours.
 * - **Remember this browser**: `localStorage`, so it survives closing the
 *   browser. The tablet ends it after 30 days.
 *
 * Either way the tablet ends it at once when the password is changed or reset,
 * or the account is disabled, and signing out removes it from both places.
 */
export function saveSession(token: string, expiresAt: string, remember = false): void {
  const value = JSON.stringify({ token, expiresAt } satisfies StoredSession)
  clearSession()
  try {
    ;(remember ? localStorage : sessionStorage).setItem(STORAGE_KEY, value)
  } catch {
    // Storage refused (private mode, full): fall back to this tab only.
    sessionStorage.setItem(STORAGE_KEY, value)
  }
}

function readFrom(storage: Storage, now: Date): string | null {
  let raw: string | null
  try {
    raw = storage.getItem(STORAGE_KEY)
  } catch {
    return null
  }
  if (!raw) return null
  try {
    const session = JSON.parse(raw) as StoredSession
    if (typeof session.token === 'string' && new Date(session.expiresAt) > now) return session.token
  } catch {
    // Unreadable: treated as expired below.
  }
  try {
    storage.removeItem(STORAGE_KEY)
  } catch {
    // Nothing more to do.
  }
  return null
}

export function readSession(now: Date = new Date()): string | null {
  return readFrom(sessionStorage, now) ?? readFrom(localStorage, now)
}

/** Whether the saved sign-in is a remembered one (kept across browser restarts). */
export function isSessionRemembered(): boolean {
  try {
    return localStorage.getItem(STORAGE_KEY) !== null
  } catch {
    return false
  }
}

export function clearSession(): void {
  sessionStorage.removeItem(STORAGE_KEY)
  try {
    localStorage.removeItem(STORAGE_KEY)
  } catch {
    // Storage is not available: nothing to remove.
  }
}
