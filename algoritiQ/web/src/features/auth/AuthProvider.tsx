import { useCallback, useEffect, useMemo, useState, type ReactNode } from 'react'
import { getMe, login, logout } from '@/core/api/auth'
import { AuthContext, type AuthState } from '@/features/auth/authContext'
import { clearSession, readSession, saveSession } from '@/features/auth/session'

/** Knows who is signed in. Restores a sign-in from this tab when the page reloads. */
export function AuthProvider({ children }: { children: ReactNode }) {
  // Nothing saved in this tab: signed out at once, no waiting.
  const [state, setState] = useState<AuthState>(() =>
    readSession() ? { status: 'loading' } : { status: 'signedOut' },
  )

  useEffect(() => {
    const token = readSession()
    if (!token) return
    let cancelled = false
    void getMe(token).then(
      (account) => {
        if (!cancelled) setState({ status: 'signedIn', account })
      },
      () => {
        // Ended on the tablet (expired, signed out, password reset).
        clearSession()
        if (!cancelled) setState({ status: 'signedOut' })
      },
    )
    return () => {
      cancelled = true
    }
  }, [])

  const signIn = useCallback(async (username: string, password: string) => {
    const result = await login(username, password)
    saveSession(result.token, result.expiresAt)
    setState({ status: 'signedIn', account: result.account })
  }, [])

  const signOut = useCallback(async () => {
    const token = readSession()
    clearSession()
    setState({ status: 'signedOut' })
    if (token) {
      // Best effort: the token is forgotten here either way.
      await logout(token).catch(() => undefined)
    }
  }, [])

  const value = useMemo(() => ({ state, signIn, signOut }), [state, signIn, signOut])
  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}
