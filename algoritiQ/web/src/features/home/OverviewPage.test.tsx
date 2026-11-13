/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { configure, screen, waitFor, within } from '@testing-library/react'
import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it, vi } from 'vitest'
import * as liveChannel from '@/core/api/LiveChannelProvider'
import * as analyticsApi from '@/core/api/analytics'
import type { Analytics, AnalyticsTotals } from '@/core/api/analytics'
import * as auditApi from '@/core/api/audit'
import * as authApi from '@/core/api/auth'
import * as backupApi from '@/core/api/backup'
import * as chambersApi from '@/core/api/chambers'
import * as monitoringApi from '@/core/api/monitoring'
import * as queueDeskApi from '@/core/api/queueDesk'
import * as sessionHistoryApi from '@/core/api/sessionHistory'
import * as setupApi from '@/core/api/setup'
import type { Account } from '@/core/api/types'
import { queryClient } from '@/core/query/queryClient'
import { saveSession } from '@/features/auth/session'
import { renderAppAt } from '@/test/render'

const owner: Account = {
  id: 'a1',
  username: 'nowshad',
  displayName: 'Nowshad Admin',
  firstName: 'Nowshad',
  lastName: 'Admin',
  phone: '',
  photoVersion: 0,
  email: 'nowshadalve@gmail.com',
  role: 'admin',
}

describe('overview page at 320px', () => {
  beforeEach(() => {
    vi.spyOn(setupApi, 'getSetupStatus').mockResolvedValue({
      adminRegistered: true,
      claimCodeRequired: false,
    })
    saveSession('tok', new Date(Date.now() + 3_600_000).toISOString())
    vi.spyOn(authApi, 'getMe').mockResolvedValue(owner)
    Object.defineProperty(window, 'innerWidth', { configurable: true, value: 320 })
    Object.defineProperty(document.documentElement, 'clientWidth', {
      configurable: true,
      value: 320,
    })
  })

  afterEach(() => {
    vi.restoreAllMocks()
    sessionStorage.clear()
    // The app shares one query cache; the next test must not see this one's answers.
    queryClient.clear()
  })

  it('should not scroll sideways with a long email in the header', async () => {
    renderAppAt('/home')

    expect(await screen.findByRole('heading', { name: 'Welcome back, Nowshad' })).toBeInTheDocument()
    expect(screen.getByText(/nowshadalve@gmail.com/)).toBeInTheDocument()

    expect(document.documentElement.scrollWidth).toBeLessThanOrEqual(
      document.documentElement.clientWidth + 1,
    )
  })
})

