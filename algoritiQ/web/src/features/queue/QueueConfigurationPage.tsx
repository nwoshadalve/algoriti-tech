/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useEffect, useMemo, useState } from 'react'
import { listChambers } from '@/core/api/chambers'
import {
  getChamberQueueConfig,
  getQueueDefaults,
  saveChamberQueueTypes,
} from '@/core/api/queue'
import type { QueueTypeConfig } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useToast } from '@/core/toast/toastContext'
import { Card } from '@/core/ui/Card'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { NoticeBanner } from '@/core/ui/NoticeBanner'
import { PageHeader } from '@/core/ui/PageHeader'
import { PagePreloader } from '@/core/ui/PagePreloader'
import { PencilIcon, PlusIcon } from '@/core/ui/icons'
import { IconButton } from '@/core/ui/IconButton'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { SelectField } from '@/core/ui/SelectField'
import { useAuth } from '@/features/auth/authContext'
import { readSession } from '@/features/auth/session'
import { queueErrorKey } from '@/features/queue/queueErrors'
import { queueQueryKeys } from '@/features/queue/queueQueryKeys'
import { markQueueConfigurationSavedLocally } from '@/features/queue/queueLocalChange'
import { QueuePolicyModal } from '@/features/queue/QueuePolicyModal'
import { QueueTypeFormModal } from '@/features/queue/QueueTypeFormModal'
import { QueueTypesTable } from '@/features/queue/QueueTypesTable'
import { formatDayBoundaryForDisplay } from '@/features/queue/queueStopTime'

type Dialog =
  | { kind: 'policy' }
  | { kind: 'addType' }
  | { kind: 'editType'; type: QueueTypeConfig }
  | null

function requireSessionToken(): string {
  const token = readSession()
  if (!token) throw new Error('missing_session')
  return token
}

