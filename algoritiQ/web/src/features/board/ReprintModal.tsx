/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useState } from 'react'
import { reprintToken } from '@/core/api/board'
import type { BoardTokenView } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useToast } from '@/core/toast/toastContext'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { Modal } from '@/core/ui/Modal'
import { TextField } from '@/core/ui/TextField'
import { readSession } from '@/features/auth/session'
import { boardErrorKey } from '@/features/board/boardErrors'
import { newBoardCommandId } from '@/features/board/boardFormat'
import { formatQueueSerial } from '@/features/queue/formatQueueSerial'

type ReprintModalProps = {
  token: BoardTokenView
  onClose: () => void
  onDone: () => void
}

/** Confirms reprint reason before sending a new print attempt. */
export function ReprintModal({ token, onClose, onDone }: ReprintModalProps) {
  const { t, locale } = useLocale()
  const toast = useToast()
  const [reason, setReason] = useState('')
  const [busy, setBusy] = useState(false)
  const serial = formatQueueSerial(token.serial, locale)

  async function confirm() {
    const sessionToken = readSession()
    if (!sessionToken || busy || !reason.trim()) return
    setBusy(true)
    try {
      await reprintToken(sessionToken, token.id, newBoardCommandId(), reason.trim())
      toast.success(t('boardReprintSent'))
      onDone()
    } catch (error) {
      toast.error(t(boardErrorKey(error)))
      setBusy(false)
    }
  }

  return (
    <Modal
      title={t('boardReprintTitle')}
      description={t('boardReprintIntro', { serial })}
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
            disabled={!reason.trim()}
            onClick={() => void confirm()}
            className="sm:w-auto sm:min-w-40"
          >
            {t('boardReprintConfirm')}
          </LoadingButton>
        </>
      }
    >
      <TextField
        id="reprint-reason"
        label={t('boardReprintReason')}
        value={reason}
        onChange={(event) => setReason(event.target.value)}
        autoComplete="off"
      />
    </Modal>
  )
}
