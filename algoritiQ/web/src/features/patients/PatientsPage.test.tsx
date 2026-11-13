/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, describe, expect, it, vi } from 'vitest'
import * as patientsApi from '@/core/api/patients'
import type { Account, PatientSummary } from '@/core/api/types'
import { LocaleProvider } from '@/core/i18n/LocaleProvider'
import { ToastProvider } from '@/core/toast/ToastProvider'
import { AuthContext } from '@/features/auth/authContext'
import * as session from '@/features/auth/session'
import { PatientsPage } from '@/features/patients/PatientsPage'
import { PatientsTable } from '@/features/patients/PatientsTable'

const admin: Account = {
  id: 'a1',
  username: 'admin',
  displayName: 'Admin User',
  firstName: 'Admin',
  lastName: 'User',
  email: 'admin@test',
  phone: '',
  photoVersion: 0,
  role: 'admin',
}

function patient(overrides: Partial<PatientSummary>): PatientSummary {
  return {
    id: 'p1',
    patientNumber: 1,
    clinicPatientId: '7761',
    name: 'Karim',
    phoneNormalized: '1711000000',
    ...overrides,
  }
}

function renderPage() {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } })
  return render(
    <LocaleProvider>
      <ToastProvider>
        <AuthContext.Provider
          value={{
            state: { status: 'signedIn', account: admin },
            signIn: vi.fn(),
            signInWithPin: vi.fn(),
            signOut: vi.fn(),
            updateAccount: vi.fn(),
          }}
        >
          <QueryClientProvider client={queryClient}>
            <PatientsPage />
          </QueryClientProvider>
        </AuthContext.Provider>
      </ToastProvider>
    </LocaleProvider>,
  )
}

describe('PatientsPage', () => {
  afterEach(() => {
    vi.restoreAllMocks()
    vi.unstubAllGlobals()
  })

  it('should filter by gender only, with no paper file filter', async () => {
    vi.spyOn(session, 'readSession').mockReturnValue('tok')
    vi.spyOn(patientsApi, 'listPatients').mockResolvedValue({ items: [patient({})], total: 1 })

    renderPage()

    await screen.findAllByText('Karim')
    expect(screen.getByLabelText('Gender')).toBeInTheDocument()
    expect(screen.queryByLabelText('Paper file')).not.toBeInTheDocument()
    expect(screen.queryByRole('checkbox')).not.toBeInTheDocument()
  })

  it('should show every patient registered next to the number shown', async () => {
    vi.spyOn(session, 'readSession').mockReturnValue('tok')
    vi.spyOn(patientsApi, 'listPatients').mockResolvedValue({
      items: [patient({})],
      total: 1,
      registeredTotal: 250,
    })

    renderPage()

    await waitFor(() => expect(screen.getByTestId('patients-total')).toHaveTextContent('250'))
    expect(screen.getByTestId('patients-shown')).toHaveTextContent('1')
  })

  it('should keep the total of all patients when a search narrows the list', async () => {
    vi.spyOn(session, 'readSession').mockReturnValue('tok')
    // An older tablet sends no registeredTotal, so the page must not borrow the filtered total.
    vi.spyOn(patientsApi, 'listPatients').mockImplementation(async (_token, query) =>
      query?.search
        ? { items: [patient({})], total: 1 }
        : { items: [patient({})], total: 27 },
    )

    renderPage()
    await waitFor(() => expect(screen.getByTestId('patients-total')).toHaveTextContent('27'))

    await userEvent.type(screen.getByRole('searchbox'), 'Karim')

    await waitFor(() => expect(screen.getByTestId('patients-shown')).toHaveTextContent('1'))
    expect(screen.getByTestId('patients-total')).toHaveTextContent('27')
  })

  it('should sort by a column heading and flip the order on a second press', async () => {
    vi.spyOn(session, 'readSession').mockReturnValue('tok')
    const list = vi.spyOn(patientsApi, 'listPatients').mockResolvedValue({
      items: [patient({})],
      total: 1,
    })

    renderPage()
    await screen.findAllByText('Karim')
    expect(screen.getByRole('columnheader', { name: /Registered/ })).toHaveAttribute('aria-sort', 'descending')

    await userEvent.click(screen.getByRole('button', { name: 'Sort by Visits' }))
    await waitFor(() =>
      expect(list).toHaveBeenLastCalledWith('tok', expect.objectContaining({ sort: 'visits', ascending: false })),
    )
    expect(screen.getByRole('columnheader', { name: /Visits/ })).toHaveAttribute('aria-sort', 'descending')

    await userEvent.click(screen.getByRole('button', { name: 'Sort by Visits' }))
    await waitFor(() =>
      expect(list).toHaveBeenLastCalledWith('tok', expect.objectContaining({ sort: 'visits', ascending: true })),
    )

    await userEvent.click(screen.getByRole('button', { name: 'Sort by Patient ID' }))
    await waitFor(() =>
      expect(list).toHaveBeenLastCalledWith('tok', expect.objectContaining({ sort: 'id', ascending: true })),
    )
  })

  it('should show the registration date of each patient', async () => {
    vi.spyOn(session, 'readSession').mockReturnValue('tok')
    vi.spyOn(patientsApi, 'listPatients').mockResolvedValue({
      items: [patient({ registeredAt: '2026-03-05T09:00:00.000Z' })],
      total: 1,
    })

    renderPage()

    expect((await screen.findAllByText(/Mar 5, 2026/)).length).toBeGreaterThan(0)
  })

  it('should show how many times each patient has visited and when last', async () => {
    vi.spyOn(session, 'readSession').mockReturnValue('tok')
    vi.spyOn(patientsApi, 'listPatients').mockResolvedValue({
      items: [
        patient({ id: 'p1', name: 'Karim', visitCount: 7, lastVisitAt: '2026-11-01T09:00:00.000Z' }),
        patient({ id: 'p2', name: 'Rina', clinicPatientId: '7762', visitCount: 0, lastVisitAt: null }),
      ],
      total: 2,
      registeredTotal: 2,
    })

    renderPage()

    expect(await screen.findAllByText('Karim')).not.toHaveLength(0)
    expect(screen.getAllByText('7').length).toBeGreaterThan(0)
    expect(screen.getAllByText('No visits yet').length).toBe(1)
  })
})

