import { screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, describe, expect, it, vi } from 'vitest'
import { renderAppAt } from '@/test/render'
import * as setupApi from '@/core/api/setup'

describe('ActivationCodePage', () => {
  afterEach(() => {
    vi.restoreAllMocks()
    sessionStorage.clear()
  })

  it('should show activation form when setup is open', async () => {
    vi.spyOn(setupApi, 'getSetupStatus').mockResolvedValue({
      adminRegistered: false,
      claimCodeRequired: true,
    })

    renderAppAt('/')

    await waitFor(() => {
      expect(screen.getByRole('textbox', { name: 'Activation code' })).toBeInTheDocument()
    })
    expect(screen.getByRole('button', { name: 'Continue' })).toBeInTheDocument()
  })

  it('should navigate to register after the API accepts the code', async () => {
    vi.spyOn(setupApi, 'getSetupStatus').mockResolvedValue({
      adminRegistered: false,
      claimCodeRequired: true,
    })
    vi.spyOn(setupApi, 'verifyClaimCode').mockResolvedValue()

    const user = userEvent.setup()
    renderAppAt('/')

    await waitFor(() => {
      expect(screen.getByRole('textbox', { name: 'Activation code' })).toBeInTheDocument()
    })

    await user.type(screen.getByRole('textbox', { name: 'Activation code' }), 'ABCD-1234')
    await user.click(screen.getByRole('button', { name: 'Continue' }))

    await waitFor(() => {
      expect(screen.getByLabelText('Username')).toBeInTheDocument()
    })
    expect(setupApi.verifyClaimCode).toHaveBeenCalledWith('ABCD-1234')
  })

  it('should stay on activation when the API rejects the code', async () => {
    vi.spyOn(setupApi, 'getSetupStatus').mockResolvedValue({
      adminRegistered: false,
      claimCodeRequired: true,
    })
    const { ApiError } = await import('@/core/api/client')
    vi.spyOn(setupApi, 'verifyClaimCode').mockRejectedValue(
      new ApiError('claim_code_invalid', 'refused', 3),
    )

    const user = userEvent.setup()
    renderAppAt('/')

    await waitFor(() => {
      expect(screen.getByRole('textbox', { name: 'Activation code' })).toBeInTheDocument()
    })

    await user.type(screen.getByRole('textbox', { name: 'Activation code' }), 'WRONG123')
    await user.click(screen.getByRole('button', { name: 'Continue' }))

    await waitFor(() => {
      expect(screen.queryByLabelText('Username')).not.toBeInTheDocument()
    })
    expect(screen.getByRole('textbox', { name: 'Activation code' })).toBeInTheDocument()
  })

  it('should switch to Bengali when বাংলা is selected', async () => {
    vi.spyOn(setupApi, 'getSetupStatus').mockResolvedValue({
      adminRegistered: false,
      claimCodeRequired: true,
    })

    const user = userEvent.setup()
    renderAppAt('/')

    await waitFor(() => {
      expect(screen.getByRole('textbox', { name: 'Activation code' })).toBeInTheDocument()
    })

    await user.click(screen.getByRole('button', { name: 'বাংলা' }))

    expect(screen.getByRole('textbox', { name: 'অ্যাক্টিভেশন কোড' })).toBeInTheDocument()
  })
})
