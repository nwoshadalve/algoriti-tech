/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { keepPreviousData, useQuery } from '@tanstack/react-query'
import { useState } from 'react'
import { getAnalytics, type Analytics, type AnalyticsPeriod, type AnalyticsPoint } from '@/core/api/analytics'
import { listChambers } from '@/core/api/chambers'
import { useLocale } from '@/core/i18n/LocaleProvider'
import type { MessageKey } from '@/core/i18n/messages/types'
import { secondaryButton } from '@/core/ui/buttonStyles'
import {
  BanknoteIcon,
  CheckCircleIcon,
  HistoryIcon,
  PersonAddIcon,
  QueueIcon,
  UsersIcon,
} from '@/core/ui/icons'
import { NoticeBanner } from '@/core/ui/NoticeBanner'
import { PageHeader } from '@/core/ui/PageHeader'
import { PagePreloader } from '@/core/ui/PagePreloader'
import { SelectField } from '@/core/ui/SelectField'
import { readSession } from '@/features/auth/session'
import { analyticsQueryKeys } from '@/features/analytics/analyticsQueryKeys'
import { BarList } from '@/features/analytics/charts/BarList'
import { ColumnChart, type Column } from '@/features/analytics/charts/ColumnChart'
import { Delta } from '@/features/analytics/charts/Delta'
import {
  change,
  compact,
  pointLabel,
  pointTitle,
  periodTitle,
  shiftPeriod,
} from '@/features/analytics/analyticsFormat'
import { ChartCard } from '@/features/analytics/ChartCard'
import { KpiTile } from '@/features/analytics/KpiTile'
import { OutcomeSummary } from '@/features/sessions/SessionStats'
import { formatBdt, formatWait } from '@/features/sessions/sessionFormat'

const periods: { value: AnalyticsPeriod; labelKey: MessageKey }[] = [
  { value: 'day', labelKey: 'analyticsPeriodDay' },
  { value: 'week', labelKey: 'analyticsPeriodWeek' },
  { value: 'month', labelKey: 'analyticsPeriodMonth' },
  { value: 'year', labelKey: 'analyticsPeriodYear' },
  { value: 'all', labelKey: 'analyticsPeriodAll' },
]

/** What a change is measured against, by period. */
const againstKey: Record<Exclude<AnalyticsPeriod, 'all'>, MessageKey> = {
  day: 'analyticsVsDay',
  week: 'analyticsVsWeek',
  month: 'analyticsVsMonth',
  year: 'analyticsVsYear',
}

const percent = (part: number, whole: number) => (whole === 0 ? 0 : Math.round((part / whole) * 100))

/** The point with the most of something, or null when every point is zero. */
function busiest(points: AnalyticsPoint[], pick: (p: AnalyticsPoint) => number): AnalyticsPoint | null {
  let best: AnalyticsPoint | null = null
  for (const point of points) {
    if (pick(point) > (best ? pick(best) : 0)) best = point
  }
  return best
}

/** A few facts, each a caption and a value, in a quiet list. */
function HighlightList({ rows, empty }: { rows: { label: string; value: string }[]; empty: string }) {
  if (rows.length === 0) return <p className="text-sm text-brand-navy/65 dark:text-white/65">{empty}</p>
  return (
    <dl className="divide-y divide-brand-navy/10 text-sm dark:divide-white/10">
      {rows.map((row) => (
        <div key={row.label} className="flex items-baseline justify-between gap-4 py-2 first:pt-0 last:pb-0">
          <dt className="text-brand-navy/70 dark:text-white/70">{row.label}</dt>
          <dd className="text-right font-semibold tabular-nums">{row.value}</dd>
        </div>
      ))}
    </dl>
  )
}

