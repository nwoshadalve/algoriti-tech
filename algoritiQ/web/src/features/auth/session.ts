const STORAGE_KEY = 'algoritiq.session'

type StoredSession = { token: string; expiresAt: string }

/**
 * The sign-in token lives in `sessionStorage`: it is gone when the tab closes,
 * and a stolen laptop is not signed in tomorrow. The server also ends it after
 * 12 hours, or at once when the password is reset.
 */
export function saveSession(token: string, expiresAt: string): void {
  sessionStorage.setItem(STORAGE_KEY, JSON.stringify({ token, expiresAt } satisfies StoredSession))
}

export function readSession(now: Date = new Date()): string | null {
  const raw = sessionStorage.getItem(STORAGE_KEY)
  if (!raw) return null
  try {
    const session = JSON.parse(raw) as StoredSession
    if (typeof session.token !== 'string' || !(new Date(session.expiresAt) > now)) {
      clearSession()
      return null
    }
    return session.token
  } catch {
    clearSession()
    return null
  }
}

export function clearSession(): void {
  sessionStorage.removeItem(STORAGE_KEY)
}
