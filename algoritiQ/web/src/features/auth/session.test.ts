/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { afterEach, describe, expect, it } from 'vitest'
import {
  clearSession,
  isSessionRemembered,
  readSession,
  saveSession,
} from '@/features/auth/session'

const later = () => new Date(Date.now() + 3_600_000).toISOString()
const earlier = () => new Date(Date.now() - 1000).toISOString()

describe('saved sign-in', () => {
  afterEach(() => {
    sessionStorage.clear()
    localStorage.clear()
  })

  it('should live in this tab only when the browser is not remembered', () => {
    saveSession('tok', later())

    expect(readSession()).toBe('tok')
    expect(sessionStorage.getItem('algoritiq.session')).not.toBeNull()
    expect(localStorage.getItem('algoritiq.session')).toBeNull()
    expect(isSessionRemembered()).toBe(false)
  })

  it('should survive closing the browser when the browser is remembered', () => {
    saveSession('tok', later(), true)

    expect(localStorage.getItem('algoritiq.session')).not.toBeNull()
    expect(sessionStorage.getItem('algoritiq.session')).toBeNull()
    expect(isSessionRemembered()).toBe(true)
    // A new tab or a restarted browser has an empty sessionStorage and still finds it.
    sessionStorage.clear()
    expect(readSession()).toBe('tok')
  })

  it('should keep only the newest sign-in, whichever kind', () => {
    saveSession('old', later(), true)

    saveSession('new', later(), false)

    expect(readSession()).toBe('new')
    expect(localStorage.getItem('algoritiq.session')).toBeNull()
  })

  it('should drop one that has run out, from either place', () => {
    saveSession('tok', earlier(), true)

    expect(readSession()).toBeNull()
    expect(localStorage.getItem('algoritiq.session')).toBeNull()

    saveSession('tok', earlier(), false)

    expect(readSession()).toBeNull()
    expect(sessionStorage.getItem('algoritiq.session')).toBeNull()
  })

  it('should drop one that cannot be read', () => {
    localStorage.setItem('algoritiq.session', 'not json')

    expect(readSession()).toBeNull()
    expect(localStorage.getItem('algoritiq.session')).toBeNull()
  })

  it('should be forgotten from both places on sign-out', () => {
    saveSession('tok', later(), true)
    sessionStorage.setItem('algoritiq.session', JSON.stringify({ token: 'x', expiresAt: later() }))

    clearSession()

    expect(readSession()).toBeNull()
    expect(localStorage.getItem('algoritiq.session')).toBeNull()
    expect(sessionStorage.getItem('algoritiq.session')).toBeNull()
  })
})
