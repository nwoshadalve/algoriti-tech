/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useState } from 'react'
import { Link } from 'react-router-dom'
import { liveStateToHealth, useLiveChannel } from '@/core/api/LiveChannelProvider'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { roleLabelKey } from '@/core/i18n/roleLabel'
import type { MessageKey } from '@/core/i18n/messages/types'
import { secondaryButton } from '@/core/ui/buttonStyles'
import {
  AnalyticsIcon,
  BanknoteIcon,
  CheckCircleIcon,
  HistoryIcon,
  PersonAddIcon,
  PersonIcon,
  QueueIcon,
  QueueDeskIcon,
  UsersIcon,
  ActivityIcon,
  HardDriveIcon,
} from '@/core/ui/icons'
import { PageHeader } from '@/core/ui/PageHeader'
import { useAuth } from '@/features/auth/authContext'
import { ColumnChart } from '@/features/analytics/charts/ColumnChart'
import { Delta } from '@/features/analytics/charts/Delta'
import { change, compact, pointLabel, pointTitle } from '@/features/analytics/analyticsFormat'
import { KpiTile } from '@/features/analytics/KpiTile'
import { ActivityPanel, AttentionPanel, HealthPanel, LiveQueuePanel, Panel } from '@/features/home/OverviewPanels'
import { buildOverviewAlerts } from '@/features/home/overviewAlerts'
import { useOverview } from '@/features/home/useOverview'
import { OutcomeSummary } from '@/features/sessions/SessionStats'
import { formatBdt, formatWait } from '@/features/sessions/sessionFormat'

const statusStyle = {
  connected: 'bg-emerald-500',
  checking: 'animate-pulse bg-brand-navy/35 dark:bg-white/40',
  offline: 'bg-brand-coral',
} as const

const shortcuts: { to: string; labelKey: MessageKey; icon: typeof UsersIcon }[] = [
  { to: '/queue-desk', labelKey: 'navQueueDesk', icon: QueueDeskIcon },
  { to: '/patients', labelKey: 'navPatients', icon: PersonIcon },
  { to: '/session-history', labelKey: 'navSessionHistory', icon: HistoryIcon },
  { to: '/analytics', labelKey: 'navAnalytics', icon: AnalyticsIcon },
  { to: '/users', labelKey: 'navUsers', icon: UsersIcon },
  { to: '/monitoring', labelKey: 'navMonitoring', icon: ActivityIcon },
  { to: '/backup', labelKey: 'navBackup', icon: HardDriveIcon },
]

