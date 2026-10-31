/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useState } from 'react'
import { uploadBackup } from '@/core/api/backup'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useToast } from '@/core/toast/toastContext'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { Modal } from '@/core/ui/Modal'
import { formatBackupSize } from '@/features/backup/formatBackupSize'
import { readSession } from '@/features/auth/session'

type UploadBackupModalProps = {
  file: File
  onClose: () => void
  onUploaded: () => void
}

export function UploadBackupModal({ file, onClose, onUploaded }: UploadBackupModalProps) {
  const { t } = useLocale()
  const toast = useToast()
  const [busy, setBusy] = useState(false)

  async function confirm() {
    const token = readSession()
    if (!token || busy) return
    setBusy(true)
    try {
      await uploadBackup(token, file)
      toast.success(t('backupUploaded'))
      onUploaded()
    } catch (err) {
      toast.error(err instanceof Error ? err.message : t('backupActionFailed'))
      setBusy(false)
    }
  }

  return (
    <Modal
      title={t('backupUploadConfirmTitle')}
      size="sm"
      busy={busy}
      onClose={onClose}
      footer={
        <>
          <button type="button" className={secondaryButton} disabled={busy} onClick={onClose}>
            {t('actionCancel')}
          </button>
          <LoadingButton
            isLoading={busy}
            loadingLabel={t('backupUploading')}
            onClick={() => void confirm()}
            className="sm:w-auto sm:min-w-40"
          >
            {t('backupUploadConfirmButton')}
          </LoadingButton>
        </>
      }
    >
      <p className="text-sm leading-relaxed">{t('backupUploadConfirmBody')}</p>
      <dl className="mt-4 space-y-2 rounded-xl border border-brand-navy/10 bg-brand-mist/50 px-3 py-3 text-sm dark:border-white/10 dark:bg-white/5">
        <div>
          <dt className="text-xs font-medium text-brand-navy/60 dark:text-white/60">{t('backupUploadFileName')}</dt>
          <dd className="mt-0.5 break-all font-medium text-brand-navy dark:text-white">{file.name}</dd>
        </div>
        <div>
          <dt className="text-xs font-medium text-brand-navy/60 dark:text-white/60">{t('backupUploadFileSize')}</dt>
          <dd className="mt-0.5 tabular-nums text-brand-navy dark:text-white">{formatBackupSize(file.size)}</dd>
        </div>
      </dl>
    </Modal>
  )
}
