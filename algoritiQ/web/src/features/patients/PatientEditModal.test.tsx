/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { fireEvent, render, screen } from '@testing-library/react'
import { useState } from 'react'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import * as feeCodesApi from '@/core/api/feeCodes'
import * as patientsApi from '@/core/api/patients'
import type { BoardTokenView, PatientSummary } from '@/core/api/types'
import { LocaleProvider } from '@/core/i18n/LocaleProvider'
import { ToastProvider } from '@/core/toast/ToastProvider'
import * as session from '@/features/auth/session'
import { PatientEditModal } from '@/features/patients/PatientEditModal'
import { PatientDraftsProvider } from '@/features/patients/patientDrafts'

const patient: PatientSummary = {
  id: 'p1',
  patientNumber: 1,
  clinicPatientId: '7761',
  name: 'করিম',
  phoneNormalized: '1711000111',
  gender: 'male',
  ageLabel: '40',
}

/** A screen that opens and closes the form, as the person leaves and returns. */
function Harness() {
  const [open, setOpen] = useState(true)
  return (
    <>
      <button type="button" onClick={() => setOpen((v) => !v)}>
        toggle
      </button>
      {open ? <PatientEditModal patient={patient} onClose={() => setOpen(false)} onSaved={vi.fn()} /> : null}
    </>
  )
}

function withQueries(children: React.ReactNode) {
  const client = new QueryClient({ defaultOptions: { queries: { retry: false } } })
  return <QueryClientProvider client={client}>{children}</QueryClientProvider>
}

function renderHarness() {
  return render(
    <LocaleProvider>
      <ToastProvider>
        <PatientDraftsProvider>
          <Harness />
        </PatientDraftsProvider>
      </ToastProvider>
    </LocaleProvider>,
  )
}

const nameField = () => document.getElementById('desk-patient-name') as HTMLInputElement

describe('PatientEditModal draft', () => {
  it('should show no draft notice while the form is as saved', () => {
    renderHarness()

    expect(screen.queryByRole('status')).not.toBeInTheDocument()
    expect(nameField().value).toBe('করিম')
  })

  it('should bring back what was typed after the form is closed and reopened', () => {
    renderHarness()
    fireEvent.change(nameField(), { target: { value: 'করিম উদ্দিন' } })
    expect(screen.getByRole('status')).toBeInTheDocument()

    fireEvent.click(screen.getByText('toggle'))
    fireEvent.click(screen.getByText('toggle'))

    expect(nameField().value).toBe('করিম উদ্দিন')
    expect(screen.getByRole('status')).toHaveTextContent(/draft|খসড়া/i)
  })

  it('should go back to the saved details when the draft is discarded', () => {
    renderHarness()
    fireEvent.change(nameField(), { target: { value: 'অন্য' } })

    fireEvent.click(screen.getByRole('button', { name: /Discard draft|খসড়া বাতিল/i }))

    expect(nameField().value).toBe('করিম')
    fireEvent.click(screen.getByText('toggle'))
    fireEvent.click(screen.getByText('toggle'))
    expect(nameField().value).toBe('করিম')
  })

  it('should drop the draft once the patient is saved', async () => {
    vi.spyOn(session, 'readSession').mockReturnValue('token')
    vi.spyOn(patientsApi, 'updatePatient').mockResolvedValue(patient)
    renderHarness()
    fireEvent.change(nameField(), { target: { value: 'করিম উদ্দিন' } })

    fireEvent.click(screen.getByRole('button', { name: /Save changes|^সংরক্ষণ/i }))
    await vi.waitFor(() => expect(patientsApi.updatePatient).toHaveBeenCalled())
    fireEvent.click(screen.getByText('toggle'))
    fireEvent.click(screen.getByText('toggle'))

    expect(nameField().value).toBe('করিম')
  })
})

