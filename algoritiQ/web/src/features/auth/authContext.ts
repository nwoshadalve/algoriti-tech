/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { createContext, useContext } from 'react'
import type { Account } from '@/core/api/types'

export type AuthState =
  | { status: 'loading' }
  | { status: 'signedOut' }
  | { status: 'signedIn'; account: Account }

export type AuthContextValue = {
  state: AuthState
  /** Throws an `ApiError` when the tablet refuses the sign-in. */
  signIn: (username: string, password: string, remember?: boolean) => Promise<void>
  /** Throws an `ApiError` when the PIN is refused, the browser is locked out or has no PIN. */
  signInWithPin: (pin: string) => Promise<void>
  signOut: () => Promise<void>
  /** Replaces the signed-in account, e.g. after the profile was saved. */
  updateAccount: (account: Account) => void
}

export const AuthContext = createContext<AuthContextValue | null>(null)

export function useAuth(): AuthContextValue {
  const ctx = useContext(AuthContext)
  if (!ctx) {
    throw new Error('useAuth must be used within AuthProvider')
  }
  return ctx
}
