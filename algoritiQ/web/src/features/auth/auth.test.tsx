import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { ApiError } from '@/core/api/client'
import * as authApi from '@/core/api/auth'
import * as setupApi from '@/core/api/setup'
import type { Account } from '@/core/api/types'
import { readSession, saveSession } from '@/features/auth/session'
import { renderAppAt } from '@/test/render'

const owner: Account = { id: 'a1', username: 'owner', displayName: 'The Owner', role: 'admin' }
const inOneHour = () => new Date(Date.now() + 3_600_000).toISOString()

function adminExists(registered = true) {
  vi.spyOn(setupApi, 'getSetupStatus').mockResolvedValue({
    adminRegistered: registered,
    claimCodeRequired: !registered,
  })
}

async function signInWith(user: ReturnType<typeof userEvent.setup>, password = 'a-long-passphrase') {
  await user.type(await screen.findByLabelText('Username'), 'Owner')
  await user.type(screen.getByLabelText('Password'), password)
  await user.click(screen.getByRole('button', { name: 'Sign in' }))
}

describe('sign-in', () => {
  beforeEach(() => adminExists())
  afterEach(() => {
    vi.restoreAllMocks()
    sessionStorage.clear()
  })

  it('should sign in and show the signed-in page', async () => {
    const login = vi
      .spyOn(authApi, 'login')
      .mockResolvedValue({ token: 'tok', expiresAt: inOneHour(), account: owner })

    renderAppAt('/login')
    await signInWith(userEvent.setup())

    expect(await screen.findByText('Welcome, The Owner')).toBeInTheDocument()
    expect(login).toHaveBeenCalledWith('Owner', 'a-long-passphrase')
    expect(readSession()).toBe('tok')
  })

  it('should say so when the username or password is wrong', async () => {
    vi.spyOn(authApi, 'login').mockRejectedValue(new ApiError('invalid_credentials', 'no'))

    renderAppAt('/login')
    await signInWith(userEvent.setup(), 'wrong-password-1')

    expect(await screen.findByRole('alert')).toHaveTextContent('Wrong username or password.')
    expect(screen.getByLabelText('Password')).toHaveValue('')
  })

  it('should tell how long to wait after too many tries', async () => {
    vi.spyOn(authApi, 'login').mockRejectedValue(
      new ApiError('too_many_attempts', 'slow down', undefined, 45),
    )

    renderAppAt('/login')
    await signInWith(userEvent.setup())

    expect(await screen.findByRole('alert')).toHaveTextContent('Try again in 45 seconds.')
  })

  it('should explain a missing connection', async () => {
    vi.spyOn(authApi, 'login').mockRejectedValue(new TypeError('Failed to fetch'))

    renderAppAt('/login')
    await signInWith(userEvent.setup())

    expect(await screen.findByRole('alert')).toHaveTextContent('Cannot reach the clinic server')
  })

  it('should not call the tablet with an empty form', async () => {
    const login = vi.spyOn(authApi, 'login')

    renderAppAt('/login')
    const user = userEvent.setup()
    await user.click(await screen.findByRole('button', { name: 'Sign in' }))

    expect(await screen.findByText('Enter your username and password.')).toBeInTheDocument()
    expect(login).not.toHaveBeenCalled()
  })

  it('should link to the forgotten password page', async () => {
    renderAppAt('/login')

    await userEvent.setup().click(await screen.findByRole('link', { name: 'Forgot password?' }))

    expect(await screen.findByText('Reset your password')).toBeInTheDocument()
  })

  it('should send a visitor to setup while there is no admin yet', async () => {
    vi.restoreAllMocks()
    adminExists(false)

    renderAppAt('/login')

    expect(await screen.findByRole('textbox', { name: 'Activation code' })).toBeInTheDocument()
  })

  it('should block home and password reset until setup is finished', async () => {
    vi.restoreAllMocks()
    adminExists(false)

    renderAppAt('/home')
    expect(await screen.findByRole('textbox', { name: 'Activation code' })).toBeInTheDocument()

    renderAppAt('/forgot-password')
    expect(await screen.findByRole('textbox', { name: 'Activation code' })).toBeInTheDocument()
  })

  it('should send the activation page to sign-in once an admin exists', async () => {
    renderAppAt('/')

    expect(await screen.findByRole('heading', { name: 'Sign in' })).toBeInTheDocument()
  })

  it('should keep the visitor signed in after a reload', async () => {
    saveSession('tok', inOneHour())
    vi.spyOn(authApi, 'getMe').mockResolvedValue(owner)

    renderAppAt('/home')

    expect(await screen.findByText('Welcome, The Owner')).toBeInTheDocument()
  })

  it('should drop a sign-in the tablet no longer accepts', async () => {
    saveSession('old', inOneHour())
    vi.spyOn(authApi, 'getMe').mockRejectedValue(new ApiError('unauthorized', 'no'))

    renderAppAt('/home')

    expect(await screen.findByRole('heading', { name: 'Sign in' })).toBeInTheDocument()
    expect(readSession()).toBeNull()
  })

  it('should send a signed-out visitor from the signed-in page to sign-in', async () => {
    renderAppAt('/home')

    expect(await screen.findByRole('heading', { name: 'Sign in' })).toBeInTheDocument()
  })

  it('should sign out on the tablet and here', async () => {
    saveSession('tok', inOneHour())
    vi.spyOn(authApi, 'getMe').mockResolvedValue(owner)
    const logout = vi.spyOn(authApi, 'logout').mockResolvedValue()

    renderAppAt('/home')
    await userEvent.setup().click(await screen.findByRole('button', { name: 'Sign out' }))

    expect(await screen.findByRole('heading', { name: 'Sign in' })).toBeInTheDocument()
    expect(logout).toHaveBeenCalledWith('tok')
    expect(readSession()).toBeNull()
  })
})

