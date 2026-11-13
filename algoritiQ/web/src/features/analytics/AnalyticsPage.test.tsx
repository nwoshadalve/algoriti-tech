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
import { afterEach, describe, expect, it, vi } from 'vitest'
import * as analyticsApi from '@/core/api/analytics'
import type { Analytics, AnalyticsTotals } from '@/core/api/analytics'
import * as chambersApi from '@/core/api/chambers'
import { LocaleProvider } from '@/core/i18n/LocaleProvider'
import * as session from '@/features/auth/session'
import { AnalyticsPage } from '@/features/analytics/AnalyticsPage'

const empty: AnalyticsTotals = {
  sessions: 0,
  tokens: 0,
  entered: 0,
  skipped: 0,
  cancelled: 0,
  notSeen: 0,
  feeBdt: 0,
  newPatients: 0,
  patients: 0,
  averageWaitSeconds: null,
  longestWaitSeconds: null,
  averageSessionMinutes: null,
}

/** A week (Monday 2 to Sunday 8 November 2026) with a busy Thursday. */
function week(overrides: Partial<Analytics> = {}): Analytics {
  const days = ['02', '03', '04', '05', '06', '07', '08']
  return {
    period: 'week',
    granularity: 'day',
    timeZone: 'Asia/Dhaka',
    fromDate: '2026-11-02',
    toDate: '2026-11-08',
    previousFromDate: '2026-10-26',
    previousToDate: '2026-11-01',
    totals: {
      ...empty,
      sessions: 3,
      tokens: 35,
      entered: 32,
      skipped: 1,
      cancelled: 1,
      notSeen: 1,
      feeBdt: 12_947,
      newPatients: 27,
      patients: 27,
      averageWaitSeconds: 3240,
      longestWaitSeconds: 7200,
      averageSessionMinutes: 150,
    },
    previous: { ...empty, tokens: 28, feeBdt: 10_000, newPatients: 30, averageWaitSeconds: 1800 },
    series: days.map((d, i) => ({
      ...empty,
      key: `2026-11-${d}`,
      tokens: i === 3 ? 27 : i === 4 ? 8 : 0,
      feeBdt: i === 3 ? 12_780 : 0,
    })),
    byQueue: [
      { ...empty, queueTypeId: 'regular', englishName: 'Regular', bengaliName: 'সাধারণ', tokens: 30, feeBdt: 10_000 },
      { ...empty, queueTypeId: 'report', englishName: 'Report', bengaliName: 'রিপোর্ট', tokens: 5, feeBdt: 2_947 },
    ],
    byChamber: [{ ...empty, chamberId: 'c1', name: 'Room 1', tokens: 35, feeBdt: 12_947, sessions: 3 }],
    byHour: Array.from({ length: 24 }, (_, hour) => ({ tokens: hour === 10 ? 12 : 0, feeBdt: 0 })),
    byWeekday: Array.from({ length: 7 }, (_, d) => ({ tokens: d === 3 ? 27 : 0, feeBdt: 0 })),
    ...overrides,
  }
}

function renderPage() {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } })
  return render(
    <LocaleProvider>
      <QueryClientProvider client={queryClient}>
        <AnalyticsPage />
      </QueryClientProvider>
    </LocaleProvider>,
  )
}

