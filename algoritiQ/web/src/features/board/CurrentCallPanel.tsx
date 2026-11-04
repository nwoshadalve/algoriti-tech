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
import { formatQueueSerial } from '@/features/queue/formatQueueSerial'

type CurrentCallPanelProps = {
  chamberId: string
  called: BoardTokenView | null
  onRefresh: () => void
  onCancel: (token: BoardTokenView) => void
  layout?: 'card' | 'desk'
}

/** Actions for the token currently in CALLED state. */
export function CurrentCallPanel({
  chamberId,
  called,
  onRefresh,
  onCancel,
  layout = 'card',
}: CurrentCallPanelProps) {
  const { t, locale } = useLocale()
  const toast = useToast()
  const [busy, setBusy] = useState('')

  async function run(action: 'entered' | 'skipped' | 'recall', activeCall: BoardTokenView) {
    const token = readSession()
    if (!token || busy) return
    setBusy(action)
    try {
      if (action === 'recall') {
        await recallCalledToken(token, chamberId, newBoardCommandId(), activeCall.queueTypeId)
        toast.success(t('boardRecallSent'))
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
    const btnClass = compact
      ? '!min-h-9 !w-auto !px-3 !py-1.5 !text-xs sm:!min-w-0'
      : 'sm:w-auto sm:min-w-36'
    return (
      <div className={`flex flex-wrap gap-2 ${compact ? 'mt-3' : 'mt-4 sm:flex-row'}`}>
        <LoadingButton
          isLoading={busy === 'recall'}
          loadingLabel={t('boardWorking')}
          disabled={!!busy}
          className={btnClass}
          onClick={() => void run('recall', activeCall)}
        >
          {t('boardRecall')}
        </LoadingButton>
        <LoadingButton
          isLoading={busy === 'entered'}
          loadingLabel={t('boardWorking')}
          disabled={!!busy}
          className={btnClass}
          onClick={() => void run('entered', activeCall)}
        >
          {t('boardPatientEntered')}
        </LoadingButton>
        <LoadingButton
          isLoading={busy === 'skipped'}
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

  if (!called) {
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

  const serial = formatQueueSerial(called.serial, locale)
  const queueName = queueDisplayName(locale, called.queueEnglishName, called.queueBengaliName)
  const compact = layout === 'desk'

  const inner = (
    <>
      <div className={`flex flex-wrap items-baseline gap-x-3 gap-y-1 ${compact ? 'mt-2' : 'mt-3'}`}>
        <p className="text-3xl font-bold tabular-nums text-brand-coral-action">{serial}</p>
        <p className="text-sm font-medium">{called.patientBengaliName}</p>
        <p className="text-sm text-brand-navy/65 dark:text-white/65">{called.clinicPatientId}</p>
        <p className={`text-sm text-brand-navy/65 dark:text-white/65 ${compact ? 'w-full' : ''}`}>{queueName}</p>
      </div>
      {renderActions(called, compact)}
    </>
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
