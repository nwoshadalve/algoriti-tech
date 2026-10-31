/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { screen } from '@testing-library/react'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import * as authApi from '@/core/api/auth'
import * as setupApi from '@/core/api/setup'
import type { Account } from '@/core/api/types'
import { saveSession } from '@/features/auth/session'
import { renderAppAt } from '@/test/render'

const owner: Account = {
  id: 'a1',
  username: 'nowshad',
  displayName: 'Nowshad Admin',
  firstName: 'Nowshad',
  lastName: 'Admin',
  phone: '',
  photoVersion: 0,
  email: 'nowshadalve@gmail.com',
  role: 'admin',
}

describe('overview page at 320px', () => {
  beforeEach(() => {
    vi.spyOn(setupApi, 'getSetupStatus').mockResolvedValue({
      adminRegistered: true,
      claimCodeRequired: false,
    })
    saveSession('tok', new Date(Date.now() + 3_600_000).toISOString())
    vi.spyOn(authApi, 'getMe').mockResolvedValue(owner)
    Object.defineProperty(window, 'innerWidth', { configurable: true, value: 320 })
    Object.defineProperty(document.documentElement, 'clientWidth', {
      configurable: true,
      value: 320,
    })
  })

  afterEach(() => {
    vi.restoreAllMocks()
    sessionStorage.clear()
  })

  it('should not scroll sideways with a long email on the account card', async () => {
    renderAppAt('/home')

    expect(await screen.findByRole('heading', { name: 'Welcome back, Nowshad' })).toBeInTheDocument()
    expect(screen.getByText('nowshadalve@gmail.com')).toBeInTheDocument()

    expect(document.documentElement.scrollWidth).toBeLessThanOrEqual(
      document.documentElement.clientWidth + 1,
    )
  })
})
