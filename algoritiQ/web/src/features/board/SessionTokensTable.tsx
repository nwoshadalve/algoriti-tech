/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useEffect, useState } from 'react'
import { useLocale } from '@/core/i18n/LocaleProvider'
import type { BoardTokenView, TokenSort } from '@/core/api/types'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { LoadingButton } from '@/core/ui/LoadingButton'
import {
  formatWaitElapsed,
  queueDisplayName,
  tokenStatusLabelKey,
  waitingElapsedMs,
} from '@/features/board/boardFormat'
import { sortHeadingLabel, type SortableColumn } from '@/features/board/QueueDeskTableToolbar'
import { TokenRowActions } from '@/features/board/TokenRowActions'
import { formatQueueSerial } from '@/features/queue/formatQueueSerial'

type SessionTokensTableProps = {
  tokens: BoardTokenView[]
  printerBusyTokenId: string | null
  sort: TokenSort
  ascending: boolean
  onSort: (column: TokenSort) => void
  emptyFiltered: boolean
  onClearFilters: () => void
  hasMore: boolean
  isLoadingMore: boolean
  onLoadMore: () => void
  onPrint: (token: BoardTokenView) => void
  onReprint: (token: BoardTokenView) => void
  onEditPatient: (token: BoardTokenView) => void
  onCancel: (token: BoardTokenView) => void
  embedded?: boolean
}

const cell =
  'px-3 py-2.5 text-sm max-md:flex max-md:items-start max-md:justify-between max-md:gap-4 max-md:px-0 max-md:py-1.5 sm:px-4 sm:py-3'

function statusPillClass(status: BoardTokenView['status']): string {
  const base =
    'inline-flex max-w-full rounded-full border px-2 py-0.5 text-xs font-medium leading-snug'
  switch (status) {
    case 'WAITING':
      return `${base} border-brand-navy/20 bg-brand-mist text-brand-navy dark:border-white/20 dark:bg-white/10 dark:text-white`
    case 'CALLED':
      return `${base} border-amber-500/40 bg-amber-50 text-amber-950 dark:border-amber-400/40 dark:bg-amber-950/40 dark:text-amber-100`
    case 'ENTERED':
      return `${base} border-emerald-600/30 bg-emerald-50 text-emerald-950 dark:border-emerald-400/30 dark:bg-emerald-950/30 dark:text-emerald-100`
    case 'SKIPPED':
      return `${base} border-orange-500/35 bg-orange-50 text-orange-950 dark:border-orange-400/35 dark:bg-orange-950/30 dark:text-orange-100`
    case 'CANCELLED':
      return `${base} border-brand-navy/15 bg-white text-brand-navy/60 dark:border-white/15 dark:bg-brand-navy dark:text-white/60`
  }
}

