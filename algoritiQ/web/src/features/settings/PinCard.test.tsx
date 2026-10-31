/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi, type MockInstance } from 'vitest'
import * as authApi from '@/core/api/auth'
import { ApiError } from '@/core/api/client'
import * as pinApi from '@/core/api/pin'
import * as profileApi from '@/core/api/profile'
import * as setupApi from '@/core/api/setup'
import type { Account, PinDevice } from '@/core/api/types'
import { readPinBrowser, savePinBrowser } from '@/features/auth/pinDevice'
import { saveSession } from '@/features/auth/session'
import { validatePin } from '@/features/settings/pinValidation'
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

const laptop: PinDevice = {
  id: 'dev-1',
  label: 'Chrome on Windows',
  createdAt: '2026-10-01T08:00:00.000Z',
  lastUsedAt: '2026-10-20T08:00:00.000Z',
}
const phone: PinDevice = {
  id: 'dev-2',
  label: 'Safari on iOS',
  createdAt: '2026-10-02T08:00:00.000Z',
  lastUsedAt: null,
}

const toasts = () => within(screen.getByLabelText('Notifications'))

describe('PIN card in settings', () => {
  let list: MockInstance<typeof pinApi.listPinDevices>

  beforeEach(() => {
    vi.spyOn(setupApi, 'getSetupStatus').mockResolvedValue({
      adminRegistered: true,
      claimCodeRequired: false,
    })
    saveSession('tok', new Date(Date.now() + 3_600_000).toISOString())
    vi.spyOn(authApi, 'getMe').mockResolvedValue(owner)
    list = vi.spyOn(pinApi, 'listPinDevices').mockResolvedValue([])
  })

  afterEach(() => {
    vi.restoreAllMocks()
    sessionStorage.clear()
    localStorage.clear()
  })

  async function open() {
    renderAppAt('/settings')
    await screen.findByRole('heading', { name: 'Password and PIN', level: 2 })
    return userEvent.setup()
  }

  async function openModal(user: ReturnType<typeof userEvent.setup>, name = 'Set PIN for this browser') {
    await user.click(screen.getByRole('button', { name }))
    return screen.findByRole('dialog', { name: 'Set a PIN' })
  }

  async function fill(
    dialog: HTMLElement,
    user: ReturnType<typeof userEvent.setup>,
    {
      password = 'a-long-passphrase',
      pin = '482913',
      confirm = pin,
    }: { password?: string; pin?: string; confirm?: string } = {},
  ) {
    await user.type(within(dialog).getByLabelText('Current password'), password)
    await user.type(within(dialog).getByLabelText('New PIN'), pin)
    await user.type(within(dialog).getByLabelText('Confirm PIN'), confirm)
  }

  describe('the list', () => {
    it('should say when no browser has a PIN', async () => {
      await open()

      expect(await screen.findByText('No PIN is set on any browser yet.')).toBeInTheDocument()
    })

    it('should list the browsers, mark this one and show when each was used', async () => {
      savePinBrowser({ deviceToken: 's', deviceId: 'dev-1', username: 'owner', displayName: 'The Owner' })
      list.mockResolvedValue([laptop, phone])
      await open()

      const row = (await screen.findByText('Chrome on Windows')).closest('li') as HTMLElement
      expect(within(row).getByText('This browser')).toBeInTheDocument()
      expect(within(row).getByText(/Last used/)).toBeInTheDocument()
      const other = screen.getByText('Safari on iOS').closest('li') as HTMLElement
      expect(within(other).queryByText('This browser')).toBeNull()
      expect(within(other).getByText('Not used yet')).toBeInTheDocument()
      expect(screen.getByRole('button', { name: 'Change PIN' })).toBeInTheDocument()
    })

    it('should forget this browser’s PIN when the tablet no longer lists it', async () => {
      savePinBrowser({ deviceToken: 's', deviceId: 'gone', username: 'owner', displayName: 'The Owner' })
      list.mockResolvedValue([phone])

      await open()

      await waitFor(() => expect(readPinBrowser()).toBeNull())
      expect(screen.getByRole('button', { name: 'Set PIN for this browser' })).toBeInTheDocument()
    })
  })

  describe('setting a PIN (popup)', () => {
    it('should set it, keep the browser’s secret and refresh the list', async () => {
      const set = vi.spyOn(pinApi, 'setPin').mockResolvedValue({
        deviceToken: 'new-secret',
        device: { ...laptop, id: 'dev-9', lastUsedAt: null },
      })
      const user = await open()
      const dialog = await openModal(user)
      await fill(dialog, user)
      // Once saved, the tablet lists the new browser.
      list.mockResolvedValue([{ ...laptop, id: 'dev-9', lastUsedAt: null }])
      const calls = list.mock.calls.length

      await user.click(within(dialog).getByRole('button', { name: 'Save changes' }))

      await waitFor(() =>
        expect(set).toHaveBeenCalledWith('tok', {
          password: 'a-long-passphrase',
          pin: '482913',
          label: expect.any(String),
          replaceDeviceId: undefined,
        }),
      )
      expect(
        await toasts().findByText('PIN set. You can use it to sign in on this browser.'),
      ).toBeInTheDocument()
      expect(readPinBrowser()).toEqual({
        deviceToken: 'new-secret',
        deviceId: 'dev-9',
        username: 'owner',
        displayName: 'The Owner',
      })
      expect(screen.queryByRole('dialog')).toBeNull()
      await waitFor(() => expect(list.mock.calls.length).toBeGreaterThan(calls))
    })

    it('should replace this browser’s earlier PIN when changing it', async () => {
      savePinBrowser({ deviceToken: 'old', deviceId: 'dev-1', username: 'owner', displayName: 'The Owner' })
      list.mockResolvedValue([laptop])
      const set = vi.spyOn(pinApi, 'setPin').mockResolvedValue({
        deviceToken: 'new-secret',
        device: { ...laptop, id: 'dev-9' },
      })
      const user = await open()
      await screen.findByText('Chrome on Windows')
      const dialog = await openModal(user, 'Change PIN')
      await fill(dialog, user, { pin: '902417' })

      await user.click(within(dialog).getByRole('button', { name: 'Save changes' }))

      await waitFor(() =>
        expect(set).toHaveBeenCalledWith('tok', expect.objectContaining({ replaceDeviceId: 'dev-1' })),
      )
    })

    it('should refuse an obvious PIN before asking the tablet', async () => {
      const set = vi.spyOn(pinApi, 'setPin')
      const user = await open()
      const dialog = await openModal(user)

      await fill(dialog, user, { pin: '123456' })
      await user.click(within(dialog).getByRole('button', { name: 'Save changes' }))

      expect(within(dialog).getByText('Choose a PIN that is harder to guess.')).toBeInTheDocument()
      expect(set).not.toHaveBeenCalled()
      expect(toasts().getByText('Check the highlighted fields and try again.')).toBeInTheDocument()
    })

    it('should need the same PIN twice and the password', async () => {
      const set = vi.spyOn(pinApi, 'setPin')
      const user = await open()
      const dialog = await openModal(user)

      await user.type(within(dialog).getByLabelText('New PIN'), '482913')
      await user.type(within(dialog).getByLabelText('Confirm PIN'), '482914')
      await user.click(within(dialog).getByRole('button', { name: 'Save changes' }))

      expect(within(dialog).getByText('The PINs do not match.')).toBeInTheDocument()
      expect(within(dialog).getByText('Enter your current password.')).toBeInTheDocument()
      expect(set).not.toHaveBeenCalled()
    })

    it('should take only digits', async () => {
      const user = await open()
      const dialog = await openModal(user)
      const box = within(dialog).getByLabelText('New PIN')

      await user.type(box, '4a8b2c9d1e3f77')

      expect(box).toHaveValue('482913')
    })

    it('should mark the password and say why when it is wrong', async () => {
      vi.spyOn(pinApi, 'setPin').mockRejectedValue(new ApiError('current_password_wrong', 'no'))
      const user = await open()
      const dialog = await openModal(user)
      await fill(dialog, user)

      await user.click(within(dialog).getByRole('button', { name: 'Save changes' }))

      expect(
        await toasts().findByText('The current password is not correct.'),
      ).toBeInTheDocument()
      expect(screen.getByRole('dialog')).toBeInTheDocument()
      expect(readPinBrowser()).toBeNull()
    })

    it('should tell how long to wait after too many wrong passwords', async () => {
      vi.spyOn(pinApi, 'setPin').mockRejectedValue(
        new ApiError('too_many_attempts', 'slow', undefined, 30),
      )
      const user = await open()
      const dialog = await openModal(user)
      await fill(dialog, user)

      await user.click(within(dialog).getByRole('button', { name: 'Save changes' }))

      expect(await toasts().findByText(/Try again in 30 seconds/)).toBeInTheDocument()
    })
  })

  describe('removing a PIN', () => {
    it('should remove one browser and say so', async () => {
      list.mockResolvedValue([laptop, phone])
      const remove = vi.spyOn(pinApi, 'removePinDevice').mockResolvedValue()
      const user = await open()

      await user.click(await screen.findByRole('button', { name: 'Remove PIN: Safari on iOS' }))

      await waitFor(() => expect(remove).toHaveBeenCalledWith('tok', 'dev-2'))
      expect(await toasts().findByText('PIN removed.')).toBeInTheDocument()
    })

    it('should also forget the secret when it is this browser’s own', async () => {
      savePinBrowser({ deviceToken: 's', deviceId: 'dev-1', username: 'owner', displayName: 'The Owner' })
      list.mockResolvedValue([laptop])
      vi.spyOn(pinApi, 'removePinDevice').mockResolvedValue()
      const user = await open()

      await user.click(await screen.findByRole('button', { name: 'Remove PIN: Chrome on Windows' }))

      await waitFor(() => expect(readPinBrowser()).toBeNull())
    })

    it('should explain when the tablet cannot remove it', async () => {
      list.mockResolvedValue([laptop])
      vi.spyOn(pinApi, 'removePinDevice').mockRejectedValue(new TypeError('fetch failed'))
      const user = await open()

      await user.click(await screen.findByRole('button', { name: 'Remove PIN: Chrome on Windows' }))

      expect(await toasts().findByText(/Cannot reach the clinic server/)).toBeInTheDocument()
    })
  })

  describe('changing the password', () => {
    it('should end this browser’s PIN, as the tablet ends every one', async () => {
      savePinBrowser({ deviceToken: 's', deviceId: 'dev-1', username: 'owner', displayName: 'The Owner' })
      list.mockResolvedValueOnce([laptop]).mockResolvedValue([])
      vi.spyOn(profileApi, 'changePassword').mockResolvedValue()
      const user = await open()
      await screen.findByText('Chrome on Windows')

      await user.click(screen.getByRole('button', { name: 'Change password' }))
      const dialog = await screen.findByRole('dialog', { name: 'Change your password' })
      await user.type(within(dialog).getByLabelText('Current password'), 'a-long-passphrase')
      await user.type(within(dialog).getByLabelText('New password'), 'a-better-passphrase')
      await user.type(within(dialog).getByLabelText('Confirm password'), 'a-better-passphrase')
      await user.click(within(dialog).getByRole('button', { name: 'Change password' }))

      await waitFor(() => expect(readPinBrowser()).toBeNull())
      expect(await screen.findByText('No PIN is set on any browser yet.')).toBeInTheDocument()
    })
  })
})

describe('PIN rules', () => {
  it('should accept six digits that are not an obvious guess', () => {
    expect(validatePin('482913')).toBeNull()
    expect(validatePin('135790')).toBeNull()
  })

  it('should need exactly six digits', () => {
    expect(validatePin('')).toBe('errorPinRequired')
    for (const pin of ['12345', '1234567', '12a456']) expect(validatePin(pin)).toBe('errorPinFormat')
  })

  it('should refuse one digit repeated and straight runs, up or down', () => {
    for (const pin of ['000000', '777777', '123456', '654321', '345678', '987654']) {
      expect(validatePin(pin)).toBe('errorPinWeak')
    }
  })
})