describe('AnalyticsPage', () => {
  afterEach(() => vi.restoreAllMocks())

  function mockApi(data: Analytics = week(), chambers = [{ id: 'c1', name: 'Room 1' }]) {
    vi.spyOn(session, 'readSession').mockReturnValue('tok')
    vi.spyOn(chambersApi, 'listChambers').mockResolvedValue(
      chambers.map((c) => ({ ...c, location: '', phone: '', patientIdPrefix: '776', patientIdNextSequence: 1 })),
    )
    return vi.spyOn(analyticsApi, 'getAnalytics').mockResolvedValue(data)
  }

  it('should open on the current week with its key figures', async () => {
    const getAnalytics = mockApi()

    renderPage()

    expect(await screen.findByTestId('kpi-tokens')).toHaveTextContent('35')
    expect(screen.getByTestId('kpi-seen')).toHaveTextContent('32')
    expect(screen.getByTestId('kpi-fees')).toHaveTextContent('৳12,947')
    expect(screen.getByTestId('kpi-new-patients')).toHaveTextContent('27')
    expect(screen.getByTestId('kpi-wait')).toHaveTextContent('54 min')
    expect(screen.getByText('Nov 2 – Nov 8, 2026')).toBeInTheDocument()
    expect(getAnalytics).toHaveBeenCalledWith('tok', { period: 'week', date: undefined, chamberId: undefined })
  })

  it('should say how each figure changed against the week before', async () => {
    mockApi()

    renderPage()

    await screen.findByTestId('kpi-tokens')
    // 35 against 28 is up 25%; the wait went up too, which is bad news.
    expect(screen.getByText('+25%')).toBeInTheDocument()
    expect(screen.getAllByText(/vs the week before/).length).toBeGreaterThan(0)
  })

  it('should ask for another period when a tab is pressed', async () => {
    const getAnalytics = mockApi()
    renderPage()
    await screen.findByTestId('kpi-tokens')

    await userEvent.click(screen.getByRole('button', { name: 'Monthly' }))

    await waitFor(() =>
      expect(getAnalytics).toHaveBeenLastCalledWith('tok', { period: 'month', date: undefined, chamberId: undefined }),
    )
    expect(screen.getByRole('button', { name: 'Monthly' })).toHaveAttribute('aria-pressed', 'true')
    expect(screen.getByRole('button', { name: 'Weekly' })).toHaveAttribute('aria-pressed', 'false')
  })

  it('should step to the period before and back to now', async () => {
    const getAnalytics = mockApi()
    renderPage()
    await screen.findByTestId('kpi-tokens')

    await userEvent.click(screen.getByRole('button', { name: 'Previous' }))

    await waitFor(() =>
      expect(getAnalytics).toHaveBeenLastCalledWith('tok', { period: 'week', date: '2026-11-01', chamberId: undefined }),
    )

    await userEvent.click(await screen.findByRole('button', { name: 'Back to now' }))

    await waitFor(() =>
      expect(getAnalytics).toHaveBeenLastCalledWith('tok', { period: 'week', date: undefined, chamberId: undefined }),
    )
  })

  it('should go to the first day of the period before for a month', async () => {
    const getAnalytics = mockApi(
      week({ period: 'month', granularity: 'day', fromDate: '2026-11-01', toDate: '2026-11-30' }),
    )
    renderPage()
    await screen.findByTestId('kpi-tokens')
    await userEvent.click(screen.getByRole('button', { name: 'Monthly' }))

    await userEvent.click(await screen.findByRole('button', { name: 'Previous' }))

    await waitFor(() =>
      expect(getAnalytics).toHaveBeenLastCalledWith('tok', { period: 'month', date: '2026-10-31', chamberId: undefined }),
    )
  })

  it('should have no previous and next for all time', async () => {
    mockApi(week({ period: 'all', granularity: 'year', fromDate: '2024-06-01', toDate: '2026-11-11', previous: null }))
    renderPage()
    await screen.findByTestId('kpi-tokens')

    await userEvent.click(screen.getByRole('button', { name: 'All time' }))

    await waitFor(() => expect(screen.queryByRole('button', { name: 'Previous' })).not.toBeInTheDocument())
  })

  it('should filter by chamber only when there is more than one', async () => {
    mockApi()
    const { unmount } = renderPage()
    await screen.findByTestId('kpi-tokens')
    expect(screen.queryByLabelText('Chamber')).not.toBeInTheDocument()
    unmount()

    const getAnalytics = mockApi(week(), [
      { id: 'c1', name: 'Room 1' },
      { id: 'c2', name: 'Room 2' },
    ])
    renderPage()
    await screen.findByTestId('kpi-tokens')

    await userEvent.selectOptions(await screen.findByLabelText('Chamber'), 'c2')

    await waitFor(() =>
      expect(getAnalytics).toHaveBeenLastCalledWith('tok', { period: 'week', date: undefined, chamberId: 'c2' }),
    )
  })

  it('should break the tokens down by queue', async () => {
    mockApi()
    renderPage()

    const heading = await screen.findByRole('heading', { name: 'By queue' })
    const card = heading.closest('section') as HTMLElement
    expect(within(card).getByText('Regular')).toBeInTheDocument()
    expect(within(card).getByText('Report')).toBeInTheDocument()
    expect(within(card).getByText('30')).toBeInTheDocument()
  })

  it('should offer every chart as a table of the same figures', async () => {
    mockApi()
    renderPage()
    const heading = await screen.findByRole('heading', { name: 'Tokens over time' })
    const card = heading.closest('section') as HTMLElement

    await userEvent.click(within(card).getByRole('button', { name: 'View as table' }))

    const table = within(card).getByRole('table')
    expect(within(table).getByText('Thu, Nov 5')).toBeInTheDocument()
    expect(within(table).getByText('27')).toBeInTheDocument()
    expect(within(table).getByText('৳12,780')).toBeInTheDocument()

    await userEvent.click(within(card).getByRole('button', { name: 'View as chart' }))
    expect(within(card).queryByRole('table')).not.toBeInTheDocument()
  })

  it('should name every column for a screen reader with its value', async () => {
    mockApi()
    renderPage()

    const heading = await screen.findByRole('heading', { name: 'Tokens over time' })
    const card = heading.closest('section') as HTMLElement

    expect(within(card).getByRole('button', { name: 'Thu, Nov 5: 27' })).toBeInTheDocument()
  })

  it('should say so, instead of an empty chart, when nothing was recorded', async () => {
    mockApi(
      week({
        totals: empty,
        previous: empty,
        series: week().series.map((p) => ({ ...p, tokens: 0, feeBdt: 0 })),
        byQueue: [],
        byChamber: [],
      }),
    )
    renderPage()

    expect((await screen.findAllByText('Nothing recorded in this period yet.')).length).toBeGreaterThan(0)
  })

  it('should offer a retry when the tablet cannot be reached', async () => {
    vi.spyOn(session, 'readSession').mockReturnValue('tok')
    vi.spyOn(chambersApi, 'listChambers').mockResolvedValue([])
    const getAnalytics = vi.spyOn(analyticsApi, 'getAnalytics').mockRejectedValueOnce(new Error('down'))
    renderPage()

    expect(await screen.findByText(/Could not load the analytics/)).toBeInTheDocument()
    getAnalytics.mockResolvedValue(week())
    await userEvent.click(screen.getByRole('button', { name: 'Try again' }))

    expect(await screen.findByTestId('kpi-tokens')).toHaveTextContent('35')
  })
})
