/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { UseQueryResult } from '@tanstack/react-query'
import type { ReactNode } from 'react'
import { useId } from 'react'
import { Link } from 'react-router-dom'
import type { BackupEntry, BackupSchedule } from '@/core/api/backup'
import type { HealthResource, Monitoring, ServiceId } from '@/core/api/monitoring'
import type { AuditLogEntry, BoardSnapshot, Chamber, SessionSummary } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import type { MessageKey } from '@/core/i18n/messages/types'
import { AlertCircleIcon, CheckCircleIcon, ClockIcon, HardDriveIcon, MapPinIcon } from '@/core/ui/icons'
import { queueDisplayName } from '@/features/board/boardFormat'
import { formatQueueSerial } from '@/features/queue/formatQueueSerial'
import { StatusBadge } from '@/features/monitoring/StatusBadge'
import { serviceMeta } from '@/features/monitoring/serviceMeta'
import { formatAgo, humanizeAction, type OverviewAlert } from '@/features/home/overviewAlerts'
import { formatClock } from '@/features/sessions/sessionFormat'

/** A titled panel with an optional link on the right. */
export function Panel({
  title,
  subtitle,
  action,
  children,
  className = '',
}: {
  title: string
  subtitle?: string
  action?: { to: string; label: string }
  children: ReactNode
  className?: string
}) {
  const id = useId()
  return (
    <section
      aria-labelledby={id}
      className={`min-w-0 rounded-xl border border-brand-navy/10 bg-white p-4 shadow-sm sm:p-5 dark:border-white/10 dark:bg-brand-navy-raised dark:shadow-none ${className}`}
    >
      <div className="mb-4 flex flex-wrap items-start justify-between gap-x-3 gap-y-1">
        <div className="min-w-0">
          <h2 id={id} className="font-semibold">
            {title}
          </h2>
          {subtitle ? <p className="text-xs text-brand-navy/65 dark:text-white/65">{subtitle}</p> : null}
        </div>
        {action ? (
          <Link
            to={action.to}
            className="text-xs font-semibold text-brand-coral-action hover:underline focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none"
          >
            {action.label}
          </Link>
        ) : null}
      </div>
      {children}
    </section>
  )
}

/** What needs the admin's eye, or a calm line saying nothing does. */
export function AttentionPanel({ alerts, ready }: { alerts: OverviewAlert[]; ready: boolean }) {
  const { t } = useLocale()
  if (alerts.length === 0) {
    // Say "all good" only once the checks have had their data.
    if (!ready) return null
    return (
      <p
        role="status"
        className="flex items-center gap-2 rounded-xl border border-emerald-600/25 bg-emerald-50 px-4 py-3 text-sm font-medium text-emerald-950 dark:border-emerald-400/25 dark:bg-emerald-950/30 dark:text-emerald-100"
      >
        <CheckCircleIcon width={18} height={18} className="shrink-0" />
        {t('overviewAllGood')}
      </p>
    )
  }
  return (
    <section aria-label={t('overviewAttentionTitle')} className="space-y-2">
      <h2 className="text-sm font-semibold">{t('overviewAttentionTitle')}</h2>
      <ul className="grid gap-2 md:grid-cols-2">
        {alerts.map((alert) => (
          <li key={alert.id}>
            <Link
              to={alert.to}
              className={`flex h-full items-start gap-3 rounded-xl border px-4 py-3 text-sm hover:brightness-95 focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none ${
                alert.tone === 'critical'
                  ? 'border-red-500/40 bg-red-50 text-red-950 dark:border-red-400/40 dark:bg-red-950/30 dark:text-red-100'
                  : 'border-amber-500/40 bg-amber-50 text-amber-950 dark:border-amber-400/40 dark:bg-amber-950/30 dark:text-amber-100'
              }`}
            >
              <AlertCircleIcon width={18} height={18} className="mt-0.5 shrink-0" />
              <span className="min-w-0 font-medium">{t(alert.messageKey, alert.params)}</span>
            </Link>
          </li>
        ))}
      </ul>
    </section>
  )
}

type LiveQueueProps = {
  chambers: Chamber[]
  boards: UseQueryResult<BoardSnapshot>[]
  /** Sessions that are open now, any chamber. */
  openSessions: SessionSummary[]
}

