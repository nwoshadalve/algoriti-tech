/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
const MODE_KEY = 'algoritiq.signInMode'

export type SignInMode = 'pin' | 'password'

/** Last sign-in screen the person chose on this client (PIN or password). */
export function readSignInMode(): SignInMode {
  try {
    if (localStorage.getItem(MODE_KEY) === 'password') return 'password'
  } catch {
    // Private mode: default below.
  }
  return 'pin'
}

export function saveSignInMode(mode: SignInMode): void {
  try {
    localStorage.setItem(MODE_KEY, mode)
  } catch {
    // Preference not saved; next visit may default to PIN when available.
  }
}
