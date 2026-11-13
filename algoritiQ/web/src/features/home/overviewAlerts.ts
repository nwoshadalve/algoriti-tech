/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { BackupEntry, BackupSchedule } from '@/core/api/backup'
import type { Monitoring, ServiceId } from '@/core/api/monitoring'
import type { SessionSummary } from '@/core/api/types'
import type { MessageKey } from '@/core/i18n/messages/types'

export type OverviewAlert = {
  id: string
  /** `critical` stops the clinic working; `warning` wants attention soon. */
  tone: 'critical' | 'warning'
  messageKey: MessageKey
  params?: Record<string, string | number>
  /** Where to go to deal with it. */
  to: string
}

const HOUR_MS = 3_600_000
const DAY_MS = 24 * HOUR_MS

/** A session left open this long is probably forgotten. */
export const longSessionHours = 20

/** Storage this full is close to stopping the tablet from saving. */
export const storageWarnPercent = 90

/** How old the newest backup may be before it counts as missing, by schedule. */
const staleAfterMs: Record<BackupSchedule, number> = {
  daily: 36 * HOUR_MS,
  weekly: 9 * DAY_MS,
  off: 7 * DAY_MS,
}

const serviceNameKey: Record<ServiceId, MessageKey> = {
  api: 'monitorApi',
  websocket: 'monitorWebsocket',
  androidService: 'monitorAndroid',
  printer: 'monitorPrinter',
  tv: 'monitorTv',
}

type AlertInput = {
  nowMs: number
  /** The tablet cannot be reached at all. */
  offline: boolean
  monitoring: Monitoring | undefined
  backupSchedule: BackupSchedule | undefined
  backups: BackupEntry[] | undefined
  openSessions: SessionSummary[]
  /** Names a service for a message, in the viewer's language. */
  serviceName: (key: MessageKey) => string
}

/**
 * What the admin should look at, most serious first. Each rule fires only on
 * data it actually has: a part that has not loaded yet raises nothing.
 */
export function buildOverviewAlerts(input: AlertInput): OverviewAlert[] {
  const alerts: OverviewAlert[] = []

  if (input.offline) {
    alerts.push({ id: 'offline', tone: 'critical', messageKey: 'overviewAlertOffline', to: '/monitoring' })
  }

  for (const service of input.monitoring?.services ?? []) {
    if (service.status === 'failed') {
      alerts.push({
        id: `service-${service.id}`,
        tone: 'critical',
        messageKey: 'overviewAlertServiceFailed',
        params: { name: input.serviceName(serviceNameKey[service.id]) },
        to: '/monitoring',
      })
    } else if (service.status === 'warning') {
      alerts.push({
        id: `service-${service.id}`,
        tone: 'warning',
        messageKey: 'overviewAlertServiceWarning',
        params: { name: input.serviceName(serviceNameKey[service.id]) },
        to: '/monitoring',
      })
    }
  }

  const storage = input.monitoring?.resources.storage
  if (storage && storage.percent !== undefined && storage.percent >= storageWarnPercent) {
    alerts.push({
      id: 'storage',
      tone: 'warning',
      messageKey: 'overviewAlertStorage',
      params: { percent: Math.round(storage.percent) },
      to: '/monitoring',
    })
  }

  for (const session of input.openSessions) {
    const hours = Math.floor((input.nowMs - Date.parse(session.openedAt)) / HOUR_MS)
    if (hours >= longSessionHours) {
      alerts.push({
        id: `session-${session.id}`,
        tone: 'warning',
        messageKey: 'overviewAlertLongSession',
        params: { chamber: session.chamberName, hours },
        to: `/session-history/${session.id}`,
      })
    }
  }

  // Backups: only once both the setting and the list are known.
  if (input.backupSchedule !== undefined && input.backups !== undefined) {
    const newest = input.backups.reduce<number | null>((best, entry) => {
      const at = Date.parse(entry.createdAt)
      return best === null || at > best ? at : best
    }, null)
    if (newest === null) {
      alerts.push({ id: 'backup-none', tone: 'warning', messageKey: 'overviewAlertBackupNone', to: '/backup' })
    } else if (input.nowMs - newest > staleAfterMs[input.backupSchedule]) {
      alerts.push({
        id: 'backup-stale',
        tone: 'warning',
        messageKey: 'overviewAlertBackupStale',
        params: { days: Math.floor((input.nowMs - newest) / DAY_MS) },
        to: '/backup',
      })
    }
    if (input.backupSchedule === 'off') {
      alerts.push({ id: 'backup-off', tone: 'warning', messageKey: 'overviewAlertBackupOff', to: '/backup' })
    }
  }

  const rank = { critical: 0, warning: 1 } as const
  return alerts.sort((a, b) => rank[a.tone] - rank[b.tone])
}

/** "3 hours ago", "yesterday", "2 days ago" in the viewer's language. */
export function formatAgo(locale: string, iso: string, nowMs: number): string {
  const seconds = Math.round((Date.parse(iso) - nowMs) / 1000)
  const rtf = new Intl.RelativeTimeFormat(locale, { numeric: 'auto' })
  const abs = Math.abs(seconds)
  if (abs < 60) return rtf.format(0, 'second')
  if (abs < 3600) return rtf.format(Math.round(seconds / 60), 'minute')
  if (abs < 86_400) return rtf.format(Math.round(seconds / 3600), 'hour')
  return rtf.format(Math.round(seconds / 86_400), 'day')
}

/** "queue.session.auto_closed" as "Queue session auto closed". */
export function humanizeAction(action: string): string {
  const text = action.replace(/[._]+/g, ' ').trim()
  return text.charAt(0).toUpperCase() + text.slice(1)
}
