/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useEffect, useState } from 'react'
import { restoreBackup, type BackupEntry } from '@/core/api/backup'
import { ApiError } from '@/core/api/client'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useToast } from '@/core/toast/toastContext'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { BrandLoader } from '@/core/ui/BrandLoader'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { Modal } from '@/core/ui/Modal'
import { useAuth } from '@/features/auth/authContext'
import { readSession } from '@/features/auth/session'

type Phase = 'confirm' | 'restoring' | 'signingOut'

type RestoreBackupModalProps = {
  entry: BackupEntry
  dateLabel: string
  onClose: () => void
  onBusyChange?: (busy: boolean) => void
}

/** Confirms restore, shows progress (non-dismissible), then signs out and opens login. */
export function RestoreBackupModal({
  entry,
  dateLabel,
  onClose,
  onBusyChange,
}: RestoreBackupModalProps) {
  const { t } = useLocale()
  const toast = useToast()
  const { signOut } = useAuth()
  const [phase, setPhase] = useState<Phase>('confirm')
  const busy = phase !== 'confirm'

  useEffect(() => {
    onBusyChange?.(busy)
  }, [busy, onBusyChange])

  async function confirm() {
    const token = readSession()
    if (!token || busy) return
    setPhase('restoring')
    try {
      await restoreBackup(token, entry.id)
      setPhase('signingOut')
      await signOut()
      window.location.assign('/login')
    } catch (err) {
      setPhase('confirm')
      toast.error(err instanceof ApiError ? err.message : t('backupActionFailed'))
    }
  }

  const title =
    phase === 'confirm'
      ? t('backupRestoreTitle')
      : phase === 'signingOut'
        ? t('backupRestoreSigningOutTitle')
        : t('backupRestoreProgressTitle')

  return (
    <Modal
      title={title}
      size="sm"
      busy={busy}
      onClose={onClose}
      footer={
        phase === 'confirm' ? (
          <>
            <button type="button" className={secondaryButton} onClick={onClose}>
              {t('actionCancel')}
            </button>
            <LoadingButton
              isLoading={false}
              onClick={() => void confirm()}
              className="sm:w-auto sm:min-w-40"
            >
              {t('backupRestoreConfirm')}
            </LoadingButton>
          </>
        ) : undefined
      }
    >
      {phase === 'confirm' ? (
        <>
          <p className="text-sm leading-relaxed">{t('backupRestoreBody')}</p>
          <dl className="mt-4 space-y-2 rounded-xl border border-brand-navy/10 bg-brand-mist/50 px-3 py-3 text-sm dark:border-white/10 dark:bg-white/5">
            <div>
              <dt className="text-xs font-medium text-brand-navy/60 dark:text-white/60">
                {t('backupRestoreWhen')}
              </dt>
              <dd className="mt-0.5 font-medium text-brand-navy dark:text-white">{dateLabel}</dd>
            </div>
            <div>
              <dt className="text-xs font-medium text-brand-navy/60 dark:text-white/60">
                {t('backupRestoreId')}
              </dt>
              <dd className="mt-0.5 font-mono text-xs tabular-nums break-all text-brand-navy/90 dark:text-white/90">
                {entry.id}
              </dd>
            </div>
          </dl>
        </>
      ) : (
        <div
          className="flex flex-col items-center gap-4 py-8 text-center"
          role="status"
          aria-live="polite"
          aria-busy="true"
        >
          <BrandLoader dotSize={10} semanticLabel={t('backupRestoring')} />
          <p className="max-w-xs text-sm leading-relaxed text-brand-navy/80 dark:text-white/80">
            {phase === 'signingOut' ? t('backupRestoreSigningOut') : t('backupRestoreProgress')}
          </p>
        </div>
      )}
    </Modal>
  )
}
