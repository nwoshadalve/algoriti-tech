/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useCallback, useEffect, useState } from 'react'
import { Navigate } from 'react-router-dom'
import { getLicense, listChambers } from '@/core/api/chambers'
import type { Chamber, LicenseStatus, LicenseSummary } from '@/core/api/types'
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

type Loaded = { license: LicenseSummary; chambers: Chamber[] }
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

/** The license and the chambers it allows: add, edit and delete up to the limit. */
export function LicensePage() {
  const { t, locale } = useLocale()
  const toast = useToast()
  const { state } = useAuth()
  const { licenseType } = useClinic()
  const [loaded, setLoaded] = useState<Loaded | null>(null)
  const [failed, setFailed] = useState(false)
  const [dialog, setDialog] = useState<Dialog>(null)
  const isAdmin = state.status === 'signedIn' && state.account.role === 'admin'

  const load = useCallback(async () => {
    const token = readSession()
    if (!token) return
    try {
      const [license, chambers] = await Promise.all([getLicense(token), listChambers(token)])
      setLoaded({ license, chambers })
      setFailed(false)
    } catch {
      setFailed(true)
      toast.error(t('licenseLoadFailed'))
    }
    // The toast and translate functions are stable for the page's life.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  useEffect(() => {
    if (licenseType !== 'doctor' || !isAdmin) return
    // Fetch on arrival; the answer sets the state.
    // eslint-disable-next-line react-hooks/set-state-in-effect
    void load()
  }, [licenseType, isAdmin, load])

  // A clinic that is not licensed for one doctor has no such page.
  if (licenseType === null || licenseType === 'chamber') return <Navigate to="/home" replace />
  if (state.status === 'signedIn' && !isAdmin) {
    return <Navigate to="/home" replace />
  }

  const date = new Intl.DateTimeFormat(locale === 'bn' ? 'bn-BD' : 'en-GB', { dateStyle: 'long' })
  const full = loaded !== null && loaded.license.chambersUsed >= loaded.license.maxChambers

  return (
    <div>
      <PageHeader title={t('navLicense')} description={t('licenseIntro')} />

      {failed && !loaded ? (
        <Card className="text-center">
          <p className="text-sm">{t('licenseLoadFailed')}</p>
          <button type="button" className={`${secondaryButton} mt-4`} onClick={() => void load()}>
            {t('usersRetry')}
          </button>
        </Card>
      ) : !loaded ? (
        <PagePreloader label={t('loadingLabel')} />
      ) : (
        <div className="space-y-6">
          <Card as="section" labelledBy="license-summary">
            <div className="flex flex-wrap items-center justify-between gap-3">
              <h2 id="license-summary" className="text-lg font-semibold">
                {t('licenseSummaryTitle')}
              </h2>
              <span className={`inline-flex rounded-full px-2.5 py-1 text-xs font-medium ${statusStyle[loaded.license.status]}`}>
                {t(statusKey[loaded.license.status])}
              </span>
            </div>
            <dl className="mt-5 grid gap-x-8 gap-y-4 text-sm sm:grid-cols-2 lg:grid-cols-4">
              <div>
                <dt className="text-brand-navy/60 dark:text-white/60">{t('licenseTypeLabel')}</dt>
                <dd className="mt-0.5 font-medium">{t('licenseTypeDoctor')}</dd>
              </div>
              <div>
                <dt className="text-brand-navy/60 dark:text-white/60">{t('licenseDoctorsLabel')}</dt>
                <dd className="mt-0.5 font-medium">{loaded.license.maxDoctors}</dd>
              </div>
              <div>
                <dt className="text-brand-navy/60 dark:text-white/60">{t('licenseIssuedLabel')}</dt>
                <dd className="mt-0.5 font-medium">{date.format(new Date(loaded.license.issuedAt))}</dd>
              </div>
              <div>
                <dt className="text-brand-navy/60 dark:text-white/60">{t('licenseExpiresLabel')}</dt>
                <dd className="mt-0.5 font-medium">
                  {loaded.license.expiresAt ? date.format(new Date(loaded.license.expiresAt)) : t('licensePerpetual')}
                </dd>
              </div>
            </dl>
            <div className="mt-6">
              <p className="flex items-baseline justify-between gap-3 text-sm">
                <span className="text-brand-navy/60 dark:text-white/60">{t('licenseChambersLabel')}</span>
                <span className="font-medium" data-testid="chambers-used">
                  {t('licenseChambersUsed', { used: loaded.license.chambersUsed, max: loaded.license.maxChambers })}
                </span>
              </p>
              <div
                className="mt-2 h-2 overflow-hidden rounded-full bg-brand-navy/10 dark:bg-white/10"
                role="progressbar"
                aria-label={t('licenseChambersLabel')}
                aria-valuemin={0}
                aria-valuemax={loaded.license.maxChambers}
                aria-valuenow={loaded.license.chambersUsed}
              >
                <div
                  className={`h-full rounded-full ${full ? 'bg-brand-coral' : 'bg-emerald-500'}`}
                  style={{ width: `${Math.min(100, (loaded.license.chambersUsed / loaded.license.maxChambers) * 100)}%` }}
                />
              </div>
            </div>
          </Card>

          <Card as="section" labelledBy="license-chambers" className="p-0 sm:p-0">
            <div className="flex flex-wrap items-center justify-between gap-3 px-4 py-4">
              <h2 id="license-chambers" className="text-lg font-semibold">
                {t('chambersTitle')}
              </h2>
              <Tooltip label={t('chambersLimitReached', { max: loaded.license.maxChambers })}>
                <LoadingButton
                  disabled={full}
                  onClick={() => setDialog({ kind: 'add' })}
                  className="inline-flex w-auto items-center justify-center gap-2 !min-h-11 !py-2"
                >
                  <span className="inline-flex items-center gap-2">
                    <PlusIcon />
                    {t('chambersAdd')}
                  </span>
                </LoadingButton>
              </Tooltip>
            </div>
            {loaded.chambers.length === 0 ? (
              <p className="px-4 pb-6 text-sm text-brand-navy/70 dark:text-white/70">{t('chambersEmpty')}</p>
            ) : (
              <ChambersTable
                chambers={loaded.chambers}
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
          onLimit={() => void load()}
          onSaved={() => {
            setDialog(null)
            void load()
          }}
        />
      ) : null}
      {dialog?.kind === 'edit' ? (
        <ChamberFormModal
          chamber={dialog.chamber}
          onClose={() => setDialog(null)}
          onLimit={() => void load()}
          onSaved={() => {
            setDialog(null)
            void load()
          }}
        />
      ) : null}
      {dialog?.kind === 'delete' ? (
        <DeleteChamberModal
          chamber={dialog.chamber}
          onClose={() => setDialog(null)}
          onDeleted={() => {
            setDialog(null)
            void load()
          }}
        />
      ) : null}
    </div>
  )
}
