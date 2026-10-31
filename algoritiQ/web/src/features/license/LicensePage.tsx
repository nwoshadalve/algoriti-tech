/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { useEffect, useState } from 'react'
import { Navigate } from 'react-router-dom'
import { getLicense, listChambers } from '@/core/api/chambers'
import type { Chamber, LicenseStatus } from '@/core/api/types'
import { chambersQueryKeys } from '@/core/query/chambersQueryKeys'
import { useClinic } from '@/core/clinic/clinicContext'
import { useLocale } from '@/core/i18n/LocaleProvider'
import type { MessageKey } from '@/core/i18n/messages/types'
import { useToast } from '@/core/toast/toastContext'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { Card } from '@/core/ui/Card'
import { PlusIcon } from '@/core/ui/icons'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { PageHeader } from '@/core/ui/PageHeader'
import { PagePreloader } from '@/core/ui/PagePreloader'
import { Tooltip } from '@/core/ui/Tooltip'
import { useAuth } from '@/features/auth/authContext'
import { readSession } from '@/features/auth/session'
import { ChamberFormModal } from '@/features/license/ChamberFormModal'
import { ChambersTable } from '@/features/license/ChambersTable'
import { DeleteChamberModal } from '@/features/license/DeleteChamberModal'
import { licenseQueryKeys } from '@/features/license/licenseQueryKeys'

type Dialog = { kind: 'add' } | { kind: 'edit'; chamber: Chamber } | { kind: 'delete'; chamber: Chamber } | null

const statusKey: Record<LicenseStatus, MessageKey> = {
  active: 'licenseStatusActive',
  grace: 'licenseStatusGrace',
  expired: 'licenseStatusExpired',
}

const statusStyle: Record<LicenseStatus, string> = {
  active: 'bg-emerald-100 text-emerald-900 dark:bg-emerald-950/50 dark:text-emerald-100',
  grace: 'bg-amber-100 text-amber-900 dark:bg-amber-950/50 dark:text-amber-100',
  expired: 'bg-red-100 text-red-900 dark:bg-red-950/50 dark:text-red-100',
}

function requireSessionToken(): string {
  const token = readSession()
  if (!token) throw new Error('signed_out')
  return token
}