/** One card per chamber: is a session running, who is being called, and how many wait in each queue. */
export function LiveQueuePanel({ chambers, boards, openSessions }: LiveQueueProps) {
  const { t, locale } = useLocale()
  if (chambers.length === 0) {
    return <p className="text-sm text-brand-navy/65 dark:text-white/65">{t('overviewNoChambers')}</p>
  }
  return (
    <ul className="grid gap-3 xl:grid-cols-2">
      {chambers.map((chamber, index) => {
        const board = boards[index]?.data
        const session = openSessions.find((s) => s.chamberId === chamber.id)
        const open = board?.sessionOpen ?? Boolean(session)
        const waiting = board?.queueControls.reduce((sum, control) => sum + control.waitingCount, 0) ?? 0
        return (
          <li
            key={chamber.id}
            className={`min-w-0 rounded-xl border p-3 sm:p-4 ${
              open
                ? 'border-emerald-500/40 dark:border-emerald-400/35'
                : 'border-brand-navy/10 dark:border-white/10'
            }`}
          >
            <div className="flex flex-wrap items-start justify-between gap-2">
              <div className="min-w-0">
                <p className="flex items-center gap-1.5 font-semibold">
                  <MapPinIcon width={15} height={15} className="shrink-0 text-brand-navy/60 dark:text-white/60" />
                  <span className="truncate">{chamber.name}</span>
                </p>
                <p className="mt-0.5 flex items-center gap-1.5 text-xs text-brand-navy/70 dark:text-white/70">
                  <ClockIcon width={13} height={13} className="shrink-0" />
                  {open
                    ? session
                      ? t('overviewSessionRunning', { time: formatClock(locale, session.openedAt) })
                      : t('overviewSessionOpen')
                    : t('overviewSessionClosed')}
                </p>
              </div>
              <span
                className={`inline-flex shrink-0 items-center gap-1.5 rounded-full border px-2.5 py-0.5 text-xs font-medium ${
                  open
                    ? 'border-emerald-600/30 bg-emerald-50 text-emerald-950 dark:border-emerald-400/30 dark:bg-emerald-950/30 dark:text-emerald-100'
                    : 'border-brand-navy/15 bg-brand-mist text-brand-navy/80 dark:border-white/15 dark:bg-white/10 dark:text-white/80'
                }`}
              >
                <span
                  aria-hidden="true"
                  className={`h-1.5 w-1.5 rounded-full bg-current ${open ? 'animate-pulse' : 'opacity-60'}`}
                />
                {open ? t('historyStatusOpen') : t('overviewSessionClosedShort')}
              </span>
            </div>

            {open && board ? (
              <>
                <p className="mt-3 text-xs font-medium text-brand-navy/65 dark:text-white/65">
                  {t('overviewWaitingCount', { count: waiting })}
                </p>
                <ul className="mt-2 divide-y divide-brand-navy/10 dark:divide-white/10">
                  {board.queueControls.map((control) => {
                    const called = board.calledTokens.find((token) => token.queueTypeId === control.queueTypeId)
                    return (
                      <li key={control.queueTypeId} className="flex items-center justify-between gap-3 py-2 text-sm">
                        <div className="min-w-0">
                          <p className="truncate font-medium">
                            {queueDisplayName(locale, control.englishName, control.bengaliName)}
                          </p>
                          <p className="truncate text-xs text-brand-navy/65 dark:text-white/65">
                            {called
                              ? `${t('overviewNowCalling')}: ${formatQueueSerial(called.serial, locale)} · ${called.patientName}`
                              : t('overviewNobodyCalled')}
                          </p>
                        </div>
                        <span className="shrink-0 rounded-full bg-brand-mist px-2.5 py-1 text-xs font-semibold tabular-nums dark:bg-white/10">
                          {t('overviewWaitingShort', { count: control.waitingCount })}
                        </span>
                      </li>
                    )
                  })}
                </ul>
              </>
            ) : null}
          </li>
        )
      })}
    </ul>
  )
}

/** A thin meter: green while there is room, amber when filling, red when nearly full. */
function Meter({ percent, label }: { percent: number; label: string }) {
  const { locale } = useLocale()
  const value = Math.max(0, Math.min(100, percent))
  const colour = value >= 90 ? 'bg-red-500' : value >= 75 ? 'bg-amber-500' : 'bg-emerald-500'
  return (
    <div>
      <div className="flex items-baseline justify-between text-sm">
        <span className="text-brand-navy/70 dark:text-white/70">{label}</span>
        <span className="font-semibold tabular-nums">{new Intl.NumberFormat(locale).format(Math.round(value))}%</span>
      </div>
      <div
        role="progressbar"
        aria-label={label}
        aria-valuemin={0}
        aria-valuemax={100}
        aria-valuenow={Math.round(value)}
        className="mt-1.5 h-2 w-full overflow-hidden rounded-full bg-brand-navy/10 dark:bg-white/10"
      >
        <div className={`h-full rounded-full ${colour}`} style={{ width: `${value}%` }} />
      </div>
    </div>
  )
}

const serviceOrder: ServiceId[] = ['printer', 'tv', 'api', 'websocket', 'androidService']

