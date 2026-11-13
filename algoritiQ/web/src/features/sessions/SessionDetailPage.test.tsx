/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter, Route, Routes } from 'react-router-dom'
import { afterEach, describe, expect, it, vi } from 'vitest'
import * as historyApi from '@/core/api/sessionHistory'
import type { BoardTokenView, SessionDetail } from '@/core/api/types'
import { LocaleProvider } from '@/core/i18n/LocaleProvider'
import * as session from '@/features/auth/session'
import { SessionDetailPage } from '@/features/sessions/SessionDetailPage'

const detail: SessionDetail = {
  session: {
    id: 's1',
    chamberId: 'c1',
    chamberName: 'Room 1',
    businessDate: '2026-11-04',
    status: 'CLOSED',
    openedAt: '2026-11-04T04:00:00.000Z',
    openedByName: 'Rina',
    closedAt: '2026-11-04T08:30:00.000Z',
    closedByName: 'Rina',
    firstCalledAt: '2026-11-04T04:10:00.000Z',
    lastCalledAt: '2026-11-04T08:00:00.000Z',
    counts: { ENTERED: 2, CANCELLED: 1 },
    totalFeeBdt: 1500,
  },
  queues: [
    {
      queueTypeId: 'regular',
      englishName: 'Regular',
      bengaliName: 'Regular',
      counts: { ENTERED: 2, CANCELLED: 1 },
      feeBdt: 1500,
    },
  ],
  patientCount: 3,
  averageWaitSeconds: 600,
  longestWaitSeconds: 1800,
}

function token(overrides: Partial<BoardTokenView>): BoardTokenView {
  return {
    id: 't1',
    serial: 1001,
    queueTypeId: 'regular',
    queueEnglishName: 'Regular',
    queueBengaliName: 'Regular',
    patientId: 'p1',
    clinicPatientId: '7761',
    patientName: 'Karim',
    status: 'ENTERED',
    issuedAt: '2026-11-04T04:00:00.000Z',
    firstCalledAt: '2026-11-04T04:10:00.000Z',
    feeBdt: 1000,
    ...overrides,
  }
}

function renderPage() {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } })
  return render(
    <LocaleProvider>
      <QueryClientProvider client={queryClient}>
        <MemoryRouter initialEntries={['/session-history/s1']}>
          <Routes>
            <Route path="/session-history/:sessionId" element={<SessionDetailPage />} />
          </Routes>
        </MemoryRouter>
      </QueryClientProvider>
    </LocaleProvider>,
  )
}

