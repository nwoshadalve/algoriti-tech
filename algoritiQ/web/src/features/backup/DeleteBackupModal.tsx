/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useState } from 'react'
import { deleteBackup, type BackupEntry } from '@/core/api/backup'
import { ApiError } from '@/core/api/client'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useToast } from '@/core/toast/toastContext'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { Modal } from '@/core/ui/Modal'
import { readSession } from '@/features/auth/session'

type DeleteBackupModalProps = {
  entry: BackupEntry
  dateLabel: string
  onClose: () => void
  onDeleted: () => void
}

export function DeleteBackupModal({ entry, dateLabel, onClose, onDeleted }: DeleteBackupModalProps) {
  const { t } = useLocale()
  const toast = useToast()
  const [busy, setBusy] = useState(false)

  async function confirm() {
    const token = readSession()
    if (!token || busy) return
    setBusy(true)
    try {
      await deleteBackup(token, entry.id)
      toast.success(t('backupDeleted'))
      onDeleted()
    } catch (err) {
      toast.error(err instanceof ApiError ? err.message : t('backupActionFailed'))
      setBusy(false)
    }
  }

  return (
    <Modal
      title={t('backupDeleteTitle')}
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
            loadingLabel={t('loadingLabel')}
            onClick={() => void confirm()}
            className="sm:w-auto sm:min-w-40"
          >
            {t('backupDeleteConfirm')}
          </LoadingButton>
        </>
      }
    >
      <p className="text-sm leading-relaxed">{t('backupDeleteBody')}</p>
      <dl className="mt-4 space-y-2 rounded-xl border border-brand-navy/10 bg-brand-mist/50 px-3 py-3 text-sm dark:border-white/10 dark:bg-white/5">
        <div>
          <dt className="text-xs font-medium text-brand-navy/60 dark:text-white/60">{t('backupRestoreWhen')}</dt>
          <dd className="mt-0.5 font-medium text-brand-navy dark:text-white">{dateLabel}</dd>
        </div>
        <div>
          <dt className="text-xs font-medium text-brand-navy/60 dark:text-white/60">{t('backupRestoreId')}</dt>
          <dd className="mt-0.5 font-mono text-xs tabular-nums break-all text-brand-navy/90 dark:text-white/90">
            {entry.id}
          </dd>
        </div>
      </dl>
    </Modal>
  )
}