/** The admin's first screen: the clinic today at a glance, what needs attention, devices and recent activity. */
export function OverviewPage() {
  const { t, locale } = useLocale()
  const { state } = useAuth()
  const { state: liveState } = useLiveChannel()
  const [now] = useState(() => Date.now())
  const health = liveStateToHealth(liveState)
  const account = state.status === 'signedIn' ? state.account : null
  const name = account ? account.firstName || account.displayName || account.username : ''
  const data = useOverview()
  const nf = new Intl.NumberFormat(locale)

  const today = data.today.data
  const week = data.week.data
  const chambers = data.chambers.data ?? []
  const openSessions = (data.sessions.data?.items ?? []).filter((session) => !session.closedAt)
  const waitingNow =
    data.boards.length > 0 && data.boards.every((board) => board.data)
      ? data.boards.reduce((sum, board) => sum + (board.data?.queueControls.reduce((n, c) => n + c.waitingCount, 0) ?? 0), 0)
      : null

  const alerts = buildOverviewAlerts({
    nowMs: now,
    offline: health === 'offline',
    monitoring: data.monitoring.data,
    backupSchedule: data.backupSettings.data?.schedule,
    backups: data.backups.data?.backups,
    openSessions,
    serviceName: (key) => t(key),
  })
  const alertsReady = data.monitoring.isSuccess && data.backups.isSuccess && data.backupSettings.isSuccess

  // The week so far (days still to come would only draw a flat line).
  const weekSoFar = week && today ? week.series.filter((point) => point.key <= today.fromDate) : []
  const spark = (pick: (p: (typeof weekSoFar)[number]) => number) => weekSoFar.map(pick)

  const vsYesterday = t('overviewVsYesterday')
  const dateLine = new Intl.DateTimeFormat(locale, { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' }).format(
    new Date(now),
  )
  const serverMessage: MessageKey =
    health === 'connected'
      ? 'overviewServerOk'
      : health === 'offline'
        ? 'overviewServerOffline'
        : 'overviewServerChecking'

  const totals = today?.totals
  const dash = '—'

  return (
    <div className="min-w-0 space-y-5 pb-6">
      <PageHeader
        title={t('homeGreeting', { name })}
        description={`${dateLine}${account ? ` · ${t(roleLabelKey[account.role])} · ${account.email}` : ''}`}
        actions={
          <div className="flex flex-wrap items-center gap-2 sm:justify-end">
            <p
              role="status"
              className="flex min-w-0 items-center gap-2 rounded-full border border-brand-navy/10 bg-white px-3 py-1.5 text-xs font-medium dark:border-white/10 dark:bg-brand-navy-raised"
            >
              <span className={`h-2.5 w-2.5 shrink-0 rounded-full ${statusStyle[health]}`} aria-hidden="true" />
              <span className="min-w-0">{t(serverMessage)}</span>
            </p>
            <Link to="/queue-desk" className={`${secondaryButton} !min-h-10 !px-3`}>
              {t('navQueueDesk')}
            </Link>
          </div>
        }
      />

      <AttentionPanel alerts={alerts} ready={alertsReady} />

      <section aria-label={t('overviewTodayTitle')} className="grid grid-cols-2 gap-3 md:grid-cols-3 xl:grid-cols-6">
        <KpiTile
          icon={QueueIcon}
          label={t('overviewTokensToday')}
          value={totals ? nf.format(totals.tokens) : dash}
          trend={spark((p) => p.tokens)}
          footer={totals ? <Delta change={change(totals.tokens, today?.previous?.tokens)} caption={vsYesterday} /> : null}
          testId="overview-tokens"
        />
        <KpiTile
          icon={HistoryIcon}
          label={t('overviewWaitingNow')}
          value={waitingNow === null ? dash : nf.format(waitingNow)}
          color="var(--viz-4)"
          footer={
            <span className="text-xs text-brand-navy/65 dark:text-white/65">
              {t('overviewSessionsOpen', { count: nf.format(openSessions.length) })}
            </span>
          }
          testId="overview-waiting"
        />
        <KpiTile
          icon={CheckCircleIcon}
          label={t('analyticsSeen')}
          value={totals ? nf.format(totals.entered) : dash}
          footer={
            totals ? (
              <span className="text-xs text-brand-navy/65 dark:text-white/65">
                {t('analyticsOfTokens', {
                  percent: nf.format(totals.tokens === 0 ? 0 : Math.round((totals.entered / totals.tokens) * 100)),
                })}
              </span>
            ) : null
          }
          testId="overview-seen"
        />
        <KpiTile
          icon={BanknoteIcon}
          label={t('overviewFeesToday')}
          value={totals ? formatBdt(locale, totals.feeBdt) : dash}
          color="var(--viz-3)"
          trend={spark((p) => p.feeBdt)}
          footer={totals ? <Delta change={change(totals.feeBdt, today?.previous?.feeBdt)} caption={vsYesterday} /> : null}
          testId="overview-fees"
        />
        <KpiTile
          icon={PersonAddIcon}
          label={t('analyticsNewPatients')}
          value={totals ? nf.format(totals.newPatients) : dash}
          color="var(--viz-2)"
          trend={spark((p) => p.newPatients)}
          footer={
            totals ? <Delta change={change(totals.newPatients, today?.previous?.newPatients)} caption={vsYesterday} /> : null
          }
          testId="overview-new-patients"
        />
        <KpiTile
          icon={HistoryIcon}
          label={t('historyAverageWait')}
          value={totals?.averageWaitSeconds == null ? dash : formatWait(t, totals.averageWaitSeconds)}
          footer={
            totals ? (
              <Delta
                change={change(totals.averageWaitSeconds ?? 0, today?.previous?.averageWaitSeconds)}
                caption={vsYesterday}
                goodWhenUp={false}
              />
            ) : null
          }
          testId="overview-wait"
        />
      </section>

      <div className="grid gap-4 xl:grid-cols-3">
        <Panel
          title={t('overviewLiveTitle')}
          subtitle={t('overviewLiveHint')}
          action={{ to: '/queue-desk', label: t('overviewOpenDesk') }}
          className="xl:col-span-2"
        >
          <LiveQueuePanel chambers={chambers} boards={data.boards} openSessions={openSessions} />
        </Panel>
        <Panel title={t('overviewHealthTitle')} action={{ to: '/monitoring', label: t('overviewDetails') }}>
          <HealthPanel
            monitoring={data.monitoring.data}
            backupSchedule={data.backupSettings.data?.schedule}
            backups={data.backups.data?.backups}
            nowMs={now}
          />
        </Panel>
      </div>

      <div className="grid gap-4 lg:grid-cols-2">
        <Panel
          title={t('overviewHoursTitle')}
          subtitle={t('overviewHoursHint')}
          action={{ to: '/analytics', label: t('overviewOpenAnalytics') }}
        >
          {today ? (
            <div className="space-y-4">
              <ColumnChart
                columns={today.series.map((point) => ({
                  key: point.key,
                  label: pointLabel(locale, 'day', point.key),
                  title: pointTitle(locale, 'day', point.key),
                  value: point.tokens,
                  display: nf.format(point.tokens),
                }))}
                color="var(--viz-1)"
                ariaLabel={t('overviewHoursTitle')}
                formatTick={(n) => compact(locale, n)}
                heightRem={9}
              />
              <OutcomeSummary
                counts={{
                  ENTERED: today.totals.entered,
                  SKIPPED: today.totals.skipped,
                  CANCELLED: today.totals.cancelled,
                  WAITING: today.totals.notSeen,
                }}
              />
            </div>
          ) : (
            <p className="text-sm text-brand-navy/65 dark:text-white/65">{t('overviewHealthLoading')}</p>
          )}
        </Panel>

        <Panel
          title={t('overviewWeekTitle')}
          subtitle={t('overviewWeekHint')}
          action={{ to: '/analytics', label: t('overviewOpenAnalytics') }}
        >
          {week ? (
            <div className="space-y-4">
              <ColumnChart
                columns={week.series.map((point) => ({
                  key: point.key,
                  label: pointLabel(locale, 'week', point.key),
                  title: pointTitle(locale, 'week', point.key),
                  value: point.tokens,
                  display: nf.format(point.tokens),
                }))}
                color="var(--viz-1)"
                ariaLabel={t('overviewWeekTitle')}
                formatTick={(n) => compact(locale, n)}
                heightRem={9}
              />
              <dl className="grid grid-cols-3 gap-3 border-t border-brand-navy/10 pt-4 text-sm dark:border-white/10">
                <div>
                  <dt className="text-xs text-brand-navy/65 dark:text-white/65">{t('historyTokens')}</dt>
                  <dd className="text-lg font-bold tabular-nums">{nf.format(week.totals.tokens)}</dd>
                </div>
                <div>
                  <dt className="text-xs text-brand-navy/65 dark:text-white/65">{t('historyTotalFees')}</dt>
                  <dd className="text-lg font-bold tabular-nums">{formatBdt(locale, week.totals.feeBdt)}</dd>
                </div>
                <div>
                  <dt className="text-xs text-brand-navy/65 dark:text-white/65">{t('analyticsNewPatients')}</dt>
                  <dd className="text-lg font-bold tabular-nums">{nf.format(week.totals.newPatients)}</dd>
                </div>
              </dl>
            </div>
          ) : (
            <p className="text-sm text-brand-navy/65 dark:text-white/65">{t('overviewHealthLoading')}</p>
          )}
        </Panel>
      </div>

      <div className="grid gap-4 lg:grid-cols-2">
        <Panel title={t('overviewActivityTitle')} action={{ to: '/audit', label: t('overviewViewAll') }}>
          <ActivityPanel entries={data.audit.data?.entries.slice(0, 6)} nowMs={now} />
        </Panel>

        <Panel title={t('overviewShortcutsTitle')}>
          <ul className="grid grid-cols-2 gap-2 sm:grid-cols-3 lg:grid-cols-2 xl:grid-cols-4">
            {shortcuts.map(({ to, labelKey, icon: Icon }) => (
              <li key={to}>
                <Link
                  to={to}
                  className="flex min-h-12 items-center gap-2.5 rounded-lg border border-brand-navy/10 px-3 py-2 text-sm font-medium hover:bg-brand-mist focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none dark:border-white/10 dark:hover:bg-white/10"
                >
                  <Icon width={18} height={18} className="shrink-0 text-brand-navy/70 dark:text-white/70" />
                  <span className="min-w-0 truncate">{t(labelKey)}</span>
                </Link>
              </li>
            ))}
          </ul>
        </Panel>
      </div>
    </div>
  )
}
