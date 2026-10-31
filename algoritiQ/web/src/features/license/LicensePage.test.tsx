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
import * as chambersApi from '@/core/api/chambers'
import { ApiError } from '@/core/api/client'
import * as doctorApi from '@/core/api/doctor'
import * as setupApi from '@/core/api/setup'
import * as workScopeApi from '@/core/api/workScope'
import type { Account, Chamber, LicenseSummary } from '@/core/api/types'
import { saveSession } from '@/features/auth/session'
import { validateChamber } from '@/features/license/chamberValidation'
import { queryClient } from '@/core/query/queryClient'
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

const license: LicenseSummary = {
  type: 'doctor',
  maxDoctors: 1,
  maxChambers: 3,
  chambersUsed: 2,
  issuedAt: '2026-01-10T00:00:00.000Z',
  expiresAt: null,
  status: 'active',
}

const main: Chamber = { id: 'c1', name: 'Main chamber', location: '12 Lake Road', phone: '01711000000' }
const evening: Chamber = { id: 'c2', name: 'Evening chamber', location: '4 Hill Street', phone: '01822000000' }

describe('license page', () => {
  let getLicense: MockInstance<typeof chambersApi.getLicense>
  let list: MockInstance<typeof chambersApi.listChambers>

  beforeEach(() => {
    queryClient.clear()
    vi.spyOn(setupApi, 'getSetupStatus').mockResolvedValue({
      adminRegistered: true,
      claimCodeRequired: false,
    })
    saveSession('tok', new Date(Date.now() + 3_600_000).toISOString())
    vi.spyOn(authApi, 'getMe').mockResolvedValue(owner)
    vi.spyOn(doctorApi, 'getLicenseType').mockResolvedValue('doctor')
    getLicense = vi.spyOn(chambersApi, 'getLicense').mockResolvedValue(license)
    list = vi.spyOn(chambersApi, 'listChambers').mockResolvedValue([main, evening])
  })

  afterEach(() => {
    vi.restoreAllMocks()
    sessionStorage.clear()
  })

  async function open() {
    renderAppAt('/config/chamber')
    await screen.findByRole('table', { name: 'Chambers' })
    return userEvent.setup()
  }

  const toasts = () => within(screen.getByLabelText('Notifications'))

  describe('the license', () => {
    it('should summarise the type, doctors, dates and chambers used', async () => {
      await open()

      expect(screen.getByText('Doctor license')).toBeInTheDocument()
      expect(screen.getByText('Active')).toBeInTheDocument()
      expect(screen.getByText('No end date')).toBeInTheDocument()
      expect(screen.getByTestId('chambers-used')).toHaveTextContent('2 of 3 used')
      const bar = screen.getByRole('progressbar', { name: 'Chambers' })
      expect(bar).toHaveAttribute('aria-valuenow', '2')
      expect(bar).toHaveAttribute('aria-valuemax', '3')
    })

    it('should show the end date and a warning status', async () => {
      getLicense.mockResolvedValue({ ...license, expiresAt: '2026-12-31T00:00:00.000Z', status: 'grace' })
      await open()

      expect(screen.getByText('Expired, in the grace period')).toBeInTheDocument()
      expect(screen.queryByText('No end date')).toBeNull()
    })
  })

  describe('the chambers', () => {
    it('should list them with address and phone, and icon actions named for each', async () => {
      await open()

      const table = screen.getByRole('table', { name: 'Chambers' })
      expect(within(table).getByText('Main chamber')).toBeInTheDocument()
      expect(within(table).getByText('4 Hill Street')).toBeInTheDocument()
      expect(within(table).getByText('01822000000')).toBeInTheDocument()
      expect(screen.getByRole('button', { name: 'Edit chamber: Main chamber' })).toBeInTheDocument()
      expect(screen.getByRole('button', { name: 'Delete chamber: Evening chamber' })).toBeEnabled()
    })

    it('should explain an icon with a tooltip', async () => {
      const user = await open()

      await user.hover(screen.getByRole('button', { name: 'Edit chamber: Main chamber' }))

      expect(await screen.findByRole('tooltip', { hidden: true })).toHaveTextContent('Edit chamber')
    })
  })

  describe('adding a chamber (popup)', () => {
    async function openAdd(user: ReturnType<typeof userEvent.setup>) {
      await user.click(screen.getByRole('button', { name: 'Add chamber' }))
      return screen.findByRole('dialog', { name: 'Add a chamber' })
    }

    async function fill(dialog: HTMLElement, user: ReturnType<typeof userEvent.setup>) {
      await user.type(within(dialog).getByLabelText('Chamber name'), '  Night chamber ')
      await user.type(within(dialog).getByLabelText('Address'), '9 River Lane')
      await user.type(within(dialog).getByLabelText('Phone number'), '01933000000')
    }

    it('should add it, say so in a toast and look again at the numbers', async () => {
      const create = vi.spyOn(chambersApi, 'createChamber').mockResolvedValue({ ...main, id: 'c3', name: 'Night chamber' })
      const user = await open()
      const dialog = await openAdd(user)
      await fill(dialog, user)
      const licenseCalls = getLicense.mock.calls.length

      await user.click(within(dialog).getByRole('button', { name: 'Add chamber' }))

      await waitFor(() =>
        expect(create).toHaveBeenCalledWith('tok', {
          name: 'Night chamber',
          location: '9 River Lane',
          phone: '01933000000',
        }),
      )
      expect(await toasts().findByText('Chamber added.')).toBeInTheDocument()
      expect(screen.queryByRole('dialog')).toBeNull()
      await waitFor(() => expect(getLicense.mock.calls.length).toBe(licenseCalls + 1))
      expect(screen.getByText('Night chamber')).toBeInTheDocument()
    })

    it('should need all three fields, and say so on the fields and in a toast', async () => {
      const create = vi.spyOn(chambersApi, 'createChamber')
      const user = await open()
      const dialog = await openAdd(user)

      await user.click(within(dialog).getByRole('button', { name: 'Add chamber' }))

      expect(within(dialog).getByText('Enter the chamber name.')).toBeInTheDocument()
      expect(within(dialog).getByText('Enter the address.')).toBeInTheDocument()
      expect(within(dialog).getByText('Enter the phone number.')).toBeInTheDocument()
      expect(create).not.toHaveBeenCalled()
      expect(toasts().getByText('Check the highlighted fields and try again.')).toBeInTheDocument()
    })

    it('should stay open and explain when the tablet says the license is full', async () => {
      vi.spyOn(chambersApi, 'createChamber').mockRejectedValue(new ApiError('chamber_limit_reached', 'x'))
      const user = await open()
      const dialog = await openAdd(user)
      await fill(dialog, user)
      const calls = getLicense.mock.calls.length

      await user.click(within(dialog).getByRole('button', { name: 'Add chamber' }))

      expect(await toasts().findByText('The license allows no more chambers.')).toBeInTheDocument()
      expect(screen.getByRole('dialog')).toBeInTheDocument()
      // The page looks again, so the numbers are not out of date.
      await waitFor(() => expect(getLicense.mock.calls.length).toBe(calls + 1))
    })

    it('should mark the field when the tablet refuses the phone number', async () => {
      vi.spyOn(chambersApi, 'createChamber').mockRejectedValue(new ApiError('chamber_phone_invalid', 'x'))
      const user = await open()
      const dialog = await openAdd(user)
      await fill(dialog, user)

      await user.click(within(dialog).getByRole('button', { name: 'Add chamber' }))

      expect(await within(dialog).findByText('Use digits, spaces, + and - only.')).toBeInTheDocument()
    })

    it('should close with Cancel without saving', async () => {
      const create = vi.spyOn(chambersApi, 'createChamber')
      const user = await open()
      const dialog = await openAdd(user)

      await user.click(within(dialog).getByRole('button', { name: 'Cancel' }))

      expect(screen.queryByRole('dialog')).toBeNull()
      expect(create).not.toHaveBeenCalled()
    })
  })

  describe('the limit', () => {
    beforeEach(() => {
      getLicense.mockResolvedValue({ ...license, chambersUsed: 3 })
      list.mockResolvedValue([main, evening, { ...main, id: 'c3', name: 'Night chamber' }])
    })

    it('should disable Add when the license is full, and say why in a tooltip', async () => {
      const user = await open()

      const add = screen.getByRole('button', { name: 'Add chamber' })
      expect(add).toBeDisabled()
      expect(screen.getByTestId('chambers-used')).toHaveTextContent('3 of 3 used')
      await user.hover(add.parentElement as HTMLElement)

      expect(await screen.findByRole('tooltip', { hidden: true })).toHaveTextContent(
        'Your license allows 3 chambers. Delete one to add another.',
      )
    })
  })

  describe('editing a chamber (popup)', () => {
    it('should open with the details and save the changes', async () => {
      const update = vi
        .spyOn(chambersApi, 'updateChamber')
        .mockResolvedValue({ ...main, name: 'Main chamber (new)' })
      const user = await open()

      await user.click(screen.getByRole('button', { name: 'Edit chamber: Main chamber' }))
      const dialog = await screen.findByRole('dialog', { name: 'Edit chamber' })
      expect(within(dialog).getByLabelText('Chamber name')).toHaveValue('Main chamber')
      await user.type(within(dialog).getByLabelText('Chamber name'), ' (new)')
      await user.click(within(dialog).getByRole('button', { name: 'Save changes' }))

      await waitFor(() =>
        expect(update).toHaveBeenCalledWith('tok', 'c1', {
          name: 'Main chamber (new)',
          location: '12 Lake Road',
          phone: '01711000000',
        }),
      )
      expect(await toasts().findByText('Chamber saved.')).toBeInTheDocument()
    })
  })

  describe('deleting a chamber', () => {
    it('should ask first, naming the chamber, then delete and look again', async () => {
      const remove = vi.spyOn(chambersApi, 'deleteChamber').mockResolvedValue()
      const user = await open()

      await user.click(screen.getByRole('button', { name: 'Delete chamber: Evening chamber' }))
      const dialog = await screen.findByRole('dialog', { name: 'Delete this chamber?' })
      expect(within(dialog).getByText(/Evening chamber will be removed/)).toBeInTheDocument()
      expect(remove).not.toHaveBeenCalled()
      const licenseCalls = getLicense.mock.calls.length
      await user.click(within(dialog).getByRole('button', { name: 'Delete chamber' }))

      await waitFor(() => expect(remove).toHaveBeenCalledWith('tok', 'c2'))
      expect(await toasts().findByText('Chamber deleted.')).toBeInTheDocument()
      await waitFor(() => expect(getLicense.mock.calls.length).toBe(licenseCalls + 1))
      expect(screen.queryByRole('cell', { name: 'Evening chamber' })).toBeNull()
    })

    it('should do nothing when the question is cancelled', async () => {
      const remove = vi.spyOn(chambersApi, 'deleteChamber')
      const user = await open()

      await user.click(screen.getByRole('button', { name: 'Delete chamber: Evening chamber' }))
      await user.click(within(await screen.findByRole('dialog')).getByRole('button', { name: 'Cancel' }))

      expect(remove).not.toHaveBeenCalled()
    })

    it('should not offer to delete the only chamber, and say why', async () => {
      list.mockResolvedValue([main])
      getLicense.mockResolvedValue({ ...license, chambersUsed: 1 })
      const user = await open()

      const button = screen.getByRole('button', { name: 'Delete chamber: Main chamber' })
      expect(button).toBeDisabled()
      await user.hover(button.parentElement as HTMLElement)

      expect(await screen.findByRole('tooltip', { hidden: true })).toHaveTextContent(
        'A doctor needs at least one chamber.',
      )
    })

    it('should explain when the tablet refuses', async () => {
      vi.spyOn(chambersApi, 'deleteChamber').mockRejectedValue(new ApiError('last_chamber', 'x'))
      const user = await open()

      await user.click(screen.getByRole('button', { name: 'Delete chamber: Evening chamber' }))
      await user.click(
        within(await screen.findByRole('dialog')).getByRole('button', { name: 'Delete chamber' }),
      )

      expect(
        await toasts().findByText('A doctor needs at least one chamber, so the last one cannot be deleted.'),
      ).toBeInTheDocument()
    })
  })

  describe('who sees it', () => {
    it('should send a chamber license to the overview and hide the menu item', async () => {
      vi.spyOn(doctorApi, 'getLicenseType').mockResolvedValue('chamber')
      renderAppAt('/config/chamber')

      expect(await screen.findByRole('heading', { name: 'Welcome back, The' })).toBeInTheDocument()
      const nav = screen.getByRole('navigation', { name: 'Dashboard sections' })
      expect(within(nav).queryByRole('link', { name: 'Chambers' })).toBeNull()
    })

    it('should list Chambers in the menu for a doctor license', async () => {
      renderAppAt('/home')
      const user = userEvent.setup()

      const nav = await screen.findByRole('navigation', { name: 'Dashboard sections' })
      await user.click(within(nav).getByRole('button', { name: 'Conf' }))

      expect(await within(nav).findByRole('link', { name: 'Chambers' })).toHaveAttribute(
        'href',
        '/config/chamber',
      )
    })

    it('should send a receptionist to the overview', async () => {
      vi.spyOn(authApi, 'getMe').mockResolvedValue({ ...owner, role: 'receptionist' })
      vi.spyOn(workScopeApi, 'getWorkScopes').mockResolvedValue({
        assignmentTarget: 'chamber',
        assignmentCount: 1,
        options: [{ id: 'c1', name: 'Main chamber', detail: '12 Lake Road' }],
      })
      renderAppAt('/config/chamber')

      expect(await screen.findByRole('heading', { name: 'Welcome back, The' })).toBeInTheDocument()
      expect(getLicense).not.toHaveBeenCalled()
    })
  })

  it('should offer a retry when the license cannot be loaded', async () => {
    getLicense.mockRejectedValue(new ApiError('request_failed', 'x'))
    renderAppAt('/config/chamber')

    // In the page, with the retry button, and in a toast.
    expect(await screen.findByRole('button', { name: 'Try again' })).toBeInTheDocument()
    expect(await toasts().findByText('The license could not be loaded.')).toBeInTheDocument()
    getLicense.mockResolvedValue(license)
    await userEvent.setup().click(screen.getByRole('button', { name: 'Try again' }))

    expect(await screen.findByRole('table', { name: 'Chambers' })).toBeInTheDocument()
  })

  describe('at 320px', () => {
    it('should not scroll sideways with long Bengali chamber details', async () => {
      list.mockResolvedValue([
        {
          id: 'c1',
          name: 'আল-খিদমাহ্ মেডিকেল সার্ভিসেস (প্রাঃ), চাঁদপুর',
          location: '৬/১, আমেরী ম্যানশন, স্টেডিয়াম রোড, চাঁদপুর',
          phone: '01766521717',
        },
      ])
      Object.defineProperty(window, 'innerWidth', { configurable: true, value: 320 })
      Object.defineProperty(document.documentElement, 'clientWidth', {
        configurable: true,
        value: 320,
      })

      await open()

      expect(document.documentElement.scrollWidth).toBeLessThanOrEqual(
        document.documentElement.clientWidth + 1,
      )
    })
  })
})

describe('chamber validation', () => {
  const ok = { name: 'Main', location: '12 Lake Road', phone: '+880 1711-000000' }

  it('should accept good details', () => {
    expect(validateChamber(ok)).toEqual({})
  })

  it('should need all three', () => {
    expect(validateChamber({ name: ' ', location: ' ', phone: ' ' })).toEqual({
      name: 'chamberErrorName',
      location: 'chamberErrorAddress',
      phone: 'chamberErrorPhone',
    })
  })

  it('should refuse long values and letters in the phone', () => {
    expect(validateChamber({ ...ok, name: 'x'.repeat(121) }).name).toBe('doctorErrorTooLong')
    expect(validateChamber({ ...ok, location: 'l'.repeat(201) }).location).toBe('doctorErrorTooLong')
    expect(validateChamber({ ...ok, phone: 'call me' }).phone).toBe('errorPhoneInvalid')
  })
})