describe('SessionDetailPage', () => {
  afterEach(() => vi.restoreAllMocks())

  function mockApi(data: SessionDetail = detail) {
    vi.spyOn(session, 'readSession').mockReturnValue('token')
    vi.spyOn(historyApi, 'getSessionDetail').mockResolvedValue(data)
    vi.spyOn(historyApi, 'listSessionTokens').mockResolvedValue({
      items: [
        token({}),
        token({ id: 't2', serial: 1002, patientName: 'Rina', feeBdt: 500, firstCalledAt: null, status: 'WAITING' }),
        token({ id: 't3', serial: 1003, patientName: 'Salma', feeBdt: 300, status: 'CANCELLED' }),
      ],
      total: 3,
      counts: { ENTERED: 1, WAITING: 1, CANCELLED: 1 },
    })
  }

  it('should show the key figures of the session at a glance', async () => {
    mockApi()

    renderPage()

    expect(await screen.findByTestId('session-fees')).toHaveTextContent('৳1,500')
    expect(screen.getByText('Average wait')).toBeInTheDocument()
    expect(screen.getByText('Longest wait')).toBeInTheDocument()
    expect(screen.getByText('30 min')).toBeInTheDocument()
    expect(screen.getAllByText('10 min').length).toBeGreaterThan(0)
  })

  it('should show the fees of each queue', async () => {
    mockApi()

    renderPage()

    const heading = await screen.findByRole('heading', { name: 'By queue' })
    const section = heading.parentElement as HTMLElement
    expect(within(section).getByText('Regular')).toBeInTheDocument()
    // One for phones and one for the table; the page hides the other with CSS.
    expect(within(section).getAllByText('৳1,500').length).toBeGreaterThan(0)
  })

  it('should show each token with its fee and how long it waited', async () => {
    mockApi()

    renderPage()

    const table = await screen.findByRole('table', { name: 'Tokens of this session' })
    expect(within(table).getByText('৳1,000')).toBeInTheDocument()
    expect(within(table).getByText('৳500')).toBeInTheDocument()
    // A cancelled token paid nothing, so its fee is not shown.
    expect(within(table).queryByText('৳300')).not.toBeInTheDocument()
    // Karim and Salma waited 10 min; Rina was never called.
    expect(within(table).getAllByText('10 min')).toHaveLength(2)
  })

  it('should search the tokens by name, patient ID or token', async () => {
    mockApi()
    renderPage()
    await screen.findByRole('table', { name: 'Tokens of this session' })

    await userEvent.type(screen.getByRole('searchbox'), 'Karim')

    await waitFor(() =>
      expect(historyApi.listSessionTokens).toHaveBeenLastCalledWith(
        'token',
        's1',
        expect.objectContaining({ search: 'Karim' }),
      ),
    )
  })

  it('should say so when a search finds nothing', async () => {
    mockApi()
    renderPage()
    await screen.findByRole('table', { name: 'Tokens of this session' })
    vi.mocked(historyApi.listSessionTokens).mockResolvedValue({ items: [], total: 0, counts: {} })

    await userEvent.type(screen.getByRole('searchbox'), 'zzz')

    expect(await screen.findByText('No tokens match your search.')).toBeInTheDocument()
  })

  it('should sort by a column heading and flip the order on a second press', async () => {
    mockApi()
    renderPage()
    await screen.findByRole('table', { name: 'Tokens of this session' })
    const header = (name: string) => screen.getByRole('columnheader', { name })
    expect(header('Token')).toHaveAttribute('aria-sort', 'ascending')

    await userEvent.click(screen.getByRole('button', { name: 'Sort by Token' }))
    await waitFor(() =>
      expect(historyApi.listSessionTokens).toHaveBeenLastCalledWith(
        'token',
        's1',
        expect.objectContaining({ sort: 'serial', ascending: false }),
      ),
    )

    // Times start with the newest.
    await userEvent.click(screen.getByRole('button', { name: 'Sort by Issued' }))
    await waitFor(() =>
      expect(historyApi.listSessionTokens).toHaveBeenLastCalledWith(
        'token',
        's1',
        expect.objectContaining({ sort: 'issued', ascending: false }),
      ),
    )
    expect(header('Issued')).toHaveAttribute('aria-sort', 'descending')

    await userEvent.click(screen.getByRole('button', { name: 'Sort by Patient' }))
    await waitFor(() =>
      expect(historyApi.listSessionTokens).toHaveBeenLastCalledWith(
        'token',
        's1',
        expect.objectContaining({ sort: 'name', ascending: true }),
      ),
    )
  })

  it('should offer sorting as a menu for phones, which have no heading row', async () => {
    mockApi()
    renderPage()
    await screen.findByRole('table', { name: 'Tokens of this session' })

    await userEvent.selectOptions(screen.getByLabelText('Sort'), 'id')

    await waitFor(() =>
      expect(historyApi.listSessionTokens).toHaveBeenLastCalledWith(
        'token',
        's1',
        expect.objectContaining({ sort: 'id', ascending: true }),
      ),
    )
  })

  it('should leave out fees and waits the tablet does not send', async () => {
    mockApi({
      ...detail,
      session: { ...detail.session, totalFeeBdt: undefined },
      queues: [{ ...detail.queues[0]!, feeBdt: undefined }],
      patientCount: undefined,
      averageWaitSeconds: undefined,
      longestWaitSeconds: undefined,
    })
    vi.mocked(historyApi.listSessionTokens).mockResolvedValue({
      items: [token({ feeBdt: undefined })],
      total: 1,
      counts: { ENTERED: 1 },
    })

    renderPage()

    await screen.findByRole('table', { name: 'Tokens of this session' })
    expect(screen.queryByTestId('session-fees')).not.toBeInTheDocument()
    expect(screen.queryByText('Average wait')).not.toBeInTheDocument()
    expect(screen.queryByRole('columnheader', { name: 'Fee' })).not.toBeInTheDocument()
  })
})
