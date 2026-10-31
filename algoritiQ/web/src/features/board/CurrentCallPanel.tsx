/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { markTokenEntered, markTokenSkipped, recallCalledToken } from '@/core/api/board'
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
import { useState } from 'react'

type CurrentCallPanelProps = {
  chamberId: string
  called: BoardTokenView | null
  onRefresh: () => void
  onCancel: (token: BoardTokenView) => void
}

/** Actions for the token currently in CALLED state. */
export function CurrentCallPanel({ chamberId, called, onRefresh, onCancel }: CurrentCallPanelProps) {
  const { t, locale } = useLocale()
  const toast = useToast()
  const [busy, setBusy] = useState('')

  if (!called) {
    return (
      <Card as="section" labelledBy="board-current-call">
        <h2 id="board-current-call" className="text-sm font-semibold text-brand-navy/70 dark:text-white/70">
          {t('boardCurrentCallTitle')}
        </h2>
        <p className="mt-2 text-sm text-brand-navy/65 dark:text-white/65">{t('boardCurrentCallEmpty')}</p>
      </Card>
    )
  }

  const activeCall = called
  const serial = formatQueueSerial(activeCall.serial, locale)
  const queueName = queueDisplayName(locale, activeCall.queueEnglishName, activeCall.queueBengaliName)

  async function run(action: 'entered' | 'skipped' | 'recall') {
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

  return (
    <Card as="section" labelledBy="board-current-call">
      <h2 id="board-current-call" className="text-sm font-semibold text-brand-navy/70 dark:text-white/70">
        {t('boardCurrentCallTitle')}
      </h2>
      <div className="mt-3 flex flex-wrap items-baseline gap-x-4 gap-y-1">
        <p className="text-3xl font-bold tabular-nums">{serial}</p>
        <p className="text-sm font-medium">{activeCall.patientBengaliName}</p>
        <p className="text-sm text-brand-navy/65 dark:text-white/65">{activeCall.clinicPatientId}</p>
        <p className="text-sm text-brand-navy/65 dark:text-white/65">{queueName}</p>
      </div>
      <div className="mt-4 flex flex-col gap-2 sm:flex-row sm:flex-wrap">
        <LoadingButton
          isLoading={busy === 'recall'}
          loadingLabel={t('boardWorking')}
          disabled={!!busy}
          className="sm:w-auto sm:min-w-36"
          onClick={() => void run('recall')}
        >
          {t('boardRecall')}
        </LoadingButton>
        <LoadingButton
          isLoading={busy === 'entered'}
          loadingLabel={t('boardWorking')}
          disabled={!!busy}
          className="sm:w-auto sm:min-w-36"
          onClick={() => void run('entered')}
        >
          {t('boardPatientEntered')}
        </LoadingButton>
        <LoadingButton
          isLoading={busy === 'skipped'}
          loadingLabel={t('boardWorking')}
          disabled={!!busy}
          className="sm:w-auto sm:min-w-36"
          onClick={() => void run('skipped')}
        >
          {t('boardPatientMissed')}
        </LoadingButton>
        <button
          type="button"
          className={`${secondaryButton} sm:w-auto`}
          disabled={!!busy}
          onClick={() => onCancel(activeCall)}
        >
          {t('boardCancelToken')}
        </button>
      </div>
    </Card>
  )
}
