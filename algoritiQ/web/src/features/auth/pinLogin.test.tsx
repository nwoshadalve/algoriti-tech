/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import * as authApi from '@/core/api/auth'
import { ApiError } from '@/core/api/client'
import * as setupApi from '@/core/api/setup'
import type { Account, LoginResult } from '@/core/api/types'
import { readPinBrowser, savePinBrowser } from '@/features/auth/pinDevice'
import { readSession } from '@/features/auth/session'
import { renderAppAt } from '@/test/render'

const owner: Account = {
  id: 'a1',
  username: 'owner',
  displayName: 'The Owner',
  firstName: 'The',
  lastName: 'Owner',
  phone: '',
  photoVersion: 0,
  email: 'owner@clinic.test',
  role: 'admin',
}

const granted = (hours = 12): LoginResult => ({
  token: 'tok',
  expiresAt: new Date(Date.now() + hours * 3_600_000).toISOString(),
  account: owner,
})

const toasts = () => within(screen.getByLabelText('Notifications'))

describe('login: remember this browser', () => {
  beforeEach(() => {
    vi.spyOn(setupApi, 'getSetupStatus').mockResolvedValue({
      adminRegistered: true,
      claimCodeRequired: false,
    })
    vi.spyOn(authApi, 'getMe').mockResolvedValue(owner)
  })

  afterEach(() => {
    vi.restoreAllMocks()
    sessionStorage.clear()
    localStorage.clear()
  })

  async function fill(user: ReturnType<typeof userEvent.setup>) {
    await user.type(await screen.findByLabelText('Username or email'), 'owner')
    await user.type(screen.getByLabelText('Password'), 'a-long-passphrase')
  }

  it('should offer the option, off by default', async () => {
    renderAppAt('/login')

    const box = await screen.findByRole('checkbox', { name: /Remember this browser/ })

    expect(box).not.toBeChecked()
  })

  it('should keep the sign-in in this tab only when it is not ticked', async () => {
    const login = vi.spyOn(authApi, 'login').mockResolvedValue(granted())
    const user = userEvent.setup()
    renderAppAt('/login')

    await fill(user)
    await user.click(screen.getByRole('button', { name: 'Sign in' }))

    await waitFor(() => expect(login).toHaveBeenCalledWith('owner', 'a-long-passphrase', false))
    await waitFor(() => expect(readSession()).toBe('tok'))
    expect(localStorage.getItem('algoritiq.session')).toBeNull()
  })

  it('should ask for a long sign-in and keep it across restarts when ticked', async () => {
    const login = vi.spyOn(authApi, 'login').mockResolvedValue(granted(24 * 30))
    const user = userEvent.setup()
    renderAppAt('/login')

    await fill(user)
    await user.click(screen.getByRole('checkbox', { name: /Remember this browser/ }))
    await user.click(screen.getByRole('button', { name: 'Sign in' }))

    await waitFor(() => expect(login).toHaveBeenCalledWith('owner', 'a-long-passphrase', true))
    await waitFor(() => expect(localStorage.getItem('algoritiq.session')).not.toBeNull())
    expect(sessionStorage.getItem('algoritiq.session')).toBeNull()
  })

  it('should open the dashboard straight away on a later visit', async () => {
    localStorage.setItem(
      'algoritiq.session',
      JSON.stringify({ token: 'tok', expiresAt: granted().expiresAt }),
    )

    renderAppAt('/home')

    expect(await screen.findByRole('heading', { name: 'Welcome back, The' })).toBeInTheDocument()
  })

  it('should forget the remembered sign-in when the tablet no longer accepts it', async () => {
    localStorage.setItem(
      'algoritiq.session',
      JSON.stringify({ token: 'old', expiresAt: granted().expiresAt }),
    )
    vi.spyOn(authApi, 'getMe').mockRejectedValue(new ApiError('unauthorized', 'no'))

    renderAppAt('/home')

    expect(await screen.findByRole('heading', { name: 'Sign in' })).toBeInTheDocument()
    expect(localStorage.getItem('algoritiq.session')).toBeNull()
  })

  it('should forget a remembered sign-in on sign-out', async () => {
    localStorage.setItem(
      'algoritiq.session',
      JSON.stringify({ token: 'tok', expiresAt: granted().expiresAt }),
    )
    vi.spyOn(authApi, 'logout').mockResolvedValue()
    const user = userEvent.setup()
    renderAppAt('/home')

    await user.click(await screen.findByRole('button', { name: 'Account menu' }))
    await user.click(screen.getByRole('button', { name: 'Sign out' }))

    expect(await screen.findByRole('heading', { name: 'Sign in' })).toBeInTheDocument()
    expect(localStorage.getItem('algoritiq.session')).toBeNull()
  })
})

