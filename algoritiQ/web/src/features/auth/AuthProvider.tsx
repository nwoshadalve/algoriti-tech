/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useCallback, useEffect, useMemo, useState, type ReactNode } from 'react'
import { getMe, login, loginWithPin, logout } from '@/core/api/auth'
import { getLicenseType } from '@/core/api/doctor'
import type { Account } from '@/core/api/types'
import { writeLicenseCache, clearLicenseCache } from '@/core/clinic/clinicLicenseCache'
import { AuthContext, type AuthState } from '@/features/auth/authContext'
import { readPinBrowser } from '@/features/auth/pinDevice'
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
        if (cancelled) return
        setState({ status: 'signedIn', account })
        void getLicenseType(token).then(
          (type) => writeLicenseCache(type),
          () => writeLicenseCache(null),
        )
      },
      () => {
        // Ended on the tablet (expired, signed out, password reset).
        clearSession()
        clearLicenseCache()
        if (!cancelled) setState({ status: 'signedOut' })
      },
    )
    return () => {
      cancelled = true
    }
  }, [])

  const signIn = useCallback(async (username: string, password: string, remember = false) => {
    const result = await login(username, password, remember)
    saveSession(result.token, result.expiresAt, remember)
    setState({ status: 'signedIn', account: result.account })
    void getLicenseType(result.token).then(
      (type) => writeLicenseCache(type),
      () => writeLicenseCache(null),
    )
  }, [])

  const signInWithPin = useCallback(async (pin: string) => {
    const browser = readPinBrowser()
    if (!browser) throw new Error('no_pin_browser')
    const result = await loginWithPin(browser.deviceToken, pin)
    // A PIN sign-in lasts as a normal one: this tab, twelve hours.
    saveSession(result.token, result.expiresAt, false)
    setState({ status: 'signedIn', account: result.account })
    void getLicenseType(result.token).then(
      (type) => writeLicenseCache(type),
      () => writeLicenseCache(null),
    )
  }, [])

  const signOut = useCallback(async () => {
    const token = readSession()
    clearSession()
    clearLicenseCache()
    setState({ status: 'signedOut' })
    if (token) {
      // Best effort: the token is forgotten here either way.
      await logout(token).catch(() => undefined)
    }
  }, [])

  const updateAccount = useCallback((account: Account) => {
    setState((current) =>
      current.status === 'signedIn' ? { status: 'signedIn', account } : current,
    )
  }, [])

  const value = useMemo(
    () => ({ state, signIn, signInWithPin, signOut, updateAccount }),
    [state, signIn, signInWithPin, signOut, updateAccount],
  )
  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}
