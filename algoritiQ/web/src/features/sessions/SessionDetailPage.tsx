/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useInfiniteQuery, useQuery } from '@tanstack/react-query'
import type { ComponentType, ReactNode, SVGProps } from 'react'
import { useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import { ApiError } from '@/core/api/client'
import { getSessionDetail, listSessionTokens } from '@/core/api/sessionHistory'
import type { BoardTokenView, SessionQueueStat, TokenSort, TokenStatus } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { canObserveScroll } from '@/core/ui/canObserveScroll'
import {
  BanknoteIcon,
  CalendarIcon,
  ChevronDownIcon,
  ChevronUpDownIcon,
  ClockIcon,
  HistoryIcon,
  MapPinIcon,
  PersonIcon,
  QueueIcon,
  SearchIcon,
  StethoscopeIcon,
  UsersIcon,
} from '@/core/ui/icons'
import { NoticeBanner } from '@/core/ui/NoticeBanner'
import { PageHeader } from '@/core/ui/PageHeader'
import { PagePreloader } from '@/core/ui/PagePreloader'
import { ScrollSentinel } from '@/core/ui/ScrollSentinel'
import { useDebouncedValue } from '@/core/ui/useDebouncedValue'
import { readSession } from '@/features/auth/session'
import { outcomeTone, statusTone } from '@/features/sessions/outcomeTone'
import { SessionStatusPill } from '@/features/sessions/SessionParts'
import { OutcomeSummary } from '@/features/sessions/SessionStats'
import {
  formatBdt,
  formatClock,
  formatDay,
  formatRelativeDay,
  formatRunTime,
  formatWait,
  notSeen,
  tokenStatusKey,
  tokenStatuses,
  totalTokens,
} from '@/features/sessions/sessionFormat'
import { sessionHistoryQueryKeys } from '@/features/sessions/sessionHistoryQueryKeys'
import { formatDigits } from '@/features/queue/formatQueueSerial'

const PAGE_SIZE = 30

type Icon = ComponentType<SVGProps<SVGSVGElement>>

const panel =
  'rounded-xl border border-brand-navy/10 bg-white shadow-sm dark:border-white/10 dark:bg-brand-navy-raised dark:shadow-none'

/** One figure of the overview strip: small icon and caption over the value. */
function KeyFigure({ icon: Icon, label, children }: { icon: Icon; label: string; children: ReactNode }) {
  return (
    <div className="min-w-0 rounded-lg bg-brand-mist/70 px-3 py-2 dark:bg-white/5">
      <p className="flex items-center gap-1.5 text-xs font-medium text-brand-navy/65 dark:text-white/65">
        <Icon width={14} height={14} className="shrink-0" />
        <span className="truncate">{label}</span>
      </p>
      <p className="mt-0.5 text-lg leading-tight font-bold tabular-nums">{children}</p>
    </div>
  )
}

/** A time or person line of the overview: small caption, then the value. */
function Fact({ icon: Icon, label, value }: { icon: Icon; label: string; value: string }) {
  return (
    <div className="min-w-0">
      <dt className="flex items-center gap-1.5 text-xs font-medium text-brand-navy/65 dark:text-white/65">
        <Icon width={13} height={13} className="shrink-0" />
        {label}
      </dt>
      <dd className="text-sm font-semibold">{value}</dd>
    </div>
  )
}

function queueName(locale: string, queue: SessionQueueStat | BoardTokenView): string {
  const bengali = 'bengaliName' in queue ? queue.bengaliName : queue.queueBengaliName
  const english = 'englishName' in queue ? queue.englishName : queue.queueEnglishName
  return locale === 'bn' && bengali.trim() ? bengali : english
}

/** When the token was last touched, and what became of it. */
function outcomeText(
  token: BoardTokenView,
  t: ReturnType<typeof useLocale>['t'],
  locale: string,
): string {
  if (token.status === 'CANCELLED') {
    const when = token.cancelledAt ? formatClock(locale, token.cancelledAt) : ''
    const reason = token.cancelReason?.trim()
    return [when, reason].filter(Boolean).join(' · ')
  }
  if (token.status === 'ENTERED' && token.enteredAt) return formatClock(locale, token.enteredAt)
  return token.status === 'WAITING' || token.status === 'CALLED' ? t('historyNotSeen') : ''
}

/** Seconds a token waited before its first call; null if it was never called. */
function waitSeconds(token: BoardTokenView): number | null {
  if (!token.firstCalledAt) return null
  return Math.max(0, (new Date(token.firstCalledAt).getTime() - new Date(token.issuedAt).getTime()) / 1000)
}

/** Times read best newest first; names and numbers from the start. */
const newestFirst: ReadonlySet<TokenSort> = new Set(['issued'])

/** On phones a row is a card: each cell shows its caption above the value. */
function Labelled({ label }: { label: string }) {
  return (
    <span className="mb-0.5 block text-[0.7rem] font-semibold tracking-wide text-brand-navy/55 uppercase md:hidden dark:text-white/55">
      {label}
    </span>
  )
}

const cell = 'px-4 py-3 align-middle max-md:p-0'
const queueCell = 'px-4 py-2.5 align-middle max-md:p-0'

/** A coloured dot before a column or cell caption, matching the outcome bar. */
function Dot({ tone }: { tone: keyof typeof outcomeTone }) {
  return <span aria-hidden="true" className={`mr-1.5 inline-block h-2 w-2 rounded-full ${outcomeTone[tone].bar}`} />
}

/** One past session: times, key figures, the result per queue and every token. Read only. */
export function SessionDetailPage() {
  const { t, locale } = useLocale()
  const { sessionId = '' } = useParams()
  const [status, setStatus] = useState<TokenStatus | ''>('')
  const [searchInput, setSearchInput] = useState('')
  const [sort, setSort] = useState<TokenSort>('serial')
  const [ascending, setAscending] = useState(true)
  const search = useDebouncedValue(searchInput.trim(), 300)
  const [now] = useState(() => Date.now())

  const detail = useQuery({
    queryKey: sessionHistoryQueryKeys.detail(sessionId),
    queryFn: async () => {
      const token = readSession()
      if (!token) throw new Error('signed_out')
      return getSessionDetail(token, sessionId)
    },
    retry: false,
  })

  const tokens = useInfiniteQuery({
    queryKey: sessionHistoryQueryKeys.tokens(sessionId, status, search, sort, ascending),
    queryFn: async ({ pageParam }) => {
      const token = readSession()
      if (!token) throw new Error('signed_out')
      return listSessionTokens(token, sessionId, {
        search: search || undefined,
        status: status || undefined,
        sort,
        ascending,
        limit: PAGE_SIZE,
        offset: pageParam,
      })
    },
    initialPageParam: 0,
    getNextPageParam: (last, pages) => {
      const loaded = pages.reduce((sum, page) => sum + page.items.length, 0)
      return loaded < last.total ? loaded : undefined
    },
    enabled: detail.isSuccess,
    retry: false,
  })

  const back = (
    <Link to="/session-history" className={`${secondaryButton} inline-flex`}>
      {t('historyBack')}
    </Link>
  )

  if (detail.isPending) return <PagePreloader />
  if (detail.isError) {
    const forbidden = detail.error instanceof ApiError && detail.error.code === 'forbidden'
    return (
      <div>
        <PageHeader title={t('historyDetailTitle')} description="" />
        <NoticeBanner tone="error">
          {forbidden ? t('historyForbidden') : t('historyLoadFailed')}
        </NoticeBanner>
        <div className="mt-4">{back}</div>
      </div>
    )
  }

  function sortBy(column: TokenSort) {
    if (column === sort) {
      setAscending((current) => !current)
      return
    }
    setSort(column)
    setAscending(!newestFirst.has(column))
  }

  /** A column heading that sorts the tokens; the current column shows its direction. */
  function heading(column: TokenSort, label: string) {
    const active = sort === column
    return (
      <th scope="col" className="px-2 py-1" aria-sort={active ? (ascending ? 'ascending' : 'descending') : 'none'}>
        <button
          type="button"
          aria-label={t('patientsSortBy', { column: label })}
          className={`inline-flex min-h-10 items-center gap-1 rounded-lg px-2 text-xs font-semibold tracking-wide uppercase hover:bg-brand-navy/5 focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none dark:hover:bg-white/10 ${active ? 'text-brand-navy dark:text-white' : ''}`}
          onClick={() => sortBy(column)}
        >
          {label}
          {active ? (
            <ChevronDownIcon width={14} height={14} className={ascending ? 'rotate-180' : ''} />
          ) : (
            <ChevronUpDownIcon width={14} height={14} className="opacity-50" />
          )}
        </button>
      </th>
    )
  }

  const { session, queues, patientCount, averageWaitSeconds, longestWaitSeconds } = detail.data
  const rows = tokens.data?.pages.flatMap((page) => page.items) ?? []
  const counts = tokens.data?.pages[0]?.counts ?? session.counts
  const reason = session.closeReason?.trim()
  const nf = new Intl.NumberFormat(locale)
  const open = !session.closedAt
  const relativeDay = formatRelativeDay(locale, session.openedAt, now)
  const dash = '—'
  const hasFees = session.totalFeeBdt !== undefined
  const hasQueueFees = queues.some((queue) => queue.feeBdt !== undefined)

  return (
    <div className="space-y-5 pb-6">
      <PageHeader
        title={t('historyDetailTitle')}
        description={`${formatDay(locale, session.openedAt)}${session.chamberName ? ` · ${session.chamberName}` : ''}`}
        actions={back}
      />

      <section
        aria-labelledby="history-overview"
        className={`${panel} space-y-4 p-4 ${open ? 'border-emerald-500/50 dark:border-emerald-400/40' : ''}`}
      >
        <header className="flex flex-wrap items-center justify-between gap-2">
          <div className="min-w-0">
            <h2 id="history-overview" className="flex flex-wrap items-center gap-x-2 font-semibold">
              <CalendarIcon width={18} height={18} className="shrink-0 text-brand-navy/60 dark:text-white/60" />
              {t('historyOverview')}
              {relativeDay ? (
                <span className="text-xs font-medium text-brand-navy/60 dark:text-white/60">{relativeDay}</span>
              ) : null}
            </h2>
            {session.chamberName ? (
              <p className="mt-0.5 flex items-center gap-1 text-xs text-brand-navy/70 dark:text-white/70">
                <MapPinIcon width={12} height={12} className="shrink-0" />
                <span className="truncate">{session.chamberName}</span>
              </p>
            ) : null}
          </div>
          <SessionStatusPill session={session} />
        </header>

        <dl className="grid grid-cols-2 gap-x-4 gap-y-3 sm:grid-cols-3 lg:grid-cols-7">
          <Fact icon={ClockIcon} label={t('historyOpened')} value={formatClock(locale, session.openedAt)} />
          <Fact
            icon={ClockIcon}
            label={t('historyEnded')}
            value={session.closedAt ? formatClock(locale, session.closedAt) : dash}
          />
          <Fact icon={HistoryIcon} label={t('historyDuration')} value={formatRunTime(t, session, now)} />
          <Fact
            icon={StethoscopeIcon}
            label={t('historyFirstCall')}
            value={session.firstCalledAt ? formatClock(locale, session.firstCalledAt) : dash}
          />
          <Fact
            icon={StethoscopeIcon}
            label={t('historyLastCall')}
            value={session.lastCalledAt ? formatClock(locale, session.lastCalledAt) : dash}
          />
          {session.openedByName ? (
            <Fact icon={PersonIcon} label={t('historyOpenedByLabel')} value={session.openedByName} />
          ) : null}
          {session.closedAt && session.closedByName ? (
            <Fact icon={PersonIcon} label={t('historyEndedByLabel')} value={session.closedByName} />
          ) : null}
        </dl>

        {reason ? (
          <p className="text-sm text-orange-800 dark:text-orange-200">{t('historyReason', { reason })}</p>
        ) : null}

        <div className="grid grid-cols-2 gap-2 sm:grid-cols-3 lg:grid-cols-6">
          <KeyFigure icon={QueueIcon} label={t('historyTokens')}>
            {nf.format(totalTokens(session.counts))}
          </KeyFigure>
          {hasFees ? (
            <KeyFigure icon={BanknoteIcon} label={t('historyTotalFees')}>
              <span data-testid="session-fees">{formatBdt(locale, session.totalFeeBdt ?? 0)}</span>
            </KeyFigure>
          ) : null}
          {patientCount !== undefined ? (
            <KeyFigure icon={UsersIcon} label={t('historyPatientCount')}>
              {nf.format(patientCount)}
            </KeyFigure>
          ) : null}
          {session.freeCount !== undefined ? (
            <KeyFigure icon={UsersIcon} label={t('historyFree')}>
              <span data-testid="session-free">{nf.format(session.freeCount)}</span>
            </KeyFigure>
          ) : null}
          {averageWaitSeconds !== undefined ? (
            <KeyFigure icon={HistoryIcon} label={t('historyAverageWait')}>
              {averageWaitSeconds === null ? dash : formatWait(t, averageWaitSeconds)}
            </KeyFigure>
          ) : null}
          {longestWaitSeconds !== undefined ? (
            <KeyFigure icon={HistoryIcon} label={t('historyLongestWait')}>
              {longestWaitSeconds === null ? dash : formatWait(t, longestWaitSeconds)}
            </KeyFigure>
          ) : null}
        </div>

        <OutcomeSummary counts={session.counts} />
      </section>

      {queues.length > 0 ? (
        <section aria-labelledby="history-by-queue">
          <h2 id="history-by-queue" className="mb-2 font-semibold">
            {t('historyByQueue')}
          </h2>
          <div className={`${panel} overflow-hidden`}>
            <table className="w-full min-w-0 border-collapse text-left text-sm">
              <thead className="max-md:sr-only">
                <tr className="border-b border-brand-navy/10 bg-brand-mist/95 text-xs font-semibold tracking-wide text-brand-navy/65 uppercase dark:border-white/10 dark:bg-brand-navy/95 dark:text-white/65">
                  <th scope="col" className="px-4 py-2.5">{t('historyColQueue')}</th>
                  <th scope="col" className="px-4 py-2.5 text-right">{t('historyTokens')}</th>
                  <th scope="col" className="px-4 py-2.5 text-right"><Dot tone="seen" />{t('boardTokenEntered')}</th>
                  <th scope="col" className="px-4 py-2.5 text-right"><Dot tone="missed" />{t('boardTokenSkipped')}</th>
                  <th scope="col" className="px-4 py-2.5 text-right"><Dot tone="cancelled" />{t('boardTokenCancelled')}</th>
                  <th scope="col" className="px-4 py-2.5 text-right"><Dot tone="waiting" />{t('historyNotSeen')}</th>
                  {hasQueueFees ? (
                    <th scope="col" className="px-4 py-2.5 text-right">{t('historyTotalFees')}</th>
                  ) : null}
                </tr>
              </thead>
              <tbody className="max-md:block max-md:divide-y max-md:divide-brand-navy/10 max-md:dark:divide-white/10">
                {queues.map((queue) => {
                  const numbers: { key: string; label: string; value: number; tone: keyof typeof outcomeTone }[] = [
                    { key: 'seen', label: t('boardTokenEntered'), value: queue.counts.ENTERED ?? 0, tone: 'seen' },
                    { key: 'missed', label: t('boardTokenSkipped'), value: queue.counts.SKIPPED ?? 0, tone: 'missed' },
                    { key: 'cancelled', label: t('boardTokenCancelled'), value: queue.counts.CANCELLED ?? 0, tone: 'cancelled' },
                    { key: 'waiting', label: t('historyNotSeen'), value: notSeen(queue.counts), tone: 'waiting' },
                  ]
                  return (
                    <tr
                      key={queue.queueTypeId}
                      className="border-b border-brand-navy/8 last:border-0 max-md:grid max-md:grid-cols-2 max-md:gap-x-3 max-md:gap-y-2.5 sm:max-md:grid-cols-4 max-md:border-0 max-md:p-3 dark:border-white/10"
                    >
                      <th
                        scope="row"
                        className={`${queueCell} font-semibold max-md:col-span-2 max-md:flex max-md:flex-wrap max-md:items-baseline max-md:justify-between max-md:gap-x-3 max-md:gap-y-0.5 sm:max-md:col-span-4`}
                      >
                        <span className="min-w-0 truncate">{queueName(locale, queue)}</span>
                        <span className="text-xs font-medium text-brand-navy/65 md:hidden dark:text-white/65">
                          {t('historyTokens')}{' '}
                          <span className="font-bold tabular-nums text-brand-navy dark:text-white">
                            {nf.format(totalTokens(queue.counts))}
                          </span>
                          {queue.feeBdt !== undefined ? (
                            <>
                              {' · '}
                              <span className="font-bold tabular-nums text-brand-navy dark:text-white">
                                {formatBdt(locale, queue.feeBdt)}
                              </span>
                            </>
                          ) : null}
                        </span>
                      </th>
                      <td className={`${queueCell} text-right tabular-nums max-md:hidden`}>
                        {nf.format(totalTokens(queue.counts))}
                      </td>
                      {numbers.map((item) => (
                        <td
                          key={item.key}
                          className={`${queueCell} text-right tabular-nums max-md:text-left ${
                            item.value === 0 ? 'text-brand-navy/40 dark:text-white/40' : ''
                          }`}
                        >
                          <span className="mb-0.5 flex items-center text-[0.7rem] font-semibold text-brand-navy/55 md:hidden dark:text-white/55">
                            <Dot tone={item.tone} />
                            <span className="truncate">{item.label}</span>
                          </span>
                          {nf.format(item.value)}
                        </td>
                      ))}
                      {hasQueueFees ? (
                        <td className={`${queueCell} text-right font-semibold tabular-nums max-md:hidden`}>
                          {queue.feeBdt !== undefined ? formatBdt(locale, queue.feeBdt) : dash}
                        </td>
                      ) : null}
                    </tr>
                  )
                })}
              </tbody>
            </table>
          </div>
        </section>
      ) : null}

      <section aria-labelledby="history-patients">
        <h2 id="history-patients" className="mb-2 font-semibold">
          {t('historyPatients')}
        </h2>
        <div className="mb-3 flex flex-wrap gap-2" role="group" aria-label={t('historyPatients')}>
          {(['', ...tokenStatuses] as const)
            .filter((value) => value === '' || (counts[value] ?? 0) > 0 || status === value)
            .map((value) => {
              const selected = status === value
              const label = value === '' ? t('historyFilterAll') : t(tokenStatusKey[value])
              const count = value === '' ? totalTokens(session.counts) : (counts[value] ?? 0)
              return (
                <button
                  key={value || 'all'}
                  type="button"
                  aria-pressed={selected}
                  onClick={() => setStatus(value)}
                  className={[
                    'min-h-10 rounded-full border px-3 text-sm font-medium focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none',
                    selected
                      ? 'border-brand-navy bg-brand-navy text-white dark:border-white dark:bg-white dark:text-brand-navy'
                      : 'border-brand-navy/20 bg-white text-brand-navy dark:border-white/20 dark:bg-brand-navy-raised dark:text-white',
                  ].join(' ')}
                >
                  {label} {nf.format(count)}
                </button>
              )
            })}
        </div>

        <div className="mb-3 flex flex-wrap items-center gap-2">
          <div className="relative min-w-0 flex-1 basis-56">
            <label htmlFor="history-token-search" className="sr-only">
              {t('historySearch')}
            </label>
            <SearchIcon
              width={18}
              height={18}
              className="pointer-events-none absolute top-1/2 left-3 -translate-y-1/2 text-brand-navy/50 dark:text-white/50"
            />
            <input
              id="history-token-search"
              type="search"
              placeholder={t('historySearch')}
              value={searchInput}
              onChange={(event) => setSearchInput(event.target.value)}
              className="block min-h-11 w-full rounded-lg border border-brand-navy/15 bg-white py-2 pr-3 pl-10 text-sm text-brand-navy shadow-sm outline-none placeholder:text-brand-navy/45 focus-visible:ring-2 focus-visible:ring-brand-coral/50 dark:border-brand-navy-line dark:bg-brand-navy-raised dark:text-white dark:placeholder:text-white/45"
            />
          </div>
          {/* Phones have no heading row, so sorting is a menu there. */}
          <div className="flex items-center gap-2 md:hidden">
            <label htmlFor="history-token-sort" className="sr-only">
              {t('historySortLabel')}
            </label>
            <select
              id="history-token-sort"
              value={sort}
              onChange={(event) => {
                const next = event.target.value as TokenSort
                setSort(next)
                setAscending(!newestFirst.has(next))
              }}
              className="block min-h-11 rounded-lg border border-brand-navy/15 bg-white px-3 py-2 text-sm text-brand-navy shadow-sm outline-none focus-visible:ring-2 focus-visible:ring-brand-coral/50 dark:border-brand-navy-line dark:bg-brand-navy-raised dark:text-white"
            >
              <option value="serial">{t('historyColToken')}</option>
              <option value="name">{t('historyColPatient')}</option>
              <option value="id">{t('patientsSortId')}</option>
              <option value="queue">{t('historyColQueue')}</option>
              <option value="issued">{t('historyColIssued')}</option>
              <option value="status">{t('boardColStatus')}</option>
            </select>
            <button
              type="button"
              className={`${secondaryButton} !min-h-11 !px-3`}
              aria-pressed={ascending}
              onClick={() => setAscending((current) => !current)}
            >
              {t('patientsReverse')}
            </button>
          </div>
        </div>

        {tokens.isPending ? <PagePreloader /> : null}
        {tokens.isError ? (
          <NoticeBanner tone="error">{t('historyLoadFailed')}</NoticeBanner>
        ) : null}
        {tokens.isSuccess && rows.length === 0 ? (
          <p className="text-sm text-brand-navy/70 dark:text-white/70">
            {search ? t('historyNoMatch') : t('historyNoPatients')}
          </p>
        ) : null}

        {rows.length > 0 ? (
          <div className={`${panel} overflow-hidden`}>
            {/* Fixed height; no `overscroll-contain`, so a drag at the end moves the page on phones. */}
            <div className="h-[max(22rem,calc(100dvh-20rem))] overflow-auto">
              <table
                className="w-full min-w-0 border-collapse text-left text-sm"
                aria-label={t('historyTokenList')}
              >
                <thead className="sticky top-0 z-10 max-md:sr-only">
                  <tr className="border-b border-brand-navy/10 bg-brand-mist/95 text-xs font-semibold tracking-wide text-brand-navy/65 uppercase backdrop-blur dark:border-white/10 dark:bg-brand-navy/95 dark:text-white/65">
                    {heading('serial', t('historyColToken'))}
                    {heading('name', t('historyColPatient'))}
                    {heading('queue', t('historyColQueue'))}
                    {heading('issued', t('historyColIssued'))}
                    <th scope="col" className="px-4 py-3">{t('historyColCalled')}</th>
                    <th scope="col" className="px-4 py-3">{t('historyColWait')}</th>
                    {heading('status', t('boardColStatus'))}
                    <th scope="col" className="px-4 py-3">{t('historyColFinished')}</th>
                    {hasFees ? <th scope="col" className="px-4 py-3 text-right">{t('historyColFee')}</th> : null}
                  </tr>
                </thead>
                <tbody className="max-md:block max-md:space-y-3 max-md:p-3">
                  {rows.map((token) => {
                    const waited = waitSeconds(token)
                    return (
                      <tr
                        key={token.id}
                        className="border-b border-brand-navy/8 transition-colors last:border-0 hover:bg-brand-mist/60 max-md:grid max-md:grid-cols-2 max-md:gap-x-4 max-md:gap-y-3 max-md:rounded-xl max-md:border max-md:border-brand-navy/10 max-md:p-4 max-md:shadow-sm max-md:hover:bg-transparent dark:border-white/10 dark:hover:bg-white/5 max-md:dark:border-white/10"
                      >
                        <td className={`${cell} text-base font-bold tabular-nums`}>
                          <Labelled label={t('historyColToken')} />
                          {nf.format(token.serial)}
                        </td>
                        <td className={`${cell} max-md:order-first max-md:col-span-2`}>
                          <p className="font-semibold">{token.patientName}</p>
                          <p className="text-xs tabular-nums text-brand-navy/60 dark:text-white/60">
                            {formatDigits(token.clinicPatientId, locale)}
                          </p>
                        </td>
                        <td className={cell}>
                          <Labelled label={t('historyColQueue')} />
                          {queueName(locale, token)}
                        </td>
                        <td className={`${cell} whitespace-nowrap tabular-nums`}>
                          <Labelled label={t('historyColIssued')} />
                          {formatClock(locale, token.issuedAt)}
                        </td>
                        <td className={`${cell} whitespace-nowrap tabular-nums`}>
                          <Labelled label={t('historyColCalled')} />
                          {token.firstCalledAt ? formatClock(locale, token.firstCalledAt) : dash}
                        </td>
                        <td className={`${cell} whitespace-nowrap tabular-nums`}>
                          <Labelled label={t('historyColWait')} />
                          {waited === null ? dash : formatWait(t, waited)}
                        </td>
                        <td className={cell}>
                          <Labelled label={t('boardColStatus')} />
                          <span
                            className={`inline-flex rounded-full border px-2.5 py-0.5 text-xs font-medium ${outcomeTone[statusTone[token.status]].pill}`}
                          >
                            {t(tokenStatusKey[token.status])}
                          </span>
                        </td>
                        <td className={cell}>
                          <Labelled label={t('historyColFinished')} />
                          {outcomeText(token, t, locale) || dash}
                        </td>
                        {hasFees ? (
                          <td className={`${cell} tabular-nums md:text-right`}>
                            <Labelled label={t('historyColFee')} />
                            {token.feeBdt != null && token.status !== 'CANCELLED' ? (
                              formatBdt(locale, token.feeBdt)
                            ) : (
                              <span className="text-brand-navy/40 dark:text-white/40">{dash}</span>
                            )}
                          </td>
                        ) : null}
                      </tr>
                    )
                  })}
                </tbody>
              </table>

              <ScrollSentinel
                onReach={() => void tokens.fetchNextPage()}
                disabled={!tokens.hasNextPage || tokens.isFetchingNextPage || tokens.isFetchNextPageError}
              />
              <div className="flex min-h-12 items-center justify-center px-4 pb-3">
                {tokens.isFetchingNextPage ? (
                  <p className="text-sm text-brand-navy/70 dark:text-white/70" role="status">
                    {t('historyLoadingMore')}
                  </p>
                ) : tokens.isFetchNextPageError || (tokens.hasNextPage && !canObserveScroll()) ? (
                  <button
                    type="button"
                    className={secondaryButton}
                    onClick={() => void tokens.fetchNextPage()}
                  >
                    {tokens.isFetchNextPageError ? t('usersRetry') : t('historyShowMore')}
                  </button>
                ) : null}
              </div>
            </div>
          </div>
        ) : null}
      </section>
    </div>
  )
}