/** Admin analytics: how the clinic did over a day, week, month, year or all time. */
export function AnalyticsPage() {
  const { t, locale } = useLocale()
  const [period, setPeriod] = useState<AnalyticsPeriod>('week')
  const [date, setDate] = useState('')
  const [chamberId, setChamberId] = useState('')
  const [now] = useState(() => Date.now())

  const chambers = useQuery({
    queryKey: ['analytics', 'chambers'],
    queryFn: async () => {
      const token = readSession()
      if (!token) throw new Error('signed_out')
      return listChambers(token)
    },
    retry: false,
  })

  const query = useQuery({
    queryKey: analyticsQueryKeys.read(period, date, chamberId),
    queryFn: async () => {
      const token = readSession()
      if (!token) throw new Error('signed_out')
      return getAnalytics(token, { period, date: date || undefined, chamberId: chamberId || undefined })
    },
    // Keep the old figures on screen while the next period loads.
    placeholderData: keepPreviousData,
    retry: false,
  })

  const nf = new Intl.NumberFormat(locale)
  const data: Analytics | undefined = query.data
  const multiChamber = (chambers.data?.length ?? 0) > 1

  function choosePeriod(next: AnalyticsPeriod) {
    setPeriod(next)
    setDate('')
  }

  const header = (
    <PageHeader title={t('navAnalytics')} description={t('analyticsIntro')} />
  )

  if (query.isPending) {
    return (
      <div>
        {header}
        <PagePreloader />
      </div>
    )
  }
  if (query.isError || !data) {
    return (
      <div>
        {header}
        <NoticeBanner tone="error">
          {t('analyticsLoadFailed')}
          <button type="button" className={`${secondaryButton} mt-2`} onClick={() => void query.refetch()}>
            {t('usersRetry')}
          </button>
        </NoticeBanner>
      </div>
    )
  }

  const { totals, previous, series } = data
  const vs = data.period === 'all' ? null : againstKey[data.period]
  const caption = vs ? t(vs) : t('analyticsSince', { date: periodTitle(locale, data).split(' – ')[0] ?? '' })
  const todayKey = new Date(now).toISOString().slice(0, 10)
  const atLatest = data.period === 'all' || data.toDate >= todayKey
  const asColumns = (value: (p: AnalyticsPoint) => number, display: (n: number) => string): Column[] =>
    series.map((point) => ({
      key: point.key,
      label: pointLabel(locale, data.period, point.key),
      title: pointTitle(locale, data.period, point.key),
      value: value(point),
      display: display(value(point)),
    }))

  const busiestPoint = busiest(series, (p) => p.tokens)
  const topFeePoint = busiest(series, (p) => p.feeBdt)
  const hourSlots = data.byHour.map((slot, hour) => ({ ...slot, hour }))
  const busiestHour = hourSlots.reduce<(typeof hourSlots)[number] | null>(
    (best, slot) => (slot.tokens > (best?.tokens ?? 0) ? slot : best),
    null,
  )
  const hourLabel = (hour: number) =>
    new Intl.DateTimeFormat(locale, { hour: 'numeric', timeZone: 'UTC' }).format(new Date(Date.UTC(2000, 0, 1, hour)))
  const weekdayName = (index: number, style: 'short' | 'long') =>
    new Intl.DateTimeFormat(locale, { weekday: style, timeZone: 'UTC' }).format(new Date(Date.UTC(2024, 0, 1 + index)))

  const seenRate = percent(totals.entered, totals.tokens)
  const perSession = totals.sessions > 0 ? Math.round(totals.tokens / totals.sessions) : null
  const feePerPatient = totals.entered > 0 ? Math.round(totals.feeBdt / totals.entered) : null
  const nothing = totals.tokens === 0 && totals.newPatients === 0 && totals.sessions === 0

  const highlights: { label: string; value: string }[] = []
  if (busiestHour) {
    highlights.push({
      label: t('analyticsHighBusiestHour'),
      value: `${hourLabel(busiestHour.hour)} – ${hourLabel(busiestHour.hour + 1)} · ${nf.format(busiestHour.tokens)}`,
    })
  }
  if (busiestPoint && data.period !== 'day') {
    highlights.push({
      label: t('analyticsHighBusiestPoint'),
      value: `${pointTitle(locale, data.period, busiestPoint.key)} · ${nf.format(busiestPoint.tokens)}`,
    })
  }
  if (topFeePoint && data.period !== 'day') {
    highlights.push({
      label: t('analyticsHighTopFees'),
      value: `${pointTitle(locale, data.period, topFeePoint.key)} · ${formatBdt(locale, topFeePoint.feeBdt)}`,
    })
  }
  if (perSession !== null) highlights.push({ label: t('analyticsHighPerSession'), value: nf.format(perSession) })
  if (feePerPatient !== null) {
    highlights.push({ label: t('analyticsHighFeePerPatient'), value: formatBdt(locale, feePerPatient) })
  }
  if (totals.averageSessionMinutes !== null) {
    highlights.push({
      label: t('analyticsHighSessionLength'),
      value: formatWait(t, totals.averageSessionMinutes * 60),
    })
  }
  if (totals.longestWaitSeconds !== null) {
    highlights.push({ label: t('historyLongestWait'), value: formatWait(t, totals.longestWaitSeconds) })
  }

  const tokenTable = {
    columns: [t('analyticsColPeriod'), t('historyTokens'), t('boardTokenEntered'), t('historyTotalFees')],
    rows: series.map((p) => [
      pointTitle(locale, data.period, p.key),
      nf.format(p.tokens),
      nf.format(p.entered),
      formatBdt(locale, p.feeBdt),
    ]),
  }

  return (
    <div className="space-y-5 pb-6">
      {header}

      <div className="space-y-3 rounded-xl border border-brand-navy/10 bg-white p-3 shadow-sm sm:p-4 dark:border-white/10 dark:bg-brand-navy-raised dark:shadow-none">
        <div className="flex flex-wrap items-center gap-3">
          <div
            role="group"
            aria-label={t('analyticsPeriodLabel')}
            className="flex w-full gap-1 rounded-lg bg-brand-mist p-1 sm:w-auto dark:bg-white/5"
          >
            {periods.map(({ value, labelKey }) => (
              <button
                key={value}
                type="button"
                aria-pressed={period === value}
                onClick={() => choosePeriod(value)}
                className={`min-h-10 min-w-0 flex-1 rounded-md px-1.5 text-xs font-medium sm:flex-none sm:px-3 sm:text-sm focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none ${
                  period === value
                    ? 'bg-white text-brand-navy shadow-sm dark:bg-brand-navy-raised dark:text-white'
                    : 'text-brand-navy/70 hover:text-brand-navy dark:text-white/70 dark:hover:text-white'
                }`}
              >
                {t(labelKey)}
              </button>
            ))}
          </div>

          {multiChamber ? (
            <SelectField
              id="analytics-chamber"
              label={t('historyChamber')}
              hideLabel
              value={chamberId}
              onChange={(event) => {
                setChamberId(event.target.value)
                setDate('')
              }}
              options={[
                { value: '', label: t('historyAllChambers') },
                ...(chambers.data ?? []).map((c) => ({ value: c.id, label: c.name })),
              ]}
              className="min-w-44"
            />
          ) : null}
        </div>

        {data.period !== 'all' ? (
          <div className="flex flex-wrap items-center justify-between gap-2">
            <button
              type="button"
              className={`${secondaryButton} !min-h-10 !px-3`}
              onClick={() => setDate(shiftPeriod(data, -1))}
            >
              {t('analyticsPrevious')}
            </button>
            <p className="order-first min-w-0 basis-full text-center font-semibold sm:order-none sm:basis-auto sm:flex-1" aria-live="polite">
              {periodTitle(locale, data)}
            </p>
            <div className="flex gap-2">
              <button
                type="button"
                className={`${secondaryButton} !min-h-10 !px-3`}
                disabled={atLatest}
                onClick={() => setDate(shiftPeriod(data, 1))}
              >
                {t('analyticsNext')}
              </button>
              {date ? (
                <button type="button" className={`${secondaryButton} !min-h-10 !px-3`} onClick={() => setDate('')}>
                  {t('analyticsCurrent')}
                </button>
              ) : null}
            </div>
          </div>
        ) : (
          <p className="text-center font-semibold">{periodTitle(locale, data)}</p>
        )}
      </div>

      {nothing ? (
        <p className="rounded-xl border border-dashed border-brand-navy/20 p-6 text-center text-sm text-brand-navy/70 dark:border-white/20 dark:text-white/70">
          {t('analyticsNothing')}
        </p>
      ) : null}

      <section aria-label={t('analyticsKeyFigures')} className="grid grid-cols-2 gap-3 md:grid-cols-3 xl:grid-cols-6">
        <KpiTile
          icon={QueueIcon}
          label={t('historyTokens')}
          value={nf.format(totals.tokens)}
          trend={series.map((p) => p.tokens)}
          footer={<Delta change={change(totals.tokens, previous?.tokens)} caption={caption} />}
          testId="kpi-tokens"
        />
        <KpiTile
          icon={CheckCircleIcon}
          label={t('analyticsSeen')}
          value={nf.format(totals.entered)}
          footer={
            <span className="text-xs text-brand-navy/65 dark:text-white/65">
              {t('analyticsOfTokens', { percent: nf.format(seenRate) })}
            </span>
          }
          testId="kpi-seen"
        />
        <KpiTile
          icon={BanknoteIcon}
          label={t('historyTotalFees')}
          value={formatBdt(locale, totals.feeBdt)}
          color="var(--viz-3)"
          trend={series.map((p) => p.feeBdt)}
          footer={<Delta change={change(totals.feeBdt, previous?.feeBdt)} caption={caption} />}
          testId="kpi-fees"
        />
        <KpiTile
          icon={PersonAddIcon}
          label={t('analyticsNewPatients')}
          value={nf.format(totals.newPatients)}
          color="var(--viz-2)"
          trend={series.map((p) => p.newPatients)}
          footer={<Delta change={change(totals.newPatients, previous?.newPatients)} caption={caption} />}
          testId="kpi-new-patients"
        />
        <KpiTile
          icon={HistoryIcon}
          label={t('historyAverageWait')}
          value={totals.averageWaitSeconds === null ? '—' : formatWait(t, totals.averageWaitSeconds)}
          footer={
            <Delta
              change={change(totals.averageWaitSeconds ?? 0, previous?.averageWaitSeconds)}
              caption={caption}
              goodWhenUp={false}
            />
          }
          testId="kpi-wait"
        />
        <KpiTile
          icon={UsersIcon}
          label={t('analyticsPatientsServed')}
          value={nf.format(totals.patients)}
          footer={
            <span className="text-xs text-brand-navy/65 dark:text-white/65">
              {t('analyticsSessionsCount', { count: nf.format(totals.sessions) })}
            </span>
          }
          testId="kpi-patients"
        />
      </section>

      <div className="grid gap-4 lg:grid-cols-2">
        <ChartCard title={t('analyticsTokensOverTime')} subtitle={t('analyticsTokensOverTimeHint')} table={tokenTable}>
          <ColumnChart
            columns={asColumns((p) => p.tokens, (n) => nf.format(n))}
            color="var(--viz-1)"
            ariaLabel={t('analyticsTokensOverTime')}
            formatTick={(n) => compact(locale, n)}
          />
        </ChartCard>
        <ChartCard title={t('analyticsFeesOverTime')} subtitle={t('analyticsFeesOverTimeHint')} table={tokenTable}>
          <ColumnChart
            columns={asColumns((p) => p.feeBdt, (n) => formatBdt(locale, n))}
            color="var(--viz-3)"
            ariaLabel={t('analyticsFeesOverTime')}
            formatTick={(n) => compact(locale, n)}
          />
        </ChartCard>
      </div>

      <div className="grid gap-4 lg:grid-cols-2">
        <ChartCard title={t('analyticsOutcomes')} subtitle={t('analyticsOutcomesHint')}>
          <OutcomeSummary
            counts={{
              ENTERED: totals.entered,
              SKIPPED: totals.skipped,
              CANCELLED: totals.cancelled,
              WAITING: totals.notSeen,
            }}
          />
          <dl className="mt-4 grid grid-cols-2 gap-3 border-t border-brand-navy/10 pt-4 text-sm sm:grid-cols-4 dark:border-white/10">
            {[
              { label: t('boardTokenEntered'), value: totals.entered },
              { label: t('boardTokenSkipped'), value: totals.skipped },
              { label: t('boardTokenCancelled'), value: totals.cancelled },
              { label: t('historyNotSeen'), value: totals.notSeen },
            ].map((row) => (
              <div key={row.label}>
                <dt className="text-xs text-brand-navy/65 dark:text-white/65">{row.label}</dt>
                <dd className="text-lg font-bold tabular-nums">{nf.format(percent(row.value, totals.tokens))}%</dd>
              </div>
            ))}
          </dl>
        </ChartCard>

        <ChartCard title={t('analyticsNewPatientsOverTime')} subtitle={t('analyticsNewPatientsHint')}>
          <ColumnChart
            columns={asColumns((p) => p.newPatients, (n) => nf.format(n))}
            color="var(--viz-2)"
            ariaLabel={t('analyticsNewPatientsOverTime')}
            formatTick={(n) => compact(locale, n)}
            heightRem={9}
          />
        </ChartCard>
      </div>

      <div className="grid gap-4 lg:grid-cols-2">
        <ChartCard title={t('analyticsBusiestHours')} subtitle={t('analyticsBusiestHoursHint')}>
          <ColumnChart
            columns={hourSlots.map((slot) => ({
              key: String(slot.hour),
              label: hourLabel(slot.hour),
              title: `${hourLabel(slot.hour)} – ${hourLabel(slot.hour + 1)}`,
              value: slot.tokens,
              display: nf.format(slot.tokens),
            }))}
            color="var(--viz-1)"
            ariaLabel={t('analyticsBusiestHours')}
            formatTick={(n) => compact(locale, n)}
            heightRem={9}
          />
        </ChartCard>
        {data.period !== 'day' ? (
          <ChartCard title={t('analyticsByWeekday')} subtitle={t('analyticsByWeekdayHint')}>
            <ColumnChart
              columns={data.byWeekday.map((slot, index) => ({
                key: String(index),
                label: weekdayName(index, 'short'),
                title: weekdayName(index, 'long'),
                value: slot.tokens,
                display: nf.format(slot.tokens),
              }))}
              color="var(--viz-1)"
              ariaLabel={t('analyticsByWeekday')}
              formatTick={(n) => compact(locale, n)}
              heightRem={9}
            />
          </ChartCard>
        ) : null}
      </div>

      <div className="grid gap-4 lg:grid-cols-2">
        <ChartCard title={t('analyticsByQueue')} subtitle={t('analyticsByQueueHint')}>
          {data.byQueue.length === 0 ? (
            <p className="text-sm text-brand-navy/65 dark:text-white/65">{t('analyticsNothing')}</p>
          ) : (
            <BarList
              color="var(--viz-1)"
              rows={data.byQueue.map((queue) => ({
                key: queue.queueTypeId,
                label: locale === 'bn' && queue.bengaliName.trim() ? queue.bengaliName : queue.englishName,
                value: queue.tokens,
                display: nf.format(queue.tokens),
                note: `${t('historyTotalFees')} ${formatBdt(locale, queue.feeBdt)}`,
              }))}
            />
          )}
        </ChartCard>

        {multiChamber ? (
          <ChartCard title={t('analyticsByChamber')} subtitle={t('analyticsByChamberHint')}>
            <BarList
              color="var(--viz-2)"
              rows={data.byChamber.map((chamber) => ({
                key: chamber.chamberId,
                label: chamber.name,
                value: chamber.tokens,
                display: nf.format(chamber.tokens),
                note: `${t('historyTotalFees')} ${formatBdt(locale, chamber.feeBdt)} · ${t('analyticsSessionsCount', { count: nf.format(chamber.sessions) })}`,
              }))}
            />
          </ChartCard>
        ) : (
          <ChartCard title={t('analyticsHighlights')} subtitle={t('analyticsHighlightsHint')}>
            <HighlightList rows={highlights} empty={t('analyticsNothing')} />
          </ChartCard>
        )}
      </div>

      {multiChamber ? (
        <ChartCard title={t('analyticsHighlights')} subtitle={t('analyticsHighlightsHint')}>
          <HighlightList rows={highlights} empty={t('analyticsNothing')} />
        </ChartCard>
      ) : null}
    </div>
  )
}
