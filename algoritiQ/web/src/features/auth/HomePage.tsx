import { useState } from 'react'
import { Navigate, useNavigate } from 'react-router-dom'
import { SetupLayout } from '@/app/SetupLayout'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { PagePreloader } from '@/core/ui/PagePreloader'
import { SetupCard } from '@/core/ui/SetupCard'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useAuth } from '@/features/auth/authContext'

/** The signed-in area. Only the account is shown so far; queue tools come next. */
export function HomePage() {
  const { t } = useLocale()
  const { state, signOut } = useAuth()
  const navigate = useNavigate()
  const [leaving, setLeaving] = useState(false)

  if (state.status === 'loading') {
    return (
      <SetupLayout>
        <SetupCard labelledBy="loading">
          <PagePreloader className="py-10" />
        </SetupCard>
      </SetupLayout>
    )
  }
  if (state.status === 'signedOut') return <Navigate to="/login" replace />

  const { account } = state
  const name = account.displayName || account.username

  async function onSignOut() {
    setLeaving(true)
    await signOut()
    navigate('/login', { replace: true })
  }

  return (
    <SetupLayout>
      <SetupCard labelledBy="home-heading">
        <h1 id="home-heading" className="text-xl font-semibold tracking-tight sm:text-2xl">
          {t('homeWelcome', { name })}
        </h1>
        <p className="mt-2 text-sm text-brand-navy/75 dark:text-white/75">
          {t('homeSignedInAs', { username: account.username })}
        </p>
        <p className="mt-4 rounded-xl bg-brand-mist px-4 py-3 text-sm leading-relaxed text-brand-navy/80 dark:bg-brand-navy dark:text-white/80">
          {t('homeComingSoon')}
        </p>
        <LoadingButton
          isLoading={leaving}
          loadingLabel={t('signingOut')}
          onClick={onSignOut}
          className="mt-6 sm:w-auto"
        >
          {t('signOut')}
        </LoadingButton>
      </SetupCard>
    </SetupLayout>
  )
}
