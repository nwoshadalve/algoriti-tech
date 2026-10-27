import { useEffect, useState } from 'react'
import { Navigate, useNavigate } from 'react-router-dom'
import { SetupLayout } from '@/app/SetupLayout'
import { SetupAside } from '@/features/setup/SetupAside'
import { SetupProgress } from '@/features/setup/SetupProgress'
import { SetupCard } from '@/core/ui/SetupCard'
import { PagePreloader } from '@/core/ui/PagePreloader'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { PasswordField } from '@/core/ui/PasswordField'
import { registerAdmin, getSetupStatus, verifyClaimCode } from '@/core/api/setup'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { TextField } from '@/core/ui/TextField'
import {
  clearClaimCode,
  isClaimCodeVerified,
  readClaimCode,
  setActivationFlash,
} from '@/features/setup/claimCodeSession'
import {
  hasFieldErrors,
  validateRegistration,
  type FieldErrors,
  type RegistrationFields,
} from '@/features/setup/adminRegistrationValidation'
import {
  isClaimCodeApiError,
  setupErrorKey,
  setupErrorParams,
} from '@/features/setup/setupErrorMessages'
import type { Account } from '@/core/api/types'

const emptyFields: RegistrationFields = {
  firstName: '',
  lastName: '',
  email: '',
  username: '',
  password: '',
  confirmPassword: '',
}

type PagePhase =
  | { kind: 'loading' }
  | { kind: 'register' }
  | { kind: 'success'; account: Account }

