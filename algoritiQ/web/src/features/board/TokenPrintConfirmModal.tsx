/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useState } from 'react'
import { reprintToken } from '@/core/api/queueDesk'
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

type TokenPrintConfirmModalProps = {
  token: BoardTokenView
  onClose: () => void
  onRefresh: () => void | Promise<void>
  onDone: () => void
}

/** Confirm first print or reprint — matches tablet desk token actions. */
export function TokenPrintConfirmModal({
  token,
  onClose,
  onRefresh,
  onDone,
}: TokenPrintConfirmModalProps) {
  const { t, locale } = useLocale()
  const toast = useToast()
  const [busy, setBusy] = useState(false)
  const serial = formatQueueSerial(token.serial, locale)
  const isReprint = token.latestPrintStatus === 'SENT'

  async function confirm() {
    const sessionToken = readSession()
    if (!sessionToken || busy) return
    setBusy(true)
    try {
      await onRefresh()
      await reprintToken(sessionToken, token.id, newBoardCommandId(), '')
      toast.success(t('boardPrintSent'))
      await onRefresh()
      onDone()
    } catch (error) {
      toast.error(t(boardErrorKey(error)))
      setBusy(false)
    }
  }

  return (
    <Modal
      title={isReprint ? t('boardReprintTitle') : t('boardPrintConfirmTitle')}
      description={
        isReprint ? t('boardReprintIntro', { serial }) : t('boardPrintConfirmBody', { serial })
      }
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
            {t('boardReprintConfirm')}
          </LoadingButton>
        </>
      }
    >
      <span className="sr-only">{serial}</span>
    </Modal>
  )
}
