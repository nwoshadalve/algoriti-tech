/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { useState } from 'react'
import {
  createBackup,
  downloadBackup,
  getBackupSettings,
  listBackups,
  updateBackupSettings,
  type BackupEntry,
  type BackupSchedule,
  type BackupSettings,
} from '@/core/api/backup'
import { ApiError } from '@/core/api/client'
import { useLocale } from '@/core/i18n/LocaleProvider'
import type { MessageKey } from '@/core/i18n/messages/types'
import { useToast } from '@/core/toast/toastContext'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { Card } from '@/core/ui/Card'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { PageHeader } from '@/core/ui/PageHeader'
import { PagePreloader } from '@/core/ui/PagePreloader'
import { SelectField } from '@/core/ui/SelectField'
import { BACKUP_RETENTION_LIMIT } from '@/features/backup/backupPolicy'
import { backupQueryKeys } from '@/features/backup/backupQueryKeys'
import { BackupListRow } from '@/features/backup/BackupListRow'
import { BackupUploadZone } from '@/features/backup/BackupUploadZone'
import { DeleteBackupModal } from '@/features/backup/DeleteBackupModal'
import { RestoreBackupModal } from '@/features/backup/RestoreBackupModal'
import { UploadBackupModal } from '@/features/backup/UploadBackupModal'
import { readSession } from '@/features/auth/session'

const compactCard = 'p-4 shadow-none sm:p-4'
const sectionTitle = 'text-sm font-semibold text-brand-navy dark:text-white'
const sectionHelp = 'mt-0.5 text-xs leading-relaxed text-brand-navy/70 sm:text-sm dark:text-white/70'

const scheduleOptions: { value: BackupSchedule; labelKey: MessageKey }[] = [
  { value: 'off', labelKey: 'backupScheduleOff' },
  { value: 'daily', labelKey: 'backupScheduleDaily' },
  { value: 'weekly', labelKey: 'backupScheduleWeekly' },
]

type BackupTarget = { entry: BackupEntry; dateLabel: string }

type BackupDashboard = {
  settings: BackupSettings
  backups: BackupEntry[]
}

function requireSessionToken(): string {
  const token = readSession()
  if (!token) throw new Error('signed_out')
  return token
}

async function loadBackupDashboard(): Promise<BackupDashboard> {
  const token = requireSessionToken()
  const [nextSettings, list] = await Promise.all([
    getBackupSettings(token),
    listBackups(token),
  ])
  return {
    settings: {
      ...nextSettings,
      retentionLimit: nextSettings.retentionLimit ?? BACKUP_RETENTION_LIMIT,
    },
    backups: list.backups,
  }
}