export function AdminRegistrationPage() {
  const { t } = useLocale()
  const navigate = useNavigate()
  // Read once: registering clears the saved code, and reading it again on the
  // next render would send the admin back to the start instead of showing the
  // success message.
  const [claimCode] = useState(readClaimCode)
  const [phase, setPhase] = useState<PagePhase>({ kind: 'loading' })
  const [fields, setFields] = useState<RegistrationFields>(emptyFields)
  const [fieldErrors, setFieldErrors] = useState<FieldErrors>({})
  const [formError, setFormError] = useState<string | null>(null)
  const [submitting, setSubmitting] = useState(false)

  useEffect(() => {
    let cancelled = false
    void (async () => {
      if (!claimCode) return
      try {
        const status = await getSetupStatus()
        if (cancelled) return
        if (status.adminRegistered) {
          navigate('/login', { replace: true })
          return
        }
        await verifyClaimCode(claimCode)
        if (cancelled) return
        setPhase({ kind: 'register' })
      } catch (error) {
        if (cancelled) return
        if (isClaimCodeApiError(error)) {
          clearClaimCode()
          setActivationFlash(t(setupErrorKey(error), setupErrorParams(error)))
          navigate('/', { replace: true })
          return
        }
        if (setupErrorKey(error) === 'errorAdminAlreadyRegistered') {
          navigate('/login', { replace: true })
          return
        }
        setPhase({ kind: 'register' })
        setFormError(t('errorStatusCheck'))
      }
    })()
    return () => {
      cancelled = true
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps -- mount only
  }, [])

  function updateField<K extends keyof RegistrationFields>(key: K, value: RegistrationFields[K]) {
    setFields((prev) => ({ ...prev, [key]: value }))
    setFieldErrors((prev) => {
      if (!prev[key]) return prev
      const next = { ...prev }
      delete next[key]
      return next
    })
    setFormError(null)
  }

  async function onSubmit(event: React.FormEvent) {
    event.preventDefault()
    const errors = validateRegistration(fields)
    setFieldErrors(errors)
    if (hasFieldErrors(errors) || !claimCode) {
      return
    }

    setSubmitting(true)
    setFormError(null)
    try {
      const account = await registerAdmin({
        claimCode,
        username: fields.username.trim().toLowerCase(),
        firstName: fields.firstName.trim(),
        lastName: fields.lastName.trim(),
        email: fields.email.trim(),
        password: fields.password,
      })
      clearClaimCode()
      setPhase({ kind: 'success', account })
    } catch (error) {
      const key = setupErrorKey(error)
      if (isClaimCodeApiError(error)) {
        clearClaimCode()
        setActivationFlash(t(key, setupErrorParams(error)))
        navigate('/', { replace: true })
        return
      }
      if (key === 'errorAdminAlreadyRegistered') {
        navigate('/login', { replace: true })
        return
      }
      setFormError(t(key, setupErrorParams(error)))
    } finally {
      setSubmitting(false)
    }
  }

  if (phase.kind !== 'success' && (!isClaimCodeVerified() || !claimCode)) {
    return <Navigate to="/" replace />
  }

  const showSteps = phase.kind === 'register'

  return (
    <SetupLayout
      aside={showSteps ? <SetupAside activeStep={3} /> : undefined}
      mobileHeader={showSteps ? <SetupProgress activeStep={3} /> : undefined}
    >
      {phase.kind === 'loading' ? <LoadingCard /> : null}
      {phase.kind === 'success' ? <SuccessCard account={phase.account} /> : null}
      {phase.kind === 'register' ? (
        <RegistrationCard
          fields={fields}
          fieldErrors={fieldErrors}
          formError={formError}
          submitting={submitting}
          onFieldChange={updateField}
          onSubmit={onSubmit}
        />
      ) : null}
    </SetupLayout>
  )
}

function LoadingCard() {
  return (
    <SetupCard labelledBy="loading-label">
      <PagePreloader className="py-10" />
    </SetupCard>
  )
}

type RegistrationCardProps = {
  fields: RegistrationFields
  fieldErrors: FieldErrors
  formError: string | null
  submitting: boolean
  onFieldChange: <K extends keyof RegistrationFields>(key: K, value: RegistrationFields[K]) => void
  onSubmit: (event: React.FormEvent) => void
}

function RegistrationCard({
  fields,
  fieldErrors,
  formError,
  submitting,
  onFieldChange,
  onSubmit,
}: RegistrationCardProps) {
  const { t } = useLocale()

  return (
    <SetupCard labelledBy="register-heading">
      <h1 id="register-heading" className="text-2xl font-semibold tracking-tight">
        <span className="lg:hidden">{t('registerTitle')}</span>
        <span className="hidden lg:inline">{t('registerFormHeading')}</span>
      </h1>
      <p className="mt-2 text-sm leading-relaxed text-brand-navy/75 dark:text-white/75 lg:hidden">
        {t('registerIntro')}
      </p>

      {formError ? (
        <div
          role="alert"
          className="mt-4 rounded-xl border border-amber-300/80 bg-amber-50 px-3 py-2.5 text-sm text-amber-950 dark:border-amber-500/40 dark:bg-amber-950/40 dark:text-amber-100"
        >
          {formError}
        </div>
      ) : null}

      <form className="mt-6 space-y-4 lg:mt-8" onSubmit={onSubmit} noValidate>
        <div className="grid gap-4 sm:grid-cols-2">
          <TextField
            id="firstName"
            name="firstName"
            label={t('fieldFirstName')}
            autoComplete="given-name"
            value={fields.firstName}
            error={fieldErrors.firstName ? t(fieldErrors.firstName) : undefined}
            onChange={(e) => onFieldChange('firstName', e.target.value)}
          />
          <TextField
            id="lastName"
            name="lastName"
            label={t('fieldLastName')}
            autoComplete="family-name"
            value={fields.lastName}
            error={fieldErrors.lastName ? t(fieldErrors.lastName) : undefined}
            onChange={(e) => onFieldChange('lastName', e.target.value)}
          />
        </div>

        <TextField
          id="email"
          name="email"
          type="email"
          label={t('fieldEmail')}
          autoComplete="email"
          spellCheck={false}
          value={fields.email}
          error={fieldErrors.email ? t(fieldErrors.email) : undefined}
          onChange={(e) => onFieldChange('email', e.target.value)}
        />

        <TextField
          id="username"
          name="username"
          label={t('fieldUsername')}
          hint={t('fieldUsernameHint')}
          autoComplete="username"
          spellCheck={false}
          value={fields.username}
          error={fieldErrors.username ? t(fieldErrors.username) : undefined}
          onChange={(e) => onFieldChange('username', e.target.value)}
        />

        <PasswordField
          id="password"
          name="password"
          label={t('fieldPassword')}
          hint={t('fieldPasswordHint')}
          autoComplete="new-password"
          value={fields.password}
          error={fieldErrors.password ? t(fieldErrors.password) : undefined}
          onChange={(e) => onFieldChange('password', e.target.value)}
        />

        <PasswordField
          id="confirmPassword"
          name="confirmPassword"
          label={t('fieldConfirmPassword')}
          autoComplete="new-password"
          value={fields.confirmPassword}
          error={fieldErrors.confirmPassword ? t(fieldErrors.confirmPassword) : undefined}
          onChange={(e) => onFieldChange('confirmPassword', e.target.value)}
        />

        <LoadingButton
          type="submit"
          isLoading={submitting}
          loadingLabel={t('registerSubmitting')}
          className="mt-2"
        >
          {t('registerSubmit')}
        </LoadingButton>
      </form>
    </SetupCard>
  )
}

function SuccessCard({ account }: { account: Account }) {
  const { t } = useLocale()
  const navigate = useNavigate()
  const name = account.displayName || account.username
  return (
    <SetupCard labelledBy="success-title">
      <h1 id="success-title" className="text-2xl font-semibold">
        {t('successTitle')}
      </h1>
      <p className="mt-3 text-sm leading-relaxed text-brand-navy/75 dark:text-white/75">
        {t('successBody', { name })}
      </p>
      <button
        type="button"
        onClick={() => navigate('/login', { replace: true })}
        className="mt-6 w-full rounded-lg bg-brand-coral-action px-4 py-3 text-base font-semibold text-white shadow-sm hover:opacity-95 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-coral sm:w-auto"
      >
        {t('goToSignIn')}
      </button>
    </SetupCard>
  )
}
