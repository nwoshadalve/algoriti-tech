/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useState } from 'react'
import { markTokenEntered, markTokenSkipped, recallCalledToken } from '@/core/api/queueDesk'
import type { BoardTokenView } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useToast } from '@/core/toast/toastContext'
import { Card } from '@/core/ui/Card'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { readSession } from '@/features/auth/session'
import { boardErrorKey } from '@/features/board/boardErrors'
import { newBoardCommandId, queueDisplayName } from '@/features/board/boardFormat'
import { formatDigits, formatQueueSerial } from '@/features/queue/formatQueueSerial'

type CurrentCallPanelProps = {
  chamberId: string
  called: BoardTokenView[]
  onRefresh: () => void
  onCancel: (token: BoardTokenView) => void
  layout?: 'card' | 'desk'
}

/** Actions for each token currently in CALLED state, one per queue at most. */
export function CurrentCallPanel({
  chamberId,
  called,
  onRefresh,
  onCancel,
  layout = 'card',
}: CurrentCallPanelProps) {
  const { t, locale } = useLocale()
  const toast = useToast()
  // Which action of which token is running, as `<token id>:<action>`.
  const [busy, setBusy] = useState('')

  async function run(action: 'entered' | 'skipped' | 'recall', activeCall: BoardTokenView) {
    const token = readSession()
    if (!token || busy) return
    setBusy(`${activeCall.id}:${action}`)
    try {
      if (action === 'recall') {
        await recallCalledToken(token, chamberId, newBoardCommandId(), activeCall.queueTypeId)
        // The first announcement of a token that came up by itself is a call, not a recall.
        toast.success(activeCall.announced === false ? t('boardCallNextSuccess') : t('boardRecallSent'))
      } else if (action === 'entered') {
        await markTokenEntered(token, activeCall.id, newBoardCommandId())
        toast.success(t('boardEnteredToast'))
      } else {
        await markTokenSkipped(token, activeCall.id, newBoardCommandId())
        toast.success(t('boardSkippedToast'))
      }
      onRefresh()
    } catch (error) {
      toast.error(t(boardErrorKey(error)))
    } finally {
      setBusy('')
    }
  }

  function renderActions(activeCall: BoardTokenView, compact: boolean) {
    const running = (action: string) => busy === `${activeCall.id}:${action}`
    // A token that came up on the board by itself is not announced yet: Call announces it.
    const announced = activeCall.announced !== false
    const btnClass = compact
      ? '!min-h-9 !w-auto !px-3 !py-1.5 !text-xs sm:!min-w-0'
      : 'sm:w-auto sm:min-w-36'
    return (
      <div className={`flex flex-wrap gap-2 ${compact ? 'mt-3' : 'mt-4 sm:flex-row'}`}>
        <LoadingButton
          isLoading={running('recall')}
          loadingLabel={t('boardWorking')}
          disabled={!!busy}
          className={btnClass}
          onClick={() => void run('recall', activeCall)}
        >
          {announced ? t('boardRecall') : t('boardCall')}
        </LoadingButton>
        <LoadingButton
          isLoading={running('entered')}
          loadingLabel={t('boardWorking')}
          disabled={!!busy}
          className={btnClass}
          onClick={() => void run('entered', activeCall)}
        >
          {t('boardPatientEntered')}
        </LoadingButton>
        <LoadingButton
          isLoading={running('skipped')}
          loadingLabel={t('boardWorking')}
          disabled={!!busy}
          className={btnClass}
          onClick={() => void run('skipped', activeCall)}
        >
          {t('boardPatientMissed')}
        </LoadingButton>
        <button
          type="button"
          className={`${secondaryButton} ${compact ? '!min-h-9 !w-auto !px-3 !py-1.5 !text-xs' : 'sm:w-auto'}`}
          disabled={!!busy}
          onClick={() => onCancel(activeCall)}
        >
          {t('boardCancelToken')}
        </button>
      </div>
    )
  }

  if (called.length === 0) {
    const empty = <p className="mt-2 text-sm text-brand-navy/65 dark:text-white/65">{t('boardCurrentCallEmpty')}</p>
    if (layout === 'desk') {
      return (
        <div className="rounded-2xl border border-dashed border-brand-navy/15 bg-brand-mist/30 px-4 py-6 text-center text-sm text-brand-navy/65 dark:border-white/15 dark:bg-white/5 dark:text-white/65">
          {t('boardCurrentCallEmpty')}
        </div>
      )
    }
    return (
      <Card as="section" labelledBy="board-current-call">
        <h2 id="board-current-call" className="text-sm font-semibold text-brand-navy/70 dark:text-white/70">
          {t('boardCurrentCallTitle')}
        </h2>
        {empty}
      </Card>
    )
  }

  const compact = layout === 'desk'

  const inner = (
    <ul className={compact ? 'mt-2 flex flex-col gap-3' : 'mt-3 flex flex-col gap-4'}>
      {called.map((token) => {
        const serial = formatQueueSerial(token.serial, locale)
        const queueName = queueDisplayName(locale, token.queueEnglishName, token.queueBengaliName)
        return (
          <li
            key={token.id}
            className="border-t border-brand-navy/10 pt-3 first:border-t-0 first:pt-0 dark:border-white/10"
          >
            <div className="flex flex-wrap items-baseline gap-x-3 gap-y-1">
              <p className="text-3xl font-bold tabular-nums text-brand-coral-action">{serial}</p>
              <p className="text-sm font-medium">{token.patientName}</p>
              <p className="text-sm text-brand-navy/65 dark:text-white/65">{formatDigits(token.clinicPatientId, locale)}</p>
              <p className={`text-sm text-brand-navy/65 dark:text-white/65 ${compact ? 'w-full' : ''}`}>{queueName}</p>
            </div>
            {renderActions(token, compact)}
          </li>
        )
      })}
    </ul>
  )

  if (layout === 'desk') {
    return (
      <div className="rounded-2xl border border-brand-coral/25 bg-gradient-to-br from-brand-coral/10 to-white p-4 dark:from-brand-coral/15 dark:to-brand-navy-raised">
        <p className="text-xs font-bold tracking-wide text-brand-navy/60 uppercase dark:text-white/60">
          {t('boardCurrentCallTitle')}
        </p>
        {inner}
      </div>
    )
  }

  return (
    <Card as="section" labelledBy="board-current-call">
      <h2 id="board-current-call" className="text-sm font-semibold text-brand-navy/70 dark:text-white/70">
        {t('boardCurrentCallTitle')}
      </h2>
      {inner}
    </Card>
  )
}
