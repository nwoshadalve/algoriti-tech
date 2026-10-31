/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { screen } from '@testing-library/react'
import { describe, expect, it, vi } from 'vitest'
import * as authApi from '@/core/api/auth'
import * as setupApi from '@/core/api/setup'
import { saveSession } from '@/features/auth/session'
import { renderAppAt } from '@/test/render'

describe('help page', () => {
  it('should render for a signed-in admin', async () => {
    vi.spyOn(setupApi, 'getSetupStatus').mockResolvedValue({
      adminRegistered: true,
      claimCodeRequired: false,
    })
    saveSession('tok', new Date(Date.now() + 3_600_000).toISOString())
    vi.spyOn(authApi, 'getMe').mockResolvedValue({
      id: 'a1',
      username: 'owner',
      displayName: 'Owner',
      firstName: 'Owner',
      lastName: 'Admin',
      email: '',
      phone: '',
      photoVersion: 0,
      role: 'admin',
    })
    renderAppAt('/help')

    expect(await screen.findByRole('heading', { name: 'Help', level: 1 })).toBeInTheDocument()
  })
})