describe('forgot password', () => {
  beforeEach(() => adminExists())
  afterEach(() => {
    vi.restoreAllMocks()
    sessionStorage.clear()
  })

  const ticket = { resetToken: 'ticket-1', expiresAt: inOneHour() }

  type User = ReturnType<typeof userEvent.setup>

  async function giveUsername(user: User, name = 'Owner') {
    await user.type(await screen.findByLabelText('Username'), name)
    await user.click(screen.getByRole('button', { name: 'Continue' }))
  }

  async function giveKey(user: User, key = '040G2-08501-8H1ZZ') {
    await user.type(await screen.findByLabelText('Activation key'), key)
    await user.click(screen.getByRole('button', { name: 'Continue' }))
  }

  async function givePassword(user: User, password = 'a-brand-new-passphrase', confirm = password) {
    await user.type(await screen.findByLabelText('New password'), password)
    await user.type(screen.getByLabelText('Confirm new password'), confirm)
    await user.click(screen.getByRole('button', { name: 'Reset password' }))
  }

  it('should start with the username and ask the tablet nothing yet', async () => {
    const start = vi.spyOn(authApi, 'startPasswordReset')

    renderAppAt('/forgot-password')
    await giveUsername(userEvent.setup())

    // Step 2 is on screen; nothing was sent, so no account was confirmed.
    expect(await screen.findByLabelText('Activation key')).toBeInTheDocument()
    expect(start).not.toHaveBeenCalled()
  })

  it('should ask for the username first', async () => {
    renderAppAt('/forgot-password')

    await userEvent.setup().click(await screen.findByRole('button', { name: 'Continue' }))

    expect(await screen.findByText('Choose a username.')).toBeInTheDocument()
    expect(screen.queryByLabelText('Activation key')).not.toBeInTheDocument()
  })

  it('should ask for the activation key', async () => {
    renderAppAt('/forgot-password')
    const user = userEvent.setup()
    await giveUsername(user)

    await user.click(await screen.findByRole('button', { name: 'Continue' }))

    expect(await screen.findByText('Enter the activation key.')).toBeInTheDocument()
  })

  it('should send the username and key to the tablet, then show the password step', async () => {
    const start = vi.spyOn(authApi, 'startPasswordReset').mockResolvedValue(ticket)

    renderAppAt('/forgot-password')
    const user = userEvent.setup()
    await giveUsername(user)
    await giveKey(user)

    expect(await screen.findByLabelText('New password')).toBeInTheDocument()
    expect(screen.getByText('The key was accepted. Choose a new password for Owner.')).toBeInTheDocument()
    expect(start).toHaveBeenCalledWith('Owner', '040G2-08501-8H1ZZ')
  })

  it('should stay on the key step when the tablet refuses it', async () => {
    vi.spyOn(authApi, 'startPasswordReset').mockRejectedValue(new ApiError('reset_refused', 'no'))

    renderAppAt('/forgot-password')
    const user = userEvent.setup()
    await giveUsername(user)
    await giveKey(user, 'WRONG')

    expect(await screen.findByRole('alert')).toHaveTextContent(
      'The activation key or the username is not correct.',
    )
    expect(screen.getByLabelText('Activation key')).toBeInTheDocument()
    expect(screen.queryByLabelText('New password')).not.toBeInTheDocument()
  })

  it('should tell how long to wait after too many wrong keys', async () => {
    vi.spyOn(authApi, 'startPasswordReset').mockRejectedValue(
      new ApiError('too_many_attempts', 'slow', undefined, 60),
    )

    renderAppAt('/forgot-password')
    const user = userEvent.setup()
    await giveUsername(user)
    await giveKey(user)

    expect(await screen.findByRole('alert')).toHaveTextContent('Try again in 60 seconds.')
  })

  it('should reset the password and go back to sign-in with a notice', async () => {
    vi.spyOn(authApi, 'startPasswordReset').mockResolvedValue(ticket)
    const finish = vi.spyOn(authApi, 'finishPasswordReset').mockResolvedValue()

    renderAppAt('/forgot-password')
    const user = userEvent.setup()
    await giveUsername(user)
    await giveKey(user)
    await givePassword(user)

    expect(
      await screen.findByText('Password changed. Sign in with your new password.'),
    ).toBeInTheDocument()
    expect(finish).toHaveBeenCalledWith('ticket-1', 'a-brand-new-passphrase')
  })

  it('should not send a weak or mismatched password to the tablet', async () => {
    vi.spyOn(authApi, 'startPasswordReset').mockResolvedValue(ticket)
    const finish = vi.spyOn(authApi, 'finishPasswordReset')

    renderAppAt('/forgot-password')
    const user = userEvent.setup()
    await giveUsername(user)
    await giveKey(user)
    await givePassword(user, 'short', 'other')

    expect(await screen.findByText('Use at least 10 characters.')).toBeInTheDocument()
    expect(screen.getByText('Passwords do not match.')).toBeInTheDocument()
    expect(finish).not.toHaveBeenCalled()
  })

  it('should go back to the key step when the ticket has expired', async () => {
    vi.spyOn(authApi, 'startPasswordReset').mockResolvedValue(ticket)
    vi.spyOn(authApi, 'finishPasswordReset').mockRejectedValue(
      new ApiError('reset_token_invalid', 'expired'),
    )

    renderAppAt('/forgot-password')
    const user = userEvent.setup()
    await giveUsername(user)
    await giveKey(user)
    await givePassword(user)

    expect(await screen.findByRole('alert')).toHaveTextContent('This reset has expired.')
    expect(screen.getByLabelText('Activation key')).toBeInTheDocument()
  })

  it('should keep the username when going back from the key step', async () => {
    renderAppAt('/forgot-password')
    const user = userEvent.setup()
    await giveUsername(user)

    await user.click(await screen.findByRole('button', { name: 'Back' }))

    expect(await screen.findByLabelText('Username')).toHaveValue('Owner')
  })

  it('should drop the ticket when going back from the password step', async () => {
    vi.spyOn(authApi, 'startPasswordReset').mockResolvedValue(ticket)
    const finish = vi.spyOn(authApi, 'finishPasswordReset').mockResolvedValue()

    renderAppAt('/forgot-password')
    const user = userEvent.setup()
    await giveUsername(user)
    await giveKey(user)
    await user.click(await screen.findByRole('button', { name: 'Back' }))

    expect(await screen.findByLabelText('Activation key')).toHaveValue('')
    expect(finish).not.toHaveBeenCalled()
  })

  it('should forget a sign-in the reset has just ended', async () => {
    saveSession('tok', new Date(Date.now() + 3_600_000).toISOString())
    vi.spyOn(authApi, 'getMe').mockResolvedValue(owner)
    vi.spyOn(authApi, 'logout').mockResolvedValue()
    vi.spyOn(authApi, 'startPasswordReset').mockResolvedValue(ticket)
    vi.spyOn(authApi, 'finishPasswordReset').mockResolvedValue()

    renderAppAt('/forgot-password')
    const user = userEvent.setup()
    await giveUsername(user)
    await giveKey(user)
    await givePassword(user)

    expect(
      await screen.findByText('Password changed. Sign in with your new password.'),
    ).toBeInTheDocument()
    expect(readSession()).toBeNull()
  })

  it('should link back to sign-in from the first step', async () => {
    renderAppAt('/forgot-password')

    await userEvent.setup().click(await screen.findByRole('link', { name: 'Back to sign in' }))

    expect(await screen.findByRole('heading', { name: 'Sign in' })).toBeInTheDocument()
  })

  it('should show which of the three steps this is', async () => {
    renderAppAt('/forgot-password')

    expect(await screen.findByRole('group', { name: 'Password reset progress' })).toHaveTextContent(
      'Step 1 of 3',
    )
  })
})

describe('session storage', () => {
  afterEach(() => sessionStorage.clear())

  it('should forget a sign-in that has expired', () => {
    saveSession('tok', new Date(Date.now() - 1000).toISOString())

    expect(readSession()).toBeNull()
  })

  it('should ignore damaged data', () => {
    sessionStorage.setItem('algoritiq.session', '{not json')

    expect(readSession()).toBeNull()
  })
})