/** Admin backup: schedule, manual copies, list, download and restore. */
export function BackupPage() {
  const { t, locale } = useLocale()
  const toast = useToast()
  const queryClient = useQueryClient()
  const dashboardQuery = useQuery({
    queryKey: backupQueryKeys.dashboard(),
    queryFn: loadBackupDashboard,
    retry: false,
  })

  const [savingSchedule, setSavingSchedule] = useState(false)
  const [creating, setCreating] = useState(false)
  const [busyId, setBusyId] = useState<string | null>(null)
  const [restoreTarget, setRestoreTarget] = useState<BackupTarget | null>(null)
  const [deleteTarget, setDeleteTarget] = useState<BackupTarget | null>(null)
  const [uploadFile, setUploadFile] = useState<File | null>(null)
  const [restoreBusyId, setRestoreBusyId] = useState<string | null>(null)

  function refreshDashboard() {
    void queryClient.invalidateQueries({ queryKey: backupQueryKeys.dashboard() })
  }

  const settings = dashboardQuery.data?.settings
  const backups = dashboardQuery.data?.backups
  const loading = dashboardQuery.isPending && dashboardQuery.data === undefined
  const failed = dashboardQuery.isError && dashboardQuery.data === undefined

  async function onSaveSchedule(schedule: BackupSchedule) {
    const token = readSession()
    if (!token || !settings) return
    setSavingSchedule(true)
    try {
      const updated = await updateBackupSettings(token, schedule)
      queryClient.setQueryData<BackupDashboard>(backupQueryKeys.dashboard(), (current) => {
        if (!current) return current
        return {
          ...current,
          settings: {
            ...updated,
            retentionLimit: updated.retentionLimit ?? current.settings.retentionLimit,
          },
        }
      })
      toast.success(t('backupSettingsSaved'))
      refreshDashboard()
    } catch (err) {
      toast.error(err instanceof ApiError ? err.message : t('backupActionFailed'))
    } finally {
      setSavingSchedule(false)
    }
  }

  async function onCreate() {
    const token = readSession()
    if (!token) return
    setCreating(true)
    try {
      await createBackup(token)
      toast.success(t('backupCreated'))
      refreshDashboard()
    } catch (err) {
      toast.error(err instanceof ApiError ? err.message : t('backupActionFailed'))
    } finally {
      setCreating(false)
    }
  }

  async function onDownload(id: string) {
    const token = readSession()
    if (!token) return
    setBusyId(id)
    try {
      await downloadBackup(token, id)
      toast.success(t('backupDownloadStarted'))
    } catch {
      toast.error(t('backupActionFailed'))
    } finally {
      setBusyId(null)
    }
  }

  function onRestoreClick(entry: BackupEntry, dateLabel: string) {
    setRestoreTarget({ entry, dateLabel })
  }

  if (loading || !settings || !backups) {
    return (
      <div className="mx-auto w-full min-w-0 max-w-5xl">
        {failed ? (
          <>
            <PageHeader title={t('navBackup')} description={t('backupIntro')} />
            <div
              role="alert"
              className="flex flex-col gap-3 rounded-xl border border-amber-300/80 bg-amber-50 px-4 py-3 text-sm text-amber-950 dark:border-amber-500/40 dark:bg-amber-950/40 dark:text-amber-100 sm:flex-row sm:items-center sm:justify-between"
            >
              <span>{t('backupLoadFailed')}</span>
              <button type="button" className={secondaryButton} onClick={() => refreshDashboard()}>
                {t('monitorRetry')}
              </button>
            </div>
          </>
        ) : (
          <PagePreloader className="py-12" />
        )}
      </div>
    )
  }

  const dateFmt = new Intl.DateTimeFormat(locale, { dateStyle: 'medium', timeStyle: 'short' })
  const scheduleSelectOptions = scheduleOptions.map((opt) => ({
    value: opt.value,
    label: t(opt.labelKey),
  }))
  const retentionLimit = settings.retentionLimit

  return (
    <div className="mx-auto w-full min-w-0 max-w-5xl space-y-4 sm:space-y-6">
      <PageHeader title={t('navBackup')} description={t('backupIntro')} />

      <div className="grid gap-4 lg:grid-cols-2 lg:gap-5">
        <Card as="section" labelledBy="backup-schedule-heading" className={compactCard}>
          <h2 id="backup-schedule-heading" className={sectionTitle}>
            {t('backupAutomaticTitle')}
          </h2>
          <p className={sectionHelp}>{t('backupAutomaticHelp')}</p>
          <div className="mt-3 space-y-3">
            <SelectField
              id="backup-schedule"
              label={t('backupScheduleLabel')}
              value={settings.schedule}
              disabled={savingSchedule}
              options={scheduleSelectOptions}
              onChange={(event) => void onSaveSchedule(event.target.value as BackupSchedule)}
            />
            <LoadingButton
              type="button"
              isLoading={creating}
              loadingLabel={t('loadingLabel')}
              onClick={() => void onCreate()}
              className="w-full sm:w-auto sm:min-w-[10rem]"
            >
              {t('backupCreateNow')}
            </LoadingButton>
          </div>
        </Card>

        <Card as="section" labelledBy="backup-upload-heading" className={compactCard}>
          <h2 id="backup-upload-heading" className={sectionTitle}>
            {t('backupUploadTitle')}
          </h2>
          <p className={sectionHelp}>{t('backupUploadHelp')}</p>
          <BackupUploadZone disabled={Boolean(uploadFile)} onPick={setUploadFile} />
        </Card>
      </div>

      <Card as="section" labelledBy="backup-list-heading" className={compactCard}>
        <div className="flex flex-col gap-1 sm:flex-row sm:items-baseline sm:justify-between">
          <h2 id="backup-list-heading" className={sectionTitle}>
            {t('backupListTitle')}
          </h2>
          <p className="text-xs tabular-nums text-brand-navy/60 dark:text-white/60" role="status">
            {t('backupRetentionStatus', { stored: backups.length, limit: retentionLimit })}
          </p>
        </div>
        <p className={sectionHelp}>{t('backupListHelp')}</p>
        <div className="mt-3">
          {backups.length === 0 ? (
            <p className="rounded-lg border border-dashed border-brand-navy/15 px-3 py-6 text-center text-sm text-brand-navy/70 dark:border-white/15 dark:text-white/70">
              {t('backupListEmpty')}
            </p>
          ) : (
            <ul className="divide-y divide-brand-navy/10 overflow-hidden rounded-lg border border-brand-navy/10 bg-brand-mist/30 dark:divide-white/10 dark:border-brand-navy-line dark:bg-brand-navy/40">
              {backups.map((entry) => {
                const dateLabel = dateFmt.format(new Date(entry.createdAt))
                const restoring = restoreBusyId === entry.id
                const modalLocked =
                  restoreTarget?.entry.id === entry.id || deleteTarget?.entry.id === entry.id
                return (
                  <BackupListRow
                    key={entry.id}
                    entry={entry}
                    dateLabel={dateLabel}
                    busy={busyId === entry.id || modalLocked}
                    restoring={restoring}
                    onDownload={() => void onDownload(entry.id)}
                    onRestore={() => onRestoreClick(entry, dateLabel)}
                    onDelete={() => setDeleteTarget({ entry, dateLabel })}
                  />
                )
              })}
            </ul>
          )}
        </div>
      </Card>

      <p className="rounded-xl border border-brand-navy/10 bg-brand-mist/50 px-3 py-2.5 text-xs leading-relaxed text-brand-navy/80 dark:border-white/10 dark:bg-white/5 dark:text-white/75">
        {t('backupOffTabletNote')}
      </p>

      {restoreTarget ? (
        <RestoreBackupModal
          entry={restoreTarget.entry}
          dateLabel={restoreTarget.dateLabel}
          onClose={() => {
            setRestoreTarget(null)
            setRestoreBusyId(null)
          }}
          onBusyChange={(busy) => setRestoreBusyId(busy ? restoreTarget.entry.id : null)}
        />
      ) : null}

      {deleteTarget ? (
        <DeleteBackupModal
          entry={deleteTarget.entry}
          dateLabel={deleteTarget.dateLabel}
          onClose={() => setDeleteTarget(null)}
          onDeleted={() => {
            setDeleteTarget(null)
            refreshDashboard()
          }}
        />
      ) : null}

      {uploadFile ? (
        <UploadBackupModal
          file={uploadFile}
          onClose={() => setUploadFile(null)}
          onUploaded={() => {
            setUploadFile(null)
            refreshDashboard()
          }}
        />
      ) : null}
    </div>
  )
}
