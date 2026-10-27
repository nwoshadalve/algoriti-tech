import { useState } from 'react'
import { Link, Navigate, useLocation, useNavigate } from 'react-router-dom'
import { SetupLayout } from '@/app/SetupLayout'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { PagePreloader } from '@/core/ui/PagePreloader'
import { PasswordField } from '@/core/ui/PasswordField'
import { SetupCard } from '@/core/ui/SetupCard'
import { TextField } from '@/core/ui/TextField'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { AuthAside } from '@/features/auth/AuthAside'
import { authError } from '@/features/auth/authErrors'
import { useAuth } from '@/features/auth/authContext'
export function LoginPage() {
  const { t } = useLocale()
  const { state, signIn } = useAuth()
  const navigate = useNavigate()
  const location = useLocation()
  const justReset = (location.state as { passwordReset?: boolean } | null)?.passwordReset === true

  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [fieldError, setFieldError] = useState<string | null>(null)
  const [formError, setFormError] = useState<string | null>(null)
  const [submitting, setSubmitting] = useState(false)

  if (state.status === 'signedIn') return <Navigate to="/home" replace />

  async function onSubmit(event: React.FormEvent) {
    event.preventDefault()
    if (!username.trim() || !password) {
      setFieldError(t('errorLoginRequired'))
      return
    }
    setFieldError(null)
    setFormError(null)
    setSubmitting(true)
    try {
      await signIn(username, password)
      navigate('/home', { replace: true })
    } catch (error) {
      const { key, params } = authError(error)
      setFormError(t(key, params))
      setPassword('')
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <SetupLayout aside={<AuthAside />}>
      {state.status === 'loading' ? (
        <SetupCard labelledBy="loading">
          <PagePreloader className="py-10" />
        </SetupCard>
      ) : (
        <SetupCard labelledBy="login-heading">
          <h1 id="login-heading" className="text-2xl font-semibold tracking-tight">
            {t('loginTitle')}
          </h1>
          <p className="mt-2 text-sm leading-relaxed text-brand-navy/75 dark:text-white/75">
            {t('loginIntro')}
          </p>

          {justReset ? (
            <div
              role="status"
              className="mt-4 rounded-xl border border-emerald-300/80 bg-emerald-50 px-3 py-2.5 text-sm text-emerald-950 dark:border-emerald-500/40 dark:bg-emerald-950/40 dark:text-emerald-100"
            >
              {t('noticePasswordReset')}
            </div>
          ) : null}
          {formError ? (
            <div
              role="alert"
              className="mt-4 rounded-xl border border-amber-300/80 bg-amber-50 px-3 py-2.5 text-sm text-amber-950 dark:border-amber-500/40 dark:bg-amber-950/40 dark:text-amber-100"
            >
              {formError}
            </div>
          ) : null}

          <form className="mt-6 space-y-4" onSubmit={onSubmit} noValidate>
            <TextField
              id="username"
              name="username"
              label={t('fieldUsername')}
              autoComplete="username"
              autoCapitalize="none"
              spellCheck={false}
              value={username}
              onChange={(e) => {
                setUsername(e.target.value)
                setFieldError(null)
              }}
            />
            <PasswordField
              id="password"
              name="password"
              label={t('fieldPassword')}
              autoComplete="current-password"
              value={password}
              error={fieldError ?? undefined}
              onChange={(e) => {
                setPassword(e.target.value)
                setFieldError(null)
              }}
            />
            <LoadingButton
              type="submit"
              isLoading={submitting}
              loadingLabel={t('loginSubmitting')}
              className="mt-2"
            >
              {t('loginSubmit')}
            </LoadingButton>
          </form>

          <p className="mt-5 text-center text-sm">
            <Link
              to="/forgot-password"
              className="inline-flex min-h-11 items-center px-3 font-medium text-brand-coral-action underline-offset-2 hover:underline"
            >
              {t('forgotPasswordLink')}
            </Link>
          </p>
        </SetupCard>
      )}
    </SetupLayout>
  )
}