/** Session table with sortable headers (md+) and card rows on small screens. */
export function SessionTokensTable({
  tokens,
  printerBusyTokenId,
  sort,
  ascending,
  onSort,
  emptyFiltered,
  onClearFilters,
  hasMore,
  isLoadingMore,
  onLoadMore,
  onPrint,
  onReprint,
  onEditPatient,
  onCancel,
  embedded,
}: SessionTokensTableProps) {
  const { t, locale } = useLocale()
  const [now, setNow] = useState(() => Date.now())

  useEffect(() => {
    const timer = setInterval(() => setNow(Date.now()), 1000)
    return () => clearInterval(timer)
  }, [])

  const shellClass = embedded
    ? 'flex min-h-0 flex-1 flex-col overflow-hidden'
    : 'flex min-h-0 flex-col overflow-hidden rounded-2xl border border-brand-navy/10 bg-white shadow-sm dark:border-white/10 dark:bg-brand-navy-raised'
  const scrollClass = embedded
    ? 'min-h-[480px] flex-1 overflow-y-auto overscroll-contain max-md:min-h-[480px] md:min-h-0'
    : 'max-h-[min(28rem,50vh)] overflow-y-auto overscroll-contain max-md:min-h-[480px]'

  function headingButton(column: SortableColumn, tokenSort: TokenSort) {
    const active = sort === tokenSort
    const ariaSort = active ? (ascending ? 'ascending' : 'descending') : 'none'
    return (
      <th scope="col" className="px-3 py-2.5 sm:px-4 sm:py-3" aria-sort={ariaSort}>
        <button
          type="button"
          className="inline-flex min-h-11 w-full items-center gap-1 text-left text-xs font-semibold tracking-wide text-brand-navy/70 uppercase hover:text-brand-navy dark:text-white/70 dark:hover:text-white"
          onClick={() => onSort(tokenSort)}
        >
          {sortHeadingLabel(t, column)}
          {active ? <span aria-hidden>{ascending ? '↑' : '↓'}</span> : null}
        </button>
      </th>
    )
  }

  const printerBusy = printerBusyTokenId != null

  return (
    <div className={shellClass}>
      <div className={scrollClass}>
        <table className="w-full min-w-0 border-collapse text-left" aria-label={t('boardSessionTableLabel')}>
          <thead className="sticky top-0 z-10 max-md:sr-only">
            <tr className="border-b border-brand-navy/10 bg-brand-mist/90 backdrop-blur dark:border-white/10 dark:bg-brand-navy/90">
              {headingButton('id', 'id')}
              {headingButton('name', 'name')}
              {headingButton('serial', 'serial')}
              {headingButton('queue', 'queue')}
              {headingButton('wait', 'wait')}
              {headingButton('status', 'status')}
              <th scope="col" className="w-[5.5rem] px-2 py-2.5 sm:px-4">
                <span className="sr-only">{t('usersColActions')}</span>
              </th>
            </tr>
          </thead>
          <tbody className="max-md:block max-md:space-y-3 max-md:p-3 md:p-0">
            {tokens.length === 0 ? (
              <tr className="max-md:block">
                <td colSpan={7} className="px-4 py-8 text-center text-sm text-brand-navy/65 dark:text-white/65">
                  {emptyFiltered ? (
                    <div className="flex flex-col items-center gap-3">
                      <p>{t('boardNoPatientsMatch')}</p>
                      <button type="button" className={secondaryButton} onClick={onClearFilters}>
                        {t('boardClearFilters')}
                      </button>
                    </div>
                  ) : (
                    t('boardSessionEmpty')
                  )}
                </td>
              </tr>
            ) : (
              tokens.map((row) => {
                const waitMs = waitingElapsedMs(
                  row.issuedAt,
                  now,
                  row.firstCalledAt,
                  row.enteredAt,
                )
                const actions = (
                  <TokenRowActions
                    token={row}
                    printerBusy={printerBusy}
                    onPrint={onPrint}
                    onReprint={onReprint}
                    onEditPatient={onEditPatient}
                    onCancel={onCancel}
                  />
                )
                return (
                  <tr
                    key={row.id}
                    className="border-b border-brand-navy/10 md:last:border-0 max-md:block max-md:overflow-visible max-md:rounded-2xl max-md:border max-md:bg-white max-md:shadow-sm dark:border-white/10 max-md:dark:bg-brand-navy-raised"
                  >
                    <td colSpan={7} className="block p-4 md:hidden">
                      <div className="flex flex-col gap-2">
                        <div className="flex items-start gap-2">
                          <span className="shrink-0 text-base font-bold tabular-nums">
                            {formatQueueSerial(row.serial, locale)}
                          </span>
                          <span className="min-w-0 flex-1 text-sm leading-snug font-semibold break-words line-clamp-2">
                            {row.patientBengaliName}
                          </span>
                          <span className="shrink-0 text-xs tabular-nums text-brand-navy/70 dark:text-white/70">
                            {formatWaitElapsed(waitMs, locale)}
                          </span>
                        </div>
                        <div className="relative z-20 flex min-w-0 items-center gap-2">
                          <p className="min-w-0 flex-1 text-xs leading-snug text-brand-navy/65 dark:text-white/65">
                            <span className="tabular-nums">{row.clinicPatientId}</span>
                            <span aria-hidden> · </span>
                            {queueDisplayName(locale, row.queueEnglishName, row.queueBengaliName)}
                          </p>
                          <span className={`${statusPillClass(row.status)} shrink-0`}>
                            {t(tokenStatusLabelKey[row.status])}
                          </span>
                          {actions}
                        </div>
                      </div>
                    </td>
                    <td className={`${cell} max-md:hidden tabular-nums md:table-cell`} data-label={t('boardColPatientId')}>
                      <span className="hidden text-brand-navy/60 max-md:inline dark:text-white/60">
                        {t('boardColPatientId')}
                      </span>
                      {row.clinicPatientId}
                    </td>
                    <td className={`${cell} max-md:hidden min-w-0 break-words md:table-cell`} data-label={t('boardColName')}>
                      <span className="hidden text-brand-navy/60 max-md:inline dark:text-white/60">
                        {t('boardColName')}
                      </span>
                      <span className="line-clamp-2">{row.patientBengaliName}</span>
                    </td>
                    <td className={`${cell} max-md:hidden font-bold tabular-nums md:table-cell`} data-label={t('boardColSerial')}>
                      <span className="hidden text-brand-navy/60 max-md:inline dark:text-white/60">
                        {t('boardColSerial')}
                      </span>
                      {formatQueueSerial(row.serial, locale)}
                    </td>
                    <td className={`${cell} max-md:hidden md:table-cell`} data-label={t('boardColQueue')}>
                      <span className="hidden text-brand-navy/60 max-md:inline dark:text-white/60">
                        {t('boardColQueue')}
                      </span>
                      {queueDisplayName(locale, row.queueEnglishName, row.queueBengaliName)}
                    </td>
                    <td className={`${cell} max-md:hidden tabular-nums md:table-cell`} data-label={t('boardColWaiting')}>
                      <span className="hidden text-brand-navy/60 max-md:inline dark:text-white/60">
                        {t('boardColWaiting')}
                      </span>
                      {formatWaitElapsed(waitMs, locale)}
                    </td>
                    <td className={`${cell} max-md:hidden md:table-cell`} data-label={t('boardColStatus')}>
                      <span className="hidden text-brand-navy/60 max-md:inline dark:text-white/60">
                        {t('boardColStatus')}
                      </span>
                      <span className={statusPillClass(row.status)}>{t(tokenStatusLabelKey[row.status])}</span>
                    </td>
                    <td className="max-md:hidden px-2 py-3 md:table-cell">
                      {actions}
                    </td>
                  </tr>
                )
              })
            )}
          </tbody>
        </table>
      </div>
      {hasMore ? (
        <div className="border-t border-brand-navy/10 p-3 dark:border-white/10">
          <LoadingButton
            className="w-full sm:mx-auto sm:max-w-xs"
            isLoading={isLoadingMore}
            loadingLabel={t('boardWorking')}
            onClick={onLoadMore}
          >
            {t('boardLoadMore')}
          </LoadingButton>
        </div>
      ) : null}
    </div>
  )
}
