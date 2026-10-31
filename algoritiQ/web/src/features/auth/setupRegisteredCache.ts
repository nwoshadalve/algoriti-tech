/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */

const STORAGE_KEY = 'algoritiq.setup.registered'

/** Avoids the setup route guard spinner on every dashboard refresh once we know an admin exists. */
export function readSetupRegisteredCache(): boolean {
  try {
    return sessionStorage.getItem(STORAGE_KEY) === '1'
  } catch {
    return false
  }
}

export function writeSetupRegisteredCache(registered: boolean): void {
  try {
    if (registered) sessionStorage.setItem(STORAGE_KEY, '1')
    else sessionStorage.removeItem(STORAGE_KEY)
  } catch {
    // Storage unavailable: the next `getSetupStatus` call decides routing.
  }
}
