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
import * as doctorApi from '@/core/api/doctor'
import * as setupApi from '@/core/api/setup'
import type { Account, Doctor } from '@/core/api/types'
import { saveSession } from '@/features/auth/session'
import { parseDegrees, validateDoctor } from '@/features/doctor/doctorValidation'
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

const doctor: Doctor = {
  id: 'd1',
  name: 'Dr. Rahim',
  degrees: ['MBBS', 'FCPS'],
  designation: 'Professor',
  workplace: '',
  registrationNumber: 'A-1',
  specialty: 'Medicine',
  photoVersion: 0,
}

describe('doctor page', () => {
  beforeEach(() => {
    vi.spyOn(setupApi, 'getSetupStatus').mockResolvedValue({
      adminRegistered: true,
      claimCodeRequired: false,
    })
    saveSession('tok', new Date(Date.now() + 3_600_000).toISOString())
    vi.spyOn(authApi, 'getMe').mockResolvedValue(owner)
    vi.spyOn(doctorApi, 'getLicenseType').mockResolvedValue('doctor')
    vi.spyOn(doctorApi, 'getDoctor').mockResolvedValue(doctor)
  })

  afterEach(() => {
    vi.restoreAllMocks()
    sessionStorage.clear()
  })

  async function open() {
    renderAppAt('/doctor')
    await screen.findByLabelText('Name, with title')
    return userEvent.setup()
  }

  it('should show the doctor in a form, degrees on one line', async () => {
    await open()

    expect(screen.getByLabelText('Name, with title')).toHaveValue('Dr. Rahim')
    expect(screen.getByLabelText('Degrees')).toHaveValue('MBBS, FCPS')
    expect(screen.getByLabelText('Specialty')).toHaveValue('Medicine')
    expect(screen.getByLabelText('Registration number')).toHaveValue('A-1')
    expect(screen.getByRole('button', { name: 'Save changes' })).toBeDisabled()
  })

  it('should save, splitting the degrees, and say so in a toast', async () => {
    const save = vi.spyOn(doctorApi, 'saveDoctor').mockResolvedValue({
      ...doctor,
      name: 'Prof. Dr. Rahim',
      degrees: ['MBBS', 'FCPS', 'MD'],
    })
    const user = await open()

    await user.clear(screen.getByLabelText('Name, with title'))
    await user.type(screen.getByLabelText('Name, with title'), 'Prof. Dr. Rahim')
    await user.type(screen.getByLabelText('Degrees'), ' , MD')
    await user.click(screen.getByRole('button', { name: 'Save changes' }))

    await waitFor(() =>
      expect(save).toHaveBeenCalledWith('tok', {
        name: 'Prof. Dr. Rahim',
        degrees: ['MBBS', 'FCPS', 'MD'],
        designation: 'Professor',
        workplace: '',
        registrationNumber: 'A-1',
        specialty: 'Medicine',
      }),
    )
    expect(
      await within(screen.getByLabelText('Notifications')).findByText('Doctor information saved.'),
    ).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Save changes' })).toBeDisabled()
  })

  it('should need a name', async () => {
    const save = vi.spyOn(doctorApi, 'saveDoctor')
    const user = await open()

    await user.clear(screen.getByLabelText('Name, with title'))
    await user.click(screen.getByRole('button', { name: 'Save changes' }))

    expect(screen.getAllByText("Enter the doctor's name.").length).toBeGreaterThan(0)
    expect(save).not.toHaveBeenCalled()
    expect(
      within(screen.getByLabelText('Notifications')).getByText('Check the highlighted fields and try again.'),
    ).toBeInTheDocument()
  })

  it('should show a refusal from the tablet in a toast', async () => {
    vi.spyOn(doctorApi, 'saveDoctor').mockRejectedValue(new ApiError('doctor_too_many_degrees', 'x'))
    const user = await open()

    await user.type(screen.getByLabelText('Specialty'), ' more')
    await user.click(screen.getByRole('button', { name: 'Save changes' }))

    expect(
      await within(screen.getByLabelText('Notifications')).findByText('Use at most 12 degrees.'),
    ).toBeInTheDocument()
  })

  it('should put back what was saved with the discard icon', async () => {
    const user = await open()

    await user.type(screen.getByLabelText('Specialty'), ' more')
    await user.click(screen.getByRole('button', { name: 'Discard changes' }))

    expect(screen.getByLabelText('Specialty')).toHaveValue('Medicine')
  })

  it('should upload and remove the photo through the same card as Settings', async () => {
    vi.spyOn(doctorApi, 'fetchDoctorPhoto').mockRejectedValue(new Error('none'))
    const remove = vi.spyOn(doctorApi, 'removeDoctorPhoto').mockResolvedValue(doctor)
    vi.spyOn(doctorApi, 'getDoctor').mockResolvedValue({ ...doctor, photoVersion: 7 })
    const user = await open()

    await user.click(await screen.findByRole('button', { name: 'Remove photo' }))

    await waitFor(() => expect(remove).toHaveBeenCalledWith('tok'))
    expect(
      await within(screen.getByLabelText('Notifications')).findByText('Photo removed.'),
    ).toBeInTheDocument()
    expect(screen.getByRole('heading', { name: 'Doctor photo' })).toBeInTheDocument()
  })

  it('should explain when the doctor cannot be loaded', async () => {
    vi.spyOn(doctorApi, 'getDoctor').mockRejectedValue(new ApiError('doctor_unavailable', 'x'))
    renderAppAt('/doctor')

    expect(
      await within(screen.getByLabelText('Notifications')).findByText(
        "The doctor's information could not be loaded.",
      ),
    ).toBeInTheDocument()
  })

  describe('the menu', () => {
    it('should list the Doctor page for a doctor license', async () => {
      renderAppAt('/home')

      const nav = await screen.findByRole('navigation', { name: 'Dashboard sections' })

      expect(await within(nav).findByRole('link', { name: 'Doctor' })).toHaveAttribute('href', '/doctor')
    })

    it('should not list it for a chamber license, and send the page to the overview', async () => {
      vi.spyOn(doctorApi, 'getLicenseType').mockResolvedValue('chamber')
      renderAppAt('/doctor')

      expect(await screen.findByRole('heading', { name: 'Welcome back, The' })).toBeInTheDocument()
      const nav = screen.getByRole('navigation', { name: 'Dashboard sections' })
      expect(within(nav).queryByRole('link', { name: 'Doctor' })).toBeNull()
    })

    it('should not list it without a valid license', async () => {
      vi.spyOn(doctorApi, 'getLicenseType').mockResolvedValue(null)
      renderAppAt('/home')

      const nav = await screen.findByRole('navigation', { name: 'Dashboard sections' })
      await screen.findByRole('heading', { name: 'Welcome back, The' })

      expect(within(nav).queryByRole('link', { name: 'Doctor' })).toBeNull()
    })
  })
})

