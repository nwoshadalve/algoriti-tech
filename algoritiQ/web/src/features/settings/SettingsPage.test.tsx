/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { fireEvent, screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import * as authApi from '@/core/api/auth'
import { ApiError } from '@/core/api/client'
import * as pinApi from '@/core/api/pin'
import * as profileApi from '@/core/api/profile'
import * as setupApi from '@/core/api/setup'
import type { Account } from '@/core/api/types'
import { saveSession } from '@/features/auth/session'
import * as source from '@/features/settings/pictureSource'
import { validateProfile } from '@/features/settings/profileValidation'
import { renderAppAt } from '@/test/render'

const owner: Account = {
  id: 'a1',
  username: 'owner',
  displayName: 'Rafi Ahmed',
  firstName: 'Rafi',
  lastName: 'Ahmed',
  phone: '01711000000',
  photoVersion: 0,
  email: 'owner@clinic.test',
  role: 'admin',
}

async function openSettings() {
  renderAppAt('/settings')
  await screen.findByRole('heading', { name: 'Settings', level: 1 })
  return userEvent.setup()
}

describe('settings page', () => {
  beforeEach(() => {
    vi.spyOn(setupApi, 'getSetupStatus').mockResolvedValue({
      adminRegistered: true,
      claimCodeRequired: false,
    })
    saveSession('tok', new Date(Date.now() + 3_600_000).toISOString())
    vi.spyOn(authApi, 'getMe').mockResolvedValue(owner)
    vi.spyOn(pinApi, 'listPinDevices').mockResolvedValue([])
  })

  afterEach(() => {
    vi.restoreAllMocks()
    sessionStorage.clear()
  })

  it('should start with the saved details and a disabled save button', async () => {
    await openSettings()

    expect(screen.getByLabelText('First name')).toHaveValue('Rafi')
    expect(screen.getByLabelText('Last name')).toHaveValue('Ahmed')
    expect(screen.getByLabelText('Email')).toHaveValue('owner@clinic.test')
    expect(screen.getByLabelText('Phone (optional)')).toHaveValue('01711000000')
    expect(screen.getByLabelText('Username')).toHaveAttribute('readonly')
    expect(screen.getByRole('button', { name: 'Save changes' })).toBeDisabled()
  })

  it('should save the changes and show the new name in the sidebar', async () => {
    const update = vi.spyOn(profileApi, 'updateProfile').mockResolvedValue({
      ...owner,
      firstName: 'Sara',
      displayName: 'Sara Ahmed',
    })
    const user = await openSettings()

    await user.clear(screen.getByLabelText('First name'))
    await user.type(screen.getByLabelText('First name'), 'Sara')
    await user.click(screen.getByRole('button', { name: 'Save changes' }))

    expect(await screen.findByText('Your changes were saved.')).toBeInTheDocument()
    expect(update).toHaveBeenCalledWith('tok', {
      firstName: 'Sara',
      lastName: 'Ahmed',
      email: 'owner@clinic.test',
      phone: '01711000000',
    })
    expect(screen.getByRole('button', { name: 'Account menu' })).toHaveTextContent('Sara Ahmed')
    expect(screen.getByRole('button', { name: 'Save changes' })).toBeDisabled()
  })

  it('should check the fields before asking the tablet', async () => {
    const update = vi.spyOn(profileApi, 'updateProfile')
    const user = await openSettings()

    await user.clear(screen.getByLabelText('First name'))
    await user.clear(screen.getByLabelText('Email'))
    await user.type(screen.getByLabelText('Email'), 'nope')
    await user.click(screen.getByRole('button', { name: 'Save changes' }))

    expect(screen.getByText('Enter your first name.')).toBeInTheDocument()
    expect(screen.getByText('Enter a valid email address.')).toBeInTheDocument()
    expect(update).not.toHaveBeenCalled()
    expect(
      within(screen.getByLabelText('Notifications')).getByText(
        'Check the highlighted fields and try again.',
      ),
    ).toBeInTheDocument()
  })

  it('should say when another account has the email', async () => {
    vi.spyOn(profileApi, 'updateProfile').mockRejectedValue(
      new ApiError('email_taken', 'taken'),
    )
    const user = await openSettings()

    await user.clear(screen.getByLabelText('Email'))
    await user.type(screen.getByLabelText('Email'), 'other@clinic.test')
    await user.click(screen.getByRole('button', { name: 'Save changes' }))

    // Marked on the field, and said in a toast.
    expect(
      await within(screen.getByLabelText('Notifications')).findByText(
        'Another account already uses this email.',
      ),
    ).toBeInTheDocument()
    expect(screen.getAllByText('Another account already uses this email.')).toHaveLength(2)
  })

  it('should explain a network failure', async () => {
    vi.spyOn(profileApi, 'updateProfile').mockRejectedValue(new TypeError('fetch failed'))
    const user = await openSettings()

    await user.type(screen.getByLabelText('Phone (optional)'), '1')
    await user.click(screen.getByRole('button', { name: 'Save changes' }))

    expect(await screen.findByRole('alert')).toHaveTextContent('Cannot reach the clinic server')
  })

  describe('photo', () => {
    function pickPicture(render = vi.fn().mockResolvedValue(new Blob(['x'], { type: 'image/jpeg' }))) {
      const dispose = vi.fn()
      vi.spyOn(source, 'loadPicture').mockResolvedValue({
        url: 'blob:picture',
        width: 600,
        height: 400,
        render,
        dispose,
      })
      return { render, dispose }
    }

    async function choose(user: ReturnType<typeof userEvent.setup>, type = 'image/png') {
      await user.upload(
        screen.getByLabelText('Upload photo', { selector: 'input' }),
        new File(['a'], 'me.png', { type }),
      )
      return screen.findByRole('dialog', { name: 'Position your photo' })
    }

    it('should open the cropper, then upload the chosen square', async () => {
      const { render, dispose } = pickPicture()
      const upload = vi
        .spyOn(profileApi, 'uploadPhoto')
        .mockResolvedValue({ ...owner, photoVersion: 5 })
      vi.spyOn(profileApi, 'fetchPhoto').mockRejectedValue(new Error('none'))
      const user = await openSettings()

      const dialog = await choose(user)
      expect(upload).not.toHaveBeenCalled()
      await user.click(within(dialog).getByRole('button', { name: 'Save photo' }))

      expect(await screen.findByText('Photo updated.')).toBeInTheDocument()
      expect(upload).toHaveBeenCalledWith('tok', expect.any(Blob))
      // Untouched, the window shows the middle square of a 600 x 400 picture.
      const rect = render.mock.calls[0][0]
      expect(rect.size).toBeCloseTo(400)
      expect(rect.sx).toBeCloseTo(100)
      expect(rect.sy).toBeCloseTo(0)
      expect(screen.queryByRole('dialog')).toBeNull()
      expect(dispose).toHaveBeenCalled()
      expect(screen.getByRole('button', { name: 'Change photo' })).toBeInTheDocument()
      expect(screen.getByRole('button', { name: 'Remove photo' })).toBeInTheDocument()
    })

    it('should upload nothing when the cropper is cancelled', async () => {
      const { dispose } = pickPicture()
      const upload = vi.spyOn(profileApi, 'uploadPhoto')
      const user = await openSettings()

      const dialog = await choose(user)
      await user.click(within(dialog).getByRole('button', { name: 'Cancel' }))

      expect(screen.queryByRole('dialog')).toBeNull()
      expect(upload).not.toHaveBeenCalled()
      expect(dispose).toHaveBeenCalled()
    })

    it('should close the cropper on Escape', async () => {
      pickPicture()
      const user = await openSettings()
      await choose(user)

      await user.keyboard('{Escape}')

      expect(screen.queryByRole('dialog')).toBeNull()
    })

    it('should move the picture when it is dragged', async () => {
      const { render } = pickPicture()
      vi.spyOn(profileApi, 'uploadPhoto').mockResolvedValue({ ...owner, photoVersion: 5 })
      vi.spyOn(profileApi, 'fetchPhoto').mockRejectedValue(new Error('none'))
      const user = await openSettings()
      const dialog = await choose(user)
      const stage = within(dialog).getByTestId('crop-stage')

      // The window is 288 px (no layout in tests); the picture is 432 x 288 at zoom 1.
      fireEvent.pointerDown(stage, { pointerId: 1, clientX: 100, clientY: 100 })
      fireEvent.pointerMove(stage, { pointerId: 1, clientX: 60, clientY: 130 })
      fireEvent.pointerUp(stage, { pointerId: 1 })
      await user.click(within(dialog).getByRole('button', { name: 'Save photo' }))

      await screen.findByText('Photo updated.')
      const rect = render.mock.calls[0][0]
      // Dragged 40 px left: the window now looks 40 px further right.
      // Vertically the picture already fills the window, so it cannot move up or down.
      expect(rect.sx).toBeCloseTo(100 + (40 * 400) / 288, 0)
      expect(rect.sy).toBeCloseTo(0)
    })

    it('should not let the picture be dragged off the window', async () => {
      const { render } = pickPicture()
      vi.spyOn(profileApi, 'uploadPhoto').mockResolvedValue({ ...owner, photoVersion: 5 })
      vi.spyOn(profileApi, 'fetchPhoto').mockRejectedValue(new Error('none'))
      const user = await openSettings()
      const dialog = await choose(user)
      const stage = within(dialog).getByTestId('crop-stage')

      fireEvent.pointerDown(stage, { pointerId: 1, clientX: 0, clientY: 0 })
      fireEvent.pointerMove(stage, { pointerId: 1, clientX: 900, clientY: 0 })
      fireEvent.pointerUp(stage, { pointerId: 1 })
      await user.click(within(dialog).getByRole('button', { name: 'Save photo' }))

      await screen.findByText('Photo updated.')
      expect(render.mock.calls[0][0].sx).toBeCloseTo(0)
    })

    it('should zoom with the slider', async () => {
      const { render } = pickPicture()
      vi.spyOn(profileApi, 'uploadPhoto').mockResolvedValue({ ...owner, photoVersion: 5 })
      vi.spyOn(profileApi, 'fetchPhoto').mockRejectedValue(new Error('none'))
      const user = await openSettings()
      const dialog = await choose(user)

      fireEvent.change(within(dialog).getByRole('slider', { name: 'Zoom' }), {
        target: { value: '2' },
      })
      await user.click(within(dialog).getByRole('button', { name: 'Save photo' }))

      await screen.findByText('Photo updated.')
      // Twice as close: half the square, still centred.
      expect(render.mock.calls[0][0].size).toBeCloseTo(200)
      expect(render.mock.calls[0][0].sx).toBeCloseTo(200)
    })

    it('should zoom with two fingers', async () => {
      const { render } = pickPicture()
      vi.spyOn(profileApi, 'uploadPhoto').mockResolvedValue({ ...owner, photoVersion: 5 })
      vi.spyOn(profileApi, 'fetchPhoto').mockRejectedValue(new Error('none'))
      const user = await openSettings()
      const dialog = await choose(user)
      const stage = within(dialog).getByTestId('crop-stage')

      fireEvent.pointerDown(stage, { pointerId: 1, clientX: 100, clientY: 100 })
      fireEvent.pointerDown(stage, { pointerId: 2, clientX: 200, clientY: 100 })
      fireEvent.pointerMove(stage, { pointerId: 2, clientX: 300, clientY: 100 })
      fireEvent.pointerUp(stage, { pointerId: 2 })
      fireEvent.pointerUp(stage, { pointerId: 1 })
      await user.click(within(dialog).getByRole('button', { name: 'Save photo' }))

      await screen.findByText('Photo updated.')
      // The fingers went from 100 px to 200 px apart: zoom 2.
      expect(render.mock.calls[0][0].size).toBeCloseTo(200)
    })

    it('should zoom with the mouse wheel and nudge with the arrow keys', async () => {
      const { render } = pickPicture()
      vi.spyOn(profileApi, 'uploadPhoto').mockResolvedValue({ ...owner, photoVersion: 5 })
      vi.spyOn(profileApi, 'fetchPhoto').mockRejectedValue(new Error('none'))
      const user = await openSettings()
      const dialog = await choose(user)
      const stage = within(dialog).getByTestId('crop-stage')

      fireEvent.wheel(stage, { deltaY: -300 })
      stage.focus()
      await user.keyboard('{ArrowLeft}')
      await user.click(within(dialog).getByRole('button', { name: 'Save photo' }))

      await screen.findByText('Photo updated.')
      const rect = render.mock.calls[0][0]
      expect(rect.size).toBeLessThan(400)
      expect(rect.sx).toBeGreaterThan(100 + (400 - rect.size) / 2)
    })

    it('should refuse a file that is not a picture', async () => {
      const load = vi.spyOn(source, 'loadPicture')
      await openSettings()

      // `applyAccept: false`: the browser's file filter is bypassed on purpose.
      await userEvent
        .setup({ applyAccept: false })
        .upload(
          screen.getByLabelText('Upload photo', { selector: 'input' }),
          new File(['a'], 'notes.pdf', { type: 'application/pdf' }),
        )

      expect(await screen.findByText('Choose a JPEG, PNG or WebP picture.')).toBeInTheDocument()
      expect(load).not.toHaveBeenCalled()
    })

    it('should say so when the picture cannot be read', async () => {
      vi.spyOn(source, 'loadPicture').mockRejectedValue(new source.UnsupportedPictureError())
      const user = await openSettings()

      await user.upload(
        screen.getByLabelText('Upload photo', { selector: 'input' }),
        new File(['a'], 'broken.png', { type: 'image/png' }),
      )

      expect(await screen.findByText('Choose a JPEG, PNG or WebP picture.')).toBeInTheDocument()
      expect(screen.queryByRole('dialog')).toBeNull()
    })

    it('should remove the photo', async () => {
      vi.spyOn(authApi, 'getMe').mockResolvedValue({ ...owner, photoVersion: 5 })
      vi.spyOn(profileApi, 'fetchPhoto').mockRejectedValue(new Error('none'))
      const remove = vi.spyOn(profileApi, 'removePhoto').mockResolvedValue(owner)
      const user = await openSettings()

      await user.click(await screen.findByRole('button', { name: 'Remove photo' }))

      expect(await screen.findByText('Photo removed.')).toBeInTheDocument()
      expect(remove).toHaveBeenCalledWith('tok')
      await waitFor(() =>
        expect(screen.queryByRole('button', { name: 'Remove photo' })).toBeNull(),
      )
    })

    it('should say so when the tablet cannot save the photo', async () => {
      pickPicture()
      vi.spyOn(profileApi, 'uploadPhoto').mockRejectedValue(new ApiError('request_failed', 'x'))
      const user = await openSettings()

      const dialog = await choose(user)
      await user.click(within(dialog).getByRole('button', { name: 'Save photo' }))

      expect(await screen.findByText('The photo could not be saved. Try again.')).toBeInTheDocument()
      expect(screen.queryByRole('dialog')).toBeNull()
    })
  })

  describe('password', () => {
    async function fill(
      user: ReturnType<typeof userEvent.setup>,
      current: string,
      next: string,
      confirm = next,
    ) {
      const dialog = await openPasswordDialog(user)
      await user.type(within(dialog).getByLabelText('Current password'), current)
      await user.type(within(dialog).getByLabelText('New password'), next)
      await user.type(within(dialog).getByLabelText('Confirm password'), confirm)
      await user.click(within(dialog).getByRole('button', { name: 'Change password' }))
    }

    async function openPasswordDialog(user: ReturnType<typeof userEvent.setup>) {
      await user.click(screen.getByRole('button', { name: 'Change password' }))
      return screen.findByRole('dialog', { name: 'Change your password' })
    }

    it('should keep the form out of the page until asked for', async () => {
      await openSettings()

      expect(screen.queryByLabelText('Current password')).toBeNull()
      expect(screen.queryByRole('dialog')).toBeNull()
    })

    it('should open the form in a popup and close it with Cancel, X and Escape', async () => {
      const user = await openSettings()

      let dialog = await openPasswordDialog(user)
      await user.click(within(dialog).getByRole('button', { name: 'Cancel' }))
      expect(screen.queryByRole('dialog')).toBeNull()

      dialog = await openPasswordDialog(user)
      await user.click(within(dialog).getByRole('button', { name: 'Close' }))
      expect(screen.queryByRole('dialog')).toBeNull()

      await openPasswordDialog(user)
      await user.keyboard('{Escape}')
      expect(screen.queryByRole('dialog')).toBeNull()
    })

    it('should start the form empty each time it is opened', async () => {
      const user = await openSettings()
      let dialog = await openPasswordDialog(user)
      await user.type(within(dialog).getByLabelText('Current password'), 'something')
      await user.keyboard('{Escape}')

      dialog = await openPasswordDialog(user)

      expect(within(dialog).getByLabelText('Current password')).toHaveValue('')
    })

    it('should send the form from the footer button', async () => {
      const change = vi.spyOn(profileApi, 'changePassword').mockResolvedValue()
      const user = await openSettings()

      await fill(user, 'old-password-1', 'a-better-passphrase')

      expect(change).toHaveBeenCalledTimes(1)
    })

    it('should change the password and clear the fields', async () => {
      const change = vi.spyOn(profileApi, 'changePassword').mockResolvedValue()
      const user = await openSettings()

      await fill(user, 'old-password-1', 'a-better-passphrase')

      expect(
        await within(screen.getByLabelText('Notifications')).findByText(
          'Password changed. Your other sign-ins were ended.',
        ),
      ).toBeInTheDocument()
      expect(change).toHaveBeenCalledWith('tok', 'old-password-1', 'a-better-passphrase')
      expect(screen.queryByRole('dialog')).toBeNull()
    })

    it('should check the fields before asking the tablet', async () => {
      const change = vi.spyOn(profileApi, 'changePassword')
      const user = await openSettings()

      await fill(user, 'old-password-1', 'short', 'other')

      expect(screen.getByText('Use at least 8 characters.')).toBeInTheDocument()
      expect(screen.getByText('Passwords do not match.')).toBeInTheDocument()
      expect(change).not.toHaveBeenCalled()
      // The popup stays open, and a toast says why.
      expect(screen.getByRole('dialog')).toBeInTheDocument()
      expect(
        within(screen.getByLabelText('Notifications')).getByText(
          'Check the highlighted fields and try again.',
        ),
      ).toBeInTheDocument()
    })

    it('should ask for the current password', async () => {
      const user = await openSettings()
      const dialog = await openPasswordDialog(user)

      await user.click(within(dialog).getByRole('button', { name: 'Change password' }))

      expect(screen.getByText('Enter your current password.')).toBeInTheDocument()
    })

    it('should refuse a new password containing the username', async () => {
      const user = await openSettings()

      await fill(user, 'old-password-1', 'my-owner-password')

      expect(screen.getByText('Password must not contain your username.')).toBeInTheDocument()
    })

    it('should say when the current password is wrong', async () => {
      vi.spyOn(profileApi, 'changePassword').mockRejectedValue(
        new ApiError('current_password_wrong', 'no'),
      )
      const user = await openSettings()

      await fill(user, 'not-it-at-all', 'a-better-passphrase')

      expect(
        await within(screen.getByLabelText('Notifications')).findByText(
          'The current password is not correct.',
        ),
      ).toBeInTheDocument()
      expect(screen.getAllByText('The current password is not correct.')).toHaveLength(2)
      expect(screen.getByRole('dialog')).toBeInTheDocument()
      expect(screen.getByLabelText('New password')).toHaveValue('a-better-passphrase')
    })

    it('should tell how long to wait after too many wrong tries', async () => {
      vi.spyOn(profileApi, 'changePassword').mockRejectedValue(
        new ApiError('too_many_attempts', 'slow down', undefined, 45),
      )
      const user = await openSettings()

      await fill(user, 'not-it-at-all', 'a-better-passphrase')

      expect(await screen.findByRole('alert')).toHaveTextContent('Try again in 45 seconds')
    })

    it('should explain a network failure', async () => {
      vi.spyOn(profileApi, 'changePassword').mockRejectedValue(new TypeError('fetch failed'))
      const user = await openSettings()

      await fill(user, 'old-password-1', 'a-better-passphrase')

      expect(await screen.findByRole('alert')).toHaveTextContent('Cannot reach the clinic server')
    })
  })
})

describe('profile validation', () => {
  const ok = {
    firstName: 'Rafi',
    lastName: 'Ahmed',
    email: 'rafi@clinic.test',
    phone: '',
  }

  it('should accept good details and an empty phone', () => {
    expect(validateProfile(ok)).toEqual({})
  })

  it('should accept common phone formats', () => {
    expect(validateProfile({ ...ok, phone: '+880 1711-000000' })).toEqual({})
    expect(validateProfile({ ...ok, phone: '(02) 555.1234' })).toEqual({})
  })

  it('should refuse letters in a phone number', () => {
    expect(validateProfile({ ...ok, phone: 'call me' }).phone).toBe('errorPhoneInvalid')
  })

  it('should refuse names that are empty or too long', () => {
    expect(validateProfile({ ...ok, firstName: ' ' }).firstName).toBe('errorFirstNameRequired')
    expect(validateProfile({ ...ok, lastName: 'x'.repeat(65) }).lastName).toBe(
      'errorLastNameTooLong',
    )
  })
})