describe('PatientEditModal fee', () => {
  const token = { id: 'tok1', serial: 104, feeBdt: 500 } as BoardTokenView

  beforeEach(() => {
    vi.spyOn(session, 'readSession').mockReturnValue('token')
    // No fee codes: the fee is typed by hand, as before codes existed.
    vi.spyOn(feeCodesApi, 'getFeeCodes').mockResolvedValue([])
  })

  function renderWithFee(feeToken?: BoardTokenView) {
    return render(
      withQueries(
        <LocaleProvider>
          <ToastProvider>
            <PatientDraftsProvider>
              <PatientEditModal patient={patient} feeToken={feeToken} onClose={vi.fn()} onSaved={vi.fn()} />
            </PatientDraftsProvider>
          </ToastProvider>
        </LocaleProvider>,
      ),
    )
  }

  const feeField = () => document.getElementById('desk-patient-fee') as HTMLInputElement | null

  it('should offer the fee, filled in, when it is the patient of a token', () => {
    renderWithFee(token)

    expect(feeField()?.value).toBe('500')
  })

  it('should offer no fee when there is no token of the open session', () => {
    renderWithFee()

    expect(feeField()).toBeNull()
  })

  it('should save the new fee with the patient', async () => {
    vi.spyOn(session, 'readSession').mockReturnValue('token')
    const update = vi.spyOn(patientsApi, 'updatePatient').mockResolvedValue(patient)
    renderWithFee(token)

    fireEvent.change(feeField()!, { target: { value: '700' } })
    fireEvent.click(screen.getByRole('button', { name: /Save changes|^সংরক্ষণ/i }))

    await vi.waitFor(() => expect(update).toHaveBeenCalled())
    expect(update.mock.calls.at(-1)![2]).toMatchObject({ tokenId: 'tok1', feeBdt: 700 })
  })

  it('should clear the fee when it is emptied', async () => {
    vi.spyOn(session, 'readSession').mockReturnValue('token')
    const update = vi.spyOn(patientsApi, 'updatePatient').mockResolvedValue(patient)
    renderWithFee({ ...token, feeBdt: 300 })

    fireEvent.change(feeField()!, { target: { value: '' } })
    fireEvent.click(screen.getByRole('button', { name: /Save changes|^সংরক্ষণ/i }))

    await vi.waitFor(() => expect(update).toHaveBeenCalled())
    expect(update.mock.calls.at(-1)![2]).toMatchObject({ tokenId: 'tok1', feeBdt: null })
  })

  it('should not save a fee that is not a number', async () => {
    vi.spyOn(session, 'readSession').mockReturnValue('token')
    const update = vi.spyOn(patientsApi, 'updatePatient').mockResolvedValue(patient)
    update.mockClear()
    renderWithFee(token)

    fireEvent.change(feeField()!, { target: { value: 'abc' } })
    fireEvent.click(screen.getByRole('button', { name: /Save changes|^সংরক্ষণ/i }))

    expect(update).not.toHaveBeenCalled()
  })

  const freeToggle = () => document.getElementById('desk-patient-fee-free-toggle') as HTMLButtonElement

  it('should hide the fee and save a free visit when F is on', async () => {
    const update = vi.spyOn(patientsApi, 'updatePatient').mockResolvedValue(patient)
    renderWithFee(token)

    fireEvent.click(freeToggle())

    expect(feeField()).toBeNull()
    expect(freeToggle()).toHaveAttribute('aria-pressed', 'true')
    fireEvent.click(screen.getByRole('button', { name: /Save changes|^সংরক্ষণ/i }))
    await vi.waitFor(() => expect(update).toHaveBeenCalled())
    expect(update.mock.calls.at(-1)![2]).toMatchObject({ tokenId: 'tok1', feeBdt: null, isFree: true })
  })

  it('should start with F on and no fee for a token that is free', () => {
    renderWithFee({ ...token, feeBdt: null, isFree: true })

    expect(freeToggle()).toHaveAttribute('aria-pressed', 'true')
    expect(feeField()).toBeNull()
  })

  it('should bring the fee back, empty, when F is turned off', () => {
    renderWithFee(token)

    fireEvent.click(freeToggle())
    fireEvent.click(freeToggle())

    expect(feeField()?.value).toBe('')
  })

  it('should send no fee when the form has no token', async () => {
    vi.spyOn(session, 'readSession').mockReturnValue('token')
    const update = vi.spyOn(patientsApi, 'updatePatient').mockResolvedValue(patient)
    renderWithFee()

    fireEvent.click(screen.getByRole('button', { name: /Save changes|^সংরক্ষণ/i }))

    await vi.waitFor(() => expect(update).toHaveBeenCalled())
    expect(update.mock.calls.at(-1)![2]).not.toHaveProperty('tokenId')
  })
})
