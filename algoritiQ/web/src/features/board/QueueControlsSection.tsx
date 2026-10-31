/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useState } from 'react'
import { callNextToken, recallCalledToken } from '@/core/api/board'
import type { BoardTokenView, QueueTypeBoardControl } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useToast } from '@/core/toast/toastContext'
import { Card } from '@/core/ui/Card'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { readSession } from '@/features/auth/session'
import { boardErrorKey } from '@/features/board/boardErrors'
import { newBoardCommandId, queueDisplayName } from '@/features/board/boardFormat'
import { formatQueueSerial } from '@/features/queue/formatQueueSerial'

type QueueControlsSectionProps = {
  chamberId: string
  controls: QueueTypeBoardControl[]
  calledToken: BoardTokenView | null
  sessionOpen: boolean
  onRefresh: () => void
}

/** Per-queue waiting counts, call next, and recall. */
export function QueueControlsSection({
  chamberId,
  controls,
  calledToken,
  sessionOpen,
  onRefresh,
}: QueueControlsSectionProps) {
  const { t, locale } = useLocale()
  const toast = useToast()
  const [busyType, setBusyType] = useState('')
  const [busyRecall, setBusyRecall] = useState('')

  if (!sessionOpen) return null

  async function callNext(queueTypeId: string) {
    const token = readSession()
    if (!token || busyType || busyRecall) return
    setBusyType(queueTypeId)
    try {
      await callNextToken(token, chamberId, newBoardCommandId(), queueTypeId)
      toast.success(t('boardCallNextSuccess'))
      onRefresh()
    } catch (error) {
      toast.error(t(boardErrorKey(error)))
    } finally {
      setBusyType('')
    }
  }

  async function recall(queueTypeId: string) {
    const token = readSession()
    if (!token || busyType || busyRecall) return
    setBusyRecall(queueTypeId)
    try {
      await recallCalledToken(token, chamberId, newBoardCommandId(), queueTypeId)
      toast.success(t('boardRecallSent'))
      onRefresh()
    } catch (error) {
      toast.error(t(boardErrorKey(error)))
    } finally {
      setBusyRecall('')
    }
  }

  return (
    <Card as="section" labelledBy="board-queue-controls">
      <h2 id="board-queue-controls" className="font-semibold">
        {t('boardQueueControlsTitle')}
      </h2>
      {calledToken ? (
        <p className="mt-1 text-sm text-amber-900 dark:text-amber-100" role="status">
          {t('boardCallBlocked', {
            serial: formatQueueSerial(calledToken.serial, locale),
          })}
        </p>
      ) : null}
      <ul className="mt-4 grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
        {controls.map((control) => {
          const name = queueDisplayName(locale, control.englishName, control.bengaliName)
          const loading = busyType === control.queueTypeId
          const recalling = busyRecall === control.queueTypeId
          return (
            <li
              key={control.queueTypeId}
              className="rounded-xl border border-brand-navy/10 bg-brand-mist/40 p-4 dark:border-white/10 dark:bg-white/5"
            >
              <p className="font-semibold">{name}</p>
              <p className="mt-1 text-sm text-brand-navy/70 dark:text-white/70">
                {t('boardWaitingCount', { count: control.waitingCount })}
              </p>
              <p className="text-xs text-brand-navy/60 dark:text-white/60">
                {t('boardNextSerial', { serial: formatQueueSerial(control.nextSerial, locale) })}
              </p>
              <div className="mt-3 flex flex-col gap-2">
                <LoadingButton
                  isLoading={loading}
                  loadingLabel={t('boardWorking')}
                  disabled={!control.canCallNext || !!busyType || !!busyRecall}
                  onClick={() => void callNext(control.queueTypeId)}
                >
                  {t('boardCallNext')}
                </LoadingButton>
                <LoadingButton
                  isLoading={recalling}
                  loadingLabel={t('boardWorking')}
                  disabled={!control.canRecall || !!busyType || !!busyRecall}
                  onClick={() => void recall(control.queueTypeId)}
                  className="!bg-brand-navy/90 hover:!opacity-100 dark:!bg-white/15"
                >
                  {t('boardRecall')}
                </LoadingButton>
              </div>
            </li>
          )
        })}
      </ul>
      {controls.length === 0 ? (
        <p className="mt-2 text-sm text-brand-navy/65 dark:text-white/65">{t('boardNoQueueTypes')}</p>
      ) : null}
    </Card>
  )
}
