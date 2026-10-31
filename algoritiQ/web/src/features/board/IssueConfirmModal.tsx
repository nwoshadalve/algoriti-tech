/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useState } from 'react'
import { issueToken } from '@/core/api/board'
import type { IssuePreview } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useToast } from '@/core/toast/toastContext'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { Modal } from '@/core/ui/Modal'
import { readSession } from '@/features/auth/session'
import { boardErrorKey } from '@/features/board/boardErrors'
import { newBoardCommandId, queueDisplayName } from '@/features/board/boardFormat'
import { formatQueueSerial } from '@/features/queue/formatQueueSerial'

type IssueConfirmModalProps = {
  chamberId: string
  preview: IssuePreview
  onClose: () => void
  onIssued: () => void
}

/** Token issue confirmation with preview serial before print. */
export function IssueConfirmModal({ chamberId, preview, onClose, onIssued }: IssueConfirmModalProps) {
  const { t, locale } = useLocale()
  const toast = useToast()
  const [busy, setBusy] = useState(false)
  const queueName = queueDisplayName(locale, preview.queueEnglishName, preview.queueBengaliName)
  const serial = formatQueueSerial(preview.previewSerial, locale)

  async function confirm() {
    const token = readSession()
    if (!token || busy) return
    setBusy(true)
    try {
      await issueToken(token, chamberId, {
        commandId: newBoardCommandId(),
        patientId: preview.patient.id,
        queueTypeId: preview.queueTypeId,
        feeBdt: preview.feeBdt ?? undefined,
      })
      toast.success(t('boardIssueSuccess'))
      onIssued()
    } catch (error) {
      toast.error(t(boardErrorKey(error)))
      setBusy(false)
    }
  }

  return (
    <Modal
      title={t('boardIssueConfirmTitle')}
      description={t('boardIssueConfirmIntro')}
      busy={busy}
      onClose={onClose}
      size="lg"
      footer={
        <>
          <button type="button" className={secondaryButton} disabled={busy} onClick={onClose}>
            {t('boardIssueBack')}
          </button>
          <LoadingButton
            isLoading={busy}
            loadingLabel={t('boardWorking')}
            onClick={() => void confirm()}
            className="sm:w-auto sm:min-w-44"
          >
            {t('boardIssueConfirmPrint')}
          </LoadingButton>
        </>
      }
    >
      <dl className="grid gap-3 text-sm sm:grid-cols-2">
        <div>
          <dt className="text-brand-navy/60 dark:text-white/60">{t('boardFieldPatient')}</dt>
          <dd className="font-medium">{preview.patient.bengaliName}</dd>
          <dd className="text-brand-navy/70 dark:text-white/70">{preview.patient.clinicPatientId}</dd>
        </div>
        <div>
          <dt className="text-brand-navy/60 dark:text-white/60">{t('boardFieldChamber')}</dt>
          <dd className="font-medium">{preview.chamberName}</dd>
        </div>
        <div>
          <dt className="text-brand-navy/60 dark:text-white/60">{t('boardFieldQueue')}</dt>
          <dd className="font-medium">{queueName}</dd>
        </div>
        <div>
          <dt className="text-brand-navy/60 dark:text-white/60">{t('boardFieldPreviewSerial')}</dt>
          <dd className="text-2xl font-bold tabular-nums">{serial}</dd>
          <dd className="text-xs text-brand-navy/60 dark:text-white/60">{t('boardPreviewHint')}</dd>
        </div>
        {preview.feeBdt != null ? (
          <div>
            <dt className="text-brand-navy/60 dark:text-white/60">{t('boardFieldFee')}</dt>
            <dd className="font-medium">{preview.feeBdt}</dd>
          </div>
        ) : null}
      </dl>
    </Modal>
  )
}
