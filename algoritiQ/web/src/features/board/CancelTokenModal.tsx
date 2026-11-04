/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useState } from 'react'
import { cancelToken } from '@/core/api/queueDesk'
import type { BoardTokenView } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useToast } from '@/core/toast/toastContext'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { Modal } from '@/core/ui/Modal'
import { readSession } from '@/features/auth/session'
import { boardErrorKey } from '@/features/board/boardErrors'
import { newBoardCommandId } from '@/features/board/boardFormat'
import { formatQueueSerial } from '@/features/queue/formatQueueSerial'

type CancelTokenModalProps = {
  token: BoardTokenView
  onClose: () => void
  onDone: () => void
}

/** Confirms cancel — no reason required (tablet desk). */
export function CancelTokenModal({ token, onClose, onDone }: CancelTokenModalProps) {
  const { t, locale } = useLocale()
  const toast = useToast()
  const [busy, setBusy] = useState(false)
  const serial = formatQueueSerial(token.serial, locale)

  async function confirm() {
    const sessionToken = readSession()
    if (!sessionToken || busy) return
    setBusy(true)
    try {
      await cancelToken(sessionToken, token.id, newBoardCommandId(), '')
      toast.success(t('boardTokenCancelledToast'))
      onDone()
    } catch (error) {
      toast.error(t(boardErrorKey(error)))
      setBusy(false)
    }
  }

  return (
    <Modal
      title={t('boardCancelTitle')}
      description={t('boardCancelIntro', { serial, name: token.patientBengaliName })}
      busy={busy}
      onClose={onClose}
      footer={
        <>
          <button type="button" className={secondaryButton} disabled={busy} onClick={onClose}>
            {t('actionCancel')}
          </button>
          <LoadingButton
            isLoading={busy}
            loadingLabel={t('boardWorking')}
            onClick={() => void confirm()}
            className="sm:w-auto sm:min-w-40"
          >
            {t('boardCancelConfirm')}
          </LoadingButton>
        </>
      }
    >
      <span className="sr-only">{serial}</span>
    </Modal>
  )
}
