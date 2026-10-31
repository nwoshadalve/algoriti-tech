/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { Navigate } from 'react-router-dom'
import { SetupLayout } from '@/app/SetupLayout'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { PagePreloader } from '@/core/ui/PagePreloader'
import { SetupCard } from '@/core/ui/SetupCard'
import { useAuth } from '@/features/auth/authContext'
import { dashboardHomePath } from '@/app/dashboard/dashboardHome'
import { useWorkScope } from '@/features/work/workScopeContext'

/** Receptionist picks a chamber or doctor before opening the board. */
export function WorkScopePage() {
  const { t } = useLocale()
  const { state: auth } = useAuth()
  const { state, select } = useWorkScope()

  if (auth.status !== 'signedIn') {
    return <Navigate to="/login" replace />
  }

  if (auth.account.role !== 'receptionist') {
    return <Navigate to={dashboardHomePath(auth.account.role)} replace />
  }

  if (state.status === 'idle' || state.status === 'loading') {
    return (
      <SetupLayout>
        <SetupCard labelledBy="work-scope-loading">
          <PagePreloader className="py-10" />
        </SetupCard>
      </SetupLayout>
    )
  }

  if (state.status === 'ready') {
    return <Navigate to="/board" replace />
  }

  const intro =
    state.status === 'unassigned'
      ? t('workScopeEmpty')
      : state.assignmentTarget === 'chamber'
        ? t('workScopeIntroChamber')
        : t('workScopeIntroDoctor')

  const options = state.status === 'choose' ? state.options : []

  return (
    <SetupLayout>
      <SetupCard labelledBy="work-scope-heading">
        <h1 id="work-scope-heading" className="text-xl font-bold sm:text-2xl">
          {t('workScopeTitle')}
        </h1>
        <p className="mt-2 text-sm text-brand-navy/70 dark:text-white/70">{intro}</p>
        {options.length > 0 ? (
          <ul className="mt-6 flex flex-col gap-3">
            {options.map((option) => (
              <li key={option.id}>
                <button
                  type="button"
                  className="flex w-full flex-col rounded-2xl border border-brand-navy/10 bg-white px-4 py-3 text-left shadow-sm transition-colors hover:border-brand-coral/40 hover:bg-brand-mist/50 focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none dark:border-white/10 dark:bg-brand-navy dark:hover:bg-white/5"
                  onClick={() => {
                    select(option)
                  }}
                >
                  <span className="font-semibold">{option.name}</span>
                  {option.detail ? (
                    <span className="mt-1 text-sm text-brand-navy/65 dark:text-white/65">
                      {option.detail}
                    </span>
                  ) : null}
                </button>
              </li>
            ))}
          </ul>
        ) : null}
      </SetupCard>
    </SetupLayout>
  )
}
