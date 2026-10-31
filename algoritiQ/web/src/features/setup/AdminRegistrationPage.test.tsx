/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, describe, expect, it, vi } from 'vitest'
import { ApiError } from '@/core/api/client'
import { renderAppAt } from '@/test/render'
import * as setupApi from '@/core/api/setup'
import { saveClaimCode, saveVerifiedClaimCode } from '@/features/setup/claimCodeSession'

describe('AdminRegistrationPage', () => {
  afterEach(() => {
    vi.restoreAllMocks()
    sessionStorage.clear()
  })

  it('should redirect to activation when no code is stored', async () => {
    vi.spyOn(setupApi, 'getSetupStatus').mockResolvedValue({
      adminRegistered: false,
      claimCodeRequired: true,
    })

    renderAppAt('/register')

    await waitFor(() => {
      expect(screen.getByRole('textbox', { name: 'Activation code' })).toBeInTheDocument()
    })
  })

  it('should redirect when a code is stored but not verified by the API', async () => {
    saveClaimCode('TEST-CODE')
    vi.spyOn(setupApi, 'getSetupStatus').mockResolvedValue({
      adminRegistered: false,
      claimCodeRequired: true,
    })

    renderAppAt('/register')

    await waitFor(() => {
      expect(screen.getByRole('textbox', { name: 'Activation code' })).toBeInTheDocument()
    })
  })

  it('should show registration form when code is verified', async () => {
    saveVerifiedClaimCode('TEST-CODE')
    vi.spyOn(setupApi, 'getSetupStatus').mockResolvedValue({
      adminRegistered: false,
      claimCodeRequired: true,
    })
    vi.spyOn(setupApi, 'verifyClaimCode').mockResolvedValue()

    renderAppAt('/register')

    await waitFor(() => {
      expect(screen.getByLabelText('Username')).toBeInTheDocument()
    })
  })

  async function fillAndSubmit(user: ReturnType<typeof userEvent.setup>) {
    await user.type(await screen.findByLabelText('First name'), 'The')
    await user.type(screen.getByLabelText('Last name'), 'Owner')
    await user.type(screen.getByLabelText('Email'), 'owner@clinic.test')
    await user.type(screen.getByLabelText('Username'), 'owner')
    await user.type(screen.getByLabelText('Password'), 'a-long-passphrase')
    await user.type(screen.getByLabelText('Confirm password'), 'a-long-passphrase')
    await user.click(screen.getByRole('button', { name: 'Create admin account' }))
  }

  it('should show the success message after registering, not jump back to the start', async () => {
    saveVerifiedClaimCode('TEST-CODE')
    vi.spyOn(setupApi, 'getSetupStatus').mockResolvedValue({
      adminRegistered: false,
      claimCodeRequired: true,
    })
    vi.spyOn(setupApi, 'verifyClaimCode').mockResolvedValue()
    const register = vi.spyOn(setupApi, 'registerAdmin').mockResolvedValue({
      id: '1',
      username: 'owner',
      displayName: 'The Owner',
      firstName: 'The',
      lastName: 'Owner',
      phone: '',
      photoVersion: 0,
      email: 'owner@clinic.test',
      role: 'admin',
    })

    renderAppAt('/register')
    await fillAndSubmit(userEvent.setup())

    expect(await screen.findByText('Admin account created')).toBeInTheDocument()
    expect(screen.getByText('Admin account created. You can sign in now.')).toBeInTheDocument()
    expect(register).toHaveBeenCalledWith(
      expect.objectContaining({ username: 'owner', password: 'a-long-passphrase' }),
    )
    expect(sessionStorage.getItem('algoritiq.setup.claimCode')).toBeNull()
  })

  it('should return to activation when the tablet refuses the code on submit', async () => {
    saveVerifiedClaimCode('TEST-CODE')
    vi.spyOn(setupApi, 'getSetupStatus').mockResolvedValue({
      adminRegistered: false,
      claimCodeRequired: true,
    })
    vi.spyOn(setupApi, 'verifyClaimCode').mockResolvedValue()
    vi.spyOn(setupApi, 'registerAdmin').mockRejectedValue(
      new ApiError('claim_code_invalid', 'no', 3),
    )

    renderAppAt('/register')
    await fillAndSubmit(userEvent.setup())

    await waitFor(() => {
      expect(screen.getByRole('textbox', { name: 'Activation code' })).toBeInTheDocument()
    })
    expect(screen.queryByLabelText('Username')).not.toBeInTheDocument()
    expect(sessionStorage.getItem('algoritiq.setup.claimVerified')).toBeNull()
  })

  it('should return to activation when the stored code fails re-check on load', async () => {
    saveVerifiedClaimCode('STALE-CODE')
    vi.spyOn(setupApi, 'getSetupStatus').mockResolvedValue({
      adminRegistered: false,
      claimCodeRequired: true,
    })
    vi.spyOn(setupApi, 'verifyClaimCode').mockRejectedValue(
      new ApiError('claim_code_invalid', 'no', 4),
    )

    renderAppAt('/register')

    await waitFor(() => {
      expect(screen.getByRole('textbox', { name: 'Activation code' })).toBeInTheDocument()
    })
    expect(screen.queryByLabelText('Username')).not.toBeInTheDocument()
  })
})
