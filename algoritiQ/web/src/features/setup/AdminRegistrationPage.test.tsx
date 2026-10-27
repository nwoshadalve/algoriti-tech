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

    renderAppAt('/register')

    await waitFor(() => {
      expect(screen.getByLabelText('Username')).toBeInTheDocument()
    })
  })

  async function fillAndSubmit(user: ReturnType<typeof userEvent.setup>) {
    await user.type(await screen.findByLabelText('Username'), 'owner')
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
    const register = vi.spyOn(setupApi, 'registerAdmin').mockResolvedValue({
      id: '1',
      username: 'owner',
      displayName: 'owner',
      role: 'admin',
    })

    renderAppAt('/register')
    await fillAndSubmit(userEvent.setup())

    expect(await screen.findByText('Admin account created')).toBeInTheDocument()
    expect(register).toHaveBeenCalledWith(
      expect.objectContaining({ username: 'owner', password: 'a-long-passphrase' }),
    )
    expect(sessionStorage.getItem('algoritiq.setup.claimCode')).toBeNull()
  })

  it('should stay on the form when the tablet refuses the code', async () => {
    saveVerifiedClaimCode('TEST-CODE')
    vi.spyOn(setupApi, 'getSetupStatus').mockResolvedValue({
      adminRegistered: false,
      claimCodeRequired: true,
    })
    vi.spyOn(setupApi, 'registerAdmin').mockRejectedValue(
      new ApiError('claim_code_invalid', 'no', 3),
    )

    renderAppAt('/register')
    await fillAndSubmit(userEvent.setup())

    await waitFor(() => {
      expect(screen.getByRole('alert')).toBeInTheDocument()
    })
    expect(screen.getByLabelText('Username')).toBeInTheDocument()
    expect(screen.queryByText('Admin account created')).not.toBeInTheDocument()
  })
})