const zero: AnalyticsTotals = {
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

function analytics(period: 'day' | 'week', overrides: Partial<Analytics> = {}): Analytics {
  return {
    period,
    granularity: period === 'day' ? 'hour' : 'day',
    timeZone: 'Asia/Dhaka',
    fromDate: '2026-11-11',
    toDate: '2026-11-11',
    previousFromDate: '2026-11-10',
    previousToDate: '2026-11-10',
    totals: zero,
    previous: zero,
    series:
      period === 'day'
        ? Array.from({ length: 24 }, (_, h) => ({ ...zero, key: `2026-11-11T${String(h).padStart(2, '0')}` }))
        : ['09', '10', '11'].map((d) => ({ ...zero, key: `2026-11-${d}` })),
    byQueue: [],
    byChamber: [],
    byHour: Array.from({ length: 24 }, () => ({ tokens: 0, feeBdt: 0 })),
    byWeekday: Array.from({ length: 7 }, () => ({ tokens: 0, feeBdt: 0 })),
    ...overrides,
  }
}

describe('overview page for the admin', () => {
  // The page starts eight requests; a busy test run can be slow to answer them all.
  beforeAll(() => configure({ asyncUtilTimeout: 5000 }))
  afterAll(() => configure({ asyncUtilTimeout: 1000 }))

  beforeEach(() => {
    vi.spyOn(setupApi, 'getSetupStatus').mockResolvedValue({ adminRegistered: true, claimCodeRequired: false })
    saveSession('tok', new Date(Date.now() + 3_600_000).toISOString())
    vi.spyOn(authApi, 'getMe').mockResolvedValue(owner)
    Object.defineProperty(window, 'innerWidth', { configurable: true, value: 1280 })
    vi.spyOn(liveChannel, 'liveStateToHealth').mockReturnValue('connected')

    vi.spyOn(analyticsApi, 'getAnalytics').mockImplementation(async (_token, query) =>
      query.period === 'day'
        ? analytics('day', {
            totals: { ...zero, tokens: 20, entered: 15, skipped: 1, cancelled: 1, notSeen: 3, feeBdt: 9_000, newPatients: 4, averageWaitSeconds: 1200 },
            previous: { ...zero, tokens: 10, feeBdt: 6_000 },
          })
        : analytics('week'),
    )
    vi.spyOn(chambersApi, 'listChambers').mockResolvedValue([
      { id: 'c1', name: 'Room 1', location: '', phone: '', patientIdPrefix: '776', patientIdNextSequence: 1 },
      { id: 'c2', name: 'Room 2', location: '', phone: '', patientIdPrefix: '777', patientIdNextSequence: 1 },
    ])
    vi.spyOn(queueDeskApi, 'getQueueDeskSnapshot').mockImplementation(async (_token, chamberId) => ({
      chamberId,
      chamberName: chamberId === 'c1' ? 'Room 1' : 'Room 2',
      sessionId: chamberId === 'c1' ? 's1' : null,
      sessionOpen: chamberId === 'c1',
      calledToken: null,
      calledTokens:
        chamberId === 'c1'
          ? [
              {
                id: 't1',
                serial: 1004,
                queueTypeId: 'regular',
                queueEnglishName: 'Regular',
                queueBengaliName: 'Regular',
                patientId: 'p1',
                clinicPatientId: '7761',
                patientName: 'Karim',
                status: 'CALLED',
                issuedAt: '2026-11-11T04:00:00.000Z',
              },
            ]
          : [],
      queueControls:
        chamberId === 'c1'
          ? [
              { queueTypeId: 'regular', englishName: 'Regular', bengaliName: 'Regular', waitingCount: 3, nextSerial: 1005, canCallNext: true, canRecall: true },
              { queueTypeId: 'report', englishName: 'Report', bengaliName: 'Report', waitingCount: 1, nextSerial: 2001, canCallNext: true, canRecall: false },
            ]
          : [],
      tokens: [],
      printerBusyTokenId: null,
    }))
    vi.spyOn(sessionHistoryApi, 'listSessionHistory').mockResolvedValue({
      items: [
        {
          id: 's1',
          chamberId: 'c1',
          chamberName: 'Room 1',
          businessDate: '2026-11-11',
          status: 'OPEN',
          openedAt: new Date(Date.now() - 2 * 3_600_000).toISOString(),
          counts: {},
        },
      ],
      total: 1,
      chambers: [],
    })
    vi.spyOn(monitoringApi, 'getMonitoring').mockResolvedValue({
      generatedAt: new Date().toISOString(),
      deviceUptimeSeconds: 100,
      resources: {
        cpu: { status: 'ok' },
        ram: { status: 'ok', percent: 46 },
        storage: { status: 'ok', percent: 13 },
        bluetooth: { status: 'ok' },
      },
      services: [
        { id: 'printer', status: 'failed', retryable: true },
        { id: 'tv', status: 'ok', retryable: false },
        { id: 'api', status: 'ok', retryable: false },
      ],
    })
    vi.spyOn(backupApi, 'getBackupSettings').mockResolvedValue({ schedule: 'daily', retentionLimit: 14 })
    vi.spyOn(backupApi, 'listBackups').mockResolvedValue({
      backups: [
        { id: 'b1', createdAt: new Date(Date.now() - 3 * 3_600_000).toISOString(), sizeBytes: 1, kind: 'automatic' },
      ],
    })
    vi.spyOn(auditApi, 'listAuditLog').mockResolvedValue({
      entries: [
        {
          id: 1,
          occurredAt: new Date(Date.now() - 5 * 60_000).toISOString(),
          action: 'queue.session.auto_closed',
          category: 'session',
          outcome: 'success',
          actorDisplayName: null,
          actorRole: null,
          safeMetadata: {},
          detail: null,
        },
      ],
      total: 1,
      nextOffset: null,
    })
  })

  afterEach(() => {
    vi.restoreAllMocks()
    sessionStorage.clear()
    // The app shares one query cache; the next test must not see this one's answers.
    queryClient.clear()
  })

  it('should show how today is going against yesterday', async () => {
    renderAppAt('/home')

    await waitFor(() => expect(screen.getByTestId('overview-tokens')).toHaveTextContent('20'))
    expect(screen.getByTestId('overview-seen')).toHaveTextContent('15')
    expect(screen.getByTestId('overview-fees')).toHaveTextContent('৳9,000')
    expect(screen.getByTestId('overview-new-patients')).toHaveTextContent('4')
    expect(screen.getByTestId('overview-wait')).toHaveTextContent('20 min')
    // 20 against 10, and 9,000 against 6,000.
    expect(screen.getByText('+100%')).toBeInTheDocument()
    expect(screen.getByText('+50%')).toBeInTheDocument()
  })

  it('should count everyone waiting across the chambers', async () => {
    renderAppAt('/home')

    await waitFor(() => expect(screen.getByTestId('overview-waiting')).toHaveTextContent('4'))
    expect(screen.getByText('1 sessions open')).toBeInTheDocument()
  })

  it('should show each chamber, who is being called and who is waiting', async () => {
    renderAppAt('/home')

    const heading = await screen.findByRole('heading', { name: 'Live queue' })
    const panel = heading.closest('section') as HTMLElement
    expect(await within(panel).findByText('Room 1')).toBeInTheDocument()
    expect(within(panel).getByText('Room 2')).toBeInTheDocument()
    expect(await within(panel).findByText(/Running since/)).toBeInTheDocument()
    expect(within(panel).getByText('No session open')).toBeInTheDocument()
    expect(within(panel).getByText(/Now calling: .*Karim/)).toBeInTheDocument()
    expect(within(panel).getByText('3 waiting')).toBeInTheDocument()
    expect(within(panel).getByText('1 waiting')).toBeInTheDocument()
  })

  it('should say what needs attention, with a way to deal with it', async () => {
    renderAppAt('/home')

    const alert = await screen.findByRole('link', { name: 'POS printer is not working.' })
    expect(alert).toHaveAttribute('href', '/monitoring')
    // A backup three hours old on a daily schedule is fine, so it raises nothing.
    expect(screen.queryByText(/There is no backup yet|The last backup was|turned off/)).not.toBeInTheDocument()
  })

  it('should say everything is fine once the checks pass', async () => {
    vi.spyOn(monitoringApi, 'getMonitoring').mockResolvedValue({
      generatedAt: new Date().toISOString(),
      deviceUptimeSeconds: 100,
      resources: {
        cpu: { status: 'ok' },
        ram: { status: 'ok', percent: 46 },
        storage: { status: 'ok', percent: 13 },
        bluetooth: { status: 'ok' },
      },
      services: [{ id: 'printer', status: 'ok', retryable: true }],
    })

    renderAppAt('/home')

    expect(await screen.findByText('Everything is running normally.', {}, { timeout: 4000 })).toBeInTheDocument()
  })

  it('should say first of all when the tablet cannot be reached', async () => {
    vi.spyOn(liveChannel, 'liveStateToHealth').mockReturnValue('offline')

    renderAppAt('/home')

    const alert = await screen.findByRole('link', { name: /The tablet cannot be reached\. Check the clinic Wi/ })
    expect(alert).toHaveAttribute('href', '/monitoring')
  })

  it('should warn when a backup is overdue or automatic backup is off', async () => {
    vi.spyOn(backupApi, 'getBackupSettings').mockResolvedValue({ schedule: 'off', retentionLimit: 14 })
    vi.spyOn(backupApi, 'listBackups').mockResolvedValue({ backups: [] })

    renderAppAt('/home')

    expect(await screen.findByRole('link', { name: 'There is no backup yet.' }, { timeout: 4000 })).toHaveAttribute('href', '/backup')
    expect(screen.getByRole('link', { name: 'Automatic backup is turned off.' })).toBeInTheDocument()
  })

  it('should show the devices, the tablet and the last backup', async () => {
    renderAppAt('/home')

    const heading = await screen.findByRole('heading', { name: 'Devices and system' })
    const panel = heading.closest('section') as HTMLElement
    expect(await within(panel).findByText('POS printer')).toBeInTheDocument()
    expect(within(panel).getByText('Tablet storage')).toBeInTheDocument()
    expect(within(panel).getByText('13%')).toBeInTheDocument()
    expect(within(panel).getByText('Last backup 3 hours ago')).toBeInTheDocument()
    expect(within(panel).getByText('Automatic backup: Every day')).toBeInTheDocument()
  })

  it('should list the latest activity in words', async () => {
    renderAppAt('/home')

    expect(await screen.findByText('Queue session auto closed')).toBeInTheDocument()
    expect(screen.getByText('System')).toBeInTheDocument()
  })

  it('should lead to analytics and the other pages an admin uses', async () => {
    renderAppAt('/home')

    const heading = await screen.findByRole('heading', { name: 'Go to' })
    const panel = heading.closest('section') as HTMLElement
    expect(within(panel).getByRole('link', { name: 'Analytics' })).toHaveAttribute('href', '/analytics')
    expect(within(panel).getByRole('link', { name: 'Patients' })).toHaveAttribute('href', '/patients')
    expect(within(panel).getByRole('link', { name: 'Backup & restore' })).toHaveAttribute('href', '/backup')
  })

  it('should still draw the rest when one part cannot be loaded', async () => {
    vi.spyOn(auditApi, 'listAuditLog').mockRejectedValue(new Error('down'))

    renderAppAt('/home')

    await waitFor(() => expect(screen.getByTestId('overview-tokens')).toHaveTextContent('20'))
    expect(screen.getByRole('heading', { name: 'Recent activity' })).toBeInTheDocument()
  })
})
