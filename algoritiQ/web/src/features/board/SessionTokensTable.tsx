/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useEffect, useState } from 'react'
import { useLocale } from '@/core/i18n/LocaleProvider'
import type { BoardTokenView } from '@/core/api/types'
import { PrinterIcon } from '@/core/ui/icons'
import { IconButton } from '@/core/ui/IconButton'
import {
  formatDurationMinutes,
  queueDisplayName,
  tokenStatusLabelKey,
  waitingMinutesSince,
} from '@/features/board/boardFormat'
import { formatQueueSerial } from '@/features/queue/formatQueueSerial'

type SessionTokensTableProps = {
  tokens: BoardTokenView[]
  printerBusyTokenId: string | null
  onReprint: (token: BoardTokenView) => void
}

const cell =
  'px-4 py-3 text-sm max-md:flex max-md:items-center max-md:justify-between max-md:gap-4 max-md:px-0 max-md:py-1.5'

/** Current-session tokens in a fixed-height scrolling table. */
export function SessionTokensTable({ tokens, printerBusyTokenId, onReprint }: SessionTokensTableProps) {
  const { t, locale } = useLocale()
  const [now, setNow] = useState(() => Date.now())

  useEffect(() => {
    const timer = setInterval(() => setNow(Date.now()), 60_000)
    return () => clearInterval(timer)
  }, [])

  return (
    <div className="flex min-h-0 flex-col overflow-hidden rounded-2xl border border-brand-navy/10 bg-white shadow-sm dark:border-white/10 dark:bg-brand-navy-raised">
      <div className="max-h-[min(28rem,50vh)] overflow-y-auto overscroll-contain">
        <table className="w-full border-collapse text-left" aria-label={t('boardSessionTableLabel')}>
          <thead className="sticky top-0 z-10 max-md:sr-only">
            <tr className="border-b border-brand-navy/10 bg-brand-mist/90 backdrop-blur dark:border-white/10 dark:bg-brand-navy/90">
              <th scope="col" className="px-4 py-3 text-xs font-semibold tracking-wide text-brand-navy/70 uppercase dark:text-white/70">
                {t('boardColSerial')}
              </th>
              <th scope="col" className="px-4 py-3 text-xs font-semibold tracking-wide text-brand-navy/70 uppercase dark:text-white/70">
                {t('boardColQueue')}
              </th>
              <th scope="col" className="px-4 py-3 text-xs font-semibold tracking-wide text-brand-navy/70 uppercase dark:text-white/70">
                {t('boardColPatientId')}
              </th>
              <th scope="col" className="px-4 py-3 text-xs font-semibold tracking-wide text-brand-navy/70 uppercase dark:text-white/70">
                {t('boardColName')}
              </th>
              <th scope="col" className="px-4 py-3 text-xs font-semibold tracking-wide text-brand-navy/70 uppercase dark:text-white/70">
                {t('boardColWaiting')}
              </th>
              <th scope="col" className="px-4 py-3 text-xs font-semibold tracking-wide text-brand-navy/70 uppercase dark:text-white/70">
                {t('boardColStatus')}
              </th>
              <th scope="col" className="px-4 py-3 text-right text-xs font-semibold tracking-wide text-brand-navy/70 uppercase dark:text-white/70">
                {t('usersColActions')}
              </th>
            </tr>
          </thead>
          <tbody className="max-md:block max-md:space-y-3 max-md:p-3 md:p-0">
            {tokens.length === 0 ? (
              <tr className="max-md:block">
                <td colSpan={7} className="px-4 py-8 text-center text-sm text-brand-navy/65 dark:text-white/65">
                  {t('boardSessionEmpty')}
                </td>
              </tr>
            ) : (
              tokens.map((row) => {
                const waiting = waitingMinutesSince(row.issuedAt, now)
                const printAttention =
                  row.latestPrintStatus === 'FAILED' || row.latestPrintStatus === 'UNKNOWN'
                const printerBusy = printerBusyTokenId === row.id
                return (
                  <tr
                    key={row.id}
                    className="border-b border-brand-navy/10 md:last:border-0 max-md:block max-md:rounded-2xl max-md:border max-md:bg-white max-md:p-4 max-md:shadow-sm dark:border-white/10 max-md:dark:bg-brand-navy-raised"
                  >
                    <td className={`${cell} font-bold tabular-nums`} data-label={t('boardColSerial')}>
                      <span className="hidden text-brand-navy/60 max-md:inline dark:text-white/60">{t('boardColSerial')}</span>
                      {formatQueueSerial(row.serial, locale)}
                    </td>
                    <td className={cell} data-label={t('boardColQueue')}>
                      <span className="hidden text-brand-navy/60 max-md:inline dark:text-white/60">{t('boardColQueue')}</span>
                      {queueDisplayName(locale, row.queueEnglishName, row.queueBengaliName)}
                    </td>
                    <td className={cell} data-label={t('boardColPatientId')}>
                      <span className="hidden text-brand-navy/60 max-md:inline dark:text-white/60">{t('boardColPatientId')}</span>
                      {row.clinicPatientId}
                    </td>
                    <td className={cell} data-label={t('boardColName')}>
                      <span className="hidden text-brand-navy/60 max-md:inline dark:text-white/60">{t('boardColName')}</span>
                      {row.patientBengaliName}
                    </td>
                    <td className={cell} data-label={t('boardColWaiting')}>
                      <span className="hidden text-brand-navy/60 max-md:inline dark:text-white/60">{t('boardColWaiting')}</span>
                      {formatDurationMinutes(waiting, locale)}
                    </td>
                    <td className={cell} data-label={t('boardColStatus')}>
                      <span className="hidden text-brand-navy/60 max-md:inline dark:text-white/60">{t('boardColStatus')}</span>
                      <span className="inline-flex flex-col gap-0.5">
                        <span>{t(tokenStatusLabelKey[row.status])}</span>
                        {printAttention ? (
                          <span className="text-xs text-amber-800 dark:text-amber-200">{t('boardPrintAttention')}</span>
                        ) : null}
                      </span>
                    </td>
                    <td className={`${cell} max-md:pt-2 md:text-right`}>
                      <IconButton
                        label={t('boardReprint')}
                        icon={PrinterIcon}
                        disabled={printerBusy || printerBusyTokenId != null}
                        disabledReason={printerBusyTokenId != null ? t('boardPrinterBusy') : undefined}
                        onClick={() => onReprint(row)}
                        labelOnSmall
                      />
                    </td>
                  </tr>
                )
              })
            )}
          </tbody>
        </table>
      </div>
    </div>
  )
}
