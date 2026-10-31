/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { BackupEntry } from '@/core/api/backup'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { formatBackupSize } from '@/features/backup/formatBackupSize'

const actionButton = `${secondaryButton} w-full min-w-0 sm:w-auto`

type BackupListRowProps = {
  entry: BackupEntry
  dateLabel: string
  busy: boolean
  restoring: boolean
  onDownload: () => void
  onRestore: () => void
  onDelete: () => void
}

export function BackupListRow({
  entry,
  dateLabel,
  busy,
  restoring,
  onDownload,
  onRestore,
  onDelete,
}: BackupListRowProps) {
  const { t } = useLocale()
  const kindLabel = entry.kind === 'automatic' ? t('backupKindAutomatic') : t('backupKindManual')

  return (
    <li className="flex flex-col gap-3 px-3 py-3 sm:px-4 lg:flex-row lg:items-center lg:justify-between lg:gap-4">
      <div className="min-w-0 flex-1">
        <p className="text-sm font-semibold text-brand-navy dark:text-white">{dateLabel}</p>
        <div className="mt-1.5 flex flex-wrap items-center gap-2 text-xs text-brand-navy/70 dark:text-white/70">
          <span className="font-mono tabular-nums break-all">{entry.id}</span>
          <span className="hidden sm:inline" aria-hidden>
            ·
          </span>
          <span className="tabular-nums">{formatBackupSize(entry.sizeBytes)}</span>
          <span
            className="rounded-full border border-brand-navy/15 bg-brand-mist/80 px-2 py-0.5 text-[0.6875rem] font-medium text-brand-navy dark:border-white/15 dark:bg-white/10 dark:text-white/90"
          >
            {kindLabel}
          </span>
        </div>
      </div>
      <div className="grid w-full grid-cols-1 gap-2 min-[400px]:grid-cols-3 lg:w-auto lg:max-w-none lg:flex lg:flex-row lg:flex-wrap">
        <button type="button" disabled={busy} className={actionButton} onClick={onDownload}>
          {t('backupDownload')}
        </button>
        <button type="button" disabled={busy} className={actionButton} onClick={onRestore}>
          {restoring ? t('backupRestoring') : t('backupRestore')}
        </button>
        <button
          type="button"
          disabled={busy}
          className={`${actionButton} border-brand-coral/35 text-brand-coral hover:bg-brand-coral/10 dark:border-brand-coral/40 dark:text-brand-coral dark:hover:bg-brand-coral/15`}
          onClick={onDelete}
        >
          {t('backupDelete')}
        </button>
      </div>
    </li>
  )
}