type HealthProps = {
  monitoring: Monitoring | undefined
  backupSchedule: BackupSchedule | undefined
  backups: BackupEntry[] | undefined
  nowMs: number
}

/** Devices and the tablet itself, at a glance: each part with its state, storage and memory, and the backup. */
export function HealthPanel({ monitoring, backupSchedule, backups, nowMs }: HealthProps) {
  const { t, locale } = useLocale()
  const services = serviceOrder
    .map((id) => monitoring?.services.find((service) => service.id === id))
    .filter((service) => service !== undefined)
  const resource = (r: HealthResource | undefined) => (r?.percent === undefined ? null : r.percent)
  const storage = resource(monitoring?.resources.storage)
  const memory = resource(monitoring?.resources.ram)
  const newest = (backups ?? []).reduce<string | null>(
    (best, entry) => (best === null || Date.parse(entry.createdAt) > Date.parse(best) ? entry.createdAt : best),
    null,
  )
  const scheduleKey: Record<BackupSchedule, MessageKey> = {
    off: 'backupScheduleOff',
    daily: 'backupScheduleDaily',
    weekly: 'backupScheduleWeekly',
  }

  return (
    <div className="space-y-4">
      {services.length === 0 ? (
        <p className="text-sm text-brand-navy/65 dark:text-white/65">{t('overviewHealthLoading')}</p>
      ) : (
        <ul className="space-y-2">
          {services.map((service) => {
            const meta = serviceMeta[service.id]
            const Icon = meta.icon
            return (
              <li key={service.id} className="flex items-center justify-between gap-3 text-sm">
                <span className="flex min-w-0 items-center gap-2">
                  <Icon width={16} height={16} className="shrink-0 text-brand-navy/60 dark:text-white/60" />
                  <span className="truncate">{t(meta.labelKey)}</span>
                </span>
                <StatusBadge status={service.status} />
              </li>
            )
          })}
        </ul>
      )}

      {storage !== null || memory !== null ? (
        <div className="space-y-3 border-t border-brand-navy/10 pt-4 dark:border-white/10">
          {storage !== null ? <Meter percent={storage} label={t('overviewStorage')} /> : null}
          {memory !== null ? <Meter percent={memory} label={t('overviewMemory')} /> : null}
        </div>
      ) : null}

      <div className="border-t border-brand-navy/10 pt-4 dark:border-white/10">
        <div className="flex items-center justify-between gap-3">
          <p className="flex items-center gap-2 text-sm font-medium">
            <HardDriveIcon width={16} height={16} className="shrink-0 text-brand-navy/60 dark:text-white/60" />
            {t('overviewBackupTitle')}
          </p>
          <Link
            to="/backup"
            className="text-xs font-semibold text-brand-coral-action hover:underline focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none"
          >
            {t('overviewManage')}
          </Link>
        </div>
        <p className="mt-1 text-sm text-brand-navy/75 dark:text-white/75">
          {backups === undefined
            ? t('overviewHealthLoading')
            : newest
              ? t('overviewBackupLast', { when: formatAgo(locale, newest, nowMs) })
              : t('overviewBackupNever')}
        </p>
        {backupSchedule ? (
          <p className="text-xs text-brand-navy/65 dark:text-white/65">
            {t('overviewBackupSchedule', { schedule: t(scheduleKey[backupSchedule]) })}
          </p>
        ) : null}
      </div>
    </div>
  )
}

/** The newest few audit entries: who did what, and when. */
export function ActivityPanel({ entries, nowMs }: { entries: AuditLogEntry[] | undefined; nowMs: number }) {
  const { t, locale } = useLocale()
  if (entries === undefined) {
    return <p className="text-sm text-brand-navy/65 dark:text-white/65">{t('overviewHealthLoading')}</p>
  }
  if (entries.length === 0) {
    return <p className="text-sm text-brand-navy/65 dark:text-white/65">{t('overviewActivityNone')}</p>
  }
  return (
    <ul className="divide-y divide-brand-navy/10 dark:divide-white/10">
      {entries.map((entry) => (
        <li key={entry.id} className="flex items-start justify-between gap-3 py-2.5 text-sm first:pt-0 last:pb-0">
          <div className="min-w-0">
            <p className="truncate font-medium">{humanizeAction(entry.action)}</p>
            <p className="truncate text-xs text-brand-navy/65 dark:text-white/65">
              {entry.actorDisplayName ?? t('overviewActivitySystem')}
              {entry.outcome !== 'success' ? ` · ${entry.outcome}` : ''}
            </p>
          </div>
          <time
            dateTime={entry.occurredAt}
            className="shrink-0 text-xs whitespace-nowrap text-brand-navy/65 dark:text-white/65"
          >
            {formatAgo(locale, entry.occurredAt, nowMs)}
          </time>
        </li>
      ))}
    </ul>
  )
}