describe('PatientsTable paging', () => {
  afterEach(() => {
    vi.unstubAllGlobals()
  })

  function renderTable(props: { hasMore: boolean; moreFailed?: boolean; onLoadMore: () => void }) {
    return render(
      <LocaleProvider>
        <PatientsTable
          patients={[patient({})]}
          draftIds={new Set()}
          loadingMore={false}
          moreFailed={props.moreFailed ?? false}
          hasMore={props.hasMore}
          onLoadMore={props.onLoadMore}
          onEdit={vi.fn()}
          sort="registered"
          ascending={false}
          onSort={vi.fn()}
        />
      </LocaleProvider>,
    )
  }

  it('should load the next page when scrolling reaches the end of the table', () => {
    let reach: (entries: { isIntersecting: boolean }[]) => void = () => {}
    class FakeObserver {
      constructor(callback: typeof reach) {
        reach = callback
      }
      observe() {}
      disconnect() {}
    }
    vi.stubGlobal('IntersectionObserver', FakeObserver)
    const onLoadMore = vi.fn()

    renderTable({ hasMore: true, onLoadMore })
    reach([{ isIntersecting: true }])

    expect(onLoadMore).toHaveBeenCalledTimes(1)
  })

  it('should edit a patient with an icon button named after the patient', () => {
    const onEdit = vi.fn()
    render(
      <LocaleProvider>
        <PatientsTable
          patients={[patient({ name: 'Karim' })]}
          draftIds={new Set()}
          loadingMore={false}
          moreFailed={false}
          hasMore={false}
          onLoadMore={vi.fn()}
          onEdit={onEdit}
          sort="registered"
          ascending={false}
          onSort={vi.fn()}
        />
      </LocaleProvider>,
    )

    const edit = screen.getByRole('button', { name: 'Edit: Karim' })
    expect(edit.textContent).toBe('')
    edit.click()
    expect(onEdit).toHaveBeenCalledWith(expect.objectContaining({ name: 'Karim' }))
  })

  it('should keep the table in a fixed-height box that scrolls inside itself', () => {
    renderTable({ hasMore: false, onLoadMore: vi.fn() })

    const scroller = screen.getByRole('table').parentElement as HTMLElement
    expect(scroller.className).toMatch(/h-\[/)
    expect(scroller.className).toContain('overflow-auto')
    // A scroll trap would stop the page moving on phones.
    expect(scroller.className).not.toContain('overscroll-contain')
  })

  it('should offer a retry button when loading the next page failed', () => {
    renderTable({ hasMore: true, moreFailed: true, onLoadMore: vi.fn() })

    expect(screen.getByRole('button', { name: 'Try again' })).toBeInTheDocument()
  })
})
