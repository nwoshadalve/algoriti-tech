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
import * as workScopeApi from '@/core/api/workScope'
import { saveSession } from '@/features/auth/session'
import { renderAppAt } from '@/test/render'

describe('queue configuration page', () => {
  it('should keep receptionists out', async () => {
    vi.spyOn(setupApi, 'getSetupStatus').mockResolvedValue({
      adminRegistered: true,
      claimCodeRequired: false,
    })
    saveSession('tok', new Date(Date.now() + 3_600_000).toISOString())
    vi.spyOn(authApi, 'getMe').mockResolvedValue({
      id: 'r1',
      username: 'desk',
      displayName: 'Desk',
      firstName: 'Desk',
      lastName: 'Staff',
      email: '',
      phone: '',
      photoVersion: 0,
      role: 'receptionist',
    })
    vi.spyOn(workScopeApi, 'getWorkScopes').mockResolvedValue({
      assignmentTarget: 'chamber',
      assignmentCount: 1,
      options: [{ id: 'c1', name: 'Main chamber', detail: '12 Lake Road' }],
    })
    renderAppAt('/config/queue')
    expect(await screen.findByText('Only an administrator can configure queues.')).toBeInTheDocument()
  })
})
