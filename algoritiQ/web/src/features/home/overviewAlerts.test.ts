/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { describe, expect, it } from 'vitest'
import type { BackupEntry } from '@/core/api/backup'
import type { HealthService, Monitoring } from '@/core/api/monitoring'
import type { SessionSummary } from '@/core/api/types'
import { buildOverviewAlerts, formatAgo, humanizeAction } from '@/features/home/overviewAlerts'

const NOW = Date.parse('2026-11-11T12:00:00.000Z')
const HOUR = 3_600_000

function monitoring(overrides: Partial<Monitoring> = {}, services: HealthService[] = []): Monitoring {
  return {
    generatedAt: '2026-11-11T12:00:00.000Z',
    deviceUptimeSeconds: 1000,
    resources: {
      cpu: { status: 'ok' },
      ram: { status: 'ok', percent: 40 },
      storage: { status: 'ok', percent: 30 },
      bluetooth: { status: 'ok' },
    },
    services,
    ...overrides,
  }
}

const backup = (hoursAgo: number): BackupEntry => ({
  id: 'b1',
  createdAt: new Date(NOW - hoursAgo * HOUR).toISOString(),
  sizeBytes: 1000,
  kind: 'automatic',
})

function session(hoursOpen: number): SessionSummary {
  return {
    id: 's1',
    chamberId: 'c1',
    chamberName: 'Room 1',
    businessDate: '2026-11-10',
    status: 'OPEN',
    openedAt: new Date(NOW - hoursOpen * HOUR).toISOString(),
    counts: {},
  }
}

function alerts(input: Partial<Parameters<typeof buildOverviewAlerts>[0]> = {}) {
  return buildOverviewAlerts({
    nowMs: NOW,
    offline: false,
    monitoring: monitoring(),
    backupSchedule: 'daily',
    backups: [backup(2)],
    openSessions: [],
    serviceName: (key) => key,
    ...input,
  })
}

describe('buildOverviewAlerts', () => {
  it('should raise nothing when everything is fine', () => {
    expect(alerts()).toEqual([])
  })

  it('should raise nothing for a part that has not loaded yet', () => {
    expect(alerts({ monitoring: undefined, backupSchedule: undefined, backups: undefined })).toEqual([])
  })

  it('should say the tablet cannot be reached, first of all', () => {
    const result = alerts({
      offline: true,
      backups: [],
    })

    expect(result[0]).toMatchObject({ id: 'offline', tone: 'critical' })
  })

  it('should name a service that stopped working', () => {
    const result = alerts({
      monitoring: monitoring({}, [{ id: 'printer', status: 'failed', retryable: true }]),
    })

    expect(result).toEqual([
      expect.objectContaining({
        id: 'service-printer',
        tone: 'critical',
        messageKey: 'overviewAlertServiceFailed',
        params: { name: 'monitorPrinter' },
      }),
    ])
  })

  it('should treat a service that needs a look as a warning, and one that is simply not connected as fine', () => {
    const result = alerts({
      monitoring: monitoring({}, [
        { id: 'tv', status: 'warning', retryable: false },
        { id: 'printer', status: 'unavailable', retryable: false },
      ]),
    })

    expect(result.map((a) => [a.id, a.tone])).toEqual([['service-tv', 'warning']])
  })

  it('should warn when the tablet storage is nearly full', () => {
    const result = alerts({
      monitoring: monitoring({
        resources: { ...monitoring().resources, storage: { status: 'warning', percent: 93 } },
      }),
    })

    expect(result).toEqual([
      expect.objectContaining({ id: 'storage', params: { percent: 93 } }),
    ])
  })

  it('should warn about a session that has been open too long', () => {
    expect(alerts({ openSessions: [session(19)] })).toEqual([])

    const result = alerts({ openSessions: [session(26)] })

    expect(result).toEqual([
      expect.objectContaining({
        id: 'session-s1',
        messageKey: 'overviewAlertLongSession',
        params: { chamber: 'Room 1', hours: 26 },
        to: '/session-history/s1',
      }),
    ])
  })

  describe('backups', () => {
    it('should say when there is no backup at all', () => {
      expect(alerts({ backups: [] }).map((a) => a.id)).toEqual(['backup-none'])
    })

    it('should say when automatic backup is off', () => {
      expect(alerts({ backupSchedule: 'off' }).map((a) => a.id)).toEqual(['backup-off'])
    })

    it('should say how old the newest backup is once a daily one is overdue', () => {
      const result = alerts({ backups: [backup(24 * 4)] })

      expect(result).toEqual([
        expect.objectContaining({ id: 'backup-stale', params: { days: 4 } }),
      ])
    })

    it('should give a weekly schedule a week and a bit before calling it overdue', () => {
      expect(alerts({ backupSchedule: 'weekly', backups: [backup(24 * 8)] })).toEqual([])
      expect(alerts({ backupSchedule: 'weekly', backups: [backup(24 * 10)] }).map((a) => a.id)).toEqual([
        'backup-stale',
      ])
    })

    it('should judge by the newest backup, not the oldest', () => {
      expect(alerts({ backups: [backup(24 * 9), backup(3)] })).toEqual([])
    })
  })

  it('should list the most serious first', () => {
    const result = alerts({
      backups: [],
      monitoring: monitoring({}, [{ id: 'api', status: 'failed', retryable: false }]),
    })

    expect(result.map((a) => a.tone)).toEqual(['critical', 'warning'])
  })
})

describe('formatAgo', () => {
  it('should say how long ago in words', () => {
    const at = (ms: number) => new Date(NOW - ms).toISOString()

    expect(formatAgo('en', at(20_000), NOW)).toBe('now')
    expect(formatAgo('en', at(26 * 60_000), NOW)).toBe('26 minutes ago')
    expect(formatAgo('en', at(3 * HOUR), NOW)).toBe('3 hours ago')
    expect(formatAgo('en', at(24 * HOUR), NOW)).toBe('yesterday')
    expect(formatAgo('en', at(5 * 24 * HOUR), NOW)).toBe('5 days ago')
  })
})

describe('humanizeAction', () => {
  it('should turn an action code into a sentence', () => {
    expect(humanizeAction('queue.session.auto_closed')).toBe('Queue session auto closed')
  })
})
