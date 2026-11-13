/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import { afterEach, describe, expect, it, vi } from 'vitest'
import * as historyApi from '@/core/api/sessionHistory'
import type { SessionSummary } from '@/core/api/types'
import { LocaleProvider } from '@/core/i18n/LocaleProvider'
import * as session from '@/features/auth/session'
import { SessionHistoryPage } from '@/features/sessions/SessionHistoryPage'
import { formatRelativeDay } from '@/features/sessions/sessionFormat'
import { visibleDashboardNavLinks } from '@/app/dashboard/dashboardNav'

const ended: SessionSummary = {
  id: 's1',
  chamberId: 'c1',
  chamberName: 'Room 1',
  businessDate: '2026-11-04',
  status: 'CLOSED',
  openedAt: '2026-11-04T04:00:00.000Z',
  openedByName: 'Rina',
  closedAt: '2026-11-04T08:30:00.000Z',
  closedByName: 'Rina',
  counts: { ENTERED: 7, SKIPPED: 1, CANCELLED: 2, WAITING: 3 },
}

function renderPage() {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } })
  return render(
    <LocaleProvider>
      <QueryClientProvider client={queryClient}>
        <MemoryRouter>
          <SessionHistoryPage />
        </MemoryRouter>
      </QueryClientProvider>
    </LocaleProvider>,
  )
}

describe('SessionHistoryPage', () => {
  afterEach(() => vi.restoreAllMocks())

  it('should list earlier sessions with what happened in them', async () => {
    vi.spyOn(session, 'readSession').mockReturnValue('token')
    vi.spyOn(historyApi, 'listSessionHistory').mockResolvedValue({
      items: [ended],
      total: 1,
      chambers: [{ id: 'c1', name: 'Room 1' }],
    })

    renderPage()

    expect(await screen.findByText('Ended')).toBeInTheDocument()
    expect(screen.getByText('Tokens')).toBeInTheDocument()
    expect(screen.getByText('13')).toBeInTheDocument()
    expect(screen.getByText(/Opened by Rina/)).toBeInTheDocument()
    expect(screen.getByRole('link')).toHaveAttribute('href', '/session-history/s1')
  })

  it('should show a running session and each outcome at a glance', async () => {
    vi.spyOn(session, 'readSession').mockReturnValue('token')
    vi.spyOn(historyApi, 'listSessionHistory').mockResolvedValue({
      items: [{ ...ended, id: 's2', closedAt: null, closedByName: null }],
      total: 1,
      chambers: [{ id: 'c1', name: 'Room 1' }],
    })

    renderPage()

    expect(await screen.findByText('Running now')).toBeInTheDocument()
    expect(screen.getByText(/to now/)).toBeInTheDocument()
    for (const label of ['Entered', 'Missed', 'Cancelled', 'Not seen']) {
      expect(screen.getByText(label)).toBeInTheDocument()
    }
    expect(screen.getByText('7')).toBeInTheDocument()
  })

  it('should name the chamber only when there is more than one', async () => {
    vi.spyOn(session, 'readSession').mockReturnValue('token')
    vi.spyOn(historyApi, 'listSessionHistory').mockResolvedValue({
      items: [ended],
      total: 1,
      chambers: [
        { id: 'c1', name: 'Room 1' },
        { id: 'c2', name: 'Room 2' },
      ],
    })

    renderPage()

    expect(await screen.findByRole('heading', { level: 2 })).toBeInTheDocument()
    expect(screen.getAllByText('Room 1').length).toBeGreaterThan(0)
  })

  it('should show the total fees of a session on its card', async () => {
    vi.spyOn(session, 'readSession').mockReturnValue('token')
    vi.spyOn(historyApi, 'listSessionHistory').mockResolvedValue({
      items: [{ ...ended, totalFeeBdt: 12500 }],
      total: 1,
      chambers: [{ id: 'c1', name: 'Room 1' }],
    })

    renderPage()

    expect(await screen.findByTestId('session-fees')).toHaveTextContent('৳12,500')
    expect(screen.getByText('Total fees')).toBeInTheDocument()
  })

  it('should show how many patients were seen free on a session card', async () => {
    vi.spyOn(session, 'readSession').mockReturnValue('token')
    vi.spyOn(historyApi, 'listSessionHistory').mockResolvedValue({
      items: [{ ...ended, totalFeeBdt: 12500, freeCount: 3 }],
      total: 1,
      chambers: [{ id: 'c1', name: 'Room 1' }],
    })

    renderPage()

    expect(await screen.findByTestId('session-free')).toHaveTextContent('3')
    expect(screen.getByText('Free patients')).toBeInTheDocument()
  })

  it('should leave out the fees when the tablet does not send them', async () => {
    vi.spyOn(session, 'readSession').mockReturnValue('token')
    vi.spyOn(historyApi, 'listSessionHistory').mockResolvedValue({
      items: [ended],
      total: 1,
      chambers: [{ id: 'c1', name: 'Room 1' }],
    })

    renderPage()

    await screen.findByText('Ended')
    expect(screen.queryByTestId('session-fees')).not.toBeInTheDocument()
    expect(screen.queryByTestId('session-free')).not.toBeInTheDocument()
  })

  it('should say so when there are no sessions', async () => {
    vi.spyOn(session, 'readSession').mockReturnValue('token')
    vi.spyOn(historyApi, 'listSessionHistory').mockResolvedValue({
      items: [],
      total: 0,
      chambers: [],
    })

    renderPage()

    expect(await screen.findByText('No sessions in this period.')).toBeInTheDocument()
  })

  it('should call the last two days Today and Yesterday', () => {
    const now = new Date(2026, 10, 7, 12).getTime()

    expect(formatRelativeDay('en', new Date(2026, 10, 7, 1).toISOString(), now)).toBe('Today')
    expect(formatRelativeDay('en', new Date(2026, 10, 6, 23).toISOString(), now)).toBe('Yesterday')
    expect(formatRelativeDay('en', new Date(2026, 10, 5, 12).toISOString(), now)).toBe('')
  })

  it('should be in the menu of an admin and of a receptionist', () => {
    for (const role of ['admin', 'receptionist'] as const) {
      const links = visibleDashboardNavLinks(undefined, role).map((link) => link.to)
      expect(links).toContain('/session-history')
    }
  })
})