/** The license and the chambers it allows: add, edit and delete up to the limit. */
export function LicensePage() {
  const { t, locale } = useLocale()
  const toast = useToast()
  const queryClient = useQueryClient()
  const { state } = useAuth()
  const { licenseType } = useClinic()
  const [dialog, setDialog] = useState<Dialog>(null)
  const isAdmin = state.status === 'signedIn' && state.account.role === 'admin'
  const queriesEnabled = licenseType === 'doctor' && isAdmin

  const licenseQuery = useQuery({
    queryKey: licenseQueryKeys.summary(),
    queryFn: async () => getLicense(requireSessionToken()),
    enabled: queriesEnabled,
    retry: false,
  })

  const chambersQuery = useQuery({
    queryKey: chambersQueryKeys.list(),
    queryFn: async () => listChambers(requireSessionToken()),
    enabled: queriesEnabled,
    retry: false,
  })

  const license = licenseQuery.data
  const chambers = chambersQuery.data ?? []
  const loading =
    (licenseQuery.isPending && license === undefined) ||
    (chambersQuery.isPending && chambersQuery.data === undefined)
  const failed =
    (licenseQuery.isError && license === undefined) || (chambersQuery.isError && chambersQuery.data === undefined)

  useEffect(() => {
    if (!queriesEnabled || !licenseQuery.isFetched || !chambersQuery.isFetched || !failed) return
    toast.error(t('licenseLoadFailed'))
  }, [
    queriesEnabled,
    licenseQuery.isFetched,
    chambersQuery.isFetched,
    failed,
    t,
    toast,
  ])

  function refreshLicenseSummary() {
    void queryClient.invalidateQueries({ queryKey: licenseQueryKeys.summary() })
  }

  function mergeChamber(saved: Chamber, created: boolean) {
    queryClient.setQueryData(chambersQueryKeys.list(), (current: Chamber[] | undefined) => {
      if (created) return [...(current ?? []), saved]
      if (!current) return current
      return current.map((row) => (row.id === saved.id ? saved : row))
    })
    refreshLicenseSummary()
  }

  function dropChamber(chamberId: string) {
    queryClient.setQueryData(chambersQueryKeys.list(), (current: Chamber[] | undefined) => {
      if (!current) return current
      return current.filter((row) => row.id !== chamberId)
    })
    refreshLicenseSummary()
  }

  async function retryLoad() {
    const results = await Promise.all([licenseQuery.refetch(), chambersQuery.refetch()])
    if (results.some((result) => result.isError)) toast.error(t('licenseLoadFailed'))
  }

  // A clinic that is not licensed for one doctor has no such page.
  if (licenseType === null || licenseType === 'chamber') return <Navigate to="/home" replace />
  if (state.status === 'signedIn' && !isAdmin) {
    return <Navigate to="/home" replace />
  }

  const date = new Intl.DateTimeFormat(locale === 'bn' ? 'bn-BD' : 'en-GB', { dateStyle: 'long' })
  const full = license !== undefined && license.chambersUsed >= license.maxChambers

  return (
    <div className="min-w-0">
      <PageHeader
        title={t('navChamber')}
        description={t('licenseIntro')}
        actions={
          license ? (
            <Tooltip label={t('chambersLimitReached', { max: license.maxChambers })}>
              <LoadingButton
                disabled={full}
                onClick={() => setDialog({ kind: 'add' })}
                className="inline-flex w-full min-w-0 items-center justify-center gap-2 !min-h-11 !py-2 sm:w-auto"
              >
                <span className="inline-flex min-w-0 items-center justify-center gap-2">
                  <PlusIcon />
                  <span className="truncate">{t('chambersAdd')}</span>
                </span>
              </LoadingButton>
            </Tooltip>
          ) : undefined
        }
      />

      {failed ? (
        <Card className="text-center">
          <p className="text-sm">{t('licenseLoadFailed')}</p>
          <button type="button" className={`${secondaryButton} mt-4`} onClick={() => void retryLoad()}>
            {t('usersRetry')}
          </button>
        </Card>
      ) : loading || !license ? (
        <PagePreloader label={t('loadingLabel')} />
      ) : (
        <div className="min-w-0 space-y-6">
          <Card as="section" labelledBy="license-summary" className="min-w-0">
            <div className="flex flex-wrap items-center justify-between gap-3">
              <h2 id="license-summary" className="text-lg font-semibold">
                {t('licenseSummaryTitle')}
              </h2>
              <span className={`inline-flex rounded-full px-2.5 py-1 text-xs font-medium ${statusStyle[license.status]}`}>
                {t(statusKey[license.status])}
              </span>
            </div>
            <dl className="mt-5 grid gap-x-8 gap-y-4 text-sm sm:grid-cols-2 lg:grid-cols-4">
              <div>
                <dt className="text-brand-navy/60 dark:text-white/60">{t('licenseTypeLabel')}</dt>
                <dd className="mt-0.5 font-medium">{t('licenseTypeDoctor')}</dd>
              </div>
              <div>
                <dt className="text-brand-navy/60 dark:text-white/60">{t('licenseDoctorsLabel')}</dt>
                <dd className="mt-0.5 font-medium">{license.maxDoctors}</dd>
              </div>
              <div>
                <dt className="text-brand-navy/60 dark:text-white/60">{t('licenseIssuedLabel')}</dt>
                <dd className="mt-0.5 font-medium">{date.format(new Date(license.issuedAt))}</dd>
              </div>
              <div>
                <dt className="text-brand-navy/60 dark:text-white/60">{t('licenseExpiresLabel')}</dt>
                <dd className="mt-0.5 font-medium">
                  {license.expiresAt ? date.format(new Date(license.expiresAt)) : t('licensePerpetual')}
                </dd>
              </div>
            </dl>
            <div className="mt-6">
              <p className="flex items-baseline justify-between gap-3 text-sm">
                <span className="text-brand-navy/60 dark:text-white/60">{t('licenseChambersLabel')}</span>
                <span className="font-medium" data-testid="chambers-used">
                  {t('licenseChambersUsed', { used: license.chambersUsed, max: license.maxChambers })}
                </span>
              </p>
              <div
                className="mt-2 h-2 overflow-hidden rounded-full bg-brand-navy/10 dark:bg-white/10"
                role="progressbar"
                aria-label={t('licenseChambersLabel')}
                aria-valuemin={0}
                aria-valuemax={license.maxChambers}
                aria-valuenow={license.chambersUsed}
              >
                <div
                  className={`h-full rounded-full ${full ? 'bg-brand-coral' : 'bg-emerald-500'}`}
                  style={{ width: `${Math.min(100, (license.chambersUsed / license.maxChambers) * 100)}%` }}
                />
              </div>
            </div>
          </Card>

          <Card as="section" labelledBy="license-chambers" className="min-w-0 p-0 sm:p-0">
            <h2 id="license-chambers" className="px-4 pt-4 text-lg font-semibold sm:px-6 sm:pt-6">
              {t('chambersTitle')}
            </h2>
            {chambers.length === 0 ? (
              <p className="px-4 pb-6 pt-2 text-sm text-brand-navy/70 sm:px-6 dark:text-white/70">{t('chambersEmpty')}</p>
            ) : (
              <ChambersTable
                chambers={chambers}
                onEdit={(chamber) => setDialog({ kind: 'edit', chamber })}
                onDelete={(chamber) => setDialog({ kind: 'delete', chamber })}
              />
            )}
          </Card>
        </div>
      )}

      {dialog?.kind === 'add' ? (
        <ChamberFormModal
          onClose={() => setDialog(null)}
          onLimit={refreshLicenseSummary}
          onSaved={(saved, created) => {
            setDialog(null)
            mergeChamber(saved, created)
          }}
        />
      ) : null}
      {dialog?.kind === 'edit' ? (
        <ChamberFormModal
          chamber={dialog.chamber}
          onClose={() => setDialog(null)}
          onLimit={refreshLicenseSummary}
          onSaved={(saved, created) => {
            setDialog(null)
            mergeChamber(saved, created)
          }}
        />
      ) : null}
      {dialog?.kind === 'delete' ? (
        <DeleteChamberModal
          chamber={dialog.chamber}
          onClose={() => setDialog(null)}
          onDeleted={() => {
            setDialog(null)
            dropChamber(dialog.chamber.id)
          }}
        />
      ) : null}
    </div>
  )
}
