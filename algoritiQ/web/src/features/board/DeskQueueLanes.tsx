/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useState } from 'react'
import {
  callNextToken,
  markTokenEntered,
  markTokenSkipped,
  recallCalledToken,
} from '@/core/api/queueDesk'
import type { BoardTokenView, QueueTypeBoardControl } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useToast } from '@/core/toast/toastContext'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { readSession } from '@/features/auth/session'
import { boardErrorKey } from '@/features/board/boardErrors'
import { newBoardCommandId, queueDisplayName } from '@/features/board/boardFormat'
import { formatDigits, formatQueueSerial } from '@/features/queue/formatQueueSerial'

type DeskQueueLanesProps = {
  chamberId: string
  controls: QueueTypeBoardControl[]
  /** The patients being called now, one per queue at most. */
  called: BoardTokenView[]
  onRefresh: () => void
  onCancel: (token: BoardTokenView) => void
}

const laneButton = '!min-h-10 !w-full !px-3 !py-2 !text-sm xl:!w-auto xl:!px-4'
const laneSecondary = `${secondaryButton} !min-h-10 w-full xl:w-auto`

/**
 * One card per queue, as on the tablet: its name and waiting count, **Call**,
 * and, while it is calling, the patient with Recall, Entered, Missed and Cancel.
 */
export function DeskQueueLanes({ chamberId, controls, called, onRefresh, onCancel }: DeskQueueLanesProps) {
  const { t, locale } = useLocale()
  const toast = useToast()
  // What is running, as `<queue type id or token id>:<action>`; one thing at a time.
  const [busy, setBusy] = useState('')

  async function run(key: string, action: (token: string) => Promise<unknown>, success: string) {
    const token = readSession()
    if (!token || busy) return
    setBusy(key)
    try {
      await action(token)
      toast.success(success)
      onRefresh()
    } catch (error) {
      toast.error(t(boardErrorKey(error)))
    } finally {
      setBusy('')
    }
  }

  if (controls.length === 0) {
    return <p className="text-sm text-brand-navy/65 dark:text-white/65">{t('boardNoQueueTypes')}</p>
  }

  return (
    <ul className="flex flex-col gap-3" aria-label={t('boardQueueControlsTitle')}>
      {controls.map((control) => {
        const name = queueDisplayName(locale, control.englishName, control.bengaliName)
        const token = called.find((row) => row.queueTypeId === control.queueTypeId)
        const loading = (action: string) => busy === `${token?.id ?? control.queueTypeId}:${action}`
        // A token that came up on the board by itself is not announced yet: Call announces it.
        const announced = token?.announced !== false
        return (
          <li
            key={control.queueTypeId}
            className={`flex flex-col gap-3 rounded-xl border px-4 py-3 xl:flex-row xl:items-center ${
              token
                ? 'border-brand-coral/60 bg-brand-coral/10 dark:bg-brand-coral/15'
                : 'border-brand-navy/10 bg-white dark:border-white/10 dark:bg-brand-navy-raised'
            }`}
          >
            <div className="min-w-0 xl:w-40 xl:shrink-0">
              <p className="truncate text-sm font-bold">{name}</p>
              <p className="truncate text-xs text-brand-navy/65 dark:text-white/65">
                {t('boardWaitingCount', { count: control.waitingCount })}
              </p>
            </div>

            <div className="min-w-0 xl:flex-[2]">
              {token ? (
                <div className="flex items-center gap-3">
                  <p className="text-2xl font-extrabold tabular-nums text-brand-coral-action">
                    {formatQueueSerial(token.serial, locale)}
                  </p>
                  <div className="min-w-0">
                    <p className="line-clamp-2 text-sm font-bold">{token.patientName}</p>
                    <p className="text-xs tabular-nums text-brand-navy/65 dark:text-white/65">
                      {formatDigits(token.clinicPatientId, locale)}
                    </p>
                  </div>
                </div>
              ) : (
                <p className="text-sm text-brand-navy/65 dark:text-white/65">{t('boardCurrentCallEmpty')}</p>
              )}
            </div>

            {token ? (
              <div className="grid grid-cols-2 gap-2 md:grid-cols-4 xl:flex xl:flex-[3] xl:flex-wrap xl:justify-end">
                <LoadingButton
                  isLoading={loading('recall')}
                  loadingLabel={t('boardWorking')}
                  disabled={!!busy}
                  className={laneButton}
                  onClick={() =>
                    void run(
                      `${token.id}:recall`,
                      (auth) =>
                        recallCalledToken(auth, chamberId, newBoardCommandId(), token.queueTypeId),
                      announced ? t('boardRecallSent') : t('boardCallNextSuccess'),
                    )
                  }
                >
                  {announced ? t('boardRecall') : t('boardCall')}
                </LoadingButton>
                <LoadingButton
                  isLoading={loading('entered')}
                  loadingLabel={t('boardWorking')}
                  disabled={!!busy}
                  className={laneButton}
                  onClick={() =>
                    void run(
                      `${token.id}:entered`,
                      (auth) => markTokenEntered(auth, token.id, newBoardCommandId()),
                      t('boardEnteredToast'),
                    )
                  }
                >
                  {t('boardPatientEntered')}
                </LoadingButton>
                <LoadingButton
                  isLoading={loading('skipped')}
                  loadingLabel={t('boardWorking')}
                  disabled={!!busy}
                  className={laneButton}
                  onClick={() =>
                    void run(
                      `${token.id}:skipped`,
                      (auth) => markTokenSkipped(auth, token.id, newBoardCommandId()),
                      t('boardSkippedToast'),
                    )
                  }
                >
                  {t('boardPatientMissed')}
                </LoadingButton>
                <button
                  type="button"
                  className={laneSecondary}
                  disabled={!!busy}
                  onClick={() => onCancel(token)}
                >
                  {t('boardCancelToken')}
                </button>
              </div>
            ) : (
              <div className="xl:flex xl:flex-[3] xl:justify-end">
                <LoadingButton
                  isLoading={loading('call')}
                  loadingLabel={t('boardWorking')}
                  disabled={!control.canCallNext || !!busy}
                  className="!min-h-11 !w-full xl:!w-auto xl:!min-w-28"
                  onClick={() =>
                    void run(
                      `${control.queueTypeId}:call`,
                      (auth) => callNextToken(auth, chamberId, newBoardCommandId(), control.queueTypeId),
                      t('boardCallNextSuccess'),
                    )
                  }
                >
                  {t('boardCall')}
                </LoadingButton>
              </div>
            )}
          </li>
        )
      })}
    </ul>
  )
}