/** Admin queue configuration per chamber ([queue-configuration.md] §4, §8). */
export function QueueConfigurationPage() {
  const { t, locale } = useLocale()
  const toast = useToast()
  const queryClient = useQueryClient()
  const { state } = useAuth()
  const account = state.status === 'signedIn' ? state.account : null
  const isAdmin = account?.role === 'admin'
  const queriesEnabled = isAdmin && state.status === 'signedIn'

  const [chamberId, setChamberId] = useState('')
  const [dialog, setDialog] = useState<Dialog>(null)
  const [togglingId, setTogglingId] = useState('')

  const defaultsQuery = useQuery({
    queryKey: queueQueryKeys.defaults(),
    queryFn: async () => {
      const token = requireSessionToken()
      return getQueueDefaults(token)
    },
    enabled: queriesEnabled,
  })

  const chambersQuery = useQuery({
    queryKey: queueQueryKeys.chambers(),
    queryFn: async () => {
      const token = requireSessionToken()
      try {
        return await listChambers(token)
      } catch {
        return []
      }
    },
    enabled: queriesEnabled,
  })

  const chamberQuery = useQuery({
    queryKey: queueQueryKeys.chamber(chamberId),
    queryFn: async () => {
      const token = requireSessionToken()
      return getChamberQueueConfig(token, chamberId)
    },
    enabled: queriesEnabled && chamberId.length > 0,
  })

  useEffect(() => {
    const list = chambersQuery.data
    if (!list?.length || chamberId) return
    setChamberId(list[0]!.id)
  }, [chambersQuery.data, chamberId])

  const saveTypesMutation = useMutation({
    mutationFn: async (types: QueueTypeConfig[]) => {
      markQueueConfigurationSavedLocally()
      const token = requireSessionToken()
      if (!chamberId) throw new Error('queue_save_unavailable')
      return saveChamberQueueTypes(token, chamberId, types)
    },
    onSuccess: (saved) => {
      markQueueConfigurationSavedLocally()
      queryClient.setQueryData(
        queueQueryKeys.chamber(chamberId),
        (current: Awaited<ReturnType<typeof getChamberQueueConfig>> | undefined) => {
          if (!current) return current
          return {
            ...current,
            settings: saved.settings,
            types: saved.types,
          }
        },
      )
      toast.success(t('queueTypeSaved'))
    },
    onError: (error) => {
      toast.error(t(queueErrorKey(error)))
    },
  })

  const policy = defaultsQuery.data?.policy ?? null
  const chambers = chambersQuery.data ?? []
  const types = chamberQuery.data?.types ?? []
  const usesClinicDefaults = chamberQuery.data?.settings.useClinicDefaults ?? true
  const chamberTypesHint = usesClinicDefaults
    ? t('queueChamberInherit')
    : t('queueChamberCustom')

  const pagePending =
    queriesEnabled &&
    ((defaultsQuery.isPending && !defaultsQuery.data) ||
      (chambersQuery.isPending && !chambersQuery.data))
  const pageFailed = defaultsQuery.isError || chambersQuery.isError
  const chamberFetching = chamberQuery.isFetching

  async function persistTypes(next: QueueTypeConfig[], closeDialog = false) {
    try {
      await saveTypesMutation.mutateAsync(next)
      if (closeDialog) setDialog(null)
    } catch {
      throw new Error('queue_save_failed')
    }
  }

  async function toggleEnabled(type: QueueTypeConfig) {
    if (togglingId || saveTypesMutation.isPending) return
    setTogglingId(type.id)
    try {
      const next = types.map((row) => (row.id === type.id ? { ...row, enabled: !row.enabled } : row))
      await persistTypes(next)
    } catch {
      // Toast already shown.
    } finally {
      setTogglingId('')
    }
  }

  const timeZoneLabel = useMemo(() => {
    if (!policy) return ''
    try {
      const parts = new Intl.DateTimeFormat(locale === 'bn' ? 'bn-BD' : 'en-GB', {
        timeZone: policy.timeZone,
        timeZoneName: 'long',
      }).formatToParts(new Date())
      return parts.find((p) => p.type === 'timeZoneName')?.value ?? policy.timeZone
    } catch {
      return policy.timeZone
    }
  }, [locale, policy])

  const stopTimeDisplay = useMemo(() => {
    if (!policy) return ''
    if (chamberId && chamberQuery.isPending && !chamberQuery.data) return '…'
    const boundary =
      chamberQuery.data?.effectivePolicy.dayBoundary ?? policy.dayBoundary
    return formatDayBoundaryForDisplay(boundary)
  }, [chamberId, chamberQuery.data, chamberQuery.isPending, policy])

  const policyModalBoundary =
    chamberQuery.data?.effectivePolicy.dayBoundary ?? policy?.dayBoundary ?? '03:00'

  function applySavedStopTimes(saved: {
    dayBoundary: string
    chamberIds: string[]
    effectiveByChamberId: Record<string, string>
  }) {
    for (const id of saved.chamberIds) {
      const boundary = saved.effectiveByChamberId[id] ?? saved.dayBoundary
      queryClient.setQueryData(
        queueQueryKeys.chamber(id),
        (current: Awaited<ReturnType<typeof getChamberQueueConfig>> | undefined) => {
          if (!current) return current
          return {
            ...current,
            settings: {
              ...current.settings,
              dayBoundaryOverride: boundary,
            },
            effectivePolicy: {
              ...current.effectivePolicy,
              dayBoundary: boundary,
            },
          }
        },
      )
      if (!queryClient.getQueryData(queueQueryKeys.chamber(id))) {
        void queryClient.invalidateQueries({ queryKey: queueQueryKeys.chamber(id) })
      }
    }
  }

  if (!account) return null

  if (!isAdmin) {
    return (
      <div>
        <PageHeader title={t('navQueue')} description={t('queueChamberHelp')} />
        <NoticeBanner tone="error">{t('queueErrorForbidden')}</NoticeBanner>
      </div>
    )
  }

  if (pagePending || !policy) {
    return (
      <div>
        <PageHeader title={t('navQueue')} description={t('queueChamberHelp')} />
        {pageFailed ? (
          <NoticeBanner tone="error">
            <button
              type="button"
              className={secondaryButton}
              onClick={() => {
                void defaultsQuery.refetch()
                void chambersQuery.refetch()
              }}
            >
              {t('usersRetry')}
            </button>
          </NoticeBanner>
        ) : (
          <PagePreloader />
        )}
      </div>
    )
  }

  return (
    <div className="pb-10">
      <PageHeader
        title={t('navQueue')}
        description={t('queueChamberHelp')}
        actions={
          <div className="flex w-full min-w-0 flex-wrap items-center gap-3 sm:justify-end">
            <p className="min-w-0 flex-1 text-sm text-brand-navy/80 dark:text-white/80 sm:flex-none">
              {t('queueAutoStopSummary', { time: stopTimeDisplay })}
            </p>
            <IconButton
              label={t('queueAutoStopEdit')}
              ariaLabel={t('queueAutoStopEdit')}
              icon={PencilIcon}
              labelOnSmall
              onClick={() => setDialog({ kind: 'policy' })}
            />
          </div>
        }
      />

      <Card as="section" labelledBy="queue-types" className="p-0 sm:p-0">
        <div className="flex flex-wrap items-center justify-between gap-3 px-4 py-4">
          <div className="min-w-0">
            <h2 id="queue-types" className="text-lg font-semibold">
              {t('queueTypesTitle')}
            </h2>
            <p className="mt-1 text-sm text-brand-navy/70 dark:text-white/70">
              {chamberTypesHint}
            </p>
          </div>
          <div className="flex w-full flex-wrap items-end gap-3 sm:w-auto sm:flex-nowrap">
            {chambers.length > 0 ? (
              <div className="min-w-[12rem] flex-1 sm:flex-none">
                <SelectField
                  id="queue-chamber-select"
                  label={t('queueChamberSelect')}
                  value={chamberId}
                  onChange={(e) => setChamberId(e.target.value)}
                  options={chambers.map((c) => ({ value: c.id, label: c.name }))}
                />
              </div>
            ) : null}
            <LoadingButton
              disabled={!chamberId || saveTypesMutation.isPending || chamberFetching}
              onClick={() => setDialog({ kind: 'addType' })}
              className="inline-flex w-auto items-center justify-center gap-2 !min-h-11 !py-2"
            >
              <span className="inline-flex items-center gap-2">
                <PlusIcon />
                {t('queueTypeAdd')}
              </span>
            </LoadingButton>
          </div>
        </div>

        {chamberId ? (
          chamberQuery.isPending && !chamberQuery.data ? (
            <div className="px-4 pb-6">
              <PagePreloader />
            </div>
          ) : (
          <div
            className={chamberFetching ? 'opacity-60 transition-opacity' : 'transition-opacity'}
            aria-busy={chamberFetching}
          >
            <QueueTypesTable
              types={types}
              togglingId={togglingId}
              actionsDisabled={chamberFetching || saveTypesMutation.isPending}
              onEdit={(type) => setDialog({ kind: 'editType', type })}
              onToggleEnabled={(type) => void toggleEnabled(type)}
            />
          </div>
          )
        ) : (
          <p className="px-4 pb-6 text-sm text-brand-navy/70 dark:text-white/70">{t('queueNoChamber')}</p>
        )}
      </Card>

      <p className="mt-8 text-center text-sm text-brand-navy/60 dark:text-white/60">
        {t('queueTimezoneFootnote', { zone: timeZoneLabel })}
      </p>

      {dialog?.kind === 'policy' ? (
        <QueuePolicyModal
          policy={{ ...policy, dayBoundary: policyModalBoundary }}
          chambers={chambers}
          initialChamberIds={chamberId ? [chamberId] : chambers.map((c) => c.id)}
          onClose={() => setDialog(null)}
          onSaved={(saved) => {
            applySavedStopTimes(saved)
            setDialog(null)
          }}
        />
      ) : null}
      {dialog?.kind === 'addType' ? (
        <QueueTypeFormModal
          siblings={types}
          onClose={() => setDialog(null)}
          onSubmitTypes={(next) => persistTypes(next, true)}
        />
      ) : null}
      {dialog?.kind === 'editType' ? (
        <QueueTypeFormModal
          type={dialog.type}
          siblings={types}
          onClose={() => setDialog(null)}
          onSubmitTypes={(next) => persistTypes(next, true)}
        />
      ) : null}
    </div>
  )
}