describe('login: PIN', () => {
  beforeEach(() => {
    vi.spyOn(setupApi, 'getSetupStatus').mockResolvedValue({
      adminRegistered: true,
      claimCodeRequired: false,
    })
    vi.spyOn(authApi, 'getMe').mockResolvedValue(owner)
    savePinBrowser({
      deviceToken: 'secret-1',
      deviceId: 'dev-1',
      username: 'owner',
      displayName: 'The Owner',
    })
  })

  afterEach(() => {
    vi.restoreAllMocks()
    sessionStorage.clear()
    localStorage.clear()
  })

  it('should offer the PIN on a browser that has one, by name', async () => {
    renderAppAt('/login')

    expect(await screen.findByRole('heading', { name: 'Sign in' })).toBeInTheDocument()
    expect(screen.getByText('Welcome back, The Owner')).toBeInTheDocument()
    expect(screen.getByLabelText('PIN')).toHaveFocus()
    expect(screen.queryByLabelText('Password')).toBeNull()
    expect(screen.getByRole('radio', { name: 'PIN' })).toHaveAttribute('aria-checked', 'true')
  })

  it('should offer only the password on a browser without one', async () => {
    localStorage.clear()
    renderAppAt('/login')

    expect(await screen.findByRole('heading', { name: 'Sign in' })).toBeInTheDocument()
    expect(screen.queryByRole('radio', { name: 'PIN' })).toBeNull()
  })

  it('should sign in by itself when the sixth digit is typed', async () => {
    const pinLogin = vi.spyOn(authApi, 'loginWithPin').mockResolvedValue(granted())
    const user = userEvent.setup()
    renderAppAt('/login')

    await user.type(await screen.findByLabelText('PIN'), '482913')

    await waitFor(() => expect(pinLogin).toHaveBeenCalledWith('secret-1', '482913'))
    expect(await screen.findByRole('heading', { name: 'Welcome back, The' })).toBeInTheDocument()
    // A PIN sign-in is for this tab only.
    expect(sessionStorage.getItem('algoritiq.session')).not.toBeNull()
    expect(localStorage.getItem('algoritiq.session')).toBeNull()
  })

  it('should take only digits, at most six', async () => {
    const pinLogin = vi.spyOn(authApi, 'loginWithPin').mockResolvedValue(granted())
    const user = userEvent.setup()
    renderAppAt('/login')
    const box = await screen.findByLabelText('PIN')

    await user.type(box, '4a8-2 9 1 3 77')

    expect(pinLogin).toHaveBeenCalledWith('secret-1', '482913')
  })

  it('should not ask the tablet for fewer than six digits', async () => {
    const pinLogin = vi.spyOn(authApi, 'loginWithPin')
    const user = userEvent.setup()
    renderAppAt('/login')

    await user.type(await screen.findByLabelText('PIN'), '4829')
    await user.click(screen.getByRole('button', { name: 'Sign in' }))

    expect(screen.getByText('Enter your 6-digit PIN.')).toBeInTheDocument()
    expect(pinLogin).not.toHaveBeenCalled()
  })

  it('should say how many tries are left after a wrong PIN, and empty the box', async () => {
    vi.spyOn(authApi, 'loginWithPin').mockRejectedValue(
      new ApiError('invalid_pin', 'no', 3),
    )
    const user = userEvent.setup()
    renderAppAt('/login')
    const box = await screen.findByLabelText('PIN')

    await user.type(box, '000111')

    expect(await toasts().findByText('That PIN is not correct. 3 tries left.')).toBeInTheDocument()
    expect(box).toHaveValue('')
    expect(readPinBrowser()).not.toBeNull()
  })

  it('should drop the PIN and ask for the password once it is locked', async () => {
    vi.spyOn(authApi, 'loginWithPin').mockRejectedValue(new ApiError('pin_locked', 'no'))
    const user = userEvent.setup()
    renderAppAt('/login')

    await user.type(await screen.findByLabelText('PIN'), '000111')

    expect(
      await toasts().findByText('Too many wrong PINs. Sign in with your password.'),
    ).toBeInTheDocument()
    expect(await screen.findByLabelText('Password')).toBeInTheDocument()
    expect(readPinBrowser()).toBeNull()
  })

  it('should drop the PIN when the tablet no longer knows this browser', async () => {
    vi.spyOn(authApi, 'loginWithPin').mockRejectedValue(new ApiError('pin_unavailable', 'no'))
    const user = userEvent.setup()
    renderAppAt('/login')

    await user.type(await screen.findByLabelText('PIN'), '482913')

    expect(await screen.findByLabelText('Password')).toBeInTheDocument()
    expect(readPinBrowser()).toBeNull()
  })

  it('should tell how long to wait when slowed down', async () => {
    vi.spyOn(authApi, 'loginWithPin').mockRejectedValue(
      new ApiError('too_many_attempts', 'slow', undefined, 45),
    )
    const user = userEvent.setup()
    renderAppAt('/login')

    await user.type(await screen.findByLabelText('PIN'), '482913')

    expect(await toasts().findByText(/Try again in 45 seconds/)).toBeInTheDocument()
    expect(readPinBrowser()).not.toBeNull()
  })

  it('should switch between the PIN and the password, keeping the PIN', async () => {
    const user = userEvent.setup()
    renderAppAt('/login')

    await user.click(await screen.findByRole('radio', { name: 'Password' }))
    expect(await screen.findByLabelText('Password')).toBeInTheDocument()
    await user.click(screen.getByRole('radio', { name: 'PIN' }))

    expect(await screen.findByLabelText('PIN')).toBeInTheDocument()
    expect(readPinBrowser()).not.toBeNull()
  })
})