describe('doctor validation', () => {
  const ok = {
    name: 'Dr. Rahim',
    degrees: 'MBBS, FCPS',
    designation: '',
    workplace: '',
    registrationNumber: '',
    specialty: '',
  }

  it('should split degrees on commas, trimmed, dropping empties', () => {
    expect(parseDegrees(' MBBS ,, FCPS , ')).toEqual(['MBBS', 'FCPS'])
    expect(parseDegrees('')).toEqual([])
  })

  it('should accept good details', () => {
    expect(validateDoctor(ok)).toEqual({})
  })

  it('should need a name and refuse long values', () => {
    expect(validateDoctor({ ...ok, name: ' ' }).name).toBe('doctorErrorName')
    expect(validateDoctor({ ...ok, name: 'x'.repeat(121) }).name).toBe('doctorErrorTooLong')
    expect(validateDoctor({ ...ok, workplace: 'w'.repeat(201) }).workplace).toBe('doctorErrorTooLong')
  })

  it('should refuse more than twelve degrees or a very long one', () => {
    const many = Array.from({ length: 13 }, (_, i) => `D${i}`).join(',')

    expect(validateDoctor({ ...ok, degrees: many }).degrees).toBe('doctorErrorDegrees')
    expect(validateDoctor({ ...ok, degrees: 'd'.repeat(61) }).degrees).toBe('doctorErrorTooLong')
  })
})
